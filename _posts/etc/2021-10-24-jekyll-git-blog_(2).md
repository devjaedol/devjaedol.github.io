---
title: \[2강\] GitHub blog 만들기(GitHub 설정 및 도메인 연결) 
categories: 
    - etc
tags: 
    - jekyll
    - githug
    - blog
    - github blog
    - minimal-mistakes
toc : true
toc_sticky  : true    
---

GitHub에 Jekyll을 통해서 만들어진 HTML 결과물을 배포해 보겠습니다.   


## GitHub 계정 생성 및 저장소 생성
<https://github.com/>{:target="_blank"} 에 Account를 생성 합니다.   
Account 로그인 후에 Create a new Repository 를 선택하여, 다음 이름 규칙으로 저장소를 생성합니다.   
![jekyll-github-blog-02_1](\assets\images_post\jekyll\jekyll-github-blog-02_1.png)


> **계정명**.github.io 

제 계정명은 devjaedol 입니다.   
저장소 이름은  devjaedol.github.io 로 작성 합니다.   
저장소는  Public으로 설정하고 생성 합니다.

## Git 저장소에 소스 Commit 및 구조 설명

1강에서 작업한 D:\jekyll-blog 에 내용을 생성한 git repository에 다음과 같이 위치 시킵니다.
bundle exec jekyll serve 명령어를 통해 서버를 실행 시키면, 
설정된 jekyll 내용대로 html 이 D:\jekyll-blog\_site 에 생성됩니다.
위 두가지 설정을 생성한 repository에 2개의 branch를 생성하여 위치 시킵니다.   

GitHub 저장소 구조    
- 계정명.github.io     
    - master   : jekyll를 통해 컴파일된 HTML이 배치됨     
        - ( D:\jekyll-blog\_site 이하 내용 )    
    - source   : jekyll 설정 소스가 배치됨     
        - ( D:\jekyll-blog 이하 내용 )   

source branch의 jekyll 소스를 Travis-CI를 통해 자동 빌드하여 master brach로 자동화 처리를 다음 편에서 진행 합니다.   
즉, master에 _site의 내용은 자동으로 업데이트 되나, 지금은 구동되는 구조를 이해하기 위해서 다음과 같이 진행 해보겠습니다.   

D:\jekyll-blog\_site 에서 cmd 창에 다음 명령어를 입력 합니다.   
위 작업을 하기 위해서는 git 설치와 git접속 인증 설정 등이 되어 있어야 합니다.    
```
git init
git commit -m "first site commit"
git remote add origin https://github.com/계정명/계정명.github.io.git
git branch -M master
git push -u origin master
```

git push가 완료된 후 브라우저를 통해서     
https://계정명.github.io 으로 접속 해 봅니다.   
로컬 기동 화면과 같은 화면이 해당 계정명으로 출력 됩니다.   
(아래에서 주소가 다름 참고)

![jekyll-github-blog-01_1](\assets\images_post\jekyll\jekyll-github-blog-01_13.png)


## Doamin 연결

연결할 도메인의 DNS를 github로 설정을 변경 합니다.     
![jekyll-github-blog-02_3](\assets\images_post\jekyll\jekyll-github-blog-02_3.png)   
- DNS 설정 값
    - A Type 
        - 185.199.108.153 
        - 185.199.109.153 
        - 185.199.110.153 
        - 185.199.111.153    
    - CNAME Type 
        - devjaedol.github.io 


개인 도메인을 GitHub에 연결하려면, 연결할 Repository에 접근 합니다.    
settings >  Pages  > Cusom domain 에 도메인을 입력 후 저장 합니다.   

![jekyll-github-blog-02_2](\assets\images_post\jekyll\jekyll-github-blog-02_2.png)

DNS 등이 정상적으로 되었다면, 에러 없이 Save가 됩니다만, DNS오류 등이 발생하면 해당 내용이 출력 됩니다.    




