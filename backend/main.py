from fastapi import FastAPI
import uvicorn
from router.routes import router
import psutil
from fastapi.middleware.cors import CORSMiddleware
# Add CORS middleware
origins = ["*"]  # Allow all origins
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI application!"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)