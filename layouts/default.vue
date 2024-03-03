<script setup lang="ts">
let network = ref();
let networks = ref([
  {
    chainId: "0x89",
    rpcUrls: ["https://polygon-rpc.com/"],
    chainName: "Matic Mainnet",
    nativeCurrency: {
      name: "MATIC",
      symbol: "MATIC",
      decimals: 18,
    },
    blockExplorerUrls: ["https://polygonscan.com/"],
  },
  {
    chainId: "0x144",
    rpcUrls: ["https://mainnet.era.zksync.io"],
    chainName: "zkSync Era",
    nativeCurrency: {
      name: "ETH",
      symbol: "ETH",
      decimals: 18,
    },
    blockExplorerUrls: ["https://explorer.zksync.io"],
  },
  {
    chainId: "0x2711",
    rpcUrls: ["https://mainnet.ethereumpow.org"],
    chainName: "ETHW-mainnet",
    nativeCurrency: {
      name: "ETHW",
      symbol: "ETHW",
      decimals: 18,
    },
    blockExplorerUrls: ["https://mainnet.ethwscan.com"],
  },
]);
watch(network, (v) => {
  window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [
      {
        chainId: v.chainId,
        rpcUrls: [...v.rpcUrls],
        chainName: v.chainName,
        nativeCurrency: {
          name: v.nativeCurrency.name,
          symbol: v.nativeCurrency.symbol,
          decimals: v.nativeCurrency.decimals,
        },
        blockExplorerUrls: [...v.blockExplorerUrls],
      },
    ],
  });
});
</script>

<template>
  <q-layout>
    <q-header style="background-color: #1c084a; box-shadow: 0 5px 7px #1f0954">
      <header class="flex justify-between q-pa-md">
        <div></div>
        <div>
          <q-select
            dense
            option-label="chainName"
            style="min-width: 250px"
            outlined
            color="indigo"
            dark
            v-model="network"
            :options="networks"
          />
        </div>
      </header>
    </q-header>
    <q-page-container>
      <q-page>
        <nuxt-page />
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<style scoped></style>
