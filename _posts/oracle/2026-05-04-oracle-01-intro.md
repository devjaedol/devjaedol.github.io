---
title: "[Oracle] 01. Oracle DB 소개 및 설치"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 초급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle Database의 기본 개념과 설치 방법을 알아봅니다.

# Oracle Database란?

Oracle Database는 세계에서 가장 널리 사용되는 상용 관계형 데이터베이스 관리 시스템(RDBMS)입니다.    
대규모 엔터프라이즈 환경에서 높은 안정성과 성능을 제공합니다.

## Oracle vs MySQL 비교

| 항목 | Oracle | MySQL |
|:---:|:---:|:---:|
| 개발사 | Oracle Corporation | Oracle Corporation (인수) |
| 라이선스 | 상용 (Enterprise/Standard) | GPL + 상용 이중 라이선스 |
| 가격 | 고가 (코어당 과금) | 무료 (Community) |
| 무료 버전 | XE (Express Edition) | Community Edition |
| 트랜잭션 | 강력한 MVCC | InnoDB 기반 MVCC |
| PL/SQL | 지원 (강력) | 미지원 (Stored Procedure만) |
| RAC (클러스터) | 지원 | 미지원 |
| 파티셔닝 | 기본 지원 | Enterprise만 지원 |
| 시퀀스 | SEQUENCE 객체 | AUTO_INCREMENT |

---

## Oracle 에디션

| 에디션 | 특징 | 용도 |
|--------|------|------|
| Enterprise Edition (EE) | 모든 기능 포함, RAC/파티셔닝 등 | 대규모 운영 환경 |
| Standard Edition (SE2) | 기본 기능, 최대 2소켓 | 중소규모 환경 |
| Express Edition (XE) | 무료, 리소스 제한 (12GB 데이터, 2GB RAM) | 학습, 개발, 소규모 |
| Personal Edition | 단일 사용자 | 개발/테스트 |

> 이 강좌에서는 무료로 사용 가능한 Oracle XE를 기준으로 설명합니다.

---

## 설치

### Windows

#### Oracle XE 설치
1. [Oracle XE 다운로드](https://www.oracle.com/database/technologies/xe-downloads.html){:target="_blank"} 페이지에서 설치 파일 다운로드
2. `OracleXE213_Win64.zip` 압축 해제 후 `setup.exe` 실행
3. 설치 경로 지정 (기본: `C:\app\oracle`)
4. SYS/SYSTEM 관리자 비밀번호 설정
5. 설치 완료 후 서비스 자동 등록

#### 설치 확인
```sql
-- SQL*Plus로 접속
sqlplus sys/비밀번호 as sysdba

-- 버전 확인
SELECT * FROM v$version;

-- 현재 인스턴스 확인
SELECT instance_name, status FROM v$instance;
```

### Mac / Linux

#### Docker를 이용한 설치 (권장)
Oracle은 Mac을 공식 지원하지 않으므로 Docker를 사용합니다.
```bash
# Oracle XE 21c 컨테이너 실행
docker run -d \
  --name oracle-xe \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PWD=OraclePass123 \
  -v oracle-data:/opt/oracle/oradata \
  container-registry.oracle.com/database/express:21.3.0-xe

# 컨테이너 접속
docker exec -it oracle-xe sqlplus sys/OraclePass123@localhost:1521/XE as sysdba
```

#### Linux (RPM 설치)
```bash
# Oracle XE RPM 설치 (Oracle Linux / CentOS)
sudo yum install oracle-database-preinstall-21c
sudo yum localinstall oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm

# 초기 설정
sudo /etc/init.d/oracle-xe-21c configure
```

---

## Oracle 아키텍처 기본 개념

### 주요 용어

| 용어 | 설명 |
|------|------|
| Instance | 메모리(SGA) + 백그라운드 프로세스 |
| Database | 물리적 파일 (데이터파일, 리두로그, 컨트롤파일) |
| SGA | System Global Area, 공유 메모리 영역 |
| PGA | Program Global Area, 세션별 메모리 |
| Tablespace | 논리적 저장 공간 단위 |
| Schema | 사용자가 소유한 객체(테이블, 뷰 등)의 집합 |
| SID | System Identifier, 인스턴스 식별자 |
| Service Name | 데이터베이스 서비스 이름 |

### Oracle vs MySQL 용어 매핑

| Oracle | MySQL | 설명 |
|--------|-------|------|
| Schema (= User) | Database | 논리적 데이터 그룹 |
| Tablespace | 없음 (파일 기반) | 물리적 저장 공간 |
| SEQUENCE | AUTO_INCREMENT | 자동 증가 번호 |
| ROWNUM / ROW_NUMBER | LIMIT | 행 수 제한 |
| NVL() | IFNULL() | NULL 대체 |
| SYSDATE | NOW() | 현재 날짜/시간 |
| DUAL | 불필요 | 더미 테이블 |
| PL/SQL | Stored Procedure | 절차적 SQL |
| SQL*Plus | mysql CLI | 명령줄 도구 |

---

## 접속 방법

### SQL*Plus (CLI)
```bash
# SYS 관리자 접속
sqlplus sys/비밀번호 as sysdba

# 일반 사용자 접속
sqlplus 사용자명/비밀번호@호스트:포트/서비스명
sqlplus devuser/pass123@localhost:1521/XE

# 원격 접속
sqlplus devuser/pass123@192.168.1.100:1521/ORCL
```

### 접속 문자열 (TNS)
```text
-- tnsnames.ora 설정
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XE)
    )
  )
```

### GUI 도구

| 도구 | 특징 | 가격 |
|------|------|------|
| SQL Developer | Oracle 공식 도구, 무료 | 무료 |
| DBeaver | 다중 DB 지원, 범용 | 무료 (Community) |
| DataGrip | JetBrains, 강력한 자동완성 | 유료 |
| Toad for Oracle | 전통적인 Oracle 전용 도구 | 유료 |
| Orange | 국산 Oracle 전용 도구 | 유료 |

---

## 서비스 관리

| 기능 | Windows | Linux |
|------|---------|-------|
| 시작 | `net start OracleServiceXE` | `sudo systemctl start oracle-xe-21c` |
| 중지 | `net stop OracleServiceXE` | `sudo systemctl stop oracle-xe-21c` |
| 리스너 시작 | `lsnrctl start` | `lsnrctl start` |
| 리스너 중지 | `lsnrctl stop` | `lsnrctl stop` |
| 리스너 상태 | `lsnrctl status` | `lsnrctl status` |

```sql
-- SQL*Plus에서 DB 시작/종료
STARTUP;
SHUTDOWN IMMEDIATE;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}
