---
title: "[Redis] 07. 영속성 (RDB, AOF)"
categories: 
    - redis
tags: 
    [redis, nosql, redis강좌, 중급, 'lecture-redis']
toc : true
toc_sticky  : true    
---

Redis의 데이터 영속성 메커니즘인 RDB 스냅샷과 AOF 로그를 정리합니다.

# 영속성이 필요한 이유

Redis는 인메모리 데이터베이스이므로, 서버가 재시작되면 모든 데이터가 사라집니다.    
영속성(Persistence) 설정을 통해 디스크에 데이터를 저장하고 복구할 수 있습니다.

## RDB vs AOF 비교

| 항목 | RDB (스냅샷) | AOF (Append Only File) |
|------|-------------|----------------------|
| 방식 | 특정 시점의 메모리 전체를 덤프 | 모든 쓰기 명령을 로그로 기록 |
| 파일 | dump.rdb | appendonly.aof |
| 크기 | 작음 (바이너리 압축) | 큼 (명령어 텍스트) |
| 복구 속도 | 빠름 | 느림 (명령 재실행) |
| 데이터 손실 | 마지막 스냅샷 이후 데이터 유실 가능 | 최소 (fsync 정책에 따라) |
| 성능 영향 | fork 시 순간 부하 | 지속적 I/O (적은 부하) |
| 용도 | 백업, 재해 복구 | 데이터 안전성 우선 |

---

## RDB (Redis Database)

### 동작 방식
1. Redis가 자식 프로세스를 fork
2. 자식 프로세스가 메모리 데이터를 dump.rdb 파일로 저장
3. 저장 완료 후 기존 파일을 교체

### 설정 (redis.conf)
```ini
# 자동 저장 조건 (초 변경수)
save 900 1      # 900초(15분) 동안 1개 이상 변경 시
save 300 10     # 300초(5분) 동안 10개 이상 변경 시
save 60 10000   # 60초(1분) 동안 10000개 이상 변경 시

# RDB 비활성화
save ""

# RDB 파일명
dbfilename dump.rdb

# 저장 디렉토리
dir /var/lib/redis

# 압축 사용
rdbcompression yes

# 체크섬 검증
rdbchecksum yes
```

### 수동 저장
```bash
# 동기 저장 (블로킹, 운영 환경 비권장)
SAVE

# 비동기 저장 (백그라운드, 권장)
BGSAVE

# 마지막 저장 시간 확인
LASTSAVE
```

### RDB 장단점

| 장점 | 단점 |
|------|------|
| 단일 파일로 백업 간편 | 스냅샷 사이 데이터 유실 가능 |
| 복구 속도 빠름 | fork 시 메모리 2배 필요할 수 있음 |
| 파일 크기 작음 | 대용량 데이터 시 fork 시간 증가 |
| 원격 백업 용이 | |

---

## AOF (Append Only File)

### 동작 방식
1. 모든 쓰기 명령을 AOF 파일에 추가(append)
2. 서버 재시작 시 AOF 파일의 명령을 순서대로 재실행하여 복구

### 설정 (redis.conf)
```ini
# AOF 활성화
appendonly yes

# AOF 파일명
appendfilename "appendonly.aof"

# fsync 정책
appendfsync always      # 매 명령마다 (가장 안전, 가장 느림)
appendfsync everysec    # 1초마다 (권장, 최대 1초 유실)
appendfsync no          # OS에 위임 (가장 빠름, 유실 가능)

# AOF 재작성 조건
auto-aof-rewrite-percentage 100   # 이전 대비 100% 증가 시
auto-aof-rewrite-min-size 64mb    # 최소 64MB 이상일 때
```

### fsync 정책 비교

| 정책 | 데이터 안전성 | 성능 | 최대 유실 |
|------|-------------|------|----------|
| always | 최고 | 느림 | 0 (유실 없음) |
| everysec | 높음 | 좋음 (권장) | 최대 1초 |
| no | 낮음 | 최고 | OS 버퍼 크기만큼 |

### AOF 재작성 (Rewrite)

AOF 파일이 커지면 자동으로 재작성하여 크기를 줄입니다.    
예: `INCR counter`가 1000번 기록된 것을 `SET counter 1000` 하나로 압축

```bash
# 수동 재작성
BGREWRITEAOF

# AOF 상태 확인
INFO persistence
```

### AOF 장단점

| 장점 | 단점 |
|------|------|
| 데이터 유실 최소화 | 파일 크기가 RDB보다 큼 |
| 사람이 읽을 수 있는 형식 | 복구 속도가 RDB보다 느림 |
| 재작성으로 크기 관리 | 지속적 디스크 I/O |

---

## 권장 설정 (운영 환경)

### RDB + AOF 동시 사용 (권장)
```ini
# redis.conf
save 900 1
save 300 10
save 60 10000

appendonly yes
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# AOF 우선 로드 (둘 다 있을 때)
aof-use-rdb-preamble yes    # AOF 앞부분을 RDB 형식으로 (Redis 4.0+, 빠른 복구)
```

### 용도별 권장 설정

| 용도 | 설정 |
|------|------|
| 순수 캐시 (유실 허용) | RDB만 또는 영속성 비활성화 |
| 세션 스토어 | AOF (everysec) |
| 메인 데이터 스토어 | RDB + AOF |
| 메시지 큐 | AOF (everysec) + Stream |

---

## 백업 및 복구

### 백업
```bash
# RDB 파일 복사 (BGSAVE 후)
BGSAVE
cp /var/lib/redis/dump.rdb /backup/redis/dump_$(date +%Y%m%d).rdb

# AOF 파일 복사
cp /var/lib/redis/appendonly.aof /backup/redis/
```

### 복구
```bash
# 1. Redis 중지
sudo systemctl stop redis

# 2. 백업 파일을 데이터 디렉토리에 복사
cp /backup/redis/dump.rdb /var/lib/redis/dump.rdb
# 또는
cp /backup/redis/appendonly.aof /var/lib/redis/appendonly.aof

# 3. Redis 시작 (AOF가 있으면 AOF 우선 로드)
sudo systemctl start redis
```

### AOF 파일 손상 복구
```bash
# AOF 파일 검증
redis-check-aof --fix appendonly.aof

# RDB 파일 검증
redis-check-rdb dump.rdb
```

{% assign c-category = 'redis' %}
{% assign c-tag = 'lecture-redis' %}
{% include /custom-ref.html %}
