---
title: "[InfluxDB] 02. 데이터 모델 (Measurement, Tag, Field)"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, influxdb강좌, 초급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB의 핵심 데이터 모델인 Measurement, Tag, Field, Timestamp를 정리합니다.

# 데이터 모델 개요

InfluxDB의 데이터 모델은 RDBMS와 완전히 다릅니다.    
시계열 데이터에 최적화된 구조로, 모든 데이터 포인트는 반드시 타임스탬프를 가집니다.

## RDBMS ↔ InfluxDB 용어 매핑

| RDBMS | InfluxDB | 설명 |
|-------|----------|------|
| Database | Bucket | 데이터 저장 공간 (보존 정책 포함) |
| Table | Measurement | 데이터 그룹 (테이블과 유사) |
| 인덱스 컬럼 | Tag | 메타데이터 (자동 인덱싱) |
| 일반 컬럼 | Field | 실제 측정값 (인덱싱 안됨) |
| Primary Key | Timestamp | 시간 (자동, 필수) |
| Row | Point | 하나의 데이터 포인트 |

---

## Line Protocol (데이터 쓰기 형식)

InfluxDB에 데이터를 쓸 때 사용하는 텍스트 형식입니다.

```text
<measurement>,<tag_key>=<tag_value>,... <field_key>=<field_value>,... <timestamp>
```

### 예시
```text
cpu,host=server01,region=kr-central usage_user=45.2,usage_system=12.1 1714900000000000000
cpu,host=server02,region=kr-central usage_user=32.8,usage_system=8.5 1714900000000000000
temperature,sensor=s1,location=factory1 value=23.5 1714900000000000000
```

### 구성 요소 상세

| 구성 요소 | 필수 | 설명 | 예시 |
|----------|:----:|------|------|
| Measurement | ✅ | 데이터 그룹명 | `cpu`, `temperature`, `http_requests` |
| Tag (key=value) | ❌ | 메타데이터, 자동 인덱싱 | `host=server01`, `region=kr` |
| Field (key=value) | ✅ | 실제 측정값, 인덱싱 안됨 | `usage=45.2`, `count=100` |
| Timestamp | ❌ | 나노초 Unix 타임스탬프 (생략 시 현재 시간) | `1714900000000000000` |

---

## Tag vs Field (핵심 구분)

이 구분을 잘못하면 성능에 큰 영향을 미칩니다.

| 항목 | Tag | Field |
|------|-----|-------|
| 인덱싱 | ✅ 자동 인덱싱 | ❌ 인덱싱 안됨 |
| 데이터 타입 | 문자열만 | 정수, 실수, 문자열, 불리언 |
| WHERE 조건 | 빠름 (인덱스 사용) | 느림 (전체 스캔) |
| GROUP BY | 가능 | 불가 |
| 카디널리티 | 낮아야 좋음 | 제한 없음 |
| 용도 | 분류, 필터링 기준 | 실제 측정값 |

### Tag로 적합한 것 ✅
- 호스트명 (`host=server01`)
- 리전 (`region=kr-central`)
- 센서 ID (`sensor=s1`)
- 환경 (`env=production`)
- 서비스명 (`service=api-gateway`)

### Field로 적합한 것 ✅
- CPU 사용률 (`usage=45.2`)
- 온도 (`temperature=23.5`)
- 응답 시간 (`response_time=120`)
- 요청 수 (`count=1500`)
- 에러 수 (`errors=3`)

### Tag로 부적합한 것 ❌ (높은 카디널리티)
- 사용자 ID (수백만 종류)
- 요청 URL (무한 종류)
- 타임스탬프 문자열
- UUID

> 카디널리티(고유 값 수)가 높은 데이터를 Tag로 설정하면 인덱스가 비대해져 메모리 부족과 성능 저하가 발생합니다.

---

## Series (시리즈)

Series는 동일한 Measurement + Tag 조합을 가진 데이터 포인트의 집합입니다.    
InfluxDB 성능의 핵심 지표는 **시리즈 카디널리티**(총 시리즈 수)입니다.

```text
# 아래는 3개의 서로 다른 시리즈
cpu,host=server01,region=kr    → Series 1
cpu,host=server02,region=kr    → Series 2
cpu,host=server01,region=us    → Series 3
```

### 시리즈 카디널리티 계산
```text
시리즈 수 = Measurement 수 × Tag 조합 수

예: cpu measurement, host 100대, region 3개
시리즈 수 = 1 × 100 × 3 = 300 시리즈 (양호)

예: http_requests, user_id 100만명, endpoint 50개
시리즈 수 = 1 × 1,000,000 × 50 = 5천만 시리즈 (위험!)
```

---

## Bucket (버킷)

InfluxDB 2.x에서 Bucket은 데이터 저장 공간 + 보존 정책을 합친 개념입니다.

```bash
# 버킷 생성 (30일 보존)
influx bucket create \
  --name monitoring \
  --org myorg \
  --retention 30d

# 버킷 목록
influx bucket list

# 버킷 삭제
influx bucket delete --name monitoring
```

### 보존 기간 (Retention)

| 설정 | 설명 |
|------|------|
| `0` | 무기한 보존 |
| `24h` | 24시간 |
| `7d` | 7일 |
| `30d` | 30일 |
| `365d` | 1년 |

```bash
# 보존 기간 변경
influx bucket update --name monitoring --retention 90d
```

---

## 데이터 쓰기

### influx CLI
```bash
influx write \
  --bucket mybucket \
  --org myorg \
  --precision s \
  "cpu,host=server01 usage_user=45.2,usage_system=12.1 1714900000"
```

### 여러 포인트 한번에 쓰기
```bash
influx write --bucket mybucket --org myorg --precision ns << EOF
cpu,host=server01 usage_user=45.2,usage_system=12.1 1714900000000000000
cpu,host=server02 usage_user=32.8,usage_system=8.5 1714900000000000000
memory,host=server01 used_percent=72.5,available=8589934592 1714900000000000000
EOF
```

### 파일에서 쓰기
```bash
# data.lp (Line Protocol 파일)
influx write --bucket mybucket --org myorg --file data.lp

# CSV 파일
influx write --bucket mybucket --org myorg \
  --file data.csv \
  --header "#constant measurement,cpu" \
  --header "#datatype tag,double,double,dateTime:RFC3339"
```

---

## 데이터 모델 설계 예시

### 서버 모니터링
```text
# Measurement: cpu
cpu,host=web01,region=kr,env=prod usage_user=45.2,usage_system=12.1,usage_idle=42.7

# Measurement: memory
memory,host=web01,region=kr,env=prod used_percent=72.5,available=8589934592

# Measurement: disk
disk,host=web01,path=/,device=sda1 used_percent=65.3,free=107374182400
```

### IoT 센서
```text
# Measurement: temperature
temperature,sensor_id=s001,location=factory1,floor=1F value=23.5,humidity=45.2

# Measurement: vibration
vibration,machine_id=m001,line=A frequency=120.5,amplitude=0.03
```

### 웹 애플리케이션 메트릭
```text
# Measurement: http_requests
http_requests,method=GET,endpoint=/api/users,status=200 count=1,response_time=45

# Measurement: errors
errors,service=api,level=error count=1,message="timeout"
```

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
