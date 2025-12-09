# ============================
# Build Stage
# ============================
FROM node:20.19.5-slim AS builder

WORKDIR /app

# Cài thêm build tools khi cần biên dịch native modules
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY src ./src

RUN npm run build


# ============================
# Production Stage
# ============================
FROM node:20.19.5-slim

WORKDIR /app

# Cài curl để dùng cho HEALTHCHECK
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Tạo user non-root TRƯỚC khi cài deps
RUN groupadd -r nodejs && useradd -r -g nodejs nodejs

COPY package*.json ./

# Chuyển sang user non-root để chạy npm → tránh vulnerability "npm as root"
USER nodejs
RUN npm ci --only=production

# Chuyển lại root để copy file
USER root
COPY --from=builder /app/dist ./dist

# Chuyển về user cuối cùng
USER nodejs

EXPOSE 3000

# HEALTHCHECK an toàn hơn, không dùng node -e
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
