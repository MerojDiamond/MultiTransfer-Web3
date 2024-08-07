<script setup>
import { ethers } from "ethers";
import SimpleToken from "../artifacts/contracts/Tokens.sol/SimpleToken.json";
import TokenTax from "../artifacts/contracts/Tokens.sol/TokenTax.json";
import TokenDualTax from "../artifacts/contracts/Tokens.sol/TokenDualTax.json";
import TokenDynamicTax from "../artifacts/contracts/Tokens.sol/TokenDynamicTax.json";
import TokenDynamicDualTax from "../artifacts/contracts/Tokens.sol/TokenDynamicDualTax.json";

let addre = ref();
let _provider = null;
let loading = ref(false);
let name = ref();
let symbol = ref();
let decimals = ref();
let totalSupply = ref();
let isCom = ref(false);
let isDual = ref(false);
let isWithdraw = ref(false);
let sellCom = ref(0);
let fixed = ref(true);
let commission = ref(0);
let address = ref();
let response = ref();

let initialize = async (address) => {
  await window.ethereum.enable();
  _provider = new ethers.BrowserProvider(window.ethereum);
  addre.value = await _provider.getSigner();
};
let connectWallet = async () => {
  const [selectedAddress] = await window.ethereum.request({
    method: "eth_requestAccounts",
  });
  initialize(selectedAddress);
  window.ethereum.on("accountsChanged", ([newAddress]) => {
    if (newAddress === "undefined") return;
    initialize(newAddress);
  });
};

async function send() {
  loading.value = true;
  let abi = null;
  let bytecode = null;
  if (isCom.value) {
    if (fixed.value) {
      if (isDual.value) {
        abi = TokenDualTax.abi;
        bytecode = TokenDualTax.bytecode;
      } else {
        abi = TokenTax.abi;
        bytecode = TokenTax.bytecode;
      }
    } else {
      if (isDual.value) {
        abi = TokenDynamicDualTax.abi;
        bytecode = TokenDynamicDualTax.bytecode;
      } else {
        abi = TokenDynamicTax.abi;
        bytecode = TokenDynamicTax.bytecode;
      }
    }
  } else {
    abi = SimpleToken.abi;
    bytecode = SimpleToken.bytecode;
  }
  const factory = new ethers.ContractFactory(
    abi,
    bytecode,
    await _provider.getSigner(0)
  );
  let args = [name.value, symbol.value, decimals.value, totalSupply.value];
  if (isCom.value)
    if (fixed.value) {
      args.push(commission.value);
      if (isDual.value) args.push(sellCom.value);
    }
  const contract = await factory.deploy(...args);
  // const response = await useFetch("/api/verify", {
  //   method: "post",
  //   body: {
  //     address: contract.target,
  //     name: name.value,
  //     symbol: symbol.value,
  //     decimals: decimals.value,
  //     totalSupply: totalSupply.value,
  //   },
  // });
  // console.log(response);
  response.value = {
    name: name.value,
    symbol: symbol.value,
    decimals: decimals.value,
    totalSupply: totalSupply.value,
    address: contract.target,
  };
  console.log(response);
  loading.value = false;
  // useFetch("/api/create-token", {
  //   method: "post",
  //   body: {
  //     addre: addre.value,
  //     name: name.value,
  //     symbol: symbol.value,
  //     decimals: decimals.value,
  //     totalSupply: totalSupply.value,
  //     com: isCom.value,
  //     address: address.value,
  //     isDual: isDual.value,
  //     sellCom: sellCom.value,
  //     fixed: fixed.value,
  //     commission: commission.value,
  //   },
  // })
  //   .then((r) => {
  //     response.value = r.data.value;
  //   })
  //   .finally(() => (loading.value = false));
}
</script>

<template>
  <q-layout style="background-color: #00150f" class="z-2">
    <q-page-container class="z-2">
      <q-page class="flex justify-center items-center z-2 px-4">
        <div class="px-4" style="max-width: 100vw">
          <div class="shado my-7 mx-4">
            <q-card
              v-if="response"
              flat
              bordered
              style="
                min-width: 300px;
                max-width: 100vw;
                width: 500px;
                background-color: rgba(33, 52, 47, 1);
                border-radius: 15px;
              "
              class="text-white hover:shadow-md"
            >
              <q-card-section>
                <div class="flex justify-between items-center">
                  <h3 class="title">Token created!</h3>
                </div>
              </q-card-section>
              <q-separator />
              <q-card-section>
                <h4 class="title">Info</h4>
                <div class="q-my-md">
                  <p>
                    Name: <b>{{ response.name }}</b>
                  </p>
                  <p>
                    Symbol: <b>{{ response.symbol }}</b>
                  </p>
                  <p>
                    Decimals: <b>{{ response.decimals }}</b>
                  </p>
                  <p>
                    Total Supply: <b>{{ response.totalSupply }}</b>
                  </p>
                  <p>
                    Address:
                    <a
                      :href="`https://sepolia.etherscan.io/token/${response.address}`"
                      ><b>{{ response.address }}</b></a
                    >
                  </p>
                </div>
              </q-card-section>
            </q-card>
            <q-card
              v-else
              flat
              bordered
              style="
                min-width: 300px;
                max-width: 100vw;
                width: 500px;
                background-color: rgba(33, 52, 47, 1);
                border-radius: 15px;
              "
              class="text-white hover:shadow-md"
            >
              <q-card-section>
                <h3 class="title">Create Token</h3>
              </q-card-section>
              <q-form @submit="send">
                <q-card-section>
                  <label class="text-bold text-h7">
                    Token Name
                    <span class="text-red">*</span>
                  </label>
                  <p class="mb-1">
                    Your project unabbreviated name with spaces (usually 1-3
                    words)
                  </p>
                  <q-input
                    placeholder="Ex: Bitcoin"
                    color="primary"
                    outlined
                    class="mb-4"
                    dense
                    v-model="name"
                  />
                  <label class="text-bold text-h7">
                    Token Symbol
                    <span class="text-red">*</span>
                  </label>
                  <p class="mb-1">
                    Currency symbol appearing in balance (usually 3-5 uppercase
                    chars)
                  </p>
                  <q-input
                    placeholder="Ex: BTC"
                    color="primary"
                    outlined
                    class="mb-4"
                    dense
                    v-model="symbol"
                  />
                  <label class="text-bold text-h7">
                    Token Decimals
                    <span class="text-red">*</span>
                  </label>
                  <p class="mb-1">
                    The decimal precision of your token (18 is default)
                  </p>
                  <q-input
                    placeholder="Ex: 18"
                    color="primary"
                    outlined
                    class="mb-4"
                    dense
                    v-model.number="decimals"
                  />
                  <label class="text-bold text-h7">
                    Token Total Supply
                    <span class="text-red">*</span>
                  </label>
                  <p class="mb-1">
                    Number of initial tokens to mint and send to your wallet
                    address (float)
                  </p>
                  <q-input
                    placeholder="Ex: 1 000 000"
                    color="primary"
                    outlined
                    class="mb-4"
                    dense
                    v-model.number="totalSupply"
                  />
                  <label>Commissions</label>
                  <q-toggle
                    color="primary"
                    label="Use commissions"
                    v-model="isCom"
                  />
                  <q-toggle
                    color="primary"
                    label="Fixed commissions"
                    v-model="fixed"
                    v-if="isCom"
                  />
                  <q-toggle
                    color="primary"
                    label="Dual commissions (buy & sell)"
                    v-model="isDual"
                    v-if="isCom"
                  />
                  <q-toggle
                    color="primary"
                    label="Withdraw Address"
                    v-if="isCom"
                    v-model="isWithdraw"
                  />
                  <template v-if="fixed && isCom">
                    <br />
                    <label>Commission (buy)*</label>
                    <q-input
                      label="Commission"
                      color="primary"
                      outlined
                      class="mt-2"
                      dense
                      suffix="%"
                      :rules="[(v) => (v > 0 && v < 50) || 'Invalid percent']"
                      v-model.number="commission"
                    />
                  </template>
                  <template v-if="fixed && isCom && isDual">
                    <label>Commission (sell)*</label>
                    <q-input
                      label="Sell commission"
                      color="primary"
                      outlined
                      class="mt-2"
                      dense
                      suffix="%"
                      :rules="[(v) => (v > 0 && v < 50) || 'Invalid percent']"
                      v-model.number="sellCom"
                    />
                  </template>
                  <template v-if="isCom && isWithdraw">
                    <label>Withdraw address*</label>
                    <q-input
                      label="Withdraw address"
                      color="primary"
                      outlined
                      class="mt-2"
                      dense
                      v-model="address"
                    />
                  </template>
                </q-card-section>
                <q-card-actions>
                  <q-btn
                    style="width: 100%"
                    unelevated
                    color="primary"
                    @click="connectWallet"
                    label="Connect wallet"
                    v-if="!addre"
                  />
                  <q-btn
                    v-else
                    :loading="loading"
                    style="width: 100%"
                    unelevated
                    color="primary"
                    type="submit"
                    label="Create"
                  />
                </q-card-actions>
              </q-form>
            </q-card>
          </div>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>
<style>
.text-h7 {
  font-size: 16px;
}

.z-2,
.q-page,
.q-page-container,
.q-layout,
#__nuxt,
body {
  position: relative;
  z-index: -2;
}

.shado {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  background: transparent;
}

.shado:before,
.shado:after {
  content: "";
  position: absolute;
  background: linear-gradient(
    45deg,
    #00150f,
    #0e221e,
    #002a1e,
    #002a1e,
    #00533b,
    #00d094,
    #00533b,
    #002a1e,
    #002a1e,
    #0e221e,
    #00150f
  );
  background-size: 400%;
  width: calc(100% - 15px);
  height: calc(100% - 15px);
  z-index: -1;
  animation: animate 20s linear infinite;
}

.shado:after {
  filter: blur(60px);
}

@keyframes animate {
  0% {
    background-position: 0 0;
  }
  50% {
    background-position: 350% 0;
  }
  100% {
    background-position: 0 0;
  }
}
</style>
