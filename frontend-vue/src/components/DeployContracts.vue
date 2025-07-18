<template>
  <div class="deploy-contracts">
    <h2>一键部署合约</h2>
    
    <!-- Token 部署参数 -->
    <div class="deploy-section">
      <h3>Token 部署参数</h3>
      <div class="input-group">
        <div class="input-row">
          <label>TokenA 名称:</label>
          <input v-model="tokenParams.tokenA.name" placeholder="TokenA" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenA 符号:</label>
          <input v-model="tokenParams.tokenA.symbol" placeholder="TKA" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenA 初始供应量:</label>
          <input v-model="tokenParams.tokenA.supply" placeholder="1000000" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenA 精度:</label>
          <input v-model="tokenParams.tokenA.decimals" placeholder="18" class="fancy-input" type="number" min="0" max="18" />
          <span class="help-text">(0-18, 默认18)</span>
        </div>
      </div>
      
      <div class="input-group">
        <div class="input-row">
          <label>TokenB 名称:</label>
          <input v-model="tokenParams.tokenB.name" placeholder="TokenB" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenB 符号:</label>
          <input v-model="tokenParams.tokenB.symbol" placeholder="TKB" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenB 初始供应量:</label>
          <input v-model="tokenParams.tokenB.supply" placeholder="1000000" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>TokenB 精度:</label>
          <input v-model="tokenParams.tokenB.decimals" placeholder="18" class="fancy-input" type="number" min="0" max="18" />
          <span class="help-text">(0-18, 默认18)</span>
        </div>
      </div>
    </div>

    <!-- Pair 部署参数 -->
    <div class="deploy-section">
      <h3>Pair 部署参数</h3>
      <div class="input-group">
        <div class="input-row">
          <label>手续费率 (%):</label>
          <input v-model="pairParams.feeRate" placeholder="0.3" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>最小滑点 (%):</label>
          <input v-model="pairParams.minSlippage" placeholder="1.0" class="fancy-input" />
        </div>
      </div>
    </div>

    <button class="deploy-btn" :disabled="loading" @click="deployContracts">
      {{ loading ? '部署中...' : '部署合约' }}
    </button>
    
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">部署成功！</div>
    
    <div v-if="addresses.tokenA" class="addresses-section">
      <h3>部署结果</h3>
      <div class="address-block">
        <span>TokenA 地址：</span>
        <span class="mono">{{ addresses.tokenA }}</span>
      </div>
      <div class="address-block">
        <span>TokenB 地址：</span>
        <span class="mono">{{ addresses.tokenB }}</span>
      </div>
      <div class="address-block">
        <span>Pair 地址：</span>
        <span class="mono">{{ addresses.pair }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import tokenArtifact from '../abi/Token.json'
import pairArtifact from '../abi/UniswapPair.json'

const loading = ref(false)
const error = ref('')
const success = ref(false)
const addresses = ref({ tokenA: '', tokenB: '', pair: '' })

// Token 部署参数
const tokenParams = ref({
  tokenA: { name: 'TokenA', symbol: 'TKA', supply: '1000000', decimals: '18' },
  tokenB: { name: 'TokenB', symbol: 'TKB', supply: '1000000', decimals: '18' }
})

// Pair 部署参数
const pairParams = ref({
  feeRate: '0.3',
  minSlippage: '1.0'
})

async function deployContracts() {
  error.value = ''
  success.value = false
  loading.value = true
  addresses.value = { tokenA: '', tokenB: '', pair: '' }
  
  try {
    if (!window.ethereum) throw new Error('请先安装并解锁MetaMask')
    await window.ethereum.request({ method: 'eth_requestAccounts' })
    const { ethers } = await import('ethers')
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()

    // 1. 部署 TokenA
    console.log('部署 TokenA:', tokenParams.value.tokenA)
    const TokenFactory = new ethers.ContractFactory(tokenArtifact.abi, tokenArtifact.bytecode, signer)
    const tokenADecimals = parseInt(tokenParams.value.tokenA.decimals)
    const tokenASupply = ethers.parseUnits(tokenParams.value.tokenA.supply, tokenADecimals)
    const tokenA = await TokenFactory.deploy(
      tokenParams.value.tokenA.name,
      tokenParams.value.tokenA.symbol,
      tokenASupply,
      tokenADecimals
    )
    await tokenA.waitForDeployment()
    const tokenAAddress = await tokenA.getAddress()
    console.log('TokenA 部署成功:', tokenAAddress)

    // 2. 部署 TokenB
    console.log('部署 TokenB:', tokenParams.value.tokenB)
    const tokenBDecimals = parseInt(tokenParams.value.tokenB.decimals)
    const tokenBSupply = ethers.parseUnits(tokenParams.value.tokenB.supply, tokenBDecimals)
    const tokenB = await TokenFactory.deploy(
      tokenParams.value.tokenB.name,
      tokenParams.value.tokenB.symbol,
      tokenBSupply,
      tokenBDecimals
    )
    await tokenB.waitForDeployment()
    const tokenBAddress = await tokenB.getAddress()
    console.log('TokenB 部署成功:', tokenBAddress)

    // 3. 部署 Pair
    console.log('部署 Pair，参数:', pairParams.value)
    const PairFactory = new ethers.ContractFactory(pairArtifact.abi, pairArtifact.bytecode, signer)
    const pair = await PairFactory.deploy(tokenAAddress, tokenBAddress)
    await pair.waitForDeployment()
    const pairAddress = await pair.getAddress()
    console.log('Pair 部署成功:', pairAddress)

    addresses.value = {
      tokenA: tokenAAddress,
      tokenB: tokenBAddress,
      pair: pairAddress
    }
    await updateConfigFile(tokenAAddress, tokenBAddress, pairAddress)
    success.value = true
  } catch (e) {
    console.error('部署失败:', e)
    error.value = e.message || '部署失败'
  } finally {
    loading.value = false
  }
}

// 自动写入 config.js 文件
async function updateConfigFile(tokenA, tokenB, pair) {
  try {
    await fetch('/__update_config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tokenA, tokenB, pair })
    })
  } catch (e) {
    console.warn('写入 config.js 失败:', e)
  }
}
</script>

<style scoped>
.deploy-contracts {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(100,108,255,0.08);
  padding: 2.5rem 2rem;
  max-width: 600px;
  margin: 2rem auto;
}
.deploy-section {
  width: 100%;
  margin-bottom: 2rem;
}
.deploy-section h3 {
  color: #333;
  margin-bottom: 1rem;
  font-size: 1.2em;
}
.input-group {
  margin-bottom: 1.5rem;
}
.input-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
  gap: 1rem;
}
.input-row label {
  min-width: 120px;
  font-weight: 500;
  color: #555;
}
.fancy-input {
  flex: 1;
  padding: 0.8em 1em;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 1em;
  transition: border-color 0.3s, box-shadow 0.3s;
  outline: none;
  background: #f9f9ff;
}
.fancy-input:focus {
  border-color: #646cff;
  box-shadow: 0 0 0 2px #646cff33;
  background: #fff;
}
.deploy-btn {
  padding: 1em 2.5em;
  border: none;
  border-radius: 8px;
  background: linear-gradient(90deg, #646cff 0%, #42b883 100%);
  color: #fff;
  font-size: 1.1em;
  font-weight: bold;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(100,108,255,0.10);
  transition: background 0.3s, transform 0.2s;
  margin: 1rem 0;
}
.deploy-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.addresses-section {
  width: 100%;
  margin-top: 2rem;
}
.addresses-section h3 {
  color: #333;
  margin-bottom: 1rem;
  font-size: 1.2em;
}
.address-block {
  margin: 0.5rem 0;
  font-size: 1.05em;
  background: #f9f9ff;
  border-radius: 6px;
  padding: 0.5em 1em;
  display: flex;
  gap: 0.5em;
  align-items: center;
}
.mono {
  font-family: 'Fira Mono', 'Consolas', 'Menlo', monospace;
  color: #646cff;
  word-break: break-all;
}
.help-text {
  font-size: 0.85em;
  color: #666;
  font-style: italic;
}
.error {
  color: #d32f2f;
  margin: 1rem 0;
  padding: 0.5em 1em;
  background: #ffebee;
  border-radius: 6px;
}
.success {
  color: #388e3c;
  margin: 1rem 0;
  padding: 0.5em 1em;
  background: #e8f5e8;
  border-radius: 6px;
}
</style> 