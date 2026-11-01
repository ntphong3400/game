// Keep Flutter's generated asset cache and add navigation fallback for clean
// URLs. Without this, reloading /harem/... offline would bypass that cache.
importScripts(`flutter_service_worker.js${new URL(self.location.href).search}`);

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET' || event.request.mode !== 'navigate') return;
  const scope = self.registration.scope;
  const url = new URL(event.request.url);
  if (!url.href.startsWith(scope)) return;
  let key = url.href.slice(scope.length);
  if (key.includes('?v=')) key = key.split('?v=')[0];
  // The generated worker already owns these requests; respondWith is one-shot.
  if (key === '' || RESOURCES[key]) return;

  event.respondWith(fetch(event.request).catch(async () => {
    const cache = await caches.open(CACHE_NAME);
    const shell = await cache.match(new URL('index.html', scope).href);
    if (shell) return shell;
    throw new Error('The game has not been cached for offline navigation yet.');
  }));
});
