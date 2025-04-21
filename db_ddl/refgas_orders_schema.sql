-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: refgas_orders
-- ------------------------------------------------------
-- Server version	10.6.19-15-MariaDB-enterprise

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `analysis_type`
--

DROP TABLE IF EXISTS `analysis_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis_type` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` tinytext CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `calibrations_fill_view`
--

DROP TABLE IF EXISTS `calibrations_fill_view`;
/*!50001 DROP VIEW IF EXISTS `calibrations_fill_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `calibrations_fill_view` (
  `idx` tinyint NOT NULL,
  `serial_number` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `time` tinyint NOT NULL,
  `species` tinyint NOT NULL,
  `mixratio` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `pressure` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `location` tinyint NOT NULL,
  `regulator` tinyint NOT NULL,
  `notes` tinyint NOT NULL,
  `mod_date` tinyint NOT NULL,
  `meas_unc` tinyint NOT NULL,
  `scale_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `run_number` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `fill_date` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `calrequest`
--

DROP TABLE IF EXISTS `calrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calrequest` (
  `num` mediumint(8) NOT NULL AUTO_INCREMENT,
  `product_num` mediumint(8) NOT NULL DEFAULT 0,
  `calservice_num` tinyint(3) NOT NULL DEFAULT 0,
  `analysis_type_num` tinyint(3) NOT NULL DEFAULT 0,
  `calrequest_status_num` tinyint(3) NOT NULL DEFAULT 0,
  `target_value` varchar(20) NOT NULL DEFAULT '',
  `analysis_value` varchar(20) NOT NULL DEFAULT '',
  `analysis_repeatability` varchar(20) NOT NULL DEFAULT '',
  `analysis_reference_scale` varchar(30) NOT NULL DEFAULT '',
  `analysis_submit_datetime` datetime DEFAULT NULL,
  `analysis_submit_user` varchar(20) DEFAULT NULL,
  `analysis_calibrations_selected` text DEFAULT NULL,
  `comments` text NOT NULL DEFAULT ' ',
  `sort_order` int(11) DEFAULT NULL,
  `co2c13_value` decimal(12,3) DEFAULT NULL,
  `co2o18_value` decimal(12,3) DEFAULT NULL,
  `num_calibrations` int(11) DEFAULT NULL,
  `highlight_comments` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`num`),
  KEY `cs_status` (`calservice_num`,`calrequest_status_num`),
  KEY `prod` (`product_num`)
) ENGINE=MyISAM AUTO_INCREMENT=12350 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `refgas_orders`.`calrequest_BEFORE_UPDATE` BEFORE UPDATE ON `calrequest` FOR EACH ROW
BEGIN
	/*If updating the submit info (proxy of cals selected for multiple cols), delete any related.  Assumes
    caller will then insert new selections*/
	if (old.analysis_calibrations_selected!=new.analysis_calibrations_selected ) then
		delete from calrequest_calibrations where calrequest_num=old.num;
	end if;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `refgas_orders`.`calrequest_BEFORE_DELETE` BEFORE DELETE ON `calrequest` FOR EACH ROW
BEGIN
	delete from calrequest_calibrations where calrequest_num=old.num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `calrequest_calibrations`
--

DROP TABLE IF EXISTS `calrequest_calibrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calrequest_calibrations` (
  `calrequest_num` int(11) NOT NULL,
  `calibrations_idx` int(11) NOT NULL,
  PRIMARY KEY (`calrequest_num`,`calibrations_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calrequest_status`
--

DROP TABLE IF EXISTS `calrequest_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calrequest_status` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `color_html` char(7) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` tinytext CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calrequests_20180605`
--

DROP TABLE IF EXISTS `calrequests_20180605`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calrequests_20180605` (
  `num` mediumint(8) NOT NULL DEFAULT 0,
  `product_num` mediumint(8) NOT NULL,
  `calservice_num` tinyint(3) NOT NULL,
  `analysis_type_num` tinyint(3) NOT NULL,
  `calrequest_status_num` tinyint(3) NOT NULL,
  `target_value` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `analysis_value` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `analysis_repeatability` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `analysis_reference_scale` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `analysis_submit_datetime` datetime NOT NULL,
  `analysis_submit_user` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `analysis_calibrations_selected` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `co2c13_value` float DEFAULT NULL,
  `co2o18_value` float DEFAULT NULL,
  `num_calibrations` int(11) DEFAULT NULL,
  `highlight_comments` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calservice`
--

DROP TABLE IF EXISTS `calservice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calservice` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `abbr_html` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `name` varchar(60) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `unit` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `unit_html` varchar(50) NOT NULL,
  `reference_scale` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `reference_scale_span_min` smallint(5) NOT NULL DEFAULT 9999,
  `reference_scale_span_max` smallint(5) NOT NULL DEFAULT 9999,
  `period_of_validity` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `estimated_processing_days` tinyint(3) NOT NULL DEFAULT 42,
  `parameter_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calservice_user`
--

DROP TABLE IF EXISTS `calservice_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calservice_user` (
  `calservice_num` tinyint(3) NOT NULL,
  `contact_num` tinyint(3) NOT NULL,
  PRIMARY KEY (`calservice_num`,`contact_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(200) NOT NULL,
  `email` varchar(150) NOT NULL,
  `customer_id` varchar(150) NOT NULL,
  `pw` varchar(64) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(150) DEFAULT NULL,
  `fax` varchar(150) DEFAULT NULL,
  `mobile` varchar(150) DEFAULT NULL,
  `street` varchar(150) DEFAULT NULL,
  `zip` varchar(200) DEFAULT NULL,
  `city` varchar(200) DEFAULT NULL,
  `country` varchar(200) DEFAULT NULL,
  `comments` varchar(250) DEFAULT NULL,
  `valid_id` smallint(6) DEFAULT NULL,
  `create_time` datetime DEFAULT current_timestamp(),
  `create_by` int(11) DEFAULT 0,
  `change_time` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `change_by` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_user_login` (`login`),
  UNIQUE KEY `email` (`email`,`customer_id`),
  KEY `FK_customer_user_create_by_id` (`create_by`),
  KEY `FK_customer_user_change_by_id` (`change_by`),
  KEY `FK_customer_user_valid_id_id` (`valid_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1178 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder`
--

DROP TABLE IF EXISTS `cylinder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder` (
  `num` mediumint(8) NOT NULL AUTO_INCREMENT,
  `id` varchar(15) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `recertification_date` date NOT NULL DEFAULT '9999-12-31',
  `cylinder_size_num` tinyint(3) NOT NULL DEFAULT 0,
  `cylinder_type_num` tinyint(3) NOT NULL DEFAULT 0,
  `cylinder_status_num` tinyint(3) NOT NULL DEFAULT 0,
  `cylinder_checkin_status_num` tinyint(3) NOT NULL DEFAULT 0,
  `location_num` smallint(3) NOT NULL DEFAULT 1,
  `location_comments` tinytext NOT NULL DEFAULT '',
  `location_datetime` datetime NOT NULL,
  `location_action_user` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`num`),
  UNIQUE KEY `unique_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4366 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder_checkin_notes`
--

DROP TABLE IF EXISTS `cylinder_checkin_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder_checkin_notes` (
  `cylinder_num` int(11) NOT NULL,
  `fill_code` varchar(1) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `next_checkin_notes` varchar(255) DEFAULT NULL,
  `int_cal_on_next_checkin` int(11) NOT NULL DEFAULT 0,
  `fin_cal_on_next_checkin` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`cylinder_num`,`fill_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder_location`
--

DROP TABLE IF EXISTS `cylinder_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder_location` (
  `cylinder_num` mediumint(8) NOT NULL,
  `location_num` smallint(3) unsigned NOT NULL,
  `location_comments` tinytext NOT NULL,
  `location_datetime` datetime NOT NULL,
  `location_action_user` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder_size`
--

DROP TABLE IF EXISTS `cylinder_size`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder_size` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(10) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` tinytext CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder_status`
--

DROP TABLE IF EXISTS `cylinder_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder_status` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cylinder_type`
--

DROP TABLE IF EXISTS `cylinder_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cylinder_type` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(10) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` tinytext CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intended_uses`
--

DROP TABLE IF EXISTS `intended_uses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intended_uses` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `abbr` varchar(45) DEFAULT NULL,
  `project_num` int(11) NOT NULL,
  `reference` tinyint(4) NOT NULL DEFAULT 0,
  `standard` tinyint(4) NOT NULL DEFAULT 0,
  `target` tinyint(4) NOT NULL DEFAULT 0,
  `working` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`),
  KEY `projsite` (`project_num`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Intended uses for orders/tanks.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location` (
  `num` smallint(3) unsigned NOT NULL AUTO_INCREMENT,
  `active_status` tinyint(3) NOT NULL DEFAULT 1,
  `name` tinytext NOT NULL DEFAULT '',
  `abbr` varchar(50) NOT NULL DEFAULT '',
  `address` text NOT NULL DEFAULT '',
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`num`),
  UNIQUE KEY `abbr` (`abbr`)
) ENGINE=MyISAM AUTO_INCREMENT=254 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_customer`
--

DROP TABLE IF EXISTS `order_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_customer` (
  `order_num` int(11) NOT NULL,
  `customer_user_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_status`
--

DROP TABLE IF EXISTS `order_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_status` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(30) NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_tbl`
--

DROP TABLE IF EXISTS `order_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_tbl` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `creation_datetime` datetime NOT NULL,
  `due_date` date NOT NULL,
  `MOU_number` varchar(50) NOT NULL DEFAULT '',
  `organization` varchar(50) NOT NULL DEFAULT '',
  `primary_customer_user_id` int(11) NOT NULL DEFAULT 0,
  `shipping_location_num` smallint(3) unsigned DEFAULT 0,
  `order_status_num` tinyint(3) NOT NULL,
  `comments` text DEFAULT '',
  `invoice_submit_dt` date DEFAULT NULL,
  `invoice_cost` decimal(10,2) DEFAULT NULL,
  `ship_date` date DEFAULT NULL,
  `ship_cost` decimal(10,2) DEFAULT NULL,
  `expedite` tinyint(3) DEFAULT 0,
  PRIMARY KEY (`num`),
  KEY `org` (`organization`),
  KEY `MOU` (`MOU_number`)
) ENGINE=MyISAM AUTO_INCREMENT=1466 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_tbl_20181002`
--

DROP TABLE IF EXISTS `order_tbl_20181002`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_tbl_20181002` (
  `num` int(11) NOT NULL DEFAULT 0,
  `creation_datetime` datetime NOT NULL,
  `due_date` date NOT NULL,
  `MOU_number` varchar(50) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `organization` varchar(50) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `primary_customer_user_id` int(11) NOT NULL,
  `shipping_location_num` smallint(3) unsigned NOT NULL,
  `order_status_num` tinyint(3) NOT NULL,
  `comments` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `num` mediumint(8) NOT NULL AUTO_INCREMENT,
  `order_num` mediumint(8) NOT NULL DEFAULT 0,
  `cylinder_num` mediumint(8) NOT NULL DEFAULT 0,
  `fill_code` varchar(1) NOT NULL DEFAULT '',
  `cylinder_size_num` tinyint(3) NOT NULL DEFAULT 0,
  `product_status_num` tinyint(3) NOT NULL DEFAULT 0,
  `comments` text NOT NULL DEFAULT '',
  `intended_use` int(11) DEFAULT NULL,
  `intended_site` int(11) DEFAULT NULL,
  `sort_num` int(11) DEFAULT NULL COMMENT 'Arbitrary sort col for use in cylinder filling functions',
  PRIMARY KEY (`num`),
  KEY `ord` (`order_num`),
  KEY `cyl` (`cylinder_num`),
  KEY `iu` (`intended_use`),
  KEY `is` (`intended_site`)
) ENGINE=MyISAM AUTO_INCREMENT=6908 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_status`
--

DROP TABLE IF EXISTS `product_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_status` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(20) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` tinytext CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `rgm_calrequest_view`
--

DROP TABLE IF EXISTS `rgm_calrequest_view`;
/*!50001 DROP VIEW IF EXISTS `rgm_calrequest_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `rgm_calrequest_view` (
  `request_num` tinyint NOT NULL,
  `product_num` tinyint NOT NULL,
  `order_num` tinyint NOT NULL,
  `calservice_num` tinyint NOT NULL,
  `calrequest_status_num` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `status_color` tinyint NOT NULL,
  `product_status_num` tinyint NOT NULL,
  `prod_status` tinyint NOT NULL,
  `species` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `cylinder_num` tinyint NOT NULL,
  `sort_num` tinyint NOT NULL,
  `cylinder_id` tinyint NOT NULL,
  `target_value` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `analysis_type_num` tinyint NOT NULL,
  `analysis_type` tinyint NOT NULL,
  `analysis_comments` tinyint NOT NULL,
  `due_date` tinyint NOT NULL,
  `MOU_number` tinyint NOT NULL,
  `organization` tinyint NOT NULL,
  `order_status_num` tinyint NOT NULL,
  `order_status` tinyint NOT NULL,
  `primary_customer_email` tinyint NOT NULL,
  `current_location` tinyint NOT NULL,
  `current_location_comments` tinyint NOT NULL,
  `analysis_value` tinyint NOT NULL,
  `analysis_repeatability` tinyint NOT NULL,
  `analysis_reference_scale` tinyint NOT NULL,
  `co2c13_value` tinyint NOT NULL,
  `co2o18_value` tinyint NOT NULL,
  `analysis_submit_datetime` tinyint NOT NULL,
  `analysis_submit_user` tinyint NOT NULL,
  `analysis_calibrations_selected` tinyint NOT NULL,
  `order_creation` tinyint NOT NULL,
  `num_calibrations` tinyint NOT NULL,
  `highlight_comments` tinyint NOT NULL,
  `order_by` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `rgm_order_view`
--

DROP TABLE IF EXISTS `rgm_order_view`;
/*!50001 DROP VIEW IF EXISTS `rgm_order_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `rgm_order_view` (
  `order_num` tinyint NOT NULL,
  `creation_datetime` tinyint NOT NULL,
  `due_date` tinyint NOT NULL,
  `MOU_number` tinyint NOT NULL,
  `organization` tinyint NOT NULL,
  `pri_cust_id` tinyint NOT NULL,
  `pri_cust_email` tinyint NOT NULL,
  `pri_cust_first_name` tinyint NOT NULL,
  `pri_cust_last_name` tinyint NOT NULL,
  `shipping_location_num` tinyint NOT NULL,
  `shipping_location` tinyint NOT NULL,
  `order_status` tinyint NOT NULL,
  `order_status_num` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `invoice_submit_dt` tinyint NOT NULL,
  `invoice_cost` tinyint NOT NULL,
  `ship_date` tinyint NOT NULL,
  `ship_cost` tinyint NOT NULL,
  `expedite` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `rgm_order_view2`
--

DROP TABLE IF EXISTS `rgm_order_view2`;
/*!50001 DROP VIEW IF EXISTS `rgm_order_view2`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `rgm_order_view2` (
  `order_num` tinyint NOT NULL,
  `creation_datetime` tinyint NOT NULL,
  `due_date` tinyint NOT NULL,
  `MOU_number` tinyint NOT NULL,
  `organization` tinyint NOT NULL,
  `pri_cust_id` tinyint NOT NULL,
  `pri_cust_email` tinyint NOT NULL,
  `pri_cust_first_name` tinyint NOT NULL,
  `pri_cust_last_name` tinyint NOT NULL,
  `shipping_location_num` tinyint NOT NULL,
  `shipping_location` tinyint NOT NULL,
  `order_status` tinyint NOT NULL,
  `order_status_num` tinyint NOT NULL,
  `comments` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `rgm_product_view`
--

DROP TABLE IF EXISTS `rgm_product_view`;
/*!50001 DROP VIEW IF EXISTS `rgm_product_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `rgm_product_view` (
  `product_num` tinyint NOT NULL,
  `order_num` tinyint NOT NULL,
  `cylinder_num` tinyint NOT NULL,
  `cylinder_id` tinyint NOT NULL,
  `recertification_date` tinyint NOT NULL,
  `cyl_type` tinyint NOT NULL,
  `cyl_status` tinyint NOT NULL,
  `cyl_status_num` tinyint NOT NULL,
  `cyl_checkin_status` tinyint NOT NULL,
  `cyl_loc` tinyint NOT NULL,
  `cyl_loc_comments` tinyint NOT NULL,
  `cyl_loc_datetime` tinyint NOT NULL,
  `cyl_loc_action_user` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `prod_status` tinyint NOT NULL,
  `prod_status_num` tinyint NOT NULL,
  `prod_cyl_size_num` tinyint NOT NULL,
  `prod_cyl_size` tinyint NOT NULL,
  `cyl_comments` tinyint NOT NULL,
  `prod_comments` tinyint NOT NULL,
  `intended_use` tinyint NOT NULL,
  `intended_site` tinyint NOT NULL,
  `order_status_num` tinyint NOT NULL,
  `MOU_number` tinyint NOT NULL,
  `organization` tinyint NOT NULL,
  `primary_customer_user_id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `contact_num` smallint(5) NOT NULL,
  `pw` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`contact_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_preferences` (
  `contact_num` tinyint(3) NOT NULL,
  `value` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  PRIMARY KEY (`contact_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'refgas_orders'
--
/*!50003 DROP FUNCTION IF EXISTS `f_expanded_uncertainty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_expanded_uncertainty`(`input_species` VARCHAR(20), `input_value` DECIMAL(12,4), `input_date` DATE) RETURNS varchar(20) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
	#JWM 2/16.  Changed the logic to use a common polynomial with different 
	#coefficients for each species (per Brad Hall)
   #JWM- 7/1/19 - updated co coefficients.  Also, note;
   #JWM- 8/31/20 - updated co2,ch4 & n2o to fixed unc as specified below.
   #This is sort of confusing because the db name isn't specified and it's not entirely clear which dbs this would be called from.  The function exists in both
   #ccgg and refgas_orders, but I'm not sure if that was intentional or just because the previous dev added to both in case it would be needed.
   #Regardless, it means that we should either remove from one (ccgg) and always call from refgas_orders.f_expa.. or make sure that both get updated each
   #time a change is made.
   
   DECLARE f_scale_min FLOAT;
   DECLARE f_scale_max FLOAT;
   declare a,b,c,d,e float default 0.0;
   declare rnd int default 0;
   # Check the input_species
   # Yes, this is redundant code but it saves
   #  having the scale check code within
   #  each species specific section
   IF input_species != 'CO2' AND
      input_species != 'CO' AND
      input_species != 'CH4' AND
      input_species != 'N2O' AND
      input_species != 'SF6' THEN
      RETURN 'Species not found';
   END IF;

   SELECT scale_min, scale_max INTO f_scale_min, f_scale_max FROM `reftank`.`scales` WHERE species = input_species AND start_date <= input_date and current=1 ORDER BY start_date DESC LIMIT 1;

   # Need to make sure a range is found!
   IF f_scale_min IS NULL OR
      f_scale_max IS NULL THEN
      RETURN 'Scale not defined';
   END IF;

   # Check if within scale range
   IF input_value < f_scale_min OR
      input_value > f_scale_max THEN
      RETURN 'Out of scale range';
   END IF;

   IF input_species = 'CO2' THEN
   
      IF '2007-09-05' <= input_date AND
         input_date <= '9999-12-31' THEN
         #set a=0.0,b=0.0,c=0.0,d=0.00038,e=0.05169,rnd=2;
         return format(input_value * .00055,2);
      ELSE
         RETURN 'Out of date range';
      END IF;
      
   ELSEIF input_species = 'CH4' THEN
   
      IF '2015-07-06' <= input_date AND
         input_date <= '9999-12-31' THEN
         #set a=5.0354E-14,b=-6.2029E-10,c=2.7572E-06,d=-3.4408E-03,e=3.8119E+00,rnd=1;
         if input_value<2200 then return format(input_value*0.00194,1);
         else return format(input_value*0.0046,1);
         end if;
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'CO' THEN
   
      IF '2014-01-01' <= input_date AND
         input_date <= '9999-12-31' THEN
         #updated June 20, 2018, prev values:
		#set a=0.0000E+00,b=-2.0064E-09,c=6.6383E-06,d=-1.0789E-03,e=9.3536E-01,rnd=1;
        set a=0.0000E+00,b=-1.0231E-09,c=7.2856E-06,d=1.1257E-03,e=1.0600E+00,rnd=1;
         
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'N2O' THEN
   
      IF '2006-01-01' <= input_date AND
         input_date <= '9999-12-31' THEN
		#set a=0.0000E+00,b=6.8118E-07,c=-5.1543E-04,d=1.2059E-01,e=-7.7493E+00,rnd=1;
         return format(input_value*0.0031,2);
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'SF6' THEN
   
      IF '2014-08-22' <= input_date AND
         input_date <= '9999-12-31' THEN
		set a=0.0000E+00,b=-4.9922E-06,c=3.7952E-04,d=-5.3089E-03,e=9.9513E-02,rnd=2;
         
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSE
      RETURN 'Species not found';
   END IF;

	#All species use a common polynomial with different coefficients and rounding precision.
	#12/16, added truncate to fill out to significant digits when needed.
	return format((a*pow(input_value,4))+(b*pow(input_value,3))+(c*pow(input_value,2))+(d*input_value)+e,rnd);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_reproducibility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_reproducibility`(`input_species` VARCHAR(20), `input_value` DECIMAL(12,4), `input_date` DATE) RETURNS varchar(20) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
   DECLARE f_scale_min FLOAT;
   DECLARE f_scale_max FLOAT;
   #jwm 4/17.  3 small updates.  co2 -> .02 (from .06), co input_value <=400 (from 300), sf6 .05 when over 15 (from .04)
 
   # Check the input_species
   # Yes, this is redundant code but it saves
   #  having the scale check code within
   #  each species specific section
   IF input_species != 'CO2' AND
      input_species != 'CO' AND
      input_species != 'CH4' AND
      input_species != 'N2O' AND
      input_species != 'SF6' THEN
      RETURN 'Species not found';
   END IF;

   SELECT scale_min, scale_max INTO f_scale_min, f_scale_max FROM `reftank`.`scales` WHERE species = input_species AND start_date <= input_date and current=1 ORDER BY start_date DESC LIMIT 1;

   IF f_scale_min IS NULL OR
      f_scale_max IS NULL THEN
      RETURN 'Scale not defined';
   END IF;

   # Check if within scale range
   IF input_value < f_scale_min OR
      input_value > f_scale_max THEN
      RETURN 'Out of scale range';
   END IF;

   IF input_species = 'CO2' THEN
   
      IF '2007-09-05' <= input_date AND
         input_date <= '9999-12-31' THEN
         
         RETURN 0.02;
      ELSE
         RETURN 'Out of date range';
      END IF;
   ELSEIF input_species = 'CH4' THEN
   
      IF '2015-07-06' <= input_date AND
         input_date <= '9999-12-31' THEN
         
         IF input_value <= 4000 THEN
            RETURN 0.2; #0.02; #jwm - changed from 1.0 7/19 with andy.  Corrected to .2 jwm 10/30/19
         ELSE
            RETURN 0.4; #0.02; #jwm - changed 7/19 with andy.. ROUND(0.0004*input_value,1);Corrected to .2 jwm 10/30/19
         END IF;
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'CO' THEN
   
      IF '2015-12-03' <= input_date AND
         input_date <= '9999-12-31' THEN
         
         IF input_value <= 400 THEN
            RETURN 0.8;
         ELSE
            RETURN 1.4;
         END IF;         
         
      ELSEIF '2014-01-01' <= input_date AND
         input_date <= '2015-12-02' THEN
      
         RETURN ROUND(0.95*(-8.82e-9*POW(input_value,3)+1.57e-5*POW(input_value,2)+-2e-3*input_value+1.16),1);
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'N2O' THEN
   
      IF '2006-01-01' <= input_date AND
         input_date <= '9999-12-31' THEN
   
         IF 310 <= input_value AND input_value <= 350 THEN #changed from 340 6/13/22 requested by brad.
            #RETURN 0.22;
            #Changed 6/13/22 reqeuested by brad
            RETURN 0.30;
         ELSE
            RETURN 0.30;
         END IF;
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSEIF input_species = 'SF6' THEN
   
      IF '2014-08-22' <= input_date AND
         input_date <= '9999-12-31' THEN
 
         IF input_value <= 15 THEN
            RETURN 0.02;#changed from 0.03 8/20/19 per Brad
         ELSE
            RETURN 0.04;#changed from 0.05 8/20/19 per Brad
         END IF;
      ELSE
         RETURN 'Out of date range';
      END IF;

   ELSE
      RETURN 'Species not found';
   END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `rgm_buildTodoList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `rgm_buildTodoList`(v_calservice_num int,v_display_mode int)
begin
	/*This is now a wrapper to rgm_builtTodoList2 so we can add optional sort_mode (mysql 5.5 doesn't support optional parameters).  If all callers (python code/web php code)
	are upgraded to supply a value, then this can be removed.*/
	call rgm_buildTodoList2(v_calservice_num, v_display_mode, 1);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `rgm_buildTodoList2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `rgm_buildTodoList2`(v_calservice_num int,v_display_mode int, v_sort_mode int)
begin
/*
Procedure to build and return a refgas manager todo list.
This procedure, as it's final output, will select the todolist and output the query.
-v_calservice_num is the todolist to return.  See refgas_orders.calservice for options.  
-v_display_mode controls which columns are output.
	1 is standard for refgas manager
	2 is expanded for refgas manager
	3 is calibrations system specific for import into the calibrations system (andy c/kirk)

	The next 3 are only supported/relevant for co2 for now.
		-5.18 - added similar support for co/h2 (and n2o)
	101 is standard + additional cals for primary system.  I'm not sure that this is an accurately generic
		description yet, but basically this is for showing ch4 cal requests on the co2 todo list because 
		both are being run on the new pc1 machine.  This lets Tom see both 'his' co2 cals, but also see ch4 only
		requests so he can schedule them in too.  Currently the front end does not allow him to do the final
		cal selection.  
	102 is expaned + additional cals for primary system
	103 is same as 3 above + additional cals for primary system.
-v_sort_mode controls sort output.  
	1 is default (order_by sort_num defined in rgm_calrequest_view, serial num
	2 -> sort #, order#, serial number
	3 -> days since last cal, order #, serial #
	4 -> reverse 3
The selected columns in the first 2 may change over time with the rgm web app,
so code should not make any assumptions about order or columns returned. 
display_mode 3 is fixed in both column names and order for use by kirk's code.
See below for columns returned.
*/
/*Create several temporary work tables to get fill code and calibration information.  This technically
could be done in a single query, but did not perform as well as building in blocks.
The query logic is fairly complex, mostly due to the need to qualify everything by fill code dates, but 
all is performed as set ops so fairly quick.  I added some indexes to support the queries.
*/
/*
First is a list of cylinders with their fill date for this request.  We do a group by and select
the min date for the fill code because the table doesn't enforce uniqueness and there were 
duplicates.  We create a master list of potential request nums so we can reuese the conditional 
below without having to keep them in sync if more wacky display modes are added*/
drop temporary table if exists t__allCalRequests;
create temporary table t__allCalRequests (index i(num)) as 
	select r.num from calrequest r
	where (r.calservice_num=v_calservice_num
			#if co2 and we're in add'l mode, include ch4 with co2 (see above for comments). (5/18 - or co/h2)
			#Note, there is one spot below (search for 101, then look in @where clause filter) that does calservice specific logic and needs to get updated if the logic changes too.
			or (v_display_mode in (101,102,103) 
				and ((v_calservice_num=1 and r.calservice_num=2) or (v_calservice_num=3 and (r.calservice_num=11 or r.calservice_num=4)))#1=>co2, 2=>ch4,3=>co, 11=>h2
				)
			)
		and r.calrequest_status_num=2; #2=>processing

drop temporary table if exists t__cals;
create temporary table t__cals (index i (serial_number)) as
	select c.num as cylinder_num,
		f.serial_number, 
		r.num as request_num,
		p.order_num,
		f.code, 
		cs.abbr as species, 
		min(f.date) as fill_start
	from calrequest r, t__allCalRequests a,
		calservice cs, 
		product p, 
		cylinder c, 
		reftank.fill f
	where r.num=a.num
		and cs.num=r.calservice_num
		and r.product_num=p.num
		and c.num=p.cylinder_num
		and p.fill_code=f.code collate latin1_general_ci #db's are using different collation, this can be significant depending on the caller
		and c.id=f.serial_number collate latin1_general_ci
	group by c.num, f.serial_number,r.num,p.order_num,f.code,cs.abbr;  #grouped to get the above min fil date for cyl
		
	#Now build a table of all fill end dates (date of next fill if any)
	drop temporary table if exists t__ends;
	create temporary table t__ends (index i (serial_number) ) as
	select f.serial_number, 
		min(f.date) as fill_end
	from reftank.fill f, 
		t__cals t
	where t.serial_number=f.serial_number
		and f.date>t.fill_start
		and f.code!=t.code #do something sane if there are duplicates
	group by f.serial_number;
	
	#Build a table of the last pressure entered for fill code.
	##jwm 3/24 optimizing  due to poor performance.  Changed from left join to subquery.
	drop temporary table if exists t__lastpressures;
	create temporary table t__lastpressures (index i (cylinder_num)) as
	select t.cylinder_num,#This will be used to join back to rgm
		(select c.pressure from reftank.calibrations_fill_view c where 
			c.serial_number=t.serial_number 
            and timestamp(c.date,c.time)>=o.creation_datetime#I think this is to limit to recent
            and t.code=c.fill_code and c.pressure is not null and c.pressure>0 
			order by timestamp(c.date,c.time) desc limit 1) as pressure,
		t.request_num
	from t__cals t join order_tbl o on o.num=t.order_num
	where  v_display_mode!=1 and v_display_mode!=101#For performance on small list, don't include
	/*Old
	select t.cylinder_num,#This will be used to join back to rgm
		c.pressure,
		t.request_num
	from reftank.calibrations c inner join t__cals t on (c.serial_number=t.serial_number)
		join order_tbl o on o.num=t.order_num
		left join t__ends e on t.serial_number=e.serial_number
		left join reftank.calibrations c2 on (c.serial_number=c2.serial_number 
			and (timestamp(c2.date,c2.time)>timestamp(c.date,c.time) #These sometimes come in with same stamp
				or (timestamp(c2.date,c2.time)=timestamp(c.date,c.time) and c2.idx>c.idx)) #avoid making assumptions about increasing index if can
			and (e.fill_end is null or c2.date<e.fill_end)
			#and c.species=c2.species #change.  Don't filter by species.. last press for any fill
			and c2.pressure is not null and c2.pressure>0)
	where c2.idx is null #? this is saying there is no later cal for fill code with a pressure entered, so c.idx is the last one.
		and c.date>=t.fill_start and timestamp(c.date,c.time)>=o.creation_datetime
		and (e.fill_end is null or c.date<e.fill_end)
		#and c.species=t.species collate latin1_general_ci
		#and c.flag='.' 
		and c.pressure is not null and c.pressure>0
		and v_display_mode!=1 and v_display_mode!=101#For performance on small list, don't include
	*/
	;

	#Build a table of the last regulator entered for fill code.
	#Note, this could be from years ago (and not valid) if this is a recert.  We could probably
	#change the logic to filter by location change date, but user (andy c) though it should show
	#last.
	#Note, ditto re above species/flag filters.
	drop temporary table if exists t__lastregulators;
	create temporary table t__lastregulators (index i (cylinder_num)) as
	select t.cylinder_num,#This will be used to join back to rgm
		(select c.regulator from reftank.calibrations_fill_view c where 
			c.serial_number=t.serial_number 
            and timestamp(c.date,c.time)>=o.creation_datetime#I think this is to limit to recent
            and t.code=c.fill_code 
            and c.regulator is not null and char_length(c.regulator)>0
            order by timestamp(c.date,c.time) desc limit 1) as regulator,
		t.request_num
	from t__cals t join order_tbl o on o.num=t.order_num
	/*old
    select t.cylinder_num,#This will be used to join back to rgm
		c.regulator,
		t.request_num
	from reftank.calibrations c inner join t__cals t on (c.serial_number=t.serial_number)
		join order_tbl o on o.num=t.order_num
		left join t__ends e on t.serial_number=e.serial_number
		left join reftank.calibrations c2 on (c.serial_number=c2.serial_number 
			and (timestamp(c2.date,c2.time)>timestamp(c.date,c.time) #These sometimes come in with same stamp
				or (timestamp(c2.date,c2.time)=timestamp(c.date,c.time) and c2.idx>c.idx)) #avoid making assumptions about increasing index if can
			and (e.fill_end is null or c2.date<e.fill_end)
			#and c.species=c2.species 
			and c2.regulator is not null and char_length(c2.regulator)>0)
	where c2.idx is null #? this is saying there is no later cal for fill code with a pressure entered, so c.idx is the last one.
		and c.date>=t.fill_start and timestamp(c.date,c.time)>=o.creation_datetime
		and (e.fill_end is null or c.date<e.fill_end)
		#and c.species=t.species collate latin1_general_ci
		#and c.flag='.' 
		and c.regulator is not null and char_length(c.regulator)>0
		and v_display_mode!=1 and v_display_mode!=101#For performance on small list, don't include
	*/
	;

	#Build a table of target data(count, avg, last cal date)
	#jwm 9.22.17 Should this be filtering by order date so that intermediate and final cals don't include previous?
	#I'm adding num ordered cals, and am not sure why the count below is for the whole fill.  May need a separate agg that
	#filters on order date so can do num remaining for order... Need to verify with tom and andy.
	drop temporary table if exists t__aggs;
	create temporary table t__aggs (index i (cylinder_num) ) as 
	select t.cylinder_num,#This will be used to join back to rgm
		t.request_num, #ditto.
		count(distinct c.date) as num_cals,#count(c.serial_number) as num_cals,
		round(avg(c.mixratio),3) as avg_val,
		max(c.date) as last_cal_date
	from reftank.calibrations c join t__cals t on c.serial_number=t.serial_number 
		join order_tbl o on o.num=t.order_num
		left join t__ends e on t.serial_number=e.serial_number
	where c.date>=t.fill_start and timestamp(c.date,c.time)>=o.creation_datetime
		and (e.fill_end is null or c.date<e.fill_end)
		and c.species=t.species collate latin1_general_ci
		and c.flag='.'
	group by t.cylinder_num,t.request_num;

	#Now we can do our final selects depending on the display_mode
	#Note we left join to our temp tables because not all calrequests will have
	#calibration data.
	#We'll build up the query dynamically using a prepared statement.
	#NOTE! rgm web app is expecting some col names (modes 1/2), so changes must be synced (cyl,sort,fill,comment)
	#and display_mode 3/103 require the first few cols to always be present
	set @sel_q="";#Set below
	set @speciesCols_q="";
	set @from_q="from t__allCalRequests a inner join rgm_calrequest_view v on a.num=v.request_num ";
	set @leftjoins_q="left join t__aggs t on 
				(v.cylinder_num=t.cylinder_num and v.request_num=t.request_num)
				left join t__lastpressures p on 
					(v.cylinder_num=p.cylinder_num and v.request_num=p.request_num)
					left join t__lastregulators r on 
						(v.cylinder_num=r.cylinder_num and v.request_num=r.request_num) ";#Note, in hindsight, I'm not sure that cyl is required if reqnum is used, but it certainly does no harm
	set @where_q="where 1=1 ";
	set @order_q= case 
		when v_sort_mode=2 then "order by v.order_by,v.order_num, v.cylinder_id "
		when v_sort_mode=3 then "order by t.last_cal_date, v.order_num, v.cylinder_id "
		when v_sort_mode=4 then "order by t.last_cal_date desc, v.order_num, v.cylinder_id "
		else "order by v.order_by,v.cylinder_id " end;
	

	#Now build up the selected cols depending on mode.  For the 10x, we'll include extra species cols
	if(v_display_mode in(101,102,103)) then #multi species mode, build a table with grouped aggreagates.
		drop temporary table if exists t__mspecies;
		create temporary table t__mspecies as
			select v.cylinder_num,
				#Note we could potentially add req nums (below) and then parse out in front end to do final cals.
				#We aren't doing official ch4 cals on the new co2 system yet, so this isn't needed yet (or necessarily desired)
				#Also note that Kirk's code expects a single reqnum to wipe out the sort number after processing,
				#so that would need to get updated.
				#group_concat(v.request_num order by v.calservice_num) as request_nums, #comma separate list so can be put right into a where .. in([])
				group_concat(v.species order by v.calservice_num separator ' | ') as species,
				group_concat(v.target_value order by v.calservice_num separator ' | ') as target_values, 
				group_concat(t.avg_val order by v.calservice_num separator ' | ') as avg_values
			from rgm_calrequest_view v inner join t__allCalRequests a on v.request_num=a.num 
				left join t__aggs t on 
				(v.cylinder_num=t.cylinder_num and v.request_num=t.request_num)
			group by v.cylinder_num;
		set @from_q=concat(@from_q," inner join t__mspecies ms on ms.cylinder_num=v.cylinder_num ");
		set @speciesCols_q="ms.species,ms.target_values,ms.avg_values"; 
		
		#Set the filter, for now we only support co2/ch4.  We'll show all co2 and any ch4 only product.
		#5.18.  added similar filter for co/h2.  Note that v_calservice_num is not in the scope of the dyn query, so have to build the query here instead of putting in where clause
		if(v_calservice_num=1) then
			set @where_q=concat(@where_q,"and (v.calservice_num=1 or ms.species like 'ch4')");
		elseif(v_calservice_num=3) then
			set @where_q=concat(@where_q,"and (v.calservice_num=3 or ms.species like 'h2' or ms.species like 'n2o')");
		else set 
			@where_q=concat(@where_q,"and 1=0 ");#hard fail to signal programmer.
		end if;
	elseif(v_display_mode in (1,2,3)) then
		set @speciesCols_q="v.target_value as 'Target val',t.avg_val as 'Avg val'"; 
	end if;

	if(v_display_mode in (1,2,101,102)) then #common cols.  See note above about col names
		#I had started adding this:
		#concat('<a href=\"index.php?mod=orders&order_num=',v.order_num,'\">',v.order_num,'</a>') as 'Order #',
		#but it got ui complicated in the todo list because you select the whole row to load final cals...  would need to filter this col in php code.  left for later project
		set @sel_q=concat("select v.request_num,
				v.species as cs_abbr,
				v.cylinder_num,
				v.organization as org_name,
				concat(v.cylinder_id,',',ifnull(ifnull(t.avg_val,v.target_value),''),',',ifnull(p.pressure,''),',',ifnull(v.fill_code,''),',',ifnull(r.regulator,''),',',ifnull(t.num_cals,'')) as 'copy_text',
				v.calservice_num,
				v.highlight_comments,
				v.sort_num as 'Sort',
				v.cylinder_id as 'Cylinder',
				",@speciesCols_q,",
				v.fill_code as 'Fill',
				t.last_cal_date as 'Last cal/Order',
				datediff(now(),t.last_cal_date) as '#days since cal',
				v.analysis_type as 'Analysis type',
				case when v.num_calibrations is null or v.num_calibrations=0 then '' else v.num_calibrations end as 'Cals req',
				t.num_cals as 'Cals done',
				case when v.num_calibrations is not null and v.num_calibrations>0 and t.num_cals is not null then v.num_calibrations-t.num_cals 
					when v.num_calibrations is not null and t.num_cals is null then v.num_calibrations else '' end as 'Cals remaining',
				#case when v.num_calibrations is not null and v.num_calibrations>0 then v.num_calibrations-t.num_cals else '' end as 'Cals remaining',
				v.analysis_comments as 'Comments'");
	end if;
	if(v_display_mode in (2,102)) then #expanded cols
		set @sel_q=concat(@sel_q,", v.organization as 'Organization',v.due_date as 'Due date', p.pressure as 'Last pressure',
				r.regulator as 'Last regulator', 
				v.order_num as 'Order #',
			v.MOU_number as 'MOU', 
			v.primary_customer_email as 'Primary customer',v.current_location as 'Location',
			v.current_location_comments as 'Loc Comments'");
	end if;
	if(v_display_mode in (3,103)) then #Set to ones kirk's code expects
		#Note the req num will be for co2 cal request or ch4 if no co2 was requested.  Kirk's
		#code wipes the sort_number after processing, which means above logic should roughly do 
		#what we want (with the sort_num), but we may need to revisit this if it causes issues
		#between co2/ch4 teams.  The co2 sort is always included and wiped after processing but a 
		#lone ch4 can be given a sort num to bump up on the list and then it'll get wiped after processing.
		set @sel_q=concat("select 
			#Note the first 3(4?) cols are expected by Kirk's code and cannot be changed.  The others can be changed as needed.
			v.cylinder_id as serial_number,
			p.pressure as 'Last press',
			r.regulator as 'Last reg',
			v.request_num,
			####
			#v.species as 'Species',
			v.sort_num as 'Sort num',
			v.cylinder_id as 'Serial num',
			t.last_cal_date as 'Last Cal Date',
			case when v.num_calibrations is not null and v.num_calibrations>0 and t.num_cals is not null then v.num_calibrations-t.num_cals 
				when v.num_calibrations is not null and t.num_cals is null then v.num_calibrations else '' end as 'Cals remaining',
			#v.num_calibrations as 'Cals remaining',
			v.organization as 'Org',
			v.due_date as 'Due date',
			v.current_location as 'Loc',
			v.current_location_comments as 'Loc comments',
			v.analysis_type as 'Analysis type',
			v.analysis_comments as 'Anal. comments',
			",@speciesCols_q,",
			#v.target_value as 'Target val',
			#t.avg_val as 'Avg val',
			case when v.num_calibrations is null or v.num_calibrations=0 then '' else v.num_calibrations end as 'Cals req',
			t.num_cals as '# cals',
			v.fill_code as 'Fill code',
			p.pressure as 'Last pressure',
			r.regulator as 'Last regulator', 
			v.MOU_number as 'MOU num'");

	end if;
	set @q=concat(@sel_q,@from_q,@leftjoins_q,@where_q,@order_q);

	prepare stmt from @q;
	execute stmt;
	deallocate prepare stmt;
	
	#drop temporary table t__aggs,t__ends,t__cals;
	#This might cause problems with some callers, so commenting out for now.
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `rgm_calibrationFinished` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `rgm_calibrationFinished`(v_request_num int)
begin
/*This is called after a reftank calibration has completed so that RefGas Manager can do any actions that it needs to do.

Currently it only does 2 things:
-updates the sort_order to null so that the calrequest for the calibration drops to the bottom of the todo list
-decrements the num_calibrations to show the number of remaining cals todo.

-3/19/18 - added logic to decrement ch4 requests when co2 updated.  These are done at same time.
Note the logic doesn't make assumptions on which (co2/ch4) request
was passed in, it treats both the same and updates the other if present.

This is only currently called for co2/ch4, but works for any type.  Only co2/ch4 are paired (currently).

*/

update calrequest set
	sort_order=null
	#,num_calibrations=case when num_calibrations is not null and num_calibrations>0 then num_calibrations-1 else num_calibrations end
where num=v_request_num;

#2nd update for req pair
update calrequest r, product p, calrequest r2
set r.sort_order=null
	#,r.num_calibrations=case when r.num_calibrations is not null and r.num_calibrations>0 then r.num_calibrations-1 else r.num_calibrations end
where r.product_num=p.num and r2.product_num=p.num
	and r.calservice_num in (1,2) and r2.calservice_num in (1,2) #limit to co2/ch4 cals
	and r.calservice_num!=r2.calservice_num
	and r2.num=v_request_num;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `calibrations_fill_view`
--

/*!50001 DROP TABLE IF EXISTS `calibrations_fill_view`*/;
/*!50001 DROP VIEW IF EXISTS `calibrations_fill_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `calibrations_fill_view` AS select `c1`.`idx` AS `idx`,`c1`.`serial_number` AS `serial_number`,`c1`.`date` AS `date`,`c1`.`time` AS `time`,`c1`.`species` AS `species`,`c1`.`mixratio` AS `mixratio`,`c1`.`stddev` AS `stddev`,`c1`.`num` AS `num`,`c1`.`method` AS `method`,`c1`.`inst` AS `inst`,`c1`.`system` AS `system`,`c1`.`pressure` AS `pressure`,`c1`.`flag` AS `flag`,`c1`.`location` AS `location`,`c1`.`regulator` AS `regulator`,`c1`.`notes` AS `notes`,`c1`.`mod_date` AS `mod_date`,`c1`.`meas_unc` AS `meas_unc`,`c1`.`scale_num` AS `scale_num`,`c1`.`parameter_num` AS `parameter_num`,`c1`.`run_number` AS `run_number`,(select max(`f1`.`code`) from `reftank`.`fill` `f1` where `f1`.`serial_number` = `c1`.`serial_number` and `f1`.`date` = (select max(`reftank`.`fill`.`date`) from `reftank`.`fill` where `reftank`.`fill`.`date` <= `c1`.`date` and `reftank`.`fill`.`serial_number` = `c1`.`serial_number`)) AS `fill_code`,(select max(`reftank`.`fill`.`date`) from `reftank`.`fill` where `reftank`.`fill`.`date` <= `c1`.`date` and `reftank`.`fill`.`serial_number` = `c1`.`serial_number`) AS `fill_date` from `reftank`.`calibrations` `c1` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rgm_calrequest_view`
--

/*!50001 DROP TABLE IF EXISTS `rgm_calrequest_view`*/;
/*!50001 DROP VIEW IF EXISTS `rgm_calrequest_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `rgm_calrequest_view` AS select `r`.`num` AS `request_num`,`r`.`product_num` AS `product_num`,`o`.`num` AS `order_num`,`r`.`calservice_num` AS `calservice_num`,`r`.`calrequest_status_num` AS `calrequest_status_num`,`stat`.`abbr` AS `status`,`stat`.`color_html` AS `status_color`,`p`.`product_status_num` AS `product_status_num`,`ps`.`abbr` AS `prod_status`,`cs`.`abbr` AS `species`,`cs`.`parameter_num` AS `parameter_num`,`c`.`num` AS `cylinder_num`,`r`.`sort_order` AS `sort_num`,`c`.`id` AS `cylinder_id`,`r`.`target_value` AS `target_value`,`p`.`fill_code` AS `fill_code`,`a`.`num` AS `analysis_type_num`,`a`.`abbr` AS `analysis_type`,`r`.`comments` AS `analysis_comments`,`o`.`due_date` AS `due_date`,`o`.`MOU_number` AS `MOU_number`,`o`.`organization` AS `organization`,`o`.`order_status_num` AS `order_status_num`,`os`.`abbr` AS `order_status`,`cu`.`email` AS `primary_customer_email`,`l`.`abbr` AS `current_location`,`c`.`location_comments` AS `current_location_comments`,`r`.`analysis_value` AS `analysis_value`,`r`.`analysis_repeatability` AS `analysis_repeatability`,`r`.`analysis_reference_scale` AS `analysis_reference_scale`,`r`.`co2c13_value` AS `co2c13_value`,`r`.`co2o18_value` AS `co2o18_value`,`r`.`analysis_submit_datetime` AS `analysis_submit_datetime`,`r`.`analysis_submit_user` AS `analysis_submit_user`,`r`.`analysis_calibrations_selected` AS `analysis_calibrations_selected`,`o`.`creation_datetime` AS `order_creation`,`r`.`num_calibrations` AS `num_calibrations`,`o`.`expedite` AS `highlight_comments`,case when `r`.`sort_order` is null then 99999 else `r`.`sort_order` end AS `order_by` from ((((((((((`refgas_orders`.`calrequest` `r` join `refgas_orders`.`calservice` `cs` on(`cs`.`num` = `r`.`calservice_num`)) join `refgas_orders`.`product` `p` on(`r`.`product_num` = `p`.`num`)) join `refgas_orders`.`cylinder` `c` on(`c`.`num` = `p`.`cylinder_num`)) join `refgas_orders`.`analysis_type` `a` on(`a`.`num` = `r`.`analysis_type_num`)) left join `refgas_orders`.`order_tbl` `o` on(`o`.`num` = `p`.`order_num`)) left join `refgas_otrs`.`customer_user` `cu` on(`o`.`primary_customer_user_id` = `cu`.`id`)) left join `refgas_orders`.`location` `l` on(`c`.`location_num` = `l`.`num`)) left join `refgas_orders`.`calrequest_status` `stat` on(`r`.`calrequest_status_num` = `stat`.`num`)) left join `refgas_orders`.`product_status` `ps` on(`p`.`product_status_num` = `ps`.`num`)) left join `refgas_orders`.`order_status` `os` on(`os`.`num` = `o`.`order_status_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rgm_order_view`
--

/*!50001 DROP TABLE IF EXISTS `rgm_order_view`*/;
/*!50001 DROP VIEW IF EXISTS `rgm_order_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `rgm_order_view` AS select `o`.`num` AS `order_num`,`o`.`creation_datetime` AS `creation_datetime`,`o`.`due_date` AS `due_date`,`o`.`MOU_number` AS `MOU_number`,`o`.`organization` AS `organization`,`o`.`primary_customer_user_id` AS `pri_cust_id`,`cust`.`email` AS `pri_cust_email`,`cust`.`first_name` AS `pri_cust_first_name`,`cust`.`last_name` AS `pri_cust_last_name`,`o`.`shipping_location_num` AS `shipping_location_num`,`sl`.`abbr` AS `shipping_location`,`os`.`abbr` AS `order_status`,`o`.`order_status_num` AS `order_status_num`,`o`.`comments` AS `comments`,`o`.`invoice_submit_dt` AS `invoice_submit_dt`,`o`.`invoice_cost` AS `invoice_cost`,`o`.`ship_date` AS `ship_date`,`o`.`ship_cost` AS `ship_cost`,`o`.`expedite` AS `expedite` from (`order_status` `os` join ((`order_tbl` `o` left join `customers` `cust` on(`o`.`primary_customer_user_id` = `cust`.`id`)) left join `location` `sl` on(`o`.`shipping_location_num` = `sl`.`num`))) where `os`.`num` = `o`.`order_status_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rgm_order_view2`
--

/*!50001 DROP TABLE IF EXISTS `rgm_order_view2`*/;
/*!50001 DROP VIEW IF EXISTS `rgm_order_view2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `rgm_order_view2` AS select `o`.`num` AS `order_num`,`o`.`creation_datetime` AS `creation_datetime`,`o`.`due_date` AS `due_date`,`o`.`MOU_number` AS `MOU_number`,`o`.`organization` AS `organization`,`o`.`primary_customer_user_id` AS `pri_cust_id`,`cust`.`email` AS `pri_cust_email`,`cust`.`first_name` AS `pri_cust_first_name`,`cust`.`last_name` AS `pri_cust_last_name`,`o`.`shipping_location_num` AS `shipping_location_num`,`sl`.`abbr` AS `shipping_location`,`os`.`abbr` AS `order_status`,`o`.`order_status_num` AS `order_status_num`,`o`.`comments` AS `comments` from (`order_status` `os` join ((`order_tbl` `o` left join `customers` `cust` on(`o`.`primary_customer_user_id` = `cust`.`id`)) left join `location` `sl` on(`o`.`shipping_location_num` = `sl`.`num`))) where `os`.`num` = `o`.`order_status_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `rgm_product_view`
--

/*!50001 DROP TABLE IF EXISTS `rgm_product_view`*/;
/*!50001 DROP VIEW IF EXISTS `rgm_product_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `rgm_product_view` AS select `p`.`num` AS `product_num`,`p`.`order_num` AS `order_num`,`p`.`cylinder_num` AS `cylinder_num`,`c`.`id` AS `cylinder_id`,`c`.`recertification_date` AS `recertification_date`,`ct`.`abbr` AS `cyl_type`,`cs`.`abbr` AS `cyl_status`,`c`.`cylinder_status_num` AS `cyl_status_num`,`cs2`.`abbr` AS `cyl_checkin_status`,`l`.`abbr` AS `cyl_loc`,`c`.`location_comments` AS `cyl_loc_comments`,`c`.`location_datetime` AS `cyl_loc_datetime`,`c`.`location_action_user` AS `cyl_loc_action_user`,`p`.`fill_code` AS `fill_code`,`ps`.`abbr` AS `prod_status`,`p`.`product_status_num` AS `prod_status_num`,`p`.`cylinder_size_num` AS `prod_cyl_size_num`,`sz`.`abbr` AS `prod_cyl_size`,`c`.`comments` AS `cyl_comments`,`p`.`comments` AS `prod_comments`,`p`.`intended_use` AS `intended_use`,`p`.`intended_site` AS `intended_site`,`o`.`order_status_num` AS `order_status_num`,`o`.`MOU_number` AS `MOU_number`,`o`.`organization` AS `organization`,`o`.`primary_customer_user_id` AS `primary_customer_user_id` from ((((((((`product` `p` left join `order_tbl` `o` on(`p`.`order_num` = `o`.`num`)) left join `cylinder` `c` on(`c`.`num` = `p`.`cylinder_num`)) left join `cylinder_size` `sz` on(`sz`.`num` = `p`.`cylinder_size_num`)) left join `cylinder_type` `ct` on(`ct`.`num` = `c`.`cylinder_type_num`)) left join `cylinder_status` `cs` on(`cs`.`num` = `c`.`cylinder_status_num`)) left join `cylinder_status` `cs2` on(`cs2`.`num` = `c`.`cylinder_checkin_status_num`)) left join `location` `l` on(`l`.`num` = `c`.`location_num`)) left join `product_status` `ps` on(`p`.`product_status_num` = `ps`.`num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-17 10:10:19
