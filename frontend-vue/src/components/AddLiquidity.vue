<template>
  <div class="add-liquidity">
    <h2>添加流动性</h2>
    
    <!-- Token 数量输入 -->
    <div class="input-section">
      <h3>Token 数量</h3>
      <div class="input-group">
        <div class="input-row">
          <label>TokenA 数量:</label>
          <input v-model="liquidityParams.tokenA.amount" placeholder="100" class="fancy-input" />
          <span class="token-symbol">TKA</span>
        </div>
        <div class="input-row">
          <label>TokenB 数量:</label>
          <input v-model="liquidityParams.tokenB.amount" placeholder="100" class="fancy-input" />
          <span class="token-symbol">TKB</span>
        </div>
      </div>
    </div>

    <!-- 交易参数 -->
    <div class="input-section">
      <h3>交易参数</h3>
      <div class="input-group">
        <div class="input-row">
          <label>滑点保护 (%):</label>
          <input v-model="liquidityParams.slippage" placeholder="1.0" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>Gas 限制:</label>
          <input v-model="liquidityParams.gasLimit" placeholder="300000" class="fancy-input" />
        </div>
      </div>
    </div>

    <!-- 合约信息显示 -->
    <div class="contract-info">
      <h3>合约信息</h3>
      <div class="info-row">
        <span>TokenA 地址:</span>
        <span class="mono">{{ contractInfo.tokenA || '未部署' }}</span>
      </div>
      <div class="info-row">
        <span>TokenB 地址:</span>
        <span class="mono">{{ contractInfo.tokenB || '未部署' }}</span>
      </div>
      <div class="info-row">
        <span>Pair 地址:</span>
        <span class="mono">{{ contractInfo.pair || '未部署' }}</span>
      </div>
    </div>

    <button class="fancy-btn" :disabled="loading || !canSubmit" @click="addLiquidity">
      {{ loading ? '处理中...' : '添加流动性' }}
    </button>
    
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
</template>

<script>
import { ethers } from "ethers";
import { pairAddress, tokenAAddress, tokenBAddress, pairAbi, tokenAbi } from "../config";

export default {
  data() {
    return {
      loading: false,
      error: '',
      success: '',
      liquidityParams: {
        tokenA: { amount: '' },
        tokenB: { amount: '' },
        slippage: '1.0',
        gasLimit: '300000'
      },
      contractInfo: {
        tokenA: tokenAAddress,
        tokenB: tokenBAddress,
        pair: pairAddress
      }
    };
  },
  computed: {
    canSubmit() {
      return this.liquidityParams.tokenA.amount && 
             this.liquidityParams.tokenB.amount && 
             this.contractInfo.tokenA && 
             this.contractInfo.tokenB && 
             this.contractInfo.pair;
    }
  },
  methods: {
    async addLiquidity() {
      this.loading = true;
      this.error = '';
      this.success = '';
      
      try {
        console.log('开始添加流动性，参数:', this.liquidityParams);
        
        if (!window.ethereum) throw new Error('请先安装并解锁MetaMask');
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        
        // 创建合约实例
        const tokenA = new ethers.Contract(tokenAAddress, tokenAbi, signer);
        const tokenB = new ethers.Contract(tokenBAddress, tokenAbi, signer);
        const pair = new ethers.Contract(pairAddress, pairAbi, signer);

        console.log('合约实例创建成功');
        console.log('TokenA 地址:', tokenAAddress);
        console.log('TokenB 地址:', tokenBAddress);
        console.log('Pair 地址:', pairAddress);

        // 获取Token精度并解析输入数量
        const tokenADecimals = await tokenA.decimals();
        const tokenBDecimals = await tokenB.decimals();
        const amount0 = ethers.parseUnits(this.liquidityParams.tokenA.amount, tokenADecimals);
        const amount1 = ethers.parseUnits(this.liquidityParams.tokenB.amount, tokenBDecimals);
        
        console.log('解析后的数量:', {
          amount0: amount0.toString(),
          amount1: amount1.toString()
        });

        // 1. 授权 TokenA
        console.log('授权 TokenA...');
        const approveTxA = await tokenA.approve(pairAddress, amount0, {
          gasLimit: parseInt(this.liquidityParams.gasLimit)
        });
        await approveTxA.wait();
        console.log('TokenA 授权成功');

        // 2. 授权 TokenB
        console.log('授权 TokenB...');
        const approveTxB = await tokenB.approve(pairAddress, amount1, {
          gasLimit: parseInt(this.liquidityParams.gasLimit)
        });
        await approveTxB.wait();
        console.log('TokenB 授权成功');

        // 3. 添加流动性
        console.log('添加流动性...');
        const addLiquidityTx = await pair.addLiquidity(amount0, amount1, {
          gasLimit: parseInt(this.liquidityParams.gasLimit)
        });
        await addLiquidityTx.wait();
        console.log('流动性添加成功');

        this.success = `流动性添加成功！交易哈希: ${addLiquidityTx.hash}`;
        
      } catch (e) {
        console.error('添加流动性失败:', e);
        this.error = e.message || '添加流动性失败';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.add-liquidity {
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
.input-section {
  width: 100%;
  margin-bottom: 2rem;
}
.input-section h3 {
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
.token-symbol {
  font-weight: bold;
  color: #646cff;
  min-width: 50px;
}
.contract-info {
  width: 100%;
  margin-bottom: 2rem;
  background: #f9f9ff;
  border-radius: 8px;
  padding: 1.5rem;
}
.contract-info h3 {
  color: #333;
  margin-bottom: 1rem;
  font-size: 1.2em;
}
.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
  font-size: 0.9em;
}
.mono {
  font-family: 'Fira Mono', 'Consolas', 'Menlo', monospace;
  color: #646cff;
  word-break: break-all;
  max-width: 200px;
  text-align: right;
}
.fancy-btn {
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
.fancy-btn:hover:not(:disabled) {
  background: linear-gradient(90deg, #42b883 0%, #646cff 100%);
  transform: translateY(-2px) scale(1.03);
}
.fancy-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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
