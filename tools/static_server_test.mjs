import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { once } from 'node:events';
import { createStaticServer } from './static_server.mjs';

test('deep links bootstrap the app; missing assets keep their 404', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'king-routing-'));
  const server = createStaticServer(directory);
  try {
    await writeFile(join(directory, 'index.html'), '<html>game</html>');
    await writeFile(join(directory, 'main.dart.js'), 'app();');
    server.listen(0, '127.0.0.1');
    await once(server, 'listening');
    const base = `http://127.0.0.1:${server.address().port}`;
    for (const path of ['/', '/citadel', '/locality/granary',
      '/people/meet/treasurer', '/country/north/embassy', '/unknown']) {
      const result = await fetch(base + path);
      assert.equal(result.status, 200, path);
      assert.match(result.headers.get('content-type'), /text\/html/);
      assert.equal(await result.text(), '<html>game</html>');
    }
    const script = await fetch(base + '/main.dart.js');
    assert.match(script.headers.get('content-type'), /javascript/);
    assert.equal(await script.text(), 'app();');
    for (const path of ['/missing.js', '/assets/missing.webp', '/assets/missing.json',
      '/assets/missing', '/canvaskit/missing']) {
      assert.equal((await fetch(base + path)).status, 404, path);
    }
    const head = await fetch(base + '/harem/meet/consort_lan', { method: 'HEAD' });
    assert.equal(head.status, 200);
    assert.equal(await head.text(), '');
    assert.equal((await fetch(base, { method: 'POST' })).status, 405);
  } finally {
    await new Promise(resolve => server.close(resolve));
    await rm(directory, { recursive: true });
  }
});
