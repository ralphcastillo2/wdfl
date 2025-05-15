FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application
COPY . .

# Create .env.local file
RUN echo "MONGODB_URI=mongodb+srv://dbdirectory1:sWC80Q8x21BrkqGi@cluster0.dsxjw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" > .env.local && \
    echo "NODE_ENV=production" >> .env.local && \
    echo "GOOGLE_PLACES_API_KEY=your_google_places_api_key_here" >> .env.local

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN yarn build

# Expose the port
EXPOSE 3000

# Start the application
CMD ["yarn", "start"] 