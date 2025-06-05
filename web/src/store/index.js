import { defineStore } from "pinia";
const userInfo = JSON.parse(localStorage.getItem("userInfo"));
const menuList = [
	{
		id: 1,
		icon: "HomeFilled",
		name: "首页",
		path: "/index"
	},
	{
		id: 2,
		icon: "List",
		name: "统计管理",
		path: "/tj",
		// roles: [2], // 只有管理员可见
		children: [
			{
				id: 21,
				icon: "List",
				name: "统计管理",
				path: "/tjList"
			}
		]
	},



	{
		id: 3,
		icon: "UserFilled",
		name: "用户管理",
		path: "/user",
		// roles: [2], // 只有管理员可见
		children: [
			{
				id: 31,
				icon: "List",
				name: "用户列表",
				path: "/userList"
			}
		]
	},
	{
		id: 4,
		icon: "List",
		name: "公告管理",
		// roles: [2], // 只有管理员可见
		path: "/notice",
		children: [
			{
				id: 5,
				icon: "List",
				name: "公告列表",
				path: "/noticeList"
			}
		]
	},
	// ------------------------------
	// {
	// 	id: 6,
	// 	icon: "List",
	// 	name: "优惠券管理",
	// 	path: "/coupon",
	// 	children: [
	// 		{
	// 			id: 7,
	// 			icon: "List",
	// 			name: "优惠券列表",
	// 			path: "/couponList"
	// 		},
	// 		{
	// 			id: 8,
	// 			icon: "List",
	// 			name: "我的优惠券",
	// 			path: "/couponMyList"
	// 		}
	// 	]
	// },
	// ------------------------------
	{
		id: 8,
		icon: "SetUp",
		name: "充电桩管理",
		path: "/charge",
		children: [
			{
				id: 9,
				icon: "List",
				name: "充电桩列表",
				path: "/chargeList"
			}
		]
	},
	{
		id: 10,
		icon: "AlarmClock",
		name: "预约管理",
		// roles: [2], // 只有管理员可见
		path: "/appoint",
		children: [
			{
				id: 11,
				icon: "List",
				name: "预约列表",
				path: "/appointList"
			}
		]
	},
	{
		id: 101,
		icon: "Open",
		name: "开始充电",
		path: "/startAppoint"
	},
	{
		id: 102,
		icon: "TurnOff",
		name: "结束充电",
		path: "/endAppoint"
	},
	{
		id: 12,
		icon: "Money",
		name: "订单管理",
		// roles: [2], // 只有管理员可见
		path: "/order",
		children: [
			{
				id: 13,
				icon: "List",
				name: "订单列表",
				path: "/orderList"
			}
		]
	},
	// {
	//   id: 15,
	//   icon: "Warning",
	//   name: "告警管理",
	//   path: "/warn",
	//   children: [
	//     {
	//       id: 16,
	//       icon: "List",
	//       name: "告警列表",
	//       path: "/warnList",
	//     },
	//   ],
	// },
	{
		id: 17,
		icon: "ChatDotRound",
		name: "留言管理",
		// roles: [2], // 只有管理员可见
		path: "/comment",
		children: [
			{
				id: 18,
				icon: "List",
				name: "留言列表",
				path: "/commentList"
			}
		]
	},
	{
		id: 19,
		icon: "ChatDotRound",
		name: "报修管理",
		// roles: [2], // 只有管理员可见
		path: "/repair",
		children: [
			{
				id: 20,
				icon: "List",
				name: "报修列表",
				path: "/repairList"
			}
		]
	}
]
const usePiniaStore = defineStore("piniaStore", {
	state: () => {
		return {
			// 是否折叠菜单
			isCollapse: false,
			// 菜单数据
			menuList: menuList
		};
	},
	actions: {
		setCollapse(value) {
			this.isCollapse = !value;
		}
	}
});

export default usePiniaStore;
