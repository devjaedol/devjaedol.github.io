---
title: "[MongoDB] 04. 인덱스 (Index)"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 중급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB 인덱스의 종류, 생성/관리 방법, 실행 계획 분석을 정리합니다.

# 인덱스 종류

| 종류 | 설명 | 용도 |
|------|------|------|
| Single Field | 단일 필드 인덱스 | 기본 검색 |
| Compound | 복합 인덱스 (다중 필드) | 다중 조건 검색 |
| Multikey | 배열 필드 인덱스 | 배열 요소 검색 |
| Text | 전문 검색 인덱스 | 텍스트 검색 |
| 2dsphere | 지리공간 인덱스 | 위치 기반 검색 |
| Hashed | 해시 인덱스 | 샤딩 키 |
| TTL | 자동 만료 인덱스 | 시간 기반 자동 삭제 |
| Unique | 유니크 인덱스 | 중복 방지 |
| Partial | 부분 인덱스 (조건부) | 특정 조건 문서만 |
| Wildcard | 와일드카드 인덱스 | 동적 필드 검색 |

---

## 인덱스 생성 및 관리

### 생성
```javascript
// 단일 필드 (1: 오름차순, -1: 내림차순)
db.users.createIndex({ email: 1 })

// 유니크 인덱스
db.users.createIndex({ email: 1 }, { unique: true })

// 복합 인덱스
db.users.createIndex({ dept: 1, salary: -1 })

// 배열 필드 (Multikey, 자동 감지)
db.users.createIndex({ skills: 1 })

// TTL 인덱스 (60초 후 자동 삭제)
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 60 })

// 부분 인덱스 (조건 만족하는 문서만)
db.users.createIndex(
    { email: 1 },
    { partialFilterExpression: { is_active: true } }
)

// 텍스트 인덱스
db.articles.createIndex({ title: "text", content: "text" })

// 지리공간 인덱스
db.stores.createIndex({ location: "2dsphere" })

// 와일드카드 인덱스 (동적 필드)
db.products.createIndex({ "attributes.$**": 1 })

// 백그라운드 생성 (MongoDB 4.2+ 기본)
db.users.createIndex({ name: 1 }, { name: "idx_name" })
```

### 조회
```javascript
// 인덱스 목록
db.users.getIndexes()

// 인덱스 크기
db.users.stats().indexSizes

// 인덱스 사용 통계
db.users.aggregate([{ $indexStats: {} }])
```

### 삭제
```javascript
// 이름으로 삭제
db.users.dropIndex("idx_name")

// 정의로 삭제
db.users.dropIndex({ email: 1 })

// _id 제외 모든 인덱스 삭제
db.users.dropIndexes()
```

---

## 실행 계획 (explain)

```javascript
// 실행 계획 확인
db.users.find({ dept: "개발팀" }).explain("executionStats")
```

### 주요 확인 항목

| 항목 | 설명 | 좋은 값 |
|------|------|--------|
| stage | 실행 단계 | IXSCAN (인덱스 사용) |
| nReturned | 반환된 문서 수 | 적을수록 좋음 |
| totalDocsExamined | 검사한 문서 수 | nReturned에 가까울수록 좋음 |
| totalKeysExamined | 검사한 인덱스 키 수 | nReturned에 가까울수록 좋음 |
| executionTimeMillis | 실행 시간 (ms) | 작을수록 좋음 |

### Stage 종류

| Stage | 설명 | 성능 |
|-------|------|------|
| COLLSCAN | 컬렉션 전체 스캔 | 나쁨 |
| IXSCAN | 인덱스 스캔 | 좋음 |
| FETCH | 인덱스 후 문서 접근 | 보통 |
| SORT | 메모리 정렬 | 인덱스 정렬 권장 |
| PROJECTION_COVERED | 인덱스만으로 처리 (커버링) | 최고 |

---

## 복합 인덱스 설계 (ESR 규칙)

복합 인덱스의 필드 순서는 성능에 큰 영향을 미칩니다.

### ESR 규칙 (Equality → Sort → Range)

| 순서 | 유형 | 예시 |
|------|------|------|
| 1 | Equality (등치) | `dept = "개발팀"` |
| 2 | Sort (정렬) | `ORDER BY salary DESC` |
| 3 | Range (범위) | `age >= 25` |

```javascript
// 쿼리: dept = "개발팀" AND age >= 25 ORDER BY salary DESC
// 최적 인덱스: { dept: 1, salary: -1, age: 1 }
db.users.createIndex({ dept: 1, salary: -1, age: 1 })
```

---

## TTL 인덱스 (자동 만료)

지정된 시간이 지나면 문서를 자동으로 삭제합니다. 세션, 로그, 임시 데이터에 유용합니다.

```javascript
// 30분 후 자동 삭제
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 1800 })

// 특정 시점에 삭제 (expireAt 필드 값 기준)
db.events.createIndex({ expireAt: 1 }, { expireAfterSeconds: 0 })
db.events.insertOne({
    event: "promotion",
    expireAt: new Date("2026-12-31T23:59:59Z")  // 이 시점에 삭제
})
```

---

## 텍스트 인덱스와 검색

```javascript
// 텍스트 인덱스 생성
db.articles.createIndex({ title: "text", content: "text" })

// 텍스트 검색
db.articles.find({ $text: { $search: "MongoDB 튜토리얼" } })

// 관련도 점수와 함께
db.articles.find(
    { $text: { $search: "MongoDB" } },
    { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })

// 구문 검색 (정확한 문구)
db.articles.find({ $text: { $search: '"MongoDB 설치"' } })

// 제외 검색
db.articles.find({ $text: { $search: "MongoDB -설치" } })
```

---

## 인덱스 설계 가이드라인

| 원칙 | 설명 |
|------|------|
| 쿼리 패턴 분석 | 자주 사용하는 쿼리 기준으로 설계 |
| ESR 규칙 준수 | Equality → Sort → Range 순서 |
| 커버링 인덱스 활용 | 쿼리에 필요한 필드를 모두 인덱스에 포함 |
| 과도한 인덱스 지양 | 쓰기 성능 저하, 메모리 사용 증가 |
| 부분 인덱스 활용 | 조건에 맞는 문서만 인덱싱 |
| 인덱스 사용 모니터링 | `$indexStats`로 미사용 인덱스 확인 |

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
