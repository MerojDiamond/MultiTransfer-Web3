import { defineStore } from "pinia";

export const useLayoutStore = defineStore("alerts", {
  state: () => ({ address: null }),
  getters: {
    getAddress: (state) => state.address,
  },
  actions: {
    setAddress(address) {
      this.address = address;
    },
  },
});
