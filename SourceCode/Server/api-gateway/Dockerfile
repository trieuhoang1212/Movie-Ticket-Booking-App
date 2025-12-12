# ============================
# Build Stage
# ============================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY src ./src

RUN npm run build


# ============================
# Production Stage
# ============================
FROM node:20-alpine

WORKDIR /app

# Copy package files and install production deps
COPY package*.json ./
RUN npm ci --only=production

# Copy built JavaScript from builder
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

CMD ["node", "dist/gateway.js"]