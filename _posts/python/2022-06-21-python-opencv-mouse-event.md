---
title: "[OpenCV] 마우스이벤트"
categories: 
    - python
tags: 
    [python, opencv, mouse, event,'mouse event','lecture-opencv' ]
toc : true
toc_sticky  : true    
---
OpenCV 마우스 이벤트에 대해서 정의 합니다.    
마우스 움직임에 대한 콜백 함수를 구현하여, 전달되는 파라메터 인자를 통해서 마우스 관련 정보를 얻을 수 있습니다.    
ex) `mouseCallbcak(event, x, y, flags, param)` 함수의
- `event` 항목의 `cv2.EVENT_XXXX` 형태로 마우스 이벤트
- `x`, `y`는 마우스의 자표
- `flags` 키보드 등의 추가 적인 정보 제공

[마우스 관련 API](https://docs.opencv.org/3.4/d0/d90/group__highgui__window__flags.html){:target="_blank"}

event 종류 
```python
  cv::EVENT_MOUSEMOVE = 0,
  cv::EVENT_LBUTTONDOWN = 1,
  cv::EVENT_RBUTTONDOWN = 2,
  cv::EVENT_MBUTTONDOWN = 3,
  cv::EVENT_LBUTTONUP = 4,
  cv::EVENT_RBUTTONUP = 5,
  cv::EVENT_MBUTTONUP = 6,
  cv::EVENT_LBUTTONDBLCLK = 7,
  cv::EVENT_RBUTTONDBLCLK = 8,
  cv::EVENT_MBUTTONDBLCLK = 9,
  cv::EVENT_MOUSEWHEEL = 10,
  cv::EVENT_MOUSEHWHEEL = 11
```

flags 종류   
```python
  cv::EVENT_FLAG_LBUTTON = 1,
  cv::EVENT_FLAG_RBUTTON = 2,
  cv::EVENT_FLAG_MBUTTON = 4,
  cv::EVENT_FLAG_CTRLKEY = 8,
  cv::EVENT_FLAG_SHIFTKEY = 16,
  cv::EVENT_FLAG_ALTKEY = 32
```

# Source Code
마우스 누르는 동작과 키보드 `shift`에 따라서 그려지는 샘플소스 입니다.

```python
import numpy
import cv2
import numpy as np

img = np.zeros((512,512,3), np.uint8)
cv2.namedWindow(windowName)

def draw_circle(event, x, y, flags, param):
    if event == cv2.EVENT_LBUTTONDOWN and flags & cv2.EVENT_FLAG_SHIFTKEY : 
        cv2.rectangle(img, (x, y), (x+20, y+20), (255, 0, 0), -1)
    if event == cv2.EVENT_LBUTTONDBLCLK:
        cv2.circle(img, (x,y), 40, (0, 255, 0), -1)
    if event == cv2.EVENT_RBUTTONDOWN:
        cv2.circle(img, (x,y), 20, (0, 0, 255), -1)
    if event == cv2.EVENT_MBUTTONDOWN:
        cv2.circle(img, (x,y), 30, (255, 0, 0), -1)

cv2.setMouseCallback(windowName, draw_circle)

def main():
    print(cv2.__version__)
    while(True):
        cv2.imshow('sample', img)
        if cv2.waitKey(20) == 27: #27키   ESC
            break

if __name__ == "__main__":
    main()  

```

OpenCV의 이벤트 확인 방법
```python
events = [i for i in dir(cv2) if 'EVENT' in i]
print(events)

#출력
['EVENT_FLAG_ALTKEY', 'EVENT_FLAG_CTRLKEY',
 'EVENT_FLAG_LBUTTON', 'EVENT_FLAG_MBUTTON', 
'EVENT_FLAG_RBUTTON', 'EVENT_FLAG_SHIFTKEY',
 'EVENT_LBUTTONDBLCLK', 'EVENT_LBUTTONDOWN', 
 'EVENT_LBUTTONUP', 'EVENT_MBUTTONDBLCLK', 
 'EVENT_MBUTTONDOWN', 'EVENT_MBUTTONUP', 
 'EVENT_MOUSEHWHEEL', 'EVENT_MOUSEMOVE', 
 'EVENT_MOUSEWHEEL', 'EVENT_RBUTTONDBLCLK', 
 'EVENT_RBUTTONDOWN', 'EVENT_RBUTTONUP']

```


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-opencv' %}
{% include /custom-ref.html %}