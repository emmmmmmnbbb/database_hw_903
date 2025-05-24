/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : charge_db_903

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 14/05/2025 22:44:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for appoint
-- ----------------------------
DROP TABLE IF EXISTS `appoint`;
CREATE TABLE `appoint`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '预约id',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '预约所属用户id',
  `charge_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '预约所属充电桩id',
  `charge_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '预约所属充电桩名称',
  `charge_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '预约所属充电桩收费',
  `create_time` datetime NOT NULL COMMENT '预约创建时间',
  `day` date NOT NULL COMMENT '预约日期',
  `time` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '预约时间段',
  `state` int NOT NULL DEFAULT 1 COMMENT '预约状态 1: 待使用; 2: 充电中; 3: 已完成',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始充电时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束充电时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of appoint
-- ----------------------------
INSERT INTO `appoint` VALUES ('1LvtH9La', 'cwX8LcGQ', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-21 19:41:12', '2025-03-21', '18:00-20:00', 3, '2025-03-21 19:41:19', '2025-03-21 19:42:33');
INSERT INTO `appoint` VALUES ('34NLKTfE', 'cwX8LcGQ', 'I19HWZSu', '映雪充电桩2', 2.00, '2025-03-19 21:10:32', '2025-03-19', '22:00-24:00', 4, NULL, NULL);
INSERT INTO `appoint` VALUES ('8v9UbTxD', 'cwX8LcGQ', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-20 21:44:47', '2025-03-20', '22:00-24:00', 3, '2025-03-20 22:02:32', '2025-03-20 22:10:30');
INSERT INTO `appoint` VALUES ('DfeC2BsG', 'bPwvDSoC', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-20 13:10:06', '2025-03-20', '13:00-16:00', 3, '2025-03-20 13:11:16', '2025-03-20 13:13:57');
INSERT INTO `appoint` VALUES ('FEkAxIIe', 'cwX8LcGQ', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-21 19:19:52', '2025-03-21', '18:00-20:00', 3, '2025-03-21 19:19:58', '2025-03-21 19:25:52');
INSERT INTO `appoint` VALUES ('OzKuVQv7', 'cwX8LcGQ', 'I19HWZSu', '映雪充电桩2', 2.00, '2025-03-20 22:31:46', '2025-03-20', '22:00-24:00', 3, '2025-03-20 22:31:53', '2025-03-20 22:33:09');
INSERT INTO `appoint` VALUES ('TbrHUyTh', 'bPwvDSoC', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-20 13:14:34', '2025-03-20', '14:00-16:00', 4, NULL, NULL);
INSERT INTO `appoint` VALUES ('ugVoG5f5', 'bPwvQRoC', 'I19HWZSu', '映雪充电桩2', 2.00, '2025-02-14 20:05:17', '2025-02-14', '20:00-24:00', 3, '2025-02-14 20:08:31', '2025-02-14 20:08:38');
INSERT INTO `appoint` VALUES ('WX28Ra4e', 'cwX8LcGQ', '00UVD2Do', '映雪充电桩1', 2.00, '2025-03-26 20:29:50', '2025-03-26', '20:00-22:00', 2, '2025-03-26 20:30:01', NULL);
INSERT INTO `appoint` VALUES ('xXMfs1Ju', 'cwX8LcGQ', 'I19HWZSu', '映雪充电桩2', 2.00, '2025-03-20 22:21:09', '2025-03-20', '22:00-24:00', 3, '2025-03-20 22:21:15', '2025-03-20 22:26:20');

-- ----------------------------
-- Table structure for charge
-- ----------------------------
DROP TABLE IF EXISTS `charge`;
CREATE TABLE `charge`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电桩id',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电桩名称',
  `station_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电桩所属电站id',
  `photo` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'common/no_image.jpg' COMMENT '充电桩图片',
  `state` int NOT NULL DEFAULT 1 COMMENT '充电桩状态 1: 正常; 2: 报修中',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '充电桩收费价格，元/分钟',
  `description` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电桩规格描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of charge
-- ----------------------------
INSERT INTO `charge` VALUES ('00UVD2Do', '映雪充电桩1', '1', '20250319/1742389338101.jpg', 1, 2.00, '厦门大学映雪903充电集团');
INSERT INTO `charge` VALUES ('I19HWZSu', '映雪充电桩2', '1', '20250319/1742395886069.jpg', 1, 2.00, '厦门大学映雪903充电集团');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '留言id',
  `content` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '留言内容',
  `create_time` datetime NOT NULL COMMENT '留言时间',
  `reply_content` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '管理员回复内容',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '留言所属用户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment
-- ----------------------------

-- ----------------------------
-- Table structure for coupon
-- ----------------------------
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `money` bigint NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of coupon
-- ----------------------------
INSERT INTO `coupon` VALUES (9, 5, '5元优惠卷');
INSERT INTO `coupon` VALUES (10, 10, '10元优惠卷');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `add_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (2, 'Mr.', 'Wm8nv3f6Eb', '2023-10-31 07:13:35');
INSERT INTO `notice` VALUES (3, 'Prof.', 'gd9IMZRDkV', '2016-09-04 23:45:26');
INSERT INTO `notice` VALUES (4, '11', '1', '2025-03-20 20:10:51');

-- ----------------------------
-- Table structure for operator
-- ----------------------------
DROP TABLE IF EXISTS `operator`;
CREATE TABLE `operator`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '运营商id',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '运营商名称',
  `description` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '运营商描述',
  `station_num` int NOT NULL DEFAULT 0 COMMENT '运营商下属电站数量',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operator
-- ----------------------------
INSERT INTO `operator` VALUES ('1', 'linzhaoqian', '903高级充电运营商  林赵謙(國内)', 1);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '订单id',
  `total_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '订单总价格',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '订单所属用户id',
  `charge_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '订单所属充电桩id',
  `charge_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '订单所属充电桩名称',
  `create_time` datetime NOT NULL COMMENT '订单创建时间-充电结束时间',
  `state` int NOT NULL DEFAULT 1 COMMENT '订单状态 1: 未支付; 2: 已支付',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES ('IfkgyiL5', 1000.00, 'cwX8LcGQ', '00UVD2Do', '映雪充电桩1', '2025-03-21 19:42:34', 2);

-- ----------------------------
-- Table structure for rate
-- ----------------------------
DROP TABLE IF EXISTS `rate`;
CREATE TABLE `rate`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '积分明细id',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '积分明细所属用户id',
  `warn_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '积分明细所属告警id',
  `type` int NOT NULL DEFAULT 1 COMMENT '积分变化类型 1: 增加; 2: 减少',
  `score` int NOT NULL DEFAULT 0 COMMENT '积分变化分数',
  `create_time` datetime NOT NULL COMMENT '积分明细变动时间',
  `content` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '积分变动描述',
  `now_score` int NOT NULL DEFAULT 0 COMMENT '变动后的积分',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rate
-- ----------------------------
INSERT INTO `rate` VALUES ('8oglfZ0v', 'cwX8LcGQ', '', 1, 5, '2025-03-20 22:10:48', '成功支付，奖励信誉分5分！', 100);
INSERT INTO `rate` VALUES ('aR5NtICw', 'cwX8LcGQ', '', 1, 5, '2025-03-20 22:33:22', '成功支付，奖励信誉分5分！', 100);
INSERT INTO `rate` VALUES ('DvyqYKKz', 'bPwvDSoC', '', 1, 5, '2025-03-20 13:14:05', '成功支付，奖励信誉分5分！', 100);
INSERT INTO `rate` VALUES ('kghphe0I', 'cwX8LcGQ', '', 1, 5, '2025-03-20 22:28:00', '成功支付，奖励信誉分5分！', 100);
INSERT INTO `rate` VALUES ('mO5g5MMf', 'cwX8LcGQ', '', 1, 5, '2025-03-20 22:35:27', '成功支付，奖励信誉分5分！', 100);
INSERT INTO `rate` VALUES ('P5Sdnyjl', 'cwX8LcGQ', '', 1, 5, '2025-03-20 22:34:35', '成功支付，奖励信誉分5分！', 100);

-- ----------------------------
-- Table structure for repair
-- ----------------------------
DROP TABLE IF EXISTS `repair`;
CREATE TABLE `repair`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修id',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修所属用户id',
  `charge_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修所属充电桩id',
  `state` int NOT NULL DEFAULT 1 COMMENT '报修状态 1: 未受理; 2: 已受理; 3: 已完成',
  `create_time` datetime NOT NULL COMMENT '报修时间',
  `charge_name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修所属充电桩名称',
  `username` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修所属用户昵称',
  `description` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '报修内容描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of repair
-- ----------------------------

-- ----------------------------
-- Table structure for station
-- ----------------------------
DROP TABLE IF EXISTS `station`;
CREATE TABLE `station`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '电站id',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '电站名称',
  `location` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '电站地址',
  `photo` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'common/no_image.jpg' COMMENT '电站图片',
  `charge_num` int NOT NULL DEFAULT 0 COMMENT '电站的充电桩总数量',
  `available_charge_num` int NOT NULL DEFAULT 0 COMMENT '电站的可用充电桩数量',
  `operator_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '电站所属运营商id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of station
-- ----------------------------
INSERT INTO `station` VALUES ('1', '站点', '全国', 'common/no_image.jpg', 3, 3, '1');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '用户id',
  `username` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '用户昵称',
  `password` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '用户密码',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '用户手机号',
  `head_pic` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'common/no_image.jpg' COMMENT '用户头像',
  `sex` int NOT NULL DEFAULT 3 COMMENT '用户性别 1: 男; 2: 女; 3: 未知',
  `role_id` int NOT NULL DEFAULT 1 COMMENT '用户角色 1: 普通用户; 2: 管理员',
  `rate` int NOT NULL DEFAULT 100 COMMENT '信誉积分',
  `money` decimal(10, 2) NULL DEFAULT NULL COMMENT '余额',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('bPwvDSoC', 'liukai', '123', '11111111111', 'common/no_image.jpg', 1, 1, 100, 100.00);
INSERT INTO `user` VALUES ('bPwvQRoC', 'liuchang', '123', '22222222222', 'common/no_image.jpg', 1, 2, 100, 100.00);

-- ----------------------------
-- Table structure for user_coupon
-- ----------------------------
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `coupon_id` int NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `money` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_coupon
-- ----------------------------
INSERT INTO `user_coupon` VALUES (15, 'cwX8LcGQ', 9, '5元优惠卷', '5', '1');
INSERT INTO `user_coupon` VALUES (16, 'cwX8LcGQ', 10, '10元优惠卷', '10', '1');

-- ----------------------------
-- Table structure for warn
-- ----------------------------
DROP TABLE IF EXISTS `warn`;
CREATE TABLE `warn`  (
  `id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '告警id',
  `user_id` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '告警所属用户id',
  `content` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '告警内容描述',
  `create_time` datetime NOT NULL COMMENT '告警产生时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of warn
-- ----------------------------

-- ----------------------------
-- Table structure for chargingsession
-- ----------------------------
DROP TABLE IF EXISTS `chargingsession`;
CREATE TABLE `chargingsession`  (
  `SessionID` char(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电会话ID',
  `UserID` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电用户ID',
  `ChargerID` char(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '充电桩ID',
  `StartTime` datetime NOT NULL COMMENT '开始充电时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT '结束充电时间',
  `EnergyUsed` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '充电使用能量 (kWh)',
  `Cost` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '充电费用 (元)',
  PRIMARY KEY (`SessionID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
