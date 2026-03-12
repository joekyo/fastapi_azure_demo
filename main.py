from fastapi import FastAPI
from datetime import datetime

app = FastAPI(title="My FastAPI App", version="1.0.0")

@app.get("/")
def root():
    return {"message": "Hello from Azure!", "time": datetime.utcnow()}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/hello")
def greeting(name: str):
    return {"hello": name}
