#!/bin/sh
# 신뢰 프록시 목록(GATEWAY_TRUSTED_PROXIES)으로 real_ip / 문서 차단용 nginx 설정을 만들고
# 인자로 받은 명령(openresty)을 exec 한다. 값을 바꾸려면 .env 수정 후 컨테이너만 재시작.
# 미설정이면 기본값을 쓰고, 설정됐는데 비었거나 형식이 틀리면 기동을 중단한다.
set -eu
DEFAULT="172.30.1.101,172.30.1.110,172.30.1.31"   # NPM, cloudflared CT110, cloudflared CT131
OUT="${TRUSTED_PROXIES_CONF:-/usr/local/openresty/nginx/conf/trusted-proxies.conf}"
LIST=$(printf '%s' "${GATEWAY_TRUSTED_PROXIES-$DEFAULT}" | tr -d ' \r\n')
[ -n "$LIST" ] || { echo "GATEWAY_TRUSTED_PROXIES 가 비어 있음" >&2; exit 1; }
# 옥텟 0-255, 선택적 /0-32 (IPv4 만 지원)
O='(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])'
RE="^$O(\.$O){3}(/(3[0-2]|[12]?[0-9]))?\$"
{
  echo "# 자동 생성: render-trusted-proxies.sh (GATEWAY_TRUSTED_PROXIES)"
  GEO=""
  IFS=','
  for ip in $LIST; do
    printf '%s' "$ip" | grep -Eq "$RE" || { echo "GATEWAY_TRUSTED_PROXIES 형식 오류: '$ip'" >&2; exit 1; }
    case "$ip" in */*) c="$ip" ;; *) c="$ip/32" ;; esac
    echo "set_real_ip_from $c;"
    GEO="$GEO    $c 1;
"
  done
  echo "geo \$realip_remote_addr \$docs_via_proxy {   # 실제 연결 주소가 신뢰 프록시면 1"
  echo "    default 0;"
  printf '%s' "$GEO"
  echo "}"
} > "$OUT.tmp" || { rm -f "$OUT.tmp"; exit 1; }
mv "$OUT.tmp" "$OUT"
exec "$@"
