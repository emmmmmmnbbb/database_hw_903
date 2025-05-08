<template>
    <div id="app">
        <top-nav />
        <div class="main-content">
            <router-view></router-view>
        </div>
    </div>
</template>

<script>
import TopNav from './components/TopNav.vue'

export default {
    name: 'App',
    components: {
        TopNav
    }
}
</script>

<style>
#app {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.main-content {
    flex: 1;
    padding: 20px;
    background-color: #f5f5f5;
}
</style>
