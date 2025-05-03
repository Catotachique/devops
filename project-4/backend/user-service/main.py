from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI()

class Product(BaseModel):
    id: int
    name: str
    price: int

class ProductCreate(BaseModel):
    name: str
    price: int

# In-memory product list
products: List[Product] = [
    Product(id=1, name="Laptop", price=1200),
    Product(id=2, name="Phone", price=800)
]

@app.get("/api/products", response_model=List[Product])
def get_products():
    return products

@app.get("/api/products/{product_id}", response_model=Product)
def get_product(product_id: int):
    for product in products:
        if product.id == product_id:
            return product
    raise HTTPException(status_code=404, detail="Product not found")

@app.post("/api/products", response_model=Product, status_code=201)
def create_product(product: ProductCreate):
    new_id = max((p.id for p in products), default=0) + 1
    new_product = Product(id=new_id, **product.dict())
    products.append(new_product)
    return new_product

@app.put("/api/products/{product_id}", response_model=Product)
def update_product(product_id: int, product_data: ProductCreate):
    for i, p in enumerate(products):
        if p.id == product_id:
            updated = Product(id=product_id, **product_data.dict())
            products[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="Product not found")

@app.delete("/api/products/{product_id}", response_model=Product)
def delete_product(product_id: int):
    for i, p in enumerate(products):
        if p.id == product_id:
            removed = products.pop(i)
            return removed
    raise HTTPException(status_code=404, detail="Product not found")