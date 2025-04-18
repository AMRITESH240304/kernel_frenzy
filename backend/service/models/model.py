from pydantic import BaseModel

class UserInfo(BaseModel):
    id:str
    email:str
    name:str

class UserCheck(BaseModel):
    id:str
    