from fastapi import APIRouter,WebSocket,WebSocketDisconnect
import psutil
import asyncio
import json
from supabase import create_client, Client
from pydantic import BaseModel
from config import settings
from ws.ws_manager import manager

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

            data = {"cpu": cpu_usage, "memory": memory_usage}
            await manager.send_personal_message(json.dumps(data), websocket)

            await asyncio.sleep(1)  

    except WebSocketDisconnect:
        print("🔌 WebSocket disconnected gracefully.")
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
    finally:
        manager.disconnect(websocket)


class UserInfo(BaseModel):
    id:str
    email:str
    name:str
    
supabase_url = settings.SUPABASE_PROJECT_URL
supabase_key = settings.SUPABASE_API_KEY
supabase: Client = create_client(supabase_url, supabase_key)
    
@router.post("/userinfo")
def get_user_info(userInfo:UserInfo):
    data = {
        "id": userInfo.id,
        "email": userInfo.email,
        "name": userInfo.name
    }
    
    supabase.table("user").insert(data).execute()
    return {"message": "User info added successfully!"}