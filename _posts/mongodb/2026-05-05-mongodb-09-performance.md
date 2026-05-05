---
title: "[MongoDB] 09. 성능 튜닝과 모니터링"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 고급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 성능 분석, 쿼리 최적화, 서버 튜닝, 모니터링을 정리합니다.

# 쿼리 성능 분석

## explain()
```javascript
// 실행 계획 확인
db.users.find({ dept: "개발팀", salary: { $gte: 5000000 } }).explain("executionStats")
```

### 핵심 지표

| 지표 | 의미 | 목표 |
|------|------|------|
| totalDocsExamined | 검사한 문서 수 | nReturned에 가까울수록 좋음 |
| totalKeysExamined | 검사한 인덱스 키 수 | nReturned에 가까울수록 좋음 |
| executionTimeMillis | 실행 시간 | 작을수록 좋음 |
| stage: COLLSCAN | 전체 스캔 | 인덱스 추가 필요 |
| stage: IXSCAN | 인덱스 사용 | 좋음 |

### 비효율 쿼리 판별
```javascript
// 비효율: 10000개 검사해서 10개 반환
// totalDocsExamined: 10000, nReturned: 10 → 인덱스 필요

// 효율: 10개 검사해서 10개 반환
// totalDocsExamined: 10, nReturned: 10 → 최적
```

---

## 쿼리 최적화 기법

### 1. 적절한 인덱스 생성
```javascript
// ❌ COLLSCAN
db.orders.find({ user_id: "u123", status: "pending" }).sort({ created_at: -1 })

// ✅ 복합 인덱스 (ESR 규칙)
db.orders.createIndex({ user_id: 1, created_at: -1, status: 1 })
```

### 2. 프로젝션으로 필요한 필드만 조회
```javascript
// ❌ 전체 문서 반환
db.users.find({ dept: "개발팀" })

// ✅ 필요한 필드만
db.users.find({ dept: "개발팀" }, { name: 1, email: 1, _id: 0 })
```

### 3. 커버링 인덱스 활용
```javascript
// 인덱스에 포함된 필드만 조회하면 문서 접근 불필요
db.users.createIndex({ dept: 1, name: 1, salary: 1 })
db.users.find({ dept: "개발팀" }, { name: 1, salary: 1, _id: 0 })
// explain → stage: PROJECTION_COVERED (최고 성능)
```

### 4. $in 대신 여러 쿼리 또는 인덱스 활용
```javascript
// 큰 $in 배열은 성능 저하 가능
db.users.find({ _id: { $in: [/* 수천 개 ID */] } })

// 배치 처리 권장
```

### 5. 대량 쓰기 최적화
```javascript
// ❌ 개별 삽입
for (let i = 0; i < 10000; i++) {
    db.logs.insertOne({ msg: `log ${i}` })
}

// ✅ 벌크 삽입
const bulk = db.logs.initializeUnorderedBulkOp()
for (let i = 0; i < 10000; i++) {
    bulk.insert({ msg: `log ${i}` })
}
bulk.execute()

// ✅ insertMany
db.logs.insertMany(docs, { ordered: false })
```

---

## 서버 설정 튜닝

### WiredTiger 캐시 (mongod.conf)
```yaml
storage:
  wiredTiger:
    engineConfig:
      # 캐시 크기 (기본: RAM의 50% - 1GB, 또는 256MB 중 큰 값)
      cacheSizeGB: 4
```

### 연결 설정
```yaml
net:
  maxIncomingConnections: 65536
```

### 프로파일러 (슬로우 쿼리 기록)
```javascript
// 프로파일러 활성화 (100ms 이상 기록)
db.setProfilingLevel(1, { slowms: 100 })

// 프로파일러 상태 확인
db.getProfilingStatus()

// 슬로우 쿼리 조회
db.system.profile.find().sort({ ts: -1 }).limit(10)

// 프로파일러 비활성화
db.setProfilingLevel(0)
```

---

## 모니터링

### 서버 상태
```javascript
db.serverStatus()                    // 전체 서버 상태
db.serverStatus().connections        // 연결 정보
db.serverStatus().opcounters         // 명령 카운터
db.serverStatus().wiredTiger.cache   // 캐시 상태
```

### mongostat / mongotop
```bash
# 실시간 서버 통계 (1초 간격)
mongostat --uri="mongodb://admin:pass@localhost:27017"

# 컬렉션별 읽기/쓰기 시간
mongotop --uri="mongodb://admin:pass@localhost:27017"
```

### 핵심 모니터링 지표

| 지표 | 확인 방법 | 정상 범위 |
|------|----------|----------|
| 연결 수 | `db.serverStatus().connections` | maxConnections 이하 |
| 캐시 히트율 | WiredTiger cache stats | 95% 이상 |
| 큐 대기 | `db.serverStatus().globalLock` | 0에 가까울수록 |
| Oplog 크기 | `rs.printReplicationInfo()` | 24시간 이상 보존 |
| 디스크 사용량 | `db.stats()` | 여유 공간 20% 이상 |
| 슬로우 쿼리 | `system.profile` | 최소화 |

### 컬렉션/DB 크기 확인
```javascript
// 데이터베이스 크기
db.stats()

// 컬렉션 크기
db.users.stats()

// 사람이 읽기 쉬운 형태
db.users.stats({ scale: 1024 * 1024 })  // MB 단위
```

---

## 성능 체크리스트

| 단계 | 점검 항목 | 확인 방법 |
|------|----------|----------|
| 1 | 프로파일러로 슬로우 쿼리 식별 | `db.setProfilingLevel(1)` |
| 2 | explain으로 실행 계획 분석 | COLLSCAN 여부 확인 |
| 3 | 인덱스 추가/최적화 | ESR 규칙 적용 |
| 4 | 미사용 인덱스 제거 | `$indexStats` |
| 5 | 스키마 설계 검토 | Embedding vs Referencing |
| 6 | WiredTiger 캐시 확인 | 히트율 95% 이상 |
| 7 | 연결 풀 설정 | 애플리케이션 커넥션 풀 |
| 8 | Write Concern 적정성 | 용도에 맞는 수준 |
| 9 | 컬렉션 크기 확인 | 대용량 컬렉션 샤딩 검토 |
| 10 | 정기적 compact | 단편화 해소 |

```javascript
// 컬렉션 단편화 해소 (운영 주의: 락 발생)
db.runCommand({ compact: "users" })
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
