---
title: "[Python Basic] 모듈 만들기, 패키지 만들기"
categories:  
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', package ]
toc : true
toc_sticky  : true    
---
Python 만든 함수를 모듈화 또는 패키지화를 만들어 봅시다.    
자주 사용하는 함수, 변수 또는 클래스 등을 재사용성을 높이기 위해서 모듈화를 진행할 수 있습니다.   

# 모듈 만들기
함수에서 작성한 아래 함수를 `module.py` 로 작성합니다.    
## module.py
```python

def sum(a, b):
    s = a + b
    return s

```

모듈을 사용할 `main.py` 를 만듭니다.   
`module.py` 와 `main.py`는 동일 경로에 위치 합니다.

## main.py
```python
import module as m

c = m.sum(1, 2)
print(c) # 3
```

# 패키지 만들기
## 구성 형태
위 모듈 만들기에서 만들어지는 모듈파일이 여러개로 구성될때, 여러 모듈을 기능에 맞게 패키지로 만들수 있습니다.      
예를 들어 다음 모듈을 만들었다고 할때, 하나의 특정 폴더 `custom` 밑에 위치 시킵니다.     
- \main.py
- \custom\module_sum.py
- \custom\module_min.py
- \custom\module_max.py
- \custom\module_avg.py

위와 같은 경우 아래와 같이 사용할 수 있습니다.   
## main.py
```python
import custom.module_sum as p

c = p.sum(1, 2)
print(c) # 3
```
## main 실행 구성
실행 메인이 되는 함수를 파악하기 위해서 `__name__` 속성을 통해서 실행 주체를 확인 할 수 있습니다.   
`main()` 함수를 `__name__ == "__main__"` 조건에 맞을 경우에만 실행하도록 할 수 있습니다.   
```python
import custom.module_sum as p

def main():
    c = p.sum(1, 2)
    print(c) # 3


if __name__ == "__main__":
    main()  
    
```

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
