---
title: Python 자료형 tuple 타입
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', list ]
toc : true
toc_sticky  : true    
---
순서가 보장되고, 중복이 허용되나 변경은되지 않는 읽기 전용의 자료형 입니다.   

# list vs tuple vs dictionary vs set

|  | list | tuple | dictionary | set |
|:---:|:---:|:---:|:---:|:---:|
| 순서 | O | O | X | X | 
| 중복 | O | O | X | X |
| 변경 | O | X | O | O |
| 형태 | [1,2,3,4,5] | (1,2,3,4,5) | {"java":10, "key":5} | {1, 2, 3} |
| type | <class 'list'> | <class 'tuple'> | <class 'dict'> | <class 'set'> |

형태 `(값, 값...., 값)` 의 형태의 자료형, 읽기 전용    
예)
 `a = (1, 2, 3, 4, 5)`   
 `a = ("AB", 10, False)`   

# 기본 사용법
## 인덱스
```python
t = ("AB", 10, False)
print(t)    # ('AB', 10, False)

t = (1, 5, 10)
 
# 인덱스
second = t[1]      # 5
last = t[-1]       # 10
 
# 슬라이스
s = t[1:2]         # (5)
s = t[1:]          # (5, 10)

```
## 연산, 반복
```python
a = (1, 2)
b = (3, 4, 5)
c = a + b
print(c)   # (1, 2, 3, 4, 5)

# 반복
d = a * 3
print(d)   # (1, 2, 1, 2, 1, 2)
```

## 변수 할당
```python
a, b, c = (1, "A", False)
print(a)    # 1
print(b)    # A
print(c)    # False
```

## tuple to dict 변환
```python
age_tuples = [('철수', 18), ('영희', 16), ('순희', 20), ('인숙', 14)]
age_dict = {t[0]: t[1] for t in age_tuples}
print(type(age_dict))   # <class 'dict'>
print(age_dict) #  {'철수': 18, '영희': 16, '순희': 20, '인숙': 14}

```

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}