# --- Build Stage ---
FROM node:18-alpine AS builder

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS="--max-old-space-size=3072"

# Add API key for build
ARG NEXT_PUBLIC_GOOGLE_PLACES_API_KEY
ENV NEXT_PUBLIC_GOOGLE_PLACES_API_KEY=${NEXT_PUBLIC_GOOGLE_PLACES_API_KEY}

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the app source code
COPY . .

# Build the Next.js app
RUN npm run build

# --- Production Runner Stage ---
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS="--max-old-space-size=3072"

# Install curl for health check
RUN apk add --no-cache curl

# Copy the standalone app output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Healthcheck hitting /api/health
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Expose port and start
EXPOSE 3000

CMD ["node", "server.js"] 