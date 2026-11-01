'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "1391a5a7a19c749df624eccdf6a7dc12",
"version.json": "3656f2f96f36c11a75e53a0051b8200e",
"index.html": "d274f8e5358cb103be90e301c94ce897",
"/": "d274f8e5358cb103be90e301c94ce897",
"crest.svg": "6d2d3bc55b42a5f57c40364e9bbb54a1",
"main.dart.js": "00bd0d759983e5df94fdae5acafe7ee2",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "113239e3ef61c90ed936b1226ab32cc5",
"assets/AssetManifest.json": "efd3d618f6f95560f8de21fd175682c7",
"assets/NOTICES": "73040c77a9812a972a162584380b2b92",
"assets/FontManifest.json": "944e5f3fcc84d9cfc4420eaca42cb889",
"assets/AssetManifest.bin.json": "6b24f0f993c0f3251f75c7e5cd4c08de",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "63b3f6c7447b6bc0e4100e65649c342b",
"assets/fonts/MaterialIcons-Regular.otf": "8364e32f0e0cbb5e6564d95a32708e78",
"assets/assets/images/harem-room.webp": "8f0f5374753bf1c4da7f5e8c43441c8e",
"assets/assets/images/court-room.webp": "573494dd9a4776913dbc6cdda548fb6b",
"assets/assets/images/treasury-objects.webp": "274abc965477a0fafd472b60688c34a9",
"assets/assets/images/kingdom-room.webp": "9aa0c7dfe30da23e7cb3f808b4b6999c",
"assets/assets/images/health-room.webp": "3fcbe48930a2937e55f18b8260732259",
"assets/assets/images/harem-interior.webp": "fb44b0006999b9ae1675e53c6c5f385a",
"assets/assets/images/treasury-interior.webp": "a935b939b462927e2fc8757adbd3bafa",
"assets/assets/images/scores-room.webp": "de208b20818930d7a83775f1fd801bee",
"assets/assets/images/people-room.webp": "b845afeb32dc6281c1175b4581c1d309",
"assets/assets/images/character-portraits.webp": "90bdf5e0bacad7c9811d8dc1233a1902",
"assets/assets/images/journal-room.webp": "e2f36741afc8b8a795d1e528c63b9dbf",
"assets/assets/images/treasury-room.webp": "66c3438f5e68556e7213651f65c3c326",
"assets/assets/images/health-interior.webp": "f250ca6bcf8f2439a7787ccb28447169",
"assets/assets/images/citadel-landscape.webp": "bd1b2dedc01a811c3cb5ea030cb47a81",
"assets/assets/images/court-interior.webp": "f8aa40d1f46d2560ade6981ea62b87ac",
"assets/assets/images/people-interior.webp": "33090b63b2bd98b3a1cfeabd9cb9ab10",
"assets/assets/images/imperial/crimson.webp": "78d585016a36aff41b7a28d7e19c16f4",
"assets/assets/images/imperial/parchment.webp": "348830e39bbee71114133f919803a797",
"assets/assets/images/imperial/panel.webp": "5e3b4b2d61f904174304883222b6c23d",
"assets/assets/images/imperial/jade-texture.webp": "e4fe75317c845930bf08b8ba89f06191",
"assets/assets/images/imperial/icons.webp": "d37ace29b76a76905fd0509db4dffaa3",
"assets/assets/images/imperial/ivory.webp": "c5991531f2b08540763e0b7a8488a4fe",
"assets/assets/images/imperial/jade.webp": "9a4c4edc3e1df004798e1e25056d0a7d",
"assets/assets/fonts/BeVietnamPro-SemiBold.ttf": "fe1a1fd0a99346e9296ca7dd66fb47cd",
"assets/assets/fonts/BeVietnamPro-Regular.ttf": "3f4d46a9b3006f5a3e53774dabf54910",
"assets/assets/fonts/Lora.ttf": "e71368f221227338edf6af09034a5062",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
