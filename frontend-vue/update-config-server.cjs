// 此文件请重命名为 update-config-server.cjs 并用 node update-config-server.cjs 启动
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3001;
const CONFIG_PATH = path.join(__dirname, 'src', 'config.js');
const TOKEN_ABI_PATH = path.join(__dirname, 'src', 'abi', 'Token.json');
const PAIR_ABI_PATH = path.join(__dirname, 'src', 'abi', 'UniswapPair.json');

function getAbi(jsonPath) {
  try {
    const raw = fs.readFileSync(jsonPath, 'utf-8');
    const obj = JSON.parse(raw);
    return JSON.stringify(obj.abi, null, 2);
  } catch (e) {
    return '[]';
  }
}

const server = http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/__update_config') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const { tokenA, tokenB, pair } = JSON.parse(body);
        const tokenAbi = getAbi(TOKEN_ABI_PATH);
        const pairAbi = getAbi(PAIR_ABI_PATH);
        const content = `// 自动生成的合约地址和ABI配置\nexport const pairAddress = "${pair}";\nexport const tokenAAddress = "${tokenA}";\nexport const tokenBAddress = "${tokenB}";\nexport const pairAbi = ${pairAbi};\nexport const tokenAbi = ${tokenAbi};\n`;
        fs.writeFileSync(CONFIG_PATH, content, 'utf-8');
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
      } catch (e) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: e.message }));
      }
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(PORT, () => {
  console.log(`Update config server running at http://localhost:${PORT}`);
}); 