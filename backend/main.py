from fastapi import FastAPI
import uvicorn
from router.routes import router
import psutil

app = FastAPI()

app.include_router(router)
@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI application!"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)