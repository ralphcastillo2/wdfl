# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Set platform-specific environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV NEXT_SHARP_PATH=/app/node_modules/sharp

# Add build arguments
ARG GOOGLE_PLACES_API_KEY
ENV GOOGLE_PLACES_API_KEY=$GOOGLE_PLACES_API_KEY

# Clean up any existing files and caches
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with aggressive cleanup
RUN npm ci --no-optional && \
    npm cache clean --force && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy the rest of the application
COPY . .

# Create .env.local file with environment variables
RUN echo "MONGODB_URI=mongodb+srv://dbdirectory1:sWC80Q8x21BrkqGi@cluster0.dsxjw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" > .env.local && \
    echo "NODE_ENV=production" >> .env.local && \
    echo "GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY}" >> .env.local

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

# Add build arguments
ARG GOOGLE_PLACES_API_KEY
ENV GOOGLE_PLACES_API_KEY=$GOOGLE_PLACES_API_KEY

# Clean up any existing files and caches
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Copy necessary files from builder
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.env.local ./.env.local

# Clean up
RUN npm cache clean --force && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/share/.cache/npm

# Expose the port
EXPOSE 3000

# Start the application
CMD ["npm", "start"] 