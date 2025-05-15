# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies with cleanup
RUN yarn install --frozen-lockfile && \
    yarn cache clean

# Copy the rest of the application
COPY . .

# Create .env.local file
RUN echo "MONGODB_URI=mongodb+srv://dbdirectory1:sWC80Q8x21BrkqGi@cluster0.dsxjw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" > .env.local && \
    echo "NODE_ENV=production" >> .env.local && \
    echo "GOOGLE_PLACES_API_KEY=your_google_places_api_key_here" >> .env.local

# Build the application
RUN yarn build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Copy necessary files from builder
COPY --from=builder /app/package.json /app/yarn.lock ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.env.local ./.env.local

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Clean up
RUN yarn cache clean && \
    rm -rf /tmp/*

# Expose the port
EXPOSE 3000

# Start the application
CMD ["yarn", "start"] 