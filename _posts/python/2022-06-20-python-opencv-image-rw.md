---
title: "[OpenCV] 이미지 불러오기, 저장하기, 사이즈 변경"
categories: 
    - python
tags: 
    [python, opencv, cv2.imread, cv2.imwrite, cv2.COLOR_BGR2RGB]
toc : true
toc_sticky  : true    
---

OpenCV는 오픈소스컴퓨터 비전 라이브러리(Open Source Computer Vision Library)로 영상 처리와 관련된 대표적인 오픈소스라이프로리 입니다.    
- 1999년 1월 IPL(Image Process Library)를 기반 C언어로 시작함
- 2000년 알파 버전 공개
- 2005년 베타 버전 공개
- 2006년 10월 v1.0 정식 버전 공개
- 2009년 9월 v2.0 공개
- 2010년 12월 v2.2 공개
- 2011년 7월 v2.3 공개(안드로이드 지원, cv-> cv2변경)
- 2015년 6월 v3.0 공개
- 2019년 1월 v4.0 공개

[opencv.org 홈페이지](http://www.opencv.org){:target="_blank"}

# 설치
## Python 설치
[Python 설치](/python/python_study_01/){:target="_blank"}

## OpenCV 설치
`pip install opencv-python` 명령어를 통해서 설치 진행.    

```python
pip install opencv-python
Collecting opencv-python
  Downloading opencv_python-4.6.0.66-cp36-abi3-win_amd64.whl (35.6 MB)
     |████████████████████████████████| 35.6 MB 43 kB/s
Requirement already satisfied: numpy>=1.14.5; python_version >= "3.7" in 

#numpy, pandas matplotlib도 함께 설치를 권장
pip install numpy pandas matplotlib
```

# 이미지 처리
OpenCV 공부하다보면 나오는 `레나` 이미지.    
레나(Lenna 또는 Lena)는 플레이보이 잡지 1972년 11월자의 센터폴드에 
실린 스웨덴의 모델인 레나 포르센(1951년 3월 31일 - )의 사진의 일부분을 말한다. - 위키백과     

## 이미지 불러오기
이미지를 읽어오기 위해서는 `cv2.imread` 메소드를 사용합니다.    

```python
import cv2

img_file = 'path/lena.jpg'
img = cv2.imread(img_file)
# img = cv2.imread(img_file, cv2.IMREAD_GRAYSCALE)  #cv2.IMREAD_GRAYSCALE을 통해서 Gray모드로 읽기 가능

print(img)              #이미지 배열 출력
print(type(img))        #<class 'numpy.ndarray'>
print(img.shape)        #(512, 512, 3)  resolution  512x512 3ch(R,G,B)
print(img.ndim)         # 3 ch      (gray인 경우 2ch로 출력됨)
print(img.size)         # 786432    = 512x512x3

if img is not None:
    cv2.imshow('IMG', img)
    cv2.waitKey()
    cv2.destoryAllWindow()
else:
    print('No Image')

```

`cv2.imread(file_name[, mode_flag])` 로 이미지를 로드할때 두번째 인자로 옵션을 줄수 있습니다.   
`mode_flag`에 올수 있는 옵션 종류
- cv2.IMREAD_COLOR : 컬러(BGR) 로 읽기, 기본값
- cv2.IMREAD_UNCHANGE : 파일 그대로 읽기
- cv2.IMREAD_GRAYSCALE : 흑백으로 읽기 
    
`cv2.imshow(title, img)`  이미지에 title의 윈도우를 표시합니다.    
`cv2.waitKey([delay])` 는 키보드의 입력을 대기합니다.
- delay의 기본값은 0으로 무한대로 대기 합니다.
- 값의 입력 단위는 ms  입니다.
`v = cv2.waitKey([delay])` 반환값은 키 코드 또는 아무 값도 입력되지 않은 경우 `-1`을 반환 합니다.

```python
import numpy
import cv2

def main():
    print(cv2.__version__)

    imgpath ="path\lena_color_512.tif"
    img = cv2.imread(imgpath)

    cv2.namedWindow('Lena', cv2.WINDOW_AUTOSIZE)    #창에 이름을 할당
    cv2.imshow('Lena', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows('Lena')      #창 이름으로 닫기

if __name__ == "__main__":
    main()
```

## 웹 이미지 불러오기
`req.urlretrieve` 를 통해서 이미지를 웹에서 읽어옵니다. 
웹에 이미지를  test.png로 저장후 로드하는 예제 입니다.    
```python
import cv2
import urllib.request as req

url = 'http://xxxxx.png'
req.urlretrieve(url, 'path/test.png')
img = cv2.imread('path/test.png')

if img is not None:
    cv2.imshow('IMG', img)
    cv2.waitKey()
    cv2.destoryAllWindow()
else:
    print('not found Image')
```

## 이미지 저장하기
이미지를 새로 저장하는 방법
```python
img_file = 'path/lena.jpg'
new_file = 'path/lena_gray.jpg'

img = cv2.imread(img_file, cv2.IMREAD_GRAYSCALE)
cv2.imshow(img_file, img)
cv2.imwrite(new_file, img)
cv2.waitKey()
cv2.destroyAllWindows()
```

## 이미지 사이즈 변경 하기
`cv2.resize` 를 통해서 이미지의 사이즈를 변경 할수 있읍니다.    
```python
import cv2

originImg = cv2.imread('origin.jpg')
newImg = cv2.resize(originImg, (600, 300))

cv2.imwrite('path/resize.jpg', newImg)
cv2.imshow('IMG', newImg)
cv2.waitKey()
cv2.destroyAllWindows()
```

## 이미지 특정 영역 크롭하기
`cv2.imread`의 반환값은 `<class 'numpy.ndarray'>`로 배열 자체를 슬라이싱하여 크롭을 구현할 수 있습니다.    
OpenCV는 `RGB` 체계의 값을 사용하지 않고 `BGR` 값 체계를 사용하여, `RGB` 정상적인 사용을 위해서 변환을 처리해야 합니다.
`cv2.COLOR_BGR2RGB`를 통해서 변환을 진행 합니다.

```python
import matplotlib.pyplot as plt
import cv2

img = cv2.imread('sample.jpg')
im2 = img[100:300, 100:500]     #이미지를 Crop영역을 선택합니다.
im2 = cv2.resize(im2, (400, 400))
cv2.imwrite('resize.png', im2)
plt.imshow(cv2.cvtColor(im2, cv2.COLOR_BGR2RGB))
plt.show()
```




