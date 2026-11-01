import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  cacheComponents: true,
  partialPrefetching: true,
  async rewrites() {
    return [
      {
        source: '/paid_media_posts/:path*',
        destination: 'http://localhost:3000/paid_media_posts/:path*',
      },
      {
        source: '/rails/:path*',
        destination: 'http://localhost:3000/rails/:path*',
      },
    ];
  },
};

export default nextConfig;
