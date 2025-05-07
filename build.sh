#!/bin/bash

# Install dependencies
npm ci

# Build the application
NODE_ENV=production npm run build

# Start the application
npm start 