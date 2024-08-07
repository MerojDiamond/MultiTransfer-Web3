<script setup lang="ts">
import { useLayoutStore } from "~/store/layout";

const store = useLayoutStore();
let address = ref();
let isOpened = ref();
let networks = ref([
  {
    chainId: "0x1",
    rpcUrls: ["https://mainnet.infura.io/v3/YOUR-PROJECT-ID"],
    chainName: "Ethereum",
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
    blockExplorerUrls: ["https://etherscan.io"],
  },
  {
    chainId: "0x38",
    rpcUrls: ["https://bsc-dataseed.binance.org/"],
    chainName: "Binance Smart Chain",
    nativeCurrency: {
      name: "Binance Coin",
      symbol: "BNB",
      decimals: 18,
    },
    blockExplorerUrls: ["https://bscscan.com"],
  },
  {
    chainId: "0x89",
    rpcUrls: ["https://polygon-rpc.com/"],
    chainName: "Polygon",
    nativeCurrency: {
      name: "Polygon",
      symbol: "MATIC",
      decimals: 18,
    },
    blockExplorerUrls: ["https://polygonscan.com"],
  },
  {
    chainId: "0xa86a",
    rpcUrls: ["https://api.avax.network/ext/bc/C/rpc"],
    chainName: "Avalanche",
    nativeCurrency: {
      name: "Avalanche",
      symbol: "AVAX",
      decimals: 18,
    },
    blockExplorerUrls: ["https://cchain.explorer.avax.network"],
  },
  {
    chainId: "0xfa",
    rpcUrls: ["https://rpcapi.fantom.network"],
    chainName: "Fantom Opera",
    nativeCurrency: {
      name: "Fantom",
      symbol: "FTM",
      decimals: 18,
    },
    blockExplorerUrls: ["https://ftmscan.com"],
  },
  {
    chainId: "0xa4b1",
    rpcUrls: ["https://arb1.arbitrum.io/rpc"],
    chainName: "Arbitrum One",
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
    blockExplorerUrls: ["https://arbiscan.io"],
  },
  {
    chainId: "0xa",
    rpcUrls: ["https://mainnet.optimism.io"],
    chainName: "Optimism",
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
    blockExplorerUrls: ["https://optimistic.etherscan.io"],
  },
  {
    chainId: "0x63564c40",
    rpcUrls: ["https://api.harmony.one"],
    chainName: "Harmony",
    nativeCurrency: {
      name: "Harmony",
      symbol: "ONE",
      decimals: 18,
    },
    blockExplorerUrls: ["https://explorer.harmony.one"],
  },
  {
    chainId: "0x505",
    rpcUrls: ["https://rpc.moonriver.moonbeam.network"],
    chainName: "Moonriver",
    nativeCurrency: {
      name: "Moonriver",
      symbol: "MOVR",
      decimals: 18,
    },
    blockExplorerUrls: ["https://moonriver.moonscan.io"],
  },
  {
    chainId: "0xa4ec",
    rpcUrls: ["https://forno.celo.org"],
    chainName: "Celo",
    nativeCurrency: {
      name: "Celo",
      symbol: "CELO",
      decimals: 18,
    },
    blockExplorerUrls: ["https://explorer.celo.org"],
  },
  {
    chainId: "8453",
    rpcUrls: ["https://mainnet.base.org"],
    chainName: "Base",
    nativeCurrency: {
      name: "Hush",
      symbol: "HUSH",
      decimals: 8,
    },
    blockExplorerUrls: ["https://basescan.org"],
  },
  {
    chainId: "0x1070",
    rpcUrls: ["https://zkevm-rpc.polygonscan.com/"],
    chainName: "Polygon zkEVM",
    nativeCurrency: {
      name: "Polygon",
      symbol: "MATIC",
      decimals: 18,
    },
    blockExplorerUrls: ["https://polygonscan.com/"],
  },
]);
let network = ref(networks.value[0]);

function formatEthAddress(address) {
  if (address.length < 6) {
    return address;
  }
  return `${address.slice(0, 4)}...${address.slice(-2)}`;
}

watch(
  () => store.getAddress,
  (v) => {
    address.value = formatEthAddress(v);
    console.log(address.value);
  }
);
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
    <q-header style="background-color: #0e352a">
      <header class="flex justify-between q-pa-md items-center">
        <div>
          <img
            src="https://vixi.pro/assets/images/logo/logo-dark.png"
            alt="logo"
            style="width: 120px"
          />
        </div>
        <div class="menu">
          <nuxt-link to="/"> Multi-Sender</nuxt-link>
          <nuxt-link to="/token"> Create Token</nuxt-link>
        </div>
        <div class="flex items-center">
          <div class="q-mx-md">
            {{ address }}
          </div>
          <q-btn outline @click="isOpened = true">
            <span style="text-transform: none">
              {{ network.chainName }}
            </span>
          </q-btn>
        </div>
      </header>
      <q-dialog v-model="isOpened">
        <q-card style="background-color: #0e352a; max-width: 600px">
          <q-card-section>
            <div class="flex justify-between" style="gap: 15px">
              <h5>Переключить сеть</h5>
              <q-btn flat dense @click="isOpened = false">
                <q-icon name="close" />
              </q-btn>
            </div>
            <div class="q-my-md flex" style="gap: 15px; flex-wrap: wrap">
              <q-btn
                outline
                v-for="net in networks"
                :key="net.chainId"
                @click="network = net"
              >
                <span style="text-transform: none">
                  {{ net.chainName }}
                </span>
              </q-btn>
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>
    </q-header>
    <q-page-container style="background: #00150f !important">
      <q-page>
        <nuxt-page />
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<style scoped>
.menu {
  display: flex;
}

.menu a {
  padding: 8px 15px;
  height: 100%;
}

.router-link-active {
  background: var(--q-primary);
  border-radius: 7px;
}
</style>
