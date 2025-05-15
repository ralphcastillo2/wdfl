#!/bin/bash
set -e

# Install dependencies
yarn install

# Build the application
yarn build

# Start the application
yarn start 