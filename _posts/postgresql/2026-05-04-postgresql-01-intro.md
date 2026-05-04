---
title: "[PostgreSQL] 01. PostgreSQL 소개 및 설치"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 초급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 기본 개념과 설치 방법을 알아봅니다.

# PostgreSQL이란?

PostgreSQL은 오픈소스 객체-관계형 데이터베이스 관리 시스템(ORDBMS)입니다.    
30년 이상의 역사를 가진 가장 진보된 오픈소스 RDBMS로, 표준 SQL 준수율이 높고 확장성이 뛰어납니다.

## PostgreSQL vs MySQL vs Oracle 비교

| 항목 | PostgreSQL | MySQL | Oracle |
|:---:|:---:|:---:|:---:|
| 라이선스 | PostgreSQL License (MIT 유사) | GPL + 상용 | 상용 |
| 가격 | 완전 무료 | 무료 (Community) | 고가 |
| SQL 표준 준수 | 매우 높음 | 보통 | 높음 |
| MVCC | 네이티브 | InnoDB만 지원 | Undo 기반 |
| JSON 지원 | JSONB (바이너리, 인덱싱) | JSON 타입 | JSON 지원 |
| 배열 타입 | 네이티브 지원 | 미지원 | VARRAY |
| 상속 | 테이블 상속 지원 | 미지원 | 미지원 |
| 확장성 | 사용자 정의 타입/연산자/함수 | 제한적 | PL/SQL |
| 전문 검색 | 내장 (tsvector) | FULLTEXT Index | Oracle Text |
| 복제 | 스트리밍 복제 내장 | 바이너리 로그 복제 | Data Guard |

---

## 설치

### Windows

1. [PostgreSQL 다운로드](https://www.postgresql.org/download/windows/){:target="_blank"} 페이지에서 인스톨러 다운로드
2. `postgresql-xx-windows-x64.exe` 실행
3. 설치 경로 지정 (기본: `C:\Program Files\PostgreSQL\17`)
4. 데이터 디렉토리 지정
5. superuser(postgres) 비밀번호 설정
6. 포트 설정 (기본: 5432)
7. 로케일 설정 (Korean, Korea 또는 Default)

#### 설치 확인
```bash
psql -U postgres
# 비밀번호 입력 후

SELECT version();
```

### Mac

#### Homebrew를 이용한 설치
```bash
brew install postgresql@17
brew services start postgresql@17

# PATH 설정 (필요 시)
echo 'export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Postgres.app (GUI 방식)
[Postgres.app](https://postgresapp.com/){:target="_blank"} 다운로드 후 Applications 폴더에 드래그하면 설치 완료됩니다.

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib

# 서비스 시작
sudo systemctl start postgresql
sudo systemctl enable postgresql

# postgres 사용자로 접속
sudo -u postgres psql
```

### Docker

```bash
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres123 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:17

# 접속
docker exec -it postgres psql -U postgres
```

---

## 서비스 관리

| 기능 | Windows | Mac (Homebrew) | Linux (systemd) |
|------|---------|----------------|-----------------|
| 시작 | `net start postgresql-x64-17` | `brew services start postgresql@17` | `sudo systemctl start postgresql` |
| 중지 | `net stop postgresql-x64-17` | `brew services stop postgresql@17` | `sudo systemctl stop postgresql` |
| 재시작 | 중지 후 시작 | `brew services restart postgresql@17` | `sudo systemctl restart postgresql` |
| 상태 | `sc query postgresql-x64-17` | `brew services list` | `sudo systemctl status postgresql` |

---

## 접속 방법

### psql (CLI)
```bash
# 로컬 접속
psql -U postgres

# 데이터베이스 지정 접속
psql -U postgres -d mydb

# 원격 접속
psql -h 192.168.1.100 -p 5432 -U postgres -d mydb
```

### psql 주요 메타 명령어

| 명령어 | 설명 |
|--------|------|
| `\l` | 데이터베이스 목록 |
| `\c dbname` | 데이터베이스 전환 |
| `\dt` | 테이블 목록 |
| `\d tablename` | 테이블 구조 |
| `\du` | 사용자/롤 목록 |
| `\di` | 인덱스 목록 |
| `\df` | 함수 목록 |
| `\dn` | 스키마 목록 |
| `\timing` | 쿼리 실행 시간 표시 토글 |
| `\x` | 확장 출력 모드 토글 |
| `\q` | psql 종료 |
| `\?` | 메타 명령어 도움말 |
| `\h SELECT` | SQL 명령어 도움말 |

### GUI 도구

| 도구 | 특징 | 가격 |
|------|------|------|
| pgAdmin | PostgreSQL 공식 도구, 웹 기반 | 무료 |
| DBeaver | 다중 DB 지원, 범용 | 무료 (Community) |
| DataGrip | JetBrains, 강력한 자동완성 | 유료 |
| Postico | Mac 전용, 직관적 UI | 유료 |
| TablePlus | 다중 DB 지원, 깔끔한 UI | 유료 (무료 제한판) |

---

## PostgreSQL 아키텍처 기본 용어

| 용어 | 설명 | MySQL 대응 |
|------|------|-----------|
| Cluster | PostgreSQL 인스턴스 (데이터 디렉토리) | mysqld 인스턴스 |
| Database | 논리적 데이터 그룹 | Database |
| Schema | 데이터베이스 내 네임스페이스 (기본: public) | 없음 (DB가 스키마 역할) |
| Tablespace | 물리적 저장 위치 | 없음 |
| Role | 사용자 + 그룹 통합 개념 | User |
| WAL | Write-Ahead Log (트랜잭션 로그) | Binary Log / Redo Log |
| VACUUM | 죽은 튜플 정리 (MVCC 부산물) | 없음 (InnoDB 자동 처리) |
| TOAST | 대용량 데이터 자동 압축 저장 | 없음 |

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}
