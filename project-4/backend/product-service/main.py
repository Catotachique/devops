from fastapi import FastAPI
from pymongo import MongoClient

app = FastAPI()

client = MongoClient("mongodb://mongo:27017")
db = client["product_db"]

@app.get("/")
def home():
    return {"message": "Product Service is running!"}

@app.get("/products/{product_id}")
def get_product(product_id: str):
    product = db.products.find_one({"id": product_id})
    if product:
        return {"product_id": product["id"], "name": product["name"]}
    return {"error": "Product not found"}
