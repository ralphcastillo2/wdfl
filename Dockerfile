FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Copy build script
COPY build.sh ./

# Make build script executable
RUN chmod +x build.sh

# Run build script
RUN ./build.sh

# Expose the port
EXPOSE 3000

# Start the application
CMD ["yarn", "start"] 