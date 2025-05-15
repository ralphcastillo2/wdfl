#!/bin/bash
set -e

# Install dependencies
yarn install --frozen-lockfile

# Create .env.local file
echo "MONGODB_URI=mongodb+srv://dbdirectory1:sWC80Q8x21BrkqGi@cluster0.dsxjw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" > .env.local
echo "NODE_ENV=production" >> .env.local
echo "GOOGLE_PLACES_API_KEY=your_google_places_api_key_here" >> .env.local

# Build the application
yarn build

# Start the application
yarn start 