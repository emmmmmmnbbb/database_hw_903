import { defineConfig, loadEnv } from "vite";
import vue from "@vitejs/plugin-vue";
import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";
import ElementPlus from "unplugin-element-plus/vite";
import path from "path";
export default defineConfig(({ command, mode }) => {
	// 如果是 npm run dev  则command 的值是 serve
	// 如果是npm run build  则command的值是 build
	// 但是如果配置了 mode='XXXXX'  则前面所说的command 会失效
	console.log(command);
	console.log(mode);
	const env = loadEnv(mode, process.cwd());
	return {
		plugins: [
			vue(),
			AutoImport({
				resolvers: [
					ElementPlusResolver({
						exclude: new RegExp(/^(?!.*loading-directive).*$/)
					})
				]
			}),
			Components({
				resolvers: [ElementPlusResolver()]
			}),
			ElementPlus({
				useSource: true
			})
		],
		resolve: {
			// 配置路径别名
			alias: {
				"@": path.resolve("./src"),
				"~": path.resolve("./src")
			}
		},
		server: {
			host: "0.0.0.0", // 配置localhost、本机IP地址
			port: 7777, // 端口号
			hmr: true, // 热更新
			open: true, // 自动打开
			proxy: {
				"/api": {
					target: "http://127.0.0.1:5000",// 目标地址
					rewrite: (path) => path.replace(/^\/api/, ""),
					changeOrigin: true
				}
			}
		},
		css: {
			preprocessorOptions: {
				scss: {
					charset: false
				}
			}
		}
	};
});
