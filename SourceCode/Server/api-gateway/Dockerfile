# ============================
# Build Stage
# ============================
FROM node:20-slim AS builder

# 1. Dùng apt-get thay vì apk
RUN apt-get update && apt-get upgrade -y

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY src ./src

RUN npm run build

# ============================
# Production Stage
# ============================
FROM node:20-slim

# 2. Update và cài đặt chứng chỉ bảo mật cần thiết
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends dumb-init && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

# 3. Sử dụng user 'node' có sẵn của image (Khỏi cần tạo mới cho đỡ lỗi)
# Image node đã tạo sẵn user tên là 'node' với uid 1000 rồi.
USER node

EXPOSE 3000

# 4. Healthcheck (không đổi)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

# Dùng dumb-init để quản lý process tốt hơn trong Docker
CMD ["dumb-init", "node", "dist/gateway.js"]