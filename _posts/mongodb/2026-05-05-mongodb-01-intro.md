---
title: "[MongoDB] 01. MongoDB 소개 및 설치"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 초급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 기본 개념, 특징, 설치 방법을 알아봅니다.

# MongoDB란?

MongoDB는 문서(Document) 지향 NoSQL 데이터베이스입니다.    
JSON과 유사한 BSON(Binary JSON) 형식으로 데이터를 저장하며, 유연한 스키마와 수평 확장을 제공합니다.

## RDBMS vs MongoDB 비교

| 항목 | RDBMS (MySQL 등) | MongoDB |
|:---:|:---:|:---:|
| 데이터 모델 | 테이블/행/열 (관계형) | 컬렉션/문서 (문서형) |
| 스키마 | 고정 스키마 필수 | 유연한 스키마 (Schemaless) |
| 데이터 형식 | 행(Row) | BSON 문서 (JSON 유사) |
| 쿼리 언어 | SQL | MQL (MongoDB Query Language) |
| JOIN | 지원 | $lookup (제한적), 비정규화 권장 |
| 트랜잭션 | ACID 완전 지원 | 4.0+ 다중 문서 트랜잭션 지원 |
| 확장 방식 | 수직 확장 (Scale-Up) | 수평 확장 (Sharding) |
| 인덱스 | B-Tree | B-Tree, 복합, 텍스트, 지리공간 등 |

## RDBMS ↔ MongoDB 용어 매핑

| RDBMS | MongoDB | 설명 |
|-------|---------|------|
| Database | Database | 동일 |
| Table | Collection | 문서의 그룹 |
| Row | Document | 하나의 데이터 레코드 |
| Column | Field | 문서 내 키-값 쌍 |
| Primary Key | _id | 자동 생성 (ObjectId) |
| JOIN | $lookup / Embedding | 관계 표현 |
| Index | Index | 동일 개념 |
| Schema | Validator (선택적) | 유연한 스키마 |

## MongoDB 주요 특징

| 특징 | 설명 |
|------|------|
| 유연한 스키마 | 같은 컬렉션 내 문서마다 구조가 달라도 됨 |
| 중첩 문서 | 문서 안에 문서를 포함 (Embedded Document) |
| 배열 지원 | 필드 값으로 배열 저장 가능 |
| 수평 확장 | Sharding으로 데이터 분산 |
| 복제 | Replica Set으로 고가용성 |
| 풍부한 쿼리 | 범위, 정규식, 배열, 지리공간 쿼리 |
| Aggregation | 파이프라인 기반 데이터 집계 |
| Change Stream | 실시간 데이터 변경 감지 |

## MongoDB 활용 사례

| 용도 | 이유 |
|------|------|
| 콘텐츠 관리 (CMS) | 유연한 스키마, 다양한 콘텐츠 구조 |
| IoT 데이터 | 대량 시계열 데이터, 수평 확장 |
| 모바일 앱 백엔드 | JSON 네이티브, 빠른 개발 |
| 실시간 분석 | Aggregation Pipeline |
| 카탈로그/상품 정보 | 상품마다 다른 속성 |
| 사용자 프로필 | 유연한 필드 구조 |
| 게임 | 빠른 읽기/쓰기, 유연한 데이터 |

---

## 설치

### Windows

1. [MongoDB 다운로드](https://www.mongodb.com/try/download/community){:target="_blank"} 페이지에서 MSI 설치 파일 다운로드
2. `mongodb-windows-x86_64-x.x.x-signed.msi` 실행
3. "Complete" 설치 선택
4. "Install MongoDB as a Service" 체크
5. MongoDB Compass (GUI) 함께 설치 선택

### Mac
```bash
# Homebrew
brew tap mongodb/brew
brew install mongodb-community@7.0
brew services start mongodb-community@7.0
```

### Linux (Ubuntu)
```bash
# GPG 키 및 저장소 추가
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt update
sudo apt install mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Docker
```bash
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=MongoPass123! \
  -v mongodata:/data/db \
  mongo:7

# 접속
docker exec -it mongodb mongosh -u admin -p MongoPass123!
```

### 설치 확인
```bash
mongosh
# 또는
mongosh "mongodb://localhost:27017"

db.version()
```

---

## 접속 방법

### mongosh (MongoDB Shell)
```bash
# 로컬 접속
mongosh

# 인증 접속
mongosh -u admin -p MongoPass123! --authenticationDatabase admin

# 원격 접속
mongosh "mongodb://192.168.1.100:27017"

# Connection String (URI)
mongosh "mongodb://admin:MongoPass123!@localhost:27017/mydb?authSource=admin"
```

### 기본 셸 명령어
```javascript
show dbs              // 데이터베이스 목록
use mydb              // 데이터베이스 전환 (없으면 자동 생성)
show collections      // 컬렉션 목록
db.stats()            // 현재 DB 통계
db.version()          // 버전 확인
exit                  // 종료
```

---

## GUI 도구

| 도구 | 특징 | 가격 |
|------|------|------|
| MongoDB Compass | 공식 도구, 시각적 쿼리 빌더 | 무료 |
| Studio 3T | 강력한 쿼리 도구, SQL→MQL 변환 | 유료 (무료 제한판) |
| Robo 3T (Robomongo) | 가볍고 빠름 | 무료 |
| MongoDB Atlas | 클라우드 관리형 서비스 | 무료 티어 있음 |
| DBeaver | 다중 DB 지원 | 무료 (Community) |

---

## 문서(Document) 구조 예시

```javascript
// RDBMS의 한 행(Row)에 해당하는 MongoDB 문서
{
    _id: ObjectId("507f1f77bcf86cd799439011"),  // 자동 생성 PK
    name: "홍길동",
    age: 30,
    email: "hong@test.com",
    address: {                    // 중첩 문서 (Embedded Document)
        city: "서울",
        zipcode: "06000"
    },
    hobbies: ["독서", "등산", "코딩"],  // 배열
    orders: [                     // 배열 + 중첩 문서
        { product: "노트북", price: 1500000, date: ISODate("2026-01-15") },
        { product: "마우스", price: 50000, date: ISODate("2026-03-20") }
    ],
    created_at: ISODate("2024-01-01T00:00:00Z"),
    is_active: true
}
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
