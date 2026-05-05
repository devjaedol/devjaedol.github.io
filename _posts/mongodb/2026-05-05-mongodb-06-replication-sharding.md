---
title: "[MongoDB] 06. Replica Set과 Sharding (고가용성/확장)"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 고급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 Replica Set(복제)과 Sharding(수평 확장)을 정리합니다.

# Replica Set (복제)

Replica Set은 동일한 데이터를 여러 노드에 복제하여 고가용성과 읽기 분산을 제공합니다.

## 구조
```text
Primary (읽기/쓰기) ──→ Secondary 1 (읽기)
                    └──→ Secondary 2 (읽기)
                    └──→ Arbiter (투표만, 데이터 없음, 선택적)
```

## 핵심 개념

| 구성 요소 | 설명 |
|----------|------|
| Primary | 모든 쓰기를 처리하는 유일한 노드 |
| Secondary | Primary의 데이터를 복제, 읽기 가능 |
| Arbiter | 투표에만 참여 (데이터 저장 안함, 짝수 노드 시 사용) |
| Oplog | 복제에 사용되는 작업 로그 (capped collection) |
| Election | Primary 장애 시 자동 선출 |

## Replica Set 설정

### 초기화
```javascript
// mongosh에서 실행 (Primary가 될 노드)
rs.initiate({
    _id: "myReplicaSet",
    members: [
        { _id: 0, host: "mongo1:27017" },
        { _id: 1, host: "mongo2:27017" },
        { _id: 2, host: "mongo3:27017" }
    ]
})
```

### 상태 확인
```javascript
rs.status()           // Replica Set 상태
rs.isMaster()         // 현재 노드 역할
rs.conf()             // 설정 확인
rs.printReplicationInfo()    // Oplog 정보
rs.printSecondaryReplicationInfo()  // 복제 지연
```

### 멤버 관리
```javascript
// 멤버 추가
rs.add("mongo4:27017")

// Arbiter 추가
rs.addArb("arbiter1:27017")

// 멤버 제거
rs.remove("mongo4:27017")

// 우선순위 변경 (높을수록 Primary 선출 우선)
cfg = rs.conf()
cfg.members[1].priority = 2
rs.reconfig(cfg)
```

## Read Preference (읽기 분산)

| 모드 | 설명 |
|------|------|
| primary | Primary에서만 읽기 (기본값, 최신 데이터 보장) |
| primaryPreferred | Primary 우선, 불가 시 Secondary |
| secondary | Secondary에서만 읽기 |
| secondaryPreferred | Secondary 우선, 불가 시 Primary |
| nearest | 네트워크 지연이 가장 적은 노드 |

```javascript
// Secondary에서 읽기
db.users.find().readPref("secondary")

// Connection String에서 지정
// mongodb://mongo1,mongo2,mongo3/mydb?replicaSet=myReplicaSet&readPreference=secondaryPreferred
```

## Write Concern (쓰기 보장 수준)

| 값 | 설명 |
|----|------|
| w: 0 | 확인 안함 (Fire & Forget) |
| w: 1 | Primary 확인 (기본값) |
| w: "majority" | 과반수 노드 확인 (권장) |
| w: 3 | 3개 노드 확인 |
| j: true | 저널링까지 확인 |

```javascript
db.users.insertOne(
    { name: "홍길동" },
    { writeConcern: { w: "majority", j: true, wtimeout: 5000 } }
)
```

---

## Sharding (수평 확장)

Sharding은 데이터를 여러 서버(Shard)에 분산 저장하여 수평 확장을 제공합니다.

### 구조
```text
Client → mongos (Router) → Config Server (메타데이터)
                        ├→ Shard 1 (Replica Set)
                        ├→ Shard 2 (Replica Set)
                        └→ Shard 3 (Replica Set)
```

### 구성 요소

| 구성 요소 | 설명 |
|----------|------|
| Shard | 데이터를 저장하는 노드 (각각 Replica Set) |
| mongos | 클라이언트 요청을 적절한 Shard로 라우팅 |
| Config Server | 클러스터 메타데이터, 청크 매핑 정보 저장 |
| Chunk | 데이터 분할 단위 (기본 128MB) |
| Shard Key | 데이터 분배 기준 필드 |

### Shard Key 선택

Shard Key는 한번 설정하면 변경이 어려우므로 신중하게 선택해야 합니다.

| 좋은 Shard Key | 나쁜 Shard Key |
|---------------|---------------|
| 높은 카디널리티 | 낮은 카디널리티 (성별, 상태) |
| 균등한 분포 | 단조 증가 (ObjectId, 타임스탬프) |
| 쿼리에 자주 포함 | 쿼리에 사용 안되는 필드 |

#### Shard Key 전략

| 전략 | 예시 | 장점 | 단점 |
|------|------|------|------|
| Hashed | `{ _id: "hashed" }` | 균등 분배 | 범위 쿼리 비효율 |
| Ranged | `{ created_at: 1 }` | 범위 쿼리 효율 | 핫스팟 가능 |
| Compound | `{ tenant_id: 1, _id: 1 }` | 균형 잡힌 분배 | 설계 복잡 |

### Sharding 설정
```javascript
// 1. Sharding 활성화 (mongos에서)
sh.enableSharding("mydb")

// 2. Shard Key로 인덱스 생성
db.orders.createIndex({ user_id: "hashed" })

// 3. 컬렉션 샤딩
sh.shardCollection("mydb.orders", { user_id: "hashed" })

// 상태 확인
sh.status()
db.orders.getShardDistribution()
```

---

## 아키텍처 선택 가이드

| 요구사항 | 권장 구성 |
|---------|----------|
| 개발/테스트 | 단일 인스턴스 |
| 고가용성 필요 | Replica Set (3노드) |
| 읽기 분산 | Replica Set + Read Preference |
| 대용량 데이터 (TB+) | Sharded Cluster |
| 글로벌 분산 | Zone Sharding |

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
