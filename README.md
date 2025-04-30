# 📌 Sandol Gateway Repository

## 📂 개요  
이 Repository는 **산돌이 프로젝트의 API Gateway**를 담당합니다.  
모든 클라이언트 요청은 **OpenResty(Nginx + Lua) 기반 Gateway**를 통해  
내부 MSA 서비스로 전달되며, 요청에 대해 **서명 기반 사용자 인증(Signature Verification)**이 수행됩니다.

---

## 📦 핵심 기능  
- 요청 경로 기반 프록시 라우팅 (`/meal/`, `/user/`, `/kakao-bot/` 등)
- `X-User-ID` + `X-Signature` 헤더를 활용한 **서명 기반 인증 처리**
- 인증 예외 경로는 **정규식으로 정의 가능** (ex. `/api/ping`, `/api/healthz`)
- 인증 실패 시 `401 Unauthorized` 응답 처리
- **정적 파일 서빙**(예: `/user/static/`) 지원
- **확장 가능한 Signature 미들웨어 구조** 적용

---

## 📁 프로젝트 구조  
```
.
├── gateway/
│   ├── default.conf              # 메인 Nginx 설정
│   ├── routes/                   # 각 서비스별 conf
│   └── lua/
│       └── signature_verify.lua  # Signature 인증 미들웨어
├── test_api/                     # 테스트용 백엔드 서비스
├── docker-compose.yml            # Gateway + Backend 구성
```

---

## 🛠️ 사용 기술  
- **Nginx (OpenResty 기반)**: 라우팅 및 인증 미들웨어 처리
- **Lua (FFI + HMAC)**: Signature 검증 처리
- **Docker + Docker Compose**: 컨테이너 기반 구성
- **환경변수 관리**: `.env` 또는 CI에서 `SECRET_KEY` 설정

---

## 🔐 인증 방식 요약

### ✅ 헤더 기반 서명 검증
- 클라이언트 요청에는 반드시 아래 두 헤더가 포함되어야 함:
  - `X-User-ID`: 사용자 ID
  - `X-Signature`: HMAC-SHA256 기반 서명값
- Gateway에서 `SECRET_KEY`를 이용해 재계산한 서명값과 비교

### ✅ 정규식 기반 예외 처리
- 특정 경로(`/api/ping`, `/api/healthz` 등)는 인증 생략 가능
- 각 서비스 conf 파일에서 `set $signature_whitelist_regex`로 지정

### ✅ 인증 대상 경로 정의
- 기본값으로 `/api/` 포함 경로만 인증 대상
- 필요시 `set $signature_match_regex`로 확장 가능

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

## 📎 문서
- [📄 API 명세서 (Notion)](링크 삽입)
- [📄 서명 인증 구조 설명 (Notion)](링크 삽입)

---

## 📞 문의
- **디스코드 채널**: (링크 삽입)

---

🛡️ Signature 기반 인증으로 보호되는 **신뢰 가능한 Gateway**  
📡 산돌이 프로젝트의 모든 API 요청은 이 Gateway를 통해 안전하게 전달됩니다.
