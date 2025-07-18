<template>
  <div class="swap-token">
    <h2>代币兑换</h2>
    
    <!-- 兑换参数 -->
    <div class="input-section">
      <h3>兑换参数</h3>
      <div class="input-group">
        <div class="input-row">
          <label>输入数量:</label>
          <input v-model="swapParams.amountIn" placeholder="100" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>兑换方向:</label>
          <select v-model="swapParams.token" class="fancy-select">
            <option value="A">TokenA → TokenB</option>
            <option value="B">TokenB → TokenA</option>
          </select>
        </div>
        <div class="input-row">
          <label>滑点保护 (%):</label>
          <input v-model="swapParams.slippage" placeholder="1.0" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>Gas 限制:</label>
          <input v-model="swapParams.gasLimit" placeholder="300000" class="fancy-input" />
        </div>
      </div>
    </div>

    <!-- 预估输出 -->
    <div class="output-section" v-if="estimatedOutput">
      <h3>预估输出</h3>
      <div class="output-info">
        <div class="output-row">
          <span>预计获得:</span>
          <span class="output-amount">{{ estimatedOutput }}</span>
          <span class="token-symbol">{{ swapParams.token === 'A' ? 'TKB' : 'TKA' }}</span>
        </div>
        <div class="output-row">
          <span>滑点:</span>
          <span>{{ swapParams.slippage }}%</span>
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

    <button class="fancy-btn" :disabled="loading || !canSubmit" @click="swap">
      {{ loading ? '处理中...' : '开始兑换' }}
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
      estimatedOutput: '',
      swapParams: {
        amountIn: '',
        token: 'A',
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
      return this.swapParams.amountIn && 
             this.contractInfo.tokenA && 
             this.contractInfo.tokenB && 
             this.contractInfo.pair;
    }
  },
  watch: {
    'swapParams.amountIn': function() {
      this.estimateOutput();
    },
    'swapParams.token': function() {
      this.estimateOutput();
    }
  },
  methods: {
    async estimateOutput() {
      if (!this.swapParams.amountIn || !this.contractInfo.pair) return;
      
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const pair = new ethers.Contract(pairAddress, pairAbi, provider);
        
        // 获取Token精度
        const tokenInAddress = this.swapParams.token === 'A' ? tokenAAddress : tokenBAddress;
        const tokenIn = new ethers.Contract(tokenInAddress, tokenAbi, provider);
        const tokenInDecimals = await tokenIn.decimals();
        
        // 获取当前储备量
        const reserve0 = await pair.reserve0();
        const reserve1 = await pair.reserve1();
        
        const amountIn = ethers.parseUnits(this.swapParams.amountIn, tokenInDecimals);
        const isToken0In = this.swapParams.token === 'A';
        
        // 计算输出量（简化计算，实际应考虑手续费）
        const reserveIn = isToken0In ? reserve0 : reserve1;
        const reserveOut = isToken0In ? reserve1 : reserve0;
        
        const amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
        this.estimatedOutput = ethers.formatUnits(amountOut, tokenInDecimals);
        
      } catch (e) {
        console.warn('预估输出失败:', e);
        this.estimatedOutput = '';
      }
    },
    
    async swap() {
      this.loading = true;
      this.error = '';
      this.success = '';
      
      try {
        console.log('开始兑换，参数:', this.swapParams);
        
        if (!window.ethereum) throw new Error('请先安装并解锁MetaMask');
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        
        // 创建合约实例
        const pair = new ethers.Contract(pairAddress, pairAbi, signer);
        const tokenInAddress = this.swapParams.token === 'A' ? tokenAAddress : tokenBAddress;
        const tokenIn = new ethers.Contract(tokenInAddress, tokenAbi, signer);

        console.log('合约实例创建成功');
        console.log('输入Token地址:', tokenInAddress);
        console.log('Pair地址:', pairAddress);

        // 获取Token精度并解析输入数量
        const tokenInDecimals = await tokenIn.decimals();
        const amountIn = ethers.parseUnits(this.swapParams.amountIn, tokenInDecimals);
        const minAmountOut = amountIn * BigInt(100 - parseFloat(this.swapParams.slippage)) / BigInt(100);
        
        console.log('解析后的参数:', {
          amountIn: amountIn.toString(),
          minAmountOut: minAmountOut.toString()
        });

        // 1. 授权输入Token
        console.log('授权输入Token...');
        const approveTx = await tokenIn.approve(pairAddress, amountIn, {
          gasLimit: parseInt(this.swapParams.gasLimit)
        });
        await approveTx.wait();
        console.log('Token授权成功');

        // 2. 执行兑换
        console.log('执行兑换...');
        const swapTx = await pair.swap(tokenInAddress, amountIn, minAmountOut, {
          gasLimit: parseInt(this.swapParams.gasLimit)
        });
        await swapTx.wait();
        console.log('兑换成功');

        this.success = `兑换成功！交易哈希: ${swapTx.hash}`;
        
      } catch (e) {
        console.error('兑换失败:', e);
        this.error = e.message || '兑换失败';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.swap-token {
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
.input-section, .output-section {
  width: 100%;
  margin-bottom: 2rem;
}
.input-section h3, .output-section h3 {
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
.fancy-input, .fancy-select {
  flex: 1;
  padding: 0.8em 1em;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 1em;
  transition: border-color 0.3s, box-shadow 0.3s;
  outline: none;
  background: #f9f9ff;
}
.fancy-input:focus, .fancy-select:focus {
  border-color: #646cff;
  box-shadow: 0 0 0 2px #646cff33;
  background: #fff;
}
.output-info {
  background: #f0f8ff;
  border-radius: 8px;
  padding: 1rem;
}
.output-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}
.output-amount {
  font-weight: bold;
  color: #646cff;
  font-size: 1.1em;
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
