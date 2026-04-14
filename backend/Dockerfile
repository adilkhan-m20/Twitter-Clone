# /backend/Dockerfile

FROM node:20-alpine

WORKDIR /app

# Copy package files and install
COPY package*.json ./
RUN npm install

# Copy backend source code
COPY . .

ENV NODE_ENV=production
ENV PORT=5000

EXPOSE 5000

CMD ["npm", "start"]