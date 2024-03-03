<script setup>
import {ethers} from 'ethers';
import transferAddress from "@/contracts/MultiTransfer-address.json"
import transferArtifact from "@/contracts/MultiTransfer.json"
import tokenArtifact from "@/contracts/SimpleToken.json"

const ERROR_CODE_REJECT_BY_USER = 4001
let addre = ref()
let transfer = null
let _provider = null
let tab = ref("input")
let text = ref()
let equal = ref(false)
let token = ref(false)
let tokenAddress = ref()
let amount = ref()
let file = ref()
let initialize = async (address) => {
  await window.ethereum.enable()
  _provider = new ethers.BrowserProvider(window.ethereum)
  transfer = new ethers.Contract(
      transferAddress.MultiTransfer,
      transferArtifact.abi,
      await _provider.getSigner(0)
  )
  addre.value = address
}
let connectWallet = async () => {
  const [selectedAddress] = await window.ethereum.request({
    method: "eth_requestAccounts"
  })
  initialize(selectedAddress)
  window.ethereum.on("accountsChanged", ([newAddress]) => {
    if (newAddress === "undefined") return;
    initialize(newAddress);
  })
}

async function t() {
  let rows
  if (tab.value != "file") rows = text.value.split("\n")
  let addresses = 0
  let amounts = 0
  let tx;
  if (token.value) {
    let sum = 0
    _provider = new ethers.BrowserProvider(window.ethereum)
    let token2 = new ethers.Contract(
        tokenAddress.value,
        tokenArtifact.abi,
        await _provider.getSigner(0)
    )
    if (equal.value) {
      amounts = amount.value
      if (tab.value == "file") {
        let reader = new FileReader();
        let json
        addresses = []
        reader.onload = async e => {
          json = JSON.parse(e.target.result);
          addresses = json.addresses
          sum = amount.value * addresses.length + 1
          await token2.increaseAllowance(transfer.target, ethers.parseEther(sum.toString()))
          await transfer.multiTransfersTokensEqualAmount(tokenAddress.value, addresses, ethers.parseEther(amounts))
        };
        reader.readAsText(file.value);
      } else {
        addresses = rows
        sum = amount.value * addresses.length
        await token2.increaseAllowance(transfer.target, ethers.parseEther(sum.toString()))
        await transfer.multiTransfersTokensEqualAmount(tokenAddress.value, addresses, ethers.parseEther(amounts))
      }
    } else {
      if (tab.value == "file") {
        let reader = new FileReader();
        let json
        addresses = []
        reader.onload = async e => {
          json = JSON.parse(e.target.result);
          addresses = json.addresses
          amounts = json.amounts.map(i => ethers.parseEther(i.toString()))
          sum = json.amounts.reduce((sum, i) => parseFloat(sum) + i, 0)
          await token2.increaseAllowance(transfer.target, ethers.parseEther(sum.toString()))
          await transfer.multiTransfersTokens(tokenAddress.value, addresses, amounts)
        };
        reader.readAsText(file.value);
      } else {
        rows.forEach(i => {
          addresses = []
          amounts = []
          let seperated = i.split(";")
          addresses.push(seperated[0])
          sum += parseFloat(seperated[1])
          amounts.push(ethers.parseEther(seperated[1].trim()))
        })
        await token2.increaseAllowance(transfer.target, ethers.parseEther(sum.toString()))
        await transfer.multiTransfersTokens(tokenAddress.value, addresses, amounts)
      }
    }
    return
  }
  if (equal.value) {
    amounts = amount.value
    if (tab.value == "file") {
      let reader = new FileReader();
      let json
      addresses = []
      reader.onload = async e => {
        json = JSON.parse(e.target.result);
        addresses = json.addresses
        await transfer.multiTransfersEthEqualAmount(addresses, ethers.parseEther(amounts.toString()), {
          value: ethers.parseEther((parseFloat(amounts) * addresses.length).toString())
        })
      };
      reader.readAsText(file.value);
    } else {
      addresses = rows
      await transfer.multiTransfersEthEqualAmount(addresses, ethers.parseEther(amounts.toString()), {
        value: ethers.parseEther((parseFloat(amounts) * addresses.length).toString())
      })
    }
  } else {
    let sum = 0
    if (tab.value == "file") {
      let reader = new FileReader();
      let json
      addresses = []
      reader.onload = async e => {
        json = JSON.parse(e.target.result);
        addresses = json.addresses
        amounts = json.amounts.map(i => ethers.parseEther(i.toString()))
        sum = json.amounts.reduce((sum, i) => parseFloat(sum) + i, 0)
        await transfer.multiTransfersEth(addresses, amounts, {
          value: ethers.parseEther(sum.toString())
        })
      };
      reader.readAsText(file.value);
    } else {
      rows.forEach(i => {
        addresses = []
        amounts = []
        let seperated = i.split(";")
        addresses.push(seperated[0])
        amounts.push(ethers.parseEther(seperated[1].trim()))
        sum += parseFloat(seperated[1])
      })
      await transfer.multiTransfersEth(addresses, amounts, {
        value: ethers.parseEther(sum.toString())
      })
    }
  }
}
</script>
<template>
  <q-layout style="background-color: #11052E" class="z-2">
    <q-page-container class="z-2">
      <q-page class="flex justify-center items-center z-2 px-4">
        <div class="px-4" style="max-width: 100vw">
          <div class="shado my-7 mx-4">
            <q-card flat bordered
                    style="min-width: 300px; max-width: 100vw; width: 500px; background-color: #1F0954; border-radius: 15px;"
                    class="text-white hover:shadow-md">
              <q-card-section>
                <h3 class="text-center title">MultiSender</h3>
              </q-card-section>
              <q-card-section>
                <q-tabs v-model="tab" active-color="indigo-5">
                  <q-tab name="input">
                    Manual
                  </q-tab>
                  <q-tab name="file">
                    From file
                  </q-tab>
                </q-tabs>
                <q-toggle keep-color color="indigo-5" class="ml-4" dark label="Equal amount" v-model="equal"/>
                <q-toggle keep-color color="indigo-5" dark label="Token" v-model="token"/>
                <q-input dark v-model="amount" v-if="equal" label="Amount" color="indigo-5" outlined
                         class="mt-2 mx-4" dense/>
                <q-input dark v-model="tokenAddress" v-if="token" label="Token Address" color="indigo-5" outlined
                         class="mt-2 mx-4" dense/>
                <q-tab-panels v-model="tab" style="background-color: #1F0954">
                  <q-tab-panel name="input">
                    <q-input dark color="indigo-5" :rows="15" v-model="text" type="textarea" outlined :placeholder="`Insert allocation: separate (;). By format: address${equal?'':';amount'}
Example:
0x0000000000000000000000000000000000000001${equal?'':'; 12.25'}
0x0000000000000000000000000000000000000002${equal?'':'; 5.056'}
0x0000000000000000000000000000000000000003${equal?'':'; 2'}`"/>
                  </q-tab-panel>
                  <q-tab-panel name="file">
                    <q-file dark outlined accept=".json" v-model="file" label="File" color="indigo-5" dense/>
                  </q-tab-panel>
                </q-tab-panels>
              </q-card-section>
              <q-card-actions>
                <q-btn style="width: 100%;" unelevated color="indigo-7" @click="connectWallet" label="Connect wallet"
                       v-if="!addre"/>
                <q-btn style="width: 100%;" unelevated color="indigo-7" @click="t" label="Send transaction" v-else/>
              </q-card-actions>
            </q-card>
          </div>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>
<style>
.z-2, .q-page, .q-page-container, .q-layout, #__nuxt, body {
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
      #1C084A,
      #1F0954,
      #2E1567,
      #3E257A,
      #52398D,
      #6850A0,
      #52398D,
      #52398D,
      #2E1567,
      #1F0954,
      #1C084A
  );;
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