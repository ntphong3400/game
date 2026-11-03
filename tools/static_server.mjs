import { createServer } from 'node:http';
import { stat, readFile } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';

const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'application/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.webp': 'image/webp', '.ttf': 'font/ttf', '.woff2': 'font/woff2',
  '.mp3': 'audio/mpeg',
};

export function createStaticServer(directory) {
  const root = resolve(directory);
  return createServer(async (req, res) => {
    if (!['GET', 'HEAD'].includes(req.method)) {
      res.writeHead(405, { Allow: 'GET, HEAD' }).end();
      return;
    }
    try {
      const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
      let file = resolve(root, `.${pathname}`);
      if (file !== root && !file.startsWith(root + sep)) {
        res.writeHead(403).end();
        return;
      }
      try {
        if ((await stat(file)).isDirectory()) file = resolve(file, 'index.html');
      } catch (error) {
        // Browser navigation must bootstrap Flutter at any game URL. Missing
        // assets still return 404, rather than HTML disguised as JS or an image.
        if (!['ENOENT', 'ENOTDIR'].includes(error.code) || extname(pathname) ||
            /^\/(assets|canvaskit|icons)(\/|$)/.test(pathname)) throw error;
        file = resolve(root, 'index.html');
      }
      const content = await readFile(file);
      const headers = {
        'Content-Type': types[extname(file)] || 'application/octet-stream',
        'Content-Length': content.length,
        'Cache-Control': 'no-cache',
        'Accept-Ranges': 'bytes',
      };
      // Browsers use byte ranges to determine MP3 duration and buffer audio.
      if (req.headers.range) {
        const match = /^bytes=(\d*)-(\d*)$/.exec(req.headers.range);
        let start = 0, end = content.length - 1;
        if (match?.[1]) {
          start = Number(match[1]);
          if (match[2]) end = Math.min(Number(match[2]), end);
        } else if (match?.[2]) {
          start = Math.max(0, content.length - Number(match[2]));
        }
        if (!match || (!match[1] && !match[2]) ||
            start > end || start >= content.length ||
            !Number.isSafeInteger(start) || !Number.isSafeInteger(end)) {
          res.writeHead(416, { 'Content-Range': `bytes */${content.length}` }).end();
          return;
        }
        res.writeHead(206, {
          ...headers,
          'Content-Length': end - start + 1,
          'Content-Range': `bytes ${start}-${end}/${content.length}`,
        });
        res.end(req.method === 'HEAD' ? undefined : content.subarray(start, end + 1));
        return;
      }
      res.writeHead(200, headers);
      res.end(req.method === 'HEAD' ? undefined : content);
    } catch {
      res.writeHead(404).end('Not found');
    }
  });
}
