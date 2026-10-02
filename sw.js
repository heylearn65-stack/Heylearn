// HeyLearn অফলাইন + অটো-আপডেট।
// index.html ও manifest সবসময় আগে ইন্টারনেট থেকে নতুনটা আনে (না পেলে ক্যাশ থেকে দেখায়)।
// তাই GitHub-এ ফাইল বদলালেই সবার অ্যাপে নিজে থেকে আপডেট আসবে।
const VERSION='heylearn-v6';
const SHELL=['./','index.html','manifest.webmanifest','heyLearn-icon-192.png','heyLearn-icon-512.png'];
self.addEventListener('install',e=>{
  e.waitUntil(caches.open(VERSION).then(c=>Promise.all(SHELL.map(u=>c.add(new Request(u,{cache:'reload'})).catch(()=>{})))));
  self.skipWaiting();
});
self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==VERSION).map(x=>caches.delete(x)))));
  self.clients.claim();
});
self.addEventListener('fetch',e=>{
  const req=e.request;
  if(req.method!=='GET')return;
  if(new URL(req.url).search.indexOf('_=')>-1)return; // আপডেট-চেক ক্যাশে রাখব না
  const sameOrigin=new URL(req.url).origin===location.origin;
  const isPage=req.mode==='navigate'||/\.(html|webmanifest|js)$/.test(new URL(req.url).pathname);
  if(sameOrigin&&isPage){
    // নেটওয়ার্ক আগে, না পেলে ক্যাশ
    e.respondWith(fetch(req,{cache:'no-cache'}).then(r=>{
      if(r.ok){const c=r.clone();caches.open(VERSION).then(ch=>ch.put(req,c))}
      return r}).catch(()=>caches.match(req).then(h=>h||caches.match('index.html'))));
    return;
  }
  // বাকি সব (আইকন, ফন্ট): ক্যাশ আগে
  e.respondWith(caches.match(req).then(hit=>hit||fetch(req).then(r=>{
    if(r.ok&&sameOrigin){const c=r.clone();caches.open(VERSION).then(ch=>ch.put(req,c))}
    return r}).catch(()=>caches.match('index.html'))));
});
