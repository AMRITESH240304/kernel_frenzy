from fastapi import APIRouter,WebSocket,WebSocketDisconnect,UploadFile,File,HTTPException,Form
import psutil
import asyncio
import json
from supabase import create_client, Client
from config import settings
from ws.ws_manager import manager
from service.db.db import supabase
from service.models.model import *
from time import sleep
router = APIRouter()

@router.get("/hello")
def say_hello():
    return {"message": "Hello from another route!"}

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            cpu_usage = psutil.cpu_percent(interval=1)
            memory_usage = psutil.virtual_memory().percent

            await manager.broadcast(json.dumps({
                "type": "metrics",
                "cpu": cpu_usage,
                "memory": memory_usage
            }))

            await asyncio.sleep(1)

    except WebSocketDisconnect:
        print("🔌 WebSocket disconnected gracefully.")
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
    finally:
        manager.disconnect(websocket)
    
@router.post("/userinfo")
def get_user_info(userInfo:UserInfo):
    
    supabase.table("user").insert(userInfo.model_dump()).execute()
    return {"message": "User info added successfully!"}

@router.post("/uploadcsv")
async def upload_csv(user_id: str = Form(), file: UploadFile = File(...)):
    try:
        user_check = supabase.table("user").select("id").eq("id", user_id).execute()
        await manager.broadcast(json.dumps({
            "type": "upload_status",
            "message": 0.3
        }))
        sleep(2)

        if not user_check.data:
            await manager.broadcast(json.dumps({
                "type": "upload_status",
                "message": 0.8
            }))
            raise HTTPException(status_code=403, detail="User ID not found. Upload not allowed.")

        await manager.broadcast(json.dumps({
            "type": "upload_status",
            "message": 0.9
        }))
        sleep(2)
        bucket_name = "csv_files"
        file_content = await file.read()
        file_path = f"{user_id}/{file.filename}"  

        response = supabase.storage.from_(bucket_name).upload(
            path=file_path,
            file=file_content,
            file_options={
                "content-type": file.content_type,
                "cacheControl": "3600",
                "upsert": False,
            }
        )

        public_url = supabase.storage.from_(bucket_name).get_public_url(file_path)
        await manager.broadcast(json.dumps({
            "type": "upload_status",
            "message": 1
        }))

        return {"message": "File uploaded successfully", "url": public_url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/getcsv/{user_id}")
def get_csv(user_id: str):
    try:
        user_check = supabase.table("user").select("id").eq("id", user_id).execute()

        if not user_check.data:
            raise HTTPException(status_code=403, detail="User ID not found. Upload not allowed.")

        bucket_name = "csv_files"
        response = supabase.storage.from_(bucket_name).list(user_id)

        return {"message": "Files retrieved successfully", "data": response}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.delete("/deletecsv/{user_id}/{file_name}")
def delete_csv(user_id: str, file_name: str):
    try:
        user_check = supabase.table("user").select("id").eq("id", user_id).execute()

        if not user_check.data:
            raise HTTPException(status_code=403, detail="User ID not found. Upload not allowed.")

        bucket_name = "csv_files"
        response = supabase.storage.from_(bucket_name).remove([f"{user_id}/{file_name}"])

        return {"message": f"File {file_name} deleted successfully", "data": response}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))