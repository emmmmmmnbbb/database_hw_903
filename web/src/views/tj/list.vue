<template>
	<div class="tj-container">
		<div class="stats-cards">
			<el-card class="stats-card" shadow="hover">
				<template #header>
					<div class="card-header">
						<i class="el-icon-money icon"></i>
						<span>本月销售额</span>
					</div>
				</template>
				<div class="stats-value">{{ monthTj.month }} 元</div>
			</el-card>
			<el-card class="stats-card" shadow="hover">
				<template #header>
					<div class="card-header">
						<i class="el-icon-date icon"></i>
						<span>本日销售额</span>
					</div>
				</template>
				<div class="stats-value">{{ monthTj.day }} 元</div>
			</el-card>
		</div>
		<div class="charts-container">
			<el-card class="chart-card" shadow="hover">
				<template #header>
					<div class="card-header">
						<i class="el-icon-pie-chart icon"></i>
						<span>充电桩类型分布</span>
					</div>
				</template>
				<div ref="pieChartRef" class="chart"></div>
			</el-card>
			<el-card class="chart-card" shadow="hover">
				<template #header>
					<div class="card-header">
						<i class="el-icon-trend-charts icon"></i>
						<span>月度收入趋势</span>
					</div>
				</template>
				<div ref="lineChartRef" class="chart"></div>
			</el-card>
		</div>
	</div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from "vue";
import { axiosPostRequest, getSessionStorage, myEventBus } from "@/util/index.js";
import * as echarts from "echarts";

// 本月统计
const monthTj = ref({});
// 图表DOM引用
const pieChartRef = ref(null);
const lineChartRef = ref(null);
// 图表实例
let pieChart = null;
let lineChart = null;

// 获取统计数据
// 获取统计数据
const getTjData = async () => {
  // 使用虚拟数据替代API调用
  const mockData = {
    // 本月和本日销售额
    month: 3560.50,
    day: 350.00,
    
    // 充电桩类型分布数据（用于饼图）
    chargeMap: {
      "普通直流桩": 1,
      "快充直流桩": 1,
      "标准快充直流充桩": 1,
      "超级快充桩": 0
    },
    
    // 月度收入趋势数据（用于折线图）
    monthlyRevenue: {
      "2025-01": 1250.50,
      "2025-02": 1680.75,
      "2025-03": 2100.25,
      "2025-04": 1850.50,
      "2025-05": 3250.00,
      "2025-06": 3560.50
    }
  };
  
  // 将模拟数据赋值给响应式变量
  monthTj.value = mockData;

  // 渲染图表
  nextTick(() => {
    renderPieChart();
    renderLineChart();
  });
};

// 渲染饼图
const renderPieChart = () => {
	if (pieChart) {
		pieChart.dispose();
	}

	pieChart = echarts.init(pieChartRef.value);

	// 将chargeMap转换为饼图数据
	const pieData = [];
	for (const key in monthTj.value.chargeMap) {
		pieData.push({
			name: key,
			value: monthTj.value.chargeMap[key]
		});
	}

	// 自定义饼图颜色
	const colorPalette = ["#409EFF", "#67C23A", "#E6A23C", "#F56C6C", "#909399", "#9966CC", "#00BFFF", "#FF6A6A"];

	const option = {
		tooltip: {
			trigger: "item",
			formatter: "{a} <br/>{b}: {c} ({d}%)",
			backgroundColor: "rgba(255, 255, 255, 0.8)",
			borderColor: "#ccc",
			borderWidth: 1,
			textStyle: {
				color: "#333"
			}
		},
		legend: {
			orient: "vertical",
			right: 10,
			top: "center",
			data: pieData.map((item) => item.name),
			textStyle: {
				fontSize: 12
			},
			formatter: (name) => {
				const item = pieData.find((data) => data.name === name);
				const percentage = ((item.value / pieData.reduce((acc, cur) => acc + cur.value, 0)) * 100).toFixed(1);
				return `${name}: ${item.value} (${percentage}%)`;
			}
		},
		series: [
			{
				name: "充电桩类型",
				type: "pie",
				radius: ["40%", "70%"],
				center: ["40%", "50%"],
				avoidLabelOverlap: false,
				itemStyle: {
					borderRadius: 8,
					borderColor: "#fff",
					borderWidth: 2
				},
				label: {
					show: true,
					position: "outside",
					formatter: "{b}\n{d}%",
					backgroundColor: "rgba(255, 255, 255, 0.7)",
					borderColor: "#ccc",
					borderWidth: 1,
					borderRadius: 4,
					padding: [2, 4],
					fontSize: 12
				},
				emphasis: {
					label: {
						show: true,
						fontSize: 14,
						fontWeight: "bold"
					},
					itemStyle: {
						shadowBlur: 10,
						shadowOffsetX: 0,
						shadowColor: "rgba(0, 0, 0, 0.5)"
					}
				},
				labelLine: {
					show: true,
					length: 15,
					length2: 10
				},
				data: pieData,
				color: colorPalette
			}
		]
	};

	pieChart.setOption(option);
	window.addEventListener("resize", () => pieChart.resize());
};

// 渲染折线图
const renderLineChart = () => {
	if (lineChart) {
		lineChart.dispose();
	}

	lineChart = echarts.init(lineChartRef.value);

	// 将monthlyRevenue转换为折线图数据
	const months = [];
	const values = [];
	for (const key in monthTj.value.monthlyRevenue) {
		months.push(key);
		values.push(monthTj.value.monthlyRevenue[key]);
	}

	const option = {
		color: ["#20a162"],
		tooltip: {
			trigger: "axis",
			axisPointer: {
				type: "shadow",
				shadowStyle: {
					color: "rgba(0, 0, 0, 0.05)"
				}
			},
			formatter: "{b}<br/>{a0}: {c0} 元",
			backgroundColor: "rgba(255, 255, 255, 0.8)",
			borderColor: "#ccc",
			borderWidth: 1,
			textStyle: {
				color: "#333"
			}
		},
		grid: {
			left: "3%",
			right: "4%",
			bottom: "3%",
			containLabel: true
		},
		xAxis: {
			type: "category",
			data: months,
			axisLabel: {
				rotate: 45,
				interval: 0,
				color: "#606266"
			},
			axisLine: {
				lineStyle: {
					color: "#DCDFE6"
				}
			},
			axisTick: {
				alignWithLabel: true
			}
		},
		yAxis: {
			type: "value",
			name: "收入",
			nameTextStyle: {
				color: "#606266",
				padding: [0, 0, 0, 30]
			},
			axisLabel: {
				formatter: "{value} 元",
				color: "#606266"
			},
			splitLine: {
				lineStyle: {
					color: "#EBEEF5",
					type: "dashed"
				}
			},
			axisLine: {
				show: false
			},
			axisTick: {
				show: false
			}
		},
		series: [
			{
				name: "月度收入",
				type: "line",
				data: values,
				markPoint: {
					data: [
						{ type: "max", name: "最大值" },
						{ type: "min", name: "最小值" }
					],
					symbol: "pin",
					symbolSize: 40,
					itemStyle: {
						color: "#F56C6C"
					}
				},
				markLine: {
					data: [{ type: "average", name: "平均值" }],
					label: {
						formatter: "平均: {c} 元",
						position: "middle"
					},
					lineStyle: {
						color: "#E6A23C",
						type: "dashed",
						width: 2
					}
				},
				lineStyle: {
					width: 4,
					shadowColor: "rgba(0, 0, 0, 0.3)",
					shadowBlur: 10,
					shadowOffsetY: 8
				},
				itemStyle: {
					borderWidth: 2,
					borderColor: "#fff",
					shadowColor: "rgba(0, 0, 0, 0.3)",
					shadowBlur: 5
				},
				smooth: true,
				areaStyle: {
					color: {
						type: "linear",
						x: 0,
						y: 0,
						x2: 0,
						y2: 1,
						colorStops: [
							{
								offset: 0,
								color: "rgba(32, 161, 98, 0.8)"
							},
							{
								offset: 1,
								color: "rgba(32, 161, 98, 0.1)"
							}
						]
					}
				}
			}
		]
	};

	lineChart.setOption(option);
	window.addEventListener("resize", () => lineChart.resize());
};

onMounted(() => {
	getTjData();
});
</script>

<style lang="scss" scoped>
.tj-container {
	padding: 20px;
	background-color: #f5f7fa;
	min-height: calc(100vh - 60px);
}

.stats-cards {
	display: flex;
	gap: 20px;
	margin-bottom: 20px;
}

.stats-card {
	flex: 1;
	text-align: center;
	transition: all 0.3s;
	border-radius: 8px;
	overflow: hidden;

	&:hover {
		transform: translateY(-5px);
		box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
	}

	.card-header {
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 16px;
		font-weight: bold;
		color: #303133;

		.icon {
			margin-right: 8px;
			font-size: 18px;
		}
	}
}

.stats-value {
	font-size: 28px;
	font-weight: bold;
	color: #20a162;
	margin: 15px 0;
}

.charts-container {
	display: flex;
	gap: 20px;
	margin-top: 20px;

	@media (max-width: 768px) {
		flex-direction: column;
	}
}

.chart-card {
	flex: 1;
	transition: all 0.3s;
	border-radius: 8px;
	overflow: hidden;

	&:hover {
		transform: translateY(-5px);
		box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
	}

	.card-header {
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 16px;
		font-weight: bold;
		color: #303133;

		.icon {
			margin-right: 8px;
			font-size: 18px;
		}
	}
}

.chart {
	height: 400px;
	width: 100%;
	padding: 10px;
}
</style>
