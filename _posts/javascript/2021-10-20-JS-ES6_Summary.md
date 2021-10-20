---
title: ES6(ECMAScript6)등 간략 정리
categories: 
    - javascript
tags: 
    - ES6
    - ES5
    - ECMAScript6
toc : true
toc_sticky  : true
---

ES6 문법을 간략히 정리해 보겠습니다.

특별한 설명이 필요없는 보시면 아실듯한...



## ES6 Features(2016)
+ JavaScript Exponentiation (**)
+ JavaScript Exponentiation assignment (**=)
+ JavaScript Array.prototype.includes


## ES6 Features(2017)
+ JavaScript String padding
+ JavaScript Object.entries
+ JavaScript Object.values
+ JavaScript async functions
+ JavaScript shared memory

## ES6 Features(2018)
+ Asynchronous Iteration
+ Promise Finally
+ Object Rest Properties
+ New RegExp Features



## let  const 

let : { } 구역내에서 유효한 변수, 재할당 가능함.

const 수정이 불가능한 변수.



## Arrow Function 단축 지원
```javascript
//ES5
function echo(str){
	return str+" : "+ str
}

//ES6
const echo = (str)=> str+" : "+ str;

```



## Function 기본값 지원

```javascript
const echo = (str='야호')=> str+" : "+ str;
echo();
'야호 : 야호'

()=>{}
v1=>{}
(v1,v2)=>{}

()=>reval
v1=>reval
(v1,v2)=>reval

```



## String 비교 startsWith(), endsWith(), includes

```javascript
let str = 'ABCDEFGHIJK';;
str.includes('CDE');	//true
str.startsWith('ABCD');	//true
str.endsWith('IJK');	//true
```



## 템플릿 리터럴

```javascript
let name = '홍길동';
console.log(`안녕하세요 저는 ${name} 입니다.`);
```



## Object Destructuring

```javascript
const car = {
	name : 'sonata',
	price : 10000,
	type : 'sedan'
};

let {name, price} = car;
console.log(name);		// sedan
console.log(price);		// 10000
```



## Destructuring

```javascript
let old_data = ["A","B","C","D","E"];
let [v1,,,v2] = old_data;
console.log(v1);	//A
console.log(v2);	//D
```





## for-in

```javascript
let arr = ['A','B','C','D'];
for(let val of arr){
    console.log(val);
}
```



## Spread orperator

```javascript
let old_val = [1,2,3,4,5];
let new_val = [0,...old_val,6];
console.log(new_val);	// [0, 1, 2, 3, 4, 5, 6]

function totalSum( v1, v2, v3, v4, v5){
    return v1 + v2 + v3 + v4 + v5;
}
totalSum(...old_val);	//15

```



## Array.from

```javascript
function prices(){
    let data = Array.from(arguments);
	//console.log(data);
    return data;
}
prices(1,2,3,4,5);	//배열로 변환되어 반환됨 [1, 2, 3, 4, 5]
```



## Array.map()



## Array.Filter()



## spread operator





## set has

```javascript
let set_data = new Set();
set_data.add("A");
set_data.add("B");
set_data.add("C");
set_data.add("D");

//ES5 C를 포함 여부를 판단하려면
set_data.forEach(function(val){
    console.log(val); //비교 로직을 통해서 판단함.
});

//ES6
set_data.has("C");	//true
set_data.has("F");	//false
```



## WeakSet





## export import


sub.js   
```javascript
export default function testFn(v1){
    return v1 * v1;
}
```

main.js   
```javascript
import testFn from './sub.js'

//fn여러개인 경우
import {fnName1, fnName2, fnName3} from './sub.js'

```



## Promises



## Class constructor

```javascript
class Car {
    constructor(name, price){
        this.name = name;
        this.price = price;
    }
}

const mycar = new Car('sonata', 10000);
console.log(mycar.name);	// sonata
console.log(mycar.price);	// 10000
```







