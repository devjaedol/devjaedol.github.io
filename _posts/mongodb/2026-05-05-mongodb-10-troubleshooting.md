---
title: "[MongoDB] 10. 자주 발생하는 Troubleshooting"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 고급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB 운영 중 자주 발생하는 문제와 해결 방법을 빈도순으로 정리합니다.

# 접속 오류

## Authentication failed

```text
MongoServerError: Authentication failed
```

| 원인 | 해결 |
|------|------|
| 비밀번호 오류 | 비밀번호 재확인 |
| authenticationDatabase 미지정 | `--authenticationDatabase admin` 추가 |
| 사용자 미존재 | `db.getUsers()`로 확인 |

```bash
# 올바른 접속
mongosh -u admin -p AdminPass123! --authenticationDatabase admin
```

## Connection refused

| 원인 | 해결 |
|------|------|
| 서비스 미실행 | `sudo systemctl start mongod` |
| bindIp 설정 | `mongod.conf`에서 `bindIp` 확인 |
| 포트 불일치 | 기본 27017 확인 |
| 방화벽 | 27017 포트 허용 |

```bash
# 서비스 상태 확인
sudo systemctl status mongod

# 로그 확인
sudo tail -50 /var/log/mongodb/mongod.log
```

---

## 쿼리 성능 저하

### 증상
- 특정 쿼리가 갑자기 느려짐
- 전체적인 응답 시간 증가

### 점검 순서

| 순서 | 점검 항목 | 확인 방법 |
|:----:|----------|----------|
| 1 | 현재 실행 중인 쿼리 | `db.currentOp()` |
| 2 | 슬로우 쿼리 확인 | `db.system.profile.find()` |
| 3 | 실행 계획 분석 | `.explain("executionStats")` |
| 4 | 인덱스 확인 | COLLSCAN 여부 |
| 5 | 컬렉션 크기 | `db.collection.stats()` |
| 6 | 서버 리소스 | `db.serverStatus()` |

```javascript
// 현재 실행 중인 느린 쿼리 확인
db.currentOp({ "secs_running": { $gte: 5 } })

// 느린 쿼리 강제 종료
db.killOp(opId)
```

---

## 디스크 용량 부족

### 확인
```javascript
// DB 크기 확인
db.stats()

// 컬렉션별 크기
db.getCollectionNames().forEach(function(c) {
    var stats = db.getCollection(c).stats();
    print(c + ": " + (stats.storageSize / 1024 / 1024).toFixed(2) + " MB");
})
```

### 해결

| 방법 | 명령어 |
|------|--------|
| 불필요한 데이터 삭제 | `db.logs.deleteMany({ date: { $lt: ... } })` |
| TTL 인덱스 설정 | 자동 만료 삭제 |
| compact 실행 | `db.runCommand({ compact: "collection" })` |
| 오래된 컬렉션 삭제 | `db.old_logs.drop()` |
| Oplog 크기 축소 | `replSetResizeOplog` |

```javascript
// TTL 인덱스로 30일 이전 자동 삭제
db.logs.createIndex({ created_at: 1 }, { expireAfterSeconds: 2592000 })
```

---

## 문서 크기 초과 (16MB)

```text
BSONObjectTooLarge: object to insert too large
```

MongoDB 문서의 최대 크기는 16MB입니다.

### 해결

| 방법 | 설명 |
|------|------|
| 배열 분리 | 큰 배열을 별도 컬렉션으로 |
| GridFS 사용 | 대용량 파일 저장 |
| Bucket 패턴 | 시계열 데이터 분할 |
| Subset 패턴 | 자주 쓰는 데이터만 내장 |

```javascript
// GridFS로 대용량 파일 저장
// mongofiles를 사용하거나 드라이버의 GridFS API 활용
```

---

## Replica Set 문제

### Primary 선출 실패

```text
No primary found in replica set
```

| 원인 | 해결 |
|------|------|
| 과반수 노드 다운 | 노드 복구 |
| 네트워크 분리 | 네트워크 확인 |
| 설정 오류 | `rs.conf()` 확인 |

```javascript
// Replica Set 상태 확인
rs.status()

// 강제 재설정 (비상 시, 데이터 유실 가능)
rs.reconfig(cfg, { force: true })
```

### 복제 지연

```javascript
// 복제 지연 확인
rs.printSecondaryReplicationInfo()

// Oplog 크기 확인 (보존 시간)
rs.printReplicationInfo()
```

| 원인 | 해결 |
|------|------|
| Secondary 성능 부족 | 하드웨어 업그레이드 |
| 네트워크 대역폭 | 네트워크 확인 |
| 대량 쓰기 | 쓰기 분산 또는 배치 크기 조정 |
| Oplog 크기 부족 | Oplog 크기 증가 |

---

## 메모리 부족 (OOM)

### 확인
```bash
# 시스템 로그에서 OOM 확인
dmesg | grep -i "oom\|killed"

# MongoDB 메모리 사용량
db.serverStatus().wiredTiger.cache
```

### 해결

| 방법 | 설명 |
|------|------|
| WiredTiger 캐시 축소 | `cacheSizeGB` 조정 |
| 인덱스 크기 확인 | 불필요한 인덱스 제거 |
| 연결 수 제한 | `maxIncomingConnections` |
| 쿼리 최적화 | 대용량 정렬/집계 최적화 |

```yaml
# mongod.conf
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 2    # 서버 메모리에 맞게 조정
```

---

## 쓰기 충돌 (Write Conflict)

```text
WriteConflict: this operation conflicted with another operation
```

동시에 같은 문서를 수정하려 할 때 발생합니다. MongoDB는 자동으로 재시도합니다.

### 해결
- 트랜잭션 범위 최소화
- 핫스팟 문서 설계 개선
- 애플리케이션에서 재시도 로직 구현

---

## 커서 타임아웃

```text
CursorNotFound: cursor id ... not found
```

기본 10분 동안 사용하지 않으면 커서가 만료됩니다.

```javascript
// noCursorTimeout 옵션 (주의: 수동 close 필수)
const cursor = db.users.find().noCursorTimeout()
// 작업 완료 후
cursor.close()

// 배치 크기 조정
db.users.find().batchSize(1000)
```

---

## 트러블슈팅 필수 명령어 요약

```javascript
// 서버 상태
db.serverStatus()

// 현재 실행 중인 작업
db.currentOp()

// 느린 작업 종료
db.killOp(opId)

// 프로파일러 (슬로우 쿼리)
db.setProfilingLevel(1, { slowms: 100 })
db.system.profile.find().sort({ ts: -1 }).limit(5)

// Replica Set 상태
rs.status()

// 컬렉션 통계
db.collection.stats()

// 인덱스 사용 통계
db.collection.aggregate([{ $indexStats: {} }])

// 로그 파일 위치
db.adminCommand({ getLog: "global" })

// 연결 정보
db.serverStatus().connections
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
