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

파이썬 공부를 스피드 있게 해봅시다.    
파이썬 IDLE를 실행 합니다.       
설명이 필요 없는 프로그램 공부의 기본을 Start!!!!    
[Python 공식 자습서](https://docs.python.org/ko/3/tutorial/index.html){:target="_blank"}

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
프로그래밍에 기초로 자료형 부터 보시죠.    
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
변수에 대한 연산을 처리하는 연산자 시리즈 입니다.      
- 사칙 연산자 
    - +, -, *, /
    - ** 제곱 
    - % 나머지
    - // 소수점이하 버림 연산
- 비교 연산자 
    - <, >, <=, =>, ==, !=
- 논리 연산자
    - and
    - or
    - not
- 비트와이즈 연산자
    - & (AND)
    - \| (OR)
    - <<, >> (비트 이동)
    - ~ (Completement)
    - ^ (XOR)
- 기타 연산자 
    - +=
    - -=
    - *=
    - in
    - not in
    - is    ( A is B A와 B가 동일 주소를 가르칠때 True)


## 조건문 
프로그램에 기본인 조건에 따라 로직을 분기하는 종류 입니다.   

### if, elif, else
```python
#if문
if tall > 180
    print("키가 큽니다.")


#if, else
if tall > 180:
    print("키가 큽니다.")
else:
    print("키가 작습니다")


#if, elif, else
if tall > 180:
    print("키가 큽니다.")
elif tall < 100:
    print("키가 작습니다")
else:
    print("키가 보통 입니다")

```

## 반복문

### for
```python

# range(반복횟수):
# for 변수 in range(시작값, 끝값+1, 증가값):
for i in range(10):
    print(i)

0
1
2
3
4
5
6
7
8
9


a=[5,6,7,8,9]
for i in a:
    print(i)

    
5
6
7
8
9


#range(이상, 미만)
for i in range(5,10):
    print(i)

5
6
7
8
9

# 중첩 For
for i in range(1,4):
    for j in range(1,4):
        print( i*j ,end="   ")
    print(" ")

1   2   3    
2   4   6    
3   6   9    


#1~10 의 합    
sum=0
for i in range(1,11):
    sum = sum+i
print(sum)

55

```
### while
```python
i=1
sum=0
while i<=10:
    sum=sum+i
print(sum)
55
```



## 함수
### 선언
자주 사용하는 기능을 Function으로 정의할 수 있습니다.   
```python
#반환값이 있는 경우
def 함수명(인자정의)
    함수 내용부
    return 반환값

#반환값이 없는 경우
def 함수명(인자정의)
    함수 내용부

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

### 파라메터 초기값 설정
```python
#빈값 입력시 기본값으로 설정 
def sum(v1, v2 = 10):
    return v1+v2

s = sum(5)
>>> 15

```

### 파라메터 이름 설정
```python
#이름으로 설정할 수 있습니다.
def info(name, age):
    print(name, age)

info(age=30, name='Hong Gil Dong')
>>> Hong Gil Dong 30

```

### 가변 길이 파라메터
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

```

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
