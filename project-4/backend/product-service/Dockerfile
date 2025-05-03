# Use official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy app files
COPY main.py /app/

# Install dependencies
RUN pip install --no-cache-dir fastapi uvicorn

# Expose port FastAPI will run on
EXPOSE 3000

# Start the app using uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]

