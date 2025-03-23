import base64
import hashlib
import hmac
import requests

SECRET_KEY = "mysecretkey"
USER_ID = "1234567890"

signature = hmac.new(
    SECRET_KEY.encode(), USER_ID.encode(), hashlib.sha256
).digest()
signature_base64 = base64.urlsafe_b64encode(signature).decode().rstrip("=")

res = requests.get(
    "http://localhost:8010",
    headers={
        "X-User-ID": USER_ID,
        "X-Signature": signature_base64,
    },
)

print(res.status_code)
try:
    print(res.json())
except:
    print("응답 JSON 아님:", res.text)
