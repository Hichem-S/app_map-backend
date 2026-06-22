FROM node:22-alpine

WORKDIR /app

# Install dependencies first (cached layer)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source
COPY src/ ./src/

# Create uploads directory
RUN mkdir -p uploads/qr uploads/photos

EXPOSE 3000

CMD ["node", "src/server.js"]
