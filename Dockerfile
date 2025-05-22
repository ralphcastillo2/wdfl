# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Set platform-specific environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_SHARP_PATH=/app/node_modules/sharp
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Add build argument
ARG NEXT_PUBLIC_GOOGLE_PLACES_API_KEY
ENV NEXT_PUBLIC_GOOGLE_PLACES_API_KEY=${NEXT_PUBLIC_GOOGLE_PLACES_API_KEY}

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

# Build the application with increased memory and CPU usage
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
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Add build argument again for production stage
ARG NEXT_PUBLIC_GOOGLE_PLACES_API_KEY
ENV NEXT_PUBLIC_GOOGLE_PLACES_API_KEY=${NEXT_PUBLIC_GOOGLE_PLACES_API_KEY}

# Install curl for healthcheck
RUN apk add --no-cache curl && \
    rm -rf /tmp/* && \
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

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["npm", "start"] 