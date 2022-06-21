---
title: "[OpenCV] 비디오/캠 불러오기, 저장하기"
categories: 
    - python
tags: 
    [python, opencv, cv2.VideoCapture, cv2.VideoWriter_fourcc,'lecture-opencv']
toc : true
toc_sticky  : true    
---
비디오 파일 재생하기와, Cam을 통한 영상을 저장하는 것을 진행해 보겠습니다.   

# 비디오 처리

## 비디오 파일 불러오기
영상을 읽어오기 위해서는 `cv2.VideoCapture` 메소드를 사용합니다.    

```python
import cv2

video_file ='sample.avi'

cap = cv2.VideoCapture(video_file)
if cap.isOpened():
    while True:
        ret, img = cap.read()       # ret는 bool값으로 읽기가 성공일때 true를 반환
        if ret:
            cv2.imshow(video_file, img)
            if cv2.waitKey(25) != -1:   #25ms 단위로 키 입력을 대기함.
                break
        else:
            break
else:
    print('cant open video.')
cap.release()
cv2.destroyAllWindows()
```
위 소스에서 `cv2.waitKey(25)` 에서 25의 경우, 25ms을 의미하며,     
`25 = 1000 / 40` 즉, 40fps 의 값을 의미합니다.   
동영상 파일이 40fps가 많아서 해당 값을 사용합니다.   

## 캠 영상 불러오기
연결된 장치의 캠에서 영상을 불러옵니다.
```python
import cv2

cap = cv2.VideoCapture(0) #연결된 장치의 순서에 따라서 번호는 다를수 있음 0,1,2....
if cap.isOpened():
    while True:
        ret, img = cap.read()
        if ret:
            cv2.imshow('CAMERA Window', img)
            if cv2.waitKey(1) != -1:
                break
        else:
            print('프레임없음')
            break
else:
    print('카메라 열기 실패')
cap.release()
cv2.destroyAllWindows()
```

## 캠 영상 저장하기
카메라 오픈 후 개별 frame정보를 저장하는 방식으로 영상을 저장 합니다.

```python
import cv2

cap = cv2.VideoCapture(0)

if cap.isOpened():
    file_path = 'path/sample.avi'
    fps = 25.40
    fourcc = cv2.VideoWriter_fourcc(*'DIVX') 
    width = cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    height = cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    size = (int(width), int(height))
    out = cv2.VideoWriter(file_path, fourcc, fps, size)
    while True:
        ret, frame = cap.read()     #비디오에 대한 영역만 읽어옴, Sound 미포함.
        if ret:
            cv2.imshow('REC', frame)
            out.write(frame)
            if cv2.waitKey(int(1000 / fps)) != -1:
                break
        else:
            print('frame 정보 없음')
            break
    out.release()
else:
    print('카메라 열기 실패')
cap.release()
cv2.destroyAllWindows()

```
`fourcc = cv2.VideoWriter_fourcc(*'DIVX')` 부분은 저장 코덱을 선정하는 부분으로 다양한 코덱을 선정 할 수 있습니다.    
- (*'DIVX')DivxX mepg-4
- (*'FMP4')  FFMPEG
- (*'WMV2')  Window Media video8 코덱
- (*'X264')  H.264

cap 객체를 통해서 아래 추가가 값을 조회(get)/설정(set) 할수 있습니다.    
- cv2.CAP_PROP_FRAME_WIDTH : 프레임 폭
- cv2.CAP_PROP_FRAME_HEIGHT : 프레임 높이
- cv2.CAP_PROP_FPS : 초당 프레임 수
- cv2/CAP_PROP_FOURCC : 동영상 파일의 코덱문자
- cv2.CAP_PROP_POS_MSEC : 동영상 파일의 프레임 위치(ms)
- cv2.CAP_PROP_POS_AVI_RATIO : 동영상 파일의 상대 위치(0:시작, 1:끝)
- cv2.CAP_PROP_AUTOFOCUS : 카메라 자동 초점 조절
- cv2.CAP_PROP_ZOOM : 카메라 줌

```python
fps = cap.get(cv2.CAP_PROP_FPS)
delay = int(1000/fps) 
cv2.waitKey(delay)
```
## 비디오 정지 화면 저장
비디오 소스에서 정지 화면 저장하기

```python
import matplotlib.pyplot as plt
import cv2
import numpy as np

def main():
    cap = cv2.VideoCapture(0)

    if cap.isOpened():
        ret, frame = cap.read()
        print(ret)
        print(frame)
    else:
        ret = False;

    img1 = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    plt.imshow(img1)
    plt.title('Color Image RGB')
    plt.xticks([])
    plt.yticks([])
    plt.show()

    cap.release()

if __name__ == "__main__":
    main()  

```    


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-opencv' %}
{% include /custom-ref.html %}
