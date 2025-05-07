/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : charge_sql

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 07/05/2025 20:14:15
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `AdminID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '管理员编号',
  `AdminName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `Role` int NOT NULL COMMENT '角色',
  `Password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码（加密）',
  PRIMARY KEY (`AdminID`) USING BTREE,
  CONSTRAINT `chk_role` CHECK (`Role` in (0,1))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------

-- ----------------------------
-- Table structure for charger
-- ----------------------------
DROP TABLE IF EXISTS `charger`;
CREATE TABLE `charger`  (
  `ChargerID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '充电桩编号',
  `Manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属管理员编号',
  `Location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物理位置',
  `Status` int NOT NULL COMMENT '0=正常，1=充电中，2=损坏',
  `PricePerKWh` decimal(6, 2) NOT NULL COMMENT '单位电价（元/度）',
  PRIMARY KEY (`ChargerID`) USING BTREE,
  INDEX `fk_charger_manager`(`Manager` ASC) USING BTREE,
  CONSTRAINT `fk_charger_manager` FOREIGN KEY (`Manager`) REFERENCES `admin` (`AdminID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_status_range` CHECK (`Status` in (0,1,2))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '充电桩信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of charger
-- ----------------------------

-- ----------------------------
-- Table structure for chargingsession
-- ----------------------------
DROP TABLE IF EXISTS `chargingsession`;
CREATE TABLE `chargingsession`  (
  `SessionID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话唯一编号',
  `UserID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '外键 → User.UserID',
  `ChargerID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '外键 → Charger.ChargerID',
  `StartTime` datetime NOT NULL COMMENT '开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `EnergyUsed` decimal(9, 4) NOT NULL COMMENT '使用电量（度）',
  `Cost` decimal(9, 4) NOT NULL COMMENT '本次费用（元）',
  PRIMARY KEY (`SessionID`) USING BTREE,
  INDEX `fk_session_user`(`UserID` ASC) USING BTREE,
  INDEX `fk_session_charger`(`ChargerID` ASC) USING BTREE,
  CONSTRAINT `fk_session_charger` FOREIGN KEY (`ChargerID`) REFERENCES `charger` (`ChargerID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_session_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '充电会话记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chargingsession
-- ----------------------------

-- ----------------------------
-- Table structure for electricvehicle
-- ----------------------------
DROP TABLE IF EXISTS `electricvehicle`;
CREATE TABLE `electricvehicle`  (
  `VehicleID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '电动车唯一编号',
  `UserID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属用户编号',
  `PlateNumber` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '车牌号（如有）',
  `Model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '电动车型号',
  `BatteryCapacity` decimal(5, 2) NOT NULL COMMENT '电池容量（kWh）',
  `CreateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`VehicleID`) USING BTREE,
  INDEX `fk_ev_user`(`UserID` ASC) USING BTREE,
  CONSTRAINT `fk_ev_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '电动车信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of electricvehicle
-- ----------------------------

-- ----------------------------
-- Table structure for income
-- ----------------------------
DROP TABLE IF EXISTS `income`;
CREATE TABLE `income`  (
  `IncomeID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '唯一收入记录编号',
  `TotalRevenue` decimal(9, 4) NOT NULL COMMENT '总收入',
  `TimePeriod` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '时间区间',
  `Notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '备注',
  PRIMARY KEY (`IncomeID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收入结算记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of income
-- ----------------------------

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `NotificationID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知编号',
  `UserID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '外键 → User.UserID',
  `Message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知内容',
  `Time` datetime NOT NULL COMMENT '发送时间',
  PRIMARY KEY (`NotificationID`) USING BTREE,
  INDEX `fk_notification_user`(`UserID` ASC) USING BTREE,
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------

-- ----------------------------
-- Table structure for payment
-- ----------------------------
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment`  (
  `PaymentID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付编号',
  `SessionID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '外键 → ChargingSession.SessionID',
  `Amount` decimal(9, 4) NOT NULL COMMENT '金额',
  `Status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（成功/失败）',
  `Timestamp` datetime NOT NULL COMMENT '支付时间',
  PRIMARY KEY (`PaymentID`) USING BTREE,
  INDEX `fk_payment_session`(`SessionID` ASC) USING BTREE,
  CONSTRAINT `fk_payment_session` FOREIGN KEY (`SessionID`) REFERENCES `chargingsession` (`SessionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment
-- ----------------------------

-- ----------------------------
-- Table structure for permission
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission`  (
  `PermissionID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编号',
  `AdminID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属管理员编号',
  `Module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限模块',
  `AccessLevel` int NOT NULL COMMENT '0 为最高权限',
  PRIMARY KEY (`PermissionID`) USING BTREE,
  INDEX `fk_admin_permission`(`AdminID` ASC) USING BTREE,
  CONSTRAINT `fk_admin_permission` FOREIGN KEY (`AdminID`) REFERENCES `admin` (`AdminID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_access_level_range` CHECK (`AccessLevel` in (0,1,2,3))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permission
-- ----------------------------

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `UserID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户唯一编号',
  `UserName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户姓名',
  `Phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号，仅支持大陆 11 位',
  `Role` int NOT NULL COMMENT '用户角色',
  `Password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码（加密）',
  `Location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所在地理位置',
  PRIMARY KEY (`UserID`) USING BTREE,
  CONSTRAINT `chk_phone_format` CHECK (regexp_like(`Phone`,_utf8mb4'^[1][3-9][0-9]{9}$'))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
