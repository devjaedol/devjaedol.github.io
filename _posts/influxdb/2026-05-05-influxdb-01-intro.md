---
title: "[InfluxDB] 01. InfluxDB 소개 및 설치"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, influxdb강좌, 초급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB의 기본 개념, 장단점, 적합한 사용 사례, 설치 방법을 알아봅니다.

# InfluxDB란?

InfluxDB는 시계열(Time Series) 데이터에 특화된 오픈소스 데이터베이스입니다.    
시간 순서로 기록되는 대량의 데이터를 빠르게 쓰고, 시간 범위 기반으로 효율적으로 조회할 수 있도록 설계되었습니다.

## 시계열 데이터란?

시계열 데이터는 시간에 따라 연속적으로 기록되는 데이터입니다.

| 예시 | 설명 |
|------|------|
| 서버 모니터링 | CPU 사용률, 메모리, 디스크 I/O (매초) |
| IoT 센서 | 온도, 습도, 압력 (매초~매분) |
| 금융 데이터 | 주가, 환율, 거래량 (매초) |
| 애플리케이션 메트릭 | 응답 시간, 에러율, 요청 수 |
| 네트워크 트래픽 | 대역폭, 패킷 수, 지연 시간 |
| 스마트 팩토리 | 설비 가동률, 생산량, 불량률 |

---

## 왜 InfluxDB를 사용하는가?

### RDBMS로 시계열 데이터를 처리할 때의 문제

| 문제 | 설명 |
|------|------|
| 쓰기 성능 | 초당 수만~수십만 건 삽입 시 RDBMS는 한계 |
| 저장 효율 | 시계열 데이터는 압축 가능하지만 RDBMS는 범용 저장 |
| 조회 패턴 | 시간 범위 + 집계 쿼리에 RDBMS 인덱스 비효율 |
| 데이터 보존 | 오래된 데이터 자동 삭제/다운샘플링 어려움 |
| 테이블 크기 | 수억~수십억 행이 빠르게 쌓여 관리 어려움 |

### InfluxDB가 해결하는 것

| 기능 | 설명 |
|------|------|
| 고속 쓰기 | 초당 수십만 포인트 삽입 가능 |
| 시간 기반 압축 | TSM(Time-Structured Merge Tree) 엔진 |
| 자동 다운샘플링 | 오래된 데이터를 요약본으로 변환 |
| 보존 정책 | 일정 기간 후 자동 삭제 (Retention Policy) |
| 시간 범위 쿼리 최적화 | 시간 인덱스 기본 내장 |
| 연속 쿼리 | 실시간 집계 자동 실행 |

---

## InfluxDB 장단점

### 장점

| 장점 | 설명 |
|------|------|
| 시계열 최적화 | 시간 기반 쓰기/읽기에 최적화된 스토리지 엔진 |
| 고속 삽입 | 초당 수십만 포인트 쓰기 가능 |
| 자동 데이터 관리 | Retention Policy로 오래된 데이터 자동 삭제 |
| 내장 함수 풍부 | 이동 평균, 미분, 적분, 예측 등 시계열 전용 함수 |
| 스키마리스 | 태그/필드를 자유롭게 추가 가능 |
| 에코시스템 | Telegraf(수집), Chronograf(시각화), Kapacitor(알림) |
| Grafana 연동 | 대시보드 시각화 도구와 완벽 호환 |
| 압축 효율 | 시계열 데이터 특성을 활용한 높은 압축률 |

### 단점

| 단점 | 설명 |
|------|------|
| 범용 DB 아님 | JOIN, 트랜잭션, 복잡한 관계 표현 불가 |
| 업데이트 비효율 | 기존 데이터 수정에 적합하지 않음 (Append-only 설계) |
| 삭제 비용 | 개별 포인트 삭제가 비효율적 |
| 높은 카디널리티 주의 | 태그 값 종류가 너무 많으면 성능 저하 |
| 클러스터링 제한 | OSS 버전은 단일 노드 (Enterprise만 클러스터) |
| 학습 곡선 | Flux 언어 (InfluxDB 2.x)가 독특함 |
| 메모리 사용 | 인덱스를 메모리에 유지하므로 RAM 필요 |

---

## 언제 InfluxDB를 사용해야 하는가?

### 적합한 경우 ✅

| 사용 사례 | 이유 |
|----------|------|
| 서버/인프라 모니터링 | 대량 메트릭, 시간 범위 조회, 대시보드 |
| IoT 센서 데이터 | 초당 수만 건 삽입, 자동 보존 정책 |
| 애플리케이션 성능 모니터링 (APM) | 응답 시간, 에러율 추적 |
| 실시간 분석 대시보드 | Grafana 연동, 실시간 집계 |
| 네트워크 모니터링 | 트래픽, 대역폭, 패킷 분석 |
| DevOps 메트릭 | CI/CD 파이프라인, 배포 추적 |
| 금융 시계열 | 주가, 거래량 (단, 트랜잭션 불필요 시) |
| 스마트 팩토리 | 설비 데이터, 생산 메트릭 |

### 부적합한 경우 ❌

| 사용 사례 | 이유 | 대안 |
|----------|------|------|
| 사용자 정보, 주문 관리 | 관계형 데이터, 트랜잭션 필요 | PostgreSQL, MySQL |
| 문서 저장 (CMS) | 유연한 문서 구조 필요 | MongoDB |
| 캐시, 세션 | 키-값 빠른 접근 | Redis |
| 전문 검색 | 텍스트 검색 | Elasticsearch |
| 데이터 수정이 빈번한 경우 | Append-only 설계와 맞지 않음 | RDBMS |
| 복잡한 JOIN이 필요한 경우 | JOIN 미지원 | RDBMS |

---

## InfluxDB 버전 비교

| 항목 | InfluxDB 1.x | InfluxDB 2.x | InfluxDB 3.x |
|------|-------------|-------------|-------------|
| 쿼리 언어 | InfluxQL (SQL 유사) | Flux (함수형) | SQL + InfluxQL |
| UI | 별도 (Chronograf) | 내장 웹 UI | 내장 웹 UI |
| 인증 | 기본 인증 | 토큰 기반 | 토큰 기반 |
| 조직/버킷 | Database/RP | Organization/Bucket | Database |
| 스토리지 | TSM | TSM | Apache Arrow + Parquet |
| 라이선스 | MIT | MIT (OSS) | Apache 2.0 (Core) |

> 이 강좌에서는 InfluxDB 2.x를 기준으로 설명합니다.

---

## 설치

### Docker (권장)
```bash
docker run -d \
  --name influxdb \
  -p 8086:8086 \
  -v influxdb-data:/var/lib/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=InfluxPass123! \
  -e DOCKER_INFLUXDB_INIT_ORG=myorg \
  -e DOCKER_INFLUXDB_INIT_BUCKET=mybucket \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-token \
  influxdb:2

# 웹 UI 접속
# http://localhost:8086
```

### Linux (Ubuntu)
```bash
wget https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.x_amd64.deb
sudo dpkg -i influxdb2_2.7.x_amd64.deb
sudo systemctl start influxdb
sudo systemctl enable influxdb

# 초기 설정
influx setup
```

### Mac
```bash
brew install influxdb
brew services start influxdb

# 초기 설정
influx setup
```

### Windows
1. [InfluxDB 다운로드](https://portal.influxdata.com/downloads/){:target="_blank"} 페이지에서 Windows 바이너리 다운로드
2. 압축 해제 후 `influxd.exe` 실행
3. 브라우저에서 `http://localhost:8086` 접속하여 초기 설정

### 설치 확인
```bash
influx version
influx ping
# 웹 UI: http://localhost:8086
```

---

## 접속 방법

### influx CLI
```bash
# 토큰 인증
influx config create \
  --config-name default \
  --host-url http://localhost:8086 \
  --org myorg \
  --token my-super-secret-token \
  --active

# 버킷 목록
influx bucket list

# 쿼리 실행
influx query 'from(bucket:"mybucket") |> range(start: -1h)'
```

### HTTP API
```bash
# 데이터 쓰기
curl -X POST "http://localhost:8086/api/v2/write?org=myorg&bucket=mybucket" \
  -H "Authorization: Token my-super-secret-token" \
  -H "Content-Type: text/plain" \
  --data-raw "cpu,host=server01 usage=45.2 1714900000000000000"

# 데이터 조회
curl -X POST "http://localhost:8086/api/v2/query?org=myorg" \
  -H "Authorization: Token my-super-secret-token" \
  -H "Content-Type: application/vnd.flux" \
  --data 'from(bucket:"mybucket") |> range(start: -1h)'
```

---

## TICK 스택 (InfluxDB 에코시스템)

| 구성 요소 | 역할 | 설명 |
|----------|------|------|
| Telegraf | 수집 (Collector) | 200+ 플러그인으로 메트릭 수집 |
| InfluxDB | 저장 (Storage) | 시계열 데이터 저장/조회 |
| Chronograf | 시각화 (Visualization) | 대시보드, 관리 UI (2.x는 내장) |
| Kapacitor | 알림 (Alerting) | 실시간 스트림 처리, 알림 (2.x는 내장) |

> InfluxDB 2.x에서는 Chronograf와 Kapacitor 기능이 내장되어 별도 설치가 불필요합니다.    
> 시각화는 Grafana와 연동하는 것이 더 일반적입니다.

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
