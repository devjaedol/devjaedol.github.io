---
title: "[Java Class] PriorityQueue" 
categories: 
    - java
tags: 
    - PriorityQueue
    - queue
    - FIFO
    - 우선순위큐
    - 자료구조
toc : true
toc_sticky  : true        
---

큐에서 특정 우선순위를 적용하여, 먼저 출력하도록 하는 클래스 입니다.    
정렬 등의 조건에서 사용이 가능합니다.    


## 일반적인 Queue
- FIFO(Fisrt Input Firs Out) 먼저 들어간 데이터가 먼저 나오는 구조이다.
- BFS 사용


## 일반 Queue Source Code
```java
package datatype;
import java.util.ArrayList;
import java.util.LinkedList;

public class QueueTest {

	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		// add() 자료 입력
		// remove() 출력
		// peek() 출력할 첫번째 데이터 읽기(제거는 아님)
		
		//Queue<String> queue = new LinkedList<String>();
		LinkedList<String> queue = new LinkedList<String>();

		// 큐 는 FIFO 방식 처음에 들어간 값이 가장 먼저 나온다.
		queue.offer("토끼"); // 인덱스 번호 0 // offer 이나 add나 똑같다.
		queue.offer("개"); // 인덱스 번호 1 // offer 대신 add를 써도 된다.
		queue.offer("늑대"); // 인덱스 번호 2 // offer을 쓰는 이유는 큐를 이해하기 위해서

		System.out.println("**String[]********************************");
		String[] arr = queue.toArray(new String[0]);
		for (int i = 0; i < arr.length; i++) {
			System.out.println(arr[i]); // 처음 값을 지우지않고 리턴한다.
		}
		System.out.println("**********************************");
		
		
		for (int i = 0; i < queue.size(); i++) {
			System.out.println(queue.peek() + "	:	" + (String) queue.get(i)); // 처음 값을 지우지않고 리턴한다.
			// 그러기 때문에 계속 토끼만 리턴된다.
		}

		System.out.println("**********************************");

		while (!queue.isEmpty()) // isEmpty()는 LinkedList 객체 안에 데이터가 없으면 True
									// 하나라도 있다면 False 값을 리턴하는 메소드
		{
			//String str = queue.poll(); // poll() 은 처음 값을 지우면서 리턴한다.
			String str = queue.pop(); // pop() 은 처음 값을 지우면서 리턴한다.
			System.out.println(str);
		}
		System.out.println("queue.size() : "+queue.size());

	}
}

//출력
**String[]********************************
토끼
개
늑대
**********************************
토끼	:	토끼
토끼	:	개
토끼	:	늑대
**********************************
토끼
개
늑대
queue.size() : 0

```


## 우선순위 Queue Source Code
```java
package datatype;

import java.util.PriorityQueue;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

public class PriorityQueueTest {
	
	public static void main(String[] args) {
		//낮은 숫자가 우선 순위인 int 형 우선순위 큐 선언
		PriorityQueue<Integer> pqLowest = new PriorityQueue<>();

		//높은 숫자가 우선 순위인 int 형 우선순위 큐 선언
		PriorityQueue<Integer> pqHighest = new PriorityQueue<>(Collections.reverseOrder());
		
		// add(value) 메서드의 경우 만약 삽입에 성공하면 true를 반환, 
		// 큐에 여유 공간이 없어 삽입에 실패하면 IllegalStateException을 발생
		pqLowest.add(1);
		pqLowest.add(10);
		pqLowest.offer(100);

		pqHighest.add(1);
		pqHighest.add(10);
		pqHighest.offer(100);
		
		System.out.println("==[pqLowest]===============");
		while(!pqLowest.isEmpty()) {
			System.out.println(pqLowest.poll());
		}
		System.out.println("==[pqHighest]===============");
		while(!pqHighest.isEmpty()) {
			System.out.println(pqHighest.poll());
		}
		
		System.out.println("==[Custome]===============");
		PriorityQueue<Node> pqCustom = new PriorityQueue<>();
		pqCustom.add(new Node(1, 100));
		pqCustom.add(new Node(100, 200));
		pqCustom.add(new Node(70, 300));
		pqCustom.add(new Node(30, 400));
		
		while(!pqCustom.isEmpty()) {
			System.out.println(pqCustom.poll().toString());
		}
		
		System.out.println("==[]===============");
		

		// 간단한 람다 방식으로 사용하려면 
		//높은 숫자가 우선 순위인 int 형 우선순위 큐 선언
		//PriorityQueue<int[]> pq = new PriorityQueue<>( (a, b) -> a[0] - b[0] );
		PriorityQueue<int[]> pq = new PriorityQueue<>( (a, b) ->{
			//System.out.format(" %d - %d = %d \n", a[1], b[1], a[1] - b[1]);
			return (a[1] - b[1]);
			//return (a[1] - b[1])* -1 ;
			} );
		
		pq.add(new int[] {1, 1});
		pq.add(new int[] {0, 7});
		pq.add(new int[] {0, 3});
		pq.add(new int[] {0, 1});

		while(!pq.isEmpty()) {
			int[] t = pq.poll();
			System.out.format("%5d %5d \n", t[0], t[1]);
		}
		
		
		PriorityQueue<Integer> q_asc = new PriorityQueue<Integer>();
		PriorityQueue<Integer> q_desc = new PriorityQueue<Integer>((a,b)->(b-a));
		
		for(int i=0;i<10;i++) {
			q_asc.add(i);
			q_desc.add(i);
		}
		
		System.out.println("==q_asc=================");
		while(!q_asc.isEmpty()) {
			System.out.format("%d \n",q_asc.poll());
		}//end while
		System.out.println("==q_desc=================");
		while(!q_desc.isEmpty()) {
			System.out.format("%d \n",q_desc.poll());
		}//end while		
		
	}

}

// Comparator 가 아닌 Comparable
class Node implements Comparable<Node> {
	public int data;
	public int distance;
	public Node(int data, int distance) {
		this.data = data;
		this.distance = distance;
	}
	
	@Override
	public String toString() {
		return String.format("data : %-5d, distance : %-5d ", this.data, this.distance);
	}

	@Override
	public int compareTo(Node o) {
		//return ( this.data - o.data ) * 1; // 1 asc, -1 desc
		return ( this.distance - o.distance ) * 1; // 1 asc, -1 desc
	}
	
}


//출력
==[pqLowest]===============
1
10
100
==[pqHighest]===============
100
10
1
==[Custome]===============
data : 1    , distance : 100   
data : 100  , distance : 200   
data : 70   , distance : 300   
data : 30   , distance : 400   
==[]===============
    1     1 
    0     1 
    0     3 
    0     7 
==q_asc=================
0 
1 
2 
3 
4 
5 
6 
7 
8 
9 
==q_desc=================
9 
8 
7 
6 
5 
4 
3 
2 
1 
0 

```
