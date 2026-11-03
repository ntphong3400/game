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

test('MP3 responses support browser metadata and byte-range buffering', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'king-audio-'));
  const server = createStaticServer(directory);
  try {
    await writeFile(join(directory, 'background.mp3'), Buffer.from('0123456789'));
    server.listen(0, '127.0.0.1');
    await once(server, 'listening');
    const url = `http://127.0.0.1:${server.address().port}/background.mp3`;
    const full = await fetch(url);
    assert.equal(full.headers.get('content-type'), 'audio/mpeg');
    assert.equal(full.headers.get('content-length'), '10');
    assert.equal(full.headers.get('accept-ranges'), 'bytes');
    assert.equal(await full.text(), '0123456789');
    for (const [range, expected, contentRange] of [
      ['bytes=0-2', '012', 'bytes 0-2/10'],
      ['bytes=7-', '789', 'bytes 7-9/10'],
      ['bytes=-2', '89', 'bytes 8-9/10'],
      ['bytes=8-100', '89', 'bytes 8-9/10'],
    ]) {
      const result = await fetch(url, { headers: { Range: range } });
      assert.equal(result.status, 206, range);
      assert.equal(result.headers.get('content-range'), contentRange);
      assert.equal(await result.text(), expected);
    }
    for (const range of ['bytes=10-', 'bytes=3-1', 'bytes=-0', 'bytes=-']) {
      const result = await fetch(url, { headers: { Range: range } });
      assert.equal(result.status, 416, range);
      assert.equal(result.headers.get('content-range'), 'bytes */10');
    }
    const head = await fetch(url, { method: 'HEAD', headers: { Range: 'bytes=2-4' } });
    assert.equal(head.status, 206);
    assert.equal(head.headers.get('content-length'), '3');
    assert.equal(await head.text(), '');
  } finally {
    await new Promise(resolve => server.close(resolve));
    await rm(directory, { recursive: true });
  }
});
