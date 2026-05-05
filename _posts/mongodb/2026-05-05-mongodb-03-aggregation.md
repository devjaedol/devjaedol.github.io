---
title: "[MongoDB] 03. Aggregation Pipeline (집계)"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 중급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 Aggregation Pipeline을 이용한 데이터 집계와 변환을 정리합니다.

# Aggregation Pipeline이란?

Aggregation Pipeline은 문서를 여러 단계(Stage)를 거쳐 변환하고 집계하는 프레임워크입니다.    
RDBMS의 GROUP BY, HAVING, JOIN, 서브쿼리 등을 대체합니다.

```text
컬렉션 → [Stage 1] → [Stage 2] → [Stage 3] → ... → 결과
```

---

## 주요 Stage

| Stage | 설명 | SQL 대응 |
|-------|------|---------|
| `$match` | 조건 필터링 | WHERE |
| `$group` | 그룹핑 및 집계 | GROUP BY |
| `$project` | 필드 선택/변환 | SELECT |
| `$sort` | 정렬 | ORDER BY |
| `$limit` | 결과 수 제한 | LIMIT |
| `$skip` | 건너뛰기 | OFFSET |
| `$unwind` | 배열 펼치기 | - |
| `$lookup` | 다른 컬렉션 조인 | JOIN |
| `$addFields` | 필드 추가 | SELECT AS |
| `$count` | 문서 수 카운트 | COUNT |
| `$out` | 결과를 컬렉션에 저장 | INSERT INTO ... SELECT |
| `$merge` | 결과를 기존 컬렉션에 병합 | MERGE |
| `$bucket` | 범위별 그룹핑 | - |
| `$facet` | 다중 파이프라인 병렬 실행 | - |

---

## $match (필터링)
```javascript
// WHERE dept = '개발팀' AND salary >= 5000000
db.users.aggregate([
    { $match: { dept: "개발팀", salary: { $gte: 5000000 } } }
])
```

## $group (그룹핑)
```javascript
// 부서별 인원수, 평균급여
db.users.aggregate([
    { $group: {
        _id: "$dept",                    // 그룹핑 기준
        count: { $sum: 1 },              // COUNT
        avg_salary: { $avg: "$salary" }, // AVG
        max_salary: { $max: "$salary" }, // MAX
        min_salary: { $min: "$salary" }, // MIN
        total_salary: { $sum: "$salary" } // SUM
    }}
])
```

### 집계 연산자

| 연산자 | 설명 |
|--------|------|
| `$sum` | 합계 (1이면 카운트) |
| `$avg` | 평균 |
| `$min` / `$max` | 최소/최대 |
| `$first` / `$last` | 첫 번째/마지막 값 |
| `$push` | 배열로 수집 |
| `$addToSet` | 중복 없이 배열로 수집 |
| `$count` | 문서 수 |

## $project (필드 선택/변환)
```javascript
db.users.aggregate([
    { $project: {
        _id: 0,
        name: 1,
        dept: 1,
        annual_salary: { $multiply: ["$salary", 12] },
        name_dept: { $concat: ["$name", " (", "$dept", ")"] }
    }}
])
```

## $sort / $limit / $skip
```javascript
// 급여 높은 순 상위 5명
db.users.aggregate([
    { $sort: { salary: -1 } },
    { $limit: 5 }
])

// 페이징 (2페이지, 페이지당 10건)
db.users.aggregate([
    { $sort: { _id: 1 } },
    { $skip: 10 },
    { $limit: 10 }
])
```

---

## $unwind (배열 펼치기)

배열 필드를 개별 문서로 분리합니다.

```javascript
// 원본: { name: "홍길동", skills: ["JS", "Python", "MongoDB"] }
// 결과: 3개 문서로 분리

db.users.aggregate([
    { $unwind: "$skills" },
    { $group: {
        _id: "$skills",
        count: { $sum: 1 }
    }},
    { $sort: { count: -1 } }
])
// 스킬별 보유 인원 수
```

---

## $lookup (JOIN)

다른 컬렉션과 조인합니다.

```javascript
// users 컬렉션의 dept_id로 departments 컬렉션 조인
db.users.aggregate([
    { $lookup: {
        from: "departments",        // 조인할 컬렉션
        localField: "dept_id",      // 현재 컬렉션 필드
        foreignField: "_id",        // 대상 컬렉션 필드
        as: "dept_info"             // 결과 배열 필드명
    }},
    { $unwind: "$dept_info" },      // 배열을 단일 문서로
    { $project: {
        name: 1,
        salary: 1,
        dept_name: "$dept_info.name"
    }}
])
```

### Pipeline $lookup (복잡한 조인, MongoDB 3.6+)
```javascript
db.orders.aggregate([
    { $lookup: {
        from: "products",
        let: { product_id: "$product_id" },
        pipeline: [
            { $match: { $expr: { $eq: ["$_id", "$$product_id"] } } },
            { $project: { name: 1, price: 1 } }
        ],
        as: "product"
    }}
])
```

---

## $addFields / $set
```javascript
// 기존 필드 유지하면서 새 필드 추가
db.users.aggregate([
    { $addFields: {
        annual_salary: { $multiply: ["$salary", 12] },
        is_senior: { $gte: ["$age", 30] }
    }}
])
```

---

## $bucket (범위별 그룹핑)
```javascript
// 급여 구간별 인원 수
db.users.aggregate([
    { $bucket: {
        groupBy: "$salary",
        boundaries: [0, 3000000, 5000000, 7000000, 10000000],
        default: "기타",
        output: {
            count: { $sum: 1 },
            names: { $push: "$name" }
        }
    }}
])
```

---

## $facet (다중 파이프라인)

하나의 입력으로 여러 파이프라인을 동시에 실행합니다.

```javascript
db.users.aggregate([
    { $facet: {
        "부서별통계": [
            { $group: { _id: "$dept", count: { $sum: 1 } } }
        ],
        "급여상위3": [
            { $sort: { salary: -1 } },
            { $limit: 3 },
            { $project: { name: 1, salary: 1 } }
        ],
        "전체통계": [
            { $group: { _id: null, total: { $sum: 1 }, avg_salary: { $avg: "$salary" } } }
        ]
    }}
])
```

---

## 실전 예시: SQL → Aggregation 변환

### SQL
```sql
SELECT dept, COUNT(*) as count, AVG(salary) as avg_sal
FROM users
WHERE age >= 25
GROUP BY dept
HAVING COUNT(*) >= 2
ORDER BY avg_sal DESC;
```

### MongoDB Aggregation
```javascript
db.users.aggregate([
    { $match: { age: { $gte: 25 } } },
    { $group: {
        _id: "$dept",
        count: { $sum: 1 },
        avg_sal: { $avg: "$salary" }
    }},
    { $match: { count: { $gte: 2 } } },
    { $sort: { avg_sal: -1 } }
])
```

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
