# 랜딩 HTML 의 브랜드 토큰 치환. 각 HTML location 안에서 include 한다.
# (.inc 확장자라 routes/*.conf 자동 include 대상이 아니다. 변수 정의는 01-brand.conf)
sub_filter_once off;
sub_filter '{{BRAND_NAME_EN}}'   $brand_name_en;
sub_filter '{{BRAND_NAME}}'      $brand_name;
sub_filter '{{BRAND_DOMAIN}}'    $brand_domain;
sub_filter '{{BRAND_MASCOT_ALT}}' $brand_mascot_alt;
sub_filter '{{BRAND_ICON_TYPE}}' $brand_icon_type;
sub_filter '{{BRAND_APPLE_ICON}}' $brand_apple_icon;
sub_filter '{{BRAND_ICON}}'      $brand_icon;
sub_filter '{{BRAND}}'           $brand;
