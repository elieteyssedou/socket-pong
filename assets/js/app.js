

import css from "../css/app.css"
import "phoenix_html"

import Vue from 'vue'
import Vuex from 'vuex'
import { stateMerge } from 'vue-object-merge'
Vue.use(Vuex)
window.Vue = Vue

import socket from "./socket"
import Game from './Game.vue';

const store = new Vuex.Store({
  state: {
    game: {}
  },
  mutations: {
    updateGame: (state, payload) => stateMerge(state, { game: payload })
  },
  getters: {
    filledPositions(state) {
      const filledPositions = {}

      Object.entries(state.game).forEach((entry) => {
        const value = entry[1]

        if (typeof value === 'object' && typeof value.center === 'object') {
          const { size_x, size_y, center } = value
          let x = Math.round(center.x)
          let y = Math.round(center.y)

          const positions = []

          if (size_x && size_y) {
            for (let sizerY = 0; sizerY < size_y; sizerY++) {
              for (let sizerX = 0; sizerX < size_x; sizerX++) {
                const newX = x - size_x + Math.ceil(size_x / 2.0) + sizerX
                const newY = y - size_y + Math.ceil(size_y / 2.0) + sizerY

                positions.push({ x: newX, y: newY })
              }
            }
          } else {
            positions.push({ x, y })
          }

          positions.forEach(({ x, y }) => {
            if (!filledPositions[x]) {
              filledPositions[x] = {}
            }
            filledPositions[x][y] = true
          })
        }
      })

      return filledPositions
    }
  }
})

let channel = socket.channel("game:1", {})

const timers = {
  1: null,
  2: null
}

const playerEvent = (player, event) => {
  channel.push(event, { player: player })
}

const playerMoveSetting = (player, event) => {
  if (timers[player]) return
  timers[player] = setInterval(() => playerEvent(player, event), 30)
  playerEvent(player, event)
}

const playerStop = (player) => {
  clearInterval(timers[player])
  timers[player] = null
}

document.addEventListener("keydown", event => {
  if (event.keyCode === 87) {
    playerMoveSetting(1, "move_up")
  } else if (event.keyCode === 83) {
    playerMoveSetting(1, "move_down")
  } else if (event.keyCode === 38) {
    playerMoveSetting(2, "move_up")
  } else if (event.keyCode === 40) {
    playerMoveSetting(2, "move_down")
  }
})

document.addEventListener("keyup", event => {
  if (event.keyCode === 83 || event.keyCode === 87) {
    playerStop(1)
  } else if (event.keyCode === 40 || event.keyCode === 38) {
    playerStop(2)
  }
})

channel.on("update", payload => {
  store.commit('updateGame', payload)
})

channel.join().receive("ok", payload => {
  store.commit('updateGame', payload)
}).receive("error", resp => {
  console.log("Unable to join", resp)
})

new Vue({
  el: '#game',
  render: h => h(Game, { props: { store, channel } })
});
