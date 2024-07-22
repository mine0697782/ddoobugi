# DDOOBUGI (뚜벅이)

주변 산책 명소와 루트를 추천해주는 앱.

건물, 동상, 숲, 산책로, 로드뷰 등 다양한 산책지 정보를 제공합니다.

## 팀소개

* [정민재 (mine0697782)](https://github.com/mine0697782)
* [송문선 (mmoossun)](https://github.com/mmoossun)
* [박규민 (gyumin4726)](https://github.com/gyumin4726)
* [김규리 (gyur2)](https://github.com/gyur2)
* [서다솜 (dasom040819)](https://github.com/dasom040819)

## 뷰 스택

앱 시작

* 로그인
  * 회원가입
* 스타팅 화면
  * 새로 시작하기
    * 지도
      * 대화 창
      * 플로팅 바 / 버튼
        * 플로팅 메뉴 ( 프롬프트 / 마이페이지 / 루트 중단 )
  * 불러오기
    * 루트 목록

      * 루트 상세
        * 지도 / 루트 진입
  * 마이페이지
    * 유저정보 / 가입일 / uid / 로그아웃

## 기술 스택

* Langchain
* Flutter
* Flask
* SQLite

## 프로젝트 구조

```
ddoobugi/
├── backend/ (임시)
│   ├── app/
│   │   ├── __init__.py
│   │   └── routes.py
│   ├── venv/
│   ├── run.py
│   └── requirements.txt
├── frontend/ (임시)
│   ├── android/
│   ├── lib/
│   │   ├── main.dart
│   ├── test/
│   ├── pubspec.yaml
│   └── (기타 Flutter 프로젝트 파일)
├── .gitignore
└── README.md
```

### Flask 가상환경 실행

```
시작
source venv/bin/activate
종료
deactive
```
