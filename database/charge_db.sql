/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 90300 (9.3.0)
 Source Host           : localhost:3306
 Source Schema         : charge_db

 Target Server Type    : MySQL
 Target Server Version : 90300 (9.3.0)
 File Encoding         : 65001

 Date: 04/06/2025 22:42:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for appoint
-- ----------------------------
DROP TABLE IF EXISTS `appoint`;
CREATE TABLE `appoint`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` int NOT NULL,
  `charge_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `charge_price` decimal(10, 2) NOT NULL,
  `create_time` datetime NOT NULL,
  `day` date NOT NULL,
  `time` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `state` tinyint NOT NULL DEFAULT 1 COMMENT '1待使用 2充电中 3已完成 4已取消',
  `start_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_appoint_charge`(`charge_id` ASC) USING BTREE,
  INDEX `idx_appoint_user_charge`(`user_id` ASC, `charge_id` ASC) USING BTREE,
  CONSTRAINT `fk_appoint_charge` FOREIGN KEY (`charge_id`) REFERENCES `charge` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_appoint_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_appoint_state` CHECK (`state` in (1,2,3,4))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of appoint
-- ----------------------------
INSERT INTO `appoint` VALUES ('AP000001', 1, 'CH000001', 2.00, '2025-06-04 15:34:44', '2026-06-04', '14:00-16:00', 1, NULL, NULL);
INSERT INTO `appoint` VALUES ('AP000002', 2, 'CH000002', 2.50, '2025-06-04 15:34:44', '2026-06-04', '16:00-18:00', 1, NULL, NULL);
INSERT INTO `appoint` VALUES ('AP000091', 1, 'CH000001', 2.00, '2025-06-04 21:57:33', '2025-06-04', '12:00-14:00', 2, '2025-06-04 21:57:33', NULL);

-- ----------------------------
-- Table structure for charge
-- ----------------------------
DROP TABLE IF EXISTS `charge`;
CREATE TABLE `charge`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '充电桩id',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `station_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `photo` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'common/no_image.jpg',
  `state` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 2报修中',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_charge_station`(`station_id` ASC) USING BTREE,
  CONSTRAINT `fk_charge_station` FOREIGN KEY (`station_id`) REFERENCES `station` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_charge_state` CHECK (`state` in (1,2))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of charge
-- ----------------------------
INSERT INTO `charge` VALUES ('CH000001', '东门1号桩', 'ST000001', 'common/no_image.jpg', 1, 2.00, '普通直流桩');
INSERT INTO `charge` VALUES ('CH000002', '东门2号桩', 'ST000001', 'common/no_image.jpg', 1, 2.50, '快充直流桩');
INSERT INTO `charge` VALUES ('CH000091', '快充桩A', 'ST000001', 'common/no_image.jpg', 1, 1.50, '标准快充直流桩');

-- ----------------------------
-- Table structure for chargingsession
-- ----------------------------
DROP TABLE IF EXISTS `chargingsession`;
CREATE TABLE `chargingsession`  (
  `SessionID` char(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `UserID` int NOT NULL,
  `ChargerID` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `StartTime` datetime NOT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `EnergyUsed` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `Cost` decimal(10, 2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`SessionID`) USING BTREE,
  INDEX `fk_session_user`(`UserID` ASC) USING BTREE,
  INDEX `fk_session_charger`(`ChargerID` ASC) USING BTREE,
  INDEX `idx_charging_time`(`StartTime` ASC) USING BTREE,
  CONSTRAINT `fk_session_charger` FOREIGN KEY (`ChargerID`) REFERENCES `charge` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_session_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chargingsession
-- ----------------------------
INSERT INTO `chargingsession` VALUES ('SESS000001', 1, 'CH000001', '2025-06-04 15:34:44', NULL, 0.00, 0.00);
INSERT INTO `chargingsession` VALUES ('SESS000901', 1, 'CH000001', '2025-06-04 20:57:33', '2025-06-04 21:57:33', 5.20, 7.80);

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL,
  `reply_content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_comment_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES ('CM000001', '充电速度快，满意！', '2025-06-04 15:34:59', '', 1);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `total_price` decimal(10, 2) NOT NULL,
  `user_id` int NOT NULL,
  `charge_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL,
  `state` tinyint NOT NULL DEFAULT 1 COMMENT '1未支付 2已支付',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_orders_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_orders_charge`(`charge_id` ASC) USING BTREE,
  INDEX `idx_order_state`(`state` ASC) USING BTREE,
  CONSTRAINT `fk_orders_charge` FOREIGN KEY (`charge_id`) REFERENCES `charge` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_orders_state` CHECK (`state` in (1,2)),
  CONSTRAINT `chk_orders_total_price` CHECK (`total_price` >= 0)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES ('ORD00001', 10.00, 1, 'CH000001', '2025-06-04 15:34:55', 1);

-- ----------------------------
-- Table structure for repair
-- ----------------------------
DROP TABLE IF EXISTS `repair`;
CREATE TABLE `repair`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` int NOT NULL,
  `charge_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `state` tinyint NOT NULL DEFAULT 1 COMMENT '1未受理 2已受理 3已完成',
  `create_time` datetime NOT NULL,
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_repair_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_repair_charge`(`charge_id` ASC) USING BTREE,
  CONSTRAINT `fk_repair_charge` FOREIGN KEY (`charge_id`) REFERENCES `charge` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_repair_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_repair_state` CHECK (`state` in (1,2,3))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of repair
-- ----------------------------
INSERT INTO `repair` VALUES ('RP000001', 2, 'CH000002', 1, '2025-06-04 15:34:59', '屏幕无显示，无法操作');

-- ----------------------------
-- Table structure for station
-- ----------------------------
DROP TABLE IF EXISTS `station`;
CREATE TABLE `station`  (
  `id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '电站id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `location` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `photo` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'common/no_image.jpg',
  `charge_num` int NOT NULL DEFAULT 0,
  `available_charge_num` int NOT NULL DEFAULT 0,
  `operator_id` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of station
-- ----------------------------
INSERT INTO `station` VALUES ('ST000001', '东门电站', '厦门大学东门', 'common/no_image.jpg', 0, 0, 'OP000001');
INSERT INTO `station` VALUES ('ST000091', '映雪充电站', '厦门大学', 'common/no_image.jpg', 0, 0, 'OP000001');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户密码（加密）',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号（唯一）',
  `head_pic` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'common/no_image.jpg' COMMENT '头像路径',
  `sex` tinyint NOT NULL DEFAULT 3 COMMENT '性别 1男 2女 3未知',
  `role_id` tinyint NOT NULL DEFAULT 1 COMMENT '1普通用户 2管理员',
  `rate` int NOT NULL DEFAULT 100 COMMENT '信誉积分',
  `money` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '账户余额',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  CONSTRAINT `chk_user_rate` CHECK (`rate` between 0 and 100),
  CONSTRAINT `chk_user_sex` CHECK (`sex` in (1,2))
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'alice', '123', '13800000001', 'common/no_image.jpg', 2, 1, 100, 500.00);
INSERT INTO `user` VALUES (2, 'bob', '456', '13800000002', 'common/no_image.jpg', 1, 1, 90, 200.00);
INSERT INTO `user` VALUES (3, 'charlie', '789', '13800000003', 'common/no_image.jpg', 1, 1, 80, 100.00);
INSERT INTO `user` VALUES (4, 'liuchang', '123', '13800000005', 'common/no_image.jpg', 1, 2, 100, 1000.00);
INSERT INTO `user` VALUES (5, 'admin', 'admin123', '13800000006', 'common/no_image.jpg', 1, 2, 100, 0.00);

-- ----------------------------
-- View structure for charging_users
-- ----------------------------
DROP VIEW IF EXISTS `charging_users`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `charging_users` AS select `u`.`username` AS `username`,`a`.`charge_id` AS `charge_id`,`a`.`start_time` AS `start_time`,timestampdiff(MINUTE,`a`.`start_time`,now()) AS `charging_duration`,`c`.`price` AS `price`,`c`.`name` AS `charger_name` from ((`appoint` `a` join `user` `u` on((`a`.`user_id` = `u`.`id`))) join `charge` `c` on((`a`.`charge_id` = `c`.`id`))) where (`a`.`state` = 2);

-- ----------------------------
-- View structure for user_charge_history
-- ----------------------------
DROP VIEW IF EXISTS `user_charge_history`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `user_charge_history` AS select `u`.`username` AS `username`,`s`.`SessionID` AS `SessionID`,`s`.`StartTime` AS `StartTime`,`s`.`EndTime` AS `EndTime`,`s`.`EnergyUsed` AS `EnergyUsed`,`s`.`Cost` AS `Cost` from (`chargingsession` `s` join `user` `u` on((`s`.`UserID` = `u`.`id`))) order by `s`.`EndTime` desc;

-- ----------------------------
-- Event structure for evt_auto_finish_charging
-- ----------------------------
DROP EVENT IF EXISTS `evt_auto_finish_charging`;
delimiter ;;
CREATE EVENT `evt_auto_finish_charging`
ON SCHEDULE
EVERY '10' MINUTE STARTS '2025-06-04 22:09:32'
DO BEGIN
  -- 更新超时充电记录（360分钟 = 6小时）
  UPDATE appoint
  SET state = 3,
      end_time = NOW()
  WHERE state = 2
    AND TIMESTAMPDIFF(MINUTE, start_time, NOW()) > 360;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table appoint
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_appoint_insert_price`;
delimiter ;;
CREATE TRIGGER `trg_appoint_insert_price` BEFORE INSERT ON `appoint` FOR EACH ROW BEGIN
  SET NEW.charge_price = (
    SELECT price FROM charge WHERE id = NEW.charge_id
  );
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table appoint
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_appoint_cancel_release`;
delimiter ;;
CREATE TRIGGER `trg_appoint_cancel_release` AFTER UPDATE ON `appoint` FOR EACH ROW BEGIN
  IF NEW.state = 4 AND OLD.state <> 4 THEN
    UPDATE station
    SET available_charge_num = available_charge_num + 1
    WHERE id = (
      SELECT station_id FROM charge WHERE id = NEW.charge_id
    );
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_reward_after_payment`;
delimiter ;;
CREATE TRIGGER `trg_reward_after_payment` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
  IF NEW.state = 2 AND OLD.state = 1 THEN
    INSERT INTO rate(user_id, score, type, create_time, content, now_score)
    VALUES (
      NEW.user_id, 5, 1, NOW(), '成功支付，奖励信誉分5分！',
      (SELECT rate + 5 FROM user WHERE id = NEW.user_id)
    );
    UPDATE user SET rate = rate + 5 WHERE id = NEW.user_id;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table repair
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_repair_update_charge`;
delimiter ;;
CREATE TRIGGER `trg_repair_update_charge` AFTER INSERT ON `repair` FOR EACH ROW BEGIN
  UPDATE charge SET state = 2 WHERE id = NEW.charge_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table user
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_user_init_money`;
delimiter ;;
CREATE TRIGGER `trg_user_init_money` AFTER INSERT ON `user` FOR EACH ROW BEGIN
  UPDATE user SET money = 10.00 WHERE id = NEW.id; -- 默认送10元
  -- 或插入日志表、发优惠券等
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
