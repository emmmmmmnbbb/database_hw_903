/*
 Navicat Premium Dump SQL

 Source Server         : charge
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : charge_sql

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 07/05/2025 23:41:53
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '充电桩信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '充电会话记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '电动车信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收入结算记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户通知表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员权限表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('666', 'lc', '18510207636', 0, '123456', '1');

SET FOREIGN_KEY_CHECKS = 1;

-- 插入管理员信息
INSERT INTO admin (AdminID, AdminName, Email) VALUES
('001', '管理员1', 'admin1@xmu.edu.cn'),
('002', '管理员2', 'admin2@xmu.edu.cn'),
('003', '管理员3', 'admin3@xmu.edu.cn'),
('004', '管理员4', 'admin4@xmu.edu.cn'),
('005', '管理员5', 'admin5@xmu.edu.cn');

-- 插入用户信息
INSERT INTO user (UserID, UserName, Phone, Role, Password, Location) VALUES
('U0001', 'user1', '13800000001', 1, 'pass1', '厦门大学南光楼'),
('U0002', 'user2', '13800000002', 1, 'pass2', '厦门大学南光楼'),
('U0003', 'user3', '13800000003', 1, 'pass3', '厦门大学芙蓉楼'),
('U0004', 'user4', '13800000004', 1, 'pass4', '厦门大学芙蓉楼'),
('U0005', 'user5', '13800000005', 1, 'pass5', '厦门大学南光楼'),
('U0006', 'user6', '13800000006', 1, 'pass6', '厦门大学建南楼'),
('U0007', 'user7', '13800000007', 1, 'pass7', '厦门大学建南楼'),
('U0008', 'user8', '13800000008', 1, 'pass8', '厦门大学芙蓉楼'),
('U0009', 'user9', '13800000009', 1, 'pass9', '厦门大学芙蓉楼'),
('U0010', 'user10', '13800000010', 1, 'pass10', '厦门大学建南楼');

-- 插入充电桩信息
INSERT INTO charger (ChargerID, Manager, Location, Status, PricePerKWh) VALUES
('C0001', '101', '南光楼', 1, 1.23),
('C0002', '102', '上弦场', 2, 1.37),
('C0003', '103', '化学楼', 0, 1.21),
('C0004', '104', '海韵公寓', 1, 1.29),
('C0005', '100', '建南大会堂', 2, 1.39),
('C0006', '101', '升旗广场', 0, 1.15),
('C0007', '102', '情人谷', 1, 1.26),
('C0008', '103', '嘉庚楼群', 2, 1.4),
('C0009', '104', '校医院', 0, 1.13),
('C0010', '100', '芙蓉隧道', 1, 1.18),
('C0011', '101', '南光楼', 2, 1.17),
('C0012', '102', '上弦场', 0, 1.23),
('C0013', '103', '化学楼', 1, 1.24),
('C0014', '104', '海韵公寓', 2, 1.32),
('C0015', '100', '建南大会堂', 0, 1.36);

-- 插入充电会话信息
INSERT INTO chargingsession (SessionID, UserID, ChargerID, StartTime, EndTime, EnergyUsed, Cost) VALUES
('S0001', 'U0001', 'C1001', '2025-05-07 13:59:02', '2025-05-07 15:59:02', 8.45, 11.01),
('S0002', 'U0002', 'C1002', '2025-05-06 12:59:02', '2025-05-06 14:59:02', 6.05, 7.0),
('S0003', 'U0003', 'C1003', '2025-05-05 11:59:02', '2025-05-05 13:59:02', 12.45, 15.73),
('S0004', 'U0004', 'C1004', '2025-05-04 10:59:02', '2025-05-04 12:59:02', 12.87, 17.8),
('S0005', 'U0005', 'C1005', '2025-05-03 09:59:02', '2025-05-03 11:59:02', 6.46, 7.26),
('S0006', 'U0006', 'C1006', '2025-05-02 08:59:02', '2025-05-02 10:59:02', 6.91, 7.61),
('S0007', 'U0007', 'C1007', '2025-05-01 07:59:02', '2025-05-01 09:59:02', 14.72, 16.44),
('S0008', 'U0008', 'C1008', '2025-04-30 06:59:02', '2025-04-30 08:59:02', 11.22, 13.92),
('S0009', 'U0009', 'C1009', '2025-04-29 05:59:02', '2025-04-29 07:59:02', 14.4, 16.6),
('S0010', 'U0010', 'C1010', '2025-04-28 04:59:02', '2025-04-28 06:59:02', 6.7, 8.52);


-- 创建日志表
CREATE TABLE IF NOT EXISTS session_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    SessionID VARCHAR(20),
    UserID VARCHAR(20),
    ChargerID VARCHAR(20),
    StopTime DATETIME,
    Cost DECIMAL(10,2)
);

-- 创建触发器
DELIMITER $$
CREATE TRIGGER trg_after_stop_charging
AFTER UPDATE ON chargingsession
FOR EACH ROW
BEGIN
    IF NEW.EndTime IS NOT NULL AND OLD.EndTime IS NULL THEN
        INSERT INTO session_log(SessionID, UserID, ChargerID, StopTime, Cost)
        VALUES (NEW.SessionID, NEW.UserID, NEW.ChargerID, NEW.EndTime, NEW.Cost);
    END IF;
END$$
DELIMITER ;

