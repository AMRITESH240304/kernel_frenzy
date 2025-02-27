from supabase import create_client, Client
from config import settings

supabase_url = settings.SUPABASE_PROJECT_URL
supabase_key = settings.SUPABASE_API_KEY
supabase: Client = create_client(supabase_url, supabase_key)
