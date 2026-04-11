#!/bin/bash

# macOS Jekyll 로컬 서버 실행 스크립트

if ! command -v ruby &> /dev/null; then
    echo "Ruby가 설치되어 있지 않습니다."
    echo "brew install rbenv ruby-build 로 설치해주세요."
    exit 1
fi

if ! command -v bundle &> /dev/null; then
    echo "Bundler가 설치되어 있지 않습니다."
    echo "gem install bundler 로 설치해주세요."
    exit 1
fi

if [ ! -f "Gemfile.lock" ] || [ "Gemfile" -nt "Gemfile.lock" ]; then
    echo "의존성을 설치합니다..."
    bundle install
fi

bundle exec jekyll serve
