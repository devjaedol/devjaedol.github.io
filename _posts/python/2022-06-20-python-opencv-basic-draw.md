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

# Color 색상
cv2에서 제공하는 색상 관련 상수을 출력 합니다.
```python
import matplotlib.pyplot as plt
import cv2
import numpy as np

def main():
    j = 0
    for filename in dir(cv2):
        if filename.startswith('COLOR_'):
            print(filename)
            j = j + 1
    print('count: '+str((j+1)))

if __name__ == "__main__":
    main()  

# 출력 
COLOR_BAYER_BG2BGR
COLOR_BAYER_BG2BGRA
COLOR_BAYER_BG2BGR_EA
COLOR_BAYER_BG2BGR_VNG
COLOR_BAYER_BG2GRAY
COLOR_BAYER_BG2RGB
COLOR_BAYER_BG2RGBA
COLOR_BAYER_BG2RGB_EA
COLOR_BAYER_BG2RGB_VNG
COLOR_BAYER_BGGR2BGR
COLOR_BAYER_BGGR2BGRA
COLOR_BAYER_BGGR2BGR_EA
COLOR_BAYER_BGGR2BGR_VNG
COLOR_BAYER_BGGR2GRAY
COLOR_BAYER_BGGR2RGB
COLOR_BAYER_BGGR2RGBA
COLOR_BAYER_BGGR2RGB_EA
COLOR_BAYER_BGGR2RGB_VNG
COLOR_BAYER_GB2BGR
COLOR_BAYER_GB2BGRA
COLOR_BAYER_GB2BGR_EA
COLOR_BAYER_GB2BGR_VNG
COLOR_BAYER_GB2GRAY
COLOR_BAYER_GB2RGB
COLOR_BAYER_GB2RGBA
COLOR_BAYER_GB2RGB_EA
COLOR_BAYER_GB2RGB_VNG
COLOR_BAYER_GBRG2BGR
COLOR_BAYER_GBRG2BGRA
COLOR_BAYER_GBRG2BGR_EA
COLOR_BAYER_GBRG2BGR_VNG
COLOR_BAYER_GBRG2GRAY
COLOR_BAYER_GBRG2RGB
COLOR_BAYER_GBRG2RGBA
COLOR_BAYER_GBRG2RGB_EA
COLOR_BAYER_GBRG2RGB_VNG
COLOR_BAYER_GR2BGR
COLOR_BAYER_GR2BGRA
COLOR_BAYER_GR2BGR_EA
COLOR_BAYER_GR2BGR_VNG
COLOR_BAYER_GR2GRAY
COLOR_BAYER_GR2RGB
COLOR_BAYER_GR2RGBA
COLOR_BAYER_GR2RGB_EA
COLOR_BAYER_GR2RGB_VNG
COLOR_BAYER_GRBG2BGR
COLOR_BAYER_GRBG2BGRA
COLOR_BAYER_GRBG2BGR_EA
COLOR_BAYER_GRBG2BGR_VNG
COLOR_BAYER_GRBG2GRAY
COLOR_BAYER_GRBG2RGB
COLOR_BAYER_GRBG2RGBA
COLOR_BAYER_GRBG2RGB_EA
COLOR_BAYER_GRBG2RGB_VNG
COLOR_BAYER_RG2BGR
COLOR_BAYER_RG2BGRA
COLOR_BAYER_RG2BGR_EA
COLOR_BAYER_RG2BGR_VNG
COLOR_BAYER_RG2GRAY
COLOR_BAYER_RG2RGB
COLOR_BAYER_RG2RGBA
COLOR_BAYER_RG2RGB_EA
COLOR_BAYER_RG2RGB_VNG
COLOR_BAYER_RGGB2BGR
COLOR_BAYER_RGGB2BGRA
COLOR_BAYER_RGGB2BGR_EA
COLOR_BAYER_RGGB2BGR_VNG
COLOR_BAYER_RGGB2GRAY
COLOR_BAYER_RGGB2RGB
COLOR_BAYER_RGGB2RGBA
COLOR_BAYER_RGGB2RGB_EA
COLOR_BAYER_RGGB2RGB_VNG
COLOR_BGR2BGR555
COLOR_BGR2BGR565
COLOR_BGR2BGRA
COLOR_BGR2GRAY
COLOR_BGR2HLS
COLOR_BGR2HLS_FULL
COLOR_BGR2HSV
COLOR_BGR2HSV_FULL
COLOR_BGR2LAB
COLOR_BGR2LUV
COLOR_BGR2Lab
COLOR_BGR2Luv
COLOR_BGR2RGB
COLOR_BGR2RGBA
COLOR_BGR2XYZ
COLOR_BGR2YCR_CB
COLOR_BGR2YCrCb
COLOR_BGR2YUV
COLOR_BGR2YUV_I420
COLOR_BGR2YUV_IYUV
COLOR_BGR2YUV_YV12
COLOR_BGR5552BGR
COLOR_BGR5552BGRA
COLOR_BGR5552GRAY
COLOR_BGR5552RGB
COLOR_BGR5552RGBA
COLOR_BGR5652BGR
COLOR_BGR5652BGRA
COLOR_BGR5652GRAY
COLOR_BGR5652RGB
COLOR_BGR5652RGBA
COLOR_BGRA2BGR
COLOR_BGRA2BGR555
COLOR_BGRA2BGR565
COLOR_BGRA2GRAY
COLOR_BGRA2RGB
COLOR_BGRA2RGBA
COLOR_BGRA2YUV_I420
COLOR_BGRA2YUV_IYUV
COLOR_BGRA2YUV_YV12
COLOR_BayerBG2BGR
COLOR_BayerBG2BGRA
COLOR_BayerBG2BGR_EA
COLOR_BayerBG2BGR_VNG
COLOR_BayerBG2GRAY
COLOR_BayerBG2RGB
COLOR_BayerBG2RGBA
COLOR_BayerBG2RGB_EA
COLOR_BayerBG2RGB_VNG
COLOR_BayerBGGR2BGR
COLOR_BayerBGGR2BGRA
COLOR_BayerBGGR2BGR_EA
COLOR_BayerBGGR2BGR_VNG
COLOR_BayerBGGR2GRAY
COLOR_BayerBGGR2RGB
COLOR_BayerBGGR2RGBA
COLOR_BayerBGGR2RGB_EA
COLOR_BayerBGGR2RGB_VNG
COLOR_BayerGB2BGR
COLOR_BayerGB2BGRA
COLOR_BayerGB2BGR_EA
COLOR_BayerGB2BGR_VNG
COLOR_BayerGB2GRAY
COLOR_BayerGB2RGB
COLOR_BayerGB2RGBA
COLOR_BayerGB2RGB_EA
COLOR_BayerGB2RGB_VNG
COLOR_BayerGBRG2BGR
COLOR_BayerGBRG2BGRA
COLOR_BayerGBRG2BGR_EA
COLOR_BayerGBRG2BGR_VNG
COLOR_BayerGBRG2GRAY
COLOR_BayerGBRG2RGB
COLOR_BayerGBRG2RGBA
COLOR_BayerGBRG2RGB_EA
COLOR_BayerGBRG2RGB_VNG
COLOR_BayerGR2BGR
COLOR_BayerGR2BGRA
COLOR_BayerGR2BGR_EA
COLOR_BayerGR2BGR_VNG
COLOR_BayerGR2GRAY
COLOR_BayerGR2RGB
COLOR_BayerGR2RGBA
COLOR_BayerGR2RGB_EA
COLOR_BayerGR2RGB_VNG
COLOR_BayerGRBG2BGR
COLOR_BayerGRBG2BGRA
COLOR_BayerGRBG2BGR_EA
COLOR_BayerGRBG2BGR_VNG
COLOR_BayerGRBG2GRAY
COLOR_BayerGRBG2RGB
COLOR_BayerGRBG2RGBA
COLOR_BayerGRBG2RGB_EA
COLOR_BayerGRBG2RGB_VNG
COLOR_BayerRG2BGR
COLOR_BayerRG2BGRA
COLOR_BayerRG2BGR_EA
COLOR_BayerRG2BGR_VNG
COLOR_BayerRG2GRAY
COLOR_BayerRG2RGB
COLOR_BayerRG2RGBA
COLOR_BayerRG2RGB_EA
COLOR_BayerRG2RGB_VNG
COLOR_BayerRGGB2BGR
COLOR_BayerRGGB2BGRA
COLOR_BayerRGGB2BGR_EA
COLOR_BayerRGGB2BGR_VNG
COLOR_BayerRGGB2GRAY
COLOR_BayerRGGB2RGB
COLOR_BayerRGGB2RGBA
COLOR_BayerRGGB2RGB_EA
COLOR_BayerRGGB2RGB_VNG
COLOR_COLORCVT_MAX
COLOR_GRAY2BGR
COLOR_GRAY2BGR555
COLOR_GRAY2BGR565
COLOR_GRAY2BGRA
COLOR_GRAY2RGB
COLOR_GRAY2RGBA
COLOR_HLS2BGR
COLOR_HLS2BGR_FULL
COLOR_HLS2RGB
COLOR_HLS2RGB_FULL
COLOR_HSV2BGR
COLOR_HSV2BGR_FULL
COLOR_HSV2RGB
COLOR_HSV2RGB_FULL
COLOR_LAB2BGR
COLOR_LAB2LBGR
COLOR_LAB2LRGB
COLOR_LAB2RGB
COLOR_LBGR2LAB
COLOR_LBGR2LUV
COLOR_LBGR2Lab
COLOR_LBGR2Luv
COLOR_LRGB2LAB
COLOR_LRGB2LUV
COLOR_LRGB2Lab
COLOR_LRGB2Luv
COLOR_LUV2BGR
COLOR_LUV2LBGR
COLOR_LUV2LRGB
COLOR_LUV2RGB
COLOR_Lab2BGR
COLOR_Lab2LBGR
COLOR_Lab2LRGB
COLOR_Lab2RGB
COLOR_Luv2BGR
COLOR_Luv2LBGR
COLOR_Luv2LRGB
COLOR_Luv2RGB
COLOR_M_RGBA2RGBA
COLOR_RGB2BGR
COLOR_RGB2BGR555
COLOR_RGB2BGR565
COLOR_RGB2BGRA
COLOR_RGB2GRAY
COLOR_RGB2HLS
COLOR_RGB2HLS_FULL
COLOR_RGB2HSV
COLOR_RGB2HSV_FULL
COLOR_RGB2LAB
COLOR_RGB2LUV
COLOR_RGB2Lab
COLOR_RGB2Luv
COLOR_RGB2RGBA
COLOR_RGB2XYZ
COLOR_RGB2YCR_CB
COLOR_RGB2YCrCb
COLOR_RGB2YUV
COLOR_RGB2YUV_I420
COLOR_RGB2YUV_IYUV
COLOR_RGB2YUV_YV12
COLOR_RGBA2BGR
COLOR_RGBA2BGR555
COLOR_RGBA2BGR565
COLOR_RGBA2BGRA
COLOR_RGBA2GRAY
COLOR_RGBA2M_RGBA
COLOR_RGBA2RGB
COLOR_RGBA2YUV_I420
COLOR_RGBA2YUV_IYUV
COLOR_RGBA2YUV_YV12
COLOR_RGBA2mRGBA
COLOR_XYZ2BGR
COLOR_XYZ2RGB
COLOR_YCR_CB2BGR
COLOR_YCR_CB2RGB
COLOR_YCrCb2BGR
COLOR_YCrCb2RGB
COLOR_YUV2BGR
COLOR_YUV2BGRA_I420
COLOR_YUV2BGRA_IYUV
COLOR_YUV2BGRA_NV12
COLOR_YUV2BGRA_NV21
COLOR_YUV2BGRA_UYNV
COLOR_YUV2BGRA_UYVY
COLOR_YUV2BGRA_Y422
COLOR_YUV2BGRA_YUNV
COLOR_YUV2BGRA_YUY2
COLOR_YUV2BGRA_YUYV
COLOR_YUV2BGRA_YV12
COLOR_YUV2BGRA_YVYU
COLOR_YUV2BGR_I420
COLOR_YUV2BGR_IYUV
COLOR_YUV2BGR_NV12
COLOR_YUV2BGR_NV21
COLOR_YUV2BGR_UYNV
COLOR_YUV2BGR_UYVY
COLOR_YUV2BGR_Y422
COLOR_YUV2BGR_YUNV
COLOR_YUV2BGR_YUY2
COLOR_YUV2BGR_YUYV
COLOR_YUV2BGR_YV12
COLOR_YUV2BGR_YVYU
COLOR_YUV2GRAY_420
COLOR_YUV2GRAY_I420
COLOR_YUV2GRAY_IYUV
COLOR_YUV2GRAY_NV12
COLOR_YUV2GRAY_NV21
COLOR_YUV2GRAY_UYNV
COLOR_YUV2GRAY_UYVY
COLOR_YUV2GRAY_Y422
COLOR_YUV2GRAY_YUNV
COLOR_YUV2GRAY_YUY2
COLOR_YUV2GRAY_YUYV
COLOR_YUV2GRAY_YV12
COLOR_YUV2GRAY_YVYU
COLOR_YUV2RGB
COLOR_YUV2RGBA_I420
COLOR_YUV2RGBA_IYUV
COLOR_YUV2RGBA_NV12
COLOR_YUV2RGBA_NV21
COLOR_YUV2RGBA_UYNV
COLOR_YUV2RGBA_UYVY
COLOR_YUV2RGBA_Y422
COLOR_YUV2RGBA_YUNV
COLOR_YUV2RGBA_YUY2
COLOR_YUV2RGBA_YUYV
COLOR_YUV2RGBA_YV12
COLOR_YUV2RGBA_YVYU
COLOR_YUV2RGB_I420
COLOR_YUV2RGB_IYUV
COLOR_YUV2RGB_NV12
COLOR_YUV2RGB_NV21
COLOR_YUV2RGB_UYNV
COLOR_YUV2RGB_UYVY
COLOR_YUV2RGB_Y422
COLOR_YUV2RGB_YUNV
COLOR_YUV2RGB_YUY2
COLOR_YUV2RGB_YUYV
COLOR_YUV2RGB_YV12
COLOR_YUV2RGB_YVYU
COLOR_YUV420P2BGR
COLOR_YUV420P2BGRA
COLOR_YUV420P2GRAY
COLOR_YUV420P2RGB
COLOR_YUV420P2RGBA
COLOR_YUV420SP2BGRA
COLOR_YUV420SP2GRAY
COLOR_YUV420SP2RGB
COLOR_YUV420SP2RGBA
COLOR_YUV420p2BGR
COLOR_YUV420p2BGRA
COLOR_YUV420p2GRAY
COLOR_YUV420p2RGB
COLOR_YUV420p2RGBA
COLOR_YUV420sp2BGR
COLOR_YUV420sp2BGRA
COLOR_YUV420sp2GRAY
COLOR_YUV420sp2RGB
COLOR_YUV420sp2RGBA
COLOR_mRGBA2RGBA
count : 347
```



{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-opencv' %}
{% include /custom-ref.html %}