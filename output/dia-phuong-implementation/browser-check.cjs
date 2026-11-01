const {chromium}=require('/Users/phongnguyen/.npm/_npx/e41f203b7505f1fb/node_modules/playwright');
const fs=require('node:fs');
const path=require('node:path');
(async()=>{
  const browser=await chromium.launch({headless:true,executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'});
  const page=await browser.newPage({viewport:{width:1440,height:900}});
  const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto('http://127.0.0.1:4173');
  await page.locator('flt-semantics-placeholder').waitFor();
  await page.locator('flt-semantics-placeholder').evaluate(el=>el.click());
  await page.getByRole('button',{name:'Bắt đầu trị vì →',exact:true}).click();
  await page.locator('input').fill('Kiểm tra Địa phương');
  await page.getByRole('button',{name:'Nhận ngọc tỷ',exact:true}).click();
  await page.getByText('Địa phương',{exact:true}).waitFor();
  await page.getByText('Địa phương',{exact:true}).click();
  await page.getByText('ĐỊA PHƯƠNG',{exact:true}).waitFor();
  await page.waitForTimeout(500);
  await page.screenshot({path:path.join(__dirname,'browser-locality.png')});
  for(const [name,title] of [
    ['Phủ nha','Phủ nha · Điều hành địa phương'],
    ['Đồng ruộng','Đồng ruộng · Nông nghiệp'],
    ['Đê điều','Đê điều · Trị thủy'],
    ['Kho lương','Kho lương · Lương thực & Cứu tế'],
    ['Chợ quê','Chợ quê · Thương chính'],
    ['Thôn làng','Thôn làng · Dân cư & Lao động'],
  ]){
    await page.getByRole('button',{name:new RegExp('^'+name+'(?: \\d+)?$')}).click();
    await page.getByText(title,{exact:true}).waitFor();
    if(!(await page.locator('body').innerText()).includes('12 hành động còn lại'))throw new Error('Navigation changed action count');
    if(name==='Phủ nha'){
      await page.waitForTimeout(350);
      await page.screenshot({path:path.join(__dirname,'browser-administration.png')});
      await page.getByRole('button',{name:'Đến Phủ Bá Quan',exact:true}).click();
      await page.getByText('Những người bên ngai vàng',{exact:true}).waitFor();
      await page.getByRole('button',{name:'Về Phủ nha',exact:true}).click();
      await page.getByText(title,{exact:true}).waitFor();
    }
    await page.getByRole('button',{name:'Về Địa phương',exact:true}).click();
    await page.getByText('ĐỊA PHƯƠNG',{exact:true}).waitFor();
    console.log('PASS',title);
  }
  await page.getByRole('button',{name:'Giang Sơn',exact:true}).click();
  await page.getByText('GIANG SƠN',{exact:true}).waitFor();
  if(errors.length)throw new Error(errors.join('\n'));
  console.log('PASS: Giang Sơn return; 12 actions preserved; no browser errors');
  fs.writeFileSync(path.join(__dirname,'browser-check.log'),'All six destinations and return routes passed. Phủ Bá Quan return passed. 12 actions preserved. No browser errors.\n');
  await browser.close();
})().catch(e=>{console.error(e);process.exit(1);});
