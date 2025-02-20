# Use an official Go image as the builder
FROM golang:1.24.0 AS builder

WORKDIR /app/

# Copy and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application
RUN go build -o main .

# Use a lightweight Ubuntu image for production
FROM ubuntu:24.04

WORKDIR /root/

# Copy the compiled binary from the builder stage
COPY --from=builder /app/main .

# Expose the port
EXPOSE 8081

# Run the application
CMD ["./main"]

