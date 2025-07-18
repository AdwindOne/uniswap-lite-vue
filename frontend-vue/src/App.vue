<script setup>
import { ref } from 'vue'
import AddLiquidity from './components/AddLiquidity.vue'
import Swap from './components/Swap.vue'
import DeployContracts from './components/DeployContracts.vue'
import ContractCaller from './components/ContractCaller.vue'

const activeTab = ref('deploy')
</script>

<template>
  <div class="tabs">
    <button :class="{ active: activeTab === 'deploy' }" @click="activeTab = 'deploy'">部署合约</button>
    <button :class="{ active: activeTab === 'add' }" @click="activeTab = 'add'">添加流动性</button>
    <button :class="{ active: activeTab === 'swap' }" @click="activeTab = 'swap'">代币兑换</button>
    <button :class="{ active: activeTab === 'caller' }" @click="activeTab = 'caller'">合约调用</button>
  </div>
  <div class="tab-content">
    <DeployContracts v-if="activeTab === 'deploy'" />
    <AddLiquidity v-if="activeTab === 'add'" />
    <Swap v-if="activeTab === 'swap'" />
    <ContractCaller v-if="activeTab === 'caller'" />
  </div>
</template>

<style scoped>
.tabs {
  display: flex;
  justify-content: center;
  margin: 2rem 0 1rem 0;
  gap: 1rem;
  flex-wrap: wrap;
}
.tabs button {
  padding: 0.7em 2em;
  border: none;
  border-radius: 6px 6px 0 0;
  background: #f0f0f0;
  color: #333;
  font-size: 1.1em;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.tabs button.active {
  background: #646cff;
  color: #fff;
  font-weight: bold;
}
.tab-content {
  background: #fff;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 2px 12px rgba(100,108,255,0.08);
  padding: 2rem 1.5rem;
  max-width: 700px;
  margin: 0 auto 2rem auto;
}
</style>
