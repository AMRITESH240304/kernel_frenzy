from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SUPABASE_API_KEY: str
    SUPABASE_PROJECT_URL: str
    
    class Config:
        env_file = ".env"
        
settings = Settings()