---
title: Python 기초
categories: 
    - python
tags: 
    - python강좌
    - python
    - 초급
toc : true
toc_sticky  : true    
---

파이썬 IDLE를 실행 합니다.    

## 기본 실습 하기
> 100 + 50    
> print('Hello world')    
> "string"*5    

```python
Python 3.10.0 (tags/v3.10.0:b494f59, Oct  4 2021, 19:00:18) [MSC v.1929 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> 100+50
150
>>> print('Hello world')
Hello world
>>> "string"*5
'stringstringstringstringstring'
```

## 자료형
Python에 주요 자료형 입니다.    
- 수치 자료형  
    - int  
    - float  
    - complex  
- 불 자료형   
    - bool   
- 군집 자료형   
    - list   
    - tuple   
    - dict   
    - set   
- 문자 자료형
    - str    

```python
# int
# type( xxx ) 은 자료형을 출력 합니다.

a = 1
type(a)
#<class 'int'>

b = 5.7
type(b)
#<class 'float'>

c = 5 + 1j
type(c)
#<class 'complex'>

d = True
type(d)
#<class 'bool'>

e = [1,2,3,4,5]
type(e)
#<class 'list'>     #(순서 O, 중복 O, 변경 O)

f = (1,2,3,4,5)
type(f)
#<class 'tuple'>    #(순서 O, 중복 O, 변경 X)

g = {"java":10, "python":5, "C":3}
type(g)
#<class 'dict'>     #(순서 X, 중복 X, 변경 O)

h = {1, 2, 3}
type(h)
#<class 'set'>      #(순서 X, 중복 X, 변경 O)

i = '가나다라마'
type(i)
#<class 'str'>
```
![파이썬 자료형](\assets/images_post/python/python-study-02_1.png)

## 연산자

## 조건문 

## 반복문

## 함수


## 예약어 확인하기
파이썬에는 다음과 같은 예약어는 사용 할 수 없습니다.   
참고 하시기 바랍니다.
```python
import keyword
print(keyword.kwlist)
['False', 'None', 'True', 'and', 'as', 'assert', 
'async', 'await', 'break', 'class', 'continue', 'def', 
'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 
'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal',
 'not', 'or', 'pass', 'raise', 'return', 'try', 
 'while', 'with', 'yield']
```
