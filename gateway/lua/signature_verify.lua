local uri = ngx.var.uri or ""
local match_regex = ngx.var.signature_match_regex or "/api/"
local whitelist_pattern = ngx.var.signature_whitelist_regex or ""

-- 1. URI가 Signature 인증 대상 경로인지 확인
if not ngx.re.find(uri, match_regex, "jo") then
    ngx.log(ngx.INFO, "[HMAC] 🔓 Non-matching path, skipping signature: ", uri)
    return
end

-- 2. API 경로지만 whitelist에 해당되면 생략
if whitelist_pattern ~= "" then
    local ok, err = ngx.re.find(uri, whitelist_pattern, "jo")
    if ok then
        ngx.log(ngx.INFO, "[HMAC] 🔓 Whitelisted API path, skipping signature: ", uri)
        return
    end
end

-- 3. Signature 검증 절차
local ffi = require "ffi"
local base64 = require("ngx.base64")

ffi.cdef [[
typedef unsigned int uint;
typedef unsigned char uchar;
uchar *HMAC(const void *evp_md, const void *key, int key_len,
            const uchar *d, int n, uchar *md, uint *md_len);
void *EVP_sha256(void);
]]

local function exit_with_error(status, message)
    ngx.status = status
    ngx.say(message)
    ngx.exit(status)
end

local user_id = ngx.req.get_headers()["X-User-ID"]
local signature = ngx.req.get_headers()["X-Signature"]
local secret_key = os.getenv("SECRET_KEY")

if not user_id then
    return exit_with_error(400, "Missing X-User-ID")
end

if not signature then
    return exit_with_error(400, "Missing X-Signature")
end

if not secret_key then
    ngx.log(ngx.ERR, "[HMAC] ❌ Missing SECRET_KEY")
    return exit_with_error(500, "Server error: no secret key")
end

local md = ffi.new("unsigned char[32]")
local md_len = ffi.new("unsigned int[1]")

local result_ptr = ffi.C.HMAC(ffi.C.EVP_sha256(),
    secret_key, #secret_key,
    user_id, #user_id,
    md, md_len)

if result_ptr == nil then
    ngx.log(ngx.ERR, "[HMAC] ❌ HMAC generation failed")
    return exit_with_error(500, "Server error: HMAC failure")
end

local signature_bin = ffi.string(md, md_len[0])
local expected_signature = base64.encode_base64url(signature_bin):gsub("=", "")

if expected_signature ~= signature then
    ngx.log(ngx.ERR, "[HMAC] ❌ Signature mismatch")
    return exit_with_error(401, "Invalid Signature")
end

ngx.log(ngx.INFO, "[HMAC] ✅ Signature verified successfully")
