<template>
  <div class="contract-caller">
    <h2>合约调用工具</h2>
    
    <!-- 合约类型选择 -->
    <div class="contract-type-selector">
      <h3>合约类型</h3>
      <div class="selector-group">
        <label>
          <input type="radio" v-model="contractType" value="erc20" />
          ERC20 Token 合约
        </label>
        <label>
          <input type="radio" v-model="contractType" value="pair" />
          Uniswap Pair 合约
        </label>
      </div>
    </div>

    <!-- 合约地址输入 -->
    <div class="contract-address-section">
      <h3>合约地址</h3>
      <div class="address-input-group">
        <div class="input-row">
          <label>合约地址:</label>
          <input v-model="contractAddress" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="preset-addresses">
          <button 
            v-for="(address, name) in presetAddresses" 
            :key="name"
            @click="selectPresetAddress(name)"
            class="preset-btn"
          >
            {{ name }}
          </button>
        </div>
      </div>
    </div>

    <!-- ERC20 合约功能 -->
    <div v-if="contractType === 'erc20'" class="function-section">
      <h3>ERC20 Token 合约功能</h3>
      <div class="function-selector">
        <select v-model="selectedFunction" class="fancy-select">
          <option value="">选择功能</option>
          <option value="transfer">transfer - 转账</option>
          <option value="transferFrom">transferFrom - 授权转账</option>
          <option value="approve">approve - 授权</option>
          <option value="balanceOf">balanceOf - 查询余额</option>
          <option value="allowance">allowance - 查询授权额度</option>
          <option value="name">name - 查询名称</option>
          <option value="symbol">symbol - 查询符号</option>
          <option value="decimals">decimals - 查询精度</option>
          <option value="totalSupply">totalSupply - 查询总供应量</option>
        </select>
      </div>

      <!-- transfer 参数 -->
      <div v-if="selectedFunction === 'transfer'" class="param-section">
        <h4>transfer 参数</h4>
        <div class="input-row">
          <label>接收地址:</label>
          <input v-model="functionParams.to" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>转账数量:</label>
          <input v-model="functionParams.amount" placeholder="100" class="fancy-input" />
        </div>
      </div>

      <!-- transferFrom 参数 -->
      <div v-if="selectedFunction === 'transferFrom'" class="param-section">
        <h4>transferFrom 参数</h4>
        <div class="input-row">
          <label>发送地址:</label>
          <input v-model="functionParams.from" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>接收地址:</label>
          <input v-model="functionParams.to" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>转账数量:</label>
          <input v-model="functionParams.amount" placeholder="100" class="fancy-input" />
        </div>
      </div>

      <!-- approve 参数 -->
      <div v-if="selectedFunction === 'approve'" class="param-section">
        <h4>approve 参数</h4>
        <div class="input-row">
          <label>授权地址:</label>
          <input v-model="functionParams.spender" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>授权数量:</label>
          <input v-model="functionParams.amount" placeholder="100" class="fancy-input" />
        </div>
      </div>

      <!-- balanceOf 参数 -->
      <div v-if="selectedFunction === 'balanceOf'" class="param-section">
        <h4>balanceOf 参数</h4>
        <div class="input-row">
          <label>查询地址:</label>
          <input v-model="functionParams.account" placeholder="0x..." class="fancy-input" />
        </div>
      </div>

      <!-- allowance 参数 -->
      <div v-if="selectedFunction === 'allowance'" class="param-section">
        <h4>allowance 参数</h4>
        <div class="input-row">
          <label>所有者地址:</label>
          <input v-model="functionParams.owner" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>授权者地址:</label>
          <input v-model="functionParams.spender" placeholder="0x..." class="fancy-input" />
        </div>
      </div>
    </div>

    <!-- Pair 合约功能 -->
    <div v-if="contractType === 'pair'" class="function-section">
      <h3>Uniswap Pair 合约功能</h3>
      <div class="function-selector">
        <select v-model="selectedFunction" class="fancy-select">
          <option value="">选择功能</option>
          <option value="addLiquidity">addLiquidity - 添加流动性</option>
          <option value="swap">swap - 代币兑换</option>
          <option value="token0">token0 - 查询Token0地址</option>
          <option value="token1">token1 - 查询Token1地址</option>
          <option value="reserve0">reserve0 - 查询Token0储备量</option>
          <option value="reserve1">reserve1 - 查询Token1储备量</option>
        </select>
      </div>

      <!-- addLiquidity 参数 -->
      <div v-if="selectedFunction === 'addLiquidity'" class="param-section">
        <h4>addLiquidity 参数</h4>
        <div class="input-row">
          <label>Token0 数量:</label>
          <input v-model="functionParams.amount0" placeholder="100" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>Token1 数量:</label>
          <input v-model="functionParams.amount1" placeholder="100" class="fancy-input" />
        </div>
      </div>

      <!-- swap 参数 -->
      <div v-if="selectedFunction === 'swap'" class="param-section">
        <h4>swap 参数</h4>
        <div class="input-row">
          <label>输入Token地址:</label>
          <input v-model="functionParams.fromToken" placeholder="0x..." class="fancy-input" />
        </div>
        <div class="input-row">
          <label>输入数量:</label>
          <input v-model="functionParams.amountIn" placeholder="100" class="fancy-input" />
        </div>
        <div class="input-row">
          <label>最小输出数量:</label>
          <input v-model="functionParams.minAmountOut" placeholder="95" class="fancy-input" />
        </div>
      </div>
    </div>

    <!-- 交易参数 (仅对写入函数显示) -->
    <div v-if="!isReadFunction()" class="transaction-params">
      <h3>交易参数</h3>
      <div class="input-row">
        <label>Gas 限制:</label>
        <input v-model="txParams.gasLimit" placeholder="300000" class="fancy-input" />
      </div>
      <div class="input-row">
        <label>Gas 价格 (Gwei):</label>
        <input v-model="txParams.gasPrice" placeholder="20" class="fancy-input" />
      </div>
    </div>

    <!-- 执行按钮 -->
    <button class="fancy-btn" :disabled="loading || !canExecute" @click="executeFunction">
      {{ loading ? '执行中...' : (isReadFunction() ? '查询' : '执行交易') }}
    </button>

    <!-- 结果显示 -->
    <div v-if="result" class="result-section">
      <h3>执行结果</h3>
      <div class="result-content">
        <pre>typeof: {{ typeof result }}</pre>
        <pre>{{ result + '' }}</pre>
      </div>
    </div>

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
      result: '',
      contractType: 'erc20',
      contractAddress: '',
      selectedFunction: '',
      functionParams: {},
      txParams: {
        gasLimit: '300000',
        gasPrice: '20'
      },
      presetAddresses: {
        'TokenA': tokenAAddress,
        'TokenB': tokenBAddress,
        'Pair': pairAddress
      }
    };
  },
  computed: {
    canExecute() {
      return this.contractAddress && this.selectedFunction;
    },
    contractAbi() {
      const abiData = this.contractType === 'pair' ? pairAbi : tokenAbi;
      // Extract the actual ABI from the Hardhat artifact format
      return Array.isArray(abiData) && abiData.length > 0 ? abiData[0].abi : abiData;
    }
  },
  watch: {
    selectedFunction() {
      this.functionParams = {};
      this.result = '';
      this.error = '';
      this.success = '';
    },
    contractType() {
      this.selectedFunction = '';
      this.functionParams = {};
      this.result = '';
      this.error = '';
      this.success = '';
    }
  },
  methods: {
    selectPresetAddress(name) {
      this.contractAddress = this.presetAddresses[name];
    },
    
    async executeFunction() {
      this.loading = true;
      this.error = '';
      this.success = '';
      this.result = '';

      try {
        if (!window.ethereum) throw new Error('请先安装并解锁MetaMask');
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();

        console.log('执行合约调用:', {
          contractType: this.contractType,
          contractAddress: this.contractAddress,
          function: this.selectedFunction,
          params: this.functionParams,
          txParams: this.txParams
        });

        let result;
        const params = this.buildFunctionParams();

        if (this.isReadFunction()) {
          // 只读函数 - 使用 provider
          const readContract = new ethers.Contract(this.contractAddress, this.contractAbi, provider);
          console.log('调用只读函数:', this.selectedFunction, '参数:', params);
          console.log('使用的ABI:', this.contractAbi);
          result = await readContract[this.selectedFunction](...params);
          console.log('原始结果:', result, '类型:', typeof result);
          this.result = await this.formatResult(result);
          this.success = '查询成功！';
        } else {
          // 写入函数 - 使用 signer
          const writeContract = new ethers.Contract(this.contractAddress, this.contractAbi, signer);
          
          let txOptions = {
            gasLimit: parseInt(this.txParams.gasLimit)
          };

          if (this.txParams.gasPrice) {
            txOptions.gasPrice = ethers.parseUnits(this.txParams.gasPrice, 'gwei');
          }

          console.log('调用写入函数:', this.selectedFunction, '参数:', params, '选项:', txOptions);
          const tx = await writeContract[this.selectedFunction](...params, txOptions);
          await tx.wait();
          this.result = `交易成功！\n交易哈希: ${tx.hash}`;
          this.success = '交易成功！';
        }

      } catch (e) {
        console.error('合约调用失败:', e);
        this.error = e.message || '合约调用失败';
      } finally {
        this.loading = false;
      }
    },

    buildFunctionParams() {
      const params = [];
      
      switch(this.selectedFunction) {
        case 'transfer':
          params.push(this.functionParams.to, ethers.parseEther(this.functionParams.amount || '0'));
          break;
        case 'transferFrom':
          params.push(this.functionParams.from, this.functionParams.to, ethers.parseEther(this.functionParams.amount || '0'));
          break;
        case 'approve':
          params.push(this.functionParams.spender, ethers.parseEther(this.functionParams.amount || '0'));
          break;
        case 'balanceOf':
          params.push(this.functionParams.account);
          break;
        case 'allowance':
          params.push(this.functionParams.owner, this.functionParams.spender);
          break;
        case 'addLiquidity':
          params.push(ethers.parseEther(this.functionParams.amount0 || '0'), ethers.parseEther(this.functionParams.amount1 || '0'));
          break;
        case 'swap':
          params.push(this.functionParams.fromToken, ethers.parseEther(this.functionParams.amountIn || '0'), ethers.parseEther(this.functionParams.minAmountOut || '0'));
          break;
      }
      
      return params;
    },

    isReadFunction() {
      const readFunctions = ['balanceOf', 'allowance', 'name', 'symbol', 'decimals', 'totalSupply', 'token0', 'token1', 'reserve0', 'reserve1'];
      return readFunctions.includes(this.selectedFunction);
    },

    async formatResult(result) {
      if (this.selectedFunction === 'decimals') {
        return result.toString();
      }
      if (typeof result === 'bigint') {
        if (this.selectedFunction === 'balanceOf' || this.selectedFunction === 'totalSupply') {
          try {
            const provider = new ethers.BrowserProvider(window.ethereum);
            const contract = new ethers.Contract(this.contractAddress, this.contractAbi, provider);
            const decimals = await contract.decimals();
            let formatted = ethers.formatUnits(result, decimals);
            if (!formatted.includes('.')) {
              formatted += '.' + '0'.repeat(decimals);
            } else {
              const [intPart, fracPart] = formatted.split('.');
              formatted = intPart + '.' + (fracPart || '').padEnd(decimals, '0');
            }
            console.log('formatUnits原始:', formatted, 'decimals:', decimals);
            return String(formatted);
          } catch (e) {
            return ethers.formatEther(result);
          }
        } else {
          return ethers.formatEther(result);
        }
      } else if (typeof result === 'string') {
        return result;
      } else {
        return JSON.stringify(result, null, 2);
      }
    }
  }
};
</script>

<style scoped>
.contract-caller {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(100,108,255,0.08);
  padding: 2.5rem 2rem;
  max-width: 700px;
  margin: 2rem auto;
}
.contract-type-selector, .contract-address-section, .function-section, .transaction-params, .result-section {
  width: 100%;
  margin-bottom: 2rem;
}
.contract-type-selector h3, .contract-address-section h3, .function-section h3, .transaction-params h3, .result-section h3 {
  color: #333;
  margin-bottom: 1rem;
  font-size: 1.2em;
}
.selector-group {
  display: flex;
  gap: 2rem;
  margin-bottom: 1rem;
}
.selector-group label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}
.address-input-group {
  margin-bottom: 1rem;
}
.preset-addresses {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
  flex-wrap: wrap;
}
.preset-btn {
  padding: 0.3em 0.8em;
  border: 1px solid #646cff;
  border-radius: 4px;
  background: #f0f0ff;
  color: #646cff;
  font-size: 0.9em;
  cursor: pointer;
  transition: background 0.2s;
}
.preset-btn:hover {
  background: #646cff;
  color: #fff;
}
.function-selector {
  margin-bottom: 1.5rem;
}
.fancy-select {
  width: 100%;
  padding: 0.8em 1em;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 1em;
  transition: border-color 0.3s, box-shadow 0.3s;
  outline: none;
  background: #f9f9ff;
}
.fancy-select:focus {
  border-color: #646cff;
  box-shadow: 0 0 0 2px #646cff33;
  background: #fff;
}
.param-section {
  background: #f9f9ff;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1rem;
}
.param-section h4 {
  color: #333;
  margin-bottom: 1rem;
  font-size: 1.1em;
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
.result-section {
  background: #f9f9ff;
  border-radius: 8px;
  padding: 1.5rem;
}
.result-content {
  background: #fff;
  border-radius: 6px;
  padding: 1rem;
  max-height: 300px;
  overflow-y: auto;
}
.result-content pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-all;
  font-family: 'Fira Mono', 'Consolas', 'Menlo', monospace;
  font-size: 0.9em;
  color: #333;
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