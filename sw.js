const CACHE='flapverse-v4';
const FILES=['./','./index.html','./styles.css','./ui-fixes.css','./app.js','./assets/Metro_city/MetroCity-poster.jpg','./assets/Logo.png','./assets/neon-bird-cutout.png','./assets/Bird.gif','./assets/flying-bird-3d-flap.png','./assets/Characters/Ember.png','./assets/Characters/Byte.png','./assets/Characters/Nox.png','./assets/Characters/UFO.png','./assets/Characters/Rocket.png'];
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(FILES)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET')return;
  event.respondWith(caches.match(event.request).then(cached=>cached||fetch(event.request).then(response=>{
    if(response.ok&&new URL(event.request.url).origin===location.origin){const copy=response.clone();caches.open(CACHE).then(cache=>cache.put(event.request,copy))}
    return response;
  })));
});
