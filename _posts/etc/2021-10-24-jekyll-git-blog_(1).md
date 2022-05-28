---
title: "[Jekyll #1] GitHub blog 만들기(기본 설정)"
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

jekyll을 통해서 GitHub blog를 만들어 보겠습니다.     
작업을 위한 필요 지식 수준은 GitHub에 저장소를 만들고 소스를 등록 및 업데이트 할수 있는 지식 수준이 필요합니다.   
최대한 단순하고 간략하게만 정리하도록 하겠습니다.   



## Jekyll 장단점 소개

jekyll을 통해서 Git blog를 운용시 다른 플랫폼이 제공하는 블로그에 비해서 장단점이 명확히 다릅니다.

장점으로는

- Custmize. ( HTML 기반으로 모든 변경이 가능합니다.)
- 다양한 Template ( 수많은 템플릿 중에 선택적으로 설치하여 사용이 가능합니다.)
- GitHub의 공간을 사용하므로, 별도의 호스팅 비용이 필요하지 않습니다.

단점으로는

- 플랫폼이 제공하는 블로그에 비하면 강력하게 불편 합니다.
- 손이 많이 갑니다.(Tistory처럼 단순히 글만 쓰면 되는 정도의 수준이 넘습니다.)
- HTML 등의 기초 홈페이지 관리에 대한 기본 지식이 필요합니다.
- 로컬에서 뭔가 서버 개발 작업하듯이 설치와 설정을 꽤 많이 해야됩니다.

  
이제 부터 간단히 블로그 생성 방법을 정리해 보겠습니다.



## Ruby 설치. 

Jekyll은 Ruby를 통해서 구동됩니다.
설치 버전 Ruby+Devkit 2.6.6-1 (x64) 

> [Ruby 다운로드](https://rubyinstaller.org/downloads/archives/ "루비 설치"){:target="_blank"}

설치를 진행 합니다    

![jekyll-github-blog-01_1](\assets\images_post\jekyll\jekyll-github-blog-01_1.png)

![jekyll-github-blog-01_2](\assets\images_post\jekyll\jekyll-github-blog-01_2.png)

![jekyll-github-blog-01_3](\assets\images_post\jekyll\jekyll-github-blog-01_3.png)

![jekyll-github-blog-01_4](\assets\images_post\jekyll\jekyll-github-blog-01_4.png)

설치가 완료되면 다음과 같은 콘솔이 출력됩니다.

![jekyll-github-blog-01_5](\assets\images_post\jekyll\jekyll-github-blog-01_5.png)

Which components shall be installed? If unsure press ENTER [1,3]

1 - MSYS2 base installation 을 선택 합니다.

Which components shall be installed? If unsure press ENTER[]

Enter를 입력 합니다.

![jekyll-github-blog-01_7](\assets\images_post\jekyll\jekyll-github-blog-01_7.png)


##  bundler 를 설치

CMD 창에 아래와 같이 명령어를 입력 합니다.

> gem install bundler

```
C:\>gem install bundler
    Fetching bundler-2.2.29.gem
    Successfully installed bundler-2.2.29g
    Parsing documentation for bundler-2.2.29
    Installing ri documentation for bundler-2.2.29
    Done installing documentation for bundler after 4 seconds
    1 gem installed
```
![jekyll-github-blog-01_8](\assets\images_post\jekyll\jekyll-github-blog-01_8.png)



## Blog 설치 디렉토리 생성

블로그 홈 서버를 실행할 작업 임시 경로를 선정하십시요.

저는 아래 경로에 임시로 작업을 진행 합니다.

D:\jekyll-blog

```
c:\>d:
d:\>mkdir jekyll-blog
d:\>cd jekyll-blog
d:\jekyll-blog>
```



## 테마 설치

Jekyll 의 강력한 장점 중 하나가  다양한 테마 입니다.

아래 사이트 들은 Jekyll 테마를 모아놓은 사이트 입니다.

이곳에서 원하는 테마를 선택 하십시요.

- <https://jekyll-themes.com/free/>{:target="_blank"}
- <http://themes.jekyllrc.org>{:target="_blank"}
- <http://jekyllthemes.org>{:target="_blank"}
- <https://jekyllthemes.io/free>{:target="_blank"}
- <https://jekyllthemes.dev/>{:target="_blank"}
- <https://drjekyllthemes.github.io/new>{:target="_blank"}



저는 Minimal Mistakes Jekyll theme 라는 테마를 통해서 홈페이지를 꾸미고 있습니다.

본 테마는 꽤 인기있는 테마로 심플함이 최대 장점이라서 적용 했습니다.

- <https://jekyllthemes.io/theme/minimal-mistakes>{:target="_blank"}
- [데모사이트 -Guick start guide](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/){:target="_blank"}

우선 해당 git에서 소스를 zip 형태로 다운 받습니다.

<https://github.com/mmistakes/minimal-mistakes>{:target="_blank"}

다운로드한  Zip파일을 생성한 D:\jekyll-blog 에 풀어 놓습니다.

![jekyll-github-blog-01_9](\assets\images_post\jekyll\jekyll-github-blog-01_9.png)


## bundle 설치

임시로 작업 폴더(테마가 다운된 경로)에서 번들 설치를 위한 다음 명령어를 입력 합니다.

> bundle install

```
d:\jekyll-blog>bundle install
```

테마와 관련된 bundle이 모두 설치 됩니다.

유사 기능으로는 npm install, pip install 과 같이 관련 패키지 모두 자동화로 설치해주신다고 보면 됩니다.

![jekyll-github-blog-01_10](\assets\images_post\jekyll\jekyll-github-blog-01_10.png)

![jekyll-github-blog-01_11](\assets\images_post\jekyll\jekyll-github-blog-01_11.png)


## 로컬 서비 시작

테마가 다운된 경로에서 서비스를 시작 합니다

> bundle exec jekyll serve

```
d:\jekyll-blog>bundle exec jekyll serve
```

![jekyll-github-blog-01_12](\assets\images_post\jekyll\jekyll-github-blog-01_12.png)

테마에 적용된 내용이 html로 생성되며, 잠시 뒤 http://127.0.0.1:4000 메세지와 함께 서비스가 기동된 것을 알수 있습니다.



## 브라우저 접속을 통한 Blog 서비스 확인

서버 기동 후 http://127.0.0.1:4000 에 접속해보면, 아래와 같은 기초 페이지가 생성되어 보여 집니다.

![jekyll-github-blog-01_13](\assets\images_post\jekyll\jekyll-github-blog-01_13.png)



## 첫번째 포트스 작성
jekyll의 포트스는 markdown을 기본으로 지원 합니다. 

아래 파일을 만듭니다.   
> d:\jekyll-blog\_posts\2021-10-24-myfirstpost.md     

모든 포스트의 위치는 _posts 폴더 밑 입니다.   
파일 내용은 아래와 같이 입력 합니다.   

```
---
title: 첫번째 포스트 입니다.
tags: 
    - 첫포스트
---

안녕하세요.   
첫번째 포스트 입니다.

```

브라우저를 통해서 새로고침하면, 첫 포스트가 계시되어 있습니다.   
markdown 작성법은 [마크 다운 문법](https://kimjaehyun.co.kr/etc/markdown/){:target="_blank"}에서 확인 하시기 바랍니다.

minimal-mistakes 에는 다양한 샘플 포스트 작성법을 제공 하고 있습니다.    
[포스트 샘플](https://mmistakes.github.io/minimal-mistakes/year-archive/){:target="_blank"}
에서 참고 바랍니다.    

![jekyll-github-blog-01_29](\assets\images_post\jekyll\jekyll-github-blog-01_29.png)

![jekyll-github-blog-01_30](\assets\images_post\jekyll\jekyll-github-blog-01_30.png)

## 트러블슈팅

bundel 작업중 아래와 같은 에러가 발생 할 경우가 있습니다.    

![jekyll-github-blog-01_27](\assets\images_post\jekyll\jekyll-github-blog-01_27.png)
```
    Please add the following to your Gemfile to avoid polling for changes:
    gem 'wdm', '>= 0.1.0' if Gem.win_platform?
```

위 메세지가 나오면, 프로젝트 폴더에 Gemfile을 메모장으로 편집 합니다.
아래 메세지를 해당 파일 마지막에 추가 합니다.   
gem 'wdm', '>= 0.1.0'

![jekyll-github-blog-01_28](\assets\images_post\jekyll\jekyll-github-blog-01_28.png)

```
source "https://rubygems.org"
gem 'wdm', '>= 0.1.0'
gemspec
```

다시 bundle install 을 통해서 변경사항을 재설치 합니다.
> bundle install




