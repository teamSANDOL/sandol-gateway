# https 업스트림 공통 TLS 설정 (http 업스트림에서는 무시된다). keycloak.conf / auth-relay.conf 의 location 안에서 include.
# 검증은 항상 켠다(끄는 옵션 없음). SNI·검증 호스트명 = $up_host (업스트림 호스트명).
# 신뢰 CA: 기본 시스템 번들, UPSTREAM_CA_BUNDLE 로 교체 (render-trusted-proxies.sh 가 upstream-ca.conf 생성)
proxy_ssl_server_name   on;
proxy_ssl_name          $up_host;
proxy_ssl_verify        on;
proxy_ssl_verify_depth  4;
proxy_ssl_protocols     TLSv1.2 TLSv1.3;
include /usr/local/openresty/nginx/conf/upstream-ca.conf;
