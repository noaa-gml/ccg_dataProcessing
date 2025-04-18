-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: cal_scale_tests
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
-- Table structure for table `bckup_response`
--

DROP TABLE IF EXISTS `bckup_response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bckup_response` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(6) DEFAULT NULL,
  `parameter_num` tinyint(3) unsigned DEFAULT NULL,
  `scale_num` int(11) DEFAULT NULL,
  `system` varchar(20) NOT NULL,
  `inst_id` varchar(8) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `start_date_id` tinyint(4) NOT NULL DEFAULT 1,
  `analysis_date` datetime DEFAULT NULL,
  `coef0` double NOT NULL DEFAULT 0,
  `coef1` double NOT NULL DEFAULT 0,
  `coef2` double NOT NULL DEFAULT 0,
  `rsd` float NOT NULL DEFAULT 0,
  `n` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'number of data points in fit',
  `flag` char(1) NOT NULL DEFAULT '.',
  `function` enum('poly','power') DEFAULT NULL COMMENT 'fit function',
  `ref_op` enum('subtract','divide','none') DEFAULT NULL COMMENT 'reference operator',
  `ref_sernum` varchar(20) DEFAULT NULL,
  `standard_set` varchar(30) DEFAULT '',
  `filename` varchar(100) DEFAULT NULL COMMENT 'file name containing data',
  `covar` text DEFAULT NULL COMMENT 'odr covariance matrix',
  `comment` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6942 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calibrations`
--

DROP TABLE IF EXISTS `calibrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrations` (
  `idx` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `time` time DEFAULT '00:00:00',
  `species` varchar(20) DEFAULT NULL,
  `mixratio` decimal(12,3) DEFAULT -999.990,
  `stddev` decimal(12,3) DEFAULT -99.990,
  `num` tinyint(4) NOT NULL DEFAULT 0,
  `method` varchar(20) DEFAULT NULL,
  `inst` char(8) DEFAULT NULL,
  `system` varchar(20) NOT NULL,
  `pressure` int(11) DEFAULT NULL,
  `flag` char(1) NOT NULL DEFAULT '.',
  `location` varchar(20) DEFAULT NULL,
  `regulator` varchar(50) NOT NULL,
  `notes` text DEFAULT NULL,
  `mod_date` datetime NOT NULL,
  `meas_unc` decimal(12,3) DEFAULT 0.000,
  `scale_num` int(11) DEFAULT NULL,
  `parameter_num` int(11) DEFAULT NULL,
  `run_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`idx`),
  KEY `cyl_date` (`serial_number`,`date`),
  KEY `i3` (`system`),
  KEY `i4` (`inst`)
) ENGINE=MyISAM AUTO_INCREMENT=252441 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
  `fill_code` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `current_scale_assignments_view`
--

DROP TABLE IF EXISTS `current_scale_assignments_view`;
/*!50001 DROP VIEW IF EXISTS `current_scale_assignments_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `current_scale_assignments_view` (
  `scale_num` tinyint NOT NULL,
  `serial_number` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `assign_date` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `dilution`
--

DROP TABLE IF EXISTS `dilution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dilution` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(20) NOT NULL,
  `fill_code` varchar(3) NOT NULL,
  `fill_num` int(11) NOT NULL,
  `parent_sn` varchar(20) NOT NULL,
  `diluent_sn` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `project` varchar(20) NOT NULL,
  `flag` varchar(1) NOT NULL,
  `notes` text NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=330 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_calibrations`
--

DROP TABLE IF EXISTS `external_calibrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_calibrations` (
  `num` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `dt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `parameter_num` int(11) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `stddev` decimal(12,3) DEFAULT -99.990,
  `n` tinyint(4) NOT NULL DEFAULT 0,
  `n_days` tinyint(4) DEFAULT NULL,
  `n_episodes` tinyint(4) DEFAULT NULL,
  `method` varchar(20) DEFAULT NULL,
  `inst` char(5) DEFAULT NULL,
  `system` varchar(20) NOT NULL,
  `regulator` varchar(50) NOT NULL,
  `pressure` int(11) DEFAULT NULL,
  `flag` char(1) NOT NULL DEFAULT '.',
  `scale_transfer_unc` decimal(12,3) DEFAULT NULL,
  `unc` decimal(12,3) DEFAULT NULL,
  `meas_lab_num` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `scale_num` int(11) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`num`),
  KEY `cyl_date` (`serial_number`,`dt`),
  KEY `i3` (`system`),
  KEY `i4` (`inst`)
) ENGINE=MyISAM AUTO_INCREMENT=6170 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fill`
--

DROP TABLE IF EXISTS `fill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fill` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `code` varchar(5) NOT NULL DEFAULT '',
  `location` varchar(40) DEFAULT NULL,
  `method` varchar(40) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `h2o` float DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `u` (`serial_number`,`code`),
  KEY `cyl_code_date` (`serial_number`,`code`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=14179 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `fill_end_dates_view`
--

DROP TABLE IF EXISTS `fill_end_dates_view`;
/*!50001 DROP VIEW IF EXISTS `fill_end_dates_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `fill_end_dates_view` (
  `serial_number` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `fill_start_date` tinyint NOT NULL,
  `fill_end_date` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `flask_data`
--

DROP TABLE IF EXISTS `flask_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data` (
  `num` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `event_num` mediumint(8) unsigned DEFAULT NULL,
  `program_num` int(11) unsigned NOT NULL DEFAULT 1,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `meas_unc` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `flag` varchar(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) NOT NULL DEFAULT '',
  `system` varchar(12) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `comment` text NOT NULL DEFAULT '',
  `update_flag_from_tags` tinyint(4) NOT NULL DEFAULT 0,
  `creation_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i2` (`parameter_num`),
  KEY `i3` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `inst` (`inst`),
  KEY `i1` (`event_num`,`program_num`,`parameter_num`,`inst`,`date`,`time`),
  KEY `cts` (`creation_datetime`)
) ENGINE=MyISAM AUTO_INCREMENT=12471301 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_event`
--

DROP TABLE IF EXISTS `flask_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_event` (
  `num` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `strategy_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `id` varchar(20) NOT NULL DEFAULT '',
  `me` char(3) NOT NULL DEFAULT '',
  `lat` decimal(10,4) NOT NULL DEFAULT -99.9999,
  `lon` decimal(10,4) NOT NULL DEFAULT -999.9999,
  `alt` decimal(8,2) NOT NULL DEFAULT -9999.99,
  `elev` decimal(8,2) NOT NULL DEFAULT -9999.99,
  `comment` tinytext NOT NULL DEFAULT '',
  PRIMARY KEY (`num`),
  KEY `i1` (`site_num`),
  KEY `i2` (`project_num`),
  KEY `i3` (`strategy_num`),
  KEY `i4` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `i5` (`id`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=550157 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grav_stds`
--

DROP TABLE IF EXISTS `grav_stds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grav_stds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fill_num` int(11) NOT NULL,
  `serial_number` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `project` varchar(100) NOT NULL,
  `notebook` smallint(6) NOT NULL,
  `pages` varchar(50) NOT NULL,
  `prepared_by` varchar(50) NOT NULL,
  `parent` varchar(50) NOT NULL,
  `o2_content` float NOT NULL,
  `calc_mw` float NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=315 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Information on preparation of gravimetric standards';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grav_values`
--

DROP TABLE IF EXISTS `grav_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grav_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `std_idx` int(11) NOT NULL,
  `species` varchar(20) NOT NULL,
  `species_num` int(11) NOT NULL,
  `value` float NOT NULL,
  `unc` float NOT NULL,
  `partial_unc` float NOT NULL,
  `flag` varchar(1) NOT NULL,
  `comments` text NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=901 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `response`
--

DROP TABLE IF EXISTS `response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `response` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(6) DEFAULT NULL,
  `parameter_num` tinyint(3) unsigned DEFAULT NULL,
  `scale_num` int(11) DEFAULT NULL,
  `system` varchar(20) NOT NULL,
  `inst_id` varchar(8) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `start_date_id` tinyint(4) NOT NULL DEFAULT 1,
  `analysis_date` datetime DEFAULT NULL,
  `coef0` double NOT NULL DEFAULT 0,
  `coef1` double NOT NULL DEFAULT 0,
  `coef2` double NOT NULL DEFAULT 0,
  `coef3` double DEFAULT 0,
  `rsd` float NOT NULL DEFAULT 0,
  `n` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'number of data points in fit',
  `flag` char(1) NOT NULL DEFAULT '.',
  `function` enum('poly','power') DEFAULT NULL COMMENT 'fit function',
  `ref_op` enum('subtract','divide','none') DEFAULT NULL COMMENT 'reference operator',
  `ref_sernum` varchar(20) DEFAULT NULL,
  `standard_set` varchar(30) DEFAULT '',
  `filename` varchar(100) DEFAULT NULL COMMENT 'file name containing data',
  `covar` text DEFAULT NULL COMMENT 'odr covariance matrix',
  `comment` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7797 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scale_assignments`
--

DROP TABLE IF EXISTS `scale_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scale_assignments` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `scale_num` int(11) NOT NULL,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `coef0` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `coef1` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `coef2` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `unc_c0` decimal(15,6) NOT NULL DEFAULT 0.000000 COMMENT 'uncertainty of coef0',
  `unc_c1` decimal(15,6) NOT NULL DEFAULT 0.000000 COMMENT 'uncertainty of coef1',
  `unc_c2` decimal(15,6) NOT NULL DEFAULT 0.000000 COMMENT 'uncertainty of coef2',
  `sd_resid` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `standard_unc` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `assign_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Date when tank assignment was created or modified\n',
  `comment` text DEFAULT NULL,
  `n` int(11) DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `uniq_constraint` (`scale_num`,`serial_number`,`start_date`,`assign_date`)
) ENGINE=MyISAM AUTO_INCREMENT=134702 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `scale_assignments_fill`
--

DROP TABLE IF EXISTS `scale_assignments_fill`;
/*!50001 DROP VIEW IF EXISTS `scale_assignments_fill`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `scale_assignments_fill` (
  `serial_number` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `next_fill_date` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `scale_assignments_view`
--

DROP TABLE IF EXISTS `scale_assignments_view`;
/*!50001 DROP VIEW IF EXISTS `scale_assignments_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `scale_assignments_view` (
  `scale` tinyint NOT NULL,
  `scale_num` tinyint NOT NULL,
  `species` tinyint NOT NULL,
  `serial_number` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `next_fill_date` tinyint NOT NULL,
  `assign_date` tinyint NOT NULL,
  `current_assignment` tinyint NOT NULL,
  `tzero` tinyint NOT NULL,
  `coef0` tinyint NOT NULL,
  `coef1` tinyint NOT NULL,
  `coef2` tinyint NOT NULL,
  `unc_c0` tinyint NOT NULL,
  `unc_c1` tinyint NOT NULL,
  `unc_c2` tinyint NOT NULL,
  `sd_resid` tinyint NOT NULL,
  `standard_unc` tinyint NOT NULL,
  `level` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `scale_assignment_num` tinyint NOT NULL,
  `current_scale` tinyint NOT NULL,
  `n` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `scales`
--

DROP TABLE IF EXISTS `scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scales` (
  `idx` smallint(6) NOT NULL AUTO_INCREMENT,
  `parameter_num` int(11) NOT NULL,
  `species` varchar(20) NOT NULL,
  `name` varchar(30) NOT NULL,
  `current` tinyint(1) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `scale_min` float NOT NULL,
  `scale_max` float NOT NULL,
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=109 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tank_history`
--

DROP TABLE IF EXISTS `tank_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tank_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(6) NOT NULL,
  `system` varchar(20) NOT NULL,
  `gas` set('CO2','CH4','CO','N2O','SF6','H2') NOT NULL,
  `serial_number` varchar(20) NOT NULL,
  `label` varchar(5) NOT NULL,
  `start_date` datetime NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3083 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tgt_tank_simple_view`
--

DROP TABLE IF EXISTS `tgt_tank_simple_view`;
/*!50001 DROP VIEW IF EXISTS `tgt_tank_simple_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tgt_tank_simple_view` (
  `serial_number` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `fill_date` tinyint NOT NULL,
  `fill_location` tinyint NOT NULL,
  `fill_notes` tinyint NOT NULL,
  `frequency` tinyint NOT NULL,
  `meas_path_num` tinyint NOT NULL,
  `label` tinyint NOT NULL,
  `tgt_comment` tinyint NOT NULL,
  `meas_system` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `tgt_tank_view`
--

DROP TABLE IF EXISTS `tgt_tank_view`;
/*!50001 DROP VIEW IF EXISTS `tgt_tank_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tgt_tank_view` (
  `serial_number` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `fill_date` tinyint NOT NULL,
  `fill_location` tinyint NOT NULL,
  `fill_notes` tinyint NOT NULL,
  `frequency` tinyint NOT NULL,
  `meas_path_num` tinyint NOT NULL,
  `label` tinyint NOT NULL,
  `tgt_comment` tinyint NOT NULL,
  `meas_system` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `analysis_date` tinyint NOT NULL,
  `actual_meas_system` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tgt_tanks`
--

DROP TABLE IF EXISTS `tgt_tanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tgt_tanks` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `fill_record` int(11) NOT NULL,
  `frequency` int(11) DEFAULT NULL,
  `meas_path` int(11) DEFAULT NULL,
  `label` varchar(45) DEFAULT NULL,
  `comment` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `idx_UNIQUE` (`idx`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'cal_scale_tests'
--
/*!50003 DROP FUNCTION IF EXISTS `f_date2dec` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_date2dec`(v_date date, v_time time ) RETURNS double(14,9)
    NO SQL
BEGIN
	declare boy datetime default timestamp(makedate(year(v_date),1)); #beginning of year
	declare nyr datetime default timestampadd(year,1,boy);#next year
	declare dt datetime default timestamp(v_date,v_time);#timestamp of passed date time

	return year(v_date)+(timestampdiff(second,boy,dt)/timestampdiff(second,boy,nyr));
	#return soy;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cal_initTest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `cal_initTest`(set_default_val int)
begin
/*Creates a development environment for Andy C to play with calibration scale changes.  
This has been through several iterations.
Latest version is we'll try to creat a full environment clone so to make it easier for processing code to choose where to 
do work in.  
if set_default_val=1 then we set various fields to -888.88
*/

#drop old tables
drop table if exists cal_scale_tests.flask_data;
drop table if exists cal_scale_tests.flask_event;
drop table if exists cal_scale_tests.calibrations;#!
drop table if exists cal_scale_tests.scales;
drop table if exists cal_scale_tests.response;
drop table if exists cal_scale_tests.scale_assignments;
drop table if exists cal_scale_tests.dilution;
drop table if exists cal_scale_tests.external_calibrations;
drop table if exists cal_scale_tests.fill;
drop table if exists cal_scale_tests.grav_stds;
drop table if exists cal_scale_tests.grav_values;
drop table if exists cal_scale_tests.tank_history;

#make clones of existing to get any ddl changes
create table cal_scale_tests.flask_data like ccgg.flask_data;
create table cal_scale_tests.flask_event like ccgg.flask_event;
create table cal_scale_tests.calibrations like reftank.calibrations;
create table cal_scale_tests.scales like reftank.scales;
create table cal_scale_tests.response like reftank.response;
create table cal_scale_tests.scale_assignments like reftank.scale_assignments;
create table cal_scale_tests.dilution like reftank.dilution;
create table cal_scale_tests.external_calibrations like reftank.external_calibrations;
create table cal_scale_tests.fill like reftank.fill;
create table cal_scale_tests.grav_stds like reftank.grav_stds;
create table cal_scale_tests.grav_values like reftank.grav_values;
create table cal_scale_tests.tank_history like reftank.tank_history;

#Fill them
insert cal_scale_tests.flask_data select * from ccgg.flask_data where program_num in (1,12) and parameter_num not in (58,59,60,61,62);
insert cal_scale_tests.flask_event select * from ccgg.flask_event;
insert cal_scale_tests.calibrations select * from reftank.calibrations;
insert cal_scale_tests.scales select * from reftank.scales;
insert cal_scale_tests.response select * from reftank.response;
insert cal_scale_tests.scale_assignments select * from reftank.scale_assignments;
insert cal_scale_tests.dilution select * from reftank.dilution;
insert cal_scale_tests.external_calibrations select * from reftank.external_calibrations;
insert cal_scale_tests.fill select * from reftank.fill;
insert cal_scale_tests.grav_stds select * from reftank.grav_stds;
insert cal_scale_tests.grav_values select * from reftank.grav_values;
insert cal_scale_tests.tank_history select * from reftank.tank_history;

#set defaults if requested so we can detect rows that weren't updated.
if set_default_val then
	update cal_scale_tests.flask_data set value=-888.88, unc=-888.88;
	update cal_scale_tests.calibrations set mixratio=-888.88, stddev=-888.88, meas_unc=-888.88;
	update cal_scale_tests.response set coef0=-888.88, coef1=-888.88, coef2=-888.88;
end if;

/*Deprecating functionality, not used.  if revisited, don't join to other dbs, make it all from here.


#create fill_avgs_view
	create or replace view cal_scale_tests.fill_avgs_view as
		select concat('sn_',c.serial_number) as serial_number,#Note; prefix is by request so outside parser forces to string
			case when c.system='' then 'NA' else c.system end as 'system',c.inst,c.species, f.fill_code, 
			avg(c.mixratio) as avg_mixratio_new, 
			avg(r.mixratio) as avg_mixratio_old, 
			avg(c.mixratio)-avg(r.mixratio) as diff, 
			avg(r.stddev) as avg_stddev_old,
			avg(c.stddev) as avg_stddev_new,
			ifnull(avg(r13.mixratio),-999.99) as avg_co2c13_mr,
			ifnull(avg(r18.mixratio),-999.99) as avg_co2o18_mr,
			count(c.mixratio) as n
			#,group_concat(concat('idx:', c.idx,' (',c.date,' ',c.time,') mr:',c.mixratio,' stdv:',c.stddev) order by c.date separator ' | ') as results
		from cal_scale_tests.calibrations c join reftank.calibrations r on #r.idx=c.idx and REmoved so could continue after divergence
				r.serial_number=c.serial_number and r.date=c.date and r.time=c.time and r.species=c.species and r.inst=c.inst #need all joins because tables diverge after clone 
                left join reftank.calibrations_fill_view f on f.idx=r.idx
			left join reftank.calibrations r13 on r13.serial_number=c.serial_number and c.species='CO2' and r13.species='CO2C13' and r13.date=c.date and r13.time=c.time
			left join reftank.calibrations r18 on r18.serial_number=c.serial_number and c.species='CO2' and r18.species='CO2O18' and r18.date=c.date and r18.time=c.time
		where c.flag='.' and r.method!='mano' and c.mixratio>-999 #and c.date>='2016-04-01'
		group by concat('sn_',c.serial_number),case when c.system='' then 'NA' else c.system end,c.inst,c.species,f.fill_code;

#and tanks_view to put it all together
    #Note; for co2 scale revision, (7/19), andy has identified extrapolated tanks and secondary tanks as ones that he'd like to be able to exclude from the
    #tank.view.  He sent them to me manually and i created tables, filled and joined them below.  Obvioulsy these won't apply for other scales and need to be reset.  He
    #purposely wants them to survive a re-init though so I didn't delete them here.
    #\create table extrapolations as select serial_number,date,time,species,inst from reftank.calibrations where 1=0;
	#create table secondaries as select serial_number,date,time,species,inst from reftank.calibrations where 1=0;
	#also added indexes for faster joins (can't use idx because of divergence).
    #ALTER TABLE `cal_scale_tests`.`secondaries`  ADD INDEX `pk` (`serial_number` ASC, `date` ASC, `time` ASC, `species` ASC, `inst` ASC);


	create or replace view cal_scale_tests.tanks_view as
		select o.idx,o.location,f.fill_code as fill_code,concat('sn_',o.serial_number) as serial_number,
			o.date,o.time,o.species,#,f_date2dec(o.date,o.time) as dd
			n.mixratio as mixratio_new,o.mixratio as mixratio_old,n.mixratio-o.mixratio as diff,
			o.stddev as old_stddev, n.stddev as new_stddev, o.num,o.method,case when o.system='' then 'NA' else o.system end as 'system',o.inst,o.pressure,o.flag
            #,case when e.serial_number is null then 0 else 1 end as extrapolation,
            #case when s.serial_number is null then 0 else 1 end as secondary
		from reftank.calibrations o join cal_scale_tests.calibrations n on 1=1 # n.idx=o.idx #removed this so can still work after the init
			and o.serial_number=n.serial_number and o.date=n.date and o.time=n.time and o.species=n.species and o.inst=n.inst #need all joins because tables diverge after clone.
			left join  reftank.calibrations_fill_view f on f.idx=o.idx 
            #left join cal_scale_tests.extrapolations e on o.serial_number=e.serial_number and o.date=e.date and o.time=e.time and o.species=e.species and o.inst=e.inst 
            #left join cal_scale_tests.secondaries s on o.serial_number=s.serial_number and o.date=s.date and hour(o.time)=hour(s.time) and o.species=s.species and o.inst=s.inst 
		where o.flag='.'  and o.method!='mano'
        ;

	#create a flask_view to put together.
	create or replace view cal_scale_tests.flask_view as
		select o.num,o.event_num,s.code as site,o.program_num,o.parameter_num,
			n.value as value_new,o.value as value_old,n.value-o.value as diff, (o.value*1.00079-0.142) as simple_linear_conv_value,
			o.unc,o.flag,case when o.system='' then 'NA' else o.system end as 'system',o.inst,e.date,e.time,e.dd, pa.formula as species,#, n.me
            timestamp(n.date,n.time) as a_datetime
		from ccgg.flask_data o join cal_scale_tests.flask_data n on #o.num=n.num and --removed so reprocessing can insert into test db and still match.  
			o.event_num=n.event_num 
			and o.program_num=n.program_num and o.parameter_num=n.parameter_num
			and o.inst=n.inst and o.date=n.date and o.time=n.time#Need all join clauses because after cloning, new rows can be inserted into test table from re-processing causing mis-matches.
			join ccgg.flask_event e on o.event_num=e.num 
			join gmd.site s on s.num=e.site_num			
            join gmd.parameter pa on pa.num=o.parameter_num
		where o.flag like '.%'
	;
*/

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateInsituData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateInsituData`(v_archive_dt datetime, inout v_mssg varchar(2000))
begin
/*This is a common method to insert/update the insitu table so that we can control archiving when needed.
You can pass v_archive_dt as now() or some past date to reconstruct history.

Requires a filled temp table tmp.t_insitu with same cols as icp.insitu like this:

create temporary table tmp.t_insitu as select * from insitu where 1=0;

The first 7 cols after num are required non-null, only set other columns that actually have data

existing rows will be updated (and archived), new rows will be inserted.
NOTE; You cannot use this method to update one of the unique cols (like intake_height).  You must update both insitu and insitu_archive directly.
If you want/need to delete and reimport; delete from insitu table, re-import then call icp_rematchArhiveIDs to fix up ids

values in tmp.t_insitu.num col are ignored and col is dropped (so don't reuse).

Note; period 7 is used by matching logic, so by default data should be inserted with a 7.  Other ones may be inserted too for special purposes like day for time series
*/
	declare vUcount,vIcount,vAcount int default 0;
	if(v_archive_dt is null) then set v_archive_dt=now(); end if;#This will be the 'archive date' (if needed)
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#Drop the num col from tmp table to make queries easier
	alter table tmp.t_insitu DROP COLUMN `num`;

	#Fill a tmp table with all the new rows, joining to existing to see if they need update or inserts
	#Unique key defined in the u index on insitu table.
	#Note; the unique key may give us problems with different datasets and if a unique param (like intake_ht) is updated.
	drop temporary table if exists tmp.t_;
	create temporary table tmp.t_ as select * from insitu where 1=0;
					#insert tmp.t_ (num,site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev)
					#select i.num,t.site_num,t.lab_num,t.icpstrat_num,t.parameter_num,t.period_num,t.date,t.e_datetime,t.method,t.intake_height,t.inst,t.value,t.unc,t.flag,t.stddev
	insert tmp.t_ select case when i.num is null then 0 else i.num end ,t.* #num is non-null, so be explicit in convert to 0
	#unique joins
	from tmp.t_insitu t left join icp.insitu i on i.site_num=t.site_num and i.lab_num=t.lab_num and i.icpstrat_num=t.icpstrat_num and i.parameter_num=t.parameter_num
		and i.period_num=t.period_num and i.e_datetime=t.e_datetime and i.method=t.method and i.intake_height=t.intake_height and i.inst=t.inst
	where i.num is null or
		#These cols should be in update statement below.
		i.value!=t.value or i.flag!=t.flag or i.unc!=t.unc or i.stddev!=t.stddev
	;


	#Archive all changes.  We'll let plot logic filter on value if desired.
	#We'll assume the columns are the same (except for archive_date).
	insert icp.insitu_archive
	select v_archive_dt,i.*
	from tmp.t_ t join icp.insitu i on t.num=i.num;
	set vAcount=row_count();

	#Update
	update icp.insitu i, tmp.t_ t
		set i.value=t.value, i.flag=t.flag, i.unc=t.unc, i.stddev=t.stddev
	where i.num=t.num;
	set vUcount=row_count();

	#Insert any new ones.  Assumes NO_AUTO_VALUE_ON_ZERO mode is not enabled.
	insert icp.insitu select * from tmp.t_ t where t.num=0;
	set vIcount=row_count();

	#Delete any that aren't in the source data anymore.
    drop temporary table if exists tmp.t_;
    create temporary table tmp.t_ as
		select  i.num
		#unique joins
		from  icp.insitu i  left join tmp.t_insitu t on i.site_num=t.site_num and i.lab_num=t.lab_num and i.icpstrat_num=t.icpstrat_num and i.parameter_num=t.parameter_num
			and i.period_num=t.period_num and i.e_datetime=t.e_datetime and i.method=t.method and i.intake_height=t.intake_height and i.inst=t.inst
		where t.e_datetime is null;
	#archive
    insert icp.insitu_archive select v_archive_dt, i.* from icp_insitu i join tmp.t_ on t.num=i.num;
    set vUcount=vUcount+row_count();#should probably make a new var for this (del), but the whole messaging thing is so useless at the moment that it's not worth it.
    #delete
    delete i from icp.insitu i join tmp.t_ t on i.num=t.num;

	set v_mssg=concat(case when vUcount+vIcount+vAcount=0 then '.' else
		concat(case when vUcount > 0 then concat(vUcount,' icp.insitu row(s) updated.  ') else '' end,
				case when vAcount > 0 then concat(vAcount,' icp.insitu row(s) archived.  ') else '' end,
				case when vIcount > 0 then concat(vIcount, ' icp.insitu row(s) inserted.  ') else '' end
	) end, " | ",v_mssg);

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
/*!50001 VIEW `calibrations_fill_view` AS select `c1`.`idx` AS `idx`,`c1`.`serial_number` AS `serial_number`,`c1`.`date` AS `date`,`c1`.`time` AS `time`,`c1`.`species` AS `species`,`c1`.`mixratio` AS `mixratio`,`c1`.`stddev` AS `stddev`,`c1`.`num` AS `num`,`c1`.`method` AS `method`,`c1`.`inst` AS `inst`,`c1`.`system` AS `system`,`c1`.`pressure` AS `pressure`,`c1`.`flag` AS `flag`,`c1`.`location` AS `location`,`c1`.`regulator` AS `regulator`,`c1`.`notes` AS `notes`,`c1`.`mod_date` AS `mod_date`,`c1`.`meas_unc` AS `meas_unc`,`c1`.`scale_num` AS `scale_num`,`c1`.`parameter_num` AS `parameter_num`,`c1`.`run_number` AS `run_number`,(select max(`f1`.`code`) from `fill` `f1` where `f1`.`serial_number` = `c1`.`serial_number` and `f1`.`date` = (select max(`fill`.`date`) from `fill` where `fill`.`date` <= `c1`.`date` and `fill`.`serial_number` = `c1`.`serial_number`)) AS `fill_code` from `calibrations` `c1` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `current_scale_assignments_view`
--

/*!50001 DROP TABLE IF EXISTS `current_scale_assignments_view`*/;
/*!50001 DROP VIEW IF EXISTS `current_scale_assignments_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `current_scale_assignments_view` AS select `scale_assignments`.`scale_num` AS `scale_num`,`scale_assignments`.`serial_number` AS `serial_number`,`scale_assignments`.`start_date` AS `start_date`,max(`scale_assignments`.`assign_date`) AS `assign_date` from `scale_assignments` group by `scale_assignments`.`scale_num`,`scale_assignments`.`serial_number`,`scale_assignments`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `fill_end_dates_view`
--

/*!50001 DROP TABLE IF EXISTS `fill_end_dates_view`*/;
/*!50001 DROP VIEW IF EXISTS `fill_end_dates_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `fill_end_dates_view` AS select `f`.`serial_number` AS `serial_number`,`f`.`code` AS `fill_code`,`f`.`date` AS `fill_start_date`,ifnull(min(`f1`.`date`),'9999-12-31') AS `fill_end_date` from (`fill` `f` left join `fill` `f1` on(`f`.`serial_number` = `f1`.`serial_number` and `f1`.`date` > `f`.`date`)) group by `f`.`serial_number`,`f`.`code`,`f`.`date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `scale_assignments_fill`
--

/*!50001 DROP TABLE IF EXISTS `scale_assignments_fill`*/;
/*!50001 DROP VIEW IF EXISTS `scale_assignments_fill`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `scale_assignments_fill` AS select distinct `a`.`serial_number` AS `serial_number`,`a`.`start_date` AS `start_date`,(select max(`f2`.`code`) from `fill` `f2` where `f2`.`serial_number` = `a`.`serial_number` and `f2`.`date` = (select max(`fill`.`date`) from `fill` where `fill`.`date` <= `a`.`start_date` and `fill`.`serial_number` = `a`.`serial_number`)) AS `fill_code`,ifnull((select min(`f3`.`date`) from `fill` `f3` where `f3`.`date` > `a`.`start_date` and `f3`.`serial_number` = `a`.`serial_number`),'9999-12-31') AS `next_fill_date` from `scale_assignments` `a` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `scale_assignments_view`
--

/*!50001 DROP TABLE IF EXISTS `scale_assignments_view`*/;
/*!50001 DROP VIEW IF EXISTS `scale_assignments_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `scale_assignments_view` AS select `s`.`name` AS `scale`,`s`.`idx` AS `scale_num`,`s`.`species` AS `species`,`a`.`serial_number` AS `serial_number`,`f`.`fill_code` AS `fill_code`,`a`.`start_date` AS `start_date`,case when ifnull((select min(`a4`.`start_date`) from `cal_scale_tests`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) = '9999-12-31' then '9999-12-31' else ifnull((select min(`a4`.`start_date`) from `cal_scale_tests`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) + interval -1 day end AS `end_date`,`f`.`next_fill_date` AS `next_fill_date`,`a`.`assign_date` AS `assign_date`,case when `c`.`scale_num` is not null then 1 else 0 end AS `current_assignment`,`a`.`tzero` AS `tzero`,`a`.`coef0` AS `coef0`,`a`.`coef1` AS `coef1`,`a`.`coef2` AS `coef2`,`a`.`unc_c0` AS `unc_c0`,`a`.`unc_c1` AS `unc_c1`,`a`.`unc_c2` AS `unc_c2`,`a`.`sd_resid` AS `sd_resid`,`a`.`standard_unc` AS `standard_unc`,`a`.`level` AS `level`,`a`.`comment` AS `comment`,`p`.`num` AS `parameter_num`,`a`.`num` AS `scale_assignment_num`,`s`.`current` AS `current_scale`,`a`.`n` AS `n` from ((((`cal_scale_tests`.`scale_assignments` `a` join `reftank`.`scales` `s` on(`s`.`idx` = `a`.`scale_num`)) join `gmd`.`parameter` `p` on(`p`.`formula` = `s`.`species`)) join `cal_scale_tests`.`scale_assignments_fill` `f` on(`f`.`serial_number` = `a`.`serial_number` and `f`.`start_date` = `a`.`start_date`)) left join `cal_scale_tests`.`current_scale_assignments_view` `c` on(`a`.`scale_num` = `c`.`scale_num` and `a`.`serial_number` = `c`.`serial_number` and `a`.`start_date` = `c`.`start_date` and `a`.`assign_date` = `c`.`assign_date`)) order by `s`.`name`,`a`.`serial_number`,`a`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tgt_tank_simple_view`
--

/*!50001 DROP TABLE IF EXISTS `tgt_tank_simple_view`*/;
/*!50001 DROP VIEW IF EXISTS `tgt_tank_simple_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`reftank_user`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `tgt_tank_simple_view` AS select `f`.`serial_number` AS `serial_number`,`f`.`code` AS `fill_code`,`f`.`date` AS `fill_date`,`f`.`location` AS `fill_location`,`f`.`notes` AS `fill_notes`,`tt`.`frequency` AS `frequency`,`tt`.`meas_path` AS `meas_path_num`,`tt`.`label` AS `label`,`tt`.`comment` AS `tgt_comment`,`s`.`abbr` AS `meas_system` from ((`cal_scale_tests`.`tgt_tanks` `tt` join `cal_scale_tests`.`fill` `f`) join `ccgg`.`system` `s`) where `tt`.`fill_record` = `f`.`idx` and `tt`.`meas_path` = `s`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tgt_tank_view`
--

/*!50001 DROP TABLE IF EXISTS `tgt_tank_view`*/;
/*!50001 DROP VIEW IF EXISTS `tgt_tank_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`reftank_user`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `tgt_tank_view` AS select `f`.`serial_number` AS `serial_number`,`f`.`code` AS `fill_code`,`f`.`date` AS `fill_date`,`f`.`location` AS `fill_location`,`f`.`notes` AS `fill_notes`,`tt`.`frequency` AS `frequency`,`tt`.`meas_path` AS `meas_path_num`,`tt`.`label` AS `label`,`tt`.`comment` AS `tgt_comment`,`s`.`abbr` AS `meas_system`,`c`.`mixratio` AS `value`,`c`.`date` AS `analysis_date`,`c`.`system` AS `actual_meas_system` from (((`cal_scale_tests`.`tgt_tanks` `tt` join `cal_scale_tests`.`fill` `f`) join `ccgg`.`system` `s`) join `cal_scale_tests`.`calibrations_fill_view` `c`) where `tt`.`fill_record` = `f`.`idx` and `tt`.`meas_path` = `s`.`num` and `f`.`serial_number` like `c`.`serial_number` and `f`.`code` like `c`.`fill_code` and `s`.`abbr` like `c`.`system` */;
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

-- Dump completed on 2025-04-17 10:07:44
