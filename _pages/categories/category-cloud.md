---
title: "Cloud Platform"
layout: archive
permalink: categories/cloud
sidebar_main: true
---
<!-- 공백이 포함되어 있는 카테고리 이름의 경우 site.categories['a b c'] 이런식으로! -->
***
{% assign posts = site.categories.cloud %}
{% for post in posts %} {% include archive-single2.html type=page.entries_layout %} {% endfor %}