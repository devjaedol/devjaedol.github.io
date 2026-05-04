---
title: "Python 가상환경 구축 (venv vs uv)"
categories: 
    - python
tags: 
    - python
    - venv
    - uv
    - virtualenv
toc : true
toc_sticky  : true    
---

Python 프로젝트를 진행할 때 가상환경은 필수다. 프로젝트마다 패키지 버전이 다를 수 있고, 시스템 Python에 직접 설치하면 충돌이 발생하기 쉽다. 이 글에서는 Python 기본 내장 모듈인 `venv`와 최근 주목받고 있는 `uv`를 비교하고, 각각의 가상환경 구축 방법을 Windows / Mac 기준으로 정리한다.

---

# 1. 가상환경이란?

가상환경(Virtual Environment)은 프로젝트별로 독립된 Python 실행 환경을 만들어주는 기능이다.

- 프로젝트마다 서로 다른 패키지 버전을 사용할 수 있다
- 시스템 Python 환경을 오염시키지 않는다
- 팀원 간 동일한 개발 환경을 쉽게 공유할 수 있다

---

# 2. venv vs uv 비교

## 2-1. 개요 비교

| 항목 | venv | uv |
|------|------|-----|
| 개발사 | Python 공식 (CPython) | Astral (Ruff 개발사) |
| 언어 | Python | Rust |
| 설치 | Python 3.3+ 내장 (별도 설치 불필요) | 별도 설치 필요 (`pip install uv` 또는 installer) |
| 첫 릴리즈 | Python 3.3 (2012) | 2024년 2월 |
| 패키지 관리 | pip을 별도로 사용 | uv 자체에 pip 호환 기능 내장 |

## 2-2. 장단점 비교

| 구분 | venv | uv |
|------|------|-----|
| **장점** | Python 내장이라 별도 설치 불필요 | 가상환경 생성·패키지 설치 속도가 매우 빠름 (10~100배) |
| | 공식 도구라 안정성이 높음 | pip, pip-tools, virtualenv 기능을 하나로 통합 |
| | 대부분의 Python 튜토리얼에서 기본으로 사용 | lock 파일 기반의 재현 가능한 빌드 지원 |
| | 추가 의존성 없이 바로 사용 가능 | Rust 기반이라 대규모 프로젝트에서 성능 우수 |
| **단점** | 패키지 설치 속도가 상대적으로 느림 | 별도 설치가 필요함 |
| | lock 파일 미지원 (requirements.txt 수동 관리) | 비교적 새로운 도구라 레퍼런스가 적음 |
| | 가상환경 생성 속도가 느린 편 | 일부 엣지 케이스에서 pip과 동작이 다를 수 있음 |

## 2-3. 주요 명령어 비교

| 기능 | venv + pip | uv |
|------|-----------|-----|
| 가상환경 생성 | `python -m venv .venv` | `uv venv .venv` |
| 가상환경 활성화 (Windows) | `.venv\Scripts\activate` | `.venv\Scripts\activate` |
| 가상환경 활성화 (Mac/Linux) | `source .venv/bin/activate` | `source .venv/bin/activate` |
| 패키지 설치 | `pip install requests` | `uv pip install requests` |
| requirements.txt로 설치 | `pip install -r requirements.txt` | `uv pip install -r requirements.txt` |
| 설치된 패키지 목록 | `pip list` | `uv pip list` |
| 패키지 제거 | `pip uninstall requests` | `uv pip uninstall requests` |
| requirements.txt 생성 | `pip freeze > requirements.txt` | `uv pip freeze > requirements.txt` |
| 가상환경 비활성화 | `deactivate` | `deactivate` |
| 가상환경 삭제 | 폴더 직접 삭제 (`rm -rf .venv`) | 폴더 직접 삭제 (`rm -rf .venv`) |

---

# 3. venv로 가상환경 구축하기 (Windows / Mac)

## 3-1. 사전 준비

Python 3.3 이상이 설치되어 있어야 한다. 터미널에서 버전을 확인한다.

```bash
python --version
```

## 3-2. 가상환경 생성 ~ 삭제 전체 절차

| 단계 | 설명 | Windows (CMD / PowerShell) | Mac / Linux (Terminal) |
|:----:|------|---------------------------|----------------------|
| 1 | 프로젝트 폴더 생성 및 이동 | `mkdir myproject && cd myproject` | `mkdir myproject && cd myproject` |
| 2 | 가상환경 생성 | `python -m venv .venv` | `python3 -m venv .venv` |
| 3 | 가상환경 활성화 | `.venv\Scripts\activate` | `source .venv/bin/activate` |
| 4 | 활성화 확인 (프롬프트 변경) | `(.venv) C:\myproject>` | `(.venv) user@mac:~/myproject$` |
| 5 | 패키지 설치 | `pip install requests flask` | `pip install requests flask` |
| 6 | 설치된 패키지 확인 | `pip list` | `pip list` |
| 7 | requirements.txt 생성 | `pip freeze > requirements.txt` | `pip freeze > requirements.txt` |
| 8 | requirements.txt로 일괄 설치 | `pip install -r requirements.txt` | `pip install -r requirements.txt` |
| 9 | 가상환경 비활성화 | `deactivate` | `deactivate` |
| 10 | 가상환경 삭제 | `rmdir /s /q .venv` | `rm -rf .venv` |

## 3-3. PowerShell 실행 정책 오류 해결 (Windows)

Windows PowerShell에서 activate 실행 시 아래 오류가 발생할 수 있다.

```
.venv\Scripts\Activate.ps1 : 이 시스템에서 스크립트를 실행할 수 없으므로 ...
```

해결 방법:

```powershell
# 현재 사용자에 대해 실행 정책 변경
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 3-4. .gitignore 설정

가상환경 폴더는 Git에 포함시키지 않는다. `.gitignore`에 아래 내용을 추가한다.

```text
.venv/
```

---

# 4. uv로 가상환경 구축하기 (Windows / Mac)

## 4-1. uv 설치

| OS | 설치 명령어 |
|----|-----------|
| Windows (PowerShell) | `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 \| iex"` |
| Windows (pip) | `pip install uv` |
| Mac / Linux (curl) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Mac (Homebrew) | `brew install uv` |

설치 확인:

```bash
uv --version
```

## 4-2. 가상환경 생성 ~ 삭제 전체 절차

| 단계 | 설명 | Windows (CMD / PowerShell) | Mac / Linux (Terminal) |
|:----:|------|---------------------------|----------------------|
| 1 | 프로젝트 폴더 생성 및 이동 | `mkdir myproject && cd myproject` | `mkdir myproject && cd myproject` |
| 2 | 가상환경 생성 | `uv venv .venv` | `uv venv .venv` |
| 3 | Python 버전 지정 생성 (선택) | `uv venv .venv --python 3.12` | `uv venv .venv --python 3.12` |
| 4 | 가상환경 활성화 | `.venv\Scripts\activate` | `source .venv/bin/activate` |
| 5 | 활성화 확인 (프롬프트 변경) | `(.venv) C:\myproject>` | `(.venv) user@mac:~/myproject$` |
| 6 | 패키지 설치 | `uv pip install requests flask` | `uv pip install requests flask` |
| 7 | 설치된 패키지 확인 | `uv pip list` | `uv pip list` |
| 8 | requirements.txt 생성 | `uv pip freeze > requirements.txt` | `uv pip freeze > requirements.txt` |
| 9 | requirements.txt로 일괄 설치 | `uv pip install -r requirements.txt` | `uv pip install -r requirements.txt` |
| 10 | 가상환경 비활성화 | `deactivate` | `deactivate` |
| 11 | 가상환경 삭제 | `rmdir /s /q .venv` | `rm -rf .venv` |

## 4-3. uv 프로젝트 관리 (pyproject.toml 기반)

uv는 `pyproject.toml` 기반의 프로젝트 관리도 지원한다. 이 방식을 사용하면 lock 파일로 더 안정적인 의존성 관리가 가능하다.

```bash
# 새 프로젝트 초기화
uv init myproject
cd myproject

# 패키지 추가 (pyproject.toml에 자동 기록)
uv add requests
uv add flask

# lock 파일 기반으로 동기화
uv sync

# 패키지 제거
uv remove requests
```

이 방식은 `uv.lock` 파일이 자동 생성되어 팀원 간 동일한 환경을 보장한다.

---

# 5. 어떤 도구를 선택할까?

| 상황 | 추천 도구 |
|------|----------|
| Python을 처음 배우는 경우 | venv (공식 도구, 튜토리얼 호환) |
| 빠른 환경 구축이 필요한 경우 | uv (생성·설치 속도 압도적) |
| 팀 프로젝트에서 환경 통일이 중요한 경우 | uv (lock 파일 지원) |
| 별도 도구 설치 없이 바로 시작하고 싶은 경우 | venv (Python 내장) |
| CI/CD 파이프라인 속도가 중요한 경우 | uv (빌드 시간 단축) |
| 레거시 프로젝트 유지보수 | venv (호환성 안정적) |

---

# 6. 자주 쓰는 명령어 요약

## venv 명령어

```bash
python -m venv .venv          # 가상환경 생성
source .venv/bin/activate      # 활성화 (Mac/Linux)
.venv\Scripts\activate         # 활성화 (Windows)
pip install 패키지명            # 패키지 설치
pip freeze > requirements.txt  # 의존성 저장
pip install -r requirements.txt # 의존성 일괄 설치
deactivate                     # 비활성화
```

## uv 명령어

```bash
uv venv .venv                  # 가상환경 생성
uv venv .venv --python 3.12   # 특정 Python 버전으로 생성
source .venv/bin/activate      # 활성화 (Mac/Linux)
.venv\Scripts\activate         # 활성화 (Windows)
uv pip install 패키지명         # 패키지 설치
uv pip freeze > requirements.txt # 의존성 저장
uv pip install -r requirements.txt # 의존성 일괄 설치
uv add 패키지명                 # pyproject.toml에 추가
uv sync                        # lock 파일 기반 동기화
deactivate                     # 비활성화
```
