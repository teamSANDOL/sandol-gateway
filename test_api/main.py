from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/")
async def read_root(request: Request):
    user_id = request.headers.get("x-user-id")
    return {"message": "Hello from backend!", "user_id": user_id, "all_headers": request.headers}
