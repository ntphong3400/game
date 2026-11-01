import assert from 'node:assert/strict';
import { writeFile } from 'node:fs/promises';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.ROUTING_BASE || 'http://127.0.0.1:4173';
const out = new URL('./context-hud/', import.meta.url).pathname;
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await context.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.stack));
page.on('console', message => { if (message.type() === 'error') errors.push(message.text()); });
async function ready() {
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached' });
  await placeholder.evaluate(element => element.click());
  await page.getByRole('button').first().waitFor();
}
async function open(path) {
  assert.equal((await page.goto(base + path)).status(), 200);
  await ready();
}
async function archive() {
  return page.evaluate(async () => {
    const db = await new Promise((resolve, reject) => {
      const request = indexedDB.open('van-tue-mvp');
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
    try {
      return await new Promise((resolve, reject) => {
        const request = db.transaction('archive').objectStore('archive').get('current');
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
      });
    } finally { db.close(); }
  });
}
const all = ['Ngân khố', 'Số dân', 'Lương thực', 'Quân lực', 'Lòng dân', 'Uy quyền', 'Sức khỏe', 'Ổn định triều đình'];
const screens = {
  '/citadel': all,
  '/capital': ['Ngân khố', 'Uy quyền', 'Ổn định triều đình'],
  '/court': ['Ngân khố', 'Lòng dân', 'Uy quyền', 'Ổn định triều đình'],
  '/treasury': ['Ngân khố', 'Lương thực'],
  '/people': ['Ngân khố', 'Uy quyền', 'Ổn định triều đình'],
  '/harem': ['Ngân khố', 'Lương thực', 'Ổn định triều đình'],
  '/health': ['Ngân khố', 'Sức khỏe'],
  '/journal': [], '/scores': [],
  '/population': ['Số dân', 'Lương thực', 'Lòng dân'],
  '/military': ['Ngân khố', 'Lương thực', 'Quân lực'],
  '/locality': ['Ngân khố', 'Số dân', 'Lương thực', 'Lòng dân'],
  '/locality/agriculture': ['Ngân khố', 'Lương thực'],
  '/locality/village': ['Số dân', 'Lương thực', 'Lòng dân'],
  '/frontier/north': ['Ngân khố', 'Lương thực', 'Quân lực'],
  '/country/north': ['Ngân khố', 'Quân lực', 'Uy quyền'],
};
async function counters() {
  return (await page.getByRole('button').allTextContents())
    .filter(text => text.includes('Nhấn để xem chi tiết'))
    .map(text => text.split(':')[0]);
}
const results = [];
try {
  await open('/');
  await page.getByRole('button', { name: 'Bắt đầu trị vì   →', exact: true }).click();
  await page.getByRole('textbox').fill('Thiên Hòa');
  await page.getByRole('button', { name: 'Nhận ngọc tỷ', exact: true }).click();
  await page.waitForURL('**/citadel');
  const original = await archive();
  const state = JSON.parse(original).active;
  const minister = state.court.find(person => person.id === 'war-minister');
  const lan = state.court.find(person => person.id === 'consort_lan');
  for (const viewport of [{ width: 1440, height: 900 }, { width: 390, height: 844 }]) {
    await page.setViewportSize(viewport);
    const label = viewport.width > 1000 ? 'desktop' : 'mobile';
    for (const [path, expected] of Object.entries(screens)) {
      await open(path);
      assert.deepEqual(await counters(), expected, `${label} ${path}`);
      assert.equal(await page.getByRole('button', { name: 'Mở danh mục', exact: true }).count(), 0);
      if (['/citadel', '/court', '/treasury', '/harem'].includes(path)) {
        await page.waitForLoadState('networkidle');
        await page.screenshot({ path: `${out}${label}-${path.slice(1)}.png` });
      }
    }
    for (const [section, person] of [['people', minister], ['harem', lan]]) {
      await open(`/${section}/meet/${person.publicId}`);
      assert.deepEqual(await counters(), []);
      const back = page.getByRole('button', { name: section === 'people' ? 'Về Triều thần' : 'Về Hậu cung', exact: true });
      await back.waitFor();
      if (section === 'people') {
        await page.waitForLoadState('networkidle');
        await page.screenshot({ path: `${out}${label}-character.png` });
      }
      await back.click();
      await page.waitForURL(url => url.pathname === `/${section}`);
      assert.equal(await page.getByRole('button', { name: 'Về Kinh Thành', exact: true }).count(), 1);
    }
    await open('/treasury');
    await page.getByRole('button', { name: 'Về Kinh Thành', exact: true }).click();
    await page.waitForURL('**/capital');
    await page.getByRole('button', { name: 'Điện Vĩnh An', exact: false }).click();
    await page.waitForURL('**/court');
    await page.getByRole('button', { name: 'Quốc sự', exact: true }).click();
    await page.waitForURL('**/kingdom');
    await page.getByRole('button', { name: 'Về Triều chính', exact: true }).click();
    await page.waitForURL('**/court');
    results.push(`${label}: 16 contextual headers, no left menu, character HUD hidden, existing back buttons and affairs entrance work`);
  }
  assert.equal(await archive(), original, 'Viewing screens and using back buttons must preserve the save');
  assert.deepEqual(errors, []);
  results.push('IndexedDB archive unchanged; no browser runtime or console errors');
  await writeFile(`${out}results.json`, JSON.stringify({ results, errors }, null, 2));
  console.log(JSON.stringify({ results, errors }, null, 2));
} catch (error) {
  console.log('FAILED AT', page.url(), error.stack);
  console.log('COUNTERS', await counters());
  console.log('ERRORS', errors);
  await page.screenshot({ path: `${out}failure.png` });
  throw error;
} finally { await browser.close(); }
