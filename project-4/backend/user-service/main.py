from fastapi import FastAPI
from pymongo import MongoClient
import os

app = FastAPI()

# Connect to MongoDB
mongo_url = os.getenv("DATABASE_URL", "mongodb://localhost:27017/userdb")
client = MongoClient(mongo_url)
db = client.get_database()

@app.get("/")
def home():
    return {"message": "User Service is running!"}

@app.get("/users/{user_id}")
def get_user(user_id: int):
    return {"user_id": user_id, "name": "John Doe"}