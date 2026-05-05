---
title: "[InfluxDB] 04. Telegraf (데이터 수집 에이전트)"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, telegraf, influxdb강좌, 중급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB의 공식 데이터 수집 에이전트인 Telegraf의 설정과 활용을 정리합니다.

# Telegraf란?

Telegraf는 InfluxData에서 개발한 플러그인 기반 메트릭 수집 에이전트입니다.    
200개 이상의 입력/출력 플러그인을 지원하며, 시스템 메트릭, 애플리케이션 메트릭, 로그 등을 수집하여 InfluxDB에 전송합니다.

## 아키텍처
```text
[Input Plugins] → [Processor Plugins] → [Aggregator Plugins] → [Output Plugins]
  (데이터 수집)      (데이터 변환)          (데이터 집계)          (데이터 전송)
```

---

## 설치

### Linux
```bash
sudo apt install telegraf
# 또는
wget https://dl.influxdata.com/telegraf/releases/telegraf_1.x.x_amd64.deb
sudo dpkg -i telegraf_1.x.x_amd64.deb
```

### Mac
```bash
brew install telegraf
```

### Docker
```bash
docker run -d --name telegraf \
  -v /path/to/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
  telegraf
```

---

## 설정 파일 (telegraf.conf)

### 기본 구조
```toml
# 글로벌 설정
[agent]
  interval = "10s"              # 수집 간격
  round_interval = true
  flush_interval = "10s"        # 전송 간격
  flush_jitter = "0s"

# 출력: InfluxDB 2.x
[[outputs.influxdb_v2]]
  urls = ["http://localhost:8086"]
  token = "my-super-secret-token"
  organization = "myorg"
  bucket = "mybucket"

# 입력: CPU
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false

# 입력: 메모리
[[inputs.mem]]

# 입력: 디스크
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs"]

# 입력: 네트워크
[[inputs.net]]
```

---

## 주요 Input 플러그인

### 시스템 메트릭

| 플러그인 | 수집 항목 |
|---------|----------|
| `inputs.cpu` | CPU 사용률 |
| `inputs.mem` | 메모리 사용량 |
| `inputs.disk` | 디스크 사용량 |
| `inputs.diskio` | 디스크 I/O |
| `inputs.net` | 네트워크 트래픽 |
| `inputs.system` | 부하, 가동 시간 |
| `inputs.processes` | 프로세스 수 |

### 애플리케이션/서비스

| 플러그인 | 대상 |
|---------|------|
| `inputs.nginx` | Nginx 상태 |
| `inputs.apache` | Apache 상태 |
| `inputs.mysql` | MySQL 메트릭 |
| `inputs.postgresql` | PostgreSQL 메트릭 |
| `inputs.redis` | Redis 메트릭 |
| `inputs.mongodb` | MongoDB 메트릭 |
| `inputs.docker` | Docker 컨테이너 |
| `inputs.kubernetes` | Kubernetes 메트릭 |

### 기타

| 플러그인 | 용도 |
|---------|------|
| `inputs.http_response` | HTTP 엔드포인트 모니터링 |
| `inputs.ping` | 네트워크 연결 확인 |
| `inputs.snmp` | SNMP 장비 모니터링 |
| `inputs.mqtt_consumer` | MQTT 메시지 수집 |
| `inputs.tail` | 로그 파일 추적 |
| `inputs.exec` | 커스텀 스크립트 실행 |

---

## 설정 예시

### MySQL 모니터링
```toml
[[inputs.mysql]]
  servers = ["user:password@tcp(localhost:3306)/"]
  gather_table_schema = true
  gather_process_list = true
  gather_slave_status = true
```

### Docker 모니터링
```toml
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  container_names = []
  timeout = "5s"
  perdevice = true
  total = true
```

### HTTP 엔드포인트 체크
```toml
[[inputs.http_response]]
  urls = ["https://myapp.com/health", "https://api.myapp.com/status"]
  response_timeout = "5s"
  method = "GET"
  follow_redirects = true
```

### 커스텀 스크립트
```toml
[[inputs.exec]]
  commands = ["/opt/scripts/custom_metric.sh"]
  timeout = "5s"
  data_format = "influx"    # Line Protocol 형식 출력
```

---

## 실행 및 관리

```bash
# 설정 파일 테스트
telegraf --config telegraf.conf --test

# 포그라운드 실행
telegraf --config telegraf.conf

# 서비스 시작
sudo systemctl start telegraf
sudo systemctl enable telegraf

# 로그 확인
sudo journalctl -u telegraf -f
```

---

## Telegraf + Grafana + InfluxDB 연동 구성

```text
[서버/앱] → [Telegraf] → [InfluxDB] → [Grafana 대시보드]
```

이 구성은 서버 모니터링의 가장 일반적인 오픈소스 스택입니다.

| 단계 | 역할 |
|------|------|
| Telegraf | 10초마다 시스템 메트릭 수집 → InfluxDB 전송 |
| InfluxDB | 시계열 데이터 저장, 30일 보존 |
| Grafana | InfluxDB를 데이터 소스로 대시보드 시각화 |

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
