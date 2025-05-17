# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Set platform-specific environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_SHARP_PATH=/app/node_modules/sharp

# Clean up any existing files and caches
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with aggressive cleanup
RUN npm install && \
    npm cache clean --force && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build && \
    npm cache clean --force && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Set platform-specific environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV NEXT_SHARP_PATH=/app/node_modules/sharp

# Clean up any existing files and caches
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy necessary files from builder
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Clean up
RUN npm cache clean --force && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Expose the port
EXPOSE 3000

# Start the application
CMD ["npm", "start"] 