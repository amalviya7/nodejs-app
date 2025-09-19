# Multi-stage build for security
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Production stage
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S app-user -u 1001

# Set working directory
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder --chown=app-user:nodejs /app/node_modules ./node_modules

# Copy app source
COPY --chown=app-user:nodejs . .

# Switch to non-root user
USER app-user

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
CMD node healthcheck.js

# Start app
CMD ["node", "app.js"]
