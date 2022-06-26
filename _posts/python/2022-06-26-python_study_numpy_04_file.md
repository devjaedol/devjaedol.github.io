---
title: "[Python][Numpy] file Input and output"
categories:  
    - python
tags: 
    [python, python강좌, 'lecture-python-basic','lecture-python-numpy', numpy ]
toc : true
toc_sticky  : true    
---

numpy를 통해서 파일에 데이터를 읽고/쓰기를 진행 합니다.   
[Input and output API 참조](https://numpy.org/doc/stable/reference/routines.io.html){:target="_blank"} 

# 텍스트 파일 (txt, csv)
## numpy.savetxt
텍스트 파일을 저장 합니다.   
`numpy.savetxt(fname, X, fmt='%.18e', delimiter=' ', newline='\n', header='', footer='', comments='# ', encoding=None)`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.savetxt.html){:target="_blank"} 

```python
t = np.random.randint(1, 10, size=(5,5))
print(t)
# [[6 5 4 1 1]
#  [9 8 3 9 8]
#  [9 7 7 4 9]
#  [6 4 9 5 7]
#  [5 7 4 9 9]]

np.savetxt("t1.csv", t)
np.savetxt("t2.csv", t, delimiter=',')
np.savetxt("t3.csv", t, delimiter=',', fmt='%.2e', header='c1,c2,c3,c4,c5')  #소수점 포멧
```

`[t1.csv File]`
```text
6.000000000000000000e+00 5.000000000000000000e+00 4.000000000000000000e+00 1.000000000000000000e+00 1.000000000000000000e+00
9.000000000000000000e+00 8.000000000000000000e+00 3.000000000000000000e+00 9.000000000000000000e+00 8.000000000000000000e+00
9.000000000000000000e+00 7.000000000000000000e+00 7.000000000000000000e+00 4.000000000000000000e+00 9.000000000000000000e+00
6.000000000000000000e+00 4.000000000000000000e+00 9.000000000000000000e+00 5.000000000000000000e+00 7.000000000000000000e+00
5.000000000000000000e+00 7.000000000000000000e+00 4.000000000000000000e+00 9.000000000000000000e+00 9.000000000000000000e+00
```

`[t2.csv File]`
```text
6.000000000000000000e+00,5.000000000000000000e+00,4.000000000000000000e+00,1.000000000000000000e+00,1.000000000000000000e+00
9.000000000000000000e+00,8.000000000000000000e+00,3.000000000000000000e+00,9.000000000000000000e+00,8.000000000000000000e+00
9.000000000000000000e+00,7.000000000000000000e+00,7.000000000000000000e+00,4.000000000000000000e+00,9.000000000000000000e+00
6.000000000000000000e+00,4.000000000000000000e+00,9.000000000000000000e+00,5.000000000000000000e+00,7.000000000000000000e+00
5.000000000000000000e+00,7.000000000000000000e+00,4.000000000000000000e+00,9.000000000000000000e+00,9.000000000000000000e+00
```

`[t3.csv File]`
```text
# c1,c2,c3,c4,c5
6.00e+00,5.00e+00,4.00e+00,1.00e+00,1.00e+00
9.00e+00,8.00e+00,3.00e+00,9.00e+00,8.00e+00
9.00e+00,7.00e+00,7.00e+00,4.00e+00,9.00e+00
6.00e+00,4.00e+00,9.00e+00,5.00e+00,7.00e+00
5.00e+00,7.00e+00,4.00e+00,9.00e+00,9.00e+00
```

## numpy.loadtxt
텍스트 파일을 조회 합니다.    
`numpy.loadtxt(fname, dtype=<class 'float'>, comments='#', delimiter=None, converters=None, skiprows=0, usecols=None, unpack=False, ndmin=0, encoding='bytes', max_rows=None, *, quotechar=None, like=None)[source]`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.loadtxt.html){:target="_blank"} 

```python
csv1 = np.loadtxt("t1.csv")
print(csv1)

csv2 = np.loadtxt("t2.csv", delimiter=',')
print(csv2)

csv3 = np.loadtxt("t3.csv", delimiter=',')
print(csv3)

# 조회 결과
# [[6. 5. 4. 1. 1.]
#  [9. 8. 3. 9. 8.]
#  [9. 7. 7. 4. 9.]
#  [6. 4. 9. 5. 7.]
#  [5. 7. 4. 9. 9.]]

```

# NumPy 이진 파일 (NPY, NPZ)
`NPY`, `NPZ` 는 NumPy의 데이터를 저장하는 Binary 형태의 데이터 입니다.    
 1개의 ndarray를, . npz 는 여러개의 ndarray를 저장하는 데 사용 됩니다.    

## numpy.save (npy)
한개의 데이터를 Binary 파일로 저장 합니다.   
`numpy.save(file, arr, allow_pickle=True, fix_imports=True)[source]`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.save.html){:target="_blank"} 

```python
t = np.random.randint(1, 10, size=(5,5))
print(t)
# [[4 1 8 3 5]
#  [2 7 2 8 6]
#  [9 9 1 8 7]
#  [8 2 4 5 1]
#  [4 9 7 1 2]]

np.save("sample", t)    # sample.npy 이 생성됨. binary 형태
```

## numpy.savez (npz)
여러 데이터를 Binary 파일로 저장 합니다.   
`numpy.savez(file, *args, **kwds)[source]`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.savez.html){:target="_blank"} 
```python

t1 = np.random.randint(1, 10, size=(5,5))
t2 = np.random.randint(1, 10, size=(5,5))
np.savez("sample2", t1, t2)  # sample2.npz 이 생성됨. binary 형태

# 데이터의 이름을 부여하고 저장하기
t1 = np.random.randint(1, 10, size=(5,5))
t2 = np.random.randint(1, 10, size=(5,5))
np.savez("sample2", c1=t1, c2=t2)    #c1, c2로 이름을 부여함

```

## numpy.load
저장된 데이터를 조회 합니다.     
`numpy.load(file, mmap_mode=None, allow_pickle=False, fix_imports=True, encoding='ASCII')`     
[API 참조](https://numpy.org/doc/stable/reference/generated/numpy.load.html){:target="_blank"} 
```python
# npy 조회
t = np.load("sample.npy")
print(t)

# npz 조회
data = np.load("sample2.npz")
print(data.files)
# ['arr_0', 'arr_1']

print(data['arr_0'])
print(data['arr_1'])

with load('sample2.npz') as data:
    t1 = data['arr_0']
    t2 = data['arr_1']

# np.savez("sample2", c1=t1, c2=t2) 와 같이 이름을 부여하면, arr_0..N  이 이름으로 조회 가능합니다. 
```

[학습 내용 참고처](https://www.youtube.com/watch?v=mirZPrWwvao){:target="_blank"} 

{% assign c-category = 'python' %}
{% assign c-tag = 'lecture-python-basic' %}
{% include /custom-ref.html %}
