---
title: "[OpenCV] 윈도우 처리, 키이벤트"
categories: 
    - python
tags: 
    [python, opencv, WINDOW_AUTOSIZE, WINDOW_NORMAL, waitKey, 'key event','lecture-opencv' ]
toc : true
toc_sticky  : true    
---
OpenCV 기본적인 window 관련 자주 쓰이는 함수들을 정리 합니다.

# 윈도우 관리
## cv2.namedWindow('이름' [, opt])
윈도의 이름을 설정합니다.   
 opt 옵션 값
- cv2.WINDOW_NORMAL : 사용자 창 크기 조절 가능
- cv2.WINDOW_AUTOSIZE : 이미지와 같은 크기, 창 크기 재조정 불 가능

## cv2.moveWindow('이름', x , y)
x, y의 좌표로 이름에 해당하는 창이 이동합니다.

## cv2.destoryWindow('이름')
특정 이름의 윈도으를 닫습니다.

## cv2.destoryAllWindows()
모든 윈도의 창을 닫습니다.

# 이벤트 관리
`waitKey`를 통해서 키 이벤트를 처리 할 수 있습니다.
`if cv2.waitKey(0) == ord('k')` 키보드 `k` 를 찾을 수 있습니다. `ord` 함수를 통해서 ascii 변환 처리를 진행함.    
64bit 일부 환경에서 ascii 변환시 오류 방지를 위해서 8bit 마스크를 진행함.    
`if (cv2.waitKey(0) & 0xFF) == ord('k')`    

```python
k = cv2.waitKey(0) & 0xFF
print(k)
print(char(k))
x = 0
y = 0

if k == ord('d')
    x =+ 100
elif k == ord('w')
    y =+ 100
elif k == ord('x')
    y =- 100
elif k == ord('a')
    x =- 100
cv2.moveWindow('win',x ,y)
```

`상하좌우` 키보드를 통해서 하려면...    
키값을 16진수로 입력 받아야 됩니다.    
```python
# key = cv2.waitKey(0) & 0xFF
key = cv2.waitKeyEx() # 16진수 키캆

if key == ord('j') or key == 0x250000:
    x -= 10
elif key == ord('l') or key == 0x270000:
    x += 10
elif key == ord('o') or key == 0x260000:
    y -= 10
elif key == ord('k') or key == 0x280000:
    y += 10
elif key == ord('q') or key == 27:
    break
```


{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-opencv' %}
{% include /custom-ref.html %}