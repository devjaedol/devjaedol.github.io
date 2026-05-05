---
title: "[MongoDB] 07. 보안과 사용자 관리"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 중급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 인증, 권한 관리, 보안 설정을 정리합니다.

# 인증 활성화

MongoDB는 기본적으로 인증이 비활성화되어 있습니다. 운영 환경에서는 반드시 활성화해야 합니다.

## 초기 관리자 생성
```javascript
// admin 데이터베이스에서 관리자 생성
use admin
db.createUser({
    user: "admin",
    pwd: "AdminPass123!",
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase"]
})
```

## 인증 활성화 (mongod.conf)
```yaml
security:
  authorization: enabled
```

```bash
# 서비스 재시작
sudo systemctl restart mongod
```

## 인증 접속
```bash
mongosh -u admin -p AdminPass123! --authenticationDatabase admin
# 또는
mongosh "mongodb://admin:AdminPass123!@localhost:27017/admin"
```

---

## 사용자 관리

### 사용자 생성
```javascript
use mydb
db.createUser({
    user: "devuser",
    pwd: "DevPass123!",
    roles: [
        { role: "readWrite", db: "mydb" }
    ]
})

// 여러 DB 권한
db.createUser({
    user: "appuser",
    pwd: "AppPass123!",
    roles: [
        { role: "readWrite", db: "production" },
        { role: "read", db: "analytics" }
    ]
})
```

### 사용자 조회/수정/삭제
```javascript
// 사용자 목록
use admin
db.getUsers()

// 특정 사용자 정보
db.getUser("devuser")

// 비밀번호 변경
db.changeUserPassword("devuser", "NewPass456!")

// 역할 추가
db.grantRolesToUser("devuser", [{ role: "dbAdmin", db: "mydb" }])

// 역할 제거
db.revokeRolesFromUser("devuser", [{ role: "dbAdmin", db: "mydb" }])

// 사용자 삭제
db.dropUser("devuser")
```

---

## 내장 역할 (Built-in Roles)

### 데이터베이스 수준

| 역할 | 설명 |
|------|------|
| read | 읽기 전용 |
| readWrite | 읽기 + 쓰기 |
| dbAdmin | 인덱스, 통계, 컬렉션 관리 |
| dbOwner | readWrite + dbAdmin + userAdmin |
| userAdmin | 사용자/역할 관리 |

### 클러스터 수준

| 역할 | 설명 |
|------|------|
| clusterAdmin | 클러스터 관리 |
| clusterManager | 클러스터 모니터링/관리 |
| clusterMonitor | 클러스터 모니터링 (읽기 전용) |
| hostManager | 서버 관리 |

### 모든 데이터베이스

| 역할 | 설명 |
|------|------|
| readAnyDatabase | 모든 DB 읽기 |
| readWriteAnyDatabase | 모든 DB 읽기/쓰기 |
| userAdminAnyDatabase | 모든 DB 사용자 관리 |
| dbAdminAnyDatabase | 모든 DB 관리 |

### 슈퍼유저

| 역할 | 설명 |
|------|------|
| root | 모든 권한 (최고 관리자) |

---

## 사용자 정의 역할
```javascript
use admin
db.createRole({
    role: "appReadOnly",
    privileges: [
        {
            resource: { db: "mydb", collection: "" },  // 모든 컬렉션
            actions: ["find", "listCollections", "listIndexes"]
        }
    ],
    roles: []
})

// 사용자에게 커스텀 역할 부여
db.createUser({
    user: "reporter",
    pwd: "ReportPass!",
    roles: [{ role: "appReadOnly", db: "admin" }]
})
```

---

## 네트워크 보안

### mongod.conf 설정
```yaml
# 바인드 주소 제한
net:
  port: 27017
  bindIp: 127.0.0.1,192.168.1.100    # 특정 IP만 허용
  # bindIp: 0.0.0.0                   # 모든 인터페이스 (주의)

# TLS/SSL 활성화
net:
  tls:
    mode: requireTLS
    certificateKeyFile: /etc/ssl/mongodb.pem
    CAFile: /etc/ssl/ca.pem
```

### 방화벽 설정
```bash
# Ubuntu (ufw)
sudo ufw allow from 192.168.1.0/24 to any port 27017

# CentOS (firewalld)
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="27017" protocol="tcp" accept'
```

---

## 보안 체크리스트

| 항목 | 설명 |
|------|------|
| 인증 활성화 | `authorization: enabled` |
| 강력한 비밀번호 | 복잡도 높은 비밀번호 사용 |
| 최소 권한 원칙 | 필요한 권한만 부여 |
| 네트워크 제한 | `bindIp`로 접근 IP 제한 |
| TLS/SSL | 전송 암호화 |
| 감사 로그 | Enterprise에서 감사 로그 활성화 |
| 포트 변경 | 기본 27017 대신 다른 포트 사용 |
| 최신 버전 유지 | 보안 패치 적용 |

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
