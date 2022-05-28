---
title: "[자료구조] Stack & Queue" 
categories: 
    - java
tags: 
    - stack
    - queue
    - FIFO
    - LIFO
    - 자료구조
toc : true
toc_sticky  : true        
---

자료 구조 중에 스택과 큐에 대해서 TestCode를 작성해 봅니다.

## Stack
- LIFO(Last Input Firs Out) 마지막에 넣은 요소가 먼저 나온다는 의미이다.
- DFS 사용

## Queue
- FIFO(Fisrt Input Firs Out) 먼저 들어간 데이터가 먼저 나오는 구조이다.
- BFS 사용

## Stack Soruce Code
```java
package datatype;
import java.util.Stack;

public class StackTest {

	public static void main(String[] args) {
		
		Stack stack = new Stack();
		System.out.println("==================");
		System.out.println("stack.size():"+stack.size());
		
		stack.push("1");
		stack.push("2");
		stack.push("3");
		stack.push("4");
		stack.push("5");

		System.out.println("stack.peek():"+stack.peek()); // peek 마지막값을 확인하는 것
		
		//stack.remove(0);
		stack.add(0,"*****");//중간에 넣기
		
		
		//while(!stack.empty()){
		//	System.out.println("get : "+stack.peek());//제거하지 않고 마지막 값을 가져오므로 무한루프에 빠진다.
		//}

		System.out.println("==================");
		for(int i=0;i<stack.size();i++){
			System.out.println(i+" : "+stack.get(i).toString()); // 제거없이 조회만
		}
		
		System.out.println("stack.size():"+stack.size());
		System.out.println("==================");

		while(!stack.empty()){
			System.out.println("get : "+stack.pop()); // 입력 역순으로 제거하면 조회됨
		}
	}

}

//출력
==================
stack.size():0
stack.peek():5
==================
0 : *****
1 : 1
2 : 2
3 : 3
4 : 4
5 : 5
stack.size():6
==================
get : 5
get : 4
get : 3
get : 2
get : 1
get : *****

```

## Queue Soruce Code
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
