# Use Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy application files
COPY . .

# Expose port and run React app
EXPOSE 3000
CMD ["npm", "start"]