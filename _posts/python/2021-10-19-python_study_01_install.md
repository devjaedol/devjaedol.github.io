---
title: "[Python Basic] 설치"
categories: 
    - python
tags: 
    - python강좌
    - python
    - 초급
    - 'lecture-python-basic'
toc : true
toc_sticky  : true        
---

파이썬 공부를 시작해봅시다.   
우선 파이썬 설치를... 시작이 반...
파이썬을 설치하고 사용할 수 있는 방법에는 몇가지 방법이 있습니다.    
아래 소개는 간단한 몇 가지 방법만 설명드리지만, 더 다양한 등이 있으니 참고 하시기 바랍니다.    

# Local에 설치 하기
[다운 로드 경로](https://www.python.org/downloads/){:target="_blank"}

![python-study-01-_1](\assets/images_post/python/python-study-01-_1.png)

다운로드 선택

![python-study-01-_2](\assets/images_post/python/python-study-01-_2.png)

설치 경로를 변경하기 위해서 Customzie 선택

![python-study-01-_3](\assets/images_post/python/python-study-01-_3.png)

기본값 Next

![python-study-01-_4](\assets/images_post/python/python-study-01-_4.png)

경로 변경

![python-study-01-_5](\assets/images_post/python/python-study-01-_5.png)

![python-study-01-_6](\assets/images_post/python/python-study-01-_6.png)

![python-study-01-_7](\assets/images_post/python/python-study-01-_7.png)

완료시 윈도우 시작위치에 위 항목이 추가됨 IDLE를 선택하여 실행함.

![python-study-01-_8](\assets/images_post/python/python-study-01-_8.png)

설치 버전이 정상 표기되면, 설치 완료됨.

window path는 필요시 추가해야 합니다.


# Google Colab 을 통해서 설치 하기
온라인에서 python을 테스트 할수 있도록 하는 구글이 제공하는 개발 환경 입니다.    
docker기반에 google drive 를 활용하여 제공하는 무료 환경으로 사용하기 편리하고 동시에 여려명이 수정가능하며, 별도의 설치 없이 사용할 수 있는 장점이 있습니다.   

몇가지 제약사항이 있는데 참고 하기 바랍니다.    
- 세션은 최대 12시간 입니다.
- 세션에 반응 없으면 자동으로 끊깁니다.
- 세션이 종료될떄 데이터는 소멸됩니다.

공짜인 만큼 제약이 있지만, 돈을 내면 또 제약이 풀립니다.   
이부분은 `colab pro` 가 있으니 알아보시면 될 것 같습니다.   
뛰어난 개발자분들이 무료에서 세션을 않끊기는 tip 코드를 공유된 곳이 많으니 그것도 찾아보시면 있습니다.(자동 리프레쉬 코드를... 이 부분은 검색 러쉬)    

설치는 간단 합니다.
1. 구글 계정 로그인(필요시 회원 가입도 하시구요)
1. 구글 드라이버 메뉴에서 `내 드라이브(마우스 왼쪽 클릭) > 더보기 > 연결할 앱 더보기` 선택 합니다. 
![python-study-01-_11](\assets/images_post/python/python-study-01-_11.png)
1. 마켓플레이스 창이 나오는데 해당 부분에 `Colaboratory` 를 입력합니다.
![python-study-01-_11](\assets/images_post/python/python-study-01-_12.png)
1. 설치를 진행합니다.
1. 하기 메뉴를 통해서 진입이 가능합니다.
![python-study-01-_11](\assets/images_post/python/python-study-01-_13.png)
1. `hello world` 출력은 아래처럼 입력후 Play 버튼 또는 Enter 실행시 RAM과 디스크가 연결되며 출력되는 것을 확인 할 수 있습니다.   
![python-study-01-_11](\assets/images_post/python/python-study-01-_14.png)


# 온라인 웹 사이트 사용하기
온라인에서 직접 사용할 수 있는 사이트 들도 존재 합니다. (검색하면 많이 나옵니다.)    
그중 하나를 소개 합니다.    
[replit.com](https://replit.com/languages/python3){:target="_blank"}
python 외에도 다양한 언어를 지원합니다.
간단한 기초 공부에는 사용이 가능하니 참고 하시기 바랍니다.  

![python-study-01-_9](\assets/images_post/python/python-study-01-_9.png)

# jupyter nootbook 사용하기
jupyter nootbook은 구글 코랩과 비슷한 형태로 로컬에 설치되는 웹기반의 python 환경 입니다.    
우선 로컬에 python이 설치된 후 사용이 가능합니다.    
`pip` 명령을 통해서 설치 가능 합니다.

```python
# 설치 하기
pip install jupyter     

# 실행하기 (실행 명령어 위치를 Root로 인식함)
jupyter notebook

# 접속하기
http://localhost:8888/tree

```


![python-study-01-_10](\assets/images_post/python/python-study-01-_10.png)


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}


