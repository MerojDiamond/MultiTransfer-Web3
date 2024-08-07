// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ["nuxt-quasar-ui", "@nuxtjs/tailwindcss", "@pinia/nuxt"],
  quasar: {
    config: {
      dark: true,
      brand: {
        primary: "#00D094",
      },
    },
  },
  ssr: false,
});
