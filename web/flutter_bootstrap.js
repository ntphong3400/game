{{flutter_js}}
{{flutter_build_config}}

const gameServiceWorkerVersion = {{flutter_service_worker_version}};
_flutter.loader.load({
  serviceWorkerSettings: gameServiceWorkerVersion == null ? undefined : {
    serviceWorkerVersion: gameServiceWorkerVersion,
    serviceWorkerUrl: new URL(
      `game_service_worker.js?v=${gameServiceWorkerVersion}`,
      document.baseURI,
    ).toString(),
  },
});
