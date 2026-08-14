import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';

const root = process.cwd();
const types = {'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.png':'image/png','.jpg':'image/jpeg','.jpeg':'image/jpeg','.gif':'image/gif','.mp4':'video/mp4','.webmanifest':'application/manifest+json'};

createServer(async (req,res)=>{
  try {
    const requested = decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    let file = normalize(join(root, requested === '/' ? 'index.html' : requested));
    if (!file.startsWith(root)) throw new Error('Invalid path');
    if ((await stat(file)).isDirectory()) file=join(file,'index.html');
    const body=await readFile(file);
    res.writeHead(200,{'Content-Type':types[extname(file)]||'application/octet-stream','Cache-Control':'no-cache'});
    res.end(body);
  } catch { res.writeHead(404); res.end('Not found'); }
}).listen(4173,'0.0.0.0',()=>console.log('Flapverse running on port 4173'));
