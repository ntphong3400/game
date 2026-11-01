'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "b37dd989604691a7d90b01b8dd71c0f6",
"version.json": "3656f2f96f36c11a75e53a0051b8200e",
"index.html": "d274f8e5358cb103be90e301c94ce897",
"/": "d274f8e5358cb103be90e301c94ce897",
"crest.svg": "6d2d3bc55b42a5f57c40364e9bbb54a1",
"main.dart.js": "939cdceea2059220f13bdbce39bbe337",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "113239e3ef61c90ed936b1226ab32cc5",
"assets/AssetManifest.json": "9c4052aa84ef094eccce8c3156f27586",
"assets/NOTICES": "73040c77a9812a972a162584380b2b92",
"assets/FontManifest.json": "944e5f3fcc84d9cfc4420eaca42cb889",
"assets/AssetManifest.bin.json": "4b48157aaec913017c75b08e257a33f1",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "9a6efaa7c6443973092714ca4b5c44cb",
"assets/fonts/MaterialIcons-Regular.otf": "3afdab5deac4f42e7d6e03dd381c942a",
"assets/assets/images/harem-room.webp": "8f0f5374753bf1c4da7f5e8c43441c8e",
"assets/assets/images/court-room.webp": "573494dd9a4776913dbc6cdda548fb6b",
"assets/assets/images/treasury-objects.webp": "274abc965477a0fafd472b60688c34a9",
"assets/assets/images/kingdom-room.webp": "9aa0c7dfe30da23e7cb3f808b4b6999c",
"assets/assets/images/health-room.webp": "3fcbe48930a2937e55f18b8260732259",
"assets/assets/images/harem-interior.webp": "fb44b0006999b9ae1675e53c6c5f385a",
"assets/assets/images/treasury-interior.webp": "a935b939b462927e2fc8757adbd3bafa",
"assets/assets/images/scores-room.webp": "de208b20818930d7a83775f1fd801bee",
"assets/assets/images/portraits/official-008.webp": "2fc88773a92ff53ef7a7d48290b24869",
"assets/assets/images/portraits/official-049.webp": "1c6ed8ab32ab9bcdef66fb05f223fb4f",
"assets/assets/images/portraits/harem-029.webp": "efbe6bcff4c968f73142683aded3b04c",
"assets/assets/images/portraits/official-032.webp": "7475a3778f37766f4215ea9f816dd59d",
"assets/assets/images/portraits/harem-005.webp": "3e121015619629dc2c1eae7ac414d1ae",
"assets/assets/images/portraits/harem-013.webp": "6a2ebb81be6707dc026e376dd5a49f5b",
"assets/assets/images/portraits/official-024.webp": "ef1805063966005f68918470fa94c011",
"assets/assets/images/portraits/official-053.webp": "c6251f7d02578bf008c2def65a384def",
"assets/assets/images/portraits/official-004.webp": "f591a39a75600d49b04dc8d815324bda",
"assets/assets/images/portraits/official-012.webp": "5a8fd384358e370117a2e4244f5b694c",
"assets/assets/images/portraits/harem-025.webp": "2155e1ee09285e5a985f9bb8ec4278b8",
"assets/assets/images/portraits/official-045.webp": "5fd8cbd921daa10c976a8de7bfbb2710",
"assets/assets/images/portraits/harem-009.webp": "11a707b2c2e5696c4dc07a518d6b77d2",
"assets/assets/images/portraits/official-028.webp": "e00faf8b14837d54b6e96bc033346d3f",
"assets/assets/images/portraits/official-029.webp": "f8c5ba5f2c0bd58d7a8a84fd85e93d81",
"assets/assets/images/portraits/harem-008.webp": "ac7192462280c3dedbb11703124b197f",
"assets/assets/images/portraits/official-044.webp": "0c8134e745828c79c3f4401d287c5915",
"assets/assets/images/portraits/harem-024.webp": "e5886f3d587258364c12743828e60088",
"assets/assets/images/portraits/official-013.webp": "0fafb726dd2c094eef38d52a0157fcc7",
"assets/assets/images/portraits/official-005.webp": "a10f3dcd7e33099099027d8424acb0d4",
"assets/assets/images/portraits/official-052.webp": "402c4c94330169f405403a9f68dc3b15",
"assets/assets/images/portraits/official-025.webp": "e39b5c3480604749174166f29c75e6b1",
"assets/assets/images/portraits/harem-012.webp": "59b6da78b7d83f628f995b1865321505",
"assets/assets/images/portraits/harem-004.webp": "4ce37e751da4abb457251a312e2c1caf",
"assets/assets/images/portraits/official-033.webp": "6a0cd8918cf295383e314304c3d02aaf",
"assets/assets/images/portraits/harem-028.webp": "fd80bfebecf5bac50f544c2909721060",
"assets/assets/images/portraits/official-048.webp": "faf214e800ff6f1a1e2162130b5d6626",
"assets/assets/images/portraits/official-009.webp": "4a11389d65555c5138330fb8c8b3e3ac",
"assets/assets/images/portraits/official-055.webp": "c4a566a71a79e9d2d19bfcef119a4740",
"assets/assets/images/portraits/official-002.webp": "f3f889662f7d7daa5bec0e2ae2578cec",
"assets/assets/images/portraits/official-014.webp": "11d8eace10ca29b090a177ca418fcc8b",
"assets/assets/images/portraits/harem-023.webp": "60aa7b36fbca684b3116565ada31128b",
"assets/assets/images/portraits/official-043.webp": "773dc1f6ecec347ccbca2d7e11212f07",
"assets/assets/images/portraits/official-038.webp": "eb7da652f99d2022750320370d32f6a7",
"assets/assets/images/portraits/harem-019.webp": "655ad96eb7ed609b7cb920641f9cb7b3",
"assets/assets/images/portraits/official-059.webp": "3d02869b830672ddc06bdb6ee6b6ee76",
"assets/assets/images/portraits/official-018.webp": "f2f7ebf8d3ccb47a13bec41e2401d884",
"assets/assets/images/portraits/official-034.webp": "b1211c50d4e6558f6320f918e97358f7",
"assets/assets/images/portraits/harem-003.webp": "c73ef547db5d038d1d82949b6f3f2d13",
"assets/assets/images/portraits/harem-015.webp": "b5b40039a83273153647650711504606",
"assets/assets/images/portraits/official-022.webp": "73e4b7e5de0f3d3da910df3711a6c6c5",
"assets/assets/images/portraits/official-023.webp": "9d58164c10cd635a228f3610f91c949e",
"assets/assets/images/portraits/harem-014.webp": "dbf8e5e06939d25bf97c0bc268b6faf0",
"assets/assets/images/portraits/harem-002.webp": "488c4ca0efe677d6c610c964a7574bd9",
"assets/assets/images/portraits/official-035.webp": "10d1ec618e4d08f66d1329c7f35a9941",
"assets/assets/images/portraits/official-019.webp": "e59d7318eaaabbb882ae307caeeb0c06",
"assets/assets/images/portraits/official-058.webp": "0037213bcea79e51fe799d11dc7351de",
"assets/assets/images/portraits/harem-018.webp": "44fdb00fdd4078eb09e83789d96f6ec5",
"assets/assets/images/portraits/official-039.webp": "ac56f013d0d3dd003d0905459a790cd6",
"assets/assets/images/portraits/official-042.webp": "2dbb0e44b5efbbf34d6ec0c571cd9d13",
"assets/assets/images/portraits/harem-022.webp": "9a1a75035a96dc8695d6539b51447600",
"assets/assets/images/portraits/official-015.webp": "0bf98e1964b44ffe091748fc7870ec55",
"assets/assets/images/portraits/official-003.webp": "ee7ba882bc3586981fba893ec94578be",
"assets/assets/images/portraits/official-054.webp": "400454d584199a800581d748d4e760bd",
"assets/assets/images/portraits/official-041.webp": "70dc3be586226af074bef0500010ebf6",
"assets/assets/images/portraits/harem-021.webp": "9f6d61ba1f3f98aff1c41bcbd10dfa6b",
"assets/assets/images/portraits/official-016.webp": "be3e8e9b5e8d3c670fb6563eadcb44dd",
"assets/assets/images/portraits/official-057.webp": "a150398fa0cdd9220af8234d07620c48",
"assets/assets/images/portraits/official-020.webp": "5dcf7ad23091dd2ef1a99ddb9ff6c229",
"assets/assets/images/portraits/harem-017.webp": "58fe4bd7d999c94110dbedf27184ea90",
"assets/assets/images/portraits/harem-001.webp": "0715fdb984916e45fe51b135da528fb8",
"assets/assets/images/portraits/official-036.webp": "b749e10e8236ba1efdd4453add333d51",
"assets/assets/images/portraits/official-037.webp": "63fbfc727d441e1d53706e71419d4d3f",
"assets/assets/images/portraits/official-060.webp": "fef655688c2a3cfb7234f17812656bb9",
"assets/assets/images/portraits/harem-016.webp": "bbce3e7fab38ed56affdac2a53508245",
"assets/assets/images/portraits/official-021.webp": "f4061ae0e5332d3e609d41355abed7ff",
"assets/assets/images/portraits/official-056.webp": "89cbac00c7a92603e97436911b017df0",
"assets/assets/images/portraits/official-001.webp": "81d446175b9ec3e71d9facb594d4d6df",
"assets/assets/images/portraits/official-017.webp": "b1a43a510341e2f6db1e0aac8c268311",
"assets/assets/images/portraits/harem-020.webp": "be1402181cef3399aaded1bd8e5f9489",
"assets/assets/images/portraits/official-040.webp": "af3d5e44de3c0d9b2c009014dbe20770",
"assets/assets/images/portraits/official-026.webp": "055240824d923e096f58aef3baf37fd8",
"assets/assets/images/portraits/harem-011.webp": "14dec7ef08cb112bd51e540b581a6f9f",
"assets/assets/images/portraits/harem-007.webp": "1a1744671f95985c6a377cb8169e04b1",
"assets/assets/images/portraits/official-030.webp": "e49d38913f72502f1cbb99089f4777bf",
"assets/assets/images/portraits/official-047.webp": "74579c42884b6f6e2b9ac8adb465f983",
"assets/assets/images/portraits/harem-027.webp": "7a933e6416b228dce91e8907f062e782",
"assets/assets/images/portraits/official-010.webp": "0a6ff88a66bddcf35937fe3fb576bae6",
"assets/assets/images/portraits/official-006.webp": "cdb617df274faf05e94c0b2f93ae35c0",
"assets/assets/images/portraits/official-051.webp": "2efccb1e21fe0354ff158750bb5f6bb9",
"assets/assets/images/portraits/harem-030.webp": "5a39efbf6670be9db96377a94e233807",
"assets/assets/images/portraits/official-050.webp": "f03969bc826534d5a82f4494722ec107",
"assets/assets/images/portraits/official-007.webp": "9e2ab0f59d89e0d28d54004b0d1919cb",
"assets/assets/images/portraits/official-011.webp": "141b88d05f6a89540343d67e844d4660",
"assets/assets/images/portraits/harem-026.webp": "9406fc69c25c96593f787aeb1889b376",
"assets/assets/images/portraits/official-046.webp": "3835ccdab820e7da5aba939a5f824347",
"assets/assets/images/portraits/emperor.webp": "bf199885f2d51e571963e68d398d2184",
"assets/assets/images/portraits/official-031.webp": "8877f6ba0a1e656f30dd6ffb2838f301",
"assets/assets/images/portraits/harem-006.webp": "86d5814949714c17a4e9f81ea0a4bcdc",
"assets/assets/images/portraits/harem-010.webp": "7d67c72616250efe040d6657841fea49",
"assets/assets/images/portraits/official-027.webp": "84c868349c9526a40f9eb001ed80754b",
"assets/assets/images/people-room.webp": "b845afeb32dc6281c1175b4581c1d309",
"assets/assets/images/petitions/river.webp": "c1a060573a1877252a722503847020d6",
"assets/assets/images/petitions/trade.webp": "59915ca1facf5ec0474a01a196be1199",
"assets/assets/images/petitions/agriculture.webp": "47522b64be8557188424657699e85e41",
"assets/assets/images/petitions/palace.webp": "8736457249272e4311b959e6b95dd12e",
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
