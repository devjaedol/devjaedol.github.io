---
title: "[InfluxDB] 06. 운영 관리와 Troubleshooting"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, influxdb강좌, 고급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB의 운영 관리, 백업/복구, 성능 튜닝, 자주 발생하는 문제 해결을 정리합니다.

# 보안 및 인증

## 토큰 관리
```bash
# 토큰 목록
influx auth list

# 읽기 전용 토큰 생성
influx auth create \
  --org myorg \
  --read-bucket mybucket \
  --description "Grafana read-only"

# 읽기/쓰기 토큰 생성
influx auth create \
  --org myorg \
  --read-bucket mybucket \
  --write-bucket mybucket \
  --description "Telegraf write"

# 토큰 비활성화
influx auth inactive --id <token-id>

# 토큰 삭제
influx auth delete --id <token-id>
```

## 사용자 관리
```bash
# 사용자 생성
influx user create --name devuser --org myorg

# 비밀번호 설정
influx user password --name devuser

# 사용자 목록
influx user list

# 사용자 삭제
influx user delete --name devuser
```

---

## 백업과 복구

### 백업
```bash
# 전체 백업
influx backup /backup/influxdb/full_$(date +%Y%m%d)

# 특정 버킷만
influx backup /backup/influxdb/mybucket --bucket mybucket

# 압축 백업
influx backup /backup/influxdb/backup_$(date +%Y%m%d) --compression gzip
```

### 복구
```bash
# 전체 복구
influx restore /backup/influxdb/full_20260505

# 특정 버킷 복구
influx restore /backup/influxdb/mybucket --bucket mybucket

# 다른 이름으로 복구
influx restore /backup/influxdb/mybucket --bucket mybucket --new-bucket mybucket_restored
```

---

## 성능 튜닝

### 시리즈 카디널리티 관리

시리즈 카디널리티는 InfluxDB 성능의 가장 중요한 지표입니다.

```bash
# 시리즈 카디널리티 확인
influx query 'import "influxdata/influxdb"
influxdb.cardinality(bucket: "mybucket", start: -30d)'
```

```flux
// 측정별 시리즈 수 확인
import "influxdata/influxdb"

influxdb.cardinality(bucket: "mybucket", start: -30d)
  |> group(columns: ["_measurement"])
  |> count()
```

### 카디널리티 줄이기

| 방법 | 설명 |
|------|------|
| 높은 카디널리티 Tag 제거 | user_id, request_id 등을 Field로 변경 |
| Tag 값 정규화 | URL 경로를 패턴으로 그룹핑 |
| 불필요한 Tag 제거 | 사용하지 않는 Tag 삭제 |
| 버킷 분리 | 용도별 버킷 분리 |

### 스토리지 설정 (config.toml)
```toml
[storage]
  # TSM 엔진 캐시 크기
  cache-max-memory-size = "1g"
  
  # 캐시 스냅샷 크기
  cache-snapshot-memory-size = "25m"
  
  # 컴팩션 처리량
  compact-throughput = "48m"
  compact-throughput-burst = "48m"
```

### 쿼리 최적화

```flux
// ❌ 넓은 시간 범위 + 필터 없음
from(bucket: "mybucket")
  |> range(start: -30d)

// ✅ 좁은 시간 범위 + 구체적 필터
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu" and r.host == "server01")
  |> filter(fn: (r) => r._field == "usage_user")

// ❌ 불필요한 데이터 로드 후 제거
from(bucket: "mybucket")
  |> range(start: -1h)
  |> last()

// ✅ pushdown 최적화 (filter를 먼저)
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> last()
```

---

## 모니터링

### 내부 메트릭 확인
```bash
# /metrics 엔드포인트 (Prometheus 형식)
curl http://localhost:8086/metrics

# 주요 지표
# influxdb_organizations_total
# influxdb_buckets_total
# influxdb_series_total (시리즈 카디널리티)
# go_memstats_alloc_bytes (메모리 사용량)
# http_api_requests_total (API 요청 수)
```

### 디스크 사용량 확인
```bash
# 데이터 디렉토리 크기
du -sh /var/lib/influxdb2/engine/

# 버킷별 크기
du -sh /var/lib/influxdb2/engine/data/*
```

---

## 자주 발생하는 문제

### 1. 높은 시리즈 카디널리티로 인한 성능 저하

증상: 메모리 사용량 급증, 쿼리 느려짐, OOM

```flux
// 카디널리티 확인
import "influxdata/influxdb"
influxdb.cardinality(bucket: "mybucket", start: -7d)
```

| 해결 | 설명 |
|------|------|
| 높은 카디널리티 Tag → Field 변경 | 스키마 재설계 |
| 불필요한 시리즈 삭제 | `influx delete` |
| 버킷 보존 기간 단축 | 오래된 데이터 자동 삭제 |

### 2. 디스크 용량 부족

```bash
# 데이터 삭제 (시간 범위)
influx delete \
  --bucket mybucket \
  --start 2025-01-01T00:00:00Z \
  --stop 2025-06-01T00:00:00Z

# 특정 measurement 삭제
influx delete \
  --bucket mybucket \
  --start 1970-01-01T00:00:00Z \
  --stop $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --predicate '_measurement="old_metric"'
```

### 3. 쓰기 실패 (Write Timeout)

| 원인 | 해결 |
|------|------|
| 배치 크기 과대 | 배치 크기 줄이기 (5000 포인트 이하) |
| 디스크 I/O 병목 | SSD 사용, I/O 스케줄러 확인 |
| 카디널리티 폭발 | Tag 설계 검토 |

### 4. 쿼리 타임아웃

```bash
# 쿼리 타임아웃 설정 (config.toml)
# query-timeout = "30s"
```

| 해결 | 설명 |
|------|------|
| 시간 범위 축소 | 조회 기간 줄이기 |
| 다운샘플링 활용 | 장기 조회는 요약 버킷 사용 |
| 필터 추가 | measurement, tag 필터 구체화 |
| aggregateWindow 사용 | 원본 대신 집계 데이터 조회 |

### 5. Telegraf 데이터 미수신

| 확인 항목 | 방법 |
|----------|------|
| Telegraf 실행 상태 | `systemctl status telegraf` |
| 설정 파일 오류 | `telegraf --config telegraf.conf --test` |
| 토큰 권한 | 쓰기 권한 있는 토큰인지 확인 |
| 네트워크 | InfluxDB 포트 접근 가능 여부 |
| 로그 확인 | `journalctl -u telegraf -f` |

---

## 운영 체크리스트

| 항목 | 확인 방법 | 권장 |
|------|----------|------|
| 시리즈 카디널리티 | `influxdb.cardinality()` | 100만 이하 (OSS) |
| 디스크 사용량 | `du -sh` | 여유 공간 20% 이상 |
| 메모리 사용량 | `/metrics` | 물리 메모리의 80% 이하 |
| 보존 정책 | 버킷 설정 확인 | 용도에 맞게 설정 |
| 다운샘플링 | Task 실행 상태 | 장기 데이터 요약 |
| 백업 | 정기 백업 스크립트 | 일 1회 이상 |
| 토큰 관리 | 최소 권한 원칙 | 읽기/쓰기 분리 |
| Telegraf 상태 | 로그 확인 | 에러 없는지 확인 |

---

## DB 선택 가이드 (최종 비교)

| 요구사항 | 추천 DB |
|---------|---------|
| 시계열 메트릭 (모니터링, IoT) | InfluxDB |
| 범용 관계형 데이터 | PostgreSQL, MySQL |
| 문서형 유연한 스키마 | MongoDB |
| 캐시, 세션, 실시간 | Redis |
| 로그 검색, 전문 검색 | Elasticsearch |
| 대규모 분석 (OLAP) | ClickHouse, TimescaleDB |

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
