---
title: "[Python Basic] Class"
categories: 
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', class ]
toc : true
toc_sticky  : true    
---
객체 지향 프로그램에서 사용하는 클래스를 학습해 보겠습니다.    

# Class
## 형태
`class 클래스이름`으로 클래스를 생성 할 수 있습니다.   
```python
class 클래스이름:
    클래스 내용        

#내용이 빈 클래스를 만들 경우.
class 클래스이름:
    pass        
```



## 사용법
인스턴스 형태로 생성하여 사용 합니다.   
```python
변수  = 클래스이름();
```



## 생성자, 소멸자, 사용자 함수
생성자의 첫번째 매개 변수는 `self` 를 꼭 포함해야 한다.    
클래스 내부에 `__xxx__` 로 구성된 메소드는 특수 기능으로 존재하는 메소드 입니다.
`__str__`, `__eq__`,`__dir__` 등등    
```python
class 클래스이름:
    def __init__(self, sample, 사용자 정의 매개변수):
        self.sample = sample
        pass

    def 사용자함수명(self, 사용자 정의 매개변수):
        pass

    def __del__(self):
        print('객체가 소멸됩니다.')

```


## 생성 예 및 소속 확인방법
`isinstance(인스턴스, 클래스)` 를 사용해서 소속을 확인 할 수 있습니다.   
`type(인스턴스) == 클래스` 로도 확인 할 수 있습니다.
```python

class Car:
    def __init__(self):
        pass

truck = Car()  #객체 생성

print( isinstance(truck, Car)) # True
print( type(truck) == Car) # True
```




## Sample Code
```python
class Car:
    def __init__(self, name):
        self.name = name
    def setDoor(self, door):
        self.door = door
    def getDoor(self):
        return self.door
    def getFeatures(self):
        pass

c = Car('NewCar')
c.setDoor(4)
print(c.getDoor()) # 4
```

# 상속
부모 클래스를 상속 합니다.
```python
class Bus (Car):
    def getFeatures(self):
        print("this is a bus:", self.name)
 
class Truck (Car):
    def getFeatures(self):
        print("this is a Truck:", self.name)

b = Bus('시내버스') 
t = Truck('화물트럭')

list = [b, t]
for i in list:
    i.getFeatures()

#출력
this is a bus: 시내버스
this is a Truck: 화물트럭

```


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
