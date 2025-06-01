/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    GOOGLE_PLACES_API_KEY: process.env.NEXT_PUBLIC_GOOGLE_PLACES_API_KEY,
    MONGODB_URI: process.env.MONGODB_URI
  },
};

module.exports = nextConfig;