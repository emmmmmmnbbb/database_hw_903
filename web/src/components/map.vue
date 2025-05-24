<template>
	<div class="map-container">
		<div v-if="location" style="width: 100%; height: 600px" id="allmap"></div>
	</div>
</template>

<script setup>
import { onMounted, watch } from "vue";

onMounted(() => {
	loadMapScript();
});

const props = defineProps({
	location: {
		type: String,
		default: "123"
	}
});

// 监听location变化并更新输入框值
watch(
	() => props.location,
	(newVal) => {
		if (newVal) {
			const input = document.getElementById("suggestId");
			if (input) {
				input.value = newVal;
			}
		}
	}
);

// 初始化地图
const init = () => {
	let Bmap = window.BMap;
	var map = new Bmap.Map("allmap");
	map.centerAndZoom(new Bmap.Point(104.04263635868074, 30.556100647961866), 11);
	map.setCurrentCity("成都");
	map.enableScrollWheelZoom(true);

	// 创建地址搜索控件
	var locationSearch = new Bmap.LocalSearch(map, {
		renderOptions: { map: map }
	});

	// 创建地理编码器和自动完成
	var geoc = new Bmap.Geocoder();
	var ac = new Bmap.Autocomplete({
		input: "suggestId",
		location: map
	});

	// 创建导航路线实例
	var driving = new Bmap.DrivingRoute(map, {
		renderOptions: {
			map: map,
			autoViewport: true
		}
	});

	// 添加距离显示div
	var distanceDiv = document.createElement("div");
	distanceDiv.style.cssText =
		"position: absolute; top: 70px; right: 10%; background: white; padding: 10px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.2); z-index: 9999; font-size: 14px; font-weight: bold; color: #333; border: 1px solid #ccc; min-width: 150px; text-align: center; display: none;";
	distanceDiv.id = "distanceInfo";
	map.getContainer().appendChild(distanceDiv);

	// 监听导航路线规划完成事件
	driving.setSearchCompleteCallback(function (results) {
		console.log("导航路线规划完成", results);
		if (driving.getStatus() == BMAP_STATUS_SUCCESS) {
			var plan = results.getPlan(0);
			var distance = plan.getDistance(true); // 获取距离，true表示以公里为单位
			var duration = plan.getDuration(true); // 获取时间，true表示以分钟为单位

			// 更新距离显示
			document.getElementById("distanceInfo").style.display = "block";
			document.getElementById(
				"distanceInfo"
			).innerHTML = `<div style="margin-bottom: 5px;">距离目标位置</div><div style="font-size: 16px; color: #e74c3c;">${distance}</div><div style="margin-top: 5px;">预计时间: ${duration}</div>`;
			console.log("显示距离信息:", distance, duration);
		} else {
			document.getElementById("distanceInfo").style.display = "none";
			console.log("导航路线规划失败");
		}
	});

	// 创建一个自定义控件类
	function SearchControl() {
		this.defaultAnchor = BMAP_ANCHOR_TOP_LEFT;
		this.defaultOffset = new Bmap.Size(20, 20);
	}
	// 通过JavaScript的prototype属性继承于BMap.Control
	SearchControl.prototype = new Bmap.Control();
	// 自定义控件必须实现自己的initialize方法,并且将控件的DOM元素返回
	SearchControl.prototype.initialize = function (map) {
		// 创建一个DOM元素
		var div = document.createElement("div");
		div.style.cssText = "background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);";
		div.innerHTML = `
			<div style="margin-bottom: 8px; color: #333; font-size: 14px; font-weight: 500;">
                <i style="margin-right: 5px; color: #3498db;">🔍</i>搜索充电桩
            </div>
			<div style="display: flex; align-items: center;">
                <input type="text" id="suggestId" 
                    style="width: 300px; height: 36px; border: 1px solid #e0e0e0; padding: 5px 12px; 
                    border-radius: 4px; font-size: 14px; outline: none; transition: all 0.3s ease; box-shadow: inset 0 1px 3px rgba(0,0,0,0.05);" 
                    placeholder="输入充电桩位置..." 
                    value="${props.location || ""}"
                    onfocus="this.style.borderColor='#3498db'; this.style.boxShadow='0 0 0 3px rgba(52,152,219,0.1)';"
                    onblur="this.style.borderColor='#e0e0e0'; this.style.boxShadow='inset 0 1px 3px rgba(0,0,0,0.05)';">
                <button id="searchBtn" 
                    style="margin-left: 5px; background: #3498db; color: white; border: none; height: 36px; padding: 0 15px; border-radius: 4px; cursor: pointer; font-weight: 500; transition: all 0.3s ease;"
                    onmouseover="this.style.background='#2980b9';" 
                    onmouseout="this.style.background='#3498db';">
                    搜索
                </button>
            </div>
		`;
		// 添加DOM元素到地图中
		map.getContainer().appendChild(div);

		// 添加搜索按钮点击事件
		document.getElementById("searchBtn").addEventListener("click", function () {
			var searchValue = document.getElementById("suggestId").value;
			if (searchValue) {
				// 使用本地搜索API搜索位置
				locationSearch.search(searchValue);
				console.log("搜索位置:", searchValue);
			}
		});

		// 添加回车键搜索
		document.getElementById("suggestId").addEventListener("keypress", function (e) {
			if (e.key === "Enter") {
				var searchValue = this.value;
				if (searchValue) {
					// 使用本地搜索API搜索位置
					locationSearch.search(searchValue);
					console.log("回车搜索位置:", searchValue);
				}
			}
		});

		// 将DOM元素返回
		return div;
	};
	// 创建控件实例并添加到地图中
	var searchCtrl = new SearchControl();
	map.addControl(searchCtrl);

	// 添加定位控件
	var geolocationControl = new Bmap.GeolocationControl({
		anchor: BMAP_ANCHOR_BOTTOM_RIGHT, // 控件的位置
		showAddressBar: true, // 是否显示信息框
		enableAutoLocation: false // 是否允许浏览器自动定位
	});
	map.addControl(geolocationControl);

	// 添加定位事件监听
	geolocationControl.addEventListener("locationSuccess", function (e) {
		// 定位成功事件
		var address = "";
		address += e.addressComponent.province;
		address += e.addressComponent.city;
		address += e.addressComponent.district;
		address += e.addressComponent.street;
		address += e.addressComponent.streetNumber;

		// 更新输入框的值
		const input = document.getElementById("suggestId");
		if (input && props.location) {
			input.value = props.location;
		}

		// 始终以传入的location为终点进行导航
		if (props.location) {
			// 获取目标位置的坐标
			// 不使用城市参数，让系统自动识别location中包含的城市信息
			geoc.getPoint(props.location, function (endPoint) {
				if (endPoint) {
					console.log("目标位置坐标:", endPoint);
					// 开始导航
					driving.search(e.point, endPoint);

					// 添加起点标记（当前位置）
					var startMarker = new Bmap.Marker(e.point);
					map.addOverlay(startMarker);
					var startInfo = new Bmap.InfoWindow("起点：" + address, {
						width: 200,
						height: 60,
						enableMessage: true
					});
					startMarker.addEventListener("click", function () {
						this.openInfoWindow(startInfo);
					});
					startMarker.openInfoWindow(startInfo);

					// 添加终点标记（目标位置）
					var endMarker = new Bmap.Marker(endPoint);
					map.addOverlay(endMarker);
					var endInfo = new Bmap.InfoWindow("终点：" + props.location, {
						width: 200,
						height: 60,
						enableMessage: true
					});
					endMarker.addEventListener("click", function () {
						this.openInfoWindow(endInfo);
					});
					endMarker.openInfoWindow(endInfo);
				} else {
					console.log("未能解析位置:", props.location);
					// 如果无法解析地址，尝试使用本地搜索来查找位置
					locationSearch.search(props.location);
				}
			});
		} else {
			// 如果没有目标位置，只显示当前位置
			var marker = new Bmap.Marker(e.point);
			map.addOverlay(marker);
			map.centerAndZoom(e.point, 15);

			var infoWindow = new Bmap.InfoWindow("您的位置：" + address, {
				width: 200,
				height: 60,
				enableMessage: true
			});
			marker.addEventListener("click", function () {
				this.openInfoWindow(infoWindow);
			});
			marker.openInfoWindow(infoWindow);
		}
	});

	geolocationControl.addEventListener("locationError", function (e) {
		// 定位失败事件
		alert("定位失败：" + e.message);
	});

	// 页面加载完成后自动定位
	setTimeout(() => {
		geolocationControl.location();
	}, 1000);

	// 添加搜索框事件监听
	ac.addEventListener("onconfirm", function (e) {
		var _value = e.item.value;
		var myValue = _value.province + _value.city + _value.district + _value.street + _value.business;

		// 获取当前位置并规划路线
		var geolocation = new Bmap.Geolocation();
		geolocation.getCurrentPosition(function (r) {
			if (this.getStatus() == BMAP_STATUS_SUCCESS) {
				geoc.getPoint(
					myValue,
					function (point) {
						if (point) {
							driving.search(r.point, point);

							// 添加起点标记（当前位置）
							var startIcon = new Bmap.Icon("https://api.map.baidu.com/images/markers.png", new Bmap.Size(23, 25), {
								offset: new Bmap.Size(10, 25),
								imageOffset: new Bmap.Size(0, 0)
							});
							var startMarker = new Bmap.Marker(r.point, { icon: startIcon });
							map.addOverlay(startMarker);
							var startInfo = new Bmap.InfoWindow(
								`
								<div style="padding: 8px 0;">
									<div style="font-weight: bold; margin-bottom: 5px; color: #3498db;">起点</div>
									<div style="font-size: 13px; color: #666;">当前位置</div>
								</div>
							`,
								{
									width: 220,
									height: 80,
									enableMessage: true
								}
							);
							startMarker.addEventListener("click", function () {
								this.openInfoWindow(startInfo);
							});
							startMarker.openInfoWindow(startInfo);

							// 添加终点标记（搜索位置）
							var endIcon = new Bmap.Icon("https://api.map.baidu.com/images/markers.png", new Bmap.Size(23, 25), {
								offset: new Bmap.Size(10, 25),
								imageOffset: new Bmap.Size(0, -250)
							});
							var endMarker = new Bmap.Marker(point, { icon: endIcon });
							map.addOverlay(endMarker);
							var endInfo = new Bmap.InfoWindow(
								`
								<div style="padding: 8px 0;">
									<div style="font-weight: bold; margin-bottom: 5px; color: #e74c3c;">终点</div>
									<div style="font-size: 13px; color: #666;">${myValue}</div>
								</div>
							`,
								{
									width: 220,
									height: 80,
									enableMessage: true
								}
							);
							endMarker.addEventListener("click", function () {
								this.openInfoWindow(endInfo);
							});
							endMarker.openInfoWindow(endInfo);
						}
					},
					_value.city
				);
			}
		});
	});

	// 为搜索按钮添加事件处理程序（延迟执行确保DOM已加载）
	setTimeout(() => {
		const searchBtn = document.getElementById("searchBtn");
		if (searchBtn) {
			searchBtn.addEventListener("click", function () {
				var searchValue = document.getElementById("suggestId").value;
				if (searchValue) {
					// 先清除之前的搜索结果
					map.clearOverlays();
					// 使用本地搜索API搜索位置
					locationSearch.search(searchValue);
					console.log("点击搜索位置:", searchValue);
				}
			});
		}

		const suggestInput = document.getElementById("suggestId");
		if (suggestInput) {
			suggestInput.addEventListener("keypress", function (e) {
				if (e.key === "Enter") {
					var searchValue = this.value;
					if (searchValue) {
						// 先清除之前的搜索结果
						map.clearOverlays();
						// 使用本地搜索API搜索位置
						locationSearch.search(searchValue);
						console.log("回车搜索位置:", searchValue);
					}
				}
			});
		}
	}, 1500);
};
const loadMapScript = () => {
	// 此处在所需页面引入资源就是，不用再public/index.html中引入
	var script = document.createElement("script");
	script.type = "text/javascript";
	script.className = "loadmap"; // 给script一个类名
	script.src = "https://api.map.baidu.com/getscript?v=3.0&ak=pU2zZkPQFqjdpnlit8RmxsjnEXkPSlji";
	// 此处需要注意：申请ak时，一定要应用类别一定要选浏览器端，不能选服务端，不然地图会报ak无效
	script.onload = () => {
		// 使用script.onload，待资源加载完成，再初始化地图
		init();
	};
	let loadmap = document.getElementsByClassName("loadmap");
	if (loadmap) {
		// 每次append script之前判断一下，避免重复添加script资源标签
		for (var i = 0; i < loadmap.length; i++) {
			document.body.removeChild(loadmap[i]);
		}
	}
	document.body.appendChild(script);
};
</script>

<style scoped>
.map-container {
	position: relative;
	width: 100%;
}

.location-display {
	position: absolute;
	top: -30px;
	left: 10%;
	z-index: 1;
	background: white;
	padding: 5px 10px;
	border-radius: 4px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* 去除水印 */
::v-deep(.BMap_cpyCtrl) {
	display: none;
}

::v-deep(.anchorBL) {
	display: none !important;
}

#allmap {
	/* // 注意给dom宽高，不然地图不出来 */
	width: 80%;
	height: 60%;
	margin: auto;
}
</style>
