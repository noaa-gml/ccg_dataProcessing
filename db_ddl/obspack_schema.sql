-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: obspack
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
-- Table structure for table `OLDweb_downloads`
--

DROP TABLE IF EXISTS `OLDweb_downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `OLDweb_downloads` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `name` varchar(256) NOT NULL,
  `organization` varchar(256) NOT NULL,
  `email` varchar(256) NOT NULL,
  `package` varchar(256) NOT NULL,
  `intended_use` varchar(256) NOT NULL,
  `use_text` text NOT NULL,
  `provider_notified_date` datetime DEFAULT NULL COMMENT 'Sent separate notice to provider datetime for providers that request',
  `ip_address` varchar(255) DEFAULT NULL COMMENT 'IP address of downloader if available.  For use in provider notifications.',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=13152 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaign`
--

DROP TABLE IF EXISTS `campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `abbr` varchar(45) DEFAULT NULL,
  `logo` varchar(45) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `ccgg_data_summary_view`
--

DROP TABLE IF EXISTS `ccgg_data_summary_view`;
/*!50001 DROP VIEW IF EXISTS `ccgg_data_summary_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `ccgg_data_summary_view` (
  `obspack_project_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `first` tinyint NOT NULL,
  `last` tinyint NOT NULL,
  `count` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `status_num` tinyint NOT NULL,
  `target_sample_days` tinyint NOT NULL,
  `first_releaseable` tinyint NOT NULL,
  `last_releaseable` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `changelog`
--

DROP TABLE IF EXISTS `changelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `changelog` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(20) NOT NULL,
  `date` datetime NOT NULL,
  `query_string` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=5549 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='log of changes made with dbedit';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `citation`
--

DROP TABLE IF EXISTS `citation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `citation` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `citation` text NOT NULL,
  `doi` varchar(128) NOT NULL,
  `icos_pids` text DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=129 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact` (
  `num` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `affiliation` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'from contact table',
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tel` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `auth_user_name` varchar(50) DEFAULT NULL,
  `orcid` varchar(100) DEFAULT NULL COMMENT 'Contact researcher id ex https://orcid.org/0000-0002-4345-2897.  Can be used to create doi metadata',
  `rorid` varchar(100) DEFAULT NULL COMMENT 'Contact affliliation (employer) ex https://ror.org/00bdqav06. Can be used to create doi metadata',
  `rorname` varchar(100) DEFAULT NULL COMMENT 'Name associated with rorid.  Could possibly look up.  Needed for xml meta data tag',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=698 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_20200416`
--

DROP TABLE IF EXISTS `contact_20200416`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_20200416` (
  `num` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `affiliation` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'from contact table',
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tel` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `auth_user_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_20220524`
--

DROP TABLE IF EXISTS `contact_20220524`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_20220524` (
  `num` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `affiliation` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'from contact table',
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tel` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `auth_user_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_20220720`
--

DROP TABLE IF EXISTS `contact_20220720`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_20220720` (
  `num` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `affiliation` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'from contact table',
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tel` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `auth_user_name` varchar(50) DEFAULT NULL,
  `orcid` varchar(100) DEFAULT NULL COMMENT 'Contact researcher id ex https://orcid.org/0000-0002-4345-2897.  Can be used to create doi metadata',
  `rorid` varchar(100) DEFAULT NULL COMMENT 'Contact affliliation (employer) ex https://ror.org/00bdqav06. Can be used to create doi metadata',
  `rorname` varchar(100) DEFAULT NULL COMMENT 'Name associated with rorid.  Could possibly look up.  Needed for xml meta data tag'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_old`
--

DROP TABLE IF EXISTS `contact_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_old` (
  `num` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type_num` int(11) NOT NULL COMMENT 'contact type: lab, individual, etc..',
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `affiliation` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'from contact table',
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tel` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `disclaimer` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `fair_use` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(40) NOT NULL,
  `auth_user_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=418 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contrib_pre_ncei_adds`
--

DROP TABLE IF EXISTS `contrib_pre_ncei_adds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contrib_pre_ncei_adds` (
  `num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor`
--

DROP TABLE IF EXISTS `contributor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i1` (`site_num`,`project_num`,`lab_num`,`parameter_num`,`type_num`)
) ENGINE=MyISAM AUTO_INCREMENT=8499 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_20220720`
--

DROP TABLE IF EXISTS `contributor_20220720`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_20220720` (
  `num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_20220830`
--

DROP TABLE IF EXISTS `contributor_20220830`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_20220830` (
  `num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_20230505`
--

DROP TABLE IF EXISTS `contributor_20230505`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_20230505` (
  `num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_20230829`
--

DROP TABLE IF EXISTS `contributor_20230829`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_20230829` (
  `num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_archive`
--

DROP TABLE IF EXISTS `contributor_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_archive` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL COMMENT 'This is the testing lab',
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `campaign_num` int(11) DEFAULT 0,
  `attributed_contact_num` int(11) DEFAULT NULL COMMENT 'This is the attributed contact, of type type_num',
  `attributed_lab_num` int(11) DEFAULT NULL COMMENT 'This is the attributed lab, of type type_num',
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  `contributorcol` varchar(45) DEFAULT NULL,
  `dt` datetime NOT NULL,
  UNIQUE KEY `p` (`dt`,`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5137 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_old`
--

DROP TABLE IF EXISTS `contributor_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_old` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `type_num` int(11) NOT NULL,
  `contact_num` int(11) NOT NULL,
  `order_num` int(11) NOT NULL DEFAULT 1,
  `comments` tinytext NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=2846 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_table`
--

DROP TABLE IF EXISTS `contributor_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_table` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor_type`
--

DROP TABLE IF EXISTS `contributor_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contributor_type` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `abbr` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_alias`
--

DROP TABLE IF EXISTS `email_alias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_alias` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `alias` varchar(255) DEFAULT NULL COMMENT 'new email address to use when emailing address in email col.  leave null for none',
  `use_in_download_notification` tinyint(4) DEFAULT 1 COMMENT 'whether to use when sending download notices',
  `use_in_usage_summary` tinyint(4) DEFAULT 1 COMMENT 'whether to use in quarterly statistics',
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Use these entries to change email addresses that have previously been incorporated into an obspack for communication from the obspack download and useage statistics pages.  New emails should be entered into the contact table.  You can set use_in_download to 0 and use_in_summary to 1 to skip download notices, but keep summaries';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gv_sample_meta_data`
--

DROP TABLE IF EXISTS `gv_sample_meta_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_sample_meta_data` (
  `sample_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `strategy` varchar(45) NOT NULL,
  `obspack_id` varchar(255) NOT NULL,
  PRIMARY KEY (`sample_num`,`lab_num`,`parameter_num`,`strategy`,`obspack_id`),
  KEY `i2` (`sample_num`,`obspack_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gv_sample_summary`
--

DROP TABLE IF EXISTS `gv_sample_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_sample_summary` (
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `strategy` varchar(45) NOT NULL,
  `obspack` varchar(255) NOT NULL DEFAULT '',
  `lat` decimal(10,4) NOT NULL,
  `lon` decimal(10,4) NOT NULL,
  `alt` decimal(10,4) NOT NULL,
  `window` int(11) NOT NULL,
  `first` datetime DEFAULT NULL,
  `last` datetime DEFAULT NULL,
  `num_samples` bigint(21) NOT NULL DEFAULT 0,
  PRIMARY KEY (`lab_num`,`parameter_num`,`strategy`,`obspack`,`lat`,`lon`,`alt`,`window`),
  KEY `latlon` (`lat`,`lon`),
  KEY `lonlat` (`lon`,`lat`),
  KEY `alt` (`alt`),
  KEY `lab` (`lab_num`),
  KEY `parameter` (`parameter_num`),
  KEY `strategy` (`strategy`),
  KEY `obspack` (`obspack`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gv_samples`
--

DROP TABLE IF EXISTS `gv_samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_samples` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `lat` decimal(10,4) NOT NULL,
  `lon` decimal(10,4) NOT NULL,
  `alt` decimal(8,2) NOT NULL,
  `start_dt` datetime NOT NULL,
  `mid_dt` datetime NOT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`lat`,`lon`,`alt`,`start_dt`,`mid_dt`),
  KEY `latlon` (`lat`,`lon`),
  KEY `lonlat` (`lon`,`lat`),
  KEY `alt` (`alt`)
) ENGINE=MyISAM AUTO_INCREMENT=103706249 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Unique samples in global view products.  Samples may be processed (averaged)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intake_height`
--

DROP TABLE IF EXISTS `intake_height`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intake_height` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `startdate` date NOT NULL DEFAULT '1900-01-01',
  `stopdate` date NOT NULL DEFAULT '9999-12-31',
  `intake_height` float NOT NULL,
  `comments` tinytext NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab`
--

DROP TABLE IF EXISTS `lab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab` (
  `num` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `hide_from_web_listing` tinyint(4) DEFAULT 0,
  `disclaimer` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `fair_use` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(40) NOT NULL,
  `php_password_hash` varchar(255) DEFAULT NULL COMMENT 'Password derived from php function password_hash().  Use php password_verify() to validate.  See php docs.',
  `primary_icp_lab_num` int(11) DEFAULT 0,
  PRIMARY KEY (`num`),
  KEY `i2` (`abbr`,`num`)
) ENGINE=MyISAM AUTO_INCREMENT=712 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_20200416`
--

DROP TABLE IF EXISTS `lab_20200416`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab_20200416` (
  `num` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `disclaimer` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `fair_use` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_old_`
--

DROP TABLE IF EXISTS `lab_old_`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab_old_` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address1` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address2` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `country` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `abbr` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `logo` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `flag` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `disclaimer` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `fair_use` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(40) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=230 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_users`
--

DROP TABLE IF EXISTS `lab_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab_users` (
  `num` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `contact_num` int(10) unsigned NOT NULL,
  `lab_num` int(11) NOT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `contact_num` (`contact_num`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `obp_contributor_view`
--

DROP TABLE IF EXISTS `obp_contributor_view`;
/*!50001 DROP VIEW IF EXISTS `obp_contributor_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `obp_contributor_view` (
  `contributor_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `contributor_type` tinyint NOT NULL,
  `campaign` tinyint NOT NULL,
  `attributed_contact` tinyint NOT NULL,
  `attributed_lab` tinyint NOT NULL,
  `order_num` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `type_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `campaign_num` tinyint NOT NULL,
  `attributed_contact_num` tinyint NOT NULL,
  `attributed_lab_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `obs_site_view`
--

DROP TABLE IF EXISTS `obs_site_view`;
/*!50001 DROP VIEW IF EXISTS `obs_site_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `obs_site_view` (
  `num` tinyint NOT NULL,
  `code` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `country` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `lst2utc` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `URL` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `map_coords` tinyint NOT NULL,
  `galleryURL` tinyint NOT NULL,
  `image` tinyint NOT NULL,
  `comments` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `abbr` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `comments` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `ccgg_strategy_num` int(11) DEFAULT NULL,
  `gmd_project_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publication`
--

DROP TABLE IF EXISTS `publication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publication` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=118 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reference`
--

DROP TABLE IF EXISTS `reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reference` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `publication_num` int(11) NOT NULL,
  `comments` tinytext NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=2046 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `table_access`
--

DROP TABLE IF EXISTS `table_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table_access` (
  `table_name` varchar(50) NOT NULL,
  `row_num` int(10) unsigned NOT NULL,
  `lab_num` int(10) unsigned NOT NULL,
  PRIMARY KEY (`table_name`,`row_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'obspack'
--
/*!50003 DROP PROCEDURE IF EXISTS `ob_createContribSnapshot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `ob_createContribSnapshot`()
begin
#Snapshot contrib table before making edits
	insert contributor_archive select c.*,now() from contributor c;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `op_update_noaa_metadata` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `op_update_noaa_metadata`(v_update int)
begin
	#This procedure will update all the publication references  and contributor entries for noaa sites.
    #References
	#try 2.  Fill temp table with all target references, use in left join to find missing.
    #Pass v_update = 1 to update the references/contribs, 0 to see what will change

    declare vCount int default 0;
    declare vMssg varchar(255) default '';
	drop temporary table if exists t_current_refs, t_all_refs, t_targ_refs;

	#target references all should have
	create temporary table t_targ_refs as select  publication_num,parameter_num,project_num from reference where 1=0;
	#fill...
	insert t_targ_refs (publication_num,parameter_num,project_num) values
			(11,1,1),#11, co2, surface-flask...  no pfp for now:, (11,1,2)
			(92,2,1),#92,methane, surface-flask
			#(94,5,1),(94,6,1),#94, n2o,sf6, surface-flask... jwm 10/20 - ed asked to be removed for now.
			(95,3,1),(96,3,1),(95,3,2),(96,3,2),(97,4,1),(98,4,1),(97,4,2),(98,4,2),#co/h2 surface-flask/pfp
			(55,1,7),(55,2,7),(55,3,7),(55,4,7),(55,5,7),(55,6,7),#55, all species, tower insitu (all species not currently measured)
			(63,1,5),(63,2,5),(63,3,5),(63,4,5),(63,5,5),(63,6,5);#63, all species, aircraft pfp

	#super set of possible references for current sites
	create temporary table t_all_refs as
		select  distinct d.site_num,r.parameter_num, r.project_num,r.publication_num #distinct only incase there are dup rows.
		from ccgg.data_summary_view d join obspack.project p on d.project_num=p.gmd_project_num and d.strategy_num=p.ccgg_strategy_num
			join t_targ_refs r on  p.num=r.project_num and d.parameter_num=r.parameter_num
		where 1=1 #and d.strategy='flask'  and d.project='ccg_surface'
			and d.parameter_num in (1,2,3,4,5,6) and d.program='ccgg'
		and site not like 'POCN%' and site not like 'AOCN%' and site not like 'SCSN%' and site not like 'POCS%' and site not like 'WPCN%' and site not like 'AOCS%' and site not like 'WPCS%'; #Skip all the bucket sites (lat);

	#subset that currently exist
	create temporary table t_current_refs as
		select  distinct r.site_num,r.parameter_num,r.project_num, r.publication_num
		from obspack.reference r
		where r.lab_num=1;

	#left join against all current sites to get missing.
    if (v_update=0) then
		#to show...
		select s.code,proj.abbr,pa.formula,pu.num as pub_num,pu.name,a.*
		from t_all_refs a join publication pu on pu.num=a.publication_num join gmd.parameter pa on a.parameter_num=pa.num join gmd.site s on a.site_num=s.num join project proj on a.project_num=proj.num
			left join t_current_refs c on a.site_num=c.site_num and a.project_num=c.project_num and a.publication_num=c.publication_num and a.parameter_num=c.parameter_num
		where c.publication_num is null #to see missing
			#is not null and c.publication_num=55 and c.project_num=7 #to see ones that have it
		order by a.publication_num desc,s.code, a.parameter_num,proj.abbr;
	else
		#for insert
		insert obspack.reference (site_num,project_num,publication_num,parameter_num,lab_num)
		select  distinct a.site_num,a.project_num, a.publication_num, a.parameter_num,1 as lab_num #distinct only incase there are dup rows.
		from t_all_refs a left join t_current_refs c on a.site_num=c.site_num and a.project_num=c.project_num and a.publication_num=c.publication_num and a.parameter_num=c.parameter_num
		where c.publication_num is null;
        set vCount=row_count();
        set vMssg=concat(vCount," reference rows inserted.");
	end if;


    #Rinse repeat for Contributors.   Note this only does flask/pfps, not towers or observatories as they aren't added very often.
    #This also only does the base 'noaa' providers, not any special cases/providers or partners which will need to be manual.
    #ed -> co2,ch4,n2o,sf6 surf/air flask/pfp
    #gabby -> co,h2 surf/air flaks/pfp
    #colm -> * air
    #targets
    drop temporary table if exists t_contribs,t_targ_contribs;
    create temporary table t_targ_contribs as select project_num, parameter_num, type_num, attributed_contact_num, attributed_lab_num,order_num from contributor where 1=0;
    #fill...
    insert t_targ_contribs (project_num,parameter_num,type_num, attributed_contact_num, attributed_lab_num,order_num) values
		(1,0,1,null,1,1) ,(2,0,1,null,1,1) ,(5,0,1,null,1,1), (8,0,1,null,1,1), #surface/air/ship flask/pfp all params, lab=noaa
		(1,1,3,272,null,1),(1,2,3,272,null,1) ,(1,5,3,272,null,1) ,(1,6,3,272,null,1),  #surface flask co2,ch4,n2o,sf6 => ed
		(1,3,3,446,null,1) ,(1,4,3,446,null,1), #surface flask co,h2 => gabby
        (8,1,3,272,null,1),(8,2,3,272,null,1) ,(8,5,3,272,null,1) ,(8,6,3,272,null,1),  #shipboard flask co2,ch4,n2o,sf6 => ed
		(8,3,3,446,null,1) ,(8,4,3,446,null,1), #shipboard flask co,h2 => gabby
        (5,0,3,244,null,1), #air pfp all params, colm#1
        (2,0,3,231,null,1), #surf pfp all params, arlyn#1
        (2,1,3,272,null,2),(2,2,3,272,null,2) ,(2,5,3,272,null,2) ,(2,6,3,272,null,2),  #surf pfp co2,ch4,n2o,sf6 => ed #2
        (5,1,3,272,null,2),(5,2,3,272,null,2) ,(5,5,3,272,null,2) ,(5,6,3,272,null,2), #air pfp co2,ch4,n2o,sf6 => ed #2
		(2,3,3,446,null,2) ,(2,4,3,446,null,2), #surf pfp flask co,h2 => gabby #2
        (5,3,3,446,null,2) ,(5,4,3,446,null,2);#air pfp flask co,h2 => gabby #2

    #super set of possible contrbs for current sites
	create temporary table t_contribs as
		select  distinct d.site_num, r.project_num,r.parameter_num,r.type_num,r.attributed_contact_num, r.attributed_lab_num, r.order_num
		from ccgg.data_summary_view d join obspack.project p on d.project_num=p.gmd_project_num and d.strategy_num=p.ccgg_strategy_num
			join t_targ_contribs r on  p.num=r.project_num and (d.parameter_num=r.parameter_num or r.parameter_num=0)
		where 1=1 #and d.strategy='flask'  and d.project='ccg_surface'
			and d.parameter_num in (1,2,3,4,5,6) and d.program='ccgg'
		and site not like 'POCN%' and site not like 'AOCN%' and site not like 'SCSN%' and site not like 'POCS%' and site not like 'WPCN%' and site not like 'AOCS%' and site not like 'WPCS%' #Skip all the bucket sites (lat);
		and d.site not in ('drp','poc','scs','akc','crs','dsc','kor','lle','mba','oce','pao','psr','rrs','sur','wpc','aoc'); #all the shipboard flasks.. some duplicatation here, but it will get sorted below

    #get special cases (shipboard flask)
    insert t_contribs select d.site_num,r.project_num,r.parameter_num,r.type_num,r.attributed_contact_num, r.attributed_lab_num, r.order_num
    from ccgg.data_summary_view d join t_targ_contribs r on  d.parameter_num=r.parameter_num
    where d.project_num in (1,2) and r.project_num=8#shipboard flask for flask/pfp
		and d.site in ('drp','poc','scs','akc','crs','dsc','kor','lle','mba','oce','pao','psr','rrs','sur','wpc','aoc');

    #Remove any that already exists.. slightly complicated due to wildcards and null fields
    delete t from t_contribs t where exists (select * from obspack.contributor c where c.site_num=t.site_num and c.project_num=t.project_num and c.lab_num=1
			and  (c.parameter_num=t.parameter_num ) and c.type_num=t.type_num
			and ((c.attributed_contact_num=t.attributed_contact_num and c.attributed_contact_num is not null and t.attributed_contact_num is not null) or
				(c.attributed_lab_num is not null and t.attributed_lab_num is not null and c.attributed_lab_num=t.attributed_lab_num))
			);


	if(v_update=0) then
		select s.code as site, p.abbr as project, ifnull(pa.formula,'all') as parameter, co.name as attr_contact, l.abbr as attr_lab, c.*
		from t_contribs c join gmd.site s on c.site_num=s.num join project p on c.project_num=p.num
			join contributor_type t on c.type_num=t.num
			left join gmd.parameter pa on c.parameter_num=pa.num
			left join contact co on co.num=c.attributed_contact_num
			left join lab l on c.attributed_lab_num=l.num
		order by s.code,p.abbr;
	else
		#for insert.. not done yet :( hard because exisitng sites with individual gases vs 0 all gases
        select "to insert site at a time while verifying use:insert obspack.contributor (site_num, project_num,lab_num,parameter_num, type_num, attributed_contact_num,attributed_lab_num,order_num,comments)
select site_num, project_num,1,parameter_num,type_num,attributed_contact_num, attributed_lab_num,order_num,''
from obspack.t_contribs where site_num= ; Note!! be sure to add Kathryn McKain to new aircraft pfp sites.  Have not added her to above logic yet (was difficult because of old sites)";
		/*insert obspack.contributor ... copied from above, needs to be contrib specific (site_num,project_num,publication_num,parameter_num,lab_num)
		select  distinct a.site_num,a.project_num, a.publication_num, a.parameter_num,1 as lab_num #distinct only incase there are dup rows.
		from t_all_refs a left join t_current_refs c on a.site_num=c.site_num and a.project_num=c.project_num and a.publication_num=c.publication_num and a.parameter_num=c.parameter_num
		where c.publication_num is null;
        set vCount=row_count();
        set vMssg=concat(vCount," reference rows inserted.");*/

	end if;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `ccgg_data_summary_view`
--

/*!50001 DROP TABLE IF EXISTS `ccgg_data_summary_view`*/;
/*!50001 DROP VIEW IF EXISTS `ccgg_data_summary_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `ccgg_data_summary_view` AS select case when `v`.`strategy_num` = 1 and `v`.`project_num` = 1 and `v`.`site` in ('abl','agp') then 4 when `v`.`strategy_num` = 1 and `v`.`project_num` = 1 and `v`.`site` in ('akc','aoc','crs','drp','dsc','kor','lle','mba','oce','pao','poc','psr','rrs','scs','wpc') then 8 when `v`.`strategy_num` = 3 and `v`.`project_num` = 1 then 3 when `p`.`num` is not null then `p`.`num` else NULL end AS `obspack_project_num`,`v`.`site` AS `site`,`v`.`project` AS `project`,`v`.`strategy` AS `strategy`,`v`.`program` AS `program`,`v`.`parameter` AS `parameter`,`v`.`status` AS `status`,`v`.`first` AS `first`,`v`.`last` AS `last`,`v`.`count` AS `count`,`v`.`site_num` AS `site_num`,`v`.`project_num` AS `project_num`,`v`.`strategy_num` AS `strategy_num`,`v`.`program_num` AS `program_num`,`v`.`parameter_num` AS `parameter_num`,`v`.`status_num` AS `status_num`,`v`.`target_sample_days` AS `target_sample_days`,`v`.`first_releaseable` AS `first_releaseable`,`v`.`last_releaseable` AS `last_releaseable` from (`ccgg`.`data_summary_view` `v` left join `obspack`.`project` `p` on(`p`.`ccgg_strategy_num` = `v`.`strategy_num` and `p`.`gmd_project_num` = `v`.`project_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `obp_contributor_view`
--

/*!50001 DROP TABLE IF EXISTS `obp_contributor_view`*/;
/*!50001 DROP VIEW IF EXISTS `obp_contributor_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `obp_contributor_view` AS select `c`.`num` AS `contributor_num`,`s`.`code` AS `site`,`pr`.`abbr` AS `project`,`l`.`abbr` AS `lab`,case when `pa`.`num` is null then 'All' else `pa`.`formula` end AS `parameter`,`t`.`abbr` AS `contributor_type`,case when `ca`.`num` is null then 'All' else `ca`.`abbr` end AS `campaign`,case when `con`.`num` is null then '' else `con`.`name` end AS `attributed_contact`,case when `l2`.`num` is null then '' else `l2`.`abbr` end AS `attributed_lab`,`c`.`order_num` AS `order_num`,`c`.`comments` AS `comments`,`c`.`lab_num` AS `lab_num`,`c`.`site_num` AS `site_num`,`c`.`project_num` AS `project_num`,`c`.`type_num` AS `type_num`,`c`.`parameter_num` AS `parameter_num`,`c`.`campaign_num` AS `campaign_num`,`c`.`attributed_contact_num` AS `attributed_contact_num`,`c`.`attributed_lab_num` AS `attributed_lab_num` from ((((((((`obspack`.`contributor` `c` join `obspack`.`lab` `l` on(`c`.`lab_num` = `l`.`num`)) join `gmd`.`site` `s` on(`c`.`site_num` = `s`.`num`)) join `obspack`.`project` `pr` on(`c`.`project_num` = `pr`.`num`)) join `obspack`.`contributor_type` `t` on(`c`.`type_num` = `t`.`num`)) left join `gmd`.`parameter` `pa` on(`c`.`parameter_num` = `pa`.`num`)) left join `obspack`.`campaign` `ca` on(`c`.`campaign_num` = `ca`.`num`)) left join `obspack`.`contact` `con` on(`c`.`attributed_contact_num` = `con`.`num`)) left join `obspack`.`lab` `l2` on(`c`.`attributed_lab_num` = `l2`.`num`)) order by `s`.`code`,`l`.`abbr`,`pr`.`abbr`,case when `pa`.`num` is null then 'All' else `pa`.`formula` end,`t`.`abbr`,`c`.`order_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `obs_site_view`
--

/*!50001 DROP TABLE IF EXISTS `obs_site_view`*/;
/*!50001 DROP VIEW IF EXISTS `obs_site_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`140.172.193.%` SQL SECURITY DEFINER */
/*!50001 VIEW `obs_site_view` AS select `gmd`.`site`.`num` AS `num`,`gmd`.`site`.`code` AS `code`,`gmd`.`site`.`name` AS `name`,`gmd`.`site`.`country` AS `country`,`gmd`.`site`.`lat` AS `lat`,`gmd`.`site`.`lon` AS `lon`,`gmd`.`site`.`elev` AS `elev`,`gmd`.`site`.`lst2utc` AS `lst2utc`,`gmd`.`site`.`flag` AS `flag`,`gmd`.`site`.`URL` AS `URL`,`gmd`.`site`.`description` AS `description`,`gmd`.`site`.`map_coords` AS `map_coords`,`gmd`.`site`.`galleryURL` AS `galleryURL`,`gmd`.`site`.`image` AS `image`,`gmd`.`site`.`comments` AS `comments` from `gmd`.`site` */;
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

-- Dump completed on 2025-04-17 10:09:47
