---
title: "[InfluxDB] 05. Task, 다운샘플링, 알림"
categories: 
    - influxdb
tags: 
    [influxdb, timeseries, influxdb강좌, 중급, 'lecture-influxdb']
toc : true
toc_sticky  : true    
---

InfluxDB의 Task(예약 작업), 다운샘플링, 알림(Alert) 설정을 정리합니다.

# Task (예약 작업)

Task는 Flux 스크립트를 주기적으로 실행하는 예약 작업입니다.    
다운샘플링, 데이터 변환, 알림 등에 활용됩니다.

## Task 생성

### 웹 UI에서 생성
InfluxDB 웹 UI → Tasks → Create Task

### Flux 스크립트로 생성
```flux
option task = {
    name: "downsample_cpu_hourly",
    every: 1h,
    offset: 5m    // 데이터 지연 고려 (5분 후 실행)
}

from(bucket: "raw_metrics")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> to(bucket: "downsampled_metrics", org: "myorg")
```

### Task 옵션

| 옵션 | 설명 | 예시 |
|------|------|------|
| `name` | 작업 이름 | `"downsample_cpu"` |
| `every` | 실행 간격 | `1h`, `5m`, `1d` |
| `cron` | Cron 표현식 | `"0 * * * *"` (매시 정각) |
| `offset` | 실행 지연 | `5m` (데이터 도착 대기) |

---

## 다운샘플링 (Downsampling)

원본 데이터를 요약하여 저장 공간을 절약하고 장기 조회 성능을 향상시킵니다.

### 전략 예시

| 보존 기간 | 해상도 | 버킷 |
|----------|--------|------|
| 7일 | 원본 (10초) | raw_metrics |
| 30일 | 5분 평균 | metrics_5m |
| 1년 | 1시간 평균 | metrics_1h |
| 무기한 | 1일 평균 | metrics_1d |

### 다운샘플링 Task 예시
```flux
// 5분 평균으로 다운샘플링
option task = { name: "downsample_5m", every: 5m, offset: 30s }

from(bucket: "raw_metrics")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "cpu" or r._measurement == "memory")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> to(bucket: "metrics_5m", org: "myorg")
```

```flux
// 1시간 평균 + 최대값 다운샘플링
option task = { name: "downsample_1h", every: 1h, offset: 5m }

data = from(bucket: "metrics_5m")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "cpu")

// 평균
data |> aggregateWindow(every: 1h, fn: mean) |> to(bucket: "metrics_1h_avg")

// 최대값
data |> aggregateWindow(every: 1h, fn: max) |> to(bucket: "metrics_1h_max")
```

---

## 알림 (Alert / Check)

InfluxDB 2.x는 내장 알림 기능을 제공합니다.

### 구성 요소

| 구성 요소 | 설명 |
|----------|------|
| Check | 데이터를 주기적으로 확인하고 상태 판단 |
| Notification Rule | 상태 변경 시 알림 전송 규칙 |
| Notification Endpoint | 알림 수신 대상 (Slack, Email, PagerDuty 등) |

### Check 종류

| 종류 | 설명 |
|------|------|
| Threshold Check | 임계값 기반 (값 > 90이면 CRIT) |
| Deadman Check | 데이터 미수신 감지 (10분간 데이터 없으면 알림) |

### Threshold Check 예시 (Flux)
```flux
import "influxdata/influxdb/monitor"

option task = { name: "cpu_alert", every: 1m }

data = from(bucket: "mybucket")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "cpu" and r._field == "usage_user")
  |> aggregateWindow(every: 1m, fn: mean)

data
  |> monitor.check(
      crit: (r) => r._value > 90.0,
      warn: (r) => r._value > 70.0,
      info: (r) => r._value > 50.0,
      ok: (r) => r._value <= 50.0,
      messageFn: (r) => "CPU 사용률: ${string(v: r._value)}% on ${r.host}"
  )
```

### Deadman Check (데이터 미수신 감지)
```flux
import "influxdata/influxdb/monitor"

option task = { name: "deadman_check", every: 5m }

from(bucket: "mybucket")
  |> range(start: -10m)
  |> filter(fn: (r) => r._measurement == "heartbeat")
  |> monitor.deadman(t: -5m)
```

---

## Notification Endpoint 설정

### Slack
```bash
influx notification-endpoint create \
  --name slack-alerts \
  --type slack \
  --url "https://hooks.slack.com/services/T00/B00/xxx"
```

### Webhook (범용)
```bash
influx notification-endpoint create \
  --name webhook-alerts \
  --type http \
  --url "https://myapp.com/webhook/alerts" \
  --method POST
```

---

## Task 관리

```bash
# Task 목록
influx task list

# Task 실행 이력
influx task log list --task-id <task-id>

# Task 비활성화/활성화
influx task update --id <task-id> --status inactive
influx task update --id <task-id> --status active

# Task 삭제
influx task delete --id <task-id>

# 수동 실행
influx task retry-failed --id <task-id>
```

{% assign c-category = 'influxdb' %}
{% assign c-tag = 'lecture-influxdb' %}
{% include /custom-ref.html %}
