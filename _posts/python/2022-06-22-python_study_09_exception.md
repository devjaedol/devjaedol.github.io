---
title: "[Python Basic] 예외처리"
categories:  
    - python
tags: 
    [python, python강좌, 초급, 'lecture-python-basic', 예외처리 ]
toc : true
toc_sticky  : true    
---
Python에서 예외 처리 방법에 대해서 알아 봅시다.     

# try ~ except
## 형태
```python
try:
    # 실행 로직
    # 실행 로직
except:                     
    # 에러 발생시 진행 로직
else:
    # 예외가 발생하지 않을떄 실행하는 영역
finally:
    # 최종 실행이 보장되는 영역
```
`except:` 은 `except 예외클래스 as 변수:` 형태로 예외 객체 별로 분리 할 수 있습니다.


## Sample Code
```python
try:
    f = open('f.txt', "w")
    f.test() #없는 함수 호출
except FileExistsError as e:
    pass        # pass 아무 일도 하지 않음 처리
except IOError as e:    
    print(type(e))
    print(e)
except Exception as e:
    print(type(e))
    print(e)
else:
    print("정상 실행")
finally:
    f.close()
```

# raise 예외 발생
임의로 예외를 발생 시킬 수 있습니다.    
`raise 예외 객체` 형태로 발생시킵니다.   
```python
try:
    # 실행 로직
    raise Exception('사용자 Error')
    # 실행 로직
except:                     
    # 에러 발생시 진행 로직
else:
    # 예외가 발생하지 않을떄 실행하는 영역
finally:
    # 최종 실행이 보장되는 영역
```

# 사용자 정의 예외 클래스
```python
class CustomException(Exception):
    def __init__(self, code, msg):
        Exception.__init__(self)
        self.code = code
        self.msg = msg
    
    def __str__(self):
        return str(self.code)+self.msg

raise CustomException(500,'InternalError')
```

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
