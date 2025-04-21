-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: ccgg_equip
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
-- Table structure for table `equip_test_events`
--

DROP TABLE IF EXISTS `equip_test_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equip_test_events` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `equip_test_num` varchar(45) NOT NULL,
  `event_num` int(11) NOT NULL,
  `equip_test_role_num` int(11) NOT NULL,
  `comments` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u1` (`equip_test_num`,`event_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `equip_test_role`
--

DROP TABLE IF EXISTS `equip_test_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equip_test_role` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  `is_control` tinyint(4) NOT NULL DEFAULT 0,
  `is_test` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `equip_test_type`
--

DROP TABLE IF EXISTS `equip_test_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equip_test_type` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL DEFAULT '',
  `has_psu` tinyint(1) DEFAULT 0,
  `has_pcp` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `equip_tests`
--

DROP TABLE IF EXISTS `equip_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equip_tests` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `equipt_test_type_num` int(11) NOT NULL,
  `datetime` datetime DEFAULT NULL,
  `comment` varchar(255) NOT NULL DEFAULT '',
  `psu_id` varchar(45) DEFAULT '',
  `pcp_id` varchar(45) DEFAULT '',
  `src_cylinder_id` varchar(45) DEFAULT '',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u1` (`equipt_test_type_num`,`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_comp`
--

DROP TABLE IF EXISTS `gen_comp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_comp` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `type` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  `version` varchar(80) NOT NULL DEFAULT '',
  `active` tinyint(3) NOT NULL DEFAULT 1,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=54 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_config`
--

DROP TABLE IF EXISTS `gen_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_config` (
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `gen_comp_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status` tinyint(3) NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `comments` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_dbquery`
--

DROP TABLE IF EXISTS `gen_dbquery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_dbquery` (
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(30) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `command` text NOT NULL,
  `comments` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_elog`
--

DROP TABLE IF EXISTS `gen_elog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_elog` (
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `gen_elog_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `gen_elog_key_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `entry` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_elog_key`
--

DROP TABLE IF EXISTS `gen_elog_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_elog_key` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `gen_elog_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(20) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci PACK_KEYS=0;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_elog_type`
--

DROP TABLE IF EXISTS `gen_elog_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_elog_type` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_inv`
--

DROP TABLE IF EXISTS `gen_inv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_inv` (
  `id` varchar(20) NOT NULL DEFAULT '',
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_inuse` date NOT NULL DEFAULT '0000-00-00',
  `date_outuse` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `gen_status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `comments` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_shipping`
--

DROP TABLE IF EXISTS `gen_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_shipping` (
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_inuse` date NOT NULL DEFAULT '0000-00-00',
  `date_outuse` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `notes` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_status`
--

DROP TABLE IF EXISTS `gen_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_status` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_case`
--

DROP TABLE IF EXISTS `gen_tlog_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_case` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `gen_tlog_keyword_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=306 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_casetest`
--

DROP TABLE IF EXISTS `gen_tlog_casetest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_casetest` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `gen_tlog_case_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `gen_tlog_test_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `user` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=564 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_comment`
--

DROP TABLE IF EXISTS `gen_tlog_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_comment` (
  `gen_tlog_casetest_num` smallint(5) NOT NULL DEFAULT 0,
  `gen_tlog_commenttype_num` tinyint(3) NOT NULL DEFAULT 0,
  `gen_tlog_keyword_num` smallint(5) NOT NULL DEFAULT 0,
  `comments` text NOT NULL,
  PRIMARY KEY (`gen_tlog_casetest_num`,`gen_tlog_commenttype_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_commenttype`
--

DROP TABLE IF EXISTS `gen_tlog_commenttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_commenttype` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_field`
--

DROP TABLE IF EXISTS `gen_tlog_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_field` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '',
  `gen_tlog_fieldtype_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `units` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_fieldtype`
--

DROP TABLE IF EXISTS `gen_tlog_fieldtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_fieldtype` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_keyword`
--

DROP TABLE IF EXISTS `gen_tlog_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_keyword` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `gen_tlog_commenttype_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(20) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_test`
--

DROP TABLE IF EXISTS `gen_tlog_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_test` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `gen_type_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_testfield`
--

DROP TABLE IF EXISTS `gen_tlog_testfield`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_testfield` (
  `gen_tlog_test_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `gen_tlog_field_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `sequence` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`gen_tlog_test_num`,`gen_tlog_field_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_tlog_value`
--

DROP TABLE IF EXISTS `gen_tlog_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_tlog_value` (
  `gen_tlog_casetest_num` smallint(5) NOT NULL DEFAULT 0,
  `gen_tlog_field_num` smallint(5) NOT NULL DEFAULT 0,
  `value` text NOT NULL,
  PRIMARY KEY (`gen_tlog_casetest_num`,`gen_tlog_field_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gen_type`
--

DROP TABLE IF EXISTS `gen_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gen_type` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `abbr` varchar(40) NOT NULL DEFAULT '',
  `info` varchar(20) DEFAULT NULL,
  `strategy_nums` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcp_info`
--

DROP TABLE IF EXISTS `pcp_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcp_info` (
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `version` varchar(10) NOT NULL DEFAULT '',
  `doc_property_num` varchar(45) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psu_info`
--

DROP TABLE IF EXISTS `psu_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psu_info` (
  `gen_inv_id` varchar(20) NOT NULL DEFAULT '',
  `batch` double NOT NULL DEFAULT 0,
  `psu_mfr_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `mfr_sn` varchar(20) NOT NULL,
  `diagrams` varchar(128) NOT NULL DEFAULT '',
  `photos` varchar(128) NOT NULL DEFAULT '',
  `doc_property_num` varchar(45) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psu_mfr`
--

DROP TABLE IF EXISTS `psu_mfr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psu_mfr` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'ccgg_equip'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-17 10:06:48
