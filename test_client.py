import requests

USER_ID = "1234567890"

res = requests.get(
    "http://localhost:8010",
    headers={
        "X-User-ID": USER_ID,
    },
)

print(res.status_code)
try:
    print(res.json())
except:
    print("응답 JSON 아님:", res.text)
