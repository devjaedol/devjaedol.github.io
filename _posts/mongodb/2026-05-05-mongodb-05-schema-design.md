---
title: "[MongoDB] 05. 스키마 설계 (Embedding vs Referencing)"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 중급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 스키마 설계 패턴, Embedding과 Referencing의 선택 기준을 정리합니다.

# 스키마 설계의 핵심

MongoDB는 스키마가 유연하지만, 좋은 설계가 성능을 결정합니다.    
핵심 원칙: **"함께 조회되는 데이터는 함께 저장한다"**

## Embedding vs Referencing

| 방식 | 설명 | RDBMS 대응 |
|------|------|-----------|
| Embedding (내장) | 관련 데이터를 하나의 문서에 포함 | JOIN 없이 비정규화 |
| Referencing (참조) | 다른 컬렉션의 _id를 참조 | 외래키 (FK) |

---

## Embedding (내장 문서)

### 구조
```javascript
// 사용자 + 주소 + 주문을 하나의 문서에
{
    _id: ObjectId("..."),
    name: "홍길동",
    email: "hong@test.com",
    address: {
        city: "서울",
        district: "강남구",
        zipcode: "06000"
    },
    orders: [
        { product: "노트북", price: 1500000, date: ISODate("2026-01-15") },
        { product: "마우스", price: 50000, date: ISODate("2026-03-20") }
    ]
}
```

### 장단점

| 장점 | 단점 |
|------|------|
| 단일 쿼리로 모든 데이터 조회 | 문서 크기 제한 (16MB) |
| JOIN 불필요 (빠른 읽기) | 중복 데이터 발생 가능 |
| 원자적 업데이트 | 내장 배열이 무한히 커질 수 있음 |
| 데이터 지역성 (디스크 I/O 감소) | 독립적 접근이 어려움 |

### Embedding이 적합한 경우
- 1:1 관계 (사용자 ↔ 프로필)
- 1:소수 관계 (게시글 ↔ 댓글 몇 개)
- 항상 함께 조회되는 데이터
- 자식 데이터가 부모 없이 의미 없는 경우

---

## Referencing (참조)

### 구조
```javascript
// users 컬렉션
{
    _id: ObjectId("user001"),
    name: "홍길동",
    email: "hong@test.com"
}

// orders 컬렉션
{
    _id: ObjectId("order001"),
    user_id: ObjectId("user001"),   // 참조
    product: "노트북",
    price: 1500000,
    date: ISODate("2026-01-15")
}
```

### 장단점

| 장점 | 단점 |
|------|------|
| 문서 크기 제한 없음 | 조회 시 $lookup 필요 (느림) |
| 데이터 중복 없음 | 2번의 쿼리 필요 |
| 독립적 접근 가능 | 원자적 업데이트 불가 (다중 문서) |
| 다대다 관계 표현 용이 | |

### Referencing이 적합한 경우
- 1:다수 관계 (사용자 ↔ 주문 수천 건)
- 다:다 관계 (학생 ↔ 수업)
- 독립적으로 조회/수정되는 데이터
- 문서 크기가 16MB를 초과할 수 있는 경우

---

## 선택 기준 요약

| 질문 | Embedding | Referencing |
|------|-----------|-------------|
| 함께 조회되는가? | ✅ | |
| 독립적으로 접근하는가? | | ✅ |
| 관계가 1:소수인가? | ✅ | |
| 관계가 1:다수/무한인가? | | ✅ |
| 자식이 부모 없이 의미 있는가? | | ✅ |
| 읽기 성능이 중요한가? | ✅ | |
| 쓰기 성능이 중요한가? | | ✅ |
| 데이터 일관성이 중요한가? | | ✅ |

---

## 실전 설계 패턴

### 패턴 1: 블로그 (게시글 + 댓글)

```javascript
// 댓글이 적은 경우: Embedding
{
    _id: ObjectId("..."),
    title: "MongoDB 입문",
    content: "...",
    author: { name: "홍길동", avatar: "url" },
    comments: [
        { user: "김철수", text: "좋은 글!", date: ISODate("...") },
        { user: "이영희", text: "감사합니다", date: ISODate("...") }
    ],
    tags: ["mongodb", "nosql"],
    created_at: ISODate("...")
}

// 댓글이 많은 경우: Referencing (별도 컬렉션)
// posts 컬렉션
{ _id: "post1", title: "MongoDB 입문", content: "..." }

// comments 컬렉션
{ _id: "c1", post_id: "post1", user: "김철수", text: "좋은 글!" }
{ _id: "c2", post_id: "post1", user: "이영희", text: "감사합니다" }
```

### 패턴 2: 전자상거래 (상품 카탈로그)

```javascript
// 상품마다 속성이 다른 경우: 유연한 스키마 활용
{
    _id: ObjectId("..."),
    name: "맥북 프로 16인치",
    category: "노트북",
    price: 3990000,
    brand: "Apple",
    specs: {                    // 상품마다 다른 속성
        cpu: "M3 Pro",
        ram: "36GB",
        storage: "512GB SSD",
        display: "16.2인치 Liquid Retina XDR"
    },
    variants: [                 // 옵션
        { color: "스페이스블랙", stock: 15 },
        { color: "실버", stock: 8 }
    ],
    reviews_summary: {          // 요약 정보 (Embedding)
        avg_rating: 4.8,
        count: 234
    }
}
```

### 패턴 3: Bucket 패턴 (시계열 데이터)

```javascript
// ❌ 측정값마다 1문서 (문서 수 폭발)
{ sensor_id: "s1", value: 23.5, time: ISODate("2026-05-05T10:00:00Z") }
{ sensor_id: "s1", value: 23.7, time: ISODate("2026-05-05T10:00:01Z") }

// ✅ Bucket 패턴 (시간 단위로 묶기)
{
    sensor_id: "s1",
    date: ISODate("2026-05-05T10:00:00Z"),
    measurements: [
        { time: ISODate("...T10:00:00Z"), value: 23.5 },
        { time: ISODate("...T10:00:01Z"), value: 23.7 },
        { time: ISODate("...T10:00:02Z"), value: 23.6 }
    ],
    count: 3,
    sum: 70.8,
    avg: 23.6
}
```

### 패턴 4: Subset 패턴 (자주 쓰는 데이터만 내장)

```javascript
// 상품 문서에 최근 리뷰 10개만 내장
{
    _id: "product1",
    name: "노트북",
    recent_reviews: [           // 최근 10개만 (Subset)
        { user: "홍길동", rating: 5, text: "최고!", date: ISODate("...") },
        // ... 최대 10개
    ]
}

// 전체 리뷰는 별도 컬렉션
// reviews: { product_id: "product1", user: "...", rating: 5, ... }
```

---

## Schema Validation (스키마 검증)

MongoDB 3.6+에서는 선택적으로 스키마 규칙을 적용할 수 있습니다.

```javascript
db.createCollection("users", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "email", "age"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "이름은 필수 문자열입니다"
                },
                email: {
                    bsonType: "string",
                    pattern: "^.+@.+\\..+$"
                },
                age: {
                    bsonType: "int",
                    minimum: 0,
                    maximum: 150
                },
                dept: {
                    enum: ["개발팀", "기획팀", "디자인팀", "인사팀"]
                }
            }
        }
    },
    validationLevel: "moderate",    // strict 또는 moderate
    validationAction: "warn"        // error 또는 warn
})
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
