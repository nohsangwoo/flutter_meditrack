#!/bin/bash

# Flutter 프로젝트 정리 및 설정 스크립트

echo "Flutter 프로젝트 정리 시작..."
flutter clean

echo "Flutter 의존성 가져오기..."
flutter pub get

echo "iOS 설정 업데이트 중..."
cd ios
arch -x86_64 pod update
arch -x86_64 pod install
cd ..

echo "Xcode 캐시 정리 중..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "모든 작업이 완료되었습니다."
