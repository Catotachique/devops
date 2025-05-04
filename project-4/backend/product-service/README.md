#### Supported Endpoints:
GET /api/products → Get all products<br>
GET /api/products/1 → Get product by ID<br><br>

POST /api/products → Create a new product<br><br>

PUT /api/products/1 → Update product by ID<br><br>

DELETE /api/products/1 → Delete product by ID<br><br>

#### Build the Docker image:
docker build -t product-service:1.0.0 .

#### Run the container:
docker run -d -p 3000:3000 product-service:1.0.0