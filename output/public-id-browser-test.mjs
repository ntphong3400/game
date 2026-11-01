const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
import assert from 'node:assert/strict';
import { writeFile } from 'node:fs/promises';
const base=process.env.ROUTING_BASE || 'http://127.0.0.1:4173';
const out=new URL('.', import.meta.url).pathname;
const browser=await chromium.launch({executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:true});
const context=await browser.newContext({viewport:{width:1440,height:1000}});
const page=await context.newPage();
const errors=[];
page.on('pageerror',e=>errors.push(e.stack));
page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
const results=[];
async function ready(){
  await page.locator('flt-semantics-placeholder').waitFor({state:'attached'});
  await page.locator('flt-semantics-placeholder').evaluate(el=>el.click());
  await page.locator('flt-semantics[role=button]').first().waitFor();
}
async function goto(path){
  const response=await page.goto(base+path);assert.equal(response.status(),200,path);
  await ready();
}
async function url(path){await page.waitForURL(u=>u.pathname===path);}
async function archive(){return await page.evaluate(async()=>{
  const db=await new Promise((ok,bad)=>{const r=indexedDB.open('van-tue-mvp');r.onsuccess=()=>ok(r.result);r.onerror=()=>bad(r.error);});
  try{return await new Promise((ok,bad)=>{const r=db.transaction('archive').objectStore('archive').get('current');r.onsuccess=()=>ok(r.result);r.onerror=()=>bad(r.error);});}finally{db.close();}
});}
try {
  await goto('/harem/meet/consort_lan');
  assert.equal(new URL(page.url()).pathname,'/');
  assert.equal(new URL(page.url()).searchParams.get('continue'),'/harem/meet/consort_lan');
  await page.getByRole('button',{name:'Bắt đầu trị vì   →',exact:true}).click();
  await page.getByRole('textbox').fill('QA Routing');
  await page.getByRole('button',{name:'Nhận ngọc tỷ',exact:true}).click();
  await page.waitForURL(u=>/^\/harem\/meet\/[0-9a-f-]{36}$/.test(u.pathname));
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  results.push('No save -> intro -> start -> requested character');
  const original=await archive();assert.ok(original);
  const active=JSON.parse(original).active;
  const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
  const all=[...active.court,...active.officialsPool];
  assert.ok(all.every(p=>uuid.test(p.publicId)));
  const lanPath='/harem/meet/'+active.court.find(p=>p.id==='consort_lan').publicId;
  const ministerPath='/people/meet/'+active.court.find(p=>p.id==='war-minister').publicId;
  assert.equal(new URL(page.url()).pathname,lanPath);
  for(const [alias,canonical] of [['/people/meet/war-minister',ministerPath],['/harem/meet/consort_lan',lanPath]]){
    await goto('/journal');
    const length=await page.evaluate(()=>history.length);
    await goto(alias);await url(canonical);
    assert.equal(await page.evaluate(()=>history.length),length+1,'Alias must replace its own history entry');
    await page.goBack();await url('/journal');
    await page.goForward();await url(canonical);
  }
  results.push('Court and harem aliases redirect to persisted UUIDs without an extra browser history entry');
  await goto('/?v=routing-qa');
  await page.getByRole('button',{name:/Tiếp tục ·/}).waitFor();
  await goto('/');
  await page.getByRole('button',{name:/Tiếp tục ·/}).click();
  await url('/citadel');
  await page.evaluate(()=>window.__routingProbe='same-document');
  await page.getByRole('button',{name:/^Kinh thành/}).click();
  await url('/capital');
  
  await page.getByRole('button',{name:/Cung Ngọc Hoa/}).click();
  await url('/harem');
  
  await page.getByRole('button',{name:'Gặp gỡ',exact:true}).first().click();
  await page.waitForURL(u=>/^\/harem\/meet\//.test(u.pathname));
  const meetingPath=new URL(page.url()).pathname;
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  await page.goBack();await url('/harem');
  await page.getByRole('button',{name:'Gặp gỡ',exact:true}).first().waitFor();
  await page.goBack();await url('/capital');
  await page.getByRole('button',{name:/Cung Ngọc Hoa/}).waitFor();
  await page.goForward();await url('/harem');
  await page.getByRole('button',{name:'Gặp gỡ',exact:true}).first().waitFor();
  await page.goForward();await url(meetingPath);
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  assert.equal(await page.evaluate(()=>window.__routingProbe),'same-document');
  results.push('In-app navigation + browser Back/Forward preserve the document and correct screens');
  await page.reload();await ready();
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  assert.equal(new URL(page.url()).pathname,meetingPath);
  results.push('Reload restores character URL and page');

  const paths=['/citadel','/capital','/court','/kingdom','/treasury','/population','/military','/people','/people/government','/harem','/harem/management','/health','/journal','/scores','/locality'];
  for(const place of ['administration','agriculture','irrigation','granary','commerce','village'])paths.push('/locality/'+place);
  for(const country of ['north','west','south']){
    paths.push('/country/'+country,'/frontier/'+country);
    for(const place of ['palace','embassy','border'])paths.push('/country/'+country+'/'+place);
    for(const place of ['camp','command','gate'])paths.push('/frontier/'+country+'/'+place);
  }
  for(const path of paths){
    await goto(path);assert.equal(new URL(page.url()).pathname,path);
    assert.equal(await page.getByText('Không tìm thấy trang này.',{exact:true}).count(),0,path);
  }
  results.push(`All ${paths.length} active-game section URLs open directly`);
  await goto('/people/meet/treasurer?from=%2Flocality%2Fadministration');
  await page.getByRole('button',{name:'Về Địa phương',exact:true}).waitFor();
  await page.reload();await ready();
  await page.getByRole('button',{name:'Về Địa phương',exact:true}).click();
  await url('/locality/administration');
  results.push('Regional character origin survives reload');
  await goto('/people/meet/treasurer/');
  await page.getByRole('button',{name:'Về Triều thần',exact:true}).waitFor();
  await goto('/people/meet/nonexistent');await url('/people');
  await goto('/people/meet/consort_lan');await url(lanPath);
  await goto('/#/harem/meet/consort_lan');await url(lanPath);
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  results.push('Missing IDs, wrong roster, and legacy hash bookmarks resolve safely');
  await goto('/not-a-page');
  await page.getByText('Không tìm thấy trang này.',{exact:true}).waitFor();
  await page.getByRole('button',{name:'Về trang giới thiệu',exact:true}).click();await url('/');
  results.push('Unknown URL has a working recovery action');
  await goto('/harem/meet/consort_lan');
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  const worker=await page.evaluate(async()=>{const r=await navigator.serviceWorker.ready;return r.active.scriptURL;});
  assert.match(worker,/game_service_worker/);
  await context.setOffline(true);
  await page.reload();await ready();
  await page.getByRole('button',{name:'Về Hậu cung',exact:true}).waitFor();
  assert.equal(new URL(page.url()).pathname,lanPath);
  await context.setOffline(false);
  results.push('Offline reload restores a previously loaded character path');
  assert.equal(await archive(),original,'Routing must not modify the game archive');
  results.push('IndexedDB game archive remains byte-for-byte unchanged after navigation and reloads');

  function withoutIds(raw){
    const data=JSON.parse(raw);
    for(const p of [...data.active.court,...data.active.officialsPool])delete p.publicId;
    return data;
  }
  const legacy=withoutIds(original);
  await page.evaluate(async data=>{
    const db=await new Promise((ok,bad)=>{const r=indexedDB.open('van-tue-mvp');r.onsuccess=()=>ok(r.result);r.onerror=()=>bad(r.error);});
    try{await new Promise((ok,bad)=>{const tx=db.transaction('archive','readwrite');tx.objectStore('archive').put(JSON.stringify(data),'current');tx.oncomplete=ok;tx.onerror=()=>bad(tx.error);});}finally{db.close();}
  },legacy);
  await goto('/people/meet/war-minister');
  const migrated=await archive();
  assert.deepEqual(withoutIds(migrated),legacy,'Migration must only add public IDs');
  const migratedState=JSON.parse(migrated).active;
  const migratedMinister=migratedState.court.find(p=>p.id==='war-minister').publicId;
  await url('/people/meet/'+migratedMinister);
  assert.ok(uuid.test(migratedMinister));
  await page.reload();await ready();
  assert.equal(await archive(),migrated,'Reload must keep migrated UUIDs');
  results.push('A legacy IndexedDB save migrates once, changes only identity metadata, and retains UUIDs on reload');
  await goto('/');
  await page.getByRole('button',{name:'Bắt đầu trị vì   →',exact:true}).click();
  await page.getByRole('textbox').fill('QA New Reign');
  await page.getByRole('button',{name:'Nhận ngọc tỷ',exact:true}).click();
  await url('/citadel');
  const nextState=JSON.parse(await archive()).active;
  const nextMinister=nextState.court.find(p=>p.id==='war-minister').publicId;
  assert.notEqual(nextMinister,migratedMinister);
  await goto('/people/meet/'+migratedMinister);await url('/people');
  await goto('/people/meet/war-minister');await url('/people/meet/'+nextMinister);
  results.push('A new reign has new UUIDs; an old UUID cannot accidentally open its new officeholder');

  assert.deepEqual(errors,[],'No browser runtime/console errors');
  await writeFile(out+'/public-id-browser-results.json',JSON.stringify({results,errors},null,2));
  console.log(JSON.stringify({results,errors},null,2));
} catch(e) {
  console.log('FAILED AT',page.url(),e.stack);
  console.log('ERRORS',errors);
  console.log('BUTTONS',await page.getByRole('button').allTextContents().catch(()=>[]));
  await page.screenshot({path:out+'/public-id-browser-failure.png'}).catch(()=>{});
  throw e;
} finally {await browser.close();}
