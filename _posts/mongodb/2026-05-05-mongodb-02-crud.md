---
title: "[MongoDB] 02. CRUD 기본 (문서 삽입, 조회, 수정, 삭제)"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 초급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB에서의 문서 CRUD(Create, Read, Update, Delete) 명령어를 정리합니다.

# 데이터베이스와 컬렉션

## 데이터베이스 관리
```javascript
// 데이터베이스 목록
show dbs

// 데이터베이스 전환 (없으면 첫 문서 삽입 시 자동 생성)
use mydb

// 현재 데이터베이스 확인
db

// 데이터베이스 삭제
db.dropDatabase()
```

## 컬렉션 관리
```javascript
// 컬렉션 목록
show collections

// 컬렉션 생성 (명시적, 보통 자동 생성)
db.createCollection("users")

// 옵션과 함께 생성
db.createCollection("logs", {
    capped: true,       // 고정 크기 컬렉션
    size: 104857600,    // 100MB
    max: 100000         // 최대 문서 수
})

// 컬렉션 삭제
db.users.drop()
```

---

## INSERT (문서 삽입)

### 단일 문서 삽입
```javascript
db.users.insertOne({
    name: "홍길동",
    age: 30,
    email: "hong@test.com",
    dept: "개발팀",
    salary: 5000000,
    hire_date: new Date("2024-01-15"),
    skills: ["JavaScript", "Python", "MongoDB"],
    address: { city: "서울", district: "강남구" }
})
// { acknowledged: true, insertedId: ObjectId("...") }
```

### 다중 문서 삽입
```javascript
db.users.insertMany([
    { name: "김철수", age: 25, dept: "기획팀", salary: 4500000 },
    { name: "이영희", age: 28, dept: "개발팀", salary: 5500000 },
    { name: "박민수", age: 35, dept: "디자인팀", salary: 4800000 },
    { name: "최지은", age: 32, dept: "개발팀", salary: 6000000 }
])
```

### _id 직접 지정
```javascript
db.users.insertOne({
    _id: "user_001",    // 직접 지정 가능 (중복 불가)
    name: "관리자",
    role: "admin"
})
```

---

## FIND (문서 조회)

### 기본 조회
```javascript
// 전체 조회
db.users.find()

// 보기 좋게 출력
db.users.find().pretty()

// 조건 조회
db.users.find({ dept: "개발팀" })

// 단일 문서 조회 (첫 번째 매칭)
db.users.findOne({ name: "홍길동" })
```

### 비교 연산자

| 연산자 | 설명 | SQL 대응 |
|--------|------|---------|
| `$eq` | 같음 | `=` |
| `$ne` | 같지 않음 | `!=` |
| `$gt` | 초과 | `>` |
| `$gte` | 이상 | `>=` |
| `$lt` | 미만 | `<` |
| `$lte` | 이하 | `<=` |
| `$in` | 목록 포함 | `IN` |
| `$nin` | 목록 미포함 | `NOT IN` |

```javascript
db.users.find({ salary: { $gte: 5000000 } })
db.users.find({ age: { $gt: 25, $lt: 35 } })
db.users.find({ dept: { $in: ["개발팀", "기획팀"] } })
db.users.find({ dept: { $ne: "디자인팀" } })
```

### 논리 연산자
```javascript
// AND (기본)
db.users.find({ dept: "개발팀", salary: { $gte: 5000000 } })

// $and (명시적)
db.users.find({ $and: [{ dept: "개발팀" }, { salary: { $gte: 5000000 } }] })

// $or
db.users.find({ $or: [{ dept: "개발팀" }, { dept: "기획팀" }] })

// $not
db.users.find({ age: { $not: { $gte: 30 } } })

// $nor (모두 아닌)
db.users.find({ $nor: [{ dept: "개발팀" }, { dept: "기획팀" }] })
```

### 필드/타입 연산자
```javascript
// 필드 존재 여부
db.users.find({ email: { $exists: true } })
db.users.find({ phone: { $exists: false } })

// 타입 확인
db.users.find({ age: { $type: "number" } })

// 정규식
db.users.find({ name: { $regex: /^홍/ } })
db.users.find({ email: { $regex: /test\.com$/, $options: "i" } })
```

### 배열 쿼리
```javascript
// 배열에 특정 값 포함
db.users.find({ skills: "Python" })

// 배열 크기
db.users.find({ skills: { $size: 3 } })

// $all: 모든 값 포함
db.users.find({ skills: { $all: ["JavaScript", "Python"] } })

// $elemMatch: 배열 요소 조건
db.users.find({ orders: { $elemMatch: { price: { $gt: 100000 } } } })
```

### 중첩 문서 쿼리
```javascript
// 점 표기법 (Dot Notation)
db.users.find({ "address.city": "서울" })
db.users.find({ "orders.0.product": "노트북" })
```

### 프로젝션 (반환 필드 선택)
```javascript
// 특정 필드만 반환 (1: 포함, 0: 제외)
db.users.find({}, { name: 1, email: 1, _id: 0 })

// 특정 필드 제외
db.users.find({}, { password: 0, __v: 0 })
```

### 정렬, 제한, 건너뛰기
```javascript
// 정렬 (1: 오름차순, -1: 내림차순)
db.users.find().sort({ salary: -1 })
db.users.find().sort({ dept: 1, salary: -1 })

// 제한
db.users.find().limit(5)

// 건너뛰기 (페이징)
db.users.find().skip(10).limit(5)

// 개수
db.users.countDocuments({ dept: "개발팀" })
db.users.estimatedDocumentCount()   // 빠른 추정치
```

---

## UPDATE (문서 수정)

### 수정 연산자

| 연산자 | 설명 |
|--------|------|
| `$set` | 필드 값 설정 (없으면 추가) |
| `$unset` | 필드 삭제 |
| `$inc` | 숫자 증감 |
| `$mul` | 숫자 곱하기 |
| `$rename` | 필드 이름 변경 |
| `$min` / `$max` | 최소/최대값으로 갱신 |
| `$push` | 배열에 요소 추가 |
| `$pull` | 배열에서 요소 제거 |
| `$addToSet` | 배열에 중복 없이 추가 |
| `$pop` | 배열 첫/마지막 요소 제거 |
| `$currentDate` | 현재 날짜로 설정 |

### 단일 문서 수정
```javascript
// $set: 필드 값 변경
db.users.updateOne(
    { name: "홍길동" },
    { $set: { salary: 5500000, dept: "인사팀" } }
)

// $inc: 숫자 증감
db.users.updateOne(
    { name: "홍길동" },
    { $inc: { salary: 500000, age: 1 } }
)

// $unset: 필드 삭제
db.users.updateOne(
    { name: "홍길동" },
    { $unset: { phone: "" } }
)

// $push: 배열에 추가
db.users.updateOne(
    { name: "홍길동" },
    { $push: { skills: "Redis" } }
)

// $addToSet: 중복 없이 배열에 추가
db.users.updateOne(
    { name: "홍길동" },
    { $addToSet: { skills: "Python" } }  // 이미 있으면 무시
)

// $pull: 배열에서 제거
db.users.updateOne(
    { name: "홍길동" },
    { $pull: { skills: "Python" } }
)
```

### 다중 문서 수정
```javascript
// 조건에 맞는 모든 문서 수정
db.users.updateMany(
    { dept: "개발팀" },
    { $inc: { salary: 500000 } }
)
```

### Upsert (없으면 삽입, 있으면 수정)
```javascript
db.users.updateOne(
    { email: "new@test.com" },
    { $set: { name: "신규유저", age: 20 } },
    { upsert: true }
)
```

### replaceOne (문서 전체 교체)
```javascript
db.users.replaceOne(
    { name: "홍길동" },
    { name: "홍길동", age: 31, dept: "CTO", salary: 8000000 }
)
```

---

## DELETE (문서 삭제)

```javascript
// 단일 문서 삭제
db.users.deleteOne({ name: "홍길동" })

// 다중 문서 삭제
db.users.deleteMany({ dept: "기획팀" })

// 전체 삭제
db.users.deleteMany({})

// 컬렉션 자체 삭제 (더 빠름)
db.users.drop()
```

---

## findOneAndUpdate / findOneAndDelete

수정/삭제와 동시에 해당 문서를 반환합니다.

```javascript
// 수정 후 새 문서 반환
db.users.findOneAndUpdate(
    { name: "홍길동" },
    { $inc: { salary: 100000 } },
    { returnDocument: "after" }   // "before" 또는 "after"
)

// 삭제하면서 삭제된 문서 반환
db.users.findOneAndDelete({ name: "홍길동" })
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
