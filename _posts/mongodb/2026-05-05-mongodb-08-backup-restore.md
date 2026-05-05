---
title: "[MongoDB] 08. 백업과 복구"
categories: 
    - mongodb
tags: 
    [mongodb, nosql, mongodb강좌, 고급, 'lecture-mongodb']
toc : true
toc_sticky  : true    
---

MongoDB의 백업 전략, 도구, 복구 방법을 정리합니다.

# 백업 도구 비교

| 도구 | 방식 | 용도 |
|------|------|------|
| mongodump / mongorestore | 논리적 백업 (BSON 덤프) | 소규모, 부분 백업 |
| 파일 시스템 스냅샷 | 물리적 백업 | 대규모, 빠른 복구 |
| MongoDB Atlas Backup | 클라우드 자동 백업 | Atlas 사용 시 |
| Ops Manager / Cloud Manager | 엔터프라이즈 백업 | 대규모 운영 |

---

## mongodump / mongorestore

### 백업 (mongodump)
```bash
# 전체 백업
mongodump --uri="mongodb://admin:pass@localhost:27017" --out=/backup/mongo_$(date +%Y%m%d)

# 특정 데이터베이스
mongodump --db=mydb --out=/backup/mydb_backup

# 특정 컬렉션
mongodump --db=mydb --collection=users --out=/backup/users_backup

# 조건부 백업
mongodump --db=mydb --collection=orders --query='{"date":{"$gte":{"$date":"2026-01-01T00:00:00Z"}}}'

# 압축 백업
mongodump --db=mydb --gzip --out=/backup/mydb_compressed

# 아카이브 (단일 파일)
mongodump --db=mydb --archive=/backup/mydb.archive --gzip

# 인증 포함
mongodump -u admin -p AdminPass123! --authenticationDatabase admin --db=mydb --out=/backup/
```

### 복구 (mongorestore)
```bash
# 전체 복구
mongorestore /backup/mongo_20260505/

# 특정 데이터베이스 복구
mongorestore --db=mydb /backup/mydb_backup/mydb/

# 기존 데이터 삭제 후 복구
mongorestore --drop --db=mydb /backup/mydb_backup/mydb/

# 압축 파일 복구
mongorestore --gzip /backup/mydb_compressed/

# 아카이브 복구
mongorestore --archive=/backup/mydb.archive --gzip

# 특정 컬렉션만 복구
mongorestore --db=mydb --collection=users /backup/mydb_backup/mydb/users.bson

# 다른 DB로 복구
mongorestore --db=mydb_restored /backup/mydb_backup/mydb/
```

---

## mongoexport / mongoimport (JSON/CSV)

개발/마이그레이션 용도로 JSON이나 CSV 형식으로 내보내기/가져오기합니다.

```bash
# JSON 내보내기
mongoexport --db=mydb --collection=users --out=users.json

# CSV 내보내기
mongoexport --db=mydb --collection=users --type=csv --fields=name,email,age --out=users.csv

# JSON 가져오기
mongoimport --db=mydb --collection=users --file=users.json

# CSV 가져오기
mongoimport --db=mydb --collection=users --type=csv --headerline --file=users.csv

# 기존 데이터 삭제 후 가져오기
mongoimport --db=mydb --collection=users --drop --file=users.json
```

---

## 파일 시스템 스냅샷

대용량 데이터에서 가장 빠른 백업/복구 방법입니다.

### 절차
```bash
# 1. 쓰기 잠금 (일관성 보장)
mongosh --eval "db.fsyncLock()"

# 2. 파일 시스템 스냅샷 (LVM, EBS 등)
lvcreate --size 10G --snapshot --name mongo_snap /dev/vg0/mongo_data

# 3. 잠금 해제
mongosh --eval "db.fsyncUnlock()"

# 4. 스냅샷에서 데이터 복사
mount /dev/vg0/mongo_snap /mnt/snapshot
cp -a /mnt/snapshot/data/* /backup/snapshot/
```

---

## 자동 백업 스크립트

```bash
#!/bin/bash
# backup_mongodb.sh

BACKUP_DIR="/backup/mongodb"
DATE=$(date +%Y%m%d_%H%M%S)
MONGO_URI="mongodb://admin:AdminPass123!@localhost:27017"
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

# 백업 실행
mongodump --uri="$MONGO_URI" --gzip --archive=$BACKUP_DIR/full_${DATE}.archive.gz

echo "$(date): 백업 완료 - full_${DATE}.archive.gz" >> $BACKUP_DIR/backup.log

# 오래된 백업 삭제
find $BACKUP_DIR -name "*.archive.gz" -mtime +$RETENTION_DAYS -delete
```

```bash
# crontab 등록 (매일 새벽 3시)
0 3 * * * /path/to/backup_mongodb.sh
```

---

## Oplog 기반 시점 복구

Replica Set 환경에서 Oplog를 활용하면 특정 시점으로 복구할 수 있습니다.

```bash
# 1. 전체 백업 복구
mongorestore --drop /backup/full_backup/

# 2. Oplog 덤프 (특정 시점까지)
mongodump --db=local --collection=oplog.rs --query='{"ts":{"$lte":{"$timestamp":{"t":1714900000,"i":1}}}}'

# 3. Oplog 적용
mongorestore --oplogReplay --oplogFile=oplog.bson
```

---

## 백업 전략 가이드

| 환경 | 전략 | 주기 |
|------|------|------|
| 개발 | mongodump | 주 1회 |
| 소규모 운영 | mongodump + gzip | 일 1회 |
| 중규모 운영 | 파일 시스템 스냅샷 + Oplog | 일 1회 + 시점 복구 |
| 대규모 운영 | Ops Manager 또는 Atlas Backup | 연속 백업 |

{% assign c-category = 'mongodb' %}
{% assign c-tag = 'lecture-mongodb' %}
{% include /custom-ref.html %}
