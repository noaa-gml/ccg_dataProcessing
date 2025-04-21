-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: scale_archives
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
-- Table structure for table `calibrations_archive`
--

DROP TABLE IF EXISTS `calibrations_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrations_archive` (
  `idx` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `time` time DEFAULT '00:00:00',
  `species` varchar(20) DEFAULT NULL,
  `mixratio` decimal(12,3) DEFAULT -999.990,
  `stddev` decimal(12,3) DEFAULT -99.990,
  `num` tinyint(4) NOT NULL DEFAULT 0,
  `method` varchar(20) DEFAULT NULL,
  `inst` char(5) DEFAULT NULL,
  `system` varchar(20) NOT NULL,
  `pressure` int(11) DEFAULT NULL,
  `flag` char(1) NOT NULL DEFAULT '.',
  `location` varchar(20) DEFAULT NULL,
  `regulator` varchar(50) NOT NULL,
  `notes` text DEFAULT NULL,
  `mod_date` datetime NOT NULL,
  `scale_num` int(11) NOT NULL COMMENT 'Fk to reftank.scales',
  PRIMARY KEY (`idx`,`scale_num`),
  KEY `cyl_date` (`serial_number`,`date`),
  KEY `i3` (`system`),
  KEY `i4` (`inst`)
) ENGINE=MyISAM AUTO_INCREMENT=151570 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Table to store prior scale values for historical record.  Insert all data along with reftank.scales.num before updating to a new scale';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_data_archive`
--

DROP TABLE IF EXISTS `flask_data_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data_archive` (
  `num` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `event_num` mediumint(8) unsigned DEFAULT NULL,
  `program_num` int(11) unsigned NOT NULL DEFAULT 1,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `flag` varchar(4) NOT NULL DEFAULT '...',
  `inst` varchar(4) NOT NULL DEFAULT '',
  `system` varchar(12) NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `comment` text NOT NULL,
  `update_flag_from_tags` tinyint(4) NOT NULL DEFAULT 0,
  `creation_datetime` datetime DEFAULT NULL,
  `scale_num` int(11) NOT NULL COMMENT 'Fk to reftank.scales',
  PRIMARY KEY (`num`,`scale_num`),
  KEY `i2` (`parameter_num`),
  KEY `i3` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `inst` (`inst`),
  KEY `i1` (`event_num`,`program_num`,`parameter_num`,`inst`,`date`,`time`),
  KEY `cts` (`creation_datetime`)
) ENGINE=MyISAM AUTO_INCREMENT=10436717 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Table to store prior scale values for historical record.  Insert all data along with reftank.scales.num before updating to a new scale';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `flask_data_archive_view`
--

DROP TABLE IF EXISTS `flask_data_archive_view`;
/*!50001 DROP VIEW IF EXISTS `flask_data_archive_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_data_archive_view` (
  `scale_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `me` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `ev_comment` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `time` tinyint NOT NULL,
  `adate` tinyint NOT NULL,
  `atime` tinyint NOT NULL,
  `a_date` tinyint NOT NULL,
  `a_time` tinyint NOT NULL,
  `a_dd` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `update_flag_from_tags` tinyint NOT NULL,
  `prettyEvDate` tinyint NOT NULL,
  `prettyADate` tinyint NOT NULL,
  `a_creation_datetime` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'scale_archives'
--

--
-- Final view structure for view `flask_data_archive_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_data_archive_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_data_archive_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_data_archive_view` AS select `d`.`scale_num` AS `scale_num`,`d`.`event_num` AS `event_num`,`d`.`num` AS `data_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`d`.`program_num` AS `program_num`,`prog`.`abbr` AS `program`,`d`.`parameter_num` AS `parameter_num`,`pa`.`formula` AS `parameter`,`e`.`date` AS `ev_date`,`e`.`time` AS `ev_time`,`e`.`dd` AS `ev_dd`,timestamp(`e`.`date`,`e`.`time`) AS `ev_datetime`,`e`.`id` AS `flask_id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `ev_comment`,`d`.`value` AS `value`,`d`.`unc` AS `unc`,`d`.`flag` AS `flag`,`d`.`inst` AS `inst`,`d`.`system` AS `system`,`d`.`date` AS `date`,`d`.`time` AS `time`,`d`.`date` AS `adate`,`d`.`time` AS `atime`,`d`.`date` AS `a_date`,`d`.`time` AS `a_time`,`d`.`dd` AS `a_dd`,timestamp(`d`.`date`,`d`.`time`) AS `a_datetime`,`d`.`dd` AS `dd`,`d`.`comment` AS `comment`,`d`.`update_flag_from_tags` AS `update_flag_from_tags`,date_format(timestamp(`e`.`date`,`e`.`time`),case when `e`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyEvDate`,date_format(timestamp(`d`.`date`,`d`.`time`),case when `d`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyADate`,`d`.`creation_datetime` AS `a_creation_datetime` from ((((((`ccgg`.`flask_event` `e` join `scale_archives`.`flask_data_archive` `d`) join `gmd`.`site` `si`) join `gmd`.`project` `proj`) join `ccgg`.`strategy` `st`) join `gmd`.`program` `prog`) join `gmd`.`parameter` `pa`) where `e`.`num` = `d`.`event_num` and `e`.`site_num` = `si`.`num` and `e`.`project_num` = `proj`.`num` and `e`.`strategy_num` = `st`.`num` and `d`.`program_num` = `prog`.`num` and `d`.`parameter_num` = `pa`.`num` */;
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

-- Dump completed on 2025-04-17 10:11:03
