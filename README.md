# 📌 Sandol Gateway Repository

## 📂 개요  
이 Repository는 **산돌이 프로젝트의 API Gateway**를 담당합니다.  
모든 클라이언트 요청은 **OpenResty(Nginx + Lua) 기반 Gateway**를 통해  
내부 MSA 서비스로 전달됩니다.

---

## 📦 핵심 기능  
- 요청 경로 기반 프록시 라우팅
  - `/meal/`
  - `/kakao-bot/`
  - `/notice-notification/`
  - `/classroom-timetable/`
  - `/static-info/`
  - `/relay/`
  - `/grafana/`
  - `/auth/` (Keycloak reverse proxy)
- 공통 헤더 전달 (`Host`, `X-Real-IP`, `X-Forwarded-For`, `X-User-ID`, `Origin`)

---

## 📁 프로젝트 구조  
```
.
├── gateway/
│   ├── default.conf              # 메인 Nginx 설정
│   └── routes/                   # 각 서비스별 conf
├── test_api/                     # 테스트용 백엔드 서비스
├── docker-compose.yml            # Gateway + Backend 구성
├── README.md
└── test_client.py                # 요청 예제 스크립트
```

---

## 🛠️ 사용 기술  
- **Nginx (OpenResty 기반)**: 라우팅 및 리버스 프록시 처리
- **Docker + Docker Compose**: 컨테이너 기반 구성
- **환경변수 관리**: `.env` 또는 셸 환경변수에서 `SECRET_KEY` 설정

---

## 🧪 실행 방법

### 1. 로컬 실행
```bash
docker compose up -d
```

### 2. 종료
```bash
docker compose down
```

### 3. 환경변수 변경 후 재시작
```bash
docker compose up -d --build
```

> `SECRET_KEY`는 `.env`에 정의하거나 환경변수로 주입해야 합니다.

### 로컬 실행 범위 안내
- 현재 `docker-compose.yml`은 `gateway`와 샘플 `backend`만 포함합니다.
- 각 라우트가 가리키는 실제 서비스(`meal-service`, `kakao-bot-service` 등)는 이 저장소에서 함께 실행되지 않습니다.

---

## 🔁 Docker 서비스 구성 요약

```yaml
services:
  gateway:
    build: ./gateway
    ports:
      - "8010:80"
    environment:
      - SECRET_KEY=${SECRET_KEY}
    volumes:
      - ./gateway/default.conf:/etc/nginx/conf.d/default.conf:ro
    command: ["/usr/local/openresty/bin/openresty", "-g", "env SECRET_KEY; daemon off;"]
    depends_on:
      - backend

  backend:
    build: ./test_api
    ports:
      - "8011:8011"
    command: ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8011"]
```

---

## 🚀 배포 가이드  
- CI/CD 자동 배포 예정 (예: GitHub Actions 기반)
- 도메인 연결: 예) `api.sandol.com`, `gateway.sandol.house.sio2.kr`
- SSL: `Let's Encrypt` 및 `Certbot` 기반 인증서 적용 가능
- 프록시 서버에 따라 내부 서비스 보안 정책 강화 가능

---

📡 산돌이 프로젝트의 모든 API 요청은 이 Gateway를 통해 전달됩니다.
