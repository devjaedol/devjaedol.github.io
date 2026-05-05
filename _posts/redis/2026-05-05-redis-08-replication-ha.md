---
title: "[Redis] 08. 복제, Sentinel, Cluster (고가용성)"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 고급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 복제(Replication), Sentinel(자동 페일오버), Cluster(수평 확장)를 정리합니다.

# 복제 (Replication)

Master-Replica 구조로 데이터를 복제하여 읽기 분산과 고가용성을 제공합니다.

## 구조
```text
Master (읽기/쓰기) ──→ Replica 1 (읽기 전용)
                   └──→ Replica 2 (읽기 전용)
```

## 설정

### Replica 측 설정 (redis.conf)
```ini
# Master 지정
replicaof 192.168.1.100 6379

# Master 비밀번호 (있는 경우)
masterauth "MasterPass123!"

# Replica 읽기 전용 (기본값)
replica-read-only yes
```

### 동적 설정
```bash
# Replica에서 실행
REPLICAOF 192.168.1.100 6379

# 복제 해제 (독립 Master로 승격)
REPLICAOF NO ONE
```

### 복제 상태 확인
```bash
# Master에서
INFO replication
# role:master
# connected_slaves:2
# slave0:ip=192.168.1.101,port=6379,state=online,offset=12345

# Replica에서
INFO replication
# role:slave
# master_host:192.168.1.100
# master_link_status:up
```

## 복제 특징

| 항목 | 설명 |
|------|------|
| 비동기 | 기본적으로 비동기 복제 (Master는 Replica 확인 안 기다림) |
| 전체 동기화 | 최초 연결 시 RDB 전송 후 이후 명령 스트리밍 |
| 부분 동기화 | 일시적 연결 끊김 후 재연결 시 차이분만 전송 |
| 체이닝 | Replica의 Replica 가능 (Master → R1 → R2) |

---

## Sentinel (자동 페일오버)

Sentinel은 Master-Replica 구조를 모니터링하고, Master 장애 시 자동으로 Replica를 Master로 승격합니다.

### 구조
```text
Sentinel 1 ──┐
Sentinel 2 ──┼── 모니터링 ──→ Master ──→ Replica 1
Sentinel 3 ──┘                        └──→ Replica 2
```

### Sentinel 설정 (sentinel.conf)
```ini
# 모니터링할 Master 지정 (이름, IP, 포트, 쿼럼)
sentinel monitor mymaster 192.168.1.100 6379 2

# Master 비밀번호
sentinel auth-pass mymaster "MasterPass123!"

# Master 다운 판단 시간 (밀리초)
sentinel down-after-milliseconds mymaster 5000

# 페일오버 타임아웃
sentinel failover-timeout mymaster 60000

# 동시 동기화 Replica 수
sentinel parallel-syncs mymaster 1
```

### Sentinel 실행
```bash
redis-sentinel /etc/redis/sentinel.conf
# 또는
redis-server /etc/redis/sentinel.conf --sentinel
```

### Sentinel 명령어
```bash
redis-cli -p 26379

SENTINEL masters                    # 모니터링 중인 Master 목록
SENTINEL master mymaster            # Master 상세 정보
SENTINEL replicas mymaster          # Replica 목록
SENTINEL get-master-addr-by-name mymaster  # 현재 Master IP/포트
SENTINEL failover mymaster          # 수동 페일오버
```

### 페일오버 과정
1. Sentinel이 Master 다운 감지 (SDOWN)
2. 다른 Sentinel들과 합의 (ODOWN, 쿼럼 충족)
3. Sentinel 리더 선출
4. 최적의 Replica를 새 Master로 승격
5. 나머지 Replica를 새 Master에 연결
6. 클라이언트에 새 Master 정보 전달

---

## Cluster (수평 확장)

Redis Cluster는 데이터를 여러 노드에 자동으로 분산(샤딩)하여 수평 확장을 제공합니다.

### 구조
```text
Slot 0~5460:     Master A ←→ Replica A'
Slot 5461~10922: Master B ←→ Replica B'
Slot 10923~16383: Master C ←→ Replica C'
```

### 핵심 개념

| 개념 | 설명 |
|------|------|
| Hash Slot | 16384개 슬롯으로 키를 분배 |
| 키 분배 | CRC16(key) % 16384 → 슬롯 번호 |
| Hash Tag | `{user}:1`, `{user}:2` → 같은 슬롯에 배치 |
| 최소 구성 | Master 3대 + Replica 3대 (총 6대) |

### Cluster 생성
```bash
# 6개 노드 시작 (포트 7000~7005)
redis-server --port 7000 --cluster-enabled yes --cluster-config-file nodes-7000.conf
redis-server --port 7001 --cluster-enabled yes --cluster-config-file nodes-7001.conf
# ... (7002~7005)

# 클러스터 생성
redis-cli --cluster create \
  127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 \
  127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
  --cluster-replicas 1
```

### Cluster 명령어
```bash
# 클러스터 접속 (-c 옵션 필수)
redis-cli -c -p 7000

# 클러스터 정보
CLUSTER INFO
CLUSTER NODES

# 슬롯 확인
CLUSTER SLOTS
CLUSTER KEYSLOT mykey    # 키의 슬롯 번호 확인

# 노드 추가/제거
redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000
redis-cli --cluster del-node 127.0.0.1:7000 <node-id>

# 슬롯 리밸런싱
redis-cli --cluster rebalance 127.0.0.1:7000
```

### Hash Tag (같은 슬롯 강제 배치)
```bash
# {user:1} 부분이 해시 계산에 사용됨
SET {user:1}:name "홍길동"
SET {user:1}:email "hong@test.com"
SET {user:1}:age 30
# 모두 같은 슬롯 → MGET, 트랜잭션 가능
```

---

## 아키텍처 선택 가이드

| 요구사항 | 권장 구성 |
|---------|----------|
| 단순 캐시 (소규모) | 단일 인스턴스 |
| 읽기 분산 | Master + Replica |
| 자동 페일오버 | Master + Replica + Sentinel |
| 대용량 데이터 + 수평 확장 | Redis Cluster |
| 최고 수준 가용성 | Redis Cluster (각 Master에 Replica) |

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
