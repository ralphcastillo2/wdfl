#!/bin/bash

# Build the Docker image
docker build -t weddingdirectoryflorida .
 
# Run the container
docker run -d -p 3000:3000 \
  -e MONGODB_URI="$MONGODB_URI" \
  -e NODE_ENV="production" \
  weddingdirectoryflorida 