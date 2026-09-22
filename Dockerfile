# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# Stage 2: Production image
FROM node:20-alpine
WORKDIR /app
# Run as a non-root user (UID 1001), and remove npm/npx since the app
# runs with plain "node" and never needs them at runtime
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
COPY --from=builder --chown=appuser:appgroup /app .
USER appuser
EXPOSE 3000
CMD ["node", "src/server.js"]
