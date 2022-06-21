---
title: "[OpenCV] 기본 도형 그리기"
categories: 
    - python
tags: 
    [python, opencv, cv2.putText, cv2.line, cv2.rectangle, cv2.polylines, cv2.circle ,'lecture-opencv']
toc : true
toc_sticky  : true    
---

영상 또는 이미지 데이터 위에 Text, 선, 사각형, 다각형 등을 그리기.    
하기 표시되는 color는 `BGR` 입니다. 참고 바랍니다.   

# 도형 그리기
## Text 그리기(cv2.putText)
`cv2.putText(img, text, position, fontFace, fontSize, color [,thickness, linetype])`
- position 입력될 글자의 좌측 하단 기준의 배치 위치 입니다.
- fontFace   
    - cv2.FONT_HERSHEY_PLAIN   
    - cv2.FONT_HERSHEY_SIMPLEX
    - cv2.FONT_HERSHEY_DUPLEX
    - cv2.FONT_HERSHEY_COMPLEX_SMALL
    - cv2.FONT_HERSHEY_COMPLEX
    - cv2.FONT_HERSHEY_TRIPLEX
    - cv2.FONT_ITALIC

```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)
cv2.putText(img, 'Plain', (100, 50), cv2.FONT_HERSHEY_PLAIN, 1, (0,0,0))
cv2.putText(img, 'Simplex', (100, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,0))
cv2.putText(img, 'Duplex', (100, 150), cv2.FONT_HERSHEY_DUPLEX, 1, (0,0,0))
cv2.putText(img, 'Duplex', (100, 200), cv2.FONT_HERSHEY_PLAIN | cv2.FONT_ITALIC, 2, (0,255,255))
cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


## 선 그리기(cv2.line)
`cv2.line(img, start, end, color [,thickness, linetype])`
- start/end 위치(x, y)
- linetype
    - cv2.LINE_4 
    - cv2.LINE_8
    - cv2.LINE_AA : 안티알라아싱

```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)
cv2.line(img, (200, 50), (300,50), (0, 255, 0))
cv2.line(img, (100, 150), (400,150), (255, 255, 0), 10)
cv2.line(img, (100, 350), (400,400), (0,0,255), 10, cv2.LINE_AA)
cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


## 사각형그리기(cv2.rectangle)
`cv2.rectangle(img, start, end, color [,thickness, linetype])`
- thickness `-1` 인 경우 채우기 상태    

```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)
cv2.rectangle(img, (100, 100), (200,500), (255,0,0), 10)
cv2.rectangle(img, (200, 200), (200,400), (0,0,255), -1)    #-1은 채워짐
cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


## 다각형그리기(cv2.polylines)
`cv2.polylines(img, points, isClosed, color [,thickness, linetype])`
```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)

p1 = np.array([[10,15], [30,25], [100, 150], [200,300], [150,400]], dtype=np.int32)
p2 = np.array([[30,60], [210,170], [140, 220]], dtype=np.int32)
cv2.polylines(img, [p1], False, (255, 0, 0))
cv2.polylines(img, [p2], True, (0, 0, 0), 10)

cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


## 원, 타원 그리기(cv2.circle)
`cv2.circle(img, center, radius, color [,thickness, linetype])`
- center 원 또는 타원의 중심 좌표(x, y)
- radius 원의 반지름    

```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)
cv2.circle(img, (150,150), 100, (255, 0, 0))
cv2.circle(img, (400,150), 50, (0, 0, 255), -1)
cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


## 호그리기(cv2.ellipse)
`cv2.ellipse(img, center, axes, angle, from, to, color [,thickness, linetype])`
- center 중심 좌표(x, y)
- axes 기준축 길이
- angle 기준축 회전 각도
- from 호의 시작 각도
- to 호의 종료 각도    

```python
import cv2
import numpy as np
img = np.full((500,500,3), 255, dtype=np.uint8)
cv2.ellipse(img, (50, 300), (50,75), 0, 0, 360, (0, 0,255))
cv2.ellipse(img, (250, 300), (50, 50), 0, 30, 180, (0, 255, 0)) #30도 부터 180도까지 호를 그림
cv2.imshow('SAMPLE', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

## Sample Code
```python
import numpy
import cv2
import numpy as np

def main():
    print(cv2.__version__)

    img = np.zeros((512,512,3), np.uint8)

    print(img)

    cv2.line(img, (0,99), (99,0), (255,0,0), 2)     
    cv2.rectangle(img, (40,60), (200,170), (0,255,0),1) 
    cv2.circle(img, (150,180), 50 , (0,0,255),-1) # 두께를 -1로 주면 원의 색이 모두 채워짐
    cv2.ellipse(img, (160,260),(50,20),0,0,360, (127,127,127),-1)
    cv2.ellipse(img, (260,360),(70,40),0,0,180, (127,127,255),-1)  #회전

    points = np.array([[80,10],[125,75],[179,10],[230,160],[80,90]], np.int32)
    points = points.reshape((-1, 1, 2))
    cv2.polylines(img, [points], True,(0,255,255))

    text1 ='Test Text'
    cv2.putText(img, text1, (200,300), cv2.FONT_HERSHEY_SIMPLEX, 2, (255,255,0))

    cv2.imshow('Lena', img)    
    cv2.waitKey(0)
    cv2.destroyAllWindows('Lena')

if __name__ == "__main__":
    main()  
```


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-opencv' %}
{% include /custom-ref.html %}