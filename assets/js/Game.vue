<template>
  <div id="game">
    <div class='board-container'>
      <div class='bar left' v-bind:class="{ fadebar: !ball_hits_left }"></div>
      <div class='map'>
        <div class='row' v-for="y in store.state.game.size_y">
          <span class='cell' v-for="x in store.state.game.size_x" v-bind:class="something_at(x, y) ? 'filled' : 'empty'"></span>
        </div>
      </div>
      <div class='bar right' v-bind:class="{ fadebar: !ball_hits_right }"></div>
    </div>

    <div class="info-row">
      <div v-if="store.state.game.player_1">
        <div class='label bold'>PLAYER 1</div>
        <div class='label'>{{store.state.game.player_1.score}}</div>
      </div>

      <button class='button' v-on:click="channel.push('reset')">
        NEW GAME
      </button>

      <div v-if="store.state.game.player_2">
        <div class='label bold'>PLAYER 2</div>
        <div class='label'>{{store.state.game.player_2.score}}</div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['store', 'channel'],

    computed: {
      ball_hits_left: function () {
        const ball = this.$props.store.state.game.ball
        if (!ball) return false
        return ball.center.x <= 1
      },

      ball_hits_right: function () {
        const ball = this.$props.store.state.game.ball
        if (!ball) return false
        return ball.center.x >= this.$props.store.state.game.size_x
      }
    },

    methods: {
      something_at: function (x, y) {
        const filledPositions = this.$props.store.getters.filledPositions

        if (filledPositions[x] && filledPositions[x][y]) {
          return true
        }
        return false
      }
    }
  };
</script>
