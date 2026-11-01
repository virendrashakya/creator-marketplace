/* eslint-disable no-undef */
importScripts("https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js");

if (workbox) {
  workbox.core.skipWaiting();
  workbox.core.clientsClaim();

  // Cache unlocked media sets (photos/videos) for offline viewing
  workbox.routing.registerRoute(
    ({ url }) => url.pathname.includes("/media") || url.pathname.includes("/preview"),
    new workbox.strategies.NetworkFirst({
      cacheName: "wf-unlocks-v1",
      plugins: [
        new workbox.expiration.ExpirationPlugin({
          maxEntries: 200,
          maxAgeSeconds: 30 * 24 * 60 * 60 // 30 days
        }),
        new workbox.cacheableResponse.CacheableResponsePlugin({
          statuses: [0, 200]
        })
      ]
    })
  );

  // Cache API endpoints (Feed, Discover, Profiles)
  workbox.routing.registerRoute(
    ({ url }) => url.pathname.startsWith("/api/v1/"),
    new workbox.strategies.NetworkFirst({
      cacheName: "wf-api-v1",
      plugins: [
        new workbox.expiration.ExpirationPlugin({
          maxEntries: 100,
          maxAgeSeconds: 5 * 60 // 5 minutes fresh
        }),
        new workbox.cacheableResponse.CacheableResponsePlugin({
          statuses: [0, 200]
        })
      ]
    })
  );

  // Cache static assets (fonts, icons, public images) - never intercept _next scripts
  workbox.routing.registerRoute(
    ({ request, url }) =>
      (request.destination === "font" ||
       request.destination === "image" ||
       url.pathname.startsWith("/icons/")) &&
      !url.pathname.includes("/_next/"),
    new workbox.strategies.StaleWhileRevalidate({
      cacheName: "wf-static-v2",
      plugins: [
        new workbox.expiration.ExpirationPlugin({
          maxEntries: 150,
          maxAgeSeconds: 30 * 24 * 60 * 60
        })
      ]
    })
  );

  // Default network first for navigation requests
  workbox.routing.registerRoute(
    ({ request }) => request.mode === "navigate",
    new workbox.strategies.NetworkFirst({
      cacheName: "wf-pages-v1",
      networkTimeoutSeconds: 3
    })
  );
}

// Push notification handling
self.addEventListener("push", (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (e) {
    data = { title: "Wishful", body: event.data ? event.data.text() : "New update from a creator!" };
  }

  const title = data.title || "Wishful";
  const options = {
    body: data.body || "Your unlock or message has arrived.",
    icon: "/icons/icon-192.png",
    badge: "/icons/icon-192.png",
    vibrate: [100, 50, 100],
    data: {
      url: data.url || "/unlocks"
    }
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const url = event.notification.data?.url || "/unlocks";

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes(url) && "focus" in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(url);
      }
    })
  );
});
