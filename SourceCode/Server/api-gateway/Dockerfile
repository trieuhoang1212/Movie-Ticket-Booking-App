# Build TypeScript
FROM node:20.19.5-slim AS builder

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

RUN npm ci

COPY src ./src

RUN npm run build

# Production stage
FROM node:20.19.5-slim

WORKDIR /app

# Copy package files and install production deps
COPY package*.json ./
RUN npm ci --only=production

# Copy built JavaScript from builder
COPY --from=builder /app/dist ./dist

# Create non-root user
RUN groupadd -r nodejs && useradd -r -g nodejs nodejs && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

CMD ["node", "dist/gateway.js"]