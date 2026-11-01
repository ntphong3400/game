import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createStaticServer } from './static_server.mjs';

const root = resolve(fileURLToPath(new URL('../build/web/', import.meta.url)));
const port = Number(process.env.PORT || 4173);
createStaticServer(root).listen(port, '127.0.0.1',
  () => console.log(`Vạn Tuế: http://127.0.0.1:${port}`));
