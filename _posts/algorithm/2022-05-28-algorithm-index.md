---
title: "[알고리즘] 어떤 종류들이 있는지?"
categories: 
    - algorithm
tags: 
    [Bubble, Selection, Insertion, Quick, Merge, Heap, Counting,
    다익스트라, 플로이드마샬, 크루스칼, 프림, KMP, 이진트리, BFS, DFS]
toc : true
toc_sticky  : true    
---

어떤 알고리즘이 있고, 어떤 때 쓰는지를 정리해보려는 목적 입니다.    

정리하려고  알게된 몇가지 사실은 9세기 페르시아의 수학자인    
무하마드 알콰리즈미 의 이름을 라틴어화한 algorismus 에서 유래 되었답니다.       
![무함마드 이븐 무사 알콰리즈미](\assets/images_post/algorithm/algorithm_muhamad.png){: width="200px"}

위키백과의 알고리즘 정의를 보면     
수학과 컴퓨터 과학, 언어학 또는 관련 분야에서    
어떠한 문제를 해결하기 위해 정해진    
일련의 절차나 방법을 공식화한 형태로 표현한 것.

정리 시작!!! 


# 정렬 방식
- Bubble Sort.			O(N^2) 
- Selection Sort.		O(N^2) 
- Insertion Sort.		O(N^2) 
- Quick Sort.			avg O(N*logN), max O(N^2) - 이미정렬된 경우
- Merge Sort.			O(N*logN) 보장, 단점 정렬시 메모리 필요함.
- Heap Sort.			N/2*logN  (N이 클경우 logN은 값은 작은 값으로 결과적으로) > O(N)
- Counting Sort.		O(N) 특정 범위 조건

- 조건별 정리 : 위상정리 TopologySort  (임계 경로 찾기, 임계경로란 갈수있는 길의 최대 값)

# 최단경로 문제
- 다익스트라 알고리즘 (특정 시작점에서 모든 지점에 최소점을 구할때)
- 플로이드 마샬(모든 정점'에서 '모든 정점'으로의 최단 경로를 구할때)
	
# 최소 신장 트리 
정의 (Node와 Node-1의 간선으로 이루어짐)
- 프림 알고리즘 (Prim) - Heap
- 크루스칼 알고리즘(Kruskal) - UnionFind
- MST(Minimum Spanning Tree)

# 글자 검색
- KMP
- 라빈카프

# 이진 트리
- 전위 순회(Preorder Traversal)		(부) - L - R
- 중위 순회(Inorder Traversal)		L - (부) - R
- 후위 순회(Postorder Traversal)	L - R - (부)

# 그래프 검색
- DFS (Stack)
- BFS (Queue)

# 동일 부모 검색
- Union Find

# 최대 유량 문제(네트워크 선로 지연/우회 관련)
-  NetworkFlow (BSF)

# 백트래킹
- 조합, 순열 관련시

# FloodFill 기법
- 좌표중에 덩어리의 묶음을 찾는 방법 (*DFS, BSF)

# BFS 검색시
- 가중치가 동일한 경우 중복을 미허용시키고
- 가중치가 다른 경우 중복방문을 허용하여 값을 overide함

# 최소 범위 검색
- 슬라이딩 윈도우 기법 (s, e를 이동하여 최소 범위 검색)
