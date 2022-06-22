---
title: "[Python Basic] 함수"
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', function ]
toc : true
toc_sticky  : true    
---



# 함수
## 선언
자주 사용하는 기능을 Function으로 정의할 수 있습니다.   
```python
#반환값이 있는 경우
def 함수명(인자정의)
    함수 내용부
    return 반환값

#반환값이 없는 경우
def 함수명(인자정의)
    함수 내용부

def 함수명(인자정의)
    함수 내용부
    return      #값이 없는 경우 `None`

def sum(a, b):
    s = a + b
    return s
 
total = sum(4, 7)
print(total)

```

단일 값 또는 다중 값(튜플)을 반환 할수 있습니다.
```python
def sum(v1, v2):
    return v1+v2

total = sum(10,20)
print(total)

>>> 30


#다중값 반환 함수
def multi(v1, v2):
    s1 = v1 + v2
    s2 = v1 - v2
    return s1, s2

t1, t2 = multi(20, 10)
print(t1, t2)
>>> 30 10

t = multi(20, 10)
print(t[0], t[1])
```



## 파라메터 초기값 설정
```python
#빈값 입력시 기본값으로 설정 
def sum(v1, v2 = 10):
    return v1+v2

s = sum(5)
>>> 15
```



## 파라메터 이름 설정
```python
#이름으로 설정할 수 있습니다.
def info(name, age):
    print(name, age)

info(age=30, name='Hong Gil Dong')
>>> Hong Gil Dong 30

```



## 가변 길이 파라메터
가변 파라메터의 제약사항    
- 가변 매개변수 뒤에는 일반 매개변수 올수 없음.
- 가변 매개변수는 한개만 사용가능함.
- 가변 매개변수 압 일반 매개변수의 기본값은 무시된다.

```python
#가변형 파라메터 입력 
def keyList(*keys):
    for n in keys:
        print(n)

keyList(1,2,3,4,5)
>>> 1
>>> 2
>>> 3
>>> 4
>>> 5

#일반 파라메터 , 가변형 파라메터 입력 
def keyList(a, b, *keys):
    print(a, b)
    for n in keys:
        print(n)

keyList('a','b', 1,2,3,4,5)
>>> 'a' 'b'
>>> 1
>>> 2
>>> 3
>>> 4
>>> 5

# 가변형 파라메터 + 키워드 일반 파라메터
def keyList(*keys, end='abc'):
    for n in keys:
        print(n)
    print(end)

keyList(1,2,3,4,5)
>>> 1
>>> 2
>>> 3
>>> 4
>>> 5
>>> abc

```

## 함수내 값의 유지(immutable, mutable)
```python
def f(i, list):
    i = i + 1
    list.append(0)
 
k = 10       # k는 int (immutable)
l = [1,2,3]  # l은 리스트 (mutable)
 
f(k, l)      # 함수 호출
print(k, m)  # 호출자 값 체크
# 출력: 10 [1, 2, 3, 0]

```

# python 함수 호출 
`math` 함수를 예로 들어서 설명 합니다.

## 전체 import
`math` 전체를 import 후 호출 시 `math.xxx()`의 형태로 사용함.

```python
import math
a = math.fabs(-7)
print(a)
```

## 일부 함수 import
`math` 전체가 아닌 일부 함수 import
```python
from math import (acos,fabs)
a = fabs(-7)    # math. 을 사용하지 않음
print(a)

```

## 일부(한개) 함수 import
`math` 전체가 아닌 일부 함수 import
```python
from math import fabs
a = fabs(-7)    # math. 을 사용하지 않음
print(a)

```

## import alias
`math` 전체가 아닌 일부 함수 import
```python
from math import fabs as f
a = f(-7)    # f로 사용함
print(a)

```

## 함수가 가진 목록 
```python
dir(math)
```

# python 내장 함수
다음은 별도의 import없이 사용이 가능한 자주 사용하는 내장 함수 입니다.   
- len()
- type()
- int()
- str()
- round()
- abs()
- max()
- min()
- sum()
- sorted() , sort()  ->   list.sort(), sorted(list)
- range()
- chr()
- ord()
- isalpha() -> 'a'.isalpha() True
- isalnum() -> '123'.isalnum() True
- eval()  -> eval('1+2') , eval('round(1.2)')

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
