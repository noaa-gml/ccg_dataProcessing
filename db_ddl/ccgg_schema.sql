-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: ccgg
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
-- Table structure for table `OLDweb_archive_download_log`
--

DROP TABLE IF EXISTS `OLDweb_archive_download_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `OLDweb_archive_download_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `archive_id` int(11) NOT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `name` varchar(255) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `intended_use` varchar(255) DEFAULT NULL,
  `use_text` text DEFAULT NULL,
  `gatekeeper_notification` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1429 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ac_log`
--

DROP TABLE IF EXISTS `ac_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ac_log` (
  `case_num` smallint(5) NOT NULL DEFAULT 0,
  `ac_log_key_num` smallint(5) NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `entry` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ac_log_case`
--

DROP TABLE IF EXISTS `ac_log_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ac_log_case` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(5) NOT NULL DEFAULT 0,
  `date` date NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=77 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ac_log_key`
--

DROP TABLE IF EXISTS `ac_log_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ac_log_key` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acrotwell_brw_co_20160119`
--

DROP TABLE IF EXISTS `acrotwell_brw_co_20160119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acrotwell_brw_co_20160119` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `unc` float(8,2) NOT NULL DEFAULT 0.00,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `port` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='This table is a snapshot of brw_co_insitu table as requested by Andy Crotwell prior to doing scale changes.  He requests that this is kept for a period of time (approx 1 yr) for reference.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acrotwell_mlo_co_20160119`
--

DROP TABLE IF EXISTS `acrotwell_mlo_co_20160119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acrotwell_mlo_co_20160119` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `unc` float(8,2) NOT NULL DEFAULT 0.00,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `port` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='This table is a snapshot of mlo_co_insitu table as requested by Andy Crotwell prior to doing scale changes.  He requests that this is kept for a period of time (approx 1 yr) for reference.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_ch4_hour`
--

DROP TABLE IF EXISTS `amt_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`),
  KEY `hour` (`hour`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_ch4_insitu`
--

DROP TABLE IF EXISTS `amt_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT 0.000,
  `meas_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `random_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `std_dev` float(8,3) NOT NULL DEFAULT 0.000,
  `scale_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_co2_hour`
--

DROP TABLE IF EXISTS `amt_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`),
  KEY `hour` (`hour`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_co2_insitu`
--

DROP TABLE IF EXISTS `amt_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT 0.000,
  `meas_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `random_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `std_dev` float(8,3) NOT NULL DEFAULT 0.000,
  `scale_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_co_hour`
--

DROP TABLE IF EXISTS `amt_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_co_insitu`
--

DROP TABLE IF EXISTS `amt_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `autoupdateable_data_flags`
--

DROP TABLE IF EXISTS `autoupdateable_data_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autoupdateable_data_flags` (
  `project_num` int(11) NOT NULL DEFAULT 0 COMMENT 'The presence of a matching prj,prg,str,param,site in this table means that new flask_data rows will have their flag automatically created using event and data tags.  a 0 entry in this table is a wild card',
  `program_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `parameter_num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL DEFAULT 0,
  UNIQUE KEY `project_num` (`project_num`,`program_num`,`strategy_num`,`parameter_num`,`site_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='New flask data rows matching criteria in this table will be in the tagging system.  update_flag_from_tag will get set to 1';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_ch4_hour`
--

DROP TABLE IF EXISTS `bao_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_ch4_insitu`
--

DROP TABLE IF EXISTS `bao_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_co2_hour`
--

DROP TABLE IF EXISTS `bao_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_co2_insitu`
--

DROP TABLE IF EXISTS `bao_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_co_hour`
--

DROP TABLE IF EXISTS `bao_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_co_insitu`
--

DROP TABLE IF EXISTS `bao_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_ch4_day`
--

DROP TABLE IF EXISTS `brw_ch4_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_ch4_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_ch4_hour`
--

DROP TABLE IF EXISTS `brw_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_ch4_insitu`
--

DROP TABLE IF EXISTS `brw_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` decimal(8,2) NOT NULL DEFAULT -999.99,
  `unc` decimal(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_ch4_month`
--

DROP TABLE IF EXISTS `brw_ch4_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_ch4_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_ch4_target`
--

DROP TABLE IF EXISTS `brw_ch4_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_ch4_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_day`
--

DROP TABLE IF EXISTS `brw_co2_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_hour`
--

DROP TABLE IF EXISTS `brw_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_insitu`
--

DROP TABLE IF EXISTS `brw_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_insitu_b`
--

DROP TABLE IF EXISTS `brw_co2_insitu_b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_insitu_b` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) DEFAULT NULL,
  `unc` float(8,2) DEFAULT NULL,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_month`
--

DROP TABLE IF EXISTS `brw_co2_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_target`
--

DROP TABLE IF EXISTS `brw_co2_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co2_target_b`
--

DROP TABLE IF EXISTS `brw_co2_target_b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co2_target_b` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) DEFAULT NULL,
  `unc` float(8,2) DEFAULT NULL,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co_day`
--

DROP TABLE IF EXISTS `brw_co_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co_hour`
--

DROP TABLE IF EXISTS `brw_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co_insitu`
--

DROP TABLE IF EXISTS `brw_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) NOT NULL DEFAULT 0.00,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co_month`
--

DROP TABLE IF EXISTS `brw_co_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_co_target`
--

DROP TABLE IF EXISTS `brw_co_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_co_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_n2o_day`
--

DROP TABLE IF EXISTS `brw_n2o_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_n2o_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_n2o_hour`
--

DROP TABLE IF EXISTS `brw_n2o_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_n2o_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_n2o_insitu`
--

DROP TABLE IF EXISTS `brw_n2o_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_n2o_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_n2o_month`
--

DROP TABLE IF EXISTS `brw_n2o_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_n2o_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_n2o_target`
--

DROP TABLE IF EXISTS `brw_n2o_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_n2o_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `build_binning_sites_view`
--

DROP TABLE IF EXISTS `build_binning_sites_view`;
/*!50001 DROP VIEW IF EXISTS `build_binning_sites_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `build_binning_sites_view` (
  `event_num` tinyint NOT NULL,
  `bin_site` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `chs_ch4_hour`
--

DROP TABLE IF EXISTS `chs_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chs_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chs_ch4_insitu`
--

DROP TABLE IF EXISTS `chs_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chs_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chs_ch4_target`
--

DROP TABLE IF EXISTS `chs_ch4_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chs_ch4_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0.00',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `analunc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `abbr` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `tel` varchar(20) NOT NULL DEFAULT '(999) 999-9999',
  `affiliation` varchar(20) NOT NULL DEFAULT 'GML',
  `orcid` varchar(45) DEFAULT NULL,
  `cires` tinyint(1) DEFAULT 1,
  `is_person` int(11) DEFAULT 1,
  `is_active` int(11) DEFAULT 1,
  PRIMARY KEY (`num`),
  KEY `i` (`abbr`)
) ENGINE=MyISAM AUTO_INCREMENT=116 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_contact_after_insert after insert ON ccgg.contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('abbr',':',ifnull(NEW.abbr,'null')), concat('name',':',ifnull(NEW.name,'null')), concat('email',':',ifnull(NEW.email,'null')), concat('tel',':',ifnull(NEW.tel,'null')), concat('affiliation',':',ifnull(NEW.affiliation,'null')), concat('orcid',':',ifnull(NEW.orcid,'null')), concat('cires',':',ifnull(NEW.cires,'null')), concat('is_person',':',ifnull(NEW.is_person,'null')), concat('is_active',':',ifnull(NEW.is_active,'null'))),'ccgg','contact',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_contact_after_update after update ON ccgg.contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.abbr <> OLD.abbr, concat('abbr(Old:',OLD.abbr,' New:',NEW.abbr,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL), IF(NEW.email <> OLD.email, concat('email(Old:',OLD.email,' New:',NEW.email,')'), NULL), IF(NEW.tel <> OLD.tel, concat('tel(Old:',OLD.tel,' New:',NEW.tel,')'), NULL), IF(NEW.affiliation <> OLD.affiliation, concat('affiliation(Old:',OLD.affiliation,' New:',NEW.affiliation,')'), NULL), IF(NEW.orcid <> OLD.orcid, concat('orcid(Old:',OLD.orcid,' New:',NEW.orcid,')'), NULL), IF(NEW.cires <> OLD.cires, concat('cires(Old:',OLD.cires,' New:',NEW.cires,')'), NULL), IF(NEW.is_person <> OLD.is_person, concat('is_person(Old:',OLD.is_person,' New:',NEW.is_person,')'), NULL), IF(NEW.is_active <> OLD.is_active, concat('is_active(Old:',OLD.is_active,' New:',NEW.is_active,')'), NULL)),'ccgg', 'contact',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_contact_before_delete before delete ON ccgg.contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('abbr',':',ifnull(OLD.abbr,'null')), concat('name',':',ifnull(OLD.name,'null')), concat('email',':',ifnull(OLD.email,'null')), concat('tel',':',ifnull(OLD.tel,'null')), concat('affiliation',':',ifnull(OLD.affiliation,'null')), concat('orcid',':',ifnull(OLD.orcid,'null')), concat('cires',':',ifnull(OLD.cires,'null')), concat('is_person',':',ifnull(OLD.is_person,'null')), concat('is_active',':',ifnull(OLD.is_active,'null'))),'ccgg', 'contact',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `contact_view`
--

DROP TABLE IF EXISTS `contact_view`;
/*!50001 DROP VIEW IF EXISTS `contact_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `contact_view` (
  `num` tinyint NOT NULL,
  `abbr` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `tel` tinyint NOT NULL,
  `affiliation` tinyint NOT NULL,
  `orcid` tinyint NOT NULL,
  `cires` tinyint NOT NULL,
  `last_name_first` tinyint NOT NULL,
  `datacite_xml` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `crv_ch4_hour`
--

DROP TABLE IF EXISTS `crv_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_ch4_insitu`
--

DROP TABLE IF EXISTS `crv_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_co2_hour`
--

DROP TABLE IF EXISTS `crv_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_co2_insitu`
--

DROP TABLE IF EXISTS `crv_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_co_hour`
--

DROP TABLE IF EXISTS `crv_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_co_insitu`
--

DROP TABLE IF EXISTS `crv_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_bin`
--

DROP TABLE IF EXISTS `data_bin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_bin` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `method` varchar(30) NOT NULL DEFAULT '',
  `min` float NOT NULL DEFAULT 0,
  `max` float NOT NULL DEFAULT 0,
  `width` float unsigned NOT NULL DEFAULT 0,
  `target_num` smallint(5) unsigned NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_binning`
--

DROP TABLE IF EXISTS `data_binning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_binning` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `begin` date NOT NULL DEFAULT '0000-00-00',
  `end` date NOT NULL DEFAULT '0000-00-00',
  `method` varchar(30) NOT NULL DEFAULT '',
  `min` float NOT NULL DEFAULT 0,
  `max` float NOT NULL DEFAULT 0,
  `width` float unsigned NOT NULL DEFAULT 0,
  `target_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  KEY `target_num` (`target_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_release`
--

DROP TABLE IF EXISTS `data_release`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_release` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `program_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `type` char(1) NOT NULL,
  `data` char(1) NOT NULL,
  `begin` date NOT NULL DEFAULT '0000-00-00',
  `end` date NOT NULL DEFAULT '0000-00-00',
  KEY `site_num` (`site_num`,`project_num`,`strategy_num`,`program_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_release_bak`
--

DROP TABLE IF EXISTS `data_release_bak`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_release_bak` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `program_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `type` char(1) NOT NULL,
  `data` char(1) NOT NULL,
  `begin` date NOT NULL DEFAULT '0000-00-00',
  `end` date NOT NULL DEFAULT '0000-00-00',
  KEY `site_num` (`site_num`,`project_num`,`strategy_num`,`program_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_summary`
--

DROP TABLE IF EXISTS `data_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_summary` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `program_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `first` date NOT NULL DEFAULT '0000-00-00',
  `last` date NOT NULL DEFAULT '0000-00-00',
  `count` mediumint(8) NOT NULL DEFAULT 0,
  `readme_present` bit(1) DEFAULT b'0',
  `first_releaseable` date NOT NULL DEFAULT '0000-00-00',
  `last_releaseable` date NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`site_num`,`project_num`,`strategy_num`,`program_num`,`parameter_num`),
  KEY `status_num` (`status_num`),
  KEY `strat` (`strategy_num`),
  KEY `proj` (`project_num`),
  KEY `prog` (`program_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `data_summary_view`
--

DROP TABLE IF EXISTS `data_summary_view`;
/*!50001 DROP VIEW IF EXISTS `data_summary_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `data_summary_view` (
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
  `last_releaseable` tinyint NOT NULL,
  `ftp_project` tinyint NOT NULL,
  `ftp_project_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `data_tag_users`
--

DROP TABLE IF EXISTS `data_tag_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_tag_users` (
  `contact_num` int(11) NOT NULL COMMENT 'References ccgg.contact',
  `can_delete` tinyint(4) NOT NULL DEFAULT 0,
  `can_edit` tinyint(4) NOT NULL DEFAULT 1,
  `can_insert` tinyint(4) NOT NULL DEFAULT 1,
  `enabled` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`contact_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Note; some client libraries (php pdo) are not able to read bit datatype correctly.  TinyInt resolves issue;';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dbquery`
--

DROP TABLE IF EXISTS `dbquery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dbquery` (
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `user` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `name` varchar(30) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `command` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `comments` text CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dois`
--

DROP TABLE IF EXISTS `dois`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dois` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `doi` varchar(45) NOT NULL,
  `parameter_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `project_num` int(11) NOT NULL DEFAULT 0,
  `program_num` int(11) NOT NULL DEFAULT 0,
  `site_num` int(11) NOT NULL DEFAULT 0,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i1` (`parameter_num`,`strategy_num`,`project_num`,`program_num`),
  KEY `i2` (`doi`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Match doi to referenced data.  Used by ftp readme builder and citation build logic.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `dois_view`
--

DROP TABLE IF EXISTS `dois_view`;
/*!50001 DROP VIEW IF EXISTS `dois_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `dois_view` (
  `parameter` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `google_scholar` tinyint NOT NULL,
  `data_cite` tinyint NOT NULL,
  `doi_url` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `doi` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `drier_chiller_types`
--

DROP TABLE IF EXISTS `drier_chiller_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_chiller_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `drier_event_view`
--

DROP TABLE IF EXISTS `drier_event_view`;
/*!50001 DROP VIEW IF EXISTS `drier_event_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `drier_event_view` (
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `ev_comment` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `method_abbr` tinyint NOT NULL,
  `drier_hist_num` tinyint NOT NULL,
  `drier_type_num` tinyint NOT NULL,
  `drier_type` tinyint NOT NULL,
  `drier_method` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `d1_location_num` tinyint NOT NULL,
  `d1_location` tinyint NOT NULL,
  `d2_location_num` tinyint NOT NULL,
  `d2_location` tinyint NOT NULL,
  `d1_path_order` tinyint NOT NULL,
  `d2_path_order` tinyint NOT NULL,
  `d1_chiller_type_num` tinyint NOT NULL,
  `d1_chiller_type` tinyint NOT NULL,
  `d2_chiller_type_num` tinyint NOT NULL,
  `d2_chiller_type` tinyint NOT NULL,
  `d1_trap_type_num` tinyint NOT NULL,
  `d1_trap_type` tinyint NOT NULL,
  `d2_trap_type_num` tinyint NOT NULL,
  `d2_trap_type` tinyint NOT NULL,
  `d1_chiller_setpoint` tinyint NOT NULL,
  `d2_chiller_setpoint` tinyint NOT NULL,
  `d1_pressure_setpoint` tinyint NOT NULL,
  `d2_pressure_setpoint` tinyint NOT NULL,
  `d1_est_max_sample_h2o` tinyint NOT NULL,
  `d2_est_max_sample_h2o` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `drier_hist`
--

DROP TABLE IF EXISTS `drier_hist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_hist` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `strategy_num` int(11) NOT NULL,
  `method` varchar(5) DEFAULT NULL COMMENT 'If supplied only applies to specific method code.  Blank or null for all',
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT '9999-12-31 00:00:00',
  `comments` text DEFAULT NULL,
  `drier_type_num` tinyint(4) NOT NULL COMMENT 'Fk to ccgg.drier_types',
  `d1_location_num` tinyint(4) DEFAULT NULL,
  `d1_path_order` tinyint(4) DEFAULT NULL,
  `d1_chiller_type_num` tinyint(4) DEFAULT NULL,
  `d1_trap_type_num` tinyint(4) DEFAULT NULL,
  `d1_chiller_setpoint` float DEFAULT NULL,
  `d1_pressure_setpoint` float DEFAULT NULL,
  `d1_est_max_sample_h2o` float DEFAULT NULL,
  `d2_location_num` tinyint(4) DEFAULT NULL,
  `d2_path_order` tinyint(4) DEFAULT NULL,
  `d2_chiller_type_num` tinyint(4) DEFAULT NULL,
  `d2_trap_type_num` tinyint(4) DEFAULT NULL,
  `d2_chiller_setpoint` float DEFAULT NULL,
  `d2_pressure_setpoint` float DEFAULT NULL,
  `d2_est_max_sample_h2o` float DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i2` (`site_num`,`project_num`,`strategy_num`),
  KEY `i3` (`drier_type_num`)
) ENGINE=InnoDB AUTO_INCREMENT=267 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Records history of installed driers at sites, mostly tower pfp sites. Note; we expect to support multiple driers but choose to denormalize into d1,d2 to reduce app complexity and because there will likely only be 2 max.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_hist_after_insert after insert ON ccgg.drier_hist FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('site_num',':',ifnull(NEW.site_num,'null')), concat('project_num',':',ifnull(NEW.project_num,'null')), concat('strategy_num',':',ifnull(NEW.strategy_num,'null')), concat('method',':',ifnull(NEW.method,'null')), concat('start_date',':',ifnull(NEW.start_date,'null')), concat('end_date',':',ifnull(NEW.end_date,'null')), concat('comments',':',ifnull(NEW.comments,'null')), concat('drier_type_num',':',ifnull(NEW.drier_type_num,'null')), concat('d1_location_num',':',ifnull(NEW.d1_location_num,'null')), concat('d1_path_order',':',ifnull(NEW.d1_path_order,'null')), concat('d1_chiller_type_num',':',ifnull(NEW.d1_chiller_type_num,'null')), concat('d1_trap_type_num',':',ifnull(NEW.d1_trap_type_num,'null')), concat('d1_chiller_setpoint',':',ifnull(NEW.d1_chiller_setpoint,'null')), concat('d1_pressure_setpoint',':',ifnull(NEW.d1_pressure_setpoint,'null')), concat('d1_est_max_sample_h2o',':',ifnull(NEW.d1_est_max_sample_h2o,'null')), concat('d2_location_num',':',ifnull(NEW.d2_location_num,'null')), concat('d2_path_order',':',ifnull(NEW.d2_path_order,'null')), concat('d2_chiller_type_num',':',ifnull(NEW.d2_chiller_type_num,'null')), concat('d2_trap_type_num',':',ifnull(NEW.d2_trap_type_num,'null')), concat('d2_chiller_setpoint',':',ifnull(NEW.d2_chiller_setpoint,'null')), concat('d2_pressure_setpoint',':',ifnull(NEW.d2_pressure_setpoint,'null')), concat('d2_est_max_sample_h2o',':',ifnull(NEW.d2_est_max_sample_h2o,'null'))),'ccgg','drier_hist',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_hist_after_update after update ON ccgg.drier_hist FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.site_num <> OLD.site_num, concat('site_num(Old:',OLD.site_num,' New:',NEW.site_num,')'), NULL), IF(NEW.project_num <> OLD.project_num, concat('project_num(Old:',OLD.project_num,' New:',NEW.project_num,')'), NULL), IF(NEW.strategy_num <> OLD.strategy_num, concat('strategy_num(Old:',OLD.strategy_num,' New:',NEW.strategy_num,')'), NULL), IF(NEW.method <> OLD.method, concat('method(Old:',OLD.method,' New:',NEW.method,')'), NULL), IF(NEW.start_date <> OLD.start_date, concat('start_date(Old:',OLD.start_date,' New:',NEW.start_date,')'), NULL), IF(NEW.end_date <> OLD.end_date, concat('end_date(Old:',OLD.end_date,' New:',NEW.end_date,')'), NULL), IF(NEW.comments <> OLD.comments, concat('comments(Old:',OLD.comments,' New:',NEW.comments,')'), NULL), IF(NEW.drier_type_num <> OLD.drier_type_num, concat('drier_type_num(Old:',OLD.drier_type_num,' New:',NEW.drier_type_num,')'), NULL), IF(NEW.d1_location_num <> OLD.d1_location_num, concat('d1_location_num(Old:',OLD.d1_location_num,' New:',NEW.d1_location_num,')'), NULL), IF(NEW.d1_path_order <> OLD.d1_path_order, concat('d1_path_order(Old:',OLD.d1_path_order,' New:',NEW.d1_path_order,')'), NULL), IF(NEW.d1_chiller_type_num <> OLD.d1_chiller_type_num, concat('d1_chiller_type_num(Old:',OLD.d1_chiller_type_num,' New:',NEW.d1_chiller_type_num,')'), NULL), IF(NEW.d1_trap_type_num <> OLD.d1_trap_type_num, concat('d1_trap_type_num(Old:',OLD.d1_trap_type_num,' New:',NEW.d1_trap_type_num,')'), NULL), IF(NEW.d1_chiller_setpoint <> OLD.d1_chiller_setpoint, concat('d1_chiller_setpoint(Old:',OLD.d1_chiller_setpoint,' New:',NEW.d1_chiller_setpoint,')'), NULL), IF(NEW.d1_pressure_setpoint <> OLD.d1_pressure_setpoint, concat('d1_pressure_setpoint(Old:',OLD.d1_pressure_setpoint,' New:',NEW.d1_pressure_setpoint,')'), NULL), IF(NEW.d1_est_max_sample_h2o <> OLD.d1_est_max_sample_h2o, concat('d1_est_max_sample_h2o(Old:',OLD.d1_est_max_sample_h2o,' New:',NEW.d1_est_max_sample_h2o,')'), NULL), IF(NEW.d2_location_num <> OLD.d2_location_num, concat('d2_location_num(Old:',OLD.d2_location_num,' New:',NEW.d2_location_num,')'), NULL), IF(NEW.d2_path_order <> OLD.d2_path_order, concat('d2_path_order(Old:',OLD.d2_path_order,' New:',NEW.d2_path_order,')'), NULL), IF(NEW.d2_chiller_type_num <> OLD.d2_chiller_type_num, concat('d2_chiller_type_num(Old:',OLD.d2_chiller_type_num,' New:',NEW.d2_chiller_type_num,')'), NULL), IF(NEW.d2_trap_type_num <> OLD.d2_trap_type_num, concat('d2_trap_type_num(Old:',OLD.d2_trap_type_num,' New:',NEW.d2_trap_type_num,')'), NULL), IF(NEW.d2_chiller_setpoint <> OLD.d2_chiller_setpoint, concat('d2_chiller_setpoint(Old:',OLD.d2_chiller_setpoint,' New:',NEW.d2_chiller_setpoint,')'), NULL), IF(NEW.d2_pressure_setpoint <> OLD.d2_pressure_setpoint, concat('d2_pressure_setpoint(Old:',OLD.d2_pressure_setpoint,' New:',NEW.d2_pressure_setpoint,')'), NULL), IF(NEW.d2_est_max_sample_h2o <> OLD.d2_est_max_sample_h2o, concat('d2_est_max_sample_h2o(Old:',OLD.d2_est_max_sample_h2o,' New:',NEW.d2_est_max_sample_h2o,')'), NULL)),'ccgg', 'drier_hist',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_hist_before_delete before delete ON ccgg.drier_hist FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('site_num',':',ifnull(OLD.site_num,'null')), concat('project_num',':',ifnull(OLD.project_num,'null')), concat('strategy_num',':',ifnull(OLD.strategy_num,'null')), concat('method',':',ifnull(OLD.method,'null')), concat('start_date',':',ifnull(OLD.start_date,'null')), concat('end_date',':',ifnull(OLD.end_date,'null')), concat('comments',':',ifnull(OLD.comments,'null')), concat('drier_type_num',':',ifnull(OLD.drier_type_num,'null')), concat('d1_location_num',':',ifnull(OLD.d1_location_num,'null')), concat('d1_path_order',':',ifnull(OLD.d1_path_order,'null')), concat('d1_chiller_type_num',':',ifnull(OLD.d1_chiller_type_num,'null')), concat('d1_trap_type_num',':',ifnull(OLD.d1_trap_type_num,'null')), concat('d1_chiller_setpoint',':',ifnull(OLD.d1_chiller_setpoint,'null')), concat('d1_pressure_setpoint',':',ifnull(OLD.d1_pressure_setpoint,'null')), concat('d1_est_max_sample_h2o',':',ifnull(OLD.d1_est_max_sample_h2o,'null')), concat('d2_location_num',':',ifnull(OLD.d2_location_num,'null')), concat('d2_path_order',':',ifnull(OLD.d2_path_order,'null')), concat('d2_chiller_type_num',':',ifnull(OLD.d2_chiller_type_num,'null')), concat('d2_trap_type_num',':',ifnull(OLD.d2_trap_type_num,'null')), concat('d2_chiller_setpoint',':',ifnull(OLD.d2_chiller_setpoint,'null')), concat('d2_pressure_setpoint',':',ifnull(OLD.d2_pressure_setpoint,'null')), concat('d2_est_max_sample_h2o',':',ifnull(OLD.d2_est_max_sample_h2o,'null'))),'ccgg', 'drier_hist',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `drier_hist_users`
--

DROP TABLE IF EXISTS `drier_hist_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_hist_users` (
  `contact_num` int(11) NOT NULL COMMENT 'Fk -> ccgg.contact',
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `can_insert` tinyint(1) NOT NULL DEFAULT 0,
  `can_edit` tinyint(1) NOT NULL DEFAULT 0,
  `can_delete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`contact_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `drier_history_view`
--

DROP TABLE IF EXISTS `drier_history_view`;
/*!50001 DROP VIEW IF EXISTS `drier_history_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `drier_history_view` (
  `drier_hist_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `drier_type_num` tinyint NOT NULL,
  `drier_type` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `d1_location_num` tinyint NOT NULL,
  `d1_location` tinyint NOT NULL,
  `d2_location_num` tinyint NOT NULL,
  `d2_location` tinyint NOT NULL,
  `d1_path_order` tinyint NOT NULL,
  `d2_path_order` tinyint NOT NULL,
  `d1_chiller_type_num` tinyint NOT NULL,
  `d1_chiller_type` tinyint NOT NULL,
  `d2_chiller_type_num` tinyint NOT NULL,
  `d2_chiller_type` tinyint NOT NULL,
  `d1_trap_type_num` tinyint NOT NULL,
  `d1_trap_type` tinyint NOT NULL,
  `d2_trap_type_num` tinyint NOT NULL,
  `d2_trap_type` tinyint NOT NULL,
  `d1_chiller_setpoint` tinyint NOT NULL,
  `d2_chiller_setpoint` tinyint NOT NULL,
  `d1_pressure_setpoint` tinyint NOT NULL,
  `d2_pressure_setpoint` tinyint NOT NULL,
  `d1_est_max_sample_h2o` tinyint NOT NULL,
  `d2_est_max_sample_h2o` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `drier_locations`
--

DROP TABLE IF EXISTS `drier_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_locations` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_locations_after_insert after insert ON ccgg.drier_locations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('name',':',ifnull(NEW.name,'null'))),'ccgg','drier_locations',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_locations_after_update after update ON ccgg.drier_locations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL)),'ccgg', 'drier_locations',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_locations_before_delete before delete ON ccgg.drier_locations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('name',':',ifnull(OLD.name,'null'))),'ccgg', 'drier_locations',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `drier_trap_types`
--

DROP TABLE IF EXISTS `drier_trap_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_trap_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_trap_types_after_insert after insert ON ccgg.drier_trap_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('name',':',ifnull(NEW.name,'null'))),'ccgg','drier_trap_types',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_trap_types_after_update after update ON ccgg.drier_trap_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL)),'ccgg', 'drier_trap_types',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_trap_types_before_delete before delete ON ccgg.drier_trap_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('name',':',ifnull(OLD.name,'null'))),'ccgg', 'drier_trap_types',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `drier_types`
--

DROP TABLE IF EXISTS `drier_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drier_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(45) NOT NULL,
  `description` varchar(2048) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_types_after_insert after insert ON ccgg.drier_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('abbr',':',ifnull(NEW.abbr,'null')), concat('description',':',ifnull(NEW.description,'null')), concat('sort_order',':',ifnull(NEW.sort_order,'null'))),'ccgg','drier_types',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_types_after_update after update ON ccgg.drier_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.abbr <> OLD.abbr, concat('abbr(Old:',OLD.abbr,' New:',NEW.abbr,')'), NULL), IF(NEW.description <> OLD.description, concat('description(Old:',OLD.description,' New:',NEW.description,')'), NULL), IF(NEW.sort_order <> OLD.sort_order, concat('sort_order(Old:',OLD.sort_order,' New:',NEW.sort_order,')'), NULL)),'ccgg', 'drier_types',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_drier_types_before_delete before delete ON ccgg.drier_types FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('abbr',':',ifnull(OLD.abbr,'null')), concat('description',':',ifnull(OLD.description,'null')), concat('sort_order',':',ifnull(OLD.sort_order,'null'))),'ccgg', 'drier_types',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `extrapolations`
--

DROP TABLE IF EXISTS `extrapolations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `extrapolations` (
  `serial_number` varchar(11) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `time` time DEFAULT '00:00:00',
  `species` varchar(20) DEFAULT NULL,
  `inst` char(5) DEFAULT NULL,
  KEY `pkey` (`serial_number`,`date`,`time`,`species`,`inst`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_analysis`
--

DROP TABLE IF EXISTS `flask_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_analysis` (
  `event_num` int(11) NOT NULL,
  `system` varchar(12) NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `initial_flask_press` decimal(12,4) DEFAULT NULL,
  `final_flask_press` decimal(12,4) DEFAULT NULL,
  `manifold` varchar(10) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_num`,`system`,`start_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=MyISAM AUTO_INCREMENT=12473753 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER flask_data_binsert_trigger
    before insert on flask_data
    for each row
    begin
      
	  
		
		set new.creation_datetime=now();

      
      
      
      if((select count(*)  
         from autoupdateable_data_flags a, flask_event e 
         where e.num=new.event_num and 
            (a.project_num=0 or a.project_num=e.project_num) and 
            (a.program_num=0 or a.program_num=new.program_num) and 
            (a.strategy_num=0 or a.strategy_num=e.strategy_num) and 
            (a.parameter_num=0 or a.parameter_num=new.parameter_num) and 
            (a.site_num=0 or a.site_num=e.site_num)             
         )>0) then 
          
         set new.update_flag_from_tags=1; 
       
      end if; 
    end */;;
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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_data_ainsert_trigger` AFTER INSERT ON `flask_data` FOR EACH ROW       

      INSERT INTO flask_data_history
      SET num = NEW.num,
          event_num = NEW.event_num,
          program_num = NEW.program_num,
          parameter_num = NEW.parameter_num,
          value = NEW.value,
          unc = NEW.unc,
          flag = NEW.flag,
          inst = NEW.inst,
          date = NEW.date,
          time = NEW.time,
          dd = NEW.dd,
          comment = NEW.comment,
          update_flag_from_tags = NEW.update_flag_from_tags,
          history_user = USER(),
          history_action = 'INSERT' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER flask_data_bupdate_trigger
    before update on flask_data
    for each row
    begin
      

	   

      
      
      
      
      
      
      
      
      
      
       
      if (new.update_flag_from_tags<0) then 
            set new.update_flag_from_tags=1; 
      elseif (new.flag!=old.flag and old.update_flag_from_tags>0 and new.update_flag_from_tags>0) then  
         
         
		
		
		
		
		
		insert tag_entry_errors (data_num,flag,user,comment) select new.num,new.flag,user(),'flag update prevented by trigger tagging logic';

		
		set new.flag=old.flag;

      end if; 
    end */;;
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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_data_aupdate_trigger` AFTER UPDATE ON `flask_data` FOR EACH ROW  BEGIN
      

      IF OLD.num != NEW.num THEN
         
         
         
         
         INSERT INTO flask_data_history
            SET num = OLD.num,
                event_num = OLD.event_num,
                program_num = OLD.program_num,
                parameter_num = OLD.parameter_num,
                value = OLD.value,
                unc = OLD.unc,
                flag = OLD.flag,
                inst = OLD.inst,
                date = OLD.date,
                time = OLD.time,
                dd = OLD.dd,
                comment = OLD.comment,
                update_flag_from_tags = OLD.update_flag_from_tags,
                history_user = USER(),
                history_action = 'DELETE';

         INSERT INTO flask_data_history
            SET num = NEW.num,
                event_num = NEW.event_num,
                program_num = NEW.program_num,
                parameter_num = NEW.parameter_num,
                value = NEW.value,
                unc = NEW.unc,
                flag = NEW.flag,
                inst = NEW.inst,
                date = NEW.date,
                time = NEW.time,
                dd = NEW.dd,
                comment = NEW.comment,
                update_flag_from_tags = NEW.update_flag_from_tags,
                history_user = USER(),
                history_action = 'INSERT';
      ELSE
         IF NEW.event_num != OLD.event_num OR
            NEW.program_num != OLD.program_num OR
            NEW.parameter_num != OLD.parameter_num OR
            NEW.value != OLD.value OR
            NEW.unc != OLD.unc OR
            NEW.flag != OLD.flag OR
            NEW.inst != OLD.inst OR
            NEW.date != OLD.date OR
            NEW.time != OLD.time OR
            NEW.dd != OLD.dd OR
            NEW.comment != OLD.comment OR
            NEW.update_flag_from_tags != OLD.update_flag_from_tags THEN
            INSERT INTO flask_data_history
               SET num = NEW.num,
                   event_num = NEW.event_num,
                   program_num = NEW.program_num,
                   parameter_num = NEW.parameter_num,
                   value = NEW.value,
                   unc = NEW.unc,
                   flag = NEW.flag,
                   inst = NEW.inst,
                   date = NEW.date,
                   time = NEW.time,
                   dd = NEW.dd,
                   comment = NEW.comment,
                   update_flag_from_tags = NEW.update_flag_from_tags,
                   history_user = USER(),
                   history_action = 'UPDATE';
         END IF;
      END IF;
   END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER flask_data_bdelete_trigger
    before delete
    on flask_data
    for each row
    begin
      

       delete from flask_data_tag_range where data_num=old.num;         
    end */;;
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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_data_adelete_trigger` AFTER DELETE ON `flask_data` FOR EACH ROW       

      INSERT INTO flask_data_history
      SET num = OLD.num,
          event_num = OLD.event_num,
          program_num = OLD.program_num,
          parameter_num = OLD.parameter_num,
          value = OLD.value,
          unc = OLD.unc,
          flag = OLD.flag,
          inst = OLD.inst,
          date = OLD.date,
          time = OLD.time,
          dd = OLD.dd,
          comment = OLD.comment,
          update_flag_from_tags = OLD.update_flag_from_tags,
          history_user = USER(),
          history_action = 'DELETE' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `flask_data_history`
--

DROP TABLE IF EXISTS `flask_data_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data_history` (
  `num` int(10) unsigned NOT NULL,
  `event_num` mediumint(8) unsigned DEFAULT NULL,
  `program_num` int(11) unsigned NOT NULL DEFAULT 1,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `flag` varchar(4) NOT NULL DEFAULT '...',
  `inst` varchar(4) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `comment` text NOT NULL,
  `update_flag_from_tags` tinyint(4) NOT NULL DEFAULT 0,
  `history_user` varchar(50) NOT NULL DEFAULT 'USER()',
  `history_action` char(6) NOT NULL,
  `history_action_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `i1` (`event_num`,`program_num`,`parameter_num`,`inst`,`date`,`time`),
  KEY `num` (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_data_tag_range`
--

DROP TABLE IF EXISTS `flask_data_tag_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data_tag_range` (
  `data_num` int(10) unsigned NOT NULL,
  `range_num` int(11) NOT NULL,
  PRIMARY KEY (`data_num`,`range_num`),
  KEY `range_num` (`range_num`,`data_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `flask_data_tag_range_info_view`
--

DROP TABLE IF EXISTS `flask_data_tag_range_info_view`;
/*!50001 DROP VIEW IF EXISTS `flask_data_tag_range_info_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_data_tag_range_info_view` (
  `range_num` tinyint NOT NULL,
  `ev_startDate` tinyint NOT NULL,
  `ev_endDate` tinyint NOT NULL,
  `startDate` tinyint NOT NULL,
  `endDate` tinyint NOT NULL,
  `rowcount` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `flask_data_tag_view`
--

DROP TABLE IF EXISTS `flask_data_tag_view`;
/*!50001 DROP VIEW IF EXISTS `flask_data_tag_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_data_tag_view` (
  `data_num` tinyint NOT NULL,
  `range_num` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `data_source` tinyint NOT NULL,
  `tag_num` tinyint NOT NULL,
  `internal_flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `group_name` tinyint NOT NULL,
  `group_name2` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `sort_order2` tinyint NOT NULL,
  `sort_order3` tinyint NOT NULL,
  `sort_order4` tinyint NOT NULL,
  `hats_sort` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `deprecated` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `short_name` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `reject_min_severity` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `unknown_issue` tinyint NOT NULL,
  `automated` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `min_severity` tinyint NOT NULL,
  `max_severity` tinyint NOT NULL,
  `last_modified` tinyint NOT NULL,
  `hats_perseus` tinyint NOT NULL,
  `hats_ng` tinyint NOT NULL,
  `exclusion` tinyint NOT NULL,
  `prelim_data` tinyint NOT NULL,
  `parent_tag_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `hats_interpolation` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `flask_data_view`
--

DROP TABLE IF EXISTS `flask_data_view`;
/*!50001 DROP VIEW IF EXISTS `flask_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_data_view` (
  `event_num` tinyint NOT NULL,
  `ccgg_event_num` tinyint NOT NULL,
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
-- Temporary table structure for view `flask_ev_data_view`
--

DROP TABLE IF EXISTS `flask_ev_data_view`;
/*!50001 DROP VIEW IF EXISTS `flask_ev_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_ev_data_view` (
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `a_date` tinyint NOT NULL,
  `a_time` tinyint NOT NULL,
  `a_dd` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `method` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_event_ainsert_trigger` AFTER INSERT ON `flask_event` FOR EACH ROW       

      INSERT INTO flask_event_history
      SET num = NEW.num,
          site_num = NEW.site_num,
          project_num = NEW.project_num,
          strategy_num = NEW.strategy_num,
          date = NEW.date,
          time = NEW.time,
          dd = NEW.dd,
          id = NEW.id,
          me = NEW.me,
          lat = NEW.lat,
          lon = NEW.lon,
          alt = NEW.alt,
          elev = NEW.elev,
          comment = NEW.comment,
          history_user = USER(),
          history_action = 'INSERT' */;;
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
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`flask_event_BEFORE_UPDATE` BEFORE UPDATE ON `flask_event` FOR EACH ROW
BEGIN
	if OLD.date!=NEW.date or OLD.time!=NEW.time then
		set NEW.dd=f_date2dec(NEW.date,NEW.time);
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
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_event_aupdate_trigger` 
   AFTER UPDATE ON `flask_event` 
   FOR EACH ROW 
   BEGIN 
      
	  IF OLD.lat != NEW.lat or old.lon != new.lon or old.alt!=new.alt or old.elev!=new.elev or old.date != new.date or old.time!=new.time then
		delete from flask_met where event_num=old.num;
	  end if;
      
      IF OLD.num != NEW.num THEN 
          
          
          
          
         INSERT INTO flask_event_history 
            SET num = OLD.num, 
                site_num = OLD.site_num, 
                project_num = OLD.project_num, 
                strategy_num = OLD.strategy_num, 
                date = OLD.date, 
                time = OLD.time, 
                dd = OLD.dd, 
                id = OLD.id, 
                me = OLD.me, 
                lat = OLD.lat, 
                lon = OLD.lon, 
                alt = OLD.alt, 
                elev = OLD.elev, 
                comment = OLD.comment, 
                history_user = USER(), 
                history_action = 'DELETE'; 
 
         INSERT INTO flask_event_history 
            SET num = NEW.num, 
                site_num = NEW.site_num, 
                project_num = NEW.project_num, 
                strategy_num = NEW.strategy_num, 
                date = NEW.date, 
                time = NEW.time, 
                dd = NEW.dd, 
                id = NEW.id, 
                me = NEW.me, 
                lat = NEW.lat, 
                lon = NEW.lon, 
                alt = NEW.alt, 
                elev = NEW.elev, 
                comment = NEW.comment, 
                history_user = USER(), 
                history_action = 'INSERT'; 
 
      ELSE 
         IF NEW.site_num != OLD.site_num OR 
            NEW.project_num != OLD.project_num OR 
            NEW.strategy_num != OLD.strategy_num OR 
            NEW.date != OLD.date OR 
            NEW.time != OLD.time OR 
            NEW.dd != OLD.dd OR 
            NEW.id != OLD.id OR 
            NEW.me != OLD.me OR 
            NEW.lat != OLD.lat OR 
            NEW.lon != OLD.lon OR 
            NEW.alt != OLD.alt OR 
            NEW.elev != OLD.elev OR 
            NEW.comment != OLD.comment THEN 
            INSERT INTO flask_event_history 
               SET num = NEW.num, 
                   site_num = NEW.site_num, 
                   project_num = NEW.project_num, 
                   strategy_num = NEW.strategy_num, 
                   date = NEW.date, 
                   time = NEW.time, 
                   dd = NEW.dd, 
                   id = NEW.id, 
                   me = NEW.me, 
                   lat = NEW.lat, 
                   lon = NEW.lon, 
                   alt = NEW.alt, 
                   elev = NEW.elev, 
                   comment = NEW.comment, 
                   history_user = USER(), 
                   history_action = 'UPDATE'; 
         END IF; 
      END IF; 
   END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER flask_event_bdelete_trigger
    before delete on flask_event
    for each row
    begin
      

       delete from flask_event_tag_range where event_num=old.num;  
       delete from flask_met where event_num=old.num;
    end */;;
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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`140.172.193.%`*/ /*!50003 TRIGGER `flask_event_adelete_trigger` AFTER DELETE ON `flask_event` FOR EACH ROW       

      INSERT INTO flask_event_history
      SET num = OLD.num,
          site_num = OLD.site_num,
          project_num = OLD.project_num,
          strategy_num = OLD.strategy_num,
          date = OLD.date,
          time = OLD.time,
          dd = OLD.dd,
          id = OLD.id,
          me = OLD.me,
          lat = OLD.lat,
          lon = OLD.lon,
          alt = OLD.alt,
          elev = OLD.elev,
          comment = OLD.comment,
          history_user = USER(),
          history_action = 'DELETE' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `flask_event_binning_view`
--

DROP TABLE IF EXISTS `flask_event_binning_view`;
/*!50001 DROP VIEW IF EXISTS `flask_event_binning_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_event_binning_view` (
  `event_num` tinyint NOT NULL,
  `bin_site` tinyint NOT NULL,
  `bin_site_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `flask_event_detail`
--

DROP TABLE IF EXISTS `flask_event_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_event_detail` (
  `event_num` int(11) NOT NULL,
  `prefill_manifold_flush` decimal(6,2) DEFAULT NULL,
  `prefill_sample_flush` decimal(6,2) DEFAULT NULL,
  `prefill_fill_vol` decimal(6,2) DEFAULT NULL,
  `prefill_fill_pressure` decimal(6,2) DEFAULT NULL,
  `time_start_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `time_end_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `prefill_all_time_start_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `prefill_all_time_end_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `prefill_each_time_start_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `prefill_each_time_end_dt` datetime DEFAULT NULL COMMENT 'Note this may deviate from flask_event.date/time.  See table comment',
  `prefill_each_flag_str` varchar(255) DEFAULT NULL,
  `pfp_minus_sys_time` int(11) DEFAULT NULL,
  `db_time_corrected` tinyint(1) DEFAULT 0 COMMENT 'If 1 then the corresponding flask_event.date/time have been corrected based on other diagnostic data.  This is used by correction logic to determine when row has been processed and verified.  See table comments for more details.',
  PRIMARY KEY (`event_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Details for the sample event beyond flask_event.  This was mostly created for pfp samples (imported directly from history files without alteration), but can be used for either flasks or pfp.  Note that pfp times are often incorrect due to clock drift.  Effort is made to correct the flask_event datetime, but we do not update the times in this table  or source history file to preserver history and as it is too complicated.  Instead tools and queries to access data use prefill each duration (end-start) and prefill all duration.  ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_event_history`
--

DROP TABLE IF EXISTS `flask_event_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_event_history` (
  `num` mediumint(8) unsigned NOT NULL,
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
  `comment` tinytext NOT NULL,
  `history_user` varchar(50) NOT NULL DEFAULT 'USER()',
  `history_action` char(6) NOT NULL,
  `history_action_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `i1` (`site_num`),
  KEY `i2` (`project_num`),
  KEY `i3` (`strategy_num`),
  KEY `i4` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `num` (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_event_tag_range`
--

DROP TABLE IF EXISTS `flask_event_tag_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_event_tag_range` (
  `event_num` int(10) unsigned NOT NULL,
  `range_num` int(11) NOT NULL,
  PRIMARY KEY (`event_num`,`range_num`),
  KEY `range_num` (`range_num`,`event_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `flask_event_tag_range_info_view`
--

DROP TABLE IF EXISTS `flask_event_tag_range_info_view`;
/*!50001 DROP VIEW IF EXISTS `flask_event_tag_range_info_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_event_tag_range_info_view` (
  `range_num` tinyint NOT NULL,
  `startDate` tinyint NOT NULL,
  `endDate` tinyint NOT NULL,
  `rowcount` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `flask_event_tag_view`
--

DROP TABLE IF EXISTS `flask_event_tag_view`;
/*!50001 DROP VIEW IF EXISTS `flask_event_tag_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_event_tag_view` (
  `event_num` tinyint NOT NULL,
  `range_num` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `data_source` tinyint NOT NULL,
  `tag_num` tinyint NOT NULL,
  `internal_flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `group_name` tinyint NOT NULL,
  `group_name2` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `sort_order2` tinyint NOT NULL,
  `sort_order3` tinyint NOT NULL,
  `sort_order4` tinyint NOT NULL,
  `hats_sort` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `deprecated` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `short_name` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `reject_min_severity` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `unknown_issue` tinyint NOT NULL,
  `automated` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `min_severity` tinyint NOT NULL,
  `max_severity` tinyint NOT NULL,
  `last_modified` tinyint NOT NULL,
  `hats_perseus` tinyint NOT NULL,
  `hats_ng` tinyint NOT NULL,
  `exclusion` tinyint NOT NULL,
  `prelim_data` tinyint NOT NULL,
  `parent_tag_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `hats_interpolation` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `flask_event_view`
--

DROP TABLE IF EXISTS `flask_event_view`;
/*!50001 DROP VIEW IF EXISTS `flask_event_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_event_view` (
  `num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `time` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `datetime` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `prettyEvDate` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `id` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `me` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `intake_ht` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `flask_inv`
--

DROP TABLE IF EXISTS `flask_inv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_inv` (
  `id` varchar(20) NOT NULL DEFAULT '',
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `sample_status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `path` varchar(80) NOT NULL DEFAULT '',
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `i1` (`id`),
  KEY `i2` (`site_num`,`id`),
  KEY `i3` (`sample_status_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_case`
--

DROP TABLE IF EXISTS `flask_log_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_case` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `id` varchar(20) NOT NULL DEFAULT '',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `keyword_num` smallint(5) NOT NULL DEFAULT 0,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=969 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_commenttype`
--

DROP TABLE IF EXISTS `flask_log_commenttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_commenttype` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_keyword`
--

DROP TABLE IF EXISTS `flask_log_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_keyword` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `comment_type_num` smallint(5) NOT NULL DEFAULT 0,
  `name` varchar(50) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_t1`
--

DROP TABLE IF EXISTS `flask_log_t1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_t1` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `case_num` smallint(5) NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `spike` float NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=1507 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_t2`
--

DROP TABLE IF EXISTS `flask_log_t2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_t2` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `case_num` smallint(5) NOT NULL DEFAULT 0,
  `user` varchar(10) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=522 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_testcomment`
--

DROP TABLE IF EXISTS `flask_log_testcomment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_testcomment` (
  `test_num` smallint(5) NOT NULL DEFAULT 0,
  `testtype_num` smallint(5) NOT NULL DEFAULT 0,
  `comment_type_num` smallint(5) NOT NULL DEFAULT 0,
  `keyword_num` smallint(5) NOT NULL DEFAULT 0,
  `comments` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_log_testtype`
--

DROP TABLE IF EXISTS `flask_log_testtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_log_testtype` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_met`
--

DROP TABLE IF EXISTS `flask_met`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_met` (
  `event_num` int(11) NOT NULL,
  `narr_pressure` decimal(12,4) DEFAULT NULL,
  `narr_air_temp` decimal(12,4) DEFAULT NULL,
  `narr_spec_humidity` decimal(12,4) DEFAULT NULL,
  `era5_pressure` decimal(12,4) DEFAULT NULL,
  `era5_air_temp` decimal(12,4) DEFAULT NULL,
  `era5_rel_humidity` decimal(12,4) DEFAULT NULL,
  `era5_spec_humidity` decimal(12,4) DEFAULT NULL,
  `era5_potential_vorticity` decimal(12,4) DEFAULT NULL,
  PRIMARY KEY (`event_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='meteorlogical data from various sources for flask_events';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_method`
--

DROP TABLE IF EXISTS `flask_method`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_method` (
  `method` varchar(3) NOT NULL,
  `description` text NOT NULL,
  `abbr` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`method`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_shipping`
--

DROP TABLE IF EXISTS `flask_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_shipping` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `id` varchar(20) NOT NULL DEFAULT '',
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  KEY `i1` (`site_num`),
  KEY `i2` (`date_out`,`date_in`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `gen_shipping_inv_view`
--

DROP TABLE IF EXISTS `gen_shipping_inv_view`;
/*!50001 DROP VIEW IF EXISTS `gen_shipping_inv_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `gen_shipping_inv_view` (
  `id` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `date_out` tinyint NOT NULL,
  `date_inuse` tinyint NOT NULL,
  `date_outuse` tinyint NOT NULL,
  `date_in` tinyint NOT NULL,
  `notes` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `gggrn_data_view`
--

DROP TABLE IF EXISTS `gggrn_data_view`;
/*!50001 DROP VIEW IF EXISTS `gggrn_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `gggrn_data_view` (
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `sample_method` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `ccgg_event_num` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `a_date` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `me` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `gggrn_pair_avg_view`
--

DROP TABLE IF EXISTS `gggrn_pair_avg_view`;
/*!50001 DROP VIEW IF EXISTS `gggrn_pair_avg_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `gggrn_pair_avg_view` (
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `sample_method` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `pair_avg` tinyint NOT NULL,
  `pair_unc` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `pair_stdv` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `me` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `a_date` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `unc` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `gv_lab`
--

DROP TABLE IF EXISTS `gv_lab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_lab` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) NOT NULL DEFAULT '',
  `country` varchar(80) NOT NULL DEFAULT '',
  `abbr` varchar(30) NOT NULL DEFAULT '',
  `logo` varchar(80) NOT NULL DEFAULT '',
  `notes` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=102 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gv_platform`
--

DROP TABLE IF EXISTS `gv_platform`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_platform` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gv_strategy`
--

DROP TABLE IF EXISTS `gv_strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gv_strategy` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `abbr` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `hats_data_view`
--

DROP TABLE IF EXISTS `hats_data_view`;
/*!50001 DROP VIEW IF EXISTS `hats_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `hats_data_view` (
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `insitu_data`
--

DROP TABLE IF EXISTS `insitu_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_data` (
  `num` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `site_num` smallint(6) NOT NULL,
  `parameter_num` smallint(6) NOT NULL,
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(10,3) NOT NULL DEFAULT -999.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.990,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` varchar(3) NOT NULL DEFAULT '...',
  `inlet` varchar(6) NOT NULL,
  `target` tinyint(1) DEFAULT 0,
  `system` varchar(12) NOT NULL,
  `inst_num` smallint(6) NOT NULL DEFAULT 0,
  `comment` text DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`,`system`,`inst_num`),
  KEY `i2` (`site_num`,`parameter_num`),
  KEY `i3` (`site_num`,`parameter_num`,`target`)
) ENGINE=InnoDB AUTO_INCREMENT=47100496 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='high frequency insitu data for observatories and towers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insitu_data_tag_range`
--

DROP TABLE IF EXISTS `insitu_data_tag_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_data_tag_range` (
  `insitu_num` int(11) NOT NULL,
  `range_num` int(11) NOT NULL,
  PRIMARY KEY (`insitu_num`,`range_num`),
  KEY `i2` (`range_num`,`insitu_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `insitu_data_tag_view`
--

DROP TABLE IF EXISTS `insitu_data_tag_view`;
/*!50001 DROP VIEW IF EXISTS `insitu_data_tag_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `insitu_data_tag_view` (
  `insitu_num` tinyint NOT NULL,
  `range_num` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `data_source` tinyint NOT NULL,
  `tag_num` tinyint NOT NULL,
  `internal_flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `group_name` tinyint NOT NULL,
  `group_name2` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `sort_order2` tinyint NOT NULL,
  `sort_order3` tinyint NOT NULL,
  `sort_order4` tinyint NOT NULL,
  `hats_sort` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `deprecated` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `short_name` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `reject_min_severity` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `unknown_issue` tinyint NOT NULL,
  `automated` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `min_severity` tinyint NOT NULL,
  `max_severity` tinyint NOT NULL,
  `last_modified` tinyint NOT NULL,
  `hats_perseus` tinyint NOT NULL,
  `hats_ng` tinyint NOT NULL,
  `exclusion` tinyint NOT NULL,
  `prelim_data` tinyint NOT NULL,
  `parent_tag_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `hats_interpolation` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `insitu_day`
--

DROP TABLE IF EXISTS `insitu_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_day` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(6) NOT NULL,
  `parameter_num` smallint(6) NOT NULL,
  `date` date NOT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` varchar(4) DEFAULT '*..',
  PRIMARY KEY (`num`),
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`,`intake_ht`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=154055 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Hourly averaged in-situ data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insitu_hour`
--

DROP TABLE IF EXISTS `insitu_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_hour` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(6) NOT NULL,
  `parameter_num` smallint(6) NOT NULL,
  `date` datetime NOT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` varchar(4) DEFAULT '*..',
  `system` varchar(8) NOT NULL,
  `inst_num` smallint(6) DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`,`inst_num`,`system`,`intake_ht`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5117336 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Hourly averaged in-situ data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `insitu_hour_view`
--

DROP TABLE IF EXISTS `insitu_hour_view`;
/*!50001 DROP VIEW IF EXISTS `insitu_hour_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `insitu_hour_view` (
  `num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `intake_ht` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `std_dev` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `hour` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `insitu_month`
--

DROP TABLE IF EXISTS `insitu_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_month` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(6) NOT NULL,
  `parameter_num` smallint(6) NOT NULL,
  `date` date NOT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` varchar(4) DEFAULT '*..',
  PRIMARY KEY (`num`),
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`,`intake_ht`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4939 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Hourly averaged in-situ data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `insitu_view`
--

DROP TABLE IF EXISTS `insitu_view`;
/*!50001 DROP VIEW IF EXISTS `insitu_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `insitu_view` (
  `num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `intake_ht` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `std_dev` tinyint NOT NULL,
  `meas_unc` tinyint NOT NULL,
  `random_unc` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `inlet` tinyint NOT NULL,
  `target` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `hr` tinyint NOT NULL,
  `min` tinyint NOT NULL,
  `sec` tinyint NOT NULL,
  `dd` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inst_OLD`
--

DROP TABLE IF EXISTS `inst_OLD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_OLD` (
  `id` smallint(5) NOT NULL AUTO_INCREMENT,
  `inst` varchar(8) NOT NULL,
  `inst_id` varchar(5) NOT NULL,
  `manufact` varchar(30) NOT NULL,
  `model` varchar(100) NOT NULL,
  `serialnum` varchar(30) NOT NULL,
  `comments` text NOT NULL,
  `property_num` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=89 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_description`
--

DROP TABLE IF EXISTS `inst_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_description` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(45) NOT NULL,
  `abbr` varchar(5) DEFAULT NULL COMMENT 'For legacy 2 and 3 character codes',
  `project_num` int(11) DEFAULT NULL COMMENT 'gmd.project',
  `inst_manuf_num` int(11) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `manuf_year` varchar(10) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `inst_type_num` int(11) DEFAULT NULL COMMENT 'gmd.inst_type.num\n',
  `property_number` varchar(255) DEFAULT NULL COMMENT 'CDO Number',
  `owner` varchar(30) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `os` varchar(45) DEFAULT NULL,
  `motherboard` varchar(45) DEFAULT NULL,
  `ram` varchar(45) DEFAULT NULL,
  `teamviewer_id` varchar(100) DEFAULT NULL,
  `inst_owner_num` int(11) DEFAULT NULL COMMENT 'Fk to inst_owner',
  `inst_owner_other` varchar(100) DEFAULT NULL,
  `contact_num` int(11) DEFAULT NULL COMMENT 'Fk to ccgg.contact',
  `inst_location_num` tinyint(1) DEFAULT NULL,
  `is_available_for_use` tinyint(1) DEFAULT NULL,
  `custodian` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`id`),
  KEY `i` (`project_num`)
) ENGINE=MyISAM AUTO_INCREMENT=220 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='GML wide intstruments table';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`inst_description_BEFORE_INSERT` BEFORE INSERT ON `inst_description` FOR EACH ROW
BEGIN
	if(new.id is null or new.id='' and new.inst_manuf_num is not null and new.inst_manuf_num!=0) then
		set new.id=f_generateInstID(new.inst_manuf_num);
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
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_description_after_insert after insert ON ccgg.inst_description FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('id',':',ifnull(NEW.id,'null')), concat('abbr',':',ifnull(NEW.abbr,'null')), concat('project_num',':',ifnull(NEW.project_num,'null')), concat('inst_manuf_num',':',ifnull(NEW.inst_manuf_num,'null')), concat('model',':',ifnull(NEW.model,'null')), concat('manuf_year',':',ifnull(NEW.manuf_year,'null')), concat('serial_number',':',ifnull(NEW.serial_number,'null')), concat('inst_type_num',':',ifnull(NEW.inst_type_num,'null')), concat('property_number',':',ifnull(NEW.property_number,'null')), concat('owner',':',ifnull(NEW.owner,'null')), concat('comments',':',ifnull(NEW.comments,'null')), concat('os',':',ifnull(NEW.os,'null')), concat('motherboard',':',ifnull(NEW.motherboard,'null')), concat('ram',':',ifnull(NEW.ram,'null')), concat('teamviewer_id',':',ifnull(NEW.teamviewer_id,'null')), concat('inst_owner_num',':',ifnull(NEW.inst_owner_num,'null')), concat('inst_owner_other',':',ifnull(NEW.inst_owner_other,'null')), concat('contact_num',':',ifnull(NEW.contact_num,'null')), concat('inst_location_num',':',ifnull(NEW.inst_location_num,'null')), concat('is_available_for_use',':',ifnull(NEW.is_available_for_use,'null')), concat('custodian',':',ifnull(NEW.custodian,'null'))),'ccgg','inst_description',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_description_after_update after update ON ccgg.inst_description FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.id <> OLD.id, concat('id(Old:',OLD.id,' New:',NEW.id,')'), NULL), IF(NEW.abbr <> OLD.abbr, concat('abbr(Old:',OLD.abbr,' New:',NEW.abbr,')'), NULL), IF(NEW.project_num <> OLD.project_num, concat('project_num(Old:',OLD.project_num,' New:',NEW.project_num,')'), NULL), IF(NEW.inst_manuf_num <> OLD.inst_manuf_num, concat('inst_manuf_num(Old:',OLD.inst_manuf_num,' New:',NEW.inst_manuf_num,')'), NULL), IF(NEW.model <> OLD.model, concat('model(Old:',OLD.model,' New:',NEW.model,')'), NULL), IF(NEW.manuf_year <> OLD.manuf_year, concat('manuf_year(Old:',OLD.manuf_year,' New:',NEW.manuf_year,')'), NULL), IF(NEW.serial_number <> OLD.serial_number, concat('serial_number(Old:',OLD.serial_number,' New:',NEW.serial_number,')'), NULL), IF(NEW.inst_type_num <> OLD.inst_type_num, concat('inst_type_num(Old:',OLD.inst_type_num,' New:',NEW.inst_type_num,')'), NULL), IF(NEW.property_number <> OLD.property_number, concat('property_number(Old:',OLD.property_number,' New:',NEW.property_number,')'), NULL), IF(NEW.owner <> OLD.owner, concat('owner(Old:',OLD.owner,' New:',NEW.owner,')'), NULL), IF(NEW.comments <> OLD.comments, concat('comments(Old:',OLD.comments,' New:',NEW.comments,')'), NULL), IF(NEW.os <> OLD.os, concat('os(Old:',OLD.os,' New:',NEW.os,')'), NULL), IF(NEW.motherboard <> OLD.motherboard, concat('motherboard(Old:',OLD.motherboard,' New:',NEW.motherboard,')'), NULL), IF(NEW.ram <> OLD.ram, concat('ram(Old:',OLD.ram,' New:',NEW.ram,')'), NULL), IF(NEW.teamviewer_id <> OLD.teamviewer_id, concat('teamviewer_id(Old:',OLD.teamviewer_id,' New:',NEW.teamviewer_id,')'), NULL), IF(NEW.inst_owner_num <> OLD.inst_owner_num, concat('inst_owner_num(Old:',OLD.inst_owner_num,' New:',NEW.inst_owner_num,')'), NULL), IF(NEW.inst_owner_other <> OLD.inst_owner_other, concat('inst_owner_other(Old:',OLD.inst_owner_other,' New:',NEW.inst_owner_other,')'), NULL), IF(NEW.contact_num <> OLD.contact_num, concat('contact_num(Old:',OLD.contact_num,' New:',NEW.contact_num,')'), NULL), IF(NEW.inst_location_num <> OLD.inst_location_num, concat('inst_location_num(Old:',OLD.inst_location_num,' New:',NEW.inst_location_num,')'), NULL), IF(NEW.is_available_for_use <> OLD.is_available_for_use, concat('is_available_for_use(Old:',OLD.is_available_for_use,' New:',NEW.is_available_for_use,')'), NULL), IF(NEW.custodian <> OLD.custodian, concat('custodian(Old:',OLD.custodian,' New:',NEW.custodian,')'), NULL)),'ccgg', 'inst_description',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_description_before_delete before delete ON ccgg.inst_description FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('id',':',ifnull(OLD.id,'null')), concat('abbr',':',ifnull(OLD.abbr,'null')), concat('project_num',':',ifnull(OLD.project_num,'null')), concat('inst_manuf_num',':',ifnull(OLD.inst_manuf_num,'null')), concat('model',':',ifnull(OLD.model,'null')), concat('manuf_year',':',ifnull(OLD.manuf_year,'null')), concat('serial_number',':',ifnull(OLD.serial_number,'null')), concat('inst_type_num',':',ifnull(OLD.inst_type_num,'null')), concat('property_number',':',ifnull(OLD.property_number,'null')), concat('owner',':',ifnull(OLD.owner,'null')), concat('comments',':',ifnull(OLD.comments,'null')), concat('os',':',ifnull(OLD.os,'null')), concat('motherboard',':',ifnull(OLD.motherboard,'null')), concat('ram',':',ifnull(OLD.ram,'null')), concat('teamviewer_id',':',ifnull(OLD.teamviewer_id,'null')), concat('inst_owner_num',':',ifnull(OLD.inst_owner_num,'null')), concat('inst_owner_other',':',ifnull(OLD.inst_owner_other,'null')), concat('contact_num',':',ifnull(OLD.contact_num,'null')), concat('inst_location_num',':',ifnull(OLD.inst_location_num,'null')), concat('is_available_for_use',':',ifnull(OLD.is_available_for_use,'null')), concat('custodian',':',ifnull(OLD.custodian,'null'))),'ccgg', 'inst_description',old.num;

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
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`inst_description_AFTER_DELETE` AFTER DELETE ON `inst_description` FOR EACH ROW
BEGIN
	delete from inst_event where inst_num=old.num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `inst_event`
--

DROP TABLE IF EXISTS `inst_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_event` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `inst_num` int(11) NOT NULL,
  `date` date NOT NULL,
  `event_type_num` int(11) NOT NULL COMMENT 'Fk to inst_event_types',
  `comment` text DEFAULT NULL,
  `site_num` int(11) DEFAULT NULL COMMENT 'Optional site where deployed',
  `pi` varchar(255) DEFAULT NULL COMMENT 'Who the responsible PI is for current project',
  `project_name` varchar(255) DEFAULT NULL COMMENT 'Name of deployment project or campaign (not ccgg.project)',
  `repair_reason` varchar(255) DEFAULT NULL COMMENT 'When out for repair, optionally record the reason for repair	',
  `res_start_date` date DEFAULT NULL COMMENT 'Reservation start date\n',
  `res_end_date` date DEFAULT NULL COMMENT 'Reservation end date	',
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=1929 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_event_after_insert after insert ON ccgg.inst_event FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('inst_num',':',ifnull(NEW.inst_num,'null')), concat('date',':',ifnull(NEW.date,'null')), concat('event_type_num',':',ifnull(NEW.event_type_num,'null')), concat('comment',':',ifnull(NEW.comment,'null')), concat('site_num',':',ifnull(NEW.site_num,'null')), concat('pi',':',ifnull(NEW.pi,'null')), concat('project_name',':',ifnull(NEW.project_name,'null')), concat('repair_reason',':',ifnull(NEW.repair_reason,'null')), concat('res_start_date',':',ifnull(NEW.res_start_date,'null')), concat('res_end_date',':',ifnull(NEW.res_end_date,'null'))),'ccgg','inst_event',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_event_after_update after update ON ccgg.inst_event FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.inst_num <> OLD.inst_num, concat('inst_num(Old:',OLD.inst_num,' New:',NEW.inst_num,')'), NULL), IF(NEW.date <> OLD.date, concat('date(Old:',OLD.date,' New:',NEW.date,')'), NULL), IF(NEW.event_type_num <> OLD.event_type_num, concat('event_type_num(Old:',OLD.event_type_num,' New:',NEW.event_type_num,')'), NULL), IF(NEW.comment <> OLD.comment, concat('comment(Old:',OLD.comment,' New:',NEW.comment,')'), NULL), IF(NEW.site_num <> OLD.site_num, concat('site_num(Old:',OLD.site_num,' New:',NEW.site_num,')'), NULL), IF(NEW.pi <> OLD.pi, concat('pi(Old:',OLD.pi,' New:',NEW.pi,')'), NULL), IF(NEW.project_name <> OLD.project_name, concat('project_name(Old:',OLD.project_name,' New:',NEW.project_name,')'), NULL), IF(NEW.repair_reason <> OLD.repair_reason, concat('repair_reason(Old:',OLD.repair_reason,' New:',NEW.repair_reason,')'), NULL), IF(NEW.res_start_date <> OLD.res_start_date, concat('res_start_date(Old:',OLD.res_start_date,' New:',NEW.res_start_date,')'), NULL), IF(NEW.res_end_date <> OLD.res_end_date, concat('res_end_date(Old:',OLD.res_end_date,' New:',NEW.res_end_date,')'), NULL)),'ccgg', 'inst_event',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_inst_event_before_delete before delete ON ccgg.inst_event FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('inst_num',':',ifnull(OLD.inst_num,'null')), concat('date',':',ifnull(OLD.date,'null')), concat('event_type_num',':',ifnull(OLD.event_type_num,'null')), concat('comment',':',ifnull(OLD.comment,'null')), concat('site_num',':',ifnull(OLD.site_num,'null')), concat('pi',':',ifnull(OLD.pi,'null')), concat('project_name',':',ifnull(OLD.project_name,'null')), concat('repair_reason',':',ifnull(OLD.repair_reason,'null')), concat('res_start_date',':',ifnull(OLD.res_start_date,'null')), concat('res_end_date',':',ifnull(OLD.res_end_date,'null'))),'ccgg', 'inst_event',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `inst_event_types`
--

DROP TABLE IF EXISTS `inst_event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_event_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(45) NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_repair` tinyint(1) NOT NULL DEFAULT 0,
  `is_h2o_cal` tinyint(1) NOT NULL DEFAULT 0,
  `is_lab_cal` tinyint(1) NOT NULL DEFAULT 0,
  `can_be_available_for_use` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'This type of event should present user with option to mark inst available for use or not	',
  `is_comment` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 means event type is a comment and does not change whether inst is available or not.',
  `is_deployed` tinyint(1) NOT NULL DEFAULT 0,
  `is_reserved` tinyint(1) NOT NULL DEFAULT 0,
  `is_retired` tinyint(1) DEFAULT 0,
  `is_out_for_repair` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `inst_event_view`
--

DROP TABLE IF EXISTS `inst_event_view`;
/*!50001 DROP VIEW IF EXISTS `inst_event_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `inst_event_view` (
  `inst_event_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `event_type_num` tinyint NOT NULL,
  `event_type_abbr` tinyint NOT NULL,
  `event_type_name` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `site_name` tinyint NOT NULL,
  `pi` tinyint NOT NULL,
  `project_name` tinyint NOT NULL,
  `repair_reason` tinyint NOT NULL,
  `is_repair` tinyint NOT NULL,
  `is_h2o_cal` tinyint NOT NULL,
  `is_lab_cal` tinyint NOT NULL,
  `can_be_available_for_use` tinyint NOT NULL,
  `is_comment` tinyint NOT NULL,
  `is_deployed` tinyint NOT NULL,
  `is_retired` tinyint NOT NULL,
  `is_out_for_repair` tinyint NOT NULL,
  `event_type` tinyint NOT NULL,
  `current` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inst_history_OLD`
--

DROP TABLE IF EXISTS `inst_history_OLD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_history_OLD` (
  `id` smallint(5) NOT NULL AUTO_INCREMENT,
  `inst` varchar(8) NOT NULL,
  `parameter_num` mediumint(9) NOT NULL,
  `startdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `enddate` datetime NOT NULL DEFAULT '9999-01-01 00:00:00',
  `location` varchar(128) NOT NULL DEFAULT '',
  `site_num` smallint(6) NOT NULL,
  `System` varchar(30) NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=126 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_inventory_OLD`
--

DROP TABLE IF EXISTS `inst_inventory_OLD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_inventory_OLD` (
  `inst_num` int(11) NOT NULL COMMENT 'gmd.inst.num',
  `site_num` int(11) NOT NULL COMMENT 'gmd.site',
  `date` datetime NOT NULL,
  `comments` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`inst_num`,`site_num`,`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_locations`
--

DROP TABLE IF EXISTS `inst_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_locations` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(45) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_manufacturer`
--

DROP TABLE IF EXISTS `inst_manufacturer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_manufacturer` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `comments` varchar(1000) DEFAULT NULL,
  `id_prefix` varchar(4) DEFAULT NULL COMMENT 'Used to create a unique id in inst_description.id',
  PRIMARY KEY (`num`),
  UNIQUE KEY `index2` (`id_prefix`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_owner`
--

DROP TABLE IF EXISTS `inst_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_owner` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(30) NOT NULL,
  `Name` varchar(255) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_type`
--

DROP TABLE IF EXISTS `inst_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_type` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `abbr` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_usage_history`
--

DROP TABLE IF EXISTS `inst_usage_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_usage_history` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `inst_num` int(11) NOT NULL COMMENT 'gmd.inst.num	',
  `site_num` int(11) NOT NULL COMMENT 'gmd.site',
  `parameter_num` int(11) DEFAULT NULL COMMENT 'gmd.parameter',
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `system` varchar(45) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i` (`inst_num`),
  KEY `i2` (`site_num`),
  KEY `i3` (`parameter_num`),
  KEY `i4` (`site_num`,`start_date`,`end_date`),
  KEY `u` (`inst_num`,`parameter_num`,`start_date`)
) ENGINE=MyISAM AUTO_INCREMENT=1237 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `inst_view`
--

DROP TABLE IF EXISTS `inst_view`;
/*!50001 DROP VIEW IF EXISTS `inst_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `inst_view` (
  `inst_num` tinyint NOT NULL,
  `id` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `manufacturer` tinyint NOT NULL,
  `inst_manuf_num` tinyint NOT NULL,
  `model` tinyint NOT NULL,
  `manuf_year` tinyint NOT NULL,
  `serial_number` tinyint NOT NULL,
  `inst_type` tinyint NOT NULL,
  `inst_type_num` tinyint NOT NULL,
  `property_number` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `owner` tinyint NOT NULL,
  `other_owner` tinyint NOT NULL,
  `os` tinyint NOT NULL,
  `motherboard` tinyint NOT NULL,
  `ram` tinyint NOT NULL,
  `teamviewer_id` tinyint NOT NULL,
  `curr_event_num` tinyint NOT NULL,
  `curr_event_type` tinyint NOT NULL,
  `curr_event_type_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `site_name` tinyint NOT NULL,
  `last_h2o_cal` tinyint NOT NULL,
  `last_lab_cal` tinyint NOT NULL,
  `can_be_available_for_use` tinyint NOT NULL,
  `is_available_for_use` tinyint NOT NULL,
  `inst_location_num` tinyint NOT NULL,
  `loc_abbr` tinyint NOT NULL,
  `location` tinyint NOT NULL,
  `is_deployed` tinyint NOT NULL,
  `is_retired` tinyint NOT NULL,
  `is_out_for_repair` tinyint NOT NULL,
  `contact` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `instrument_OLD`
--

DROP TABLE IF EXISTS `instrument_OLD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instrument_OLD` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `id` varchar(4) NOT NULL DEFAULT '',
  `name` text NOT NULL,
  `startdate` date NOT NULL DEFAULT '0000-00-00',
  `enddate` date NOT NULL DEFAULT '0000-00-00',
  `location` varchar(128) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=59 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intake_height`
--

DROP TABLE IF EXISTS `intake_height`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intake_height` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `height` decimal(6,2) NOT NULL,
  `intake_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_height_after_insert after insert ON ccgg.intake_height FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('id',':',ifnull(NEW.id,'null')), concat('site_num',':',ifnull(NEW.site_num,'null')), concat('parameter_num',':',ifnull(NEW.parameter_num,'null')), concat('start_date',':',ifnull(NEW.start_date,'null')), concat('end_date',':',ifnull(NEW.end_date,'null')), concat('height',':',ifnull(NEW.height,'null')), concat('intake_id',':',ifnull(NEW.intake_id,'null'))),'ccgg','intake_height',new.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_height_after_update after update ON ccgg.intake_height FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.id <> OLD.id, concat('id(Old:',OLD.id,' New:',NEW.id,')'), NULL), IF(NEW.site_num <> OLD.site_num, concat('site_num(Old:',OLD.site_num,' New:',NEW.site_num,')'), NULL), IF(NEW.parameter_num <> OLD.parameter_num, concat('parameter_num(Old:',OLD.parameter_num,' New:',NEW.parameter_num,')'), NULL), IF(NEW.start_date <> OLD.start_date, concat('start_date(Old:',OLD.start_date,' New:',NEW.start_date,')'), NULL), IF(NEW.end_date <> OLD.end_date, concat('end_date(Old:',OLD.end_date,' New:',NEW.end_date,')'), NULL), IF(NEW.height <> OLD.height, concat('height(Old:',OLD.height,' New:',NEW.height,')'), NULL), IF(NEW.intake_id <> OLD.intake_id, concat('intake_id(Old:',OLD.intake_id,' New:',NEW.intake_id,')'), NULL)),'ccgg', 'intake_height',new.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_height_before_delete before delete ON ccgg.intake_height FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('id',':',ifnull(OLD.id,'null')), concat('site_num',':',ifnull(OLD.site_num,'null')), concat('parameter_num',':',ifnull(OLD.parameter_num,'null')), concat('start_date',':',ifnull(OLD.start_date,'null')), concat('end_date',':',ifnull(OLD.end_date,'null')), concat('height',':',ifnull(OLD.height,'null')), concat('intake_id',':',ifnull(OLD.intake_id,'null'))),'ccgg', 'intake_height',old.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `intake_heights`
--

DROP TABLE IF EXISTS `intake_heights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intake_heights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `parameter_num` tinyint(4) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `inlet` varchar(6) NOT NULL,
  `height` decimal(8,3) NOT NULL,
  `comment` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=142 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_heights_after_insert after insert ON ccgg.intake_heights FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('id',':',ifnull(NEW.id,'null')), concat('site_num',':',ifnull(NEW.site_num,'null')), concat('parameter_num',':',ifnull(NEW.parameter_num,'null')), concat('start_date',':',ifnull(NEW.start_date,'null')), concat('end_date',':',ifnull(NEW.end_date,'null')), concat('inlet',':',ifnull(NEW.inlet,'null')), concat('height',':',ifnull(NEW.height,'null')), concat('comment',':',ifnull(NEW.comment,'null'))),'ccgg','intake_heights',new.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_heights_after_update after update ON ccgg.intake_heights FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.id <> OLD.id, concat('id(Old:',OLD.id,' New:',NEW.id,')'), NULL), IF(NEW.site_num <> OLD.site_num, concat('site_num(Old:',OLD.site_num,' New:',NEW.site_num,')'), NULL), IF(NEW.parameter_num <> OLD.parameter_num, concat('parameter_num(Old:',OLD.parameter_num,' New:',NEW.parameter_num,')'), NULL), IF(NEW.start_date <> OLD.start_date, concat('start_date(Old:',OLD.start_date,' New:',NEW.start_date,')'), NULL), IF(NEW.end_date <> OLD.end_date, concat('end_date(Old:',OLD.end_date,' New:',NEW.end_date,')'), NULL), IF(NEW.inlet <> OLD.inlet, concat('inlet(Old:',OLD.inlet,' New:',NEW.inlet,')'), NULL), IF(NEW.height <> OLD.height, concat('height(Old:',OLD.height,' New:',NEW.height,')'), NULL), IF(NEW.comment <> OLD.comment, concat('comment(Old:',OLD.comment,' New:',NEW.comment,')'), NULL)),'ccgg', 'intake_heights',new.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_intake_heights_before_delete before delete ON ccgg.intake_heights FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('id',':',ifnull(OLD.id,'null')), concat('site_num',':',ifnull(OLD.site_num,'null')), concat('parameter_num',':',ifnull(OLD.parameter_num,'null')), concat('start_date',':',ifnull(OLD.start_date,'null')), concat('end_date',':',ifnull(OLD.end_date,'null')), concat('inlet',':',ifnull(OLD.inlet,'null')), concat('height',':',ifnull(OLD.height,'null')), concat('comment',':',ifnull(OLD.comment,'null'))),'ccgg', 'intake_heights',old.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `internal_flag`
--

DROP TABLE IF EXISTS `internal_flag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `internal_flag` (
  `event_num` mediumint(8) unsigned NOT NULL,
  `program_num` int(11) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `flag_type_num` tinyint(3) unsigned NOT NULL,
  `flag` varchar(1) NOT NULL,
  `comment` tinytext NOT NULL,
  KEY `i1` (`event_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `internal_flag_definitions`
--

DROP TABLE IF EXISTS `internal_flag_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `internal_flag_definitions` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `flag` varchar(1) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `type_num` tinyint(4) NOT NULL,
  `program_num` tinyint(4) NOT NULL DEFAULT 0,
  `assignment` varchar(1) NOT NULL COMMENT '[R]reject,[S]election,[I]nformation',
  `name` varchar(256) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=86 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `internal_flag_type`
--

DROP TABLE IF EXISTS `internal_flag_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `internal_flag_type` (
  `num` tinyint(3) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `abbr` varchar(2) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_deficit_history`
--

DROP TABLE IF EXISTS `inv_deficit_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inv_deficit_history` (
  `date` date NOT NULL,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `project_num` int(11) NOT NULL DEFAULT 0,
  `deficit` int(11) DEFAULT 0,
  PRIMARY KEY (`date`,`strategy_num`,`project_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_queue_history`
--

DROP TABLE IF EXISTS `inv_queue_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inv_queue_history` (
  `date` date NOT NULL,
  `strategy_num` int(11) NOT NULL,
  `system_num` int(11) NOT NULL,
  `queue_n` int(11) NOT NULL DEFAULT 0,
  `queue_age` int(11) NOT NULL DEFAULT 0,
  `queue_avg_age` float DEFAULT 0,
  `pipeline_n` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`strategy_num`,`system_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_co2_insitu`
--

DROP TABLE IF EXISTS `lab_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab_co_insitu`
--

DROP TABLE IF EXISTS `lab_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_ch4_hour`
--

DROP TABLE IF EXISTS `lef_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_ch4_insitu`
--

DROP TABLE IF EXISTS `lef_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_co2_hour`
--

DROP TABLE IF EXISTS `lef_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_co2_insitu`
--

DROP TABLE IF EXISTS `lef_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_co_hour`
--

DROP TABLE IF EXISTS `lef_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_co_insitu`
--

DROP TABLE IF EXISTS `lef_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map`
--

DROP TABLE IF EXISTS `map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `jpg` varchar(60) NOT NULL DEFAULT '',
  `notes` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_coords`
--

DROP TABLE IF EXISTS `map_coords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_coords` (
  `site_num` int(10) unsigned DEFAULT NULL,
  `map_num` int(10) unsigned DEFAULT NULL,
  `coord` varchar(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  KEY `smn` (`site_num`,`map_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mbo_co2_hour`
--

DROP TABLE IF EXISTS `mbo_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mbo_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mbo_co2_insitu`
--

DROP TABLE IF EXISTS `mbo_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mbo_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mbo_co_hour`
--

DROP TABLE IF EXISTS `mbo_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mbo_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mbo_co_insitu`
--

DROP TABLE IF EXISTS `mbo_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mbo_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_ch4_day`
--

DROP TABLE IF EXISTS `mko_ch4_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_ch4_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_ch4_hour`
--

DROP TABLE IF EXISTS `mko_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_ch4_insitu`
--

DROP TABLE IF EXISTS `mko_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` decimal(8,2) NOT NULL DEFAULT -999.99,
  `unc` decimal(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_ch4_month`
--

DROP TABLE IF EXISTS `mko_ch4_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_ch4_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co2_day`
--

DROP TABLE IF EXISTS `mko_co2_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co2_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co2_hour`
--

DROP TABLE IF EXISTS `mko_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co2_insitu`
--

DROP TABLE IF EXISTS `mko_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co2_month`
--

DROP TABLE IF EXISTS `mko_co2_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co2_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co_day`
--

DROP TABLE IF EXISTS `mko_co_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co_hour`
--

DROP TABLE IF EXISTS `mko_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co_insitu`
--

DROP TABLE IF EXISTS `mko_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) NOT NULL DEFAULT 0.00,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mko_co_month`
--

DROP TABLE IF EXISTS `mko_co_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mko_co_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_ch4_day`
--

DROP TABLE IF EXISTS `mlo_ch4_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_ch4_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_ch4_hour`
--

DROP TABLE IF EXISTS `mlo_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_ch4_insitu`
--

DROP TABLE IF EXISTS `mlo_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` decimal(8,2) NOT NULL DEFAULT -999.99,
  `unc` decimal(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_ch4_month`
--

DROP TABLE IF EXISTS `mlo_ch4_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_ch4_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_ch4_target`
--

DROP TABLE IF EXISTS `mlo_ch4_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_ch4_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_day`
--

DROP TABLE IF EXISTS `mlo_co2_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_hour`
--

DROP TABLE IF EXISTS `mlo_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_insitu`
--

DROP TABLE IF EXISTS `mlo_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_insitu_b`
--

DROP TABLE IF EXISTS `mlo_co2_insitu_b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_insitu_b` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_month`
--

DROP TABLE IF EXISTS `mlo_co2_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_target`
--

DROP TABLE IF EXISTS `mlo_co2_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co2_target_b`
--

DROP TABLE IF EXISTS `mlo_co2_target_b`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co2_target_b` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co_day`
--

DROP TABLE IF EXISTS `mlo_co_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co_hour`
--

DROP TABLE IF EXISTS `mlo_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co_insitu`
--

DROP TABLE IF EXISTS `mlo_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(4) NOT NULL DEFAULT 0,
  `sec` tinyint(4) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT -999.990,
  `std_dev` float(8,2) NOT NULL DEFAULT 0.00,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` int(11) NOT NULL DEFAULT 1,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `inlet` tinyint(4) NOT NULL,
  PRIMARY KEY (`date`,`intake_ht`,`inst`,`hr`,`min`,`sec`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co_month`
--

DROP TABLE IF EXISTS `mlo_co_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_co_target`
--

DROP TABLE IF EXISTS `mlo_co_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_co_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mobile_insitu_data`
--

DROP TABLE IF EXISTS `mobile_insitu_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mobile_insitu_data` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `event_num` int(11) NOT NULL COMMENT 'FK to ccgg.campaign_event.num',
  `program_num` int(11) NOT NULL DEFAULT 1,
  `parameter_num` int(11) NOT NULL COMMENT 'FK to gmd.parameter.num',
  `mobile_insitu_inst_num` int(11) DEFAULT NULL COMMENT 'FK to ccgg.mobile_insitu_instruments.num	',
  `value` decimal(12,4) NOT NULL,
  `stddev` decimal(12,4) DEFAULT NULL,
  `n` int(11) DEFAULT NULL,
  `interval_sec` int(11) NOT NULL DEFAULT 0 COMMENT 'seconds in averaging window for this measurement.',
  `unc` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) NOT NULL DEFAULT '...',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`event_num`,`parameter_num`,`mobile_insitu_inst_num`,`interval_sec`)
) ENGINE=InnoDB AUTO_INCREMENT=1955734 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `mobile_insitu_data_view`
--

DROP TABLE IF EXISTS `mobile_insitu_data_view`;
/*!50001 DROP VIEW IF EXISTS `mobile_insitu_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `mobile_insitu_data_view` (
  `num` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `program` tinyint NOT NULL,
  `instrument` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `expedition_id` tinyint NOT NULL,
  `profile_num` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `intake_id` tinyint NOT NULL,
  `interval_sec` tinyint NOT NULL,
  `vehicle_num` tinyint NOT NULL,
  `vehicle` tinyint NOT NULL,
  `vehicle_abbr` tinyint NOT NULL,
  `airplane` tinyint NOT NULL,
  `boat` tinyint NOT NULL,
  `automobile` tinyint NOT NULL,
  `campaign_abbr` tinyint NOT NULL,
  `campaign_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mobile_insitu_event`
--

DROP TABLE IF EXISTS `mobile_insitu_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mobile_insitu_event` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL DEFAULT 0 COMMENT 'FK to gmd.site',
  `project_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 3,
  `expedition_id` varchar(30) NOT NULL COMMENT 'flight_num, cruise_num…	',
  `datetime` datetime NOT NULL COMMENT 'UTC start of averaging window',
  `lat` decimal(10,4) NOT NULL COMMENT 'deg',
  `lon` decimal(10,4) NOT NULL COMMENT 'deg',
  `alt` decimal(8,4) NOT NULL COMMENT 'meters',
  `elev` decimal(10,4) DEFAULT -999.9900,
  `vehicle_num` int(11) NOT NULL COMMENT 'fk to vehicle',
  `profile_num` int(11) DEFAULT NULL COMMENT 'Unique profile id',
  `intake_id` varchar(45) DEFAULT '0',
  `campaign_num` int(11) DEFAULT NULL COMMENT 'fk to obspack.campaign.',
  `elev_source` varchar(45) DEFAULT NULL COMMENT 'Where elevation came from; db, gps…. This could be a look up table too',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`datetime`,`lat`,`lon`,`alt`,`vehicle_num`,`intake_id`),
  KEY `p` (`profile_num`),
  KEY `sd` (`site_num`,`datetime`),
  KEY `sfn` (`site_num`,`expedition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=273427 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`mobile_insitu_event_AFTER_DELETE` AFTER DELETE ON `mobile_insitu_event` FOR EACH ROW
BEGIN
	delete from ccgg.mobile_insitu_data where event_num = old.num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `mobile_insitu_event_view`
--

DROP TABLE IF EXISTS `mobile_insitu_event_view`;
/*!50001 DROP VIEW IF EXISTS `mobile_insitu_event_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `mobile_insitu_event_view` (
  `num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `datetime` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `elev_source` tinyint NOT NULL,
  `expedition_id` tinyint NOT NULL,
  `intake_id` tinyint NOT NULL,
  `profile_num` tinyint NOT NULL,
  `vehicle_num` tinyint NOT NULL,
  `vehicle` tinyint NOT NULL,
  `vehicle_abbr` tinyint NOT NULL,
  `airplane` tinyint NOT NULL,
  `boat` tinyint NOT NULL,
  `automobile` tinyint NOT NULL,
  `campaign_abbr` tinyint NOT NULL,
  `campaign_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mobile_insitu_instruments`
--

DROP TABLE IF EXISTS `mobile_insitu_instruments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mobile_insitu_instruments` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `abbr` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=200006 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='We may want to merge with ccgg.inst at some point, but keeping separate for now to avoid cluttering table. ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) DEFAULT NULL,
  `subject` varchar(100) NOT NULL DEFAULT '',
  `details` varchar(2048) DEFAULT NULL,
  `archive_after_date` date DEFAULT NULL,
  `creation_datetime` datetime NOT NULL,
  `mod_datetime` datetime NOT NULL,
  `author` varchar(255) DEFAULT NULL,
  `status_num` int(11) DEFAULT 0 COMMENT '0=>na,1=>''On-going'',2=>''Complete''',
  PRIMARY KEY (`num`),
  KEY `site` (`site_num`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`network_status_BEFORE_INSERT` BEFORE INSERT ON `news` FOR EACH ROW
BEGIN
	if(new.creation_datetime='0000-00-00') then 	
        set new.creation_datetime=now();
        set new.mod_datetime=now();        
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
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `ccgg`.`network_status_BEFORE_UPDATE` BEFORE UPDATE ON `news` FOR EACH ROW
BEGIN
        set new.mod_datetime=now();        
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `observatory_tanks`
--

DROP TABLE IF EXISTS `observatory_tanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `observatory_tanks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(5) NOT NULL,
  `serial_number` varchar(12) NOT NULL,
  `fill_code` varchar(2) NOT NULL,
  `usage_type` varchar(5) NOT NULL,
  `usage_id` varchar(5) NOT NULL,
  `status` enum('New','Empty','Offline','Online') NOT NULL,
  `co2` float NOT NULL DEFAULT 0,
  `ch4` float NOT NULL DEFAULT 0,
  `co` float NOT NULL DEFAULT 0,
  `n2o` float NOT NULL DEFAULT 0,
  `online_date` date DEFAULT NULL,
  `offline_date` date DEFAULT NULL,
  `ship_to_date` date DEFAULT NULL,
  `ship_from_date` date DEFAULT NULL,
  `arrival_boulder_date` date DEFAULT NULL,
  `pre_use_cals` int(11) NOT NULL DEFAULT 0,
  `post_use_cals` int(11) NOT NULL DEFAULT 0,
  `onsite` tinyint(1) NOT NULL DEFAULT 0,
  `comment` tinytext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `optimal_sample_conditions`
--

DROP TABLE IF EXISTS `optimal_sample_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `optimal_sample_conditions` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL,
  `strategy_num` int(11) NOT NULL,
  `sample_from_time` time NOT NULL DEFAULT '-99:59:59' COMMENT 'LST',
  `sample_to_time` time NOT NULL DEFAULT '-99:59:59' COMMENT 'LST',
  `min_wind_speed` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `wind_from_deg` int(11) NOT NULL DEFAULT -999,
  `wind_dir_margin_deg` int(11) NOT NULL DEFAULT 0,
  `use_to_flag_non_background` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `i` (`site_num`,`project_num`,`strategy_num`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parameterinfo`
--

DROP TABLE IF EXISTS `parameterinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameterinfo` (
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `extension` varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY (`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_comment_type`
--

DROP TABLE IF EXISTS `pfp_comment_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_comment_type` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  KEY `num` (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_comp`
--

DROP TABLE IF EXISTS `pfp_comp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_comp` (
  `num` smallint(5) NOT NULL AUTO_INCREMENT,
  `pfp_unit_type_num` smallint(5) NOT NULL DEFAULT 0,
  `type` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  `version` varchar(80) NOT NULL DEFAULT '',
  `active_status_num` tinyint(3) NOT NULL DEFAULT 1,
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=1038 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_history`
--

DROP TABLE IF EXISTS `pfp_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_history` (
  `unit_id` varchar(20) NOT NULL DEFAULT '',
  `comp_num` smallint(5) NOT NULL DEFAULT 0,
  `current_status_num` tinyint(3) NOT NULL DEFAULT 0,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `notes` text NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_inv`
--

DROP TABLE IF EXISTS `pfp_inv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_inv` (
  `id` varchar(20) NOT NULL DEFAULT '',
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  `sample_status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `path` varchar(80) NOT NULL DEFAULT '',
  `nflasks` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `plan` varchar(20) NOT NULL DEFAULT 'default',
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `i1` (`id`),
  KEY `i2` (`site_num`,`id`),
  KEY `i3` (`sample_status_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_log`
--

DROP TABLE IF EXISTS `pfp_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_log` (
  `unit_id` varchar(20) NOT NULL DEFAULT '',
  `flight_date` date NOT NULL DEFAULT '0000-00-00',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `user` varchar(60) NOT NULL DEFAULT '',
  `site_num` smallint(5) NOT NULL DEFAULT 0,
  `pfp_comment_type_num` tinyint(3) NOT NULL DEFAULT 0,
  `entry` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_shipping`
--

DROP TABLE IF EXISTS `pfp_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_shipping` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `id` varchar(20) NOT NULL DEFAULT '',
  `date_out` date NOT NULL DEFAULT '0000-00-00',
  `date_in` date NOT NULL DEFAULT '0000-00-00',
  KEY `i1` (`site_num`),
  KEY `i2` (`site_num`,`date_out`,`date_in`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_unit`
--

DROP TABLE IF EXISTS `pfp_unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_unit` (
  `id` varchar(20) NOT NULL DEFAULT '',
  `pfp_unit_type_num` smallint(5) NOT NULL DEFAULT 0,
  `version` varchar(80) NOT NULL DEFAULT '',
  `batch` varchar(20) NOT NULL DEFAULT '',
  `active_status_num` tinyint(3) NOT NULL DEFAULT 1,
  `comments` text NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfp_unit_type`
--

DROP TABLE IF EXISTS `pfp_unit_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pfp_unit_type` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `abbr` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  KEY `num` (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `abbr` varchar(20) DEFAULT NULL,
  `description` text NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_contact`
--

DROP TABLE IF EXISTS `project_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_contact` (
  `site_num` smallint(5) unsigned NOT NULL,
  `project_num` tinyint(3) unsigned NOT NULL,
  `strategy_num` tinyint(3) unsigned NOT NULL,
  `program_num` tinyint(3) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `contact_num` smallint(5) NOT NULL,
  PRIMARY KEY (`site_num`,`project_num`,`strategy_num`,`program_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `releaseable_flask_data_view`
--

DROP TABLE IF EXISTS `releaseable_flask_data_view`;
/*!50001 DROP VIEW IF EXISTS `releaseable_flask_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `releaseable_flask_data_view` (
  `prelim` tinyint NOT NULL,
  `excluded` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `ev_date` tinyint NOT NULL,
  `ev_time` tinyint NOT NULL,
  `ev_dd` tinyint NOT NULL,
  `ev_datetime` tinyint NOT NULL,
  `a_date` tinyint NOT NULL,
  `a_time` tinyint NOT NULL,
  `a_dd` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `method` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sample_status`
--

DROP TABLE IF EXISTS `sample_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_status` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sbt_ch4_insitu`
--

DROP TABLE IF EXISTS `sbt_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sbt_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sbt_co2_insitu`
--

DROP TABLE IF EXISTS `sbt_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sbt_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sbt_co_insitu`
--

DROP TABLE IF EXISTS `sbt_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sbt_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_ch4_hour`
--

DROP TABLE IF EXISTS `sct_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_ch4_insitu`
--

DROP TABLE IF EXISTS `sct_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_co2_hour`
--

DROP TABLE IF EXISTS `sct_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_co2_insitu`
--

DROP TABLE IF EXISTS `sct_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_co_hour`
--

DROP TABLE IF EXISTS `sct_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sct_co_insitu`
--

DROP TABLE IF EXISTS `sct_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `secondaries`
--

DROP TABLE IF EXISTS `secondaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `secondaries` (
  `serial_number` varchar(11) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `time` time DEFAULT '00:00:00',
  `species` varchar(20) DEFAULT NULL,
  `inst` char(5) DEFAULT NULL,
  KEY `pk` (`serial_number`,`date`,`time`,`species`,`inst`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_coop`
--

DROP TABLE IF EXISTS `site_coop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_coop` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(256) NOT NULL DEFAULT '',
  `abbr` varchar(20) NOT NULL DEFAULT '',
  `url` varchar(150) NOT NULL DEFAULT '',
  `logo` varchar(150) NOT NULL DEFAULT '',
  `contact` varchar(150) NOT NULL DEFAULT '',
  `address` blob DEFAULT '',
  `tel` varchar(50) NOT NULL DEFAULT '',
  `fax` varchar(30) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `comment` blob NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_coop_archive`
--

DROP TABLE IF EXISTS `site_coop_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_coop_archive` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(256) NOT NULL DEFAULT '',
  `abbr` varchar(20) NOT NULL DEFAULT '',
  `url` varchar(150) NOT NULL DEFAULT '',
  `logo` varchar(150) NOT NULL DEFAULT '',
  `contact` varchar(150) NOT NULL DEFAULT '',
  `address` blob NOT NULL DEFAULT '',
  `tel` varchar(50) NOT NULL DEFAULT '',
  `fax` varchar(30) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `comment` blob NOT NULL DEFAULT '',
  `modification_datetime` datetime NOT NULL,
  PRIMARY KEY (`num`),
  KEY `i2` (`site_num`,`project_num`,`strategy_num`)
) ENGINE=MyISAM AUTO_INCREMENT=98 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_desc`
--

DROP TABLE IF EXISTS `site_desc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_desc` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `default_project` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,1) DEFAULT -9999.9,
  `method` char(2) NOT NULL DEFAULT 'D',
  `image` varchar(128) NOT NULL DEFAULT '',
  `comments` text NOT NULL DEFAULT ' ',
  `include_temp_rh` tinyint(3) NOT NULL DEFAULT 0,
  `target_num_checked_out` int(11) DEFAULT 0 COMMENT 'How many pfp or flasks should be checked out to site prj strat.  used for logistics',
  KEY `i` (`site_num`,`project_num`,`strategy_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_shipping`
--

DROP TABLE IF EXISTS `site_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_shipping` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `send_address` blob DEFAULT NULL,
  `send_carrier` blob DEFAULT NULL,
  `send_doc` blob DEFAULT NULL,
  `send_comments` blob DEFAULT NULL,
  `return_address` blob DEFAULT NULL,
  `return_carrier` blob DEFAULT NULL,
  `return_doc` blob DEFAULT NULL,
  `return_comments` blob DEFAULT NULL,
  `samplesheet` varchar(128) NOT NULL DEFAULT '',
  `meas_path` varchar(80) DEFAULT NULL,
  `meas_comments` blob NOT NULL DEFAULT '',
  `flask_type` varchar(80) DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `tel` varchar(50) DEFAULT NULL,
  `fax` varchar(30) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `mail_address` blob DEFAULT NULL,
  `name2` varchar(150) DEFAULT NULL,
  `tel2` varchar(50) DEFAULT NULL,
  `fax2` varchar(30) DEFAULT NULL,
  `email2` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_shipping_archive`
--

DROP TABLE IF EXISTS `site_shipping_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_shipping_archive` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `send_address` blob DEFAULT NULL,
  `send_carrier` blob DEFAULT NULL,
  `send_doc` blob DEFAULT NULL,
  `send_comments` blob DEFAULT NULL,
  `return_address` blob DEFAULT NULL,
  `return_carrier` blob DEFAULT NULL,
  `return_doc` blob DEFAULT NULL,
  `return_comments` blob DEFAULT NULL,
  `samplesheet` varchar(128) NOT NULL DEFAULT '',
  `meas_path` varchar(80) DEFAULT NULL,
  `meas_comments` blob NOT NULL,
  `flask_type` varchar(80) DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `tel` varchar(50) DEFAULT NULL,
  `fax` varchar(30) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `mail_address` blob DEFAULT NULL,
  `name2` varchar(150) DEFAULT NULL,
  `tel2` varchar(50) DEFAULT NULL,
  `fax2` varchar(30) DEFAULT NULL,
  `email2` varchar(100) DEFAULT NULL,
  `modification_datetime` datetime NOT NULL,
  PRIMARY KEY (`num`),
  KEY `i2` (`site_num`,`project_num`,`strategy_num`)
) ENGINE=MyISAM AUTO_INCREMENT=917 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_spon`
--

DROP TABLE IF EXISTS `site_spon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_spon` (
  `site_num` smallint(5) unsigned DEFAULT NULL,
  `project_num` tinyint(3) unsigned DEFAULT NULL,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(150) DEFAULT NULL,
  `abbr` varchar(20) DEFAULT NULL,
  `url` varchar(150) DEFAULT NULL,
  `logo` varchar(150) DEFAULT NULL,
  `contact` varchar(150) DEFAULT NULL,
  `address` blob DEFAULT NULL,
  `tel` varchar(50) DEFAULT NULL,
  `fax` varchar(30) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_subsites`
--

DROP TABLE IF EXISTS `site_subsites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_subsites` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `parent_site_num` int(11) NOT NULL,
  `description` varchar(45) NOT NULL,
  `lat` decimal(8,4) DEFAULT NULL,
  `lon` decimal(8,4) DEFAULT NULL,
  `alt` decimal(8,2) DEFAULT NULL,
  `elev` decimal(8,2) DEFAULT NULL,
  `me` varchar(3) DEFAULT NULL,
  `comment` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`parent_site_num`,`description`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_co2_day`
--

DROP TABLE IF EXISTS `smo_co2_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_co2_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_co2_hour`
--

DROP TABLE IF EXISTS `smo_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_co2_insitu`
--

DROP TABLE IF EXISTS `smo_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_co2_month`
--

DROP TABLE IF EXISTS `smo_co2_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_co2_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_co2_target`
--

DROP TABLE IF EXISTS `smo_co2_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_co2_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snp_co2_hour`
--

DROP TABLE IF EXISTS `snp_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snp_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snp_co2_insitu`
--

DROP TABLE IF EXISTS `snp_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snp_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snp_co_hour`
--

DROP TABLE IF EXISTS `snp_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snp_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snp_co_insitu`
--

DROP TABLE IF EXISTS `snp_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snp_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_co2_day`
--

DROP TABLE IF EXISTS `spo_co2_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_co2_day` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_co2_hour`
--

DROP TABLE IF EXISTS `spo_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_co2_insitu`
--

DROP TABLE IF EXISTS `spo_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(4) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  `inlet` tinyint(2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_co2_month`
--

DROP TABLE IF EXISTS `spo_co2_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_co2_month` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `flag` varchar(4) DEFAULT '*..',
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_co2_target`
--

DROP TABLE IF EXISTS `spo_co2_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_co2_target` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `type` varchar(10) NOT NULL DEFAULT '0',
  `value` float(12,4) NOT NULL DEFAULT -999.9900,
  `std_dev` float(8,2) NOT NULL DEFAULT -999.99,
  `unc` float(8,2) NOT NULL DEFAULT -999.99,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(6) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`type`,`inst`),
  KEY `i2` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `status` (
  `num` tinyint(3) unsigned DEFAULT NULL,
  `name` varchar(80) DEFAULT NULL,
  `comments` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `strategy`
--

DROP TABLE IF EXISTS `strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `strategy` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `abbr` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system`
--

DROP TABLE IF EXISTS `system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `abbr` varchar(25) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  `route` varchar(25) NOT NULL DEFAULT '',
  `comments` text NOT NULL DEFAULT '',
  `program_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `t_event_nums`
--

DROP TABLE IF EXISTS `t_event_nums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t_event_nums` (
  `num` mediumint(8) unsigned NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_conversion_history`
--

DROP TABLE IF EXISTS `tag_conversion_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_conversion_history` (
  `data_num` int(11) NOT NULL,
  `old_flag` char(3) NOT NULL,
  `datetime` timestamp NULL DEFAULT current_timestamp(),
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`data_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_data_sources`
--

DROP TABLE IF EXISTS `tag_data_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_data_sources` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='sources for callers creating tag ranges.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_dictionary`
--

DROP TABLE IF EXISTS `tag_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_dictionary` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `deprecated` tinyint(4) DEFAULT 0,
  `flag` varchar(3) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `name` varchar(256) NOT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `reject` tinyint(4) DEFAULT 0,
  `reject_min_severity` int(11) DEFAULT NULL COMMENT 'value >= this is cause to reject',
  `selection` tinyint(4) DEFAULT 0,
  `information` tinyint(4) DEFAULT 0,
  `collection_issue` tinyint(4) DEFAULT 0,
  `measurement_issue` tinyint(4) DEFAULT 0,
  `selection_issue` tinyint(4) DEFAULT 0,
  `unknown_issue` tinyint(4) DEFAULT 0,
  `automated` tinyint(4) DEFAULT 0,
  `comment` tinyint(4) DEFAULT 0,
  `min_severity` int(11) DEFAULT 0 COMMENT 'min acceptable value for severity',
  `max_severity` int(11) DEFAULT 0 COMMENT 'max acceptable value for severity, if same as min then no severity can be entered',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `hats_perseus` tinyint(4) DEFAULT 0,
  `hats_ng` tinyint(4) DEFAULT 0,
  `exclusion` tinyint(4) DEFAULT 0 COMMENT 'Data with this tag is not eligible for release',
  `prelim_data` tinyint(4) DEFAULT 0 COMMENT 'Data with this tag is considered preliminary',
  `parent_tag_num` int(11) DEFAULT 0,
  `project_num` int(11) NOT NULL DEFAULT 0,
  `program_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `parameter_num` int(11) NOT NULL DEFAULT 0,
  `inst_num` int(11) NOT NULL DEFAULT 0,
  `hats_interpolation` int(11) DEFAULT 0,
  `pair_diff` int(11) DEFAULT 0,
  `inj_diff` int(11) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=307 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Note; the mysql bit type causes issues with some client libraries (php pdo) so these ''bit'' columns are all tiny int';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_dictionary_after_insert after insert ON ccgg.tag_dictionary FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('deprecated',':',ifnull(NEW.deprecated,'null')), concat('flag',':',ifnull(NEW.flag,'null')), concat('name',':',ifnull(NEW.name,'null')), concat('short_name',':',ifnull(NEW.short_name,'null')), concat('reject',':',ifnull(NEW.reject,'null')), concat('reject_min_severity',':',ifnull(NEW.reject_min_severity,'null')), concat('selection',':',ifnull(NEW.selection,'null')), concat('information',':',ifnull(NEW.information,'null')), concat('collection_issue',':',ifnull(NEW.collection_issue,'null')), concat('measurement_issue',':',ifnull(NEW.measurement_issue,'null')), concat('selection_issue',':',ifnull(NEW.selection_issue,'null')), concat('unknown_issue',':',ifnull(NEW.unknown_issue,'null')), concat('automated',':',ifnull(NEW.automated,'null')), concat('comment',':',ifnull(NEW.comment,'null')), concat('min_severity',':',ifnull(NEW.min_severity,'null')), concat('max_severity',':',ifnull(NEW.max_severity,'null')), concat('last_modified',':',ifnull(NEW.last_modified,'null')), concat('hats_perseus',':',ifnull(NEW.hats_perseus,'null')), concat('hats_ng',':',ifnull(NEW.hats_ng,'null')), concat('exclusion',':',ifnull(NEW.exclusion,'null')), concat('prelim_data',':',ifnull(NEW.prelim_data,'null')), concat('parent_tag_num',':',ifnull(NEW.parent_tag_num,'null')), concat('project_num',':',ifnull(NEW.project_num,'null')), concat('program_num',':',ifnull(NEW.program_num,'null')), concat('strategy_num',':',ifnull(NEW.strategy_num,'null')), concat('parameter_num',':',ifnull(NEW.parameter_num,'null')), concat('inst_num',':',ifnull(NEW.inst_num,'null')), concat('hats_interpolation',':',ifnull(NEW.hats_interpolation,'null'))),'ccgg','tag_dictionary',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_dictionary_after_update after update ON ccgg.tag_dictionary FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.deprecated <> OLD.deprecated, concat('deprecated(Old:',OLD.deprecated,' New:',NEW.deprecated,')'), NULL), IF(NEW.flag <> OLD.flag, concat('flag(Old:',OLD.flag,' New:',NEW.flag,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL), IF(NEW.short_name <> OLD.short_name, concat('short_name(Old:',OLD.short_name,' New:',NEW.short_name,')'), NULL), IF(NEW.reject <> OLD.reject, concat('reject(Old:',OLD.reject,' New:',NEW.reject,')'), NULL), IF(NEW.reject_min_severity <> OLD.reject_min_severity, concat('reject_min_severity(Old:',OLD.reject_min_severity,' New:',NEW.reject_min_severity,')'), NULL), IF(NEW.selection <> OLD.selection, concat('selection(Old:',OLD.selection,' New:',NEW.selection,')'), NULL), IF(NEW.information <> OLD.information, concat('information(Old:',OLD.information,' New:',NEW.information,')'), NULL), IF(NEW.collection_issue <> OLD.collection_issue, concat('collection_issue(Old:',OLD.collection_issue,' New:',NEW.collection_issue,')'), NULL), IF(NEW.measurement_issue <> OLD.measurement_issue, concat('measurement_issue(Old:',OLD.measurement_issue,' New:',NEW.measurement_issue,')'), NULL), IF(NEW.selection_issue <> OLD.selection_issue, concat('selection_issue(Old:',OLD.selection_issue,' New:',NEW.selection_issue,')'), NULL), IF(NEW.unknown_issue <> OLD.unknown_issue, concat('unknown_issue(Old:',OLD.unknown_issue,' New:',NEW.unknown_issue,')'), NULL), IF(NEW.automated <> OLD.automated, concat('automated(Old:',OLD.automated,' New:',NEW.automated,')'), NULL), IF(NEW.comment <> OLD.comment, concat('comment(Old:',OLD.comment,' New:',NEW.comment,')'), NULL), IF(NEW.min_severity <> OLD.min_severity, concat('min_severity(Old:',OLD.min_severity,' New:',NEW.min_severity,')'), NULL), IF(NEW.max_severity <> OLD.max_severity, concat('max_severity(Old:',OLD.max_severity,' New:',NEW.max_severity,')'), NULL), IF(NEW.last_modified <> OLD.last_modified, concat('last_modified(Old:',OLD.last_modified,' New:',NEW.last_modified,')'), NULL), IF(NEW.hats_perseus <> OLD.hats_perseus, concat('hats_perseus(Old:',OLD.hats_perseus,' New:',NEW.hats_perseus,')'), NULL), IF(NEW.hats_ng <> OLD.hats_ng, concat('hats_ng(Old:',OLD.hats_ng,' New:',NEW.hats_ng,')'), NULL), IF(NEW.exclusion <> OLD.exclusion, concat('exclusion(Old:',OLD.exclusion,' New:',NEW.exclusion,')'), NULL), IF(NEW.prelim_data <> OLD.prelim_data, concat('prelim_data(Old:',OLD.prelim_data,' New:',NEW.prelim_data,')'), NULL), IF(NEW.parent_tag_num <> OLD.parent_tag_num, concat('parent_tag_num(Old:',OLD.parent_tag_num,' New:',NEW.parent_tag_num,')'), NULL), IF(NEW.project_num <> OLD.project_num, concat('project_num(Old:',OLD.project_num,' New:',NEW.project_num,')'), NULL), IF(NEW.program_num <> OLD.program_num, concat('program_num(Old:',OLD.program_num,' New:',NEW.program_num,')'), NULL), IF(NEW.strategy_num <> OLD.strategy_num, concat('strategy_num(Old:',OLD.strategy_num,' New:',NEW.strategy_num,')'), NULL), IF(NEW.parameter_num <> OLD.parameter_num, concat('parameter_num(Old:',OLD.parameter_num,' New:',NEW.parameter_num,')'), NULL), IF(NEW.inst_num <> OLD.inst_num, concat('inst_num(Old:',OLD.inst_num,' New:',NEW.inst_num,')'), NULL), IF(NEW.hats_interpolation <> OLD.hats_interpolation, concat('hats_interpolation(Old:',OLD.hats_interpolation,' New:',NEW.hats_interpolation,')'), NULL)),'ccgg', 'tag_dictionary',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_dictionary_before_delete before delete ON ccgg.tag_dictionary FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('deprecated',':',ifnull(OLD.deprecated,'null')), concat('flag',':',ifnull(OLD.flag,'null')), concat('name',':',ifnull(OLD.name,'null')), concat('short_name',':',ifnull(OLD.short_name,'null')), concat('reject',':',ifnull(OLD.reject,'null')), concat('reject_min_severity',':',ifnull(OLD.reject_min_severity,'null')), concat('selection',':',ifnull(OLD.selection,'null')), concat('information',':',ifnull(OLD.information,'null')), concat('collection_issue',':',ifnull(OLD.collection_issue,'null')), concat('measurement_issue',':',ifnull(OLD.measurement_issue,'null')), concat('selection_issue',':',ifnull(OLD.selection_issue,'null')), concat('unknown_issue',':',ifnull(OLD.unknown_issue,'null')), concat('automated',':',ifnull(OLD.automated,'null')), concat('comment',':',ifnull(OLD.comment,'null')), concat('min_severity',':',ifnull(OLD.min_severity,'null')), concat('max_severity',':',ifnull(OLD.max_severity,'null')), concat('last_modified',':',ifnull(OLD.last_modified,'null')), concat('hats_perseus',':',ifnull(OLD.hats_perseus,'null')), concat('hats_ng',':',ifnull(OLD.hats_ng,'null')), concat('exclusion',':',ifnull(OLD.exclusion,'null')), concat('prelim_data',':',ifnull(OLD.prelim_data,'null')), concat('parent_tag_num',':',ifnull(OLD.parent_tag_num,'null')), concat('project_num',':',ifnull(OLD.project_num,'null')), concat('program_num',':',ifnull(OLD.program_num,'null')), concat('strategy_num',':',ifnull(OLD.strategy_num,'null')), concat('parameter_num',':',ifnull(OLD.parameter_num,'null')), concat('inst_num',':',ifnull(OLD.inst_num,'null')), concat('hats_interpolation',':',ifnull(OLD.hats_interpolation,'null'))),'ccgg', 'tag_dictionary',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tag_dictionary_history`
--

DROP TABLE IF EXISTS `tag_dictionary_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_dictionary_history` (
  `num` int(11) NOT NULL,
  `flag` varchar(1) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `name` varchar(256) NOT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `reject` bit(1) DEFAULT b'0',
  `reject_min_severity` int(11) DEFAULT NULL COMMENT 'value >= this is cause to reject',
  `selection` bit(1) DEFAULT b'0',
  `information` bit(1) DEFAULT b'0',
  `collection_issue` bit(1) DEFAULT b'0',
  `measurement_issue` bit(1) DEFAULT b'0',
  `selection_issue` bit(1) DEFAULT b'0',
  `unknown_issue` bit(1) DEFAULT b'0',
  `automated` bit(1) DEFAULT b'0',
  `min_severity` int(11) DEFAULT 0 COMMENT 'min acceptable value for severity',
  `max_severity` int(11) DEFAULT 0 COMMENT 'max acceptable value for severity, if same as min then no severity can be entered',
  `comment` bit(1) DEFAULT b'0',
  `history_user` varchar(50) NOT NULL,
  `history_action` char(6) NOT NULL,
  `history_action_datetime` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `num` (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_dictionary_new`
--

DROP TABLE IF EXISTS `tag_dictionary_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_dictionary_new` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `deprecated` tinyint(4) DEFAULT 0,
  `new_tag_num` int(11) DEFAULT 0,
  `flag` varchar(1) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `name` varchar(256) NOT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `reject` tinyint(4) DEFAULT 0,
  `reject_min_severity` int(11) DEFAULT NULL COMMENT 'value >= this is cause to reject',
  `selection` tinyint(4) DEFAULT 0,
  `information` tinyint(4) DEFAULT 0,
  `collection_issue` tinyint(4) DEFAULT 0,
  `measurement_issue` tinyint(4) DEFAULT 0,
  `selection_issue` tinyint(4) DEFAULT 0,
  `unknown_issue` tinyint(4) DEFAULT 0,
  `automated` tinyint(4) DEFAULT 0,
  `comment` tinyint(4) DEFAULT 0,
  `min_severity` int(11) DEFAULT 0 COMMENT 'min acceptable value for severity',
  `max_severity` int(11) DEFAULT 0 COMMENT 'max acceptable value for severity, if same as min then no severity can be entered',
  `last_modified` timestamp NOT NULL DEFAULT current_timestamp(),
  `hats_internal` tinyint(4) DEFAULT 0,
  `hats_system` tinyint(4) DEFAULT 0,
  `exclusion` tinyint(4) DEFAULT 0 COMMENT 'Data with this tag is not eligible for release',
  `prelim_data` tinyint(4) DEFAULT 0 COMMENT 'Data with this tag is considered preliminary',
  `parent_tag_num` int(11) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=214 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Note; the mysql bit type causes issues with some client libraries (php pdo) so these ''bit'' columns are all tiny int';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_entry_errors`
--

DROP TABLE IF EXISTS `tag_entry_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_entry_errors` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `data_num` int(11) NOT NULL,
  `flag` char(3) DEFAULT NULL,
  `datetime` timestamp NULL DEFAULT current_timestamp(),
  `user` varchar(200) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3764314 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_filters__deprecated`
--

DROP TABLE IF EXISTS `tag_filters__deprecated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_filters__deprecated` (
  `tag_num` int(11) NOT NULL,
  `project_num` int(11) NOT NULL DEFAULT 0,
  `program_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `parameter_num` int(11) NOT NULL DEFAULT 0,
  UNIQUE KEY `filters` (`tag_num`,`project_num`,`program_num`,`strategy_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='The presence of a matching row means that the tag_num should be included.  0 is wild card.  So to get all tags for program 12: select * from tag_dictionary d left join tag_filters f on d.num=f.tag_num where f.tag_num is null or (f.program_num in (0,12)) ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tag_list`
--

DROP TABLE IF EXISTS `tag_list`;
/*!50001 DROP VIEW IF EXISTS `tag_list`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tag_list` (
  `Tag_number` tinyint NOT NULL,
  `Name` tinyint NOT NULL,
  `Tag_Type` tinyint NOT NULL,
  `Severity` tinyint NOT NULL,
  `Old_style_flag` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tag_range_info_cache`
--

DROP TABLE IF EXISTS `tag_range_info_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_range_info_cache` (
  `range_num` int(11) NOT NULL,
  `ev_startDate` datetime DEFAULT NULL,
  `ev_endDate` datetime DEFAULT NULL,
  `d_startDate` datetime DEFAULT NULL,
  `d_endDate` datetime DEFAULT NULL,
  `rowcount` int(11) DEFAULT NULL,
  `is_data_range` tinyint(4) DEFAULT NULL,
  `is_event_range` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`range_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='caches information about the tag ranges for performance.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `tag_range_info_view`
--

DROP TABLE IF EXISTS `tag_range_info_view`;
/*!50001 DROP VIEW IF EXISTS `tag_range_info_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tag_range_info_view` (
  `range_num` tinyint NOT NULL,
  `tag_num` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `tag_description` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `json_selection_criteria` tinyint NOT NULL,
  `data_source` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `internal_flag` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `group_name` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `sort_order2` tinyint NOT NULL,
  `automated` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tag_range_openended_criteria`
--

DROP TABLE IF EXISTS `tag_range_openended_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_range_openended_criteria` (
  `range_num` int(11) NOT NULL,
  `last_processed_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'last datetime this row was used to add new data to a range.  the special range_num 0 entry is for the whole table.',
  `tot_rows_processed` int(11) NOT NULL DEFAULT 0 COMMENT 'Total number of rows added to range by the openend logic.  Just for metrics.',
  `site_num` int(11) NOT NULL DEFAULT 0,
  `project_num` int(11) NOT NULL DEFAULT 0,
  `strategy_num` int(11) NOT NULL DEFAULT 0,
  `program_num` int(11) NOT NULL DEFAULT 0,
  `parameter_num` int(11) NOT NULL DEFAULT 0,
  `ev_s_datetime` datetime NOT NULL,
  `ev_e_datetime` datetime NOT NULL,
  `method` varchar(3) NOT NULL DEFAULT '',
  PRIMARY KEY (`range_num`,`parameter_num`),
  KEY `site_date_param` (`site_num`,`ev_s_datetime`,`ev_e_datetime`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='New flask_event/data rows matching criteria in this table will automatically be added to the tag_range by a cron job running periodially.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_ranges`
--

DROP TABLE IF EXISTS `tag_ranges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_ranges` (
  `num` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tag_num` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `prelim` tinyint(4) DEFAULT 0,
  `json_selection_criteria` text DEFAULT NULL COMMENT 'This field is a json hash array of the selection criteria used to populate the range.  flask_event fields are prepended with ev_ and flask_data fields with d_.  Currently there are no computed values, but that may change in the future.  See php datatagger documentation for details.',
  `data_source` tinyint(4) DEFAULT 0 COMMENT 'This field signifies what/where the row was created.  See stored procedure tag_createTagRange for current list of values.  It exists to make it easier to delete groups of tag ranges, particularly during development but also maybe in automated statistics scripts	',
  `description` varchar(255) DEFAULT NULL,
  `modified_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`num`),
  KEY `tag_num` (`tag_num`)
) ENGINE=InnoDB AUTO_INCREMENT=539224 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_ranges_after_insert after insert ON ccgg.tag_ranges FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('tag_num',':',ifnull(NEW.tag_num,'null')), concat('comment',':',ifnull(NEW.comment,'null')), concat('prelim',':',ifnull(NEW.prelim,'null')), concat('json_selection_criteria',':',ifnull(NEW.json_selection_criteria,'null')), concat('data_source',':',ifnull(NEW.data_source,'null')), concat('description',':',ifnull(NEW.description,'null')), concat('modified_date',':',ifnull(NEW.modified_date,'null'))),'ccgg','tag_ranges',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_ranges_after_update after update ON ccgg.tag_ranges FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.tag_num <> OLD.tag_num, concat('tag_num(Old:',OLD.tag_num,' New:',NEW.tag_num,')'), NULL), IF(NEW.comment <> OLD.comment, concat('comment(Old:',OLD.comment,' New:',NEW.comment,')'), NULL), IF(NEW.prelim <> OLD.prelim, concat('prelim(Old:',OLD.prelim,' New:',NEW.prelim,')'), NULL), IF(NEW.json_selection_criteria <> OLD.json_selection_criteria, concat('json_selection_criteria(Old:',OLD.json_selection_criteria,' New:',NEW.json_selection_criteria,')'), NULL), IF(NEW.data_source <> OLD.data_source, concat('data_source(Old:',OLD.data_source,' New:',NEW.data_source,')'), NULL), IF(NEW.description <> OLD.description, concat('description(Old:',OLD.description,' New:',NEW.description,')'), NULL), IF(NEW.modified_date <> OLD.modified_date, concat('modified_date(Old:',OLD.modified_date,' New:',NEW.modified_date,')'), NULL)),'ccgg', 'tag_ranges',new.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER ccgg._auditlog_tag_ranges_before_delete before delete ON ccgg.tag_ranges FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('tag_num',':',ifnull(OLD.tag_num,'null')), concat('comment',':',ifnull(OLD.comment,'null')), concat('prelim',':',ifnull(OLD.prelim,'null')), concat('json_selection_criteria',':',ifnull(OLD.json_selection_criteria,'null')), concat('data_source',':',ifnull(OLD.data_source,'null')), concat('description',':',ifnull(OLD.description,'null')), concat('modified_date',':',ifnull(OLD.modified_date,'null'))),'ccgg', 'tag_ranges',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `tag_view`
--

DROP TABLE IF EXISTS `tag_view`;
/*!50001 DROP VIEW IF EXISTS `tag_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tag_view` (
  `tag_num` tinyint NOT NULL,
  `internal_flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `group_name` tinyint NOT NULL,
  `group_name2` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `sort_order2` tinyint NOT NULL,
  `sort_order3` tinyint NOT NULL,
  `sort_order4` tinyint NOT NULL,
  `hats_sort` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `deprecated` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `short_name` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `reject_min_severity` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `unknown_issue` tinyint NOT NULL,
  `automated` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `min_severity` tinyint NOT NULL,
  `max_severity` tinyint NOT NULL,
  `last_modified` tinyint NOT NULL,
  `hats_perseus` tinyint NOT NULL,
  `hats_ng` tinyint NOT NULL,
  `exclusion` tinyint NOT NULL,
  `prelim_data` tinyint NOT NULL,
  `parent_tag_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `hats_interpolation` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tbp_co2_hour`
--

DROP TABLE IF EXISTS `tbp_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbp_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`),
  KEY `hour` (`hour`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbp_co2_insitu`
--

DROP TABLE IF EXISTS `tbp_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbp_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` tinyint(2) NOT NULL DEFAULT 0,
  `min` tinyint(2) NOT NULL DEFAULT 0,
  `sec` tinyint(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` float(8,2) NOT NULL DEFAULT 0.00,
  `value` float(12,3) NOT NULL DEFAULT 0.000,
  `meas_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `random_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `std_dev` float(8,3) NOT NULL DEFAULT 0.000,
  `scale_unc` float(8,3) NOT NULL DEFAULT 0.000,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_fill_codes`
--

DROP TABLE IF EXISTS `test_fill_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test_fill_codes` (
  `cal_idx` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `code` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '',
  KEY `i` (`cal_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tower_contacts`
--

DROP TABLE IF EXISTS `tower_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tower_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_code` varchar(6) NOT NULL DEFAULT ' ',
  `contact1_name` varchar(50) NOT NULL DEFAULT ' ',
  `contact1_email` varchar(50) NOT NULL DEFAULT ' ',
  `Contact1_phone` varchar(20) NOT NULL DEFAULT ' ',
  `contact2_name` varchar(50) NOT NULL DEFAULT ' ',
  `contact2_email` varchar(50) NOT NULL DEFAULT ' ',
  `contact2_phone` varchar(20) NOT NULL DEFAULT ' ',
  `ship_address1` text NOT NULL DEFAULT ' ',
  `ship_address2` text NOT NULL DEFAULT ' ',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tower_tanks`
--

DROP TABLE IF EXISTS `tower_tanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tower_tanks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_code` varchar(6) NOT NULL,
  `tank_id` varchar(8) NOT NULL,
  `tank_descrip` varchar(20) NOT NULL,
  `inuse_tank_sn` varchar(15) NOT NULL,
  `replace_tank_sn` varchar(15) NOT NULL,
  `target_arrival_date` date DEFAULT NULL,
  `tank_use_rate` float NOT NULL DEFAULT 0,
  `target_swap_date` date DEFAULT NULL,
  `days_till_swap` float NOT NULL DEFAULT 0,
  `shipped_date` date DEFAULT NULL,
  `swapped_date` date DEFAULT NULL,
  `inuse_cal_values` varchar(20) NOT NULL,
  `replace_cal_values` varchar(20) NOT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle`
--

DROP TABLE IF EXISTS `vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `abbr` varchar(255) NOT NULL,
  `vehicle_type_num` int(11) NOT NULL,
  `detail` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_types`
--

DROP TABLE IF EXISTS `vehicle_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `abbr` varchar(45) NOT NULL,
  `boat` int(1) DEFAULT 0,
  `airplane` int(1) DEFAULT 0,
  `automobile` int(1) DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `i` (`abbr`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_ch4_hour`
--

DROP TABLE IF EXISTS `wbi_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_ch4_insitu`
--

DROP TABLE IF EXISTS `wbi_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_co2_hour`
--

DROP TABLE IF EXISTS `wbi_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_co2_insitu`
--

DROP TABLE IF EXISTS `wbi_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_co_hour`
--

DROP TABLE IF EXISTS `wbi_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_co_insitu`
--

DROP TABLE IF EXISTS `wbi_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_archive_dataOLD`
--

DROP TABLE IF EXISTS `web_archive_dataOLD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_archive_dataOLD` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(1000) DEFAULT NULL,
  `fairuse` text DEFAULT NULL,
  `citation` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `dir_path` varchar(255) DEFAULT NULL,
  `provider_emails` text DEFAULT NULL,
  `content_html` mediumtext DEFAULT NULL,
  `password` varchar(45) DEFAULT NULL,
  `doi_url` varchar(255) DEFAULT NULL COMMENT 'For reference, this is the external DOI url ',
  `download_gatekeeper` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='see gmd/ccgg/arc/index.php for details on the use of this';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_ch4_hour`
--

DROP TABLE IF EXISTS `wgc_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_ch4_insitu`
--

DROP TABLE IF EXISTS `wgc_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_co2_hour`
--

DROP TABLE IF EXISTS `wgc_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_co2_insitu`
--

DROP TABLE IF EXISTS `wgc_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_co_hour`
--

DROP TABLE IF EXISTS `wgc_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` varchar(6) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_co_insitu`
--

DROP TABLE IF EXISTS `wgc_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(4) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_ch4_hour`
--

DROP TABLE IF EXISTS `wkt_ch4_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_ch4_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_ch4_insitu`
--

DROP TABLE IF EXISTS `wkt_ch4_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_ch4_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(8) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_co2_hour`
--

DROP TABLE IF EXISTS `wkt_co2_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_co2_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_co2_insitu`
--

DROP TABLE IF EXISTS `wkt_co2_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_co2_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(8) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  `x2019` tinyint(1) DEFAULT 1 COMMENT '0 means value was converted from x2007 using linear conversion value=(value*1.00079-0.142), 1 means value was reprocessed using x2019 scale',
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_co_hour`
--

DROP TABLE IF EXISTS `wkt_co_hour`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_co_hour` (
  `dd` double(14,9) DEFAULT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` tinyint(4) NOT NULL DEFAULT 0,
  `intake_ht` decimal(8,2) NOT NULL,
  `value` decimal(12,3) DEFAULT -999.990,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `std_dev` decimal(12,3) DEFAULT -99.990,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `flag` varchar(4) DEFAULT '*..',
  `inst` char(8) NOT NULL,
  KEY `idx1` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_co_insitu`
--

DROP TABLE IF EXISTS `wkt_co_insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_co_insitu` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `min` int(2) NOT NULL DEFAULT 0,
  `sec` int(2) NOT NULL DEFAULT 0,
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,3) NOT NULL DEFAULT -999.999,
  `meas_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `random_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `scale_unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` char(8) NOT NULL,
  PRIMARY KEY (`date`,`hr`,`min`,`sec`,`intake_ht`,`inst`),
  KEY `i2` (`intake_ht`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'ccgg'
--
/*!50003 DROP FUNCTION IF EXISTS `f_adjustedWindDir` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_adjustedWindDir`(u decimal(12,4), v decimal(12,4), northAdj decimal(12,4) ) RETURNS decimal(12,4)
    NO SQL
BEGIN
 		return mod(f_windDir(u,v)+northAdj+360,360);
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_date2dec` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_date2dec`(v_date date, v_time time ) RETURNS double
    NO SQL
BEGIN
    declare s1,s2 decimal(39,30) default 0;#Note these require range for # of seconds in year
    declare s3 decimal(35,30) default 0;#Use higher precison decimal to attempt to preserve accuracy out to double default precision
	declare boy datetime default timestamp(makedate(year(v_date),1)); #beginning of year
	declare nyr datetime default timestampadd(year,1,boy);#next year
	declare dt datetime default timestamp(v_date,v_time);#timestamp of passed date time
    set s1=timestampdiff(second,boy,dt);
    set s2=timestampdiff(second,boy,nyr);
    set s3=s1/s2;
    return year(v_date)+s3;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_dec2dt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_dec2dt`(dd double) RETURNS datetime
    NO SQL
begin
		declare yr int default truncate(dd,0);
		declare boy datetime default timestamp(makedate(yr,1)); #beginning of year
		declare nyr datetime default timestampadd(year,1,boy);#next year
        declare s double default dd-yr;
        return date_add(makedate(yr,1),interval s*(timestampdiff(second,boy,nyr)+1) second);
	end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_dt2dec` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_dt2dec`(v_datetime datetime) RETURNS double
    NO SQL
begin
		return f_date2dec(date(v_datetime),time(v_datetime));
	end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_external_flag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_external_flag`(v_data_num int) RETURNS varchar(3) CHARSET latin1 COLLATE latin1_swedish_ci
begin

#This function returns a standardized external flag generated from both event and data tags.

#Note; there is a bug in this version of mysql (5.5) which causes a spurious warning to be
#generated when using select ... into var and no rows are returned.  Apparently this can fill
#up logs when happens often.  We re-factored the originial code to (hopefully) avoid this.
#I'm not 100% sure this avoids it, because I couldn't quite figure out the conditions to get
#it to happen (but it did several times). jwm 10-15

#Do not use for data modification.  Use stored procedure tag_updateFlagsFromTags for that!
#This is probably really slow.  If you want to use for large datasets, it would be
#worth rewriting as a set op in a procedure like the update proc

#NOTE changes to the below logic must be kept in sync with tag_updateFalgsFromTags procedure!!!
#See that procedure for more extensive notes.

                        declare flag char(3);
                        declare r,s,i char(1);
						drop temporary table if exists t_dt;
						create temporary table t_dt as
							select data_num, tag_num,
								collection_issue,measurement_issue,selection_issue,
								reject,selection,information,exclusion,prelim_data
							from flask_data_tag_view where data_num=v_data_num
						union
							select d.num as data_num,v.tag_num,
								collection_issue,measurement_issue,selection_issue,
								reject,selection,information,exclusion,prelim_data
							from flask_data d, flask_event_tag_view v
							where d.event_num=v.event_num and d.num=v_data_num;

                        #Rejection
                        SELECT ifnull(
                                (SELECT case    when sum(v.collection_issue)>=1 AND sum(v.measurement_issue)>=1 then 'B'
                                                when sum(v.collection_issue)>=1 then 'C'
                                                when sum(v.measurement_issue)>=1 then 'M'
                                                else 'U'
                                        end
                                FROM t_dt v
                                WHERE v.reject=1
                                GROUP BY v.data_num,v.reject),'.') INTO r;

                        #Selection
                        SELECT ifnull(
                                (SELECT case    when sum(v.selection_issue)>=1 then 'S'
                                                else 'U'
                                        end
                                FROM t_dt v
                                WHERE v.selection=1
                                GROUP BY v.data_num,v.selection),'.') INTO s;


                        #Information
                        SELECT ifnull(
                                (SELECT case    when sum(case when v.tag_num=155 then 1 else 0 end)>=1 then 'i' #special logic for issues to be looked into.  These are not expected to go out to public
												when sum(v.prelim_data)>=1 then 'P'
                                                #when sum(v.exclusion)>=1 then 'E'
												when sum(v.collection_issue)>=1 AND sum(v.measurement_issue)>=1 then 'B'
                                                when sum(v.collection_issue)>=1 then 'C'
                                                when sum(v.measurement_issue)>=1 then 'M'
												else 'U'
                                        end
                                FROM t_dt v
                                WHERE v.information=1
                                GROUP BY v.data_num,v.information),'.') INTO i;

                        #final flag
                        SET flag=concat(r,s,i);

                        RETURN flag;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_first_of_month` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_first_of_month`(d date) RETURNS date
    NO SQL
BEGIN
		return str_to_date(concat(year(d),'-',month(d),'-1'),'%Y-%c-%e');
	END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_flagType` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_flagType`(flag varchar(2), table_name varchar(25)) RETURNS int(11)
    NO SQL
BEGIN
    declare ret int default 0;
    set ret=case 
		when table_name='flags_system' and flag regexp '[A-Z]' then 1
        
			
    end;
    return ret;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_generateInstID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_generateInstID`(v_inst_manuf_num int ) RETURNS varchar(10) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
    declare prefix varchar(10) default '';
    select concat(id_prefix,'-',lpad((select count(*) from inst_description
		where inst_manuf_num=v_inst_manuf_num)+case when v_inst_manuf_num=5 then 2 when v_inst_manuf_num=8 then 5 else 1 end,3,0)) #padd a couple that had off counts
        into prefix from inst_manufacturer where num=v_inst_manuf_num;
        if(select count(*) from inst_description where id=prefix)>0 then
			#attempt to find a new one that doesn't conflict.  This could happen if someone deletes an entry or changes manuf type of existing.
            #note the format is garunteed because we just hit a duplicate so there is atleast 1.  We don't just do this on all because
            #existing entries do not have the same format.
               select concat(id_prefix,'-',lpad(max(convert(f_getCol(id,2,'-'),UNSIGNED))+1,3,0)) into prefix
               from inst_description d join inst_manufacturer m on m.num=d.inst_manuf_num
			   where m.num=v_inst_manuf_num;
        end if;
    return prefix;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_getCol` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_getCol`(v_txt varchar(1024),v_col int,v_delim varchar(50)) RETURNS varchar(255) CHARSET latin1 COLLATE latin1_swedish_ci
    NO SQL
begin
		#This function returns specified v_col of embedded v_delim separated value string in v_txt or null
		#v_col must be positive n
        if v_col>f_numCsvCols(v_txt,v_delim) then #range check.
			return null;
		else
			return substring_index ( substring_index ( v_txt,v_delim,v_col ), v_delim, -1);
		end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_getCsvCol` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_getCsvCol`(v_csv varchar(1024),v_col int) RETURNS varchar(255) CHARSET latin1 COLLATE latin1_swedish_ci
    NO SQL
begin
		#This function returns specified v_col of embedded comma separated value string in v_csv or null
		#v_col must be positive n
        return f_getCol(v_csv,v_col,',');
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_intake_ht` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_intake_ht`(`sample_altitude` DECIMAL(8,2), `sample_elevation` DECIMAL(8,2)) RETURNS decimal(8,2)
    NO SQL
BEGIN
      DECLARE intake_ht DECIMAL(8,2);

      IF sample_altitude = -9999.99 OR
          sample_elevation = -9999.99  THEN
          SET intake_ht = -9999.99;
      ELSE
          SET intake_ht = sample_altitude-sample_elevation;
      END IF;

      RETURN intake_ht;

   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_isFlaskOkToAnalyze` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_isFlaskOkToAnalyze`(v_event_num int) RETURNS varchar(255) CHARSET latin1 COLLATE latin1_swedish_ci
begin
        declare ret varchar(255) default 'OK';
		#Check for auto low volume flag/tag
		if exists (select * from flask_data where event_num=v_event_num and program_num=1 and flag like 'V%' )
			or exists (select * from flask_data_tag_view t join flask_data d on t.data_num=d.num where d.event_num=v_event_num and d.program_num=1 and t.tag_num in (19,32) ) then
			 set ret="(V..) Sample flow < 0 on a CCGG species";
		end if;

		return ret;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_numCsvCols` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_numCsvCols`(v_csv varchar(1024),v_delim varchar(50)) RETURNS int(11)
    NO SQL
begin
    #returns the number of columns in csv string
		declare ret int default 0;
		set  ret=CHAR_LENGTH(v_csv) - CHAR_LENGTH( REPLACE ( v_csv, v_delim, '') )+1;
        return ret;
	end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_oldstyle_external_flag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_oldstyle_external_flag`(v_data_num int, v_tag_to_remove int, v_tag_to_add int) RETURNS varchar(3) CHARSET latin1 COLLATE latin1_swedish_ci
begin
/*This function is a utility function that returns a modified external flag for added/removed tags
in the oldstyle version.  This is to apply a tag to an 'uncoverted to tag system' row.
It uses the generally non destructive logic of ccg_flaskupdate (won't overwrite an entry).
v_data_num is target row
v_tag_to_remove - 0 if none, tag num of previously applied tag to remove from flag
v_tag_to_add - 0 if none, tag num of tag to add to flag.

returns the new external flag, emtpy string if row is in the tagging system already (because that
would be complicated to program and not useful for anything).
*/
declare v_flag varchar(3) default '';
declare rpos,apos int default 0;
declare rflag,aflag,c1,c2,c3 varchar(1) default '';
DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END;

#Select out the existing flag.
select flag,substring(flag,1,1),substring(flag,2,1),substring(flag,3,1)
	into v_flag,c1,c2,c3 from flask_data where num=v_data_num and update_flag_from_tags=0;

#Figure out the position and letter of old and new tags if any
select case when reject=1 then 1 when selection=1 then 2 when information=1 then 3 else 0 end,flag
	into rpos,rflag from tag_dictionary where num=v_tag_to_remove and flag is not null and char_length(flag)=1 ;
select case when reject=1 then 1 when selection=1 then 2 when information=1 then 3 else 0 end,flag
	into apos,aflag from tag_dictionary where num=v_tag_to_add and flag is not null and char_length(flag)=1;

if(v_flag!='') then#only proceed if this is an oldstyle row.
	#First remove existing flag, if needed.
	if(rpos>0 and rflag!='')then
		if(rpos=1 and rflag=c1 collate latin1_general_cs) then set c1='.'; end if;
		if(rpos=2 and rflag=c2 collate latin1_general_cs) then set c2='.'; end if;
		if(rpos=3 and rflag=c3 collate latin1_general_cs) then set c3='.'; end if;
	end if;
	#Now add new one if needed.
	if(apos>0 and aflag!="")then
		if(apos=1 and c1='.')then set c1=aflag; end if;
		if(apos=2 and c2='.')then set c2=aflag; end if;
		if(apos=3 and c3='.')then set c3=aflag; end if;
	end if;
	#If a tag removed, see if there's any others that could fill in, ie if 2 rejects, and remove one, put the other there.
	if(rpos>0 and rpos!=apos)then
		set aflag='';
		#default to data first, then event.  Pick at random.
		select max(v.flag) into aflag from flask_data_tag_view v
			where v.data_num=v_data_num and flag is not null and char_length(flag)=1 and
				((rpos=1 and v.reject=1) or (rpos=2 and v.selection=1) or (rpos=3 and v.information=1));
		if(aflag is null or aflag='')then
			select max(v.flag) into aflag from flask_event_tag_view v,flask_data d
				where v.event_num=d.event_num and d.num=v_data_num
					and v.flag is not null and char_length(v.flag)=1
					and ((rpos=1 and v.reject=1) or (rpos=2 and v.selection=1) or (rpos=3 and v.information=1));
		end if;
		if(aflag is not null and aflag!='')then
			#defer to the added tag (change) if any
			if(rpos=1 and c1='.')then set c1=aflag; end if;
			if(rpos=2 and c2='.')then set c2=aflag; end if;
			if(rpos=3 and c3='.')then set c3=aflag; end if;
		end if;
	end if;
	set v_flag=concat(c1,c2,c3);
end if;

return v_flag;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_reproducibility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
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

   SELECT scale_min, scale_max INTO f_scale_min, f_scale_max FROM `reftank`.`scales` WHERE species = input_species AND start_date <= input_date ORDER BY start_date DESC LIMIT 1;

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

         RETURN 0.02;
      ELSE
         RETURN 'Out of date range';
      END IF;
   ELSEIF input_species = 'CH4' THEN

      IF '2015-07-06' <= input_date AND
         input_date <= '9999-12-31' THEN

         IF input_value <= 3000 THEN
            RETURN 1.0;
         ELSE
            RETURN ROUND(0.0004*input_value,1);
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

         IF 310 <= input_value AND
            input_value <= 340 THEN
            RETURN 0.22;
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
            RETURN 0.03;
         ELSE
            RETURN 0.05;
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
/*!50003 DROP FUNCTION IF EXISTS `f_sampleSheetDirPath` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_sampleSheetDirPath`(v_event_num int) RETURNS varchar(1000) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
		/*Returns a standardized subpath to use for scanned sample sheet.
        I don't know where we'll put the samplesheets dir yet, so this will be
        path from there for org purposes.
        Be very wary changing format, it may be expected by some programs.
        If adding others (hats_flask?) change view to a join with gmd.project
        */
		DECLARE fn varchar(1000);
        select
			lower(concat(
            "/",case when strategy_num=1 then 'flask' when strategy_num=2 then 'pfp' else strategy end,
            "/",case when project_num=1 then 'surface' when project_num=2 then 'aircraft' else project end,#spell out to remove ccg_ and to prevent future issues if name changes
			"/",site,
            "/"))

        into fn
        from ccgg.flask_event_view where num=v_event_num;
		RETURN fn;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_sampleSheetFileName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_sampleSheetFileName`(v_event_num int) RETURNS varchar(1000) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
		/*Returns a standardized filename to use for scanned sample sheet.
        Be very wary changing format, it may be expected by some programs.
        If adding others (hats_flask?) change view to a join with gmd.project
        */
		DECLARE fn varchar(1000);
        declare fm varchar(40) default '%Y.%m.%d_%H.%i.%S';
        select
			case when strategy_num=1 #flask
				then lower(concat(
                case when strategy_num=1 then 'flask' when strategy_num=2 then 'pfp' else strategy end,
                "_",case when project_num=1 then 'surface' when project_num=2 then 'aircraft' else project end,#spell out to remove ccg_ and to prevent future issues if name changes
                "_",site,
                "_",date_format(ev_datetime,fm),".pdf"))
			when strategy_num=2 #pfp
				then lower(concat(
                case when strategy_num=1 then 'flask' when strategy_num=2 then 'pfp' else strategy end,
                "_",case when project_num=1 then 'surface' when project_num=2 then 'aircraft' else project end,
                "_",site,
				"_",f_getCol(id,1,'-'),"_",date_format(ev_datetime,fm),".pdf"))
			else '' end
        into fn
        from ccgg.flask_event_view where num=v_event_num;
		RETURN fn;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_snippet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_snippet`(txt text, n int) RETURNS varchar(255) CHARSET latin1 COLLATE latin1_swedish_ci
    NO SQL
begin
	return concat(substring(txt, 1, n-3), IF(length(txt) > n, '...', substring(txt, n-2)));
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_tag_userTimeStamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_tag_userTimeStamp`(v_userid int) RETURNS varchar(1000) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
		/*Returns a user timestamp where v_userid is a key in the ccgg.contact table.*/
		DECLARE stamp varchar(1000); 
		set stamp=concat('(',case when v_userid<=0 then '[Automated process]' else ifnull((select abbr from ccgg.contact where num=v_userid),'') end," ",now(),') ');
		RETURN stamp;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_tag_userTimeStamp2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_tag_userTimeStamp2`(v_username varchar(255)) RETURNS varchar(1000) CHARSET latin1 COLLATE latin1_swedish_ci
BEGIN
		/*Returns a user timestamp for passed name.  This is intended to be used where caller is bypassing normal security (pydv, automated entries)
        and passes user name directly (unix username).  We capitalize the first char for appearence and assume only single word was passed.*/
		DECLARE stamp varchar(1000);
		set stamp=concat('(',CONCAT(UCASE(LEFT(v_username, 1)),LCASE(SUBSTRING(v_username, 2)))," ",now(),') ');
		RETURN stamp;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_utctime2lstdec` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_utctime2lstdec`(v_event_num int ) RETURNS double(14,9)
BEGIN
	declare t double(14,9) default 0;
	select
		case when lst2utc>-99 then
			time_to_sec(time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time))))/60.0/60.0 #fractional hours
			#time_to_sec(time(date_add(timestamp(e.date,e.time), interval -1*s.lst2utc hour)))/(24*60*60) #fractional day
			else 0 end into t
	from flask_event e join gmd.site s on e.site_num=s.num
	where e.num=v_event_num;
	return t;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_windDir` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_windDir`(u decimal(12,4), v decimal(12,4) ) RETURNS decimal(12,4)
    NO SQL
BEGIN
 		return (atan2(-u,-v)*57.29578) ;# 57 is 180/pi
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_windSpeed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_windSpeed`(u decimal(12,4), v decimal(12,4) ) RETURNS decimal(12,4)
    NO SQL
BEGIN
    declare DperR decimal (12,5) default 57.29578; #180/pi
 		return sqrt(pow(u,2)+pow(v,2)) ;
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
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`140.172.193.%` PROCEDURE `cal_initTest`(v_species varchar(5))
begin
/* Inits the test tables and gathers fill code info if needed.
This is to be used when testing new calibration scale changes (using calpro/flpro python scripts with test option).

v_species is formula from gmd.parameter table.

This creates several views which can be used to retrieve data after being processed.
cal_scale_tests.
	fill_avgs_view
	tanks_view
	flask_view
*/
declare v_parameter_num int default 0;
declare v_status int default 0;

#We'll need to loop through to get fill codes easily.  Set up cursor now.
DECLARE done INT DEFAULT FALSE;
declare _idx int default 0;
declare _code varchar(4) default '';
declare cur cursor for select idx from cal_scale_tests.calibrations;
declare continue handler for not found set done = true;

#fetch parameter to get num (if needed) and to verify 
select num into v_parameter_num from gmd.parameter where formula=v_species;

#verify the parameters.
if(v_parameter_num=0)then select 'Invalid species, call like "call cal_initTest("co2");"',v_species; set v_status=1; end if;
#if(v_type not in ('cal','flask')) then select 'invalid type passed, call like "call cal_initTest("co2","cal");"'; set v_status=1; end if;

if(v_status=0) then
	#Wipe and create a testing calibrations table.
	drop table if exists cal_scale_tests.calibrations;#!
	create table cal_scale_tests.calibrations like reftank.calibrations;
	insert cal_scale_tests.calibrations select * from reftank.calibrations where species like v_species;


	#create and fill a table with fill code info to make matching logic easier
	drop table if exists cal_scale_tests.test_fill_codes;
	create table cal_scale_tests.test_fill_codes (index i(cal_idx))  as select idx as cal_idx,'none' as code from cal_scale_tests.calibrations;
	
	
	#Loop through each and find fill code (if any).
	open cur;
	read_loop: LOOP
		fetch cur into _idx;
		if done then leave read_loop; end if;
		
		set _code='';
		select f.code into _code 
		from cal_scale_tests.calibrations c join reftank.fill f on c.serial_number=f.serial_number
		where c.idx=_idx and f.date <= c.date
		order by f.date desc,f.code
		limit 1;

		if (_code!='') then #update if found.
			update cal_scale_tests.test_fill_codes set code=_code where cal_idx=_idx;
		end if;
		set done=false;#If we didn't find a fill, the handler sets this to true.. pia.  reset each loop so it can continue
	end LOOP;
	close cur;
	


	#create an agg view
	SET @@session.group_concat_max_len = 20000; #not sure how long this persists for...
	create or replace view cal_scale_tests.fill_avgs_view as
		select c.serial_number,c.inst,c.species, f.code, 
			avg(r.mixratio) as avg_mixratio_old, 
			avg(r.stddev) as avg_stddev_old,
			avg(c.mixratio) as avg_mixratio_new, 
			avg(c.stddev) as avg_stddev_new,
			group_concat(concat('idx:', c.idx,' (',c.date,' ',c.time,') mr:',c.mixratio,' stdv:',c.stddev) order by c.date separator ' | ') as results
		from cal_scale_tests.calibrations c join cal_scale_tests.test_fill_codes f on c.idx=f.cal_idx
			join reftank.calibrations r on r.idx=c.idx
		where c.flag='.'
		group by c.serial_number,c.inst,c.species,f.code;

	#and a view to put it all together
	create or replace view cal_scale_tests.tanks_view as
		select o.idx,f.code as fill_code,o.serial_number,o.date,o.time,o.species,o.mixratio as old_mr,n.mixratio as new_mr,
		o.stddev as old_stddev, n.stddev as new_stddev, o.num,o.method,o.inst,o.pressure,o.flag,o.location,o.regulator,o.notes,o.mod_date
		from reftank.calibrations o join cal_scale_tests.calibrations n on n.idx=o.idx
			join cal_scale_tests.test_fill_codes f on f.cal_idx=o.idx;

		#flask data
	drop table if exists cal_scale_tests.flask_data;
	create table cal_scale_tests.flask_data like ccgg.flask_data;
	insert cal_scale_tests.flask_data select * from ccgg.flask_data where parameter_num=v_parameter_num;
	#select * from cal_scale_tests.flask_data order by date desc limit 1000;

	#create a view to put together.
	create or replace view cal_scale_tests.flask_view as
		select o.num,o.event_num,o.program_num,o.parameter_num,n.value as new_value,o.value as old_value,
			o.unc,o.flag,o.inst,o.date,o.time,o.dd,o.comment
		from ccgg.flask_data o join cal_scale_tests.flask_data n on o.num=n.num;

end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ccg_pairAverage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `ccg_pairAverage`(v_site varchar(20),v_start_date date, v_end_date date,v_parameter varchar(20),v_logic_mode int)
begin
/*This procedures calculates flask pair (and psuedo pair) averages for passed parameter or 'all' for all params.
Site is three letter code
start and end dates are the date range for sample dates.
v_logic_mode is what set of logic assumptions to use for the event matching algorithm and what the output is
from this procedure.
See ccg_pairEvents for comments on matching algorithms.

The default/generic logic mode is 1.
	Mode 1 calls ccg_pairEvents with v_logic_mode=1, filters out values with first col rejection flag
	and outputs a default set of results which are a join of t_pairAverages (see below for col details)
	with basic event info for the first event in the pair grouping.
mode 2 is similar but only does exact time matches, no psuedo groupings

Regardless of output, this procedure creates and fills a temp table t_pairAverages with;
	grp_event_num which is a representative event number for each grouping
	grp_id which is a concatinated list of all member event_nums
	parameter_num - number for passed parameter text
	avg_value - avg of non-rejected values in pair
	num_vals - number of values in average

As a byproduct it also creates t_eventPairs with 2 columns; event_num and grp_event_num,
the second of which can be used to group pairs together.
See ccg_pairEvents for details.
This table can be used for more complicated averaging or other query purposes.
*/

declare parameter_num int default 0;

#Pair all the target events
call ccg_pairEvents(v_site,v_start_date,v_end_date,v_logic_mode);

#Find param num
if(v_parameter != 'all')then
	select num into parameter_num from gmd.parameter where lower(formula)=lower(v_parameter);
end if;

#Now we can build our output table
drop temporary table if exists t_pairAverages, t_eventPairs2;
#create a work table with a unique grp id for each grp_event_num.  This is so all parameters have same grp_id even if
#not all events used in avg (like if some were flagged for that species)
create temporary table t_eventPairs2 as
	select t.grp_event_num,
		group_concat(distinct t.event_num order by t.event_num SEPARATOR '|') as grp_id
    from t_eventPairs t
    group by t.grp_event_num;

create temporary table t_pairAverages (index i(grp_event_num)) as
	select t.grp_event_num,
		max(t2.grp_id) as grp_id,#max here so don't have to group by below, one for each event_num, but all the same so max or min same
        #group_concat(distinct t.event_num order by t.event_num SEPARATOR '|') as grp_id,
		d.parameter_num,
		cast(avg(d.value) as decimal(12,4)) as avg_value,
		stddev(d.value) as stddev_value,
		count(distinct(d.num)) as num_vals
	from flask_data d, t_eventPairs t, t_eventPairs2 t2
	where d.event_num=t.event_num and t.grp_event_num=t2.grp_event_num
		and (d.parameter_num=parameter_num or parameter_num=0)
		and d.flag like '.%' #This could be condtional based on logic mode.
	group by t.grp_event_num,d.parameter_num
	order by grp_event_num,d.parameter_num;

#Output results
#Actually don't.. we're integrating into ccg_flask2.py so this isn't needed.
if(v_logic_mode=0)then
	select a.grp_event_num,a.grp_id,p.formula,
		a.avg_value,a.stddev_value,a.num_vals,
		v.site,v.project,v.strategy,v.me,v.datetime,
		dd,lat,lon,alt,elev
	from t_pairAverages a,flask_event_view v, gmd.parameter p
	where a.grp_event_num=v.event_num  and a.parameter_num=p.num
	order by grp_event_num,p.formula;
end if;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ccg_pairEvents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `ccg_pairEvents`(v_site varchar(20),v_start_date date, v_end_date date,v_logic_mode int)
begin
/*This procedure matches all actual and psuedo flask pairs together.
It creates a temporary table t_eventPairs with 2 columns; event_num and grp_event_num,
the second of which can be used to group pairs together.  Pairs (misleading name) can be 2+ events
that are grouped according to the rules below.

Site is the three letter code
start and end dates are the date range for sample dates.
v_logic_mode is what set of logic assumptions to use for the event matching algorithm.
	Option is 1 which makes these assumptions/filters:
		-Only considers ccg_surface/aircraft, flask/pfp
		-same site, project,strategy, method and:
			-strategy flask -> no psuedo pairs, always have same datetime.
			-strategy pfp, project surface -> datetime within 30 min
			-strategy pfp, project aircraft same time only-> no atempt at psuedo pairing is made because the 2nd cylinder of the pair is always
				for co2c14.  Note the psuedo pairing logic is complicated if this needs to be implemented.  At a min
				you need to account for alt (within ~200 feet), lat/lon (withing ~2.5 degrees) and time window (~30min?)
				We decided to skip as no one was asking for these pairs.
		-For surf pfps; we psuedo pair all events that occur inside of the 30 min window from the first event unless
		the first 2 are at the same time in which case we only group additional events at that same time.
		This is because the psudeo pair logic is fairly fuzzy so we need to be inclusive.
		Once same timed pairs started, then the grouping definition became fairly clear.
		--Actually, we decided to not do this.  Leaving the logic and comment though in case we want to do it
		for a different logic mode.
	Option 2 is the same as 1 except all pairs are same datetime (no psuedo pairs)
We require passing the single v_logic_mode parameter for future flexibility because our version of mysql
requires all parameters to be passed, making it difficult to add a new parameter in the future without breaking existing code
if we want to add a new set of logic rules.  We've already identified some different rule conditions we may want to
apply for specific campaigns, although those may be site specific.

*/
declare done int default false;
declare prevEventNum,prevSite,prevProj,prevStrat mediumint default 0;
declare currEventNum,currSite,currProj,currStrat mediumint default 0;
declare timediff,isExactMatch,pairExactsWithWindow int default 0;
declare prevEvDate,currEvDate datetime default '1000-01-01';
declare prevMe,currMe char(3) default '';
declare cur cursor for
	select num,site_num,project_num,strategy_num,me,datetime
	from ccgg.flask_event_view
	where site=v_site
		and date>=v_start_date
		and date<=v_end_date
		and case when v_logic_mode=1 or v_logic_mode=2 then
			strategy_num in (1,2) and project_num in (1,2) #filter to ccg_surface/air, flask/pfp
		else 1=0 end

	order by site_num,project_num,strategy_num,me,datetime,num;#Note this order is significant for below logic.

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

#Output table.
drop temporary table if exists t_eventPairs;
create temporary table t_eventPairs (index i(grp_event_num)) as
	select event_num,event_num as 'grp_event_num'
	from ccgg.flask_event_view where 1=0;

#This conditional deals with how to handle an actual pair with same time and another event within the window (pfp)
#If 1 then we'll pair anything in the time window.  If 0 then we'll only group either
#exact matches or psuedos, but won't add an event that occured in the window of 2 exact matches.
set	pairExactsWithWindow=case when v_logic_mode=1 then 1 else 0 end;

#I couldn't figure out how to do this algorithm quicker using set operations.  I think
#this type of problem is actually faster as an iterative loop.
#We basically just start the beginning and compare each to the previous grouped by site,prj,strat,me
#and if within set time window, then create pair groups by assigning the first event as 'grp_event' to
#all members.

open cur;
read_loop: LOOP
	fetch cur into currEventNum,currSite,currProj,currStrat,currMe,currEvDate;

	if done then
		LEAVE read_loop;
	end if;

	#Set matching criteria depending on logic mode.  The only real difference is how to match time.
	set timediff=
			case
				when v_logic_mode=1 then
					case
						when currProj=1 and currStrat=2 then 60*30 #surface pfp->30 min
							#The rest of the cases are all 0, this is just to document.
						when currProj=1 and currStrat=1 then 0 #surface flask, same time
						when currProj=2 then 0 #aircraft, flask/pfp only pair same timed events.
						else 0
					end
				else 0 #mode 2
			end;


	#Compare to prev record and save into temp table for later grping.
	#We'll record the first event_num of psuedo pair for id.
	if(currSite!=prevSite or currProj!=prevProj or currStrat!=prevStrat or currMe!=prevMe #different site,proj,strategy or me
		or timestampdiff(second,prevEvDate,currEvDate)>timediff #outside of the matching window
		or (pairExactsWithWindow=0 and isExactMatch=1 and timestampdiff(second,prevEvDate,currEvDate)>0)) #This
			#event is after the prev and the prev 2+ were exact matches and we are set to only pair exacts with each other.
	then
		#This is the start of a new pair, save off into the prev vars and save with this one as the grp num.
		set prevSite=currSite, prevProj=currProj, prevStrat=currStrat, prevMe=currMe,prevEvDate=currEvDate,prevEventNum=currEventNum,isExactMatch=0;
	else
	#It was a match.  See if it was an exact match and mark it if so
		if(timestampdiff(second,prevEvDate,currEvDate)=0 )then
			set isExactMatch=1;
		end if;
	end if;

	insert t_eventPairs select
		currEventNum,prevEventNum;

END LOOP;
close cur;

#This is a silly noop workaround for mysql bug.. just to prevent warnings about no work done (1329).
select 1 into done from t_eventPairs limit 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ccg_syncHatsData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `ccg_syncHatsData`(v_useTargetNums int, out v_mssg varchar(255))
begin
	#Some variables with set values
	declare vProgramNum int default 8;#HATS
	declare vUcount,vIcount,vDcount,vDoDelete int default 0;
	#declare vDataSource int default 11;
	set v_mssg='';#output variables defaults.

	drop temporary table if exists t_hatsData,t_inserts,t_dels,t_targNums;

	#Create and fill targ table.
	if(v_useTargetNums=0)then
		create temporary table t_targNums (index i(analysis_num)) as select num as analysis_num from hats.analysis where sample_type in('PFP','CCGG') and event_num!=0;#All analysis_nums
		set vDoDelete=1;#Set flag to do delete operation.
	else
		create temporary table t_targNums (index i(analysis_num)) as select distinct analysis_num from t_targAnalysisNums;#Make sure to distinctify in case there were dups (which will mess up inserts)
	end if;

	#Create a temp table of all target hats rows that need to be propagated.
	#Note; we can't use hats_data_view here because we need to find new hats rows too.
	create temporary table t_hatsData (index i (event_num,parameter_num)) as
		select a.event_num,vProgramNum as program_num,m.parameter_num,
			##Temporarity (8/19) adjust pr1 values to m1/2/3 scale.  per ben miller and Steve M.  cast to dec to avoid rounding issues.
            case when a.inst_num=58 and m.parameter_num=42 then cast(m.C_reported/1.0212 as decimal(12,4)) else m.C_reported end as value,
            -999.9900 as unc,
			i.id as inst, a.analysis_datetime#Note adatetime is in gmt!  Still under discussion on whether to convert to lst for import
		from hats.analysis a join t_targNums t on a.num=t.analysis_num
			join hats.mole_fractions m on a.num=m.analysis_num
			join ccgg.inst_description i on a.inst_num=i.num
		where a.lab_num=1 and a.inst_num in (46,47,54,58)
			and a.sample_type in('PFP','CCGG') and event_num!=0;
	#create index i on t_hatsData(event_num,parameter_num);

	#update any existing that are different.
	update flask_data d, t_hatsData h
	set d.value=h.value, d.unc=h.unc
	where d.program_num=h.program_num
		and d.event_num=h.event_num
		and d.parameter_num=h.parameter_num
		and d.inst=h.inst
		and timestamp(d.date,d.time)=h.analysis_datetime
		and (d.value!=h.value or d.unc!=h.unc); #Note this is needed to get accurate row_count in some callers.
	set vUcount=row_count();

	#Insert any new rows
	create temporary table t_inserts as
	select h.*
	from t_hatsData h left join flask_data d
		on (h.program_num=d.program_num and h.event_num=d.event_num and h.parameter_num=d.parameter_num
			and h.inst=d.inst and h.analysis_datetime=timestamp(d.date,d.time))
	where d.event_num is null;

	insert flask_data (event_num,program_num,parameter_num,inst,date,time,dd,value,unc,flag,comment,update_flag_from_tags)
	select t.event_num,t.program_num,t.parameter_num,t.inst,date(t.analysis_datetime),time(t.analysis_datetime),
		f_date2dec(date(t.analysis_datetime),time(t.analysis_datetime)),t.value,t.unc,'...','',1
	from t_inserts t join flask_event e on t.event_num=e.num;#Ensure that event actually exists.. sometimes this gets out of sync.
	set vIcount=row_count();

	if(vDoDelete=1)then
		#Delete any that have been removed.
		create temporary table t_dels as
		select d.num
		from flask_data d left join t_hatsData h
			on (d.program_num=h.program_num and d.event_num=h.event_num and d.parameter_num=h.parameter_num
				and d.inst=h.inst and timestamp(d.date,d.time)=h.analysis_datetime)
		where d.program_num=vProgramNum and h.event_num is null;

		delete d from flask_data d, t_dels t
		where d.num=t.num and d.program_num=vProgramNum;
		set vDcount=row_count();
	end if;

	#Clean up and set output.
	drop temporary table if exists t_hatsData,t_inserts,t_dels,t_targNums;
	set v_mssg=case when vUcount+vIcount+vDcount=0 then 'No changes.' else
		concat(case when vUcount > 0 then concat(vUcount,' ccgg flask_data rows updated (value).  ') else '' end,
				case when vIcount > 0 then concat(vIcount, ' ccgg flask_data rows inserted.  ') else '' end,
				case when vDcount > 0 then concat(vDcount,' ccgg flask_data rows deleted.') else '' end
	) end;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ccg_syncNewHatsData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `ccg_syncNewHatsData`()
begin
	/*This is a 'quick' sync of any new rows added to hats analysis.  This doesn't sync flags, update existing or delete from flask_data, only adds
    new rows that are not currently in flask_data.  Designed to be lightweight cron job to bring in new data as it arrives.*/
	drop temporary table if exists t_targAnalysisNums;
	create temporary table t_targAnalysisNums (index i(analysis_num)) as
		select num as analysis_num from hats.analysis where analysis_datetime>=(select timestamp(date,time) from flask_data where program_num=8 order by date desc, time desc limit 1);
	call ccg_syncHatsData(1,@v_mssg);
	select @v_mssg;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag2_addEditTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag2_addEditTagRange`(v_userid int,inout v_range_num int, v_tag_num int, v_add_comment text,v_prelim tinyint,v_json_selection_criteria text, v_description varchar(255),v_data_source int,out v_status int,out v_mssg varchar(255),out v_numrows int)
sp: begin
/*
TODO; 
-if tag changed, old needs to be passed into tag_updateOldStyleFlags() (or atleast follow code all the way through to verify acting correct)
-add foreign keys (didn't want to do this right before leaving town)
-add inisitu logic to tag_range_info_cache()


This procedure creates a new, modifies an existing or removes a tag range. 
tag2_initMemberTables() should be called prior to calling this procedure.

-If v_range_num=0, then a new range is created with passed parameter info and members from tmp member tables created using
tag2_initMemberTables(0).
-If v_range_num>0 then that range is edited, setting range info using passed parameters, and members using
tag2_initMemberTables([range_num]) tables.  If no members in any tables, this removes the tag range (delete).
  
Note! This procedure will make the members be whatever are in the temporary member tables(removes existing members that do not have
corresponding rows in the member tables), so you must fill them appropriately even if not changing range members.  
This can be done easily by passing range num to tag2_initMemberTables([range_num]);

This does not check to see if tag exists for members, caller should do that as appropriate.

Any affected measurement rows flag col will be updated appropriately. (flask_data, insitu_data...)

As there are multiple tables involved, this uses a transaction to manage data integrity.  
Caller must not wrap call in a transaction as that may not work as expected.

Inputs:
This procedure expects the member temp tables to exist by caller calling tag2_initMemberTables() and filliing as appropriate.

-v_userid is ccgg.contact num column or <0 for automated process.  Note, we do not do any security checks in SP (all done in application logic)
if v_userid=-2, we pass comment straight through without appending timestamp (caller does it).
-v_range_num is 0 for new range, existing range_num otherwise.
-v_tag_num is tag to set.  Pass -1 on edit to leave unchanged.
-v_add_comment is appended to existing comment (sets when comment is null).  This procedure adds a user/timestamp.
-v_prelim, pass 1 to mark this tags as 'preliminary' which is just a way to highlight for frontend. -1 for no change.
v_json_selection_criteria is a json hash array of the selection criteria for use by the php front end.  This should be
	passed null from any other front end unless cooridinated with the php logic. It's used to reload/change the orignal search criteria
	pass -1 for no change to existing, null to remove.
v_description, can be null, is a description of the criteria selection.  Pass -1 to keep existing.
v_data_source is a num from tag_data_sources.  This isn't displayed anywhere, but is convienent for developer use.
	It is used to group ranges together to make it easier to delete them, mostly during development/initial conversions of sites,
	but also in automated scripts that may delete entries with a particular data_source so use with care.

Outputs:
-This returns in v_status:
	0 for success
	1 for  error. v_mssg may have a text description of the error.
-v_mssg may contain a displayable message.
-v_numrows will contain the number of affected rows.
-v_range_num will contain newly inserted or edited range_num.
*/
	declare vRowsDeleted,vRowsInserted,vFlaskFlagsUpdated,vInsituFlagsUpdated,vOldStyleFlagsUpdated,v_member_count int default 0;
	declare vComment text default '';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- Declare variables to capture error details
		DECLARE err_code VARCHAR(5);
		DECLARE err_message TEXT;
		GET DIAGNOSTICS CONDITION 1 err_code = RETURNED_SQLSTATE, err_message = MESSAGE_TEXT;-- Get the error details
		ROLLBACK;-- Rollback transaction
		SET v_status = 1;
		-- Raise the error with the actual message
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_message;#CONCAT('SQL Error [', err_code, ']: ', err_message);
	END;
    
    set v_status=0,v_mssg='Status:',v_numrows=0;
	                
	if(v_tag_num>0 and (select count(*) from tag_dictionary where num=v_tag_num)=0) then
		set v_status=1,v_mssg=concat("Error: Invalid tag id (",v_tag_num,")");
	else 
		START TRANSACTION;#Wrap in a transaction since we will be touching multiple tables.
		
		#Set comment as needed
		set vComment=concat(f_tag_userTimeStamp(v_userid),ifnull(v_add_comment,'[tag added]'));
		if(v_data_source=11 or v_userid=-2) then #Hats sync or special call from automated process, don't add timestamp, just pass thru
			set vComment=v_add_comment;
		end if;
	
		#Create new tag range if needed and save off the new id
		if(v_range_num=0) then				
			insert tag_ranges (tag_num,comment,prelim,json_selection_criteria,data_source,description) 
				select v_tag_num,
					vComment,
					ifnull(v_prelim,0),
					v_json_selection_criteria,
					v_data_source,
					v_description;				
			set v_range_num=last_insert_id();
            set v_mssg= concat(v_mssg," Tag range ",v_range_num," created.");
			set v_numrows=1;
            
			if(v_range_num is null or v_range_num=0) then
				select v_userid,v_range_num,v_tag_num,v_add_comment,v_prelim, v_json_selection_criteria, v_description,v_status,v_mssg,v_numrows;
				set v_status=1,v_mssg='Error inserting range';
				rollback;
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error inserting range'; -- Stop execution
			end if;
		else
			#update existing range (only if we still have members and arent' going to later delete)
			update tag_ranges set json_selection_criteria=v_json_selection_criteria,description=v_description,
				tag_num=case when v_tag_num=-1 then tag_num else v_tag_num end, 
				prelim=v_prelim, comment=concat(ifnull(concat(comment,'\n'),''),vComment)
			where num=v_range_num;
			set v_numrows=1;
			set v_mssg= concat(v_mssg," Tag range ",v_range_num,' updated.');
		end if;
		
		#Update/set applicable members
		if(v_status=0)then #Not strictly needed to check this as above will short the procedure, but this is clearer
			#Keep track of inserts/deletes so we can update external flags below.
			#Flask data rows
			drop temporary table if exists t__datanumsDeleted,t__datanumsInserted;
            
            create temporary table t__datanumsDeleted (index i(num)) as 
				#rows we'll be removing
				select d.data_num as num 
				from flask_data_tag_range d left join t_data_nums t on d.data_num=t.num 
				where d.range_num=v_range_num and t.num is null;
			
			create temporary table t__datanumsInserted (index i(num)) as 
				#rows we'll be inserting
				select t.num 
				from t_data_nums t left join flask_data_tag_range d on (t.num=d.data_num and d.range_num=v_range_num)
				where d.data_num is null;
			
			#Flask Event rows
			drop temporary table if exists t__eventsDeleted, t__eventsInserted;
			create  temporary table t__eventsDeleted (index i(num)) as
				#rows we'll be removing
				select e.event_num as num
				from flask_event_tag_range e left join t_event_nums t on e.event_num=t.num
				where e.range_num=v_range_num and t.num is null;
			create  temporary table t__eventsInserted (index i(num)) as
				#rows we'll be inserting
				select t.num
				from t_event_nums t left join flask_event_tag_range e on (t.num=e.event_num and e.range_num=v_range_num)
				where e.event_num is null;
				
			#Insitu data rows
			drop temporary table if exists t__insituNumsDeleted, t__insituNumsInserted;
			create  temporary table t__insituNumsDeleted (index i(num)) as
				#rows we'll be removing
				select i.insitu_num as num
				from insitu_data_tag_range i left join t_insitu_nums t on i.insitu_num=t.num
				where i.range_num=v_range_num and t.num is null;
			create temporary table t__insituNumsInserted (index i(num)) as
				#rows we'll be inserting
				select t.num
				from t_insitu_nums t left join insitu_data_tag_range i on (t.num=i.insitu_num and i.range_num=v_range_num)
				where i.insitu_num is null;

			
			#Remove any existing not in the new list
			delete d from flask_data_tag_range d join t__datanumsDeleted t on d.data_num=t.num and d.range_num=v_range_num;
				set vRowsDeleted=row_count();
			delete e from flask_event_tag_range e join t__eventsDeleted t on e.event_num=t.num and e.range_num=v_range_num;
				set vRowsDeleted=vRowsDeleted+row_count();
			delete i from insitu_data_tag_range i join t__insituNumsDeleted t on i.insitu_num=t.num and i.range_num=v_range_num;
				set vRowsDeleted=vRowsDeleted+row_count();
			
			#Insert any new ones.  
			insert into flask_data_tag_range (data_num,range_num) 
				select distinct num,v_range_num from t__datanumsInserted;
				set vRowsInserted=row_count();
			insert into flask_event_tag_range (event_num,range_num)
				select distinct num,v_range_num from t__eventsInserted;
				set vRowsInserted=vRowsInserted+row_count();
			insert into insitu_data_tag_range (insitu_num,range_num)
				select distinct num,v_range_num from t__insituNumsInserted;
				set vRowsInserted=vRowsInserted+row_count();
		
			if (vRowsInserted>0) then set v_mssg= concat(v_mssg," Rows tagged:",vRowsInserted); end if;
            if (vRowsDeleted>0) then set v_mssg= concat(v_mssg," Rows un-tagged:",vRowsDeleted); end if;
            set v_numrows=vRowsInserted+vRowsDeleted;
            
			#Delete the range if no members, update the cache otherwise
            if( (select count(*) from flask_data_tag_range where range_num=v_range_num)
					+(select count(*) from flask_event_tag_range where range_num=v_range_num)
					+(select count(*) from insitu_data_tag_range where range_num=v_range_num) =0) then
				#Delete the range too
				set v_mssg=concat(v_mssg, ' Deleting range:',v_range_num);
				delete from tag_ranges where num=v_range_num;
				delete from tag_range_info_cache where range_num=v_range_num;
				delete from tag_range_openended_criteria where range_num=v_range_num;
			else
				#Update the range info cache
                ####!!! Note; insitu ranges aren't updated yet.. need to figure out what caller will want.
                delete from t_range_nums;
				insert t_range_nums select v_range_num;
				#call tag_setTagRangeInfoCache();
			end if;
			
            drop temporary table if exists t__d,t__e,t__i;
            #We'll save off member tables so we can reset.  It would be better if the flagging logic didn't use them though, 
            #so may want to rewrite so we don't need to do this.  Not in project scope at moment..
			create temporary table t__d as select * from t_data_nums; 
            create temporary table t__e as select * from t_event_nums;
            create temporary table t__i as select * from t_insitu_nums;
			#update external flags in flask_data (if configured) and insitu_data
			delete from t_data_nums;
			delete from t_event_nums;
            delete from t_insitu_nums;
			insert t_data_nums select distinct num from t__datanumsInserted;
			insert t_event_nums select distinct num from t__eventsInserted;
			insert t_data_nums select distinct num from t__datanumsDeleted;
			insert t_event_nums select distinct num from t__eventsDeleted;
			insert t_insitu_nums select distinct num from t__insituNumsInserted;
			insert t_insitu_nums select distinct num from t__insituNumsDeleted;
            
			#Update any flags for rows that aren't converted to the tagging system yet.
			call tag_updateOldStyleFlags(0,v_tag_num,vOldStyleFlagsUpdated,v_mssg);
			if(vOldStyleFlagsUpdated>0)then
				set v_mssg=concat(v_mssg,"  Non tagging flask_data flags updated:",vOldStyleFlagsUpdated);
			end if;
			call tag_updateFlagsFromTags(vFlaskFlagsUpdated);#flask_data/flask_event
			call tag2_updateInsituFlagsFromTags(vInsituFlagsUpdated);#insitu_data
			if(vFlaskFlagsUpdated>0)then
				set v_mssg=concat(v_mssg,"  flask_data flags updated:",vFlaskFlagsUpdated);
			end if;
			if(vInsituFlagsUpdated>0)then
				set v_mssg=concat(v_mssg,"  insitu_data flags updated:",vInsituFlagsUpdated);
			end if;
			
            #reset member tables
            delete from t_data_nums;
			delete from t_event_nums;
            delete from t_insitu_nums;
            insert t_data_nums select * from t__d;
            insert t_event_nums select * from t__e;
            insert t_insitu_nums select * from t__i;
            
		end if;
	   
        COMMIT;#Commit any changes.
	end if;#valid tag_num    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag2_initMemberTables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag2_initMemberTables`(v_range_num int)
begin
/*
This procedure inits any temporary tables used by the tag2_ family of procedures.
v_range_num can be 0 for caller to fill tables/new range, or range_num to prefill member tables with an existing range
*/
	drop temporary table if exists t_data_nums, t_event_nums, t_insitu_nums, t_range_nums;
    create temporary table t_data_nums (index i(num)) as select data_num as num from flask_data_tag_range where range_num=v_range_num;
    create temporary table t_event_nums (index i(num)) as select event_num as num from flask_event_tag_range where range_num=v_range_num;
    create temporary table t_insitu_nums (index i(num)) as select insitu_num as num from insitu_data_tag_range where range_num=v_range_num;
    create temporary table t_range_nums (index(num)) as select num from tag_ranges where num=v_range_num;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tagwr_addFlaskDataTag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tagwr_addFlaskDataTag`(v_data_num int,v_tag_num int,v_comment varchar(255),v_username varchar(255))
begin
/*
This procedure is a wrapper that creates a new tag range with comment for the passed flask_data.num (v_data_num).
v_username is the unix/windows username
if the tag already exists, it appends the passed comment to first tag_range found.

flask_data.flag will be updated appropriately.

This returns 2 columns in a resultset:
status:
0 for success
1+ for error

message: may contain a displayable message.
*/
    declare vdata_source int default 17;#see ccgg.tag_data_sources
    declare vuserid int default -2;#see tag_securityAccess(), bypassing.
	declare v_status,v_numrows,v_range_num,vrange_num int default 0;#To pass to sp
    declare v_mssg varchar(255) default '';
    declare vComment text default '';

	if((select count(*) from tag_dictionary where num=v_tag_num)=0) then
		set v_status=2,v_mssg=concat("Error: Invalid tag id (",v_tag_num,")");
	else
		#prepend timestamp
        #See if any ranges with passed tag num already exist for passed ids.
		set vrange_num=(select min(v.range_num) from flask_data_tag_view v where v.data_num=v_data_num and v.tag_num=v_tag_num);
		if(vrange_num is not null and vrange_num>0)then
			if(v_comment is not null and v_comment != '') then
				set vComment=concat(f_tag_userTimeStamp2(v_username),v_comment);
				call tag_appendTagComment(vuserid, vrange_num, vComment, v_status, v_mssg, v_numrows);
			end if;
		else
			drop temporary tables if exists t_data_nums,t_event_nums;
			create temporary table t_data_nums as select num from flask_data where 1=0;
			create temporary table t_event_nums as select num from flask_event where 1=0;
			insert t_data_nums select v_data_num;
            set vComment=concat(f_tag_userTimeStamp2(v_username),ifnull(v_comment,'[tag added]'));
			call tag_createTagRange(vuserid,v_tag_num, vComment,0,'',vdata_source,'',v_status,v_mssg,v_numrows,v_range_num);
		end if;#tag already exists
	end if;#valid tag_num
    select v_status as status,v_mssg as message;#convienence for caller, send back in a resultset.
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tagwr_delFlaskDataTag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tagwr_delFlaskDataTag`(v_data_num int,v_tagrange_num int,v_username varchar(255))
begin
/*
This procedure is a wrapper that removes a tag for the passed flask_data.num (v_data_num).  
v_username is the unix/windows username

flask_data.flag will be updated appropriately.

This returns 2 columns in a resultset:
status:
0 for success
1+ for error

message: may contain a displayable message.
*/
    declare vdata_source int default 17;#see ccgg.tag_data_sources
    declare vuserid int default -1;#see tag_securityAccess(), bypassing.
	declare v_status,v_numrows,v_range_num,rcount int default 0;#To pass to sp
	declare v_mssg,vcomment varchar(255) default '';
	
    #Fetch tag info for comment in flask_data.comment.  Skip if no user provided.  Some callers (ccg_flaskupdate2.py) do not supply
    if(v_username!='') then 
		set vcomment = (select concat(f_tag_userTimeStamp2(v_username)," Removed tag ",r.tag_num," (",t.internal_flag,").")
						from tag_ranges r join tag_view t on t.num=r.tag_num where r.num=v_tagrange_num);
		if ((select count(*) from tag_ranges where num=v_tagrange_num and tag_num=155)=1) then
			set vcomment='';
		end if;
	end if;
	drop temporary tables if exists t_data_nums,t_event_nums;
	create temporary table t_data_nums as select num from flask_data where 1=0;
	create temporary table t_event_nums as select num from flask_event where 1=0;
	insert t_data_nums select v_data_num;
	call tag_delFromTagRange(vuserid,v_tagrange_num,null,v_status,v_mssg,v_numrows); 
    if (v_status=0 and vcomment!='' ) then
		update flask_data set comment=case when comment='' then vcomment else concat(comment,' ',vcomment) end where num=v_data_num;
    end if;
    select v_status as status,v_mssg as message;#convienence for caller, send back in a resultset.
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tagwr_getFlaskDataTagList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tagwr_getFlaskDataTagList`(v_data_num int)
begin
/*
This procedure is a wrapper that returns a result set of all applicable tags that can be added to a flask data row 
plus any existing tags already applied.

It's a simplified interface to be called by external programs (python pydv).

Results are flask_data row specific and may change if program_num, parameter_num, strategy_num or project_num differs.

This returns 4 columns in a resultset:
tag_num - primary key of tag.  This can be used to pass to tag_addFlaskDataTag().
abbr - short text of the associated tag
description - long text of the associated tag
group_name - description of the tag type (collection issue, measurement issue...).  This can be used to group the results by type. 

Result set is pre-sorted.  Result set may include tags already associated with this flask_data row.
*/
#Find any tag ranges associated with data row.  
#Note we can't just call the tagwr_getFlaskDataTags() proc because it returns a result set (as does this one)
#and that confused the client rs parsing logic.  
drop temporary tables if exists t_range_nums,t_data_nums,t_event_nums,t_out;
create temporary table t_range_nums as select num from tag_ranges where 1=0;
create temporary table t_data_nums as select num from flask_data where 1=0;
create temporary table t_event_nums as select num from flask_event where 1=0;
insert t_data_nums select v_data_num;
call tag_getTagRanges();#Fills t_range_nums

#do a union to collect all applicable tags plus any already applied (like automated) that may not be in the list.
create temporary table t_out as #filter through another temp table so we can sort without outputting the sort col (not expected by client)
select t.num as tag_num, internal_flag as abbr, display_name as description, group_name, sort_order3 as sort_order
from flask_data_view d ,tag_view t 
where d.data_num=v_data_num 
	and (t.program_num=0 or t.program_num=d.program_num)
	and (t.parameter_num=0 or t.parameter_num=d.parameter_num)
	and (t.strategy_num=0 or t.strategy_num=d.strategy_num)
	and (t.project_num=0 or t.project_num=d.project_num)
	and t.automated=0 and t.deprecated=0
union
select t2.num as tag_num, t2.internal_flag as abbr, t2.display_name as description, t2.group_name, sort_order3 as sort_order
from t_range_nums rn join tag_ranges r on r.num=rn.num
		join tag_view t2 on t2.num=r.tag_num
order by sort_order
;

select tag_num, abbr, description, group_name from t_out order by sort_order;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tagwr_getFlaskDataTags` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tagwr_getFlaskDataTags`(v_data_num int)
begin
/*
This procedure is a wrapper that returns a result set of all applicable tags associated with v_data_num.

This returns 9 columns in a resultset:
range_num - id to identify associated tag_range.  This can be used by tag_delFlaskDataTag().
abbr - short text of the associated tag
description - long text of the associated tag
is_tag_range 0 - if tag is associated with flask_data row directly and therefor can be edited and deleted
			1 - if tag is part of a range (data tag range or event range) that must be edited in the data tagger web interface.

url - url that can be clicked to open the data tagger web app to this particular data_num.
tag_num - id number of associated tag.
tag_comment - comments associated with the tag
affected_rows - text describing number of affected measurements and samples
selection_criteria - describes selection criteria when appropriate.  May be blank ''
Results are pre-sorted.

Temporary table t_range_nums will be created and filled the range_nums of applicable tags.
*/
	drop temporary tables if exists t_range_nums,t_data_nums,t_event_nums, t_rangeCounts;
    create temporary table t_range_nums as select num from tag_ranges where 1=0;
	create temporary table t_data_nums as select num from flask_data where 1=0;
	create temporary table t_event_nums as select num from flask_event where 1=0;
    insert t_data_nums select v_data_num;
    call tag_getTagRanges();#get associated ranges into t_range_nums

    #Try 3.  See notes below re using cache.
    #we'll get counts for target ranges so we don't have to do whole table groupings below
    create temporary table t_rangeCounts as
		select r.num as range_num, count(e.event_num) as e_count, count(d.data_num) as d_count
		from t_range_nums r left join flask_data_tag_range d on d.range_num=r.num
			left join flask_event_tag_range e on e.range_num=r.num
		group by r.num;

    select rn.range_num, tv.internal_flag as abbr, tv.display_name as description,
		#is_tag_range true if event tag or attached to 2+ data_nums.  Then we want them to edit in the web app.
		case when rn.d_count=1 then 0 else 1 end as is_tag_range,
        concat("https://omi.cmdl.noaa.gov/dt/?data_num=",v_data_num,"&range_num=",rn.range_num) as url,
        r.tag_num,r.comment as tag_comment,
        concat("This ",case when tv.reject=1 then 'rejection' when tv.selection=1 then 'selection' when tv.information =1 then 'informational' end, ' tag is attached to ',
			case when rn.e_count=1 then '1 sample event' when rn.e_count>1 then concat(format(rn.e_count,0),' sample events')
				when rn.d_count=1 then '1 measurement' when rn.d_count>1 then concat(format(rn.d_count,0), ' measurements') end) as affected_rows,
        case when r.json_selection_criteria is not null and json_selection_criteria!='' then r.description else '' end as selection_criteria
    from t_rangeCounts rn join tag_ranges r on r.num=rn.range_num
		join tag_view tv on tv.num=r.tag_num
        ;
    /* This attempt caused locking issues with the range info cache when it needed to set cache rows (in dev db).  Not quite sure why, but has to do with the way the python program creates conns and does auto commit.
    Rewrote as above for now.  It'd be nice if it gave actual number.  May need to optimize for large ranges.  Probably wouldn't be an issue in prod because cache always exists
    but don't want to leave a random bug.
    #call tag_getTagRangeInfo();#get details on those ranges in t_range_info temp table (proc creates)

    select i.range_num, i.internal_flag as abbr, i.display_name as description,
		case when i.rowcount>1 then 1 else 0 end as is_tag_range,
        concat("https://omi.cmdl.noaa.gov/dt/?data_num=",v_data_num,"&range_num=",i.range_num) as url,
        i.tag_num,i.tag_comment,
        concat("This ",case when reject=1 then 'rejection' when selection=1 then 'selection' when information =1 then 'informational' end, ' tag is ', i.prettyRowCount) as affected_rows,
        case when i.json_selection_criteria is not null and json_selection_criteria!='' then i.tag_description else '' end as selection_criteria
    from t_range_info i
	order by i.sort_order;
    */

    /*old
    #Return rs with left join to flask_data_tag_range so can designate deletable ones
	select rn.num as range_num, tv.internal_flag as abbr, tv.display_name as description,
		case when dt.data_num is null then 1 else 0 end as event_tag,
        concat("https://omi.cmdl.noaa.gov/dt/?data_num=",v_data_num,"&range_num=",rn.num) as url,
        r.tag_num,r.comment as tag_comment
    from t_range_nums rn join tag_ranges r on r.num=rn.num
		join tag_view tv on tv.num=r.tag_num
        left join flask_data_tag_range dt on dt.range_num=rn.num and dt.data_num=v_data_num

	order by tv.sort_order
        ;
	*/

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tagwr_getFlaskDataTags2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tagwr_getFlaskDataTags2`(v_data_num int)
begin
/*
This procedure is a wrapper that returns a result set of all applicable tags associated with v_data_num.

This returns 9 columns in a resultset:
range_num - id to identify associated tag_range.  This can be used by tag_delFlaskDataTag().
abbr - short text of the associated tag
description - long text of the associated tag
is_tag_range 0 - if tag is associated with flask_data row directly and therefor can be edited and deleted
			1 - if tag is part of a range (data tag range or event range) that must be edited in the data tagger web interface.
            
url - url that can be clicked to open the data tagger web app to this particular data_num.
tag_num - id number of associated tag.
tag_comment - comments associated with the tag
affected_rows - text describing number of affected measurements and samples
selection_criteria - describes selection criteria when appropriate.  May be blank ''
Results are pre-sorted.

Temporary table t_range_nums will be created and filled the range_nums of applicable tags.
*/
	drop temporary tables if exists t_range_nums,t_data_nums,t_event_nums;
    create temporary table t_range_nums as select num from tag_ranges where 1=0;
	create temporary table t_data_nums as select num from flask_data where 1=0;
	create temporary table t_event_nums as select num from flask_event where 1=0;
    insert t_data_nums select v_data_num;
    call tag_getTagRanges();#get associated ranges
    select * from t_range_nums;
    call tag_getTagRangeInfo();#get details on those ranges in t_range_info temp table (proc creates)
    select 'asdfasdf';
    select i.range_num, i.internal_flag as abbr, i.display_name as description, 
		case when i.rowcount>1 then 1 else 0 end as is_tag_range, 
        concat("https://omi.cmdl.noaa.gov/dt/?data_num=",v_data_num,"&range_num=",i.range_num) as url,
        i.tag_num,i.tag_comment, 
        concat("This ",case when reject=1 then 'rejection' when selection=1 then 'selection' when information =1 then 'informational' end, ' tag is ', i.prettyRowCount) as affected_rows, 
        case when i.json_selection_criteria is not null and json_selection_criteria!='' then i.tag_description else '' end as selection_criteria
    from t_range_info i
	order by i.sort_order;
    /*old
    #Return rs with left join to flask_data_tag_range so can designate deletable ones
	select rn.num as range_num, tv.internal_flag as abbr, tv.display_name as description, 
		case when dt.data_num is null then 1 else 0 end as event_tag, 
        concat("https://omi.cmdl.noaa.gov/dt/?data_num=",v_data_num,"&range_num=",rn.num) as url,
        r.tag_num,r.comment as tag_comment
    from t_range_nums rn join tag_ranges r on r.num=rn.num
		join tag_view tv on tv.num=r.tag_num
        left join flask_data_tag_range dt on dt.range_num=rn.num and dt.data_num=v_data_num
        
	order by tv.sort_order
        ;
	*/
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`140.172.193.%` PROCEDURE `tag_`(v_userid int, out v_status int,out v_mssg varchar(255),out v_numrows int)
begin

	declare flagsUpdated int default 0;
	set v_status=0,v_mssg='',v_numrows=0;
	call tag_securityAccess(v_userid,1,v_status,v_mssg);
	if (v_status=0) then 	

		
	
		
		call tag_updateFlagsFromTags(flagsUpdated);
		if(flagsUpdated>0)then
			set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
				case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
		end if;
		
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addConversionTagsByDataNum` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addConversionTagsByDataNum`(v_data_num int, v_tag_num int, v_flag char(3), v_comment varchar(2048))
begin
	/*Utility function to assist flags to tags conversions.  This adds tags based on unique data_num -> tag mappings.
		Unique combos written to spreadsheet, worked on by PIs and Molly, I turn into procedure calls.
    */
	declare vstatus,v_update,vnumrows, vrange_num int default 0;
	declare vmssg varchar(255) default '';

    drop temporary table if exists t_data_nums,t_event_nums;

	###
	set v_update=1;
	###
    if (v_update=0 or v_tag_num>0) then #skip 0 tags (no op when in production mode to speed up.  no need to record them.
		#for sp
		create temporary table t_data_nums as select num from flask_data where 1=0;
		create temporary table t_event_nums as select num from flask_event where 1=0;

		#fill targets
		insert t_data_nums select v_data_num;
		if(v_update=0)then
			#Put into a work table so we can track which ones have been handled.
			insert mund_dev.`tag_conversion_work_table` select t.num,v_tag_num, v_flag, v_comment from t_data_nums t;
				/*select d.event_num, d.data_num, d.site, d.project, d.strategy, d.parameter, d.flag, d.comment, (select display_name from tag_view where num=v_tag_num) as tag
				from flask_data_view d join t_data_nums t on d.data_num=t.num;*/
		else #still use the wrapper so they get logged.
			call tag_addConversionTags_createWrapper(v_tag_num,v_flag,'');
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addConversionTagsByFlagComment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addConversionTagsByFlagComment`(v_project_num int, v_strategy_num int, v_program_num int, v_parameter_num int, v_tag_num int, v_flag char(3), v_comment varchar(2048))
begin
	/*Utility function to assist flags to tags conversions.  This adds tags based on unique flag/comment -> tag mappings.
		Unique combos written to spreadsheet, worked on by PIs and Molly, I turn into procedure calls.
        v_parameter_num can be 0 for wildcard
    */
	declare vstatus,v_update, vnumrows, vrange_num int default 0;
	declare vmssg varchar(255) default '';
	drop temporary table if exists t_data_nums,t_event_nums;
	###
	set v_update=1;
	###
    if (v_update=0 or v_tag_num>0) then #skip 0 tags (no op when in production mode to speed up.  no need to record them.
		#for sp
		create temporary table t_data_nums as select num from flask_data where 1=0;
		create temporary table t_event_nums as select num from flask_event where 1=0;

		#fill targets
		insert t_data_nums
			select distinct data_num from flask_data_view v
			where project_num=v_project_num and strategy_num=v_strategy_num and program_num=v_program_num and (v_parameter_num=0 or parameter_num=v_parameter_num)
				and flag=v_flag and comment=v_comment
				and v.update_flag_from_tags=0 and flag not like '...'
				#and not exists(select * from flask_data_tag_range dt join tag_ranges r on dt.range_num=r.num where r.tag_num=v_tag_num and dt.data_num=v.data_num )
				;

		#call sp or log in work table
		if(v_update=0)then
			#Put into a work table so we can track which ones have been handled.
			insert mund_dev.`tag_conversion_work_table` select t.num,v_tag_num, v_flag, v_comment from t_data_nums t;
				/*select d.event_num, d.data_num, d.site, d.project, d.strategy, d.parameter, d.flag, d.comment, (select display_name from tag_view where num=v_tag_num) as tag
				from flask_data_view d join t_data_nums t on d.data_num=t.num;*/
		else
			call tag_addConversionTags_createWrapper(v_tag_num,v_flag,'');
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addConversionTagsByFlagComment2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addConversionTagsByFlagComment2`(v_project_num int, v_strategy_num int, v_program_num int, v_parameter_num int, v_tag_num int, v_flag char(3), v_comment varchar(2048),v_newTagComment varchar(2048))
begin
	/*Utility function to assist flags to tags conversions.  This adds tags based on unique flag/comment -> tag mappings.
		Unique combos written to spreadsheet, worked on by PIs and Molly, I turn into procedure calls.
        v_parameter_num can be 0 for wildcard.
        can pass new tag comment or use default (pass '').  I made this a v2 because you can't create optional parameters and i didn't want to redo spreadsheets that already had param count in them.
    */
	declare vstatus,v_update, vnumrows, vrange_num int default 0;
	declare vmssg varchar(255) default '';
	drop temporary table if exists t_data_nums,t_event_nums;
	###
	set v_update=1;
	###
    if (v_update=0 or v_tag_num>0) then #skip 0 tags (no op when in production mode to speed up.  no need to record them.
		#for sp
		create temporary table t_data_nums as select num from flask_data where 1=0;
		create temporary table t_event_nums as select num from flask_event where 1=0;

		#fill targets
		insert t_data_nums
			select distinct data_num from flask_data_view v
			where project_num=v_project_num and strategy_num=v_strategy_num and program_num=v_program_num and (v_parameter_num=0 or parameter_num=v_parameter_num)
				and flag=v_flag and comment=v_comment
				and v.update_flag_from_tags=0 and flag not like '...'
				#and not exists(select * from flask_data_tag_range dt join tag_ranges r on dt.range_num=r.num where r.tag_num=v_tag_num and dt.data_num=v.data_num )
				;

		#call sp or log in work table
		if(v_update=0)then
			#Put into a work table so we can track which ones have been handled.
			insert mund_dev.`tag_conversion_work_table` select t.num,v_tag_num, v_flag, v_comment from t_data_nums t;
				/*select d.event_num, d.data_num, d.site, d.project, d.strategy, d.parameter, d.flag, d.comment, (select display_name from tag_view where num=v_tag_num) as tag
				from flask_data_view d join t_data_nums t on d.data_num=t.num;*/
		else
			call tag_addConversionTags_createWrapper(v_tag_num,v_flag,v_newTagComment);
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addConversionTagsByNEVFlagComment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addConversionTagsByNEVFlagComment`(v_project_num int, v_strategy_num int, v_program_num int, v_parameter_num int, v_tag_num int, v_flag char(3), v_comment varchar(2048), v_tag_comment varchar(2048))
begin
	/*Utility function to assist flags to tags conversions.  This adds tags based on unique flag/comment -> tag mappings for rows with a middle col N(162) tag already applied.
		Unique combos written to spreadsheet, worked on by PIs and Molly, I turn into procedure calls.
    */
	declare vupdated,v_update int default 0;
	declare vstatus, vnumrows, vrange_num int default 0;
	declare vmssg varchar(255) default '';
	drop temporary table if exists t_data_nums,t_event_nums;
	###
	 set v_update=1;
	if (v_update=0 or v_tag_num>0) then #skip 0 tags (no op when in production mode to speed up.  no need to record them.

		create temporary table t_data_nums as select num from flask_data where 1=0;
		create temporary table t_event_nums as select num from flask_event where 1=0;

		#fill targets
		insert t_data_nums
			select distinct data_num from flask_data_view v join flask_event_tag_range e on v.event_num=e.event_num join tag_ranges r on r.num=e.range_num
			where project_num=v_project_num and strategy_num=v_strategy_num and program_num=v_program_num and (v_parameter_num=0 or parameter_num=v_parameter_num)
				and flag=v_flag and v.comment=v_comment and
				r.tag_num=162 and r.comment=v_tag_comment
				and v.update_flag_from_tags=0
				#and not exists(select * from flask_data_tag_range dt join tag_ranges r on dt.range_num=r.num where r.tag_num=v_tag_num and dt.data_num=v.data_num )
				#and not exists(select * from flask_event_tag_range et join tag_ranges r on et.range_num=r.num where v.event_num=et.event_num and r.tag_num=v_tag_num)
			;
		#call sp or log in work table
		if(v_update=0)then
			#Put into a work table so we can track which ones have been handled.
			insert mund_dev.`tag_conversion_work_table2` select t.num,v_tag_num, v_flag, v_comment,v_tag_comment from t_data_nums t;
				/*select d.event_num, d.data_num, d.site, d.project, d.strategy, d.parameter, d.flag, d.comment, (select display_name from tag_view where num=v_tag_num) as tag
				from flask_data_view d join t_data_nums t on d.data_num=t.num;*/
		else
			call tag_addConversionTags_createWrapper(v_tag_num,v_flag,'');
		end if;

	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addConversionTags_createWrapper` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addConversionTags_createWrapper`(v_tag_num int,v_flag char(3), v_tagcomment varchar(255))
begin
	#takes rows in t_data_nums and creates single row tags for each.
    declare done int default false;
    ####
    declare vtest int default 0;
    ####
    declare vdata_num int default 0;
	declare vstatus, vnumrows, vrange_num int default 0;
	declare vmssg varchar(255) default '';
	declare acur cursor for select distinct num from t__d;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    drop temporary table if exists t__d ;
    create temporary table t__d as select * from t_data_nums;
    delete from t_data_nums;
    delete from t_event_nums;#just in case.

    if (v_tagcomment='') then set v_tagcomment='Tag added during flag to tag conversion'; end if;

    open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vdata_num;
		if (done=true) then LEAVE read_loop; end if;
        delete from t_data_nums;
        insert t_data_nums select vdata_num;
        call tag_createTagRange(60,v_tag_num,v_tagcomment,0,null,21, null, vstatus,vmssg,vnumrows,vrange_num); #we don't really care about the status.  we'll check afterwards
        insert mund_dev.tag_conversions select vdata_num, v_tag_num, vstatus, vnumrows, now(),vmssg,v_flag,vtest;#log it
	END LOOP;
	close acur;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addFlaskDataTag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addFlaskDataTag`(v_data_num int,v_tag_num int, out v_status int,out v_mssg varchar(255))
begin
/*
This procedure is a wrapper that creates a new tag range for the passed flask_data.num (v_data_num).  It's
a simplified interface to be called by external programs (python pydv)

flask_data.flag will be updated appropriately.

This returns in status:
-1 for tag already exists, no action taken
0 for success
1+ for error

v_message may contain a displayable message.
*/
    declare vdata_source int default 17;#see ccgg.tag_data_sources
    declare vuserid int default -1;#see tag_securityAccess(), bypassing.
	declare v_numrows,v_range_num,rcount int default 0;#To pass to sp
	set v_status=0,v_mssg='';
	
	if((select count(*) from tag_dictionary where num=v_tag_num)=0) then
		set v_status=2,v_mssg=concat("Error: Invalid tag id (",v_tag_num,")");
	else 
		#See if any ranges with passed tag num already exist for passed ids.			
		set rcount=(select count(distinct v.range_num) from flask_data_tag_view v where v.data_num=v_data_num and v.tag_num=v_tag_num);
		if(rcount>0)then
			set v_status=-1, v_mssg='Data row already has tag associated.';
		else
			drop temporary tables if exists t_data_nums,t_event_nums;
			create temporary table t_data_nums as select num from flask_data where 1=0;
			create temporary table t_event_nums as select num from flask_event where 1=0;
			insert t_data_nums select v_data_num;
			call tag_createTagRange(vuserid,v_tag_num, '',0,'',vdata_source,'',v_status,v_mssg,v_numrows,v_range_num); 	
		end if;#tag already exists	
	end if;#valid tag_num
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addToOpenEndedRanges` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addToOpenEndedRanges`(out v_numrows int,out v_status int, out v_mssg varchar(255))
begin
	declare done int default false;
	declare processDateTime datetime default now();#We'll process any new data up through this datetime.  This is then used
		#as the last_processed datetime which defines new data.
	declare lastProcessedDateTime datetime;
	declare flagsUpdated,dataNum,tagNum,rangeNum,c,totalCount int default 0;
	declare vUserID int default -1;#System user
	declare vExcludeProgram int default -1; #We used to exclude HATS data, but are now including because users have been tagging data in ccgg datatagger
	declare mssg text default '';

	#cursors that we'll need below.
	declare cur1 cursor for select distinct d.data_num,d.tag_num from t__data_tags d;
	declare cur2 cursor for select distinct range_num from t__data_ranges;
	declare cur3 cursor for select distinct range_num from t__data_ranges;#Not sure if this needs to be separate, but doesn't hurt.
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	set v_mssg='No Changes.', v_status=0, v_numrows=0;

	#Fetch the datetime of the last time this was called.
	select min(last_processed_datetime) into lastProcessedDateTime 
	from tag_range_openended_criteria where range_num=0;
	
    /*jwm -8/24.  Removing this.  Now that most converted to tags, there aren't good reasons to disallow this*/
    #We no longer allow wild card reprocess because it may overwrite user entries to flask data rows with event tags
    #sanity check the dates and adjust arbitrarily if needed.  We'll use an arbitrary 1 week window (in case servers were down
    # for maint or something);
    #if(lastProcessedDateTime<date_add(processDateTime, interval -1 week)) then 
    #if(lastProcessedDateTime<date_add(processDateTime, interval -4 week)) then ###temp override
	#	set mssg=concat(mssg," ","UNEXPECTED VALUE FOR lastProcessedDateTime (",lastProcessedDateTime,").  RESETTING TO -1 DAY FROM now()");
	#	set lastProcessedDateTime=date_add(processDateTime, interval -1 day);
	#end if;
	
    
	#Temp tables for stored procs.
	drop temporary table if exists t_data_nums,t_event_nums,t__data_tags,t__targ_nums,t__data_ranges;
	create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0;
	create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0;
	create temporary table t__targ_nums (index(data_num)) as select num as data_num, event_num, update_flag_from_tags from flask_data where 1=0;
	create temporary table t__data_tags (index(data_num)) as select num as data_num,num as tag_num from flask_data where 1=0;
	create temporary table t__data_ranges (index(data_num)) as select num as data_num,event_num,num as range_num from flask_data where 1=0;

	/*We'll process 3 types of new data:
		-new measurements that belong to an event with one or more defined tags.
			->these get their flags updated.
		-new data rows that match an open ended tag range
			->gets added to the tag_range(s)
		-new data events that match an open ended flask_event tag range
			->get added to the tag_range if needed.
	*/

	#Fill our target ids table.  We use a temp table just to make queries below easier.  This is only needed
	#to handle case when we want to process whole table (either initial update or occasional sanity check).
	#Skip hats data as it is sync by other logic.
	if (lastProcessedDateTime is null) then #slow...
		insert t__targ_nums select num, event_num, update_flag_from_tags from flask_data where program_num!=vExcludeProgram;
	else
		insert t__targ_nums select num, event_num, update_flag_from_tags from flask_data
		where creation_datetime>=lastProcessedDateTime and creation_datetime<processDateTime
			and program_num!=vExcludeProgram;
	end if;

	#####
	#Event Tags
	#####

	#Process event tags.  All new measurements for tagged events need to get their external flag updated.
	delete from t_data_nums;  #Tag data rows are easier.
	insert t_data_nums select distinct d.data_num 
		from t__targ_nums d join flask_event_tag_range t on d.event_num=t.event_num
		where d.update_flag_from_tags=1;
	#Update the external flag
	call tag_updateFlagsFromTags(flagsUpdated);
	if(flagsUpdated>0) then set mssg=concat(mssg," ",flagsUpdated," tagging system row(s) updated with event tag.  ");end if;
	
	#For non tagging rows, we'll cycle through the list and add tags to the external flag as needed
	#We can't do it all at once in a set op because we need to apply each tag to the ext flag one at a time
	#so that they build up (and because that's how the conversion logic works).
	delete from t__data_tags;
	insert t__data_tags select distinct d.data_num, t.tag_num 
		from t__targ_nums d join flask_event_tag_view t on d.event_num=t.event_num
		where d.update_flag_from_tags=0;
	set c=row_count();
	#Loop through each range and add. Cursor rolls through above temp table.	
	if(c>0) then
		open cur1; set done=false, c=0;
		read_loop: LOOP
			fetch cur1 into dataNum,tagNum;
			if (done=true or dataNum is null) then	LEAVE read_loop; end if;
			#Apply this one tag. Function below merges with any existing flag gracefully.
			update flask_data set flag=f_oldstyle_external_flag(num,0,tagNum) 
				where num=dataNum and update_flag_from_tags=0 limit 1;#Don't really need the limit
			set c=c+row_count();
		END LOOP;
		close cur1;	
		if(c>0) then 
			select count(distinct data_num) into c from t__data_tags;
			set flagsUpdated=flagsUpdated+c, mssg=concat(mssg,"  ",c," non-tagging system row(s) updated with event tag.  ");end if;
	end if;
	
	#####
	#New flask_data rows to existing data range.
	#####
	
	#Add new flask_data rows to existing ranges as applicable.  We use the 
	#tag_range_openended_criteria defined criteria to add to an existing range
	delete from t__data_ranges;
	insert t__data_ranges select distinct d.data_num,0, t.range_num
		from t__targ_nums d join flask_ev_data_view v on d.data_num=v.data_num #Join to get ev/data params
			join tag_range_openended_criteria t	on( #match all criteria
				(t.program_num=0 or t.program_num=v.program_num) and 
				(t.parameter_num=0 or t.parameter_num=v.parameter_num) and 
				(t.parameter_num>0 or t.program_num>0) and #Ensure this is a data_tag

				(t.site_num=0 or t.site_num=v.site_num) and 
				(t.project_num=0 or t.project_num=v.project_num) and 
				(t.strategy_num=0 or t.strategy_num=v.strategy_num) and 
                (t.method='' or t.method=v.method) and 
				(t.ev_s_datetime is null or (v.ev_date>=date(t.ev_s_datetime) and 
					v.ev_datetime>=t.ev_s_datetime)) and #Mimics logic in datatagger code (lib/funcs.php->buildQueryBase()).  See that for comments
				(t.ev_e_datetime is null or (v.ev_date<=date(t.ev_e_datetime) and #Ditto.  treat null time as end of day.
					timestamp(v.ev_date,case when time(t.ev_e_datetime)='00:00:00' then '00:00:00' else v.ev_time end)<=t.ev_e_datetime))
			)
			join tag_ranges r on r.num=t.range_num #valid range
			#left join to existing tag ranges for any not there.
			left join flask_data_tag_view tv on (t.range_num=tv.range_num and tv.data_num=d.data_num)
		where tv.data_num is null;
	set c=row_count();
    #select * from t__data_ranges;
	#Loop through each range and add new member(s). 	
	if(c>0) then
		open cur2; set done=false; delete from t_event_nums;
		read_loop2: LOOP
			fetch cur2 into rangeNum;
			if (done=true or rangeNum is null or v_status>0) then	LEAVE read_loop2; end if;
			#Add all data rows for this range (may only be 1)
			delete from t_data_nums;
			insert t_data_nums select distinct data_num from t__data_ranges where range_num=rangeNum;
			call tag_addToTagRange(vUserID,rangeNum,null,v_status,v_mssg,v_numrows);
			#Update the lastProcessedDate and count.. note that we update all matching rows with range_num (multi params), so these values are for the whole range, not the parameter specific row.
			if(v_status=0)then update tag_range_openended_criteria set last_processed_datetime=processDateTime,tot_rows_processed=tot_rows_processed+v_numrows where range_num=rangeNum;end if;#This is just for stats/diag
		END LOOP;
		close cur2;	
		if(v_status>0) then 
			set mssg=concat(mssg,' Error(',v_status,') adding data rows to new range: ',v_mssg,'. ProccessTime:',processDateTime,' LastProcessedTime:',lastProcessedDateTime,' Range_num: ',rangeNum);  
		else 
			set totalCount=totalCount+c, mssg=concat(mssg,"  ",c," flask_data row(s) added to existing tag range. ");
			#Update the criteria row count showing how many have been added.  This is just for curiosity.			
		end if;
	end if;



	#####
	#New flask_event rows to existing range.
	#####
	if(v_status=0) then 
		#Add new flask_event rows to existing ranges as applicable.  We use the 
		#tag_range_openended_criteria defined criteria to add to an existing range
		delete from t__data_ranges;
		insert t__data_ranges select distinct 0,d.event_num, t.range_num
			from t__targ_nums d join flask_ev_data_view v on d.data_num=v.data_num #Join to get ev/data params
				join tag_range_openended_criteria t	on( #match all criteria
					(t.parameter_num=0 and t.program_num=0) and #Ensure this is an event_tag
					
					(t.site_num=0 or t.site_num=v.site_num) and 
					(t.project_num=0 or t.project_num=v.project_num) and 
					(t.strategy_num=0 or t.strategy_num=v.strategy_num) and 
                    (t.method='' or t.method=v.method) and
					(t.ev_s_datetime is null or (v.ev_date>=date(t.ev_s_datetime) and 
						v.ev_datetime>=t.ev_s_datetime)) and #Mimics logic in datatagger code (lib/funcs.php->buildQueryBase()).  See that for comments
					(t.ev_e_datetime is null or (v.ev_date<=date(t.ev_e_datetime) and #Ditto.  treat null time as end of day.
						timestamp(v.ev_date,case when time(t.ev_e_datetime)='00:00:00' then '00:00:00' else v.ev_time end)<=t.ev_e_datetime))
				)
				join tag_ranges r on r.num=t.range_num #valid range
				#left join to existing tag ranges for any not there.
				left join flask_event_tag_view tv on (t.range_num=tv.range_num and tv.event_num=d.event_num)
			where tv.event_num is null;
		set c=row_count();

		#Loop through each range and add new member(s). 	
		if(c>0) then
			delete from t_data_nums;#clear from above.
			open cur3; set done=false;
			read_loop3: LOOP
				fetch cur3 into rangeNum;
				if (done=true or rangeNum is null or v_status>0) then	LEAVE read_loop3; end if;
				#Add all event rows for this range (may only be 1)
				delete from t_event_nums;
				insert t_event_nums select distinct event_num from t__data_ranges where range_num=rangeNum;
				call tag_addToTagRange(vUserID,rangeNum,null,v_status,v_mssg,v_numrows);
				if(v_status=0)then update tag_range_openended_criteria set last_processed_datetime=processDateTime,tot_rows_processed=tot_rows_processed+v_numrows where range_num=rangeNum;end if;#This is just for stats/diag
			END LOOP;
			close cur3;	
			if(v_status>0) then 
				set mssg=concat(mssg,' Error(',v_status,') adding event rows to new range: ',v_mssg,'. ProccessTime:',processDateTime,' LastProcessedTime:',lastProcessedDateTime,' Range_num: ',rangeNum);  
			else 
				set totalCount=totalCount+c, mssg=concat(mssg,"  ",c," flask_event row(s) added to existing tag range. ");
			end if;
			
		end if;
	end if;
	if(v_status=0) then 
		#set the last processed time into the filters table so we know where to pick up from next time.  Skip on error until resolved.
		insert into tag_range_openended_criteria (range_num,last_processed_datetime, tot_rows_processed)
			values (0,processDateTime,totalCount) 
		on duplicate key 
			update last_processed_datetime=processDateTime, tot_rows_processed=tot_rows_processed+totalCount;
	end if;

	#set output variables
	set v_mssg=case when mssg!='' then mssg else v_mssg end, v_numrows=totalCount+flagsUpdated;

	#clean up
	drop temporary table if exists t_data_nums,t_event_nums,t__data_tags,t__targ_nums,t__data_ranges;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_addToTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_addToTagRange`(v_userid int,v_range_num int,v_json_selection_criteria text,out v_status int,out v_mssg varchar(255),out v_numrows int )
begin
/*
Add all target ids to the passed v_range_num.  This ignores nums that already belong to the range.

This will update the external flag of any applicable flask_data row configured to update flag from tags

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0;
create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0;

v_userid is ccgg.contact num column.
SEE BELOW:v_json_selection_criteria is a json hash array of the selection criteria for use by the php front end.  This should be
passed null from any other front end unless cooridinated with the php logic.

This returns in status:
0 for success
1 for access error.
2 if range does not exist.
3 for other error.

v_message may contain a displayable message.

v_numrows will contain the number of inserted rows.

NOTE; this should also update v_description (json selection description).  I just noticed it's not doing that, but it just
happens that the only caller(tag_syncHatsTags) using this only sets json to null (web app uses tag_updateTagRangeMembers) and so it's
not needed as the description/json is only applicable in the web app.  If web app calls this, it should be reprogrammed
to update description too.
NOTE; 2nd caller (tag_addToOpenEndedRanges) is now calling this too, but it doesn't change the selection or description.
I am deprecating the v_json_selection_criteria parameter.  It is no longer used in this procedure to avoid confusion.
Web app (which uses both) should only use tag_updateTagRangeMembers.  This method is now for callers that
don't use those fields or do not want them changed.
*/
	declare flagsUpdated,r_count,v_tag_num int default 0;
	set v_status=1,v_mssg='',v_numrows=0;
	call tag_securityAccess(v_userid,1,v_status,v_mssg);
	if (v_status=0) then

		if((select count(*) from tag_ranges where num=v_range_num)=0) then
			set v_status=2,v_mssg='This range does not exist';
		else
			#Do a reality check to make sure we don't insert data rows into an event range and versa
			if(
				((select count(*) from t_data_nums)>0 and (select count(*) from flask_event_tag_range where range_num=v_range_num)>0)
					or
				((select count(*) from t_event_nums)>0 and (select count(*) from flask_data_tag_range where range_num=v_range_num)>0)
			) then
				set v_status=3,v_mssg="Error: can't assign a tag for both flask_data and flask_event rows";
			else
				#Insert using the on dup update syntax with a noop update so that we can get an accurate count (as opposed to replace syntax)
				insert flask_data_tag_range (data_num,range_num)
					select num,v_range_num from t_data_nums
					on duplicate key update range_num=v_range_num;
					set v_numrows=row_count();

				insert flask_event_tag_range (event_num,range_num)
					select num,v_range_num from t_event_nums
					on duplicate key update range_num=v_range_num;
					set v_numrows=v_numrows+row_count();

				set v_mssg= concat(v_numrows,case when v_numrows = 1 then ' row' else ' rows' end,' inserted');

				#update the range selection criteria with passed json array (or null to erase).
				#deprecated. see comments above.
				#update tag_ranges set json_selection_criteria=v_json_selection_criteria where num=v_range_num;

				#update any flask_data rows configured to update external flag from tags.
				call tag_updateFlagsFromTags(flagsUpdated);
				if(flagsUpdated>0)then
					set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
						case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
				end if;

				#update any flask data rows not configure to update external flag from tags using oldstyle
				select tag_num into v_tag_num from tag_ranges where num=v_range_num;
				call tag_updateOldStyleFlags(0,v_tag_num,r_count,v_mssg);

				#Update the range info cache
				drop temporary table if exists t_range_nums;
				create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0;
				insert t_range_nums select v_range_num;
				call tag_setTagRangeInfoCache();
				drop temporary table t_range_nums;

			end if;#ev/data mix check
		end if;#range exists
	end if;#sec check
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_appendTagComment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_appendTagComment`(v_userid int,v_range_num int, v_comment text, out v_status int,out v_mssg varchar(255),out v_numrows int)
begin
/*
This is a procedure to append a comment to an existing tag range.  It requires 'insert' access.

v_userid is ccgg.contact num column.  If -2 (automated process), we just pass through v_comment without adding timestamp.

This returns in status:
0 for success
1 for access error.
2 for call error (incorrect params).
3 for other error.

v_message may contain a displayable message.

v_numrows will contain the number of affected rows.
*/
	set v_status=0,v_mssg='',v_numrows=0;
	if(v_range_num is null or (select count(*) from tag_ranges where num=v_range_num)=0) then
		set v_status=2,v_mssg="a valid v_range_num is a required parameter";
	else
		if(v_comment is null)then
			set v_status=2, v_mssg="v_comment required.";
		else
			#Create and populate temp tables sec access proc is expecting
			drop temporary table if exists t_data_nums,t_event_nums;
			create temporary table t_data_nums as select num from flask_data where 1=0;
			create temporary table t_event_nums as select num from flask_event where 1=0;
			insert t_data_nums select data_num from flask_data_tag_range where range_num=v_range_num;
			insert t_event_nums select event_num from flask_event_tag_range where range_num=v_range_num;


			call tag_securityAccess(v_userid,2,v_status,v_mssg);
			if (v_status=0) then
				#Do update. #(note syntax flagger chokes on below for some reason.)
                if(v_userid=-2) then
					update tag_ranges set comment=concat_ws("\n",comment,v_comment) where num=v_range_num;
				else
					update tag_ranges set comment=concat_ws("\n",comment,concat(f_tag_userTimeStamp(v_userid),v_comment)) where num=v_range_num;
				end if;
				set v_numrows=row_count();
				if(v_numrows>0)then
					set v_mssg='Tag comment successfully updated.';
				else
					set v_mssg='No changes';
				end if;

			end if;#sec access
		end if;#parameter check
	end if;#range num check
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_convertDataSetToTagSystem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_convertDataSetToTagSystem`(v_userid int, v_comment varchar(255),v_update int,
	v_project_num int, v_program_num int, v_strategy_num int, v_parameter_num int, v_site_num int,
	out v_mssg varchar(255),out v_numrows int)
begin
/*
This is a utility procedure to convert a dataset to the tagging system.
Pass zero for wild card for the five conditionals.  This will update existing rows (clobbering
old flag!!!), and set new rows to be on tag system.
v_update=0 for info, 1 to do it, 2 to override errors finding tags for some rows.
!!Be careful with 2, it will wipe unconvertables!!  It won't set any tags on those rows
It should only be used by John.
*/
declare stat int default 0;
declare msg varchar(255) default '';
declare tag1 int;
declare tag2 int;
declare tag3 int;
declare rn int;
declare nr int;
declare n int;
declare t int;
DECLARE done INT DEFAULT FALSE;
declare cur cursor for select num from t_data_nums;
declare cur2 cursor for select data_num,tag_num from t_new_tags;
declare continue handler for not found set done = true;

if(v_userid=60) then
	#target rows
	drop temporary table if exists t_data_nums;
	create temporary table t_data_nums
		select data_num as num from flask_data_view
		where (project_num=v_project_num or v_project_num=0)
			and (program_num=v_program_num or v_program_num=0)
			and (strategy_num=v_strategy_num or v_strategy_num=0)
			and (parameter_num=v_parameter_num or v_parameter_num=0)
			and (site_num=v_site_num or v_site_num=0) ;

	#find info to convert flag to tags
	drop temporary table if exists t_new_tags, t_unconvertables;
	create temporary table t_new_tags as select data_num,tag_num from flask_data_tag_view where 1=0;
	create temporary table t_unconvertables as select num,comment as mssg from flask_data where 1=0;

	open cur;
	read_loop: LOOP
		fetch cur into n;
		if done then
			leave read_loop;
		end if;
		#skip rows already converted (if any)
		if((select count(*) from flask_data where update_flag_from_tags=1 and num=n)=0) then
			call tag_findTagsFromFlag(n,'',stat,msg,tag1,tag2,tag3);
			if(stat=1) then #error
				insert t_unconvertables select n,msg;
			else
				if(tag1>0) then insert t_new_tags select n,tag1; end if;
				if(tag2>0) then insert t_new_tags select n,tag2; end if;
				if(tag3>0) then insert t_new_tags select n,tag3; end if;
			end if;
		end if;
	end LOOP;
	close cur;
	if((select count(*) from t_unconvertables)>0 and v_update<2 and v_update>0) then
		select * from t_unconvertables;
	else
		if (v_update>0) then
			delete from t_unconvertables;#clear so we can detect new errors.
			#insert any new tags needed.
			#This one created above.create temporary table t_data_nums as select num from flask_data where 1=0;
			#Unfortunate naming clash, make a copy of target rows so we can reuse t_data_nums
			drop temporary table if exists t__data_nums,t_event_nums;
			create temporary table t__data_nums as select * from t_data_nums;
			create temporary table t_event_nums as select num from flask_event where 1=0;
			set done = false;
			open cur2;
			read_loop2: LOOP
				fetch cur2 into n,t;
				if done then
					leave read_loop2;
				end if;
				delete from t_data_nums;
				insert t_data_nums select n;
				call tag_createTagRange(v_userid,t,v_comment,0,null,10,'Automated conversion to tagging system',stat,msg,nr,rn);
				if(stat>0) then insert t_unconvertables select n,msg; end if;
			end LOOP;
			close cur2;
			delete from t_data_nums;
			insert t_data_nums select * from t__data_nums;#repopulate master target rows.
			if((select count(*) from t_unconvertables)>0 and v_update<3) then
				select * from t_unconvertables;
			else
				call tag_convertRowsToTagSystem(v_userid,v_comment,1,v_mssg,v_numrows);
				#if(v_numrows>0)then
					replace autoupdateable_data_flags (project_num,program_num,strategy_num,parameter_num,site_num)
					select v_project_num,v_program_num,v_strategy_num,v_parameter_num,v_site_num;
				#end if;
			end if;

		else
			select count(*)  as 'total num rows' from t_data_nums;
			select count(*)  as 'num rows to convert' from t_data_nums t, flask_data d where d.num=t.num and d.update_flag_from_tags=0;
			select count(*) as 'total new tags to insert' from t_new_tags;
			select distinct program,project,strategy,site from flask_data_view v, t_data_nums t where t.num=v.data_num;
			select d.num as data_num,d.flag as 'existing flag',tv.internal_flag as 'new tag'
				from t_new_tags t, flask_data d, tag_view tv
				where t.data_num=d.num and t.tag_num=tv.num
				order by d.num;
			select * from t_unconvertables;
			select group_concat(num),mssg,count(*) from t_unconvertables group by mssg;
			#select * from flask_data_view v, t_data_nums t where v.data_num=t.num;
			#select v.data_num,v.flag as flag_missing_tags  from flask_data_view v, t_data_nums t
			#where v.data_num=t.num and v.update_flag_from_tag=0
			#	and f_external_flag(v.data_num)='...' and v.flag!='...';
		end if;
	end if;
end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_convertDataSetToTagSystem2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_convertDataSetToTagSystem2`(v_userid int, v_comment varchar(255),v_update int,
	v_project_num int, v_program_num int, v_strategy_num int, v_parameter_num int, v_site_num int,
	out v_mssg varchar(255),out v_numrows int)
begin
	/*THIS DOES NOT ADD ANY TAGS!!
    Similar to below, but assumes all tags have already been added appropriately for selected dataset.

    */
    if(v_userid=60) then
		drop temporary table if exists t_data_nums;
		create temporary table t_data_nums
			select data_num as num from flask_data_view
			where (project_num=v_project_num or v_project_num=0)
				and (program_num=v_program_num or v_program_num=0)
				and (strategy_num=v_strategy_num or v_strategy_num=0)
				and (parameter_num=v_parameter_num or v_parameter_num=0)
				and (site_num=v_site_num or v_site_num=0) ;
			if(v_update>0) then
				call tag_convertRowsToTagSystem(v_userid,v_comment,1,v_mssg,v_numrows);#applies tags to the external flag and sets to 1 tagging row.
                #Note may wipe t_data_nums
				replace autoupdateable_data_flags (project_num,program_num,strategy_num,parameter_num,site_num)#sets new rows to be auto converted
					select v_project_num,v_program_num,v_strategy_num,v_parameter_num,v_site_num;
			else
				select count(*)  as 'total num rows' from t_data_nums;
				select count(*)  as 'num rows to convert' from t_data_nums t, flask_data d where d.num=t.num and d.update_flag_from_tags=0;
				select distinct program,project,strategy,site,parameter from flask_data_view v, t_data_nums t where t.num=v.data_num;
            end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_convertRowsToTagSystem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_convertRowsToTagSystem`(v_userid int, v_comment varchar(255),v_update int,out v_mssg varchar(255),out v_numrows int)
begin
/*
This is a utility procedure to convert rows to the tagging system.
It should only be used by John.
create temporary table t_data_nums as select num from flask_data where 1=0
*/
	declare flagsUpdated int default 0;
	declare t1 int;
	declare t2 int;
	declare t3 int;
	set v_mssg='',v_numrows=0;
	if(v_userid=60) then
		if(v_update=1) then
			#Save a copy of the flag.
			replace tag_conversion_history(data_num,old_flag,comment)
			select d.num,d.flag,v_comment from flask_data d, t_data_nums t
			where d.num=t.num and d.update_flag_from_tags=0;
			#update the bit
			update flask_data d, t_data_nums t set d.update_flag_from_tags=1, d.flag='...'
			where d.num=t.num and d.update_flag_from_tags=0;
			set v_numrows=row_count();
			#update the external flags
			#only do ones with a tag for speed on large sets (hats!)
			drop temporary table if exists t__,t__2;
			create temporary table t__ (index(num)) as select * from t_data_nums;
			create temporary table t__2 (index(num)) as select * from t_data_nums;
			drop temporary table t_data_nums;
			create temporary table t_data_nums (index(num)) as
				select t.num from t__ t join flask_data_tag_range r on t.num=r.data_num
				union
				select t.num from t__2 t join flask_data d on t.num=d.num join flask_event_tag_range e on d.event_num=e.event_num;

			call tag_updateFlagsFromTags(flagsUpdated);
			set v_mssg=concat(v_numrows," converted to tagging system.  ",flagsUpdated," external flags changed as a result.");

		else #Just select out target row info

			select v.program,v.strategy,v.project,v.site,count(*) as 'total rows',
				sum(case when v.flag='...' then 0 else 1 end) as 'rows with flags'
			from flask_data_view v, t_data_nums t
			where v.data_num=t.num
			group by v.program,v.strategy,v.project,v.site;
		end if;

	end if;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_createIndividualDataTags` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_createIndividualDataTags`(v_tag_num int, v_tagcomment varchar(255),out v_numrows int)
begin
	#Requires existence of 2 temp tables;
    #create temporary table t_data_nums as select num from flask_data where 1=0;
	#create temporary table t_event_nums as select num from flask_event where 1=0;

	#This procedure is a wrapper to take rows in t_data_nums and create single row tags for each.
    #This is mainly done when selection is done programmatically based on some criteria from PI,
    #but we want the PI to maintain the ability to easily remove individual tags in tools like pydv
    #This is generally only used by John M and is not currently called from other programs.
    #vnum_rows returns the total number of tags created.
    declare done int default false;
    declare vdata_num int default 0;
	declare vstatus, n, vrange_num int default 0;
	declare vmssg varchar(255) default '';
	declare acur cursor for select distinct num from t__d;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    drop temporary table if exists t__d ;
    create temporary table t__d as select * from t_data_nums;
    delete from t_data_nums;
    delete from t_event_nums;#just in case.
    set v_numrows=0;

    open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vdata_num;
		if (done=true) then LEAVE read_loop; end if;
        delete from t_data_nums;
        insert t_data_nums select vdata_num;
        call tag_createTagRange(60,v_tag_num,v_tagcomment,0,null,22, null, vstatus,vmssg,n,vrange_num); #we don't really care about the status.  we'll check afterwards
        set v_numrows=v_numrows+n;
	END LOOP;
	close acur;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_createTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_createTagRange`(v_userid int,v_tag_num int, v_comment text,v_prelim tinyint,v_json_selection_criteria text,v_data_source int, v_description varchar(255), out v_status int,out v_mssg varchar(255),out v_numrows int,out v_range_num int)
sp: begin
/*
This procedure creates a new tag range with the passed flask_event or flask_data ids.

Any affected flask_data rows flag col will be updated appropriately.

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums as select num from flask_data where 1=0
create temporary table t_event_nums as select num from flask_event where 1=0

v_userid is ccgg.contact num column or <0 for automated process (see tag_securityAccess).
if v_userid=-2, we pass comment straight through without appending timestamp (caller does it).

v_json_selection_criteria is a json hash array of the selection criteria for use by the php front end.  This should be
passed null from any other front end unless cooridinated with the php logic. It's used to reload/change the orignal search criteria
v_description, can be null, is a description of the criteria selection.

This returns in status:
0 for success
1 for access error.
2 for call error.
3 if a range for this tag already exists and only a single row was passed in t_data_Nums. 
	New range is not created and no data is modified.  For multi row ranges we let the front-ends
    do their own checks as it can be complicated.
	tag_appendToTagRange can be used to add rows to one of the ranges if desired.
    
4 some other error.

v_message may contain a displayable message.
v_numrows will contain the number of affected rows.
v_range_num will contain newly inserted range_num on success.

v_tag_num is required.
v_comment can be null.
v_description can be null, is a description of the selection criteria
v_prelim (defaults to 0) is 1 to mark range as preliminary.
v_data_source is the caller/program that created row.  It is used to group ranges together
	to make it easier to delete them, mostly during development/initial conversions of sites,
	but also in automated scripts that may delete entries with a particular data_source so use with care.

	Add new sources and see details for existing ones in ccgg.tag_data_sources

*/
	declare r_count int default 0;
	declare flagsUpdated int default 0;
	declare vComment text default '';

	set v_status=0,v_mssg='',v_numrows=0,v_range_num = null;
	
	if((select count(*) from tag_dictionary where num=v_tag_num)=0) then
		set v_status=2,v_mssg=concat("Error: Invalid tag id (",v_tag_num,")");
	else 
		call tag_securityAccess(v_userid,1,v_status,v_mssg);
		if (v_status=0) then 	
			#See if any ranges with passed tag num already exist for passed id.  We only look when doing a single row range and let
            #front end logic handle any other cases (which could be complicated).
			if((select count(*) from t_data_nums)=1 )then
				if( exists (select * from flask_data_tag_view v join t_data_nums d on d.num=v.data_num and v.tag_num=v_tag_num)) then
					set v_status=3, v_mssg='Tag not added, already exists for this measurement.';
                    #select * from t_data_nums;
					leave sp;
				end if;
            end if;
            
            #Previous comments:
            #NOTE; I'm not sure we need to enforce this uniqueness.  Up for debate.  update and append do not currently check.
			#What it should probably do is remove any evs or datanums that would be duplicates and silently continue.
			#Then we could remove that logic from perl script callers and web gui.  If ever doing that, make sure
			#to not trash the temp tables as they might be used by callers (make copies to work from).

			/*Leaving out for now and doing a front end check/warning instead.
			set r_count=(select count(distinct v.range_num) from flask_data_tag_view v, t_data_nums n where v.data_num=n.num and v.tag_num=v_tag_num);
			if(r_count=0)then
				set r_count=(select count(distinct v.range_num) from flask_event_tag_view v, t_event_nums n where v.event_num=n.num and v.tag_num=v_tag_num);
			end if;
			if(r_count>0)then
				set v_status=3, v_mssg='Error: 1 or more selected rows already have this tag.';
			else
			*/
		#Check for empty sets and skip if so.  This is to allow script callers to call without knowing if it's needed.
			if((select count(*) from t_data_nums)+(select count(*) from t_event_nums)>0) then

				#Create new tag range and save off the new id
                set vComment=concat(f_tag_userTimeStamp(v_userid),ifnull(v_comment,'[tag added]'));
				if(v_data_source=11 or v_userid=-2) then #Hats sync or special call from automated process, don't add timestamp, just pass thru
					set vComment=v_comment;
				end if;
				insert tag_ranges (tag_num,comment,prelim,json_selection_criteria,data_source,description) 
					select v_tag_num,
						vComment,
						ifnull(v_prelim,0),
						v_json_selection_criteria,
						v_data_source,
						v_description;				
				set v_range_num=last_insert_id();
				
				if(v_range_num is null) then
					set v_status=4,v_mssg='Error inserting range';
				else
					#insert applicable relation tables
					insert flask_data_tag_range (data_num,range_num)
						select distinct d.num,v_range_num from t_data_nums d;
					set v_numrows=row_count();

					insert flask_event_tag_range (event_num,range_num)
						select distinct e.num,v_range_num from t_event_nums e;
					set v_numrows=v_numrows+row_count();

					set v_mssg= concat(v_numrows,case when v_numrows=1 then ' row' else ' rows' end,' inserted.');
					
					#update any flask_data rows configured to update external flag from tags.
					call tag_updateFlagsFromTags(flagsUpdated);
					if(flagsUpdated>0)then
						set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
							case when flagsUpdated=1 then ' was updated' else 's were updated' end,
							' using attached tags.');
					end if;
					
					#If data source is the php web app, also update any flags for rows that aren't converted to the tagging system yet.
					#actually, now we'll do it from any source.  jwm 11/1/16.
					#if(v_data_source=7 ) then
					call tag_updateOldStyleFlags(0,v_tag_num,r_count,v_mssg);
					#end if;

					#Update the range info cache
					drop temporary table if exists t_range_nums;
					create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0;
					insert t_range_nums select v_range_num;
					call tag_setTagRangeInfoCache();
					drop temporary table t_range_nums;

				end if;#range inserted
			end if;#emtpy id tables.
			#end if;#exists check
		end if;#sec check
	end if;#valid tag_num
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_deleteTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_deleteTagRange`(v_userid int,v_range_num int, out v_status int,out v_mssg varchar(255),out v_numrows int)
begin
/*
This procedure should be used to delete a tag range.

v_userid and v_range_num are required

Any affected flask_data rows configured to use an exteranl flag will be updated appropriately.

v_userid is ccgg.contact num column.

This returns in status:
0 for success
1 for access error.
2 for call error (incorrect params).
3 for other error.

v_message may contain a displayable message.

v_numrows will contain 1 or zero depending on whether row was deleted.

*/
	declare flagsUpdated,r_count,v_tag_num int default 0;
	set v_status=0,v_mssg='',v_numrows=0;
	if(v_range_num is null or (select count(*) from tag_ranges where num=v_range_num)=0) then
		set v_status=2,v_mssg="a valid v_range_num is a required parameter";
	else
		#Create and populate temp tables sec access proc is expecting
		drop temporary table if exists t_data_nums,t_event_nums;
		create temporary table t_data_nums as select num from flask_data where 1=0;
		create temporary table t_event_nums as select num from flask_event where 1=0;
		insert t_data_nums select data_num from flask_data_tag_range where range_num=v_range_num;
		insert t_event_nums select event_num from flask_event_tag_range where range_num=v_range_num;


		call tag_securityAccess(v_userid,4,v_status,v_mssg);
		if (v_status=0) then
			#Mark the tag_num for use below
			select tag_num into v_tag_num from tag_ranges where num=v_range_num;
			#Do delete.
			delete from tag_ranges where num=v_range_num;
			#and the relation tables.
			delete from flask_data_tag_range where range_num=v_range_num;
			set v_numrows=row_count();
			delete from flask_event_tag_range where range_num=v_range_num;
			set v_numrows=v_numrows+row_count();

			delete from tag_range_info_cache where range_num=v_range_num;
			delete from tag_range_openended_criteria where range_num=v_range_num;

			if(v_numrows>0)then
				set v_mssg='Tag successfully deleted.';
			else
				set v_mssg='No tag rows found to delete.';
			end if;

			#update any flask_data rows configured to update external flag from tags.
			call tag_updateFlagsFromTags(flagsUpdated);
			if(flagsUpdated>0)then
				set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
					case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
			end if;

			#update any flask data rows not configure to update external flag from tags using oldstyle
			call tag_updateOldStyleFlags(v_tag_num,0,r_count,v_mssg);

		end if;#sec access
	end if;#range num check
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_delFromTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_delFromTagRange`(v_userid int,v_range_num int,v_json_selection_criteria text,out v_status int,out v_mssg varchar(255),out v_numrows int )
begin
/*
Remove all target ids from the passed v_range_num.

This will update the external flag of any applicable flask_data row.

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums as select num from flask_data where 1=0
create temporary table t_event_nums as select num from flask_event where 1=0

v_userid is ccgg.contact num column.
v_json_selection_criteria is a json hash array of the selection criteria for use by the php front end.  This should be
passed null from any other front end unless cooridinated with the php logic.

This returns in status:
0 for success
1 for access error.
2 if range does not exist.
3 for other error.

v_message may contain a displayable message.

v_numrows will contain the number of removed rows.

Note; 4/17 jwm.  This is called from the hats sync logic.
*/
	declare flagsUpdated,r_count,v_tag_num int default 0;
	set v_status=1,v_mssg='',v_numrows=0;
	call tag_securityAccess(v_userid,4,v_status,v_mssg);
	if (v_status=0) then

		if((select count(*) from tag_ranges where num=v_range_num)=0) then
			set v_status=2,v_mssg='This tag range does not exist';
		else
			#Do a reality check to make sure we don't have both data and event ids and passed ids were correct for range.
			if(
				((select count(*) from t_data_nums)>0 and (select count(*) from flask_event_tag_range where range_num=v_range_num)>0)
					or
				((select count(*) from t_event_nums)>0 and (select count(*) from flask_data_tag_range where range_num=v_range_num)>0)
			) then
				set v_status=3,v_mssg="Error: Tag can't be removed using this procedure (incorrect tag type for selected ids)";
			else
				#Remove target rows from the range
				delete dt
					from flask_data_tag_range dt, t_data_nums t
					where dt.data_num=t.num and dt.range_num=v_range_num;
					set v_numrows=row_count();
				delete et
					from flask_event_tag_range et, t_event_nums t
					where et.event_num=t.num and et.range_num=v_range_num;
					set v_numrows=v_numrows+row_count();

				set v_mssg= concat(v_numrows,case when v_numrows = 1 then ' row' else ' rows' end,' removed.');

				#update the range selection criteria with passed json array (or null to erase).
				update tag_ranges set json_selection_criteria=v_json_selection_criteria where num=v_range_num;

				#update any flask_data rows configured to update external flag from tags.
				call tag_updateFlagsFromTags(flagsUpdated);
				if(flagsUpdated>0)then
					set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
						case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
				end if;

				#update any flask data rows not configure to updated external flag from tags using oldstyle
				select tag_num into v_tag_num from tag_ranges where num=v_range_num;
				call tag_updateOldStyleFlags(v_tag_num,0,r_count,v_mssg);

				#Delete the range if no more member rows are left (must be last).
				if((select count(*) from flask_data_tag_range where range_num=v_range_num)+
					(select count(*) from flask_event_tag_range where range_num=v_range_num)=0) then
					delete from tag_ranges where num=v_range_num;
					delete from tag_range_info_cache where range_num=v_range_num;
					set v_mssg=concat(v_mssg, '  Tag Range deleted because all members have been removed.');
				else
					#Update the range info cache
					drop temporary table if exists t_range_nums;
					create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0;
					insert t_range_nums select v_range_num;
					call tag_setTagRangeInfoCache();
					drop temporary table t_range_nums;
				end if;

			end if;#ev/data mix check
		end if;#range exists
	end if;#sec check
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_findTagsFromFlag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_findTagsFromFlag`(v_data_num int, v_new_flag char(3), out v_status int,out v_message varchar(50), out v_tag1 int, out v_tag2 int, out v_tag3 int)
begin
	declare newflag1 char(3) default '...';
	declare newflag2 char(3) default '...';
	declare newflag3 char(3) default '...';
	
	declare t_num int default 0;

	set v_status=0,v_tag1=0,v_tag2=0,v_tag3=0,v_message="";
	#Create 3 separate 'single issue flags' for any new or changed columns.
	#This will turn a c.P into c.. ... ..P for example.  This will allow us
	#to match them up to individual tags.
	if(v_new_flag='')then#Just check existing flag (if it's not autogenerated.
		if((select count(*) from flask_data where num=v_data_num and update_flag_from_tags=0)=1) then
			select flag,
					concat(substring(flag,1,1),'.','.'),
					concat('.',substring(flag,2,1),'.'),
					concat('.','.',substring(flag,3,1))
				into v_new_flag,newflag1,newflag2,newflag3 
			from flask_data where num=v_data_num;
		else set v_message="This row is already set to update flag from tags";
		end if;
	else #Find the difference for the new flag
		select 
			case when substring(d.flag,1,1)=substring(v_new_flag,1,1) collate latin1_general_cs
				then '...' else concat(substring(v_new_flag,1,1),'.','.') end ,
			case when substring(d.flag,2,1)=substring(v_new_flag,2,1) collate latin1_general_cs
				then '...' else concat('.',substring(v_new_flag,2,1),'.') end ,
			case when substring(d.flag,3,1)=substring(v_new_flag,3,1) collate latin1_general_cs
				then '...' else concat('.','.',substring(v_new_flag,3,1)) end 
		into newflag1,newflag2,newflag3
		from flask_data d where d.num=v_data_num;
	end if;
	#Try to find a tag for each internal flag using the data row's attributes to match.
	#The logic is a little convoluted to avoid mysql warnings when no matches found.
	if(newflag1 != '...') then 
		if((select count(*) from tag_view t, flask_data d,flask_event e 
			where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag1 collate latin1_general_cs
				and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
				and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num)
			)=1) then		
				select t.num into t_num from tag_view t, flask_data d,flask_event e 
					where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag1 collate latin1_general_cs
					and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
					and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num) 
				limit 1;
				#only output tag num if row doesn't already have it.
				if((select count(*) from flask_data_tag_view where data_num=v_data_num and tag_num=t_num)=0 and
					(select count(*) from flask_event_tag_view v, flask_data d where v.event_num=d.event_num
						and d.num=v_data_num and v.tag_num=t_num)=0
				)then set v_tag1=t_num; end if;
		else #Either no match or more than 1
			set v_message=concat('Error: Unique tag not found for (',v_new_flag,') ',newflag1),v_status=1;	
		end if;
	end if;
	if(newflag2 != '...' and v_status=0) then 
		if((select count(*) from tag_view t, flask_data d,flask_event e 
			where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag2 collate latin1_general_cs
				and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
				and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num)
			)=1) then		
				select t.num into t_num from tag_view t, flask_data d,flask_event e 
					where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag2 collate latin1_general_cs
					and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
					and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num) 
				limit 1;
				#only output tag num if row doesn't already have it.
				if((select count(*) from flask_data_tag_view where data_num=v_data_num and tag_num=t_num)=0 and
					(select count(*) from flask_event_tag_view v, flask_data d where v.event_num=d.event_num
						and d.num=v_data_num and v.tag_num=t_num)=0
				)then set v_tag2=t_num; end if;
		else #Either no match or more than 1.  Reset tag1 if set too.
			set v_message=concat('Error: Unique tag not found for (',v_new_flag,') ',newflag2),v_status=1,v_tag1=0;	
		end if;
	end if;
	if(newflag3 != '...' and v_status=0) then 
		if((select count(*) from tag_view t, flask_data d,flask_event e 
			where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag3 collate latin1_general_cs
				and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
				and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num)
			)=1) then		
				select t.num into t_num from tag_view t, flask_data d,flask_event e 
					where d.event_num=e.num and d.num=v_data_num and t.internal_flag like newflag3 collate latin1_general_cs
					and (t.program_num=0 or t.program_num=d.program_num) and (t.parameter_num=0 or t.parameter_num=d.parameter_num)	
					and (t.strategy_num=0 or t.strategy_num=e.strategy_num) and (t.project_num=0 or t.project_num=e.project_num) 
				limit 1;
				#only output tag num if row doesn't already have it.
				if((select count(*) from flask_data_tag_view where data_num=v_data_num and tag_num=t_num)=0 and
					(select count(*) from flask_event_tag_view v, flask_data d where v.event_num=d.event_num
						and d.num=v_data_num and v.tag_num=t_num)=0
				)then set v_tag3=t_num; end if;
		else #Either no match or more than 1
			set v_message=concat('Error: Unique tag not found for (',v_new_flag,') ',newflag3),v_status=1,v_tag1=0,v_tag2=0;	
		end if;
	end if;
	

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_getTagDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_getTagDetails`()
begin
/*
This procedure creates and fills the t_tag_details temp table with all tag data associated from the target ids
in t_data_nums.
As a convienence, it also creates and fills the t_range_nums table which will contain a row for every applicable data_num/range_num if
caller would prefer to format the data in another way.

You must create 1 temp table to use this procedure:
create temporary table t_data_nums (index (num)) as select num from flask_data where 1=0

The t_tag_details and t_range_nums temp tables will be dropped (if exists) and created for you with this structure:
create temporary table t_tag_details (data_num int primary key, tags varchar(255) null, tag_names varchar(1024) null, tag_details text null,tag_details_formatted text null,tag_details_html text null);
and t_range_nums will be data_num,range_num

It will contain a row for each data_num in t_data_nums.

Note; we drop and create temp table here for flexibility (so that we can add columns in the future).
*/
drop temporary table if exists t_tag_details,t_range_nums;

#create output table.  Note we may add to this in the future, but these columns will remain the same.
create temporary table t_tag_details (data_num int primary key, tag_nums varchar(255) null, tags varchar(255) null, tag_names varchar(1024) null, tag_details text null,tag_details_formatted text null,tag_details_html text null);

#build a list of applicable tags
create temporary table t_range_nums (index (data_num)) as
	#first data tags
	select v.data_num,v.range_num
		from ccgg.flask_data_tag_range v join t_data_nums t on v.data_num=t.num;

#now the event tags
insert t_range_nums (data_num,range_num)
	select d.num,v.range_num
	from ccgg.flask_event_tag_range v join ccgg.flask_data d on v.event_num=d.event_num
		join t_data_nums t on d.num=t.num;

#We'll use group concat to format the output.  Set the size to be large enough to handle any expected output.  Something too large will get truncated.
SET @@session.group_concat_max_len = 20000;

#now we can fill the output table.
insert t_tag_details (data_num,tag_nums,tags,tag_names,tag_details,tag_details_formatted,tag_details_html)
	select t.num,
		group_concat(v.tag_num separator ','),
		group_concat(v.flag separator ','),
		group_concat(v.display_name separator ' | '),
		group_concat(concat(v.display_name,': ', REPLACE(REPLACE(v.tag_comment, '\r', ''), '\n', ' ')) separator ' | '),
		group_concat(concat(v.display_name,'\n',trim(v.tag_comment)) separator '\n\n'),
		group_concat(concat(v.display_name,'<br>',trim(v.tag_comment)) separator '<br><br>')

	from t_data_nums t left join t_range_nums r on t.num=r.data_num
		join ccgg.tag_range_info_view v on r.range_num=v.range_num
	group by t.num
	order by v.display_name;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_getTagRangeInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_getTagRangeInfo`()
begin
/*This fills the t_range_info temporary table with various metrics from the ranges in t_range_nums.
This replicates the functionality of old tag_range_info_view but performs much better because of
problems our version of mysql has optimizing query plans inside of views..

Caller must create and fill t_range_nums with target ranges:
create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0

t_range_info is created in this procedure.

-update 4/17.  Added cacheing logic to speed up more.
*/
drop temporary table if exists t_range_info;

/*
drop temporary table if exists t__range_info,t_range_info,t_range_nums2;
create temporary table t_range_nums2 (index(num)) as select * from t_range_nums;

create temporary table t__range_info as
select dr.range_num,
	min(TIMESTAMP(e.date,e.time)) as ev_startDate,
	max(TIMESTAMP(e.date,e.time)) as ev_endDate,
	min(TIMESTAMP(d.date,d.time)) as d_startDate,
	max(TIMESTAMP(d.date,d.time)) as d_endDate,
	count(*) as rowcount,
	1 as is_data_range,0 as is_event_range
	from flask_data_tag_range dr, flask_data d, flask_event e, t_range_nums t
	where dr.data_num=d.num and d.event_num=e.num and dr.range_num=t.num
	group by dr.range_num
union
select er.range_num,
	min(TIMESTAMP(e.date,e.time)) as ev_startDate,
	max(TIMESTAMP(e.date,e.time)) as ev_endDate,
	min(TIMESTAMP(e.date,e.time)) as d_startDate,
	max(TIMESTAMP(e.date,e.time)) as d_endDate,
	count(*) as rowcount,
	0 as is_data_range,1 as is_event_range
	from flask_event_tag_range er, flask_event e, t_range_nums2 t
	where er.event_num=e.num and er.range_num=t.num
	group by er.range_num
;
*/
#Do a sanity check to make sure data is cached.  Note this doesn't ensure that its up to date.
if((select count(*) from t_range_nums n left join tag_range_info_cache c on n.num=c.range_num where c.range_num is null)>0) then
	call tag_setTagRangeInfoCache();
end if;

#Build the output table joining with tag info.
create temporary table t_range_info as
select v.*,
	t.ev_startDate,t.ev_endDate,
	t.d_startDate,t.d_endDate,
	case when v.measurement_issue=1 then t.d_startDate else t.ev_startDate end as startDate,
	date_format(case when v.measurement_issue=1 then t.d_startDate else t.ev_startDate end,
		case when time(case when v.measurement_issue=1 then t.d_startDate else t.ev_startDate end)='00:00:00'
			then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) as prettyStartDate,
	case when v.measurement_issue=1 then t.d_endDate else t.ev_endDate end as endDate,
	date_format(case when v.measurement_issue=1 then t.d_endDate else t.ev_endDate end,
		case when time(case when v.measurement_issue=1 then t.d_endDate else t.ev_endDate end)='00:00:00'
			then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) as prettyEndDate,
	concat("attached to ",format(t.rowcount,0),
		case when t.is_data_range=1 then ' measurement' else ' sample' end,
		case when t.rowcount!=1 then 's' else '' end)
		as prettyRowCount,
	t.rowcount,
	t.is_data_range,t.is_event_range
from tag_range_info_cache t join tag_range_info_view v on t.range_num=v.range_num
	join t_range_nums n on t.range_num=n.num;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_getTagRanges` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_getTagRanges`()
begin


delete from t_range_nums;
create temporary table if not exists t__ like t_range_nums;
delete from t__;


insert t__ select distinct r.range_num
	from flask_data_tag_range r, t_data_nums d
	where d.num=r.data_num;


insert t__ select distinct r.range_num
	from flask_data_tag_range r, t_event_nums e, flask_data fd
	where fd.event_num=e.num and fd.num=r.data_num;


insert t__ select distinct r.range_num
	from flask_event_tag_range r,t_event_nums e
	where e.num=r.event_num;


insert t__ select distinct r.range_num
	from flask_event_tag_range r,t_data_nums d, flask_data fd
	where fd.num=d.num and fd.event_num=r.event_num;


insert t_range_nums select distinct num from t__;

drop temporary table t__;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_nonOptimalSampleTimes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_nonOptimalSampleTimes`( v_start_date date, v_end_date date, v_update int, out v_status int,out v_mssg varchar(255),out v_numrows int)
begin
/*create temp table t_event_nums of all samples that were taken outside of optimal sample times alter
 optionally add to tag range.
Uses ccgg.optimal_sample_conditions where use_to_flag_non_background=1

Requires t_site_nums to be created and contain 1 or more sites to look at
create temporary table t_site_nums (index(site_num)) as select site_num from flask_event where 1=0;

v_userid is ccgg.contact num column.

This returns in status:
0 for success
1 for access error.
2 for call error.
4 some other error.

v_message may contain a displayable message.
v_numrows will contain the number of affected rows.

*/
declare vdata_source int default 16; #see ccgg.tag_data_sources
declare vuser_id int default 48; #see ccgg.contact
declare vtag_num int default 0;
set v_status=1,v_mssg='',v_numrows=0;

#Create ID tables using this syntax to ensure type matches source table:
#We'll only fill eventnums but both are needed by tag proc (if called)
drop temporary table if exists t_data_nums, t_event_nums;
create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0;
create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0;

#build list
insert t_event_nums
select e.num#,timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time)),e.date,e.time,o.sample_from_time, o.sample_to_time
from flask_event e join t_site_nums sn on sn.site_num=e.site_num
	join ccgg.optimal_sample_conditions o on
		e.site_num=o.site_num and e.project_num=o.project_num and e.strategy_num=o.strategy_num
    join gmd.site s on s.num=e.site_num
    where (o.use_to_flag_non_background=1 or v_update=0)#show all sites when not updating.
		and s.lst2utc>-99 and e.date>=v_start_date and e.date<=v_end_date
        and o.sample_from_time is not null and o.sample_to_time is not null
		and o.sample_from_time >=0 and o.sample_to_time >=0
        and case when o.sample_from_time>o.sample_to_time #over midnight
			then #to < x < from (credit z protocal)
				case when o.sample_to_time < time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time)))
                and o.sample_from_time > time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time))) then 1 else 0 end
			else # during day, from < to
				# x > to OR x < from
                case when
					time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time)))> o.sample_to_time
                    or time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time))) < o.sample_from_time
				then 1 else 0 end
			end = 1
            order by time(timestampadd(hour,-1*s.lst2utc,timestamp(e.date,e.time)));
    set v_numrows=(select count(*) from t_event_nums);
    set v_mssg=concat(v_numrows," total events match criteria");

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_securityAccess` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_securityAccess`(v_userid int, v_operation int, out v_status int,out v_mssg varchar(255) )
begin
/*
Procedure to verify security access for user/operation/target rows.
This is mostly a hook for future requirements. The request is per program restrictions.
For now we'll just return the generic access from the data_tag_users table,
but this may become arbitrarily complicated..

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums as select num from flask_data where 1=0
create temporary table t_event_nums as select num from flask_event where 1=0

v_userid is ccgg.contact num column <0 for automated process (bypass).  Note
that most automated processes use -1, some will use other values however.

This returns in status:
0 if user has requested access for v_operation on the event/data nums.
v_status=1 if not.
v_status=2 if there is an error in call parameters.

v_message may contain a displayable message.

v_operation:
1=insert ids into a tag range (implies insert tag_range if needed)
2=append comments to existing range
3=edit tag_range (ability to alter existing comments or change tag_num or change range members)
4=delete tag_range/ range members.
*/
	declare d_count int;
	declare e_count int;
	set v_mssg='',v_status=1;

	#Do some sanity checks (for developer error).
	#Note calling procedures rely on these checks being done here (so they don't have to).
	set d_count=(select count(*) from t_data_nums);
	set e_count=(select count(*) from t_event_nums);
	if(d_count>0 and e_count>0) then
		#None of the tag operations should logically operate on both events and data rows, consider this an error.
		set v_status=2,v_mssg="Error: This procedure can operate on flask_data or flask_event rows, not both";

	#We used to check for empty rows, but made calls from other procs more complicated, so we'll just allow them through
	#Note though that if we make more complicated security rules (using the ids), empty tables might return a
	#security error.
	#elseif(d_count=0 and e_count=0) then
	#	set v_status=2, v_mssg="Error: No target rows in temp id tables";
	else
		if(v_userid<0) then
			#bypass sec check for automated processes.
			select 0 into v_status;
		else
			#Check access for requested operation.  Note we currently don't use the id nums,
			#but may in the future.
			select
				case
					when v_operation=1 and can_insert=1 then 0
					when v_operation=2 and can_insert=1 then 0
					when v_operation=3 and can_edit=1 then 0
					when v_operation=4 and can_delete=1 then 0
					else 1
				end into v_status
			from data_tag_users
			where contact_num=v_userid;

			set v_mssg= case
				when v_operation is null  or v_operation <1 or v_operation>4 then concat('Unknown operation(',v_operation,')')
				when v_status=1 then concat('Insufficient access for this operation(',v_operation,') userID:',v_userid)
				else ''
				end;
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_setTagRangeInfoCache` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_setTagRangeInfoCache`()
begin
/*Because of the joins/performance of the range_info lookups and the frequency of their
use in the dt web app, we created cacheing logic to speed things up.  Caller must create
the t_range_nums temporary table:
create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0

and fill with any modified ranges to update.  This should be called by any logic that
modifies the tag_range members.
Note we only cache information about the members, not the tag data, which is generated dynamiclly by
tag_getTagRangeInfo
*/

drop temporary table if exists t_range_nums2;
create temporary table t_range_nums2 (index(num)) as select * from t_range_nums;#can't reference temp tables twice in union

replace into tag_range_info_cache (range_num,ev_startDate,ev_endDate,d_startDate,d_endDate,rowcount,is_data_range,is_event_range)
select dr.range_num,
	min(TIMESTAMP(e.date,e.time)) as ev_startDate,
	max(TIMESTAMP(e.date,e.time)) as ev_endDate,
	min(TIMESTAMP(d.date,d.time)) as d_startDate,
	max(TIMESTAMP(d.date,d.time)) as d_endDate,
	count(*) as rowcount,
	1 as is_data_range,0 as is_event_range
	from flask_data_tag_range dr, flask_data d, flask_event e, t_range_nums t
	where dr.data_num=d.num and d.event_num=e.num and dr.range_num=t.num
	group by dr.range_num
union
select er.range_num,
	min(TIMESTAMP(e.date,e.time)) as ev_startDate,
	max(TIMESTAMP(e.date,e.time)) as ev_endDate,
	min(TIMESTAMP(e.date,e.time)) as d_startDate,
	max(TIMESTAMP(e.date,e.time)) as d_endDate,
	count(*) as rowcount,
	0 as is_data_range,1 as is_event_range
	from flask_event_tag_range er, flask_event e, t_range_nums2 t
	where er.event_num=e.num and er.range_num=t.num
	group by er.range_num
;

#Build the output table joining with tag info.

drop temporary table t_range_nums2;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_syncHatsTags` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_syncHatsTags`(v_analysis_num int, out v_numrows int,out v_status int, out v_mssg varchar(255))
begin
	declare done int default false;
	declare hAnalysisNum,vDataNum,vRangeNum,v_range_num bigint default 0;
	declare hComment varchar(255) default '';
	declare vCount,vNumRowsA,vNumRowsD,vNumRowsC,vNumRowsP,hTagNum,flagsUpdated,vPrelimRangeNum int default 0;

	#Some variables with set values
	declare vDataSource int default 11;#HATS datasource for sync
	declare vProgramNum int default 8;#HATS
	declare vUserID int default -1;#System user
	declare vPrelimTagNum int default 66;#We hard code this instead of using bit flags to select because we want to make sure to use this specific one and don't want possiblility of multiples.
	declare vTagSelDescription varchar(255) default 'Syncronized from HATS DB';

	#cursor that we'll need below.
	declare acur cursor for select analysis_num,tag_num,comment 
		from t__newRanges order by analysis_num;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	#wipe and create some temp tables we'll need below and init some variables.  Note we drop tables here (if exists) and below incase the script is halted (for error) in the middle and then re-run.  Below is just to be tidy.
	drop temporary table if exists t_data_nums,t_event_nums,t__newDataRows,t__newRanges,t__delRows,t__comments,t__hatsFlags,t__dups,t_range_nums,t__afftectedRanges;
	create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0;
	create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0;
	create temporary table t__afftectedRanges(index(num)) as select num from tag_ranges where 1=0;
	set v_numrows=0,v_status=0,v_mssg='';#output variables defaults.
###
	#Create a temp table of all target hats flag/tags that need to be propagated.  
	#We'll do this once, and then run joins off it so we can combine the internal and system flags a little easier.
	#This may take awhile on full tables (v_analysis_num=0).
	create temporary table t__hatsFlags as 
		select v.analysis_num,v.data_num,i.tag_num,i.comment
		from hats.flags_internal i join hats_data_view v
			on (i.analysis_num=v.analysis_num and i.parameter_num=v.parameter_num)
		where (v_analysis_num <= 0 or v.analysis_num=v_analysis_num)			
	union
		select v.analysis_num,v.data_num,s.tag_num, s.comment
		from hats.flags_system s join hats_data_view v
			on (s.analysis_num=v.analysis_num)
		where (v_analysis_num <= 0 or v.analysis_num=v_analysis_num);
	create index i on t__hatsFlags(data_num,tag_num);

	#Remove any duplicates that may have crept in.  This can happen if a calling process is killed and restarted but orig sp is 
	#still running or maybe legitimately if dup entered in hats and then removed.
	#regardless, delete any duplicates and let below logic re-insert as needed.
	if(v_status=0) then
		create temporary table t__dups as
			select t.data_num,t.tag_num,t.comment,count(*) 
			from flask_data_tag_view t, hats_data_view v
			where t.data_source=vDataSource and t.data_num=v.data_num
				and (v_analysis_num <= 0 or v.analysis_num=v_analysis_num)
			group by t.data_num,t.tag_num,t.comment
			having count(*)>1;
		
		#Mark and then remove each from their respective ranges.
		insert t__afftectedRanges select distinct dr.range_num from flask_data_tag_range dr, t__dups t, tag_ranges r
			where dr.data_num=t.data_num and dr.range_num=r.num
				and r.data_source=vDataSource and t.tag_num=r.tag_num;
		delete dr from flask_data_tag_range dr, t__dups t,tag_ranges r
			where dr.data_num=t.data_num and dr.range_num=r.num
				and r.data_source=vDataSource and t.tag_num=r.tag_num
			;
		set vNumRowsD=vNumRowsD+row_count();

		#clean up any orphaned ranges
		delete r from tag_ranges r
			where r.data_source=vDataSource 
				and (select count(*) from flask_data_tag_range where range_num=r.num)=0; 
		
		#Update any flags that need to be updated.. note this is duplicative because it will likely get run
		#again below (in createtag), but we'll do it anyway for modularity and in case the source is no longer
		#there.
		if((select count(*) from t__dups)>0)then
			delete from t_data_nums;
			insert t_data_nums select distinct data_num from t__dups;
			call tag_updateFlagsFromTags(flagsUpdated);
		end if;
	end if;

	#Preliminary rows.
	#We've gone back and forth on whether to group prelims (and exclusions, but that's another process) together in
	#One huge range or to let them get handled by the normal logic below which groups by analysis.  There was a performance
	#hit with large ranges, but I rewrote the logic to mitigate (although could use some caching still to make faster).(5/2/17 - cacheing done, no performance issues anymore)
	#So we're going back to putting them all in one range because it declutters the ui in DT.
	if(v_status=0) then
		delete from t_data_nums;
		#Fill nums table with all target prelim rows.
		insert t_data_nums
			select data_num from t__hatsFlags where tag_num=vPrelimTagNum;
		set vCount=row_count();
		set vPrelimRangeNum=(select min(range_num) from flask_data_tag_view 
								where data_source=vDataSource and program_num=vProgramNum
									and tag_num=vPrelimTagNum);
		if(vPrelimRangeNum is null or vPrelimRangeNum=0) then #Create new range
			if(vCount>0) then #Don't bother if there's none to add.
				call tag_createTagRange(vUserID,vPrelimTagNum,"Data that has not been quality controlled yet.",0,null,vDataSource,vTagSelDescription,v_status,v_mssg,v_numrows,v_range_num);
				set vNumRowsP=vNumRowsP+v_numrows;
			end if;
		else
			#Sync this list with existing prelim rows (or update analysis members if needed).
			if(v_analysis_num<=0) then #Full replace of whole list
				if(vCount=0) then #No prelim rows, delete the range.  Below logic will clean up any ccgg tags
					delete from tag_ranges where num=vPrelimRangeNum;
				else #reset the member list
					call tag_updateTagRangeMembers(vUserID,vPrelimRangeNum,null,vTagSelDescription,v_status,v_mssg,v_numrows);
					set vNumRowsP=vNumRowsP+v_numrows;
				end if;
			else #Just sync this analsysis
				if(vCount>0) then #Add any new
					call tag_addToTagRange(vUserID,vPrelimRangeNum,null,v_status,v_mssg,v_numrows);
					set vNumRowsP=vNumRowsP+v_numrows;			
				end if;
				if(v_status=0) then 
					#remove any that aren't prelim any more.
					delete from t_data_nums;
					insert t_data_nums 
						select v.data_num from hats_data_view v
						where v.analysis_num=v_analysis_num
							and (select count(*) from t__hatsFlags h where h.data_num=v.data_num 
							and h.tag_num=vPrelimTagNum)=0;
					set vCount=row_count();
					if(vCount>0) then 
						call tag_delFromTagRange(vUserID,vPrelimRangeNum,null,v_status,v_mssg,v_numrows);
						set vNumRowsP=vNumRowsP+v_numrows;
					end if;
				end if;
			end if;
		end if;
	end if;

	if(v_status=0) then
		#Find all HATS rows with missing ccgg tags and add them.  Limit to tags created by this procedure (data_source=11).
		create temporary table t__newDataRows as
		select distinct f.analysis_num,f.data_num,f.tag_num,f.comment #distinct shouldn't be needed, but doesn't hurt much and ensures no error on duplicates.
		from t__hatsFlags f left join flask_data_tag_view dv 
				on (f.data_num=dv.data_num and f.tag_num=dv.tag_num and dv.data_source=vDataSource)#and dv.program_num=vProgramNum. #jwm - 11/24. removed this filter, it was causing trouble and serves no purpose 
		where dv.data_num is null;
		create index i2 on t__newDataRows(analysis_num);

		#select count(*) as 'New flags' from t__newDataRows;

		#We'll attempt to group flagged measurements in an analysis
		create temporary table t__newRanges as select distinct analysis_num,tag_num,comment from t__newDataRows;

		#Loop through each range and add. Cursor rolls through above temp table.		
		open acur;
		set done=false;
		read_loop: LOOP
			fetch acur into hAnalysisNum,hTagNum,hComment;
			if (done=true or v_status>0) then
				LEAVE read_loop;
			end if;

			delete from t_data_nums;
			insert t_data_nums #group all data_nums for this anal, flag, comment
				select data_num from t__newDataRows 
				where analysis_num=hAnalysisNum and tag_num=hTagNum and comment=hComment;

			if(hTagNum>0) then #create new range. Note if hats added more analysis rows to flag at a later time, we'll end up with 2 ranges.. that's ok.
				call tag_createTagRange(vUserID,hTagNum,case when hComment='' then null else hComment end,0,null,vDataSource,vTagSelDescription,v_status,v_mssg,v_numrows,v_range_num);
                #Ignore error statuses of 3 because they are a no-op (tag already exists).
                if (v_status=3) then 
					set v_status=0; 
				else
					set vNumRowsA=vNumRowsA+v_numrows;#Keep running total					
				end if;
			end if;
			
		END LOOP;
		close acur;		 
	end if;#v_status=0

	#Remove any ccgg tags that don't have a corresponding hats flag anymore.  Could be it was deleted or changed.
	if(v_status=0) then
		create temporary table t__delRows as
			select distinct dt.data_num, dt.range_num #distinct shouldn't be needed, but doesn't hurt much and ensures no error on duplicates.
			from flask_data_tag_view dt join hats_data_view v on dt.data_num=v.data_num 
				left join t__hatsFlags f
					on (dt.data_num=f.data_num and f.tag_num=dt.tag_num)
			where f.data_num is null and dt.data_source=vDataSource #and dt.program_num=vProgramNum  #jwm - 11/24. removed this filter, it was causing trouble and serves no purpose 
				and (v_analysis_num<=0 or v.analysis_num=v_analysis_num);

		#Mark and remove each from their respective ranges.
		insert t__afftectedRanges select distinct t.range_num from t__delRows t;
		delete dr from flask_data_tag_range dr, t__delRows t
			where dr.data_num=t.data_num and dr.range_num=t.range_num;
		set vNumRowsD=vNumRowsD+row_count();

		#clean up any orphaned ranges.  Note we don't filter by the rows we just deleted.. we clean any from 
		#this data source to catch any that may have been created from deleting flask_data rows in the tag_syncHatsData
		#sp.  That proc doesn't sync any tags, although the flask_data delete trigger removes the relations (but doesn't
		#remove orphaned ranges for now for performance reasons).
		delete r from tag_ranges r
			where r.data_source=vDataSource
				and (select count(*) from flask_data_tag_range where range_num=r.num)=0;
		
		#Update any flags that need to be updated.
		if((select count(*) from t__delRows)>0) then
			delete from t_data_nums;
			insert t_data_nums select distinct data_num from t__delRows;
			call tag_updateFlagsFromTags(flagsUpdated);
		end if;
	end if;

	#Now update any comments that may have changed.
	if(v_status=0) then
		#We'll do this in 2 steps just for clarity in the update syntax
		create temporary table t__comments as 
			select distinct v.range_num,f.comment 
			from flask_data_tag_view v join t__hatsFlags f on (v.data_num=f.data_num and f.tag_num=v.tag_num)
			where v.data_source=vDataSource and f.comment!=v.tag_comment;
		update tag_ranges r, t__comments t set r.comment=t.comment where t.range_num=r.num;
		set vNumRowsC=vNumRowsC+row_count();
	end if;

	#if(v_analysis_num<=0)then #Update statistics if needed as there could have been many changes..
	#	optimize tables flask_data_tag_range,tag_ranges;
	#end if;

	#update the range info statistics.  This is done in some of the above SPs, but we also directly insert/delete.  Note
	#the logic above inserts ranges that had deleted members.  	
	if(v_analysis_num<=0) then #Just  do all hats ranges.		
		insert t__afftectedRanges select distinct r.range_num 
			from flask_data_tag_view r join flask_data d on r.data_num=d.num 
			where d.program_num=8;
	end if;
	if((select count(*) from t__afftectedRanges)>0)then
		drop temporary table if exists t_range_nums;#Some other sps use this table name too.. ensure we're in a clean state
		create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0;
		insert t_range_nums select * from t__afftectedRanges;
		call tag_setTagRangeInfoCache();
	end if;

	#Clean up and set output.
	drop temporary table if exists t_data_nums,t_event_nums,t__newDataRows,t__newRanges,t__delRows,t__comments,t__hatsFlags,t__dups,t_range_nums,t__afftectedRanges;
	
	set v_numrows=vNumRowsA+vNumRowsD+vNumRowsC+vNumRowsP;
	set v_mssg=case when v_status>0 then v_mssg when v_numrows=0 then 'No changes.' else 
		concat(case when vNumRowsA > 0 then concat(vNumRowsA,' ccgg flask_data tags(s) added from HATS internal and system flags.  ') else '' end,
				case when vNumRowsD > 0 then concat(vNumRowsD, ' ccgg flask_data tag(s) removed (either deleted or changed in HATS).  ') else '' end,
				case when vNumRowsP > 0 then concat(vNumRowsP, ' preliminary row(s) updated in ccgg.  ') else '' end,
				case when vNumRowsC > 0 then concat(vNumRowsC,'  ccgg tag comment(s) updated.') else '' end
	) end;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_updateFlagsFromTags` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_updateFlagsFromTags`(out v_numrows int)
BEGIN	
	set v_numrows=0;
	drop temporary table if exists t__data_tags, t__data_tags1, t__data_tags2, t__data_tags3, t__nums,t__nums2;

	#Create a master list of all affected flask_data rows.
	create temporary table t__nums (index(num)) as
	select num from t_data_nums
	union #distinctify
	select d.num from t_event_nums n, flask_data d where n.num=d.event_num; 

	#create a copy for use in query below (mysql only allows single ref to temp table annoyingly.
	create temporary table t__nums2 (index(num)) as select num from t__nums;

	#create a temp table of all the event&data tags for selected rows.
	#Note we use distinct and replace to ensure there are no duplicates 
		#REPLACE into t__data_tags 
	
	create temporary table t__data_tags (UNIQUE(data_num,tag_num)) as
		#all the flask data tags for passed flask_data rows.
		select n.num as data_num,r.tag_num 
		from t__nums n,flask_data_tag_range t, tag_ranges r
		where t.data_num=n.num and t.range_num=r.num #and r.prelim=0
		
		union #distinctify
		select n.num as data_num, r.tag_num
		from t__nums2 n, flask_data d, flask_event_tag_range t, tag_ranges r
		where n.num=d.num and d.event_num=t.event_num and t.range_num=r.num; #and r.prelim=0;

	
	#See above note on temp tables.. these are for query below
	create temporary table t__data_tags1 (index(data_num,tag_num)) as select * from t__data_tags;
	create temporary table t__data_tags2 (index(data_num,tag_num)) as select * from t__data_tags;
	create temporary table t__data_tags3 (index(data_num,tag_num)) as select * from t__data_tags;


	update flask_data as f,t__nums n 
	#Set the update_flag_from_tags bit to -1 to bypass trigger update logic.  See flask_data triggers for details.
	#NOTE! this external flag logic must be kept in sync with function f_external_flag!!!
	set update_flag_from_tags=-1,
		flag=	
		concat(
			#Rejection
			ifnull(
				(select case when sum(v.collection_issue)>=1 and sum(v.measurement_issue)>=1 then 'B'
						when sum(v.collection_issue)>=1 then 'C'
						when sum(v.measurement_issue)>=1 then 'M'
						else 'U' 
					end 
				from t__data_tags1 t, tag_dictionary v
				where t.data_num=f.num and t.tag_num=v.num and v.reject=1 
				group by t.data_num,v.reject),'.'),

			#Selection
			ifnull(
				(select case #Moved excl to 3rd col at request of users. jwm 2.18
						when sum(v.selection_issue)>=1 then 'S' 
						else 'U' 
					end
				from t__data_tags2 t2, tag_dictionary v
				where t2.data_num=f.num and t2.tag_num=v.num and v.selection=1 
				group by t2.data_num,v.selection),'.'),


			#Information.  Switched the order to prelim, b, c, m, u (moved prelim up).  jwm 2.18
			ifnull(
				(select case 
						when sum(case when t3.tag_num=155 then 1 else 0 end)>=1 then 'i' #special logic for issues to be looked into.  These are not expected to go out to public
						when sum(v.prelim_data)>=1 then 'P'
						#when sum(v.exclusion)>=1 then 'E' #Actually pulled E entirely.  Ben and I decided it wasn't needed (in flag display).
						when sum(v.collection_issue)>=1 and sum(v.measurement_issue)>=1 then 'B'
						when sum(v.collection_issue)>=1 then 'C'
						when sum(v.measurement_issue)>=1 then 'M'
						else 'U' 
					end
				from t__data_tags3 t3, tag_dictionary v
				where t3.data_num=f.num and t3.tag_num=v.num and v.information=1 
				group by t3.data_num,v.information),'.') 
	) 
	where f.num=n.num and f.update_flag_from_tags=1;
	set v_numrows=row_count();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_updateOldStyleFlags` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_updateOldStyleFlags`(v_tag_to_remove int, v_tag_to_add int, out v_numrows int, inout v_mssg varchar(255))
begin

/*NOTE, this does not do a security check as it should only be called from other procedures!

This procedure will update the external flag column for flask_data rows in the passed temp tables that are
configured not to use the tagging system. This allows tags to be created and edited, while maintaining the
old 3 letter flag.
v_tag_to_remove, if 0 means none, else the tag to remove from the flag
v_tag_to_add, if 0 means none, else the tag to add to the flag.

v_mssg will get appended a message about num rows affected when appropriate.

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums as select num from flask_data where 1=0
create temporary table t_event_nums as select num from flask_event where 1=0
*/
	if(v_tag_to_remove>0 or v_tag_to_add>0)then
		#Create a master list of all affected flask_data rows.
		drop temporary table if exists t__nums;
		create temporary table t__nums as
		select t.num from t_data_nums t,flask_data d where d.num=t.num and d.update_flag_from_tags=0
		union #distinctify
		select d.num from t_event_nums n, flask_data d where n.num=d.event_num and d.update_flag_from_tags=0;

		#update flag using ccg_flaskupdate merge logic, which is basically non-destructive
		update flask_data d, t__nums t
			set d.flag=f_oldstyle_external_flag(d.num,v_tag_to_remove,v_tag_to_add)
		where d.num=t.num
			and d.update_flag_from_tags=0;
		set v_numrows=row_count();
		if(v_numrows>0) then
			set v_mssg=concat(v_mssg, "  ", v_numrows,' non-tagging system external flag',
				case when v_numrows=1 then ' was updated.' else 's were updated.' end);
		end if;
		drop temporary table t__nums;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_updateTagRange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_updateTagRange`(v_userid int, v_range_num int, v_comment text, v_tag_num text, v_prelim tinyint, out v_status int,out v_mssg varchar(255),out v_numrows int)
begin
/*
This procedure should be used to edit a tag range.
Note, if just appending comment the tag_appendTagComment should be used (less work and less security requirements).
Note, passed comment overwrites existing comment!

v_range_num,v_comment,v_tag_num, & v_prelim are all required fields.

Any affected flask_data rows configured to use an exteranl flag will be updated appropriately.
Ditto for non converted rows.

v_userid is ccgg.contact num column.

This returns in status:
0 for success
1 for access error.
2 for call error (incorrect params).
3 for other error.

v_message may contain a displayable message.

v_numrows will contain 1 or zero depending on whether row was updated.

*/
	declare updateFlags tinyint default 0;
	declare flagsUpdated int default 0;
	declare oldTag,r_count int default 0;

	set v_status=0,v_mssg='',v_numrows=0;
	if(v_range_num is null or (select count(*) from tag_ranges where num=v_range_num)=0) then
		set v_status=2,v_mssg="a valid v_range_num is a required parameter";
	else
		if(v_comment is null or v_prelim is null or v_tag_num is null)then
			set v_status=2, v_mssg="v_comment, v_tag_num, & v_prelim are required non-null fields, but may be the same as existing entries";
		else
			#Create and populate temp tables sec access proc is expecting
			drop temporary table if exists t_data_nums,t_event_nums;
			create temporary table t_data_nums as select num from flask_data where 1=0;
			create temporary table t_event_nums as select num from flask_event where 1=0;
			insert t_data_nums select data_num from flask_data_tag_range where range_num=v_range_num;
			insert t_event_nums select event_num from flask_event_tag_range where range_num=v_range_num;


			call tag_securityAccess(v_userid,3,v_status,v_mssg);
			if (v_status=0) then
				#See if any fields would cause external flags to get updated (tag_num or prelim)
				set updateFlags=(select count(*) from tag_ranges where num=v_range_num and (tag_num!=v_tag_num or prelim!=v_prelim));
				#mark the old tag
				select tag_num into oldTag from tag_ranges where num=v_range_num;
				#Do update.
				update tag_ranges set tag_num=v_tag_num, prelim=v_prelim, comment=v_comment where num=v_range_num;
				set v_numrows=row_count();
				if(v_numrows>0)then
					set v_mssg='Tag successfully updated.';
				else
					set v_mssg='No changes';
				end if;

				#update any flask_data rows configured to update external flag from tags.
				if(updateFlags>0)then
					call tag_updateFlagsFromTags(flagsUpdated);
					if(flagsUpdated>0)then
						set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
							case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
					end if;

					#If the tag_num changed, also update any oldstyle flags.  Note we don't check the data source (ike on create) because the only caller of this should be web app anyway.
					if(oldTag!=v_tag_num) then
						call tag_updateOldStyleFlags(oldTag,v_tag_num,r_count,v_mssg);
					end if;
				end if;
			end if;#sec access
		end if;#parameter check
	end if;#range num check
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `tag_updateTagRangeMembers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `tag_updateTagRangeMembers`(v_userid int,v_range_num int,v_json_selection_criteria text, v_description varchar(255),  out v_status int,out v_mssg varchar(255),out v_numrows int)
begin
/*
This procedure updates the members of passed tag range to be whatever ids are in the temp tables (see below).

Any affected flask_data rows configured to use an exteranl flag will be updated appropriately.

This procedure expects 2 temp tables to exist, 1 of which containing the target row id nums (either
flask_data.num or flask_event.num).
It is considered an error to populate both tables.

Create ID tables using this syntax to ensure type matches source table:
create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0
create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0

All range members are removed and then all ids in the temp tables are added.

v_userid is ccgg.contact num column.

v_json_selection_criteria is a json hash array of the selection criteria for use by the php front end.  This should be
passed null from any other front end unless cooridinated with the php logic.
v_description can be null, is a description of the selection criteria

This returns in status:
0 for success
1 for access error.
2 for call error.
4 some other error.

v_message may contain a displayable message.
v_numrows will contain the number of affected rows.

*/
	declare flagsUpdated,numdeleted,v_tag_num,r_count int default 0;


	set v_status=0,v_mssg='',v_numrows=0;

	call tag_securityAccess(v_userid,3,v_status,v_mssg);
		if (v_status=0) then
			#Copy off any ids that will be changing so we can update their flags below.
			#Keep track of inserts/deletes so we can update external flags below.
			drop temporary table if exists t__datanumsDeleted,t__datanumsInserted;
			create temporary table t__datanumsDeleted as
				#rows we'll be removing
				select d.data_num as num
				from flask_data_tag_range d left join t_data_nums t on d.data_num=t.num
				where d.range_num=v_range_num and t.num is null;

			create temporary table t__datanumsInserted as
				#rows we'll be inserting
				select t.num
				from t_data_nums t left join flask_data_tag_range d on (t.num=d.data_num and d.range_num=v_range_num)
				where d.data_num is null;

			drop temporary table if exists t__eventsDeleted, t__eventsInserted;
			create  temporary table t__eventsDeleted as
				#rows we'll be removing
				select e.event_num as num
				from flask_event_tag_range e left join t_event_nums t on e.event_num=t.num
				where e.range_num=v_range_num and t.num is null;
			create  temporary table t__eventsInserted
				#rows we'll be inserting
				select t.num
				from t_event_nums t left join flask_event_tag_range e on (t.num=e.event_num and e.range_num=v_range_num)
				where e.event_num is null;

			#Remove any existing not in the new list
			delete d from flask_data_tag_range d join t__datanumsDeleted t on d.data_num=t.num and d.range_num=v_range_num;
			set numdeleted=row_count();

			delete e from flask_event_tag_range e join t__eventsDeleted t on e.event_num=t.num and e.range_num=v_range_num;
			set numdeleted=numdeleted+row_count();

			#Insert any new ones.  Use on duplicate syntax to avoid duplicates and get an accurate count
			insert into flask_data_tag_range (data_num,range_num)
				select distinct num,v_range_num from t__datanumsInserted;
			set v_numrows=row_count();

			insert into flask_event_tag_range (event_num,range_num)
				select distinct num,v_range_num from t__eventsInserted;
			set v_numrows=v_numrows+row_count();

			#update selection criteria.  Note we don't check to see if null or empty.  We want to replace the old criteria,
			update tag_ranges set json_selection_criteria=v_json_selection_criteria,description=v_description where num=v_range_num;


			set v_mssg= concat(v_numrows,case when v_numrows=1 then ' row' else ' rows' end,' inserted and ',numdeleted,case when numdeleted=1 then ' row' else ' rows' end,' deleted.');

			set v_numrows=v_numrows+numdeleted;#Set to total number of affected rows.

			#update any flask_data rows configured to update external flag from tags.
			delete from t_data_nums;
			delete from t_event_nums;
			insert t_data_nums select distinct num from t__datanumsInserted;
			insert t_event_nums select distinct num from t__eventsInserted;
			insert t_data_nums select distinct num from t__datanumsDeleted;
			insert t_event_nums select distinct num from t__eventsDeleted;

			call tag_updateFlagsFromTags(flagsUpdated);
			if(flagsUpdated>0)then
				set v_mssg=concat(v_mssg,"  ",flagsUpdated," external flag",
					case when flagsUpdated=1 then ' was updated' else 's were updated.' end);
			end if;

			#update any flask data rows not configured to update external flag from tags using oldstyle
			#We'll do once for removed, and once for added
			select tag_num into v_tag_num from tag_ranges where num=v_range_num;
			#Add to flag
			delete from t_data_nums;
			delete from t_event_nums;
			insert t_data_nums select distinct num from t__datanumsInserted;
			insert t_event_nums select distinct num from t__eventsInserted;
			call tag_updateOldStyleFlags(0,v_tag_num,r_count,v_mssg);
			#Remove from flag
			delete from t_data_nums;
			delete from t_event_nums;
			insert t_data_nums select distinct num from t__datanumsDeleted;
			insert t_event_nums select distinct num from t__eventsDeleted;
			call tag_updateOldStyleFlags(v_tag_num,0,r_count,v_mssg);

			#Update the range info cache
			drop temporary table if exists t_range_nums;
			create temporary table t_range_nums (index(num)) as select num from tag_ranges where 1=0;
			insert t_range_nums select v_range_num;
			call tag_setTagRangeInfoCache();
			drop temporary table t_range_nums;

			drop table t__datanumsInserted,t__eventsInserted;
	end if;#sec check

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `build_binning_sites_view`
--

/*!50001 DROP TABLE IF EXISTS `build_binning_sites_view`*/;
/*!50001 DROP VIEW IF EXISTS `build_binning_sites_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `build_binning_sites_view` AS select `e`.`num` AS `event_num`,concat(`si`.`code`,case when cast(case when (`e`.`lat` - `b`.`min`) MOD `b`.`width` < `b`.`width` / 2 then `e`.`lat` - (`e`.`lat` - `b`.`min`) MOD `b`.`width` else `e`.`lat` - (`e`.`lat` - `b`.`min`) MOD `b`.`width` + `b`.`width` end as signed) < 0 then 'S' else 'N' end,lpad(cast(abs(cast(case when (`e`.`lat` - `b`.`min`) MOD `b`.`width` < `b`.`width` / 2 then `e`.`lat` - (`e`.`lat` - `b`.`min`) MOD `b`.`width` else `e`.`lat` - (`e`.`lat` - `b`.`min`) MOD `b`.`width` + `b`.`width` end as signed)) as char charset latin1),2,'0')) AS `bin_site` from ((`ccgg`.`data_binning` `b` join `ccgg`.`flask_event` `e`) join `gmd`.`site` `si`) where `b`.`target_num` = `e`.`site_num` and `e`.`site_num` = `si`.`num` and `b`.`method` = 'lat' and `e`.`date` >= `b`.`begin` and `e`.`date` <= `b`.`end` and lcase(`b`.`method`) = 'lat' and `e`.`lat` >= `b`.`min` - `b`.`width` / 2 and `e`.`lat` < `b`.`max` + `b`.`width` / 2 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `contact_view`
--

/*!50001 DROP TABLE IF EXISTS `contact_view`*/;
/*!50001 DROP VIEW IF EXISTS `contact_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `contact_view` AS select `c`.`num` AS `num`,`c`.`abbr` AS `abbr`,`c`.`name` AS `name`,`c`.`email` AS `email`,`c`.`tel` AS `tel`,`c`.`affiliation` AS `affiliation`,`c`.`orcid` AS `orcid`,`c`.`cires` AS `cires`,concat(`f_getCol`(`c`.`name`,`f_numCsvCols`(`c`.`name`,' '),' '),', ',`f_getCol`(`c`.`name`,1,' ')) AS `last_name_first`,concat('\n<creator>\n	<creatorName nameType="Personal">',`f_getCol`(`c`.`name`,`f_numCsvCols`(`c`.`name`,' '),' '),', ',`f_getCol`(`c`.`name`,1,' '),'</creatorName>\n	<givenName>',`f_getCol`(`c`.`name`,1,' '),'</givenName>\n	<familyName>',`f_getCol`(`c`.`name`,`f_numCsvCols`(`c`.`name`,' '),' '),'</familyName>\n    ',case when `c`.`orcid` is not null and `c`.`orcid` <> '' then concat('<nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org">https://orcid.org/',`c`.`orcid`,'</nameIdentifier>\n    ') else '' end,convert(case when `c`.`affiliation` like '%INSTAAR%' then '<affiliation affiliationIdentifier="https://ror.org/00924z688" affiliationIdentifierScheme="ROR" schemeURI="https://ror.org">Institute of Arctic and Alpine Research</affiliation>\n        ' when `c`.`affiliation` like '%GML%' and `c`.`cires` = 1 then '<affiliation affiliationIdentifier="https://ror.org/00bdqav06" affiliationIdentifierScheme="ROR" schemeURI="https://ror.org">Cooperative Institute for Research in Environmental Sciences</affiliation>\n        ' when `c`.`affiliation` like '%GML%' and `c`.`cires` = 0 then '<affiliation affiliationIdentifier="https://ror.org/02z5nhe81" affiliationIdentifierScheme="ROR" schemeURI="https://ror.org">National Oceanic and Atmospheric Administration</affiliation>\n        ' else '' end using latin1),'\n</creator>') AS `datacite_xml` from `contact` `c` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `data_summary_view`
--

/*!50001 DROP TABLE IF EXISTS `data_summary_view`*/;
/*!50001 DROP VIEW IF EXISTS `data_summary_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `data_summary_view` AS select `s`.`code` AS `site`,`proj`.`abbr` AS `project`,`st`.`abbr` AS `strategy`,`prog`.`abbr` AS `program`,`pa`.`formula` AS `parameter`,`stat`.`name` AS `status`,`ds`.`first` AS `first`,`ds`.`last` AS `last`,`ds`.`count` AS `count`,`ds`.`site_num` AS `site_num`,`ds`.`project_num` AS `project_num`,`ds`.`strategy_num` AS `strategy_num`,`ds`.`program_num` AS `program_num`,`ds`.`parameter_num` AS `parameter_num`,`ds`.`status_num` AS `status_num`,case when `ds`.`strategy_num` = 1 then case when `s`.`code` in ('asc','cba') then 3.5 when `s`.`code` = 'syo' then 14 when `s`.`code` in ('bhd','drp') then 21 else 7 end when `ds`.`strategy_num` = 2 then case when `s`.`code` = 'sgp' then 35 when `s`.`code` in ('bwd','neb','nwb','tmd','inx') then 30 when `s`.`code` in ('mrc','msh') then 25 when `s`.`code` = 'crv' then 23 when `s`.`code` = 'nwr' then 16 when `s`.`code` in ('amt','lef','lew','sct','wgc','wkt') then 11 when `s`.`code` = 'mbo' then 9 when `s`.`code` = 'mwo' then 7 when `s`.`code` = 'str' then 6 else 15 end when `ds`.`strategy_num` in (3,4) then 1 else 0 end AS `target_sample_days`,`ds`.`first_releaseable` AS `first_releaseable`,`ds`.`last_releaseable` AS `last_releaseable`,case when `ds`.`project_num` = 1 and `ds`.`strategy_num` = 3 then 'tower' else `proj`.`abbr` end AS `ftp_project`,case when `ds`.`project_num` = 1 and `ds`.`strategy_num` = 3 then 3 else `ds`.`project_num` end AS `ftp_project_num` from ((((((`ccgg`.`data_summary` `ds` join `gmd`.`site` `s` on(`ds`.`site_num` = `s`.`num`)) join `gmd`.`project` `proj` on(`proj`.`num` = `ds`.`project_num`)) join `ccgg`.`strategy` `st` on(`st`.`num` = `ds`.`strategy_num`)) join `gmd`.`program` `prog` on(`prog`.`num` = `ds`.`program_num`)) join `gmd`.`parameter` `pa` on(`pa`.`num` = `ds`.`parameter_num`)) join `ccgg`.`status` `stat` on(`stat`.`num` = `ds`.`status_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `dois_view`
--

/*!50001 DROP TABLE IF EXISTS `dois_view`*/;
/*!50001 DROP VIEW IF EXISTS `dois_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `dois_view` AS select `g`.`formula` AS `parameter`,`pr`.`abbr` AS `project`,`s`.`abbr` AS `strategy`,`prg`.`abbr` AS `program`,concat('<a href="https://scholar.google.com/scholar?lookup=0&q=',`d`.`doi`,'&hl=en&as_sdt=0,6" target="_gs">',`d`.`doi`,'</a>') AS `google_scholar`,concat('<a href="https://search.datacite.org/works?query=',`d`.`doi`,'" target="_ds">',`d`.`doi`,'</a>') AS `data_cite`,concat('<a href="https://doi.org/',`d`.`doi`,'" target="_doi">','https:doi.org/',`d`.`doi`,'</a>') AS `doi_url`,`d`.`num` AS `num`,`d`.`doi` AS `doi`,`d`.`parameter_num` AS `parameter_num`,`d`.`strategy_num` AS `strategy_num`,`d`.`project_num` AS `project_num`,`d`.`program_num` AS `program_num`,`d`.`site_num` AS `site_num` from ((((`ccgg`.`dois` `d` left join `gmd`.`parameter` `g` on(`g`.`num` = `d`.`parameter_num`)) left join `ccgg`.`project` `pr` on(`pr`.`num` = `d`.`project_num`)) left join `ccgg`.`strategy` `s` on(`s`.`num` = `d`.`strategy_num`)) left join `gmd`.`program` `prg` on(`prg`.`num` = `d`.`program_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `drier_event_view`
--

/*!50001 DROP TABLE IF EXISTS `drier_event_view`*/;
/*!50001 DROP VIEW IF EXISTS `drier_event_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `drier_event_view` AS select `e`.`event_num` AS `event_num`,`e`.`site_num` AS `site_num`,`e`.`site` AS `site`,`e`.`project_num` AS `project_num`,`e`.`project` AS `project`,`e`.`strategy_num` AS `strategy_num`,`e`.`strategy` AS `strategy`,`e`.`ev_date` AS `ev_date`,`e`.`ev_time` AS `ev_time`,`e`.`ev_datetime` AS `ev_datetime`,`e`.`dd` AS `ev_dd`,`e`.`flask_id` AS `flask_id`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `ev_comment`,`e`.`me` AS `method`,`m`.`abbr` AS `method_abbr`,`h`.`drier_hist_num` AS `drier_hist_num`,`h`.`drier_type_num` AS `drier_type_num`,`h`.`drier_type` AS `drier_type`,`h`.`method` AS `drier_method`,`h`.`start_date` AS `start_date`,`h`.`end_date` AS `end_date`,`h`.`comments` AS `comments`,`h`.`d1_location_num` AS `d1_location_num`,`h`.`d1_location` AS `d1_location`,`h`.`d2_location_num` AS `d2_location_num`,`h`.`d2_location` AS `d2_location`,`h`.`d1_path_order` AS `d1_path_order`,`h`.`d2_path_order` AS `d2_path_order`,`h`.`d1_chiller_type_num` AS `d1_chiller_type_num`,`h`.`d1_chiller_type` AS `d1_chiller_type`,`h`.`d2_chiller_type_num` AS `d2_chiller_type_num`,`h`.`d2_chiller_type` AS `d2_chiller_type`,`h`.`d1_trap_type_num` AS `d1_trap_type_num`,`h`.`d1_trap_type` AS `d1_trap_type`,`h`.`d2_trap_type_num` AS `d2_trap_type_num`,`h`.`d2_trap_type` AS `d2_trap_type`,`h`.`d1_chiller_setpoint` AS `d1_chiller_setpoint`,`h`.`d2_chiller_setpoint` AS `d2_chiller_setpoint`,`h`.`d1_pressure_setpoint` AS `d1_pressure_setpoint`,`h`.`d2_pressure_setpoint` AS `d2_pressure_setpoint`,`h`.`d1_est_max_sample_h2o` AS `d1_est_max_sample_h2o`,`h`.`d2_est_max_sample_h2o` AS `d2_est_max_sample_h2o` from ((`ccgg`.`flask_event_view` `e` join `ccgg`.`flask_method` `m` on(`m`.`method` = `e`.`me`)) left join `ccgg`.`drier_history_view` `h` on(`e`.`site_num` = `h`.`site_num` and `e`.`project_num` = `h`.`project_num` and `e`.`strategy_num` = `h`.`strategy_num` and (`h`.`method` is null or `h`.`method` = '' or `h`.`method` = `e`.`me`) and `e`.`ev_datetime` >= `h`.`start_date` and `e`.`ev_datetime` < `h`.`end_date` and case when `h`.`method` is null or `h`.`method` = '' then case when exists(select 1 from `ccgg`.`drier_hist` `h2` where `e`.`site_num` = `h2`.`site_num` and `e`.`project_num` = `h2`.`project_num` and `e`.`strategy_num` = `h2`.`strategy_num` and `h2`.`method` = `e`.`me` and `e`.`ev_datetime` >= `h2`.`start_date` and `e`.`ev_datetime` < `h2`.`end_date` limit 1) then 1 else 0 end else 0 end = 0)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `drier_history_view`
--

/*!50001 DROP TABLE IF EXISTS `drier_history_view`*/;
/*!50001 DROP VIEW IF EXISTS `drier_history_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `drier_history_view` AS select `h`.`num` AS `drier_hist_num`,`h`.`site_num` AS `site_num`,`st`.`code` AS `site`,`h`.`project_num` AS `project_num`,`p`.`abbr` AS `project`,`h`.`strategy_num` AS `strategy_num`,`s`.`abbr` AS `strategy`,`h`.`drier_type_num` AS `drier_type_num`,`d`.`abbr` AS `drier_type`,`h`.`method` AS `method`,`h`.`start_date` AS `start_date`,ifnull(`h`.`end_date`,'9999-12-31') AS `end_date`,`h`.`comments` AS `comments`,`h`.`d1_location_num` AS `d1_location_num`,`dl1`.`name` AS `d1_location`,`h`.`d2_location_num` AS `d2_location_num`,`dl2`.`name` AS `d2_location`,`h`.`d1_path_order` AS `d1_path_order`,`h`.`d2_path_order` AS `d2_path_order`,`h`.`d1_chiller_type_num` AS `d1_chiller_type_num`,`dc1`.`name` AS `d1_chiller_type`,`h`.`d2_chiller_type_num` AS `d2_chiller_type_num`,`dc2`.`name` AS `d2_chiller_type`,`h`.`d1_trap_type_num` AS `d1_trap_type_num`,`dt1`.`name` AS `d1_trap_type`,`h`.`d2_trap_type_num` AS `d2_trap_type_num`,`dt2`.`name` AS `d2_trap_type`,`h`.`d1_chiller_setpoint` AS `d1_chiller_setpoint`,`h`.`d2_chiller_setpoint` AS `d2_chiller_setpoint`,`h`.`d1_pressure_setpoint` AS `d1_pressure_setpoint`,`h`.`d2_pressure_setpoint` AS `d2_pressure_setpoint`,`h`.`d1_est_max_sample_h2o` AS `d1_est_max_sample_h2o`,`h`.`d2_est_max_sample_h2o` AS `d2_est_max_sample_h2o` from ((((((((((`ccgg`.`drier_hist` `h` join `ccgg`.`project` `p` on(`p`.`num` = `h`.`project_num`)) join `ccgg`.`strategy` `s` on(`s`.`num` = `h`.`strategy_num`)) join `gmd`.`site` `st` on(`st`.`num` = `h`.`site_num`)) join `ccgg`.`drier_types` `d` on(`d`.`num` = `h`.`drier_type_num`)) left join `ccgg`.`drier_locations` `dl1` on(`dl1`.`num` = `h`.`d1_location_num`)) left join `ccgg`.`drier_locations` `dl2` on(`dl2`.`num` = `h`.`d2_location_num`)) left join `ccgg`.`drier_trap_types` `dt1` on(`dt1`.`num` = `h`.`d1_trap_type_num`)) left join `ccgg`.`drier_trap_types` `dt2` on(`dt2`.`num` = `h`.`d2_trap_type_num`)) left join `ccgg`.`drier_chiller_types` `dc1` on(`dc1`.`num` = `h`.`d1_chiller_type_num`)) left join `ccgg`.`drier_chiller_types` `dc2` on(`dc2`.`num` = `h`.`d2_chiller_type_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_data_tag_range_info_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_data_tag_range_info_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_data_tag_range_info_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_data_tag_range_info_view` AS select `dr`.`range_num` AS `range_num`,min(timestamp(`e`.`date`,`e`.`time`)) AS `ev_startDate`,max(timestamp(`e`.`date`,`e`.`time`)) AS `ev_endDate`,min(timestamp(`d`.`date`,`d`.`time`)) AS `startDate`,max(timestamp(`d`.`date`,`d`.`time`)) AS `endDate`,count(0) AS `rowcount` from ((`flask_data_tag_range` `dr` join `flask_data` `d`) join `flask_event` `e`) where `dr`.`data_num` = `d`.`num` and `d`.`event_num` = `e`.`num` group by `dr`.`range_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_data_tag_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_data_tag_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_data_tag_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_data_tag_view` AS select `dr`.`data_num` AS `data_num`,`dr`.`range_num` AS `range_num`,`r`.`comment` AS `tag_comment`,`r`.`prelim` AS `prelim`,`r`.`description` AS `description`,`r`.`data_source` AS `data_source`,`t`.`tag_num` AS `tag_num`,`t`.`internal_flag` AS `internal_flag`,`t`.`display_name` AS `display_name`,`t`.`group_name` AS `group_name`,`t`.`group_name2` AS `group_name2`,`t`.`sort_order` AS `sort_order`,`t`.`sort_order2` AS `sort_order2`,`t`.`sort_order3` AS `sort_order3`,`t`.`sort_order4` AS `sort_order4`,`t`.`hats_sort` AS `hats_sort`,`t`.`num` AS `num`,`t`.`deprecated` AS `deprecated`,`t`.`flag` AS `flag`,`t`.`name` AS `name`,`t`.`short_name` AS `short_name`,`t`.`reject` AS `reject`,`t`.`reject_min_severity` AS `reject_min_severity`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`unknown_issue` AS `unknown_issue`,`t`.`automated` AS `automated`,`t`.`comment` AS `comment`,`t`.`min_severity` AS `min_severity`,`t`.`max_severity` AS `max_severity`,`t`.`last_modified` AS `last_modified`,`t`.`hats_perseus` AS `hats_perseus`,`t`.`hats_ng` AS `hats_ng`,`t`.`exclusion` AS `exclusion`,`t`.`prelim_data` AS `prelim_data`,`t`.`parent_tag_num` AS `parent_tag_num`,`t`.`project_num` AS `project_num`,`t`.`program_num` AS `program_num`,`t`.`strategy_num` AS `strategy_num`,`t`.`parameter_num` AS `parameter_num`,`t`.`inst_num` AS `inst_num`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff` from ((`ccgg`.`flask_data_tag_range` `dr` join `ccgg`.`tag_ranges` `r`) join `ccgg`.`tag_view` `t`) where `dr`.`range_num` = `r`.`num` and `r`.`tag_num` = `t`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_data_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_data_view` AS select `d`.`event_num` AS `event_num`,`d`.`event_num` AS `ccgg_event_num`,`d`.`num` AS `data_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`d`.`program_num` AS `program_num`,`prog`.`abbr` AS `program`,`d`.`parameter_num` AS `parameter_num`,`pa`.`formula` AS `parameter`,`e`.`date` AS `ev_date`,`e`.`time` AS `ev_time`,`e`.`dd` AS `ev_dd`,timestamp(`e`.`date`,`e`.`time`) AS `ev_datetime`,`e`.`id` AS `flask_id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `ev_comment`,`d`.`value` AS `value`,`d`.`unc` AS `unc`,`d`.`flag` AS `flag`,`d`.`inst` AS `inst`,`d`.`system` AS `system`,`d`.`date` AS `date`,`d`.`time` AS `time`,`d`.`date` AS `adate`,`d`.`time` AS `atime`,`d`.`date` AS `a_date`,`d`.`time` AS `a_time`,`d`.`dd` AS `a_dd`,timestamp(`d`.`date`,`d`.`time`) AS `a_datetime`,`d`.`dd` AS `dd`,`d`.`comment` AS `comment`,`d`.`update_flag_from_tags` AS `update_flag_from_tags`,date_format(timestamp(`e`.`date`,`e`.`time`),case when `e`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyEvDate`,date_format(timestamp(`d`.`date`,`d`.`time`),case when `d`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyADate`,`d`.`creation_datetime` AS `a_creation_datetime` from ((((((`ccgg`.`flask_event` `e` join `ccgg`.`flask_data` `d`) join `gmd`.`site` `si`) join `gmd`.`project` `proj`) join `ccgg`.`strategy` `st`) join `gmd`.`program` `prog`) join `gmd`.`parameter` `pa`) where `e`.`num` = `d`.`event_num` and `e`.`site_num` = `si`.`num` and `e`.`project_num` = `proj`.`num` and `e`.`strategy_num` = `st`.`num` and `d`.`program_num` = `prog`.`num` and `d`.`parameter_num` = `pa`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_ev_data_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_ev_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_ev_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_ev_data_view` AS select `d`.`num` AS `data_num`,`d`.`event_num` AS `event_num`,`e`.`site_num` AS `site_num`,`e`.`project_num` AS `project_num`,`e`.`strategy_num` AS `strategy_num`,`d`.`program_num` AS `program_num`,`d`.`parameter_num` AS `parameter_num`,`e`.`date` AS `ev_date`,`e`.`time` AS `ev_time`,`e`.`dd` AS `ev_dd`,timestamp(`e`.`date`,`e`.`time`) AS `ev_datetime`,`d`.`date` AS `a_date`,`d`.`time` AS `a_time`,`d`.`dd` AS `a_dd`,timestamp(`d`.`date`,`d`.`time`) AS `a_datetime`,`d`.`inst` AS `inst`,`d`.`flag` AS `flag`,`e`.`me` AS `method` from (`flask_event` `e` join `flask_data` `d`) where `e`.`num` = `d`.`event_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_event_binning_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_event_binning_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_event_binning_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_binning_view` AS select `b`.`event_num` AS `event_num`,`b`.`bin_site` AS `bin_site`,`s`.`num` AS `bin_site_num` from (`ccgg`.`build_binning_sites_view` `b` join `gmd`.`site` `s`) where lcase(`s`.`code`) = lcase(`b`.`bin_site`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_event_tag_range_info_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_event_tag_range_info_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_event_tag_range_info_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_tag_range_info_view` AS select `er`.`range_num` AS `range_num`,min(timestamp(`e`.`date`,`e`.`time`)) AS `startDate`,max(timestamp(`e`.`date`,`e`.`time`)) AS `endDate`,count(0) AS `rowcount` from (`flask_event_tag_range` `er` join `flask_event` `e`) where `er`.`event_num` = `e`.`num` group by `er`.`range_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_event_tag_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_event_tag_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_event_tag_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_tag_view` AS select `er`.`event_num` AS `event_num`,`r`.`num` AS `range_num`,`r`.`comment` AS `tag_comment`,`r`.`description` AS `description`,`r`.`prelim` AS `prelim`,`r`.`data_source` AS `data_source`,`t`.`tag_num` AS `tag_num`,`t`.`internal_flag` AS `internal_flag`,`t`.`display_name` AS `display_name`,`t`.`group_name` AS `group_name`,`t`.`group_name2` AS `group_name2`,`t`.`sort_order` AS `sort_order`,`t`.`sort_order2` AS `sort_order2`,`t`.`sort_order3` AS `sort_order3`,`t`.`sort_order4` AS `sort_order4`,`t`.`hats_sort` AS `hats_sort`,`t`.`num` AS `num`,`t`.`deprecated` AS `deprecated`,`t`.`flag` AS `flag`,`t`.`name` AS `name`,`t`.`short_name` AS `short_name`,`t`.`reject` AS `reject`,`t`.`reject_min_severity` AS `reject_min_severity`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`unknown_issue` AS `unknown_issue`,`t`.`automated` AS `automated`,`t`.`comment` AS `comment`,`t`.`min_severity` AS `min_severity`,`t`.`max_severity` AS `max_severity`,`t`.`last_modified` AS `last_modified`,`t`.`hats_perseus` AS `hats_perseus`,`t`.`hats_ng` AS `hats_ng`,`t`.`exclusion` AS `exclusion`,`t`.`prelim_data` AS `prelim_data`,`t`.`parent_tag_num` AS `parent_tag_num`,`t`.`project_num` AS `project_num`,`t`.`program_num` AS `program_num`,`t`.`strategy_num` AS `strategy_num`,`t`.`parameter_num` AS `parameter_num`,`t`.`inst_num` AS `inst_num`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff` from ((`ccgg`.`flask_event_tag_range` `er` join `ccgg`.`tag_ranges` `r`) join `ccgg`.`tag_view` `t`) where `er`.`range_num` = `r`.`num` and `r`.`tag_num` = `t`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_event_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_event_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_event_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_view` AS select `e`.`num` AS `num`,`e`.`num` AS `event_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`e`.`date` AS `date`,`e`.`date` AS `ev_date`,`e`.`time` AS `time`,`e`.`time` AS `ev_time`,timestamp(`e`.`date`,`e`.`time`) AS `datetime`,timestamp(`e`.`date`,`e`.`time`) AS `ev_datetime`,date_format(timestamp(`e`.`date`,`e`.`time`),case when `e`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyEvDate`,`e`.`dd` AS `dd`,`e`.`id` AS `id`,`e`.`id` AS `flask_id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `comment`,`f_intake_ht`(`e`.`alt`,`e`.`elev`) AS `intake_ht` from (((`ccgg`.`flask_event` `e` join `gmd`.`site` `si`) join `gmd`.`project` `proj`) join `ccgg`.`strategy` `st`) where `e`.`site_num` = `si`.`num` and `e`.`project_num` = `proj`.`num` and `e`.`strategy_num` = `st`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `gen_shipping_inv_view`
--

/*!50001 DROP TABLE IF EXISTS `gen_shipping_inv_view`*/;
/*!50001 DROP VIEW IF EXISTS `gen_shipping_inv_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `gen_shipping_inv_view` AS select `sh`.`gen_inv_id` AS `id`,`s`.`code` AS `site`,`p`.`abbr` AS `project`,`t`.`abbr` AS `type`,`sh`.`date_out` AS `date_out`,`sh`.`date_inuse` AS `date_inuse`,`sh`.`date_outuse` AS `date_outuse`,`sh`.`date_in` AS `date_in`,`sh`.`notes` AS `notes` from (((`gmd`.`site` `s` join `gmd`.`project` `p`) join `ccgg_equip`.`gen_shipping` `sh`) join `ccgg_equip`.`gen_type` `t`) where `s`.`num` = `sh`.`site_num` and `p`.`num` = `sh`.`project_num` and `sh`.`gen_type_num` = `t`.`num` union select `i`.`id` AS `id`,`s`.`code` AS `site`,`p`.`abbr` AS `project`,`t`.`abbr` AS `type`,`i`.`date_out` AS `date_out`,`i`.`date_inuse` AS `date_inuse`,`i`.`date_outuse` AS `date_outuse`,`i`.`date_in` AS `date_in`,`i`.`notes` AS `notes` from (((`gmd`.`site` `s` join `gmd`.`project` `p`) join `ccgg_equip`.`gen_inv` `i`) join `ccgg_equip`.`gen_type` `t`) where `s`.`num` = `i`.`site_num` and `p`.`num` = `i`.`project_num` and `i`.`gen_type_num` = `t`.`num` and `i`.`gen_status_num` = 3 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `gggrn_data_view`
--

/*!50001 DROP TABLE IF EXISTS `gggrn_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `gggrn_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `gggrn_data_view` AS select `d`.`site_num` AS `site_num`,`d`.`site` AS `site`,`d`.`project_num` AS `project_num`,`d`.`project` AS `project`,`d`.`strategy_num` AS `strategy_num`,`d`.`strategy` AS `strategy`,`d`.`program_num` AS `program_num`,`d`.`program` AS `program`,`d`.`parameter` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,`d`.`value` AS `value`,`d`.`unc` AS `unc`,`i`.`num` AS `inst_num`,`d`.`inst` AS `inst_id`,1 AS `n`,-999.9999 AS `stddev`,`d`.`ev_datetime` AS `sample_datetime`,`d`.`a_datetime` AS `analysis_datetime`,`d`.`flask_id` AS `sample_id`,`d`.`me` AS `sample_method`,`d`.`alt` AS `alt`,`d`.`lat` AS `lat`,`d`.`lon` AS `lon`,`d`.`elev` AS `elev`,`d`.`data_num` AS `data_num`,0 AS `analysis_num`,`d`.`event_num` AS `ccgg_event_num`,0 AS `pair_id_num`,`d`.`flag` AS `flag`,`d`.`ev_date` AS `ev_date`,`d`.`ev_datetime` AS `ev_datetime`,`d`.`a_date` AS `a_date`,`d`.`a_datetime` AS `a_datetime`,`d`.`flask_id` AS `flask_id`,`d`.`me` AS `me` from (`ccgg`.`flask_data_view` `d` left join `ccgg`.`inst_description` `i` on(`i`.`id` = `d`.`inst`)) where `d`.`program_num` <> 8 union select `d`.`site_num` AS `site_num`,`d`.`site` AS `site`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`str`.`num` AS `strategy_num`,`str`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,`d`.`parameter` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,`d`.`value` AS `value`,-999.9999 AS `unc`,`d`.`inst_num` AS `inst_num`,`d`.`inst_id` AS `inst_id`,1 AS `n`,-999.9999 AS `stddev`,`d`.`sample_datetime` AS `sample_datetime`,`d`.`analysis_datetime` AS `a_datetime`,`d`.`sample_id` AS `sample_id`,`d`.`sample_type` AS `sample_method`,`d`.`alt` AS `alt`,`d`.`lat` AS `lat`,`d`.`lon` AS `lon`,`d`.`elev` AS `elev`,0 AS `data_num`,`d`.`analysis_num` AS `analysis_num`,`d`.`ccgg_event_num` AS `ccgg_event_num`,`d`.`pair_id_num` AS `pair_id_num`,concat(case when `d`.`rejected` = 0 and `d`.`data_exclusion` = 0 then '.' else 'N' end,case when `d`.`background` = 0 then '.' else 'X' end,case when `d`.`suspicious` = 1 then 'n' else '.' end) AS `flag`,cast(`d`.`sample_datetime` as date) AS `ev_date`,`d`.`sample_datetime` AS `ev_datetime`,cast(`d`.`analysis_datetime` as date) AS `a_date`,`d`.`analysis_datetime` AS `a_datetime`,`d`.`sample_id` AS `flask_id`,`d`.`sample_type` AS `me` from (((`hats`.`prs_data_view` `d` join `gmd`.`project` `prj` on(`prj`.`num` = `d`.`project_num`)) join `ccgg`.`strategy` `str` on(`str`.`num` = `d`.`strategy_num`)) join `gmd`.`program` `prg` on(`prg`.`num` = 8)) union select `d`.`site_num` AS `site_num`,`d`.`site` AS `site`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`str`.`num` AS `strategy_num`,`str`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,`d`.`parameter` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,`d`.`value` AS `value`,-999.9999 AS `unc`,`d`.`inst_num` AS `inst_num`,`d`.`inst_id` AS `inst_id`,1 AS `n`,-999.9999 AS `stddev`,`d`.`sample_datetime` AS `sample_datetime`,`d`.`analysis_datetime` AS `a_datetime`,`d`.`sample_id` AS `sample_id`,`d`.`sample_type` AS `sample_method`,`d`.`elev` AS `alt`,`d`.`lat` AS `lat`,`d`.`lon` AS `lon`,`d`.`elev` AS `elev`,0 AS `data_num`,`d`.`analysis_num` AS `analysis_num`,`d`.`ccgg_event_num` AS `ccgg_event_num`,`d`.`pair_id_num` AS `pair_id_num`,concat(case when `d`.`rejected` = 0 then '.' else 'N' end,'.',case when `d`.`suspicious` = 1 then 'n' else '.' end) AS `flag`,cast(`d`.`sample_datetime` as date) AS `ev_date`,`d`.`sample_datetime` AS `ev_datetime`,cast(`d`.`analysis_datetime` as date) AS `a_date`,`d`.`analysis_datetime` AS `a_datetime`,`d`.`sample_id` AS `flask_id`,`d`.`sample_type` AS `me` from (((`hats`.`ng_data_view` `d` join `gmd`.`project` `prj` on(`prj`.`num` = `d`.`project_num`)) join `ccgg`.`strategy` `str` on(`str`.`num` = `d`.`strategy_num`)) join `gmd`.`program` `prg` on(`prg`.`num` = 8)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `gggrn_pair_avg_view`
--

/*!50001 DROP TABLE IF EXISTS `gggrn_pair_avg_view`*/;
/*!50001 DROP VIEW IF EXISTS `gggrn_pair_avg_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `gggrn_pair_avg_view` AS select `d`.`site_num` AS `site_num`,`d`.`site` AS `site`,`d`.`project_num` AS `project_num`,`d`.`project` AS `project`,`d`.`strategy_num` AS `strategy_num`,`d`.`strategy` AS `strategy`,`d`.`program_num` AS `program_num`,`d`.`program` AS `program`,`d`.`parameter` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,`i`.`num` AS `inst_num`,`d`.`inst` AS `inst_id`,`d`.`ev_datetime` AS `sample_datetime`,min(`d`.`a_datetime`) AS `analysis_datetime`,group_concat(`d`.`flask_id` order by `d`.`flask_id` ASC separator '|') AS `sample_id`,`d`.`me` AS `sample_method`,`d`.`alt` AS `alt`,`d`.`lat` AS `lat`,`d`.`lon` AS `lon`,`d`.`elev` AS `elev`,group_concat(`d`.`data_num` order by `d`.`data_num` ASC separator '|') AS `data_num`,group_concat(`d`.`event_num` order by `d`.`event_num` ASC separator '|') AS `event_num`,0 AS `pair_id_num`,avg(`d`.`value`) AS `pair_avg`,avg(`d`.`unc`) AS `pair_unc`,count(0) AS `n`,std(`d`.`value`) AS `pair_stdv`,`d`.`ev_datetime` AS `ev_datetime`,`d`.`a_datetime` AS `a_datetime`,`d`.`flask_id` AS `flask_id`,`d`.`me` AS `me`,cast(`d`.`ev_datetime` as date) AS `ev_date`,cast(`d`.`a_datetime` as date) AS `a_date`,avg(`d`.`value`) AS `value`,avg(`d`.`unc`) AS `unc` from (`ccgg`.`flask_data_view` `d` left join `ccgg`.`inst_description` `i` on(`i`.`id` = `d`.`inst`)) where `d`.`program_num` <> 8 group by `d`.`site_num`,`d`.`site`,`d`.`project_num`,`d`.`project`,`d`.`strategy_num`,`d`.`strategy`,`d`.`program_num`,`d`.`program`,`d`.`parameter`,`d`.`parameter_num`,`i`.`num`,`d`.`inst`,`d`.`ev_datetime`,`d`.`a_datetime`,`d`.`flask_id`,`d`.`me`,`d`.`alt`,`d`.`lat`,`d`.`lon`,`d`.`elev`,cast(`d`.`ev_datetime` as date),cast(`d`.`a_datetime` as date) union select `h`.`site_num` AS `site_num`,`h`.`site` AS `site`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`str`.`num` AS `strategy_num`,`str`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,`h`.`parameter` AS `parameter`,`h`.`parameter_num` AS `parameter_num`,`h`.`inst_num` AS `inst_num`,`h`.`inst_id` AS `inst_id`,`h`.`sample_datetime` AS `ev_datetime`,`h`.`analysis_datetime` AS `analysis_datetime`,`h`.`sample_id` AS `sample_id`,`h`.`sample_type` AS `sample_method`,`s`.`elev` AS `alt`,`s`.`lat` AS `lat`,`s`.`lon` AS `lon`,`s`.`elev` AS `elev`,0 AS `data_num`,0 AS `event_num`,`h`.`pair_id_num` AS `pair_id_num`,`h`.`pair_avg` AS `pair_avg`,-999.99 AS `pair_unc`,`h`.`n` AS `n`,`h`.`pair_stdv` AS `stddev`,`h`.`sample_datetime` AS `ev_datetime`,`h`.`analysis_datetime` AS `a_datetime`,`h`.`sample_id` AS `flask_id`,`h`.`sample_type` AS `me`,cast(`h`.`sample_datetime` as date) AS `ev_date`,cast(`h`.`analysis_datetime` as date) AS `a_date`,`h`.`pair_avg` AS `value`,-999.99 AS `unc` from ((((`hats`.`prs_pair_avg_view` `h` join `gmd`.`project` `prj` on(`prj`.`num` = 6)) join `ccgg`.`strategy` `str` on(`str`.`num` = 1)) join `gmd`.`program` `prg` on(`prg`.`num` = 8)) join `gmd`.`site` `s` on(`s`.`num` = `h`.`site_num`)) union select `h`.`site_num` AS `site_num`,`h`.`site` AS `site`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`str`.`num` AS `strategy_num`,`str`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,`h`.`parameter` AS `parameter`,`h`.`parameter_num` AS `parameter_num`,`h`.`inst_num` AS `inst_num`,`h`.`inst_id` AS `inst_id`,`h`.`sample_datetime` AS `ev_datetime`,`h`.`analysis_datetime` AS `analysis_datetime`,`h`.`sample_id` AS `sample_id`,`h`.`sample_type` AS `sample_method`,`s`.`elev` AS `alt`,`s`.`lat` AS `lat`,`s`.`lon` AS `lon`,`s`.`elev` AS `elev`,0 AS `data_num`,0 AS `event_num`,`h`.`pair_id_num` AS `pair_id_num`,`h`.`pair_avg` AS `pair_avg`,-999.99 AS `pair_unc`,`h`.`n` AS `n`,`h`.`pair_stdv` AS `stddev`,`h`.`sample_datetime` AS `ev_datetime`,`h`.`analysis_datetime` AS `a_datetime`,`h`.`sample_id` AS `flask_id`,`h`.`sample_type` AS `me`,cast(`h`.`sample_datetime` as date) AS `ev_date`,cast(`h`.`analysis_datetime` as date) AS `a_date`,`h`.`pair_avg` AS `value`,-999.99 AS `unc` from ((((`hats`.`ng_pair_avg_view` `h` join `gmd`.`site` `s` on(`s`.`num` = `h`.`site_num`)) join `gmd`.`project` `prj` on(`prj`.`num` = 6)) join `ccgg`.`strategy` `str` on(`str`.`num` = 1)) join `gmd`.`program` `prg` on(`prg`.`num` = 8)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `hats_data_view`
--

/*!50001 DROP TABLE IF EXISTS `hats_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `hats_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `hats_data_view` AS select `d`.`num` AS `data_num`,`d`.`event_num` AS `event_num`,`a`.`num` AS `analysis_num`,`d`.`parameter_num` AS `parameter_num`,`d`.`value` AS `value`,`a`.`inst_num` AS `inst_num` from (((`ccgg`.`flask_data` `d` join `hats`.`analysis` `a`) join `ccgg`.`inst_description` `i`) join `hats`.`mole_fractions` `m`) where `d`.`event_num` = `a`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `d`.`program_num` = 8 and `d`.`inst` = `i`.`id` and `i`.`num` = `a`.`inst_num` and `a`.`inst_num` in (46,47,54,58) and `a`.`num` = `m`.`analysis_num` and `d`.`parameter_num` = `m`.`parameter_num` and timestamp(`d`.`date`,`d`.`time`) = `a`.`analysis_datetime` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `insitu_data_tag_view`
--

/*!50001 DROP TABLE IF EXISTS `insitu_data_tag_view`*/;
/*!50001 DROP VIEW IF EXISTS `insitu_data_tag_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `insitu_data_tag_view` AS select `dr`.`insitu_num` AS `insitu_num`,`dr`.`range_num` AS `range_num`,`r`.`comment` AS `tag_comment`,`r`.`prelim` AS `prelim`,`r`.`description` AS `description`,`r`.`data_source` AS `data_source`,`t`.`tag_num` AS `tag_num`,`t`.`internal_flag` AS `internal_flag`,`t`.`display_name` AS `display_name`,`t`.`group_name` AS `group_name`,`t`.`group_name2` AS `group_name2`,`t`.`sort_order` AS `sort_order`,`t`.`sort_order2` AS `sort_order2`,`t`.`sort_order3` AS `sort_order3`,`t`.`sort_order4` AS `sort_order4`,`t`.`hats_sort` AS `hats_sort`,`t`.`num` AS `num`,`t`.`deprecated` AS `deprecated`,`t`.`flag` AS `flag`,`t`.`name` AS `name`,`t`.`short_name` AS `short_name`,`t`.`reject` AS `reject`,`t`.`reject_min_severity` AS `reject_min_severity`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`unknown_issue` AS `unknown_issue`,`t`.`automated` AS `automated`,`t`.`comment` AS `comment`,`t`.`min_severity` AS `min_severity`,`t`.`max_severity` AS `max_severity`,`t`.`last_modified` AS `last_modified`,`t`.`hats_perseus` AS `hats_perseus`,`t`.`hats_ng` AS `hats_ng`,`t`.`exclusion` AS `exclusion`,`t`.`prelim_data` AS `prelim_data`,`t`.`parent_tag_num` AS `parent_tag_num`,`t`.`project_num` AS `project_num`,`t`.`program_num` AS `program_num`,`t`.`strategy_num` AS `strategy_num`,`t`.`parameter_num` AS `parameter_num`,`t`.`inst_num` AS `inst_num`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff` from ((`ccgg`.`insitu_data_tag_range` `dr` join `ccgg`.`tag_ranges` `r`) join `ccgg`.`tag_view` `t`) where `dr`.`range_num` = `r`.`num` and `r`.`tag_num` = `t`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `insitu_hour_view`
--

/*!50001 DROP TABLE IF EXISTS `insitu_hour_view`*/;
/*!50001 DROP VIEW IF EXISTS `insitu_hour_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `insitu_hour_view` AS select `d`.`num` AS `num`,`s`.`code` AS `site`,`d`.`site_num` AS `site_num`,`p`.`formula` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,cast(`d`.`date` as date) AS `date`,`d`.`intake_ht` AS `intake_ht`,`d`.`value` AS `value`,`d`.`std_dev` AS `std_dev`,`d`.`unc` AS `unc`,`d`.`n` AS `n`,`d`.`flag` AS `flag`,`d`.`system` AS `system`,`d`.`inst_num` AS `inst_num`,`i`.`id` AS `inst`,`s`.`lat` AS `lat`,`s`.`lon` AS `lon`,`s`.`elev` AS `elev`,`s`.`elev` + `d`.`intake_ht` AS `alt`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`st`.`num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,hour(`d`.`date`) AS `hour` from ((((((`ccgg`.`insitu_hour` `d` join `ccgg`.`inst_description` `i` on(`d`.`inst_num` = `i`.`num`)) join `gmd`.`site` `s` on(`s`.`num` = `d`.`site_num`)) join `gmd`.`parameter` `p` on(`p`.`num` = `d`.`parameter_num`)) join `gmd`.`project` `prj` on(`prj`.`num` = case when `d`.`site_num` in (15,73,75,112,113) then 4 else 3 end)) join `ccgg`.`strategy` `st` on(`st`.`num` = 3)) join `gmd`.`program` `prg` on(`prg`.`num` = 1)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `insitu_view`
--

/*!50001 DROP TABLE IF EXISTS `insitu_view`*/;
/*!50001 DROP VIEW IF EXISTS `insitu_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `insitu_view` AS select `d`.`num` AS `num`,`s`.`code` AS `site`,`d`.`site_num` AS `site_num`,`p`.`formula` AS `parameter`,`d`.`parameter_num` AS `parameter_num`,`d`.`date` AS `date`,`d`.`intake_ht` AS `intake_ht`,`d`.`value` AS `value`,`d`.`std_dev` AS `std_dev`,`d`.`meas_unc` AS `meas_unc`,`d`.`random_unc` AS `random_unc`,`d`.`n` AS `n`,`d`.`flag` AS `flag`,`d`.`inlet` AS `inlet`,`d`.`target` AS `target`,`d`.`system` AS `system`,`d`.`inst_num` AS `inst_num`,`i`.`id` AS `inst`,`d`.`comment` AS `comment`,`s`.`lat` AS `lat`,`s`.`lon` AS `lon`,`s`.`elev` AS `elev`,`s`.`elev` + `d`.`intake_ht` AS `alt`,`prj`.`num` AS `project_num`,`prj`.`abbr` AS `project`,`st`.`num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`prg`.`num` AS `program_num`,`prg`.`abbr` AS `program`,hour(`d`.`date`) AS `hr`,minute(`d`.`date`) AS `min`,second(`d`.`date`) AS `sec`,`f_dt2dec`(`d`.`date`) AS `dd` from ((((((`ccgg`.`insitu_data` `d` join `ccgg`.`inst_description` `i` on(`d`.`inst_num` = `i`.`num`)) join `gmd`.`site` `s` on(`s`.`num` = `d`.`site_num`)) join `gmd`.`parameter` `p` on(`p`.`num` = `d`.`parameter_num`)) join `gmd`.`project` `prj` on(`prj`.`num` = case when `d`.`site_num` in (15,73,75,112,113) then 4 else 3 end)) join `ccgg`.`strategy` `st` on(`st`.`num` = 3)) join `gmd`.`program` `prg` on(`prg`.`num` = 1)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `inst_event_view`
--

/*!50001 DROP TABLE IF EXISTS `inst_event_view`*/;
/*!50001 DROP VIEW IF EXISTS `inst_event_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `inst_event_view` AS select `e`.`num` AS `inst_event_num`,`e`.`inst_num` AS `inst_num`,`e`.`date` AS `date`,`e`.`event_type_num` AS `event_type_num`,`t`.`abbr` AS `event_type_abbr`,`t`.`name` AS `event_type_name`,`e`.`comment` AS `comment`,`e`.`site_num` AS `site_num`,`s`.`code` AS `site`,`s`.`name` AS `site_name`,`e`.`pi` AS `pi`,`e`.`project_name` AS `project_name`,`e`.`repair_reason` AS `repair_reason`,`t`.`is_repair` AS `is_repair`,`t`.`is_h2o_cal` AS `is_h2o_cal`,`t`.`is_lab_cal` AS `is_lab_cal`,`t`.`can_be_available_for_use` AS `can_be_available_for_use`,`t`.`is_comment` AS `is_comment`,`t`.`is_deployed` AS `is_deployed`,`t`.`is_retired` AS `is_retired`,`t`.`is_out_for_repair` AS `is_out_for_repair`,case when `t`.`is_h2o_cal` = 1 or `t`.`is_lab_cal` = 1 then 'Calibration' else `t`.`abbr` end AS `event_type`,case when `t`.`is_comment` = 1 then 0 when exists(select 1 from (`ccgg`.`inst_event` `e2` join `ccgg`.`inst_event_types` `t2` on(`e2`.`event_type_num` = `t2`.`num`)) where `e2`.`inst_num` = `e`.`inst_num` and `e2`.`date` >= `e`.`date` and `e2`.`num` <> `e`.`num` and `t2`.`is_comment` = 0 limit 1) then 0 else 1 end AS `current` from ((`ccgg`.`inst_event` `e` join `ccgg`.`inst_event_types` `t` on(`e`.`event_type_num` = `t`.`num`)) left join `gmd`.`site` `s` on(`s`.`num` = `e`.`site_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `inst_view`
--

/*!50001 DROP TABLE IF EXISTS `inst_view`*/;
/*!50001 DROP VIEW IF EXISTS `inst_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `inst_view` AS select `i`.`num` AS `inst_num`,`i`.`id` AS `id`,`proj`.`abbr` AS `project`,`i`.`project_num` AS `project_num`,`m`.`Name` AS `manufacturer`,`i`.`inst_manuf_num` AS `inst_manuf_num`,`i`.`model` AS `model`,`i`.`manuf_year` AS `manuf_year`,`i`.`serial_number` AS `serial_number`,`t`.`abbr` AS `inst_type`,`i`.`inst_type_num` AS `inst_type_num`,`i`.`property_number` AS `property_number`,`i`.`comments` AS `comments`,`o`.`abbr` AS `owner`,`i`.`inst_owner_other` AS `other_owner`,`i`.`os` AS `os`,`i`.`motherboard` AS `motherboard`,`i`.`ram` AS `ram`,`i`.`teamviewer_id` AS `teamviewer_id`,`e`.`inst_event_num` AS `curr_event_num`,`e`.`event_type` AS `curr_event_type`,`e`.`event_type_num` AS `curr_event_type_num`,`e`.`site_num` AS `site_num`,`e`.`site` AS `site`,`e`.`site_name` AS `site_name`,(select max(`inst_event_view`.`date`) from `ccgg`.`inst_event_view` where `inst_event_view`.`inst_num` = `i`.`num` and `inst_event_view`.`is_h2o_cal` = 1) AS `last_h2o_cal`,(select max(`inst_event_view`.`date`) from `ccgg`.`inst_event_view` where `inst_event_view`.`inst_num` = `i`.`num` and `inst_event_view`.`is_lab_cal` = 1) AS `last_lab_cal`,case when `e`.`can_be_available_for_use` is null then 1 else `e`.`can_be_available_for_use` end AS `can_be_available_for_use`,case when `e`.`can_be_available_for_use` = 0 then 0 else `i`.`is_available_for_use` end AS `is_available_for_use`,case when `e`.`is_deployed` = 1 then NULL else `l`.`num` end AS `inst_location_num`,case when `e`.`is_deployed` = 1 then NULL else `l`.`abbr` end AS `loc_abbr`,case when `e`.`is_deployed` = 1 then NULL else `l`.`name` end AS `location`,case when `e`.`is_deployed` is null then 0 else `e`.`is_deployed` end AS `is_deployed`,case when `e`.`is_retired` is null then 0 else `e`.`is_retired` end AS `is_retired`,case when `e`.`is_out_for_repair` is null then 0 else `e`.`is_out_for_repair` end AS `is_out_for_repair`,`c`.`name` AS `contact` from (((((((`ccgg`.`inst_description` `i` left join `gmd`.`project` `proj` on(`proj`.`num` = `i`.`project_num`)) left join `ccgg`.`inst_manufacturer` `m` on(`m`.`num` = `i`.`inst_manuf_num`)) left join `ccgg`.`inst_type` `t` on(`t`.`num` = `i`.`inst_type_num`)) left join `ccgg`.`inst_event_view` `e` on(`i`.`num` = `e`.`inst_num` and `e`.`current` = 1)) left join `ccgg`.`inst_owner` `o` on(`i`.`inst_owner_num` = `o`.`num`)) left join `ccgg`.`contact` `c` on(`i`.`contact_num` = `c`.`num`)) left join `ccgg`.`inst_locations` `l` on(`l`.`num` = `i`.`inst_location_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `mobile_insitu_data_view`
--

/*!50001 DROP TABLE IF EXISTS `mobile_insitu_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `mobile_insitu_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `mobile_insitu_data_view` AS select `d`.`num` AS `num`,`d`.`num` AS `data_num`,`e`.`event_num` AS `event_num`,`e`.`site_num` AS `site_num`,`e`.`site` AS `site`,`e`.`project_num` AS `project_num`,`e`.`project` AS `project`,`e`.`strategy_num` AS `strategy_num`,`e`.`strategy` AS `strategy`,`d`.`program_num` AS `program_num`,`prog`.`abbr` AS `program`,`i`.`abbr` AS `instrument`,`i`.`num` AS `inst_num`,`d`.`parameter_num` AS `parameter_num`,`pa`.`formula` AS `parameter`,`e`.`datetime` AS `ev_datetime`,`e`.`ev_date` AS `ev_date`,`e`.`ev_time` AS `ev_time`,`e`.`ev_dd` AS `ev_dd`,`e`.`expedition_id` AS `expedition_id`,`e`.`profile_num` AS `profile_num`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`d`.`value` AS `value`,`d`.`stddev` AS `stddev`,`d`.`n` AS `n`,`d`.`unc` AS `unc`,`d`.`flag` AS `flag`,`e`.`intake_id` AS `intake_id`,`d`.`interval_sec` AS `interval_sec`,`e`.`vehicle_num` AS `vehicle_num`,`e`.`vehicle` AS `vehicle`,`e`.`vehicle_abbr` AS `vehicle_abbr`,`e`.`airplane` AS `airplane`,`e`.`boat` AS `boat`,`e`.`automobile` AS `automobile`,`e`.`campaign_abbr` AS `campaign_abbr`,`e`.`campaign_name` AS `campaign_name` from ((((`ccgg`.`mobile_insitu_event_view` `e` join `ccgg`.`mobile_insitu_data` `d` on(`e`.`num` = `d`.`event_num`)) join `gmd`.`program` `prog` on(`d`.`program_num` = `prog`.`num`)) join `gmd`.`parameter` `pa` on(`d`.`parameter_num` = `pa`.`num`)) left join `ccgg`.`mobile_insitu_instruments` `i` on(`i`.`num` = `d`.`mobile_insitu_inst_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `mobile_insitu_event_view`
--

/*!50001 DROP TABLE IF EXISTS `mobile_insitu_event_view`*/;
/*!50001 DROP VIEW IF EXISTS `mobile_insitu_event_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `mobile_insitu_event_view` AS select `e`.`num` AS `num`,`e`.`num` AS `event_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`e`.`datetime` AS `datetime`,`e`.`datetime` AS `ev_datetime`,cast(`e`.`datetime` as date) AS `ev_date`,cast(`e`.`datetime` as time) AS `ev_time`,`f_dt2dec`(`e`.`datetime`) AS `dd`,`f_dt2dec`(`e`.`datetime`) AS `ev_dd`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`elev_source` AS `elev_source`,`e`.`expedition_id` AS `expedition_id`,`e`.`intake_id` AS `intake_id`,`e`.`profile_num` AS `profile_num`,`e`.`vehicle_num` AS `vehicle_num`,`v`.`abbr` AS `vehicle`,`v`.`abbr` AS `vehicle_abbr`,`vt`.`airplane` AS `airplane`,`vt`.`boat` AS `boat`,`vt`.`automobile` AS `automobile`,`c`.`abbr` AS `campaign_abbr`,`c`.`name` AS `campaign_name` from ((((((`ccgg`.`mobile_insitu_event` `e` join `gmd`.`site` `si` on(`e`.`site_num` = `si`.`num`)) join `gmd`.`project` `proj` on(`e`.`project_num` = `proj`.`num`)) join `ccgg`.`strategy` `st` on(`e`.`strategy_num` = `st`.`num`)) left join `ccgg`.`vehicle` `v` on(`v`.`num` = `e`.`vehicle_num`)) left join `ccgg`.`vehicle_types` `vt` on(`v`.`vehicle_type_num` = `vt`.`num`)) left join `obspack`.`campaign` `c` on(`c`.`num` = `e`.`campaign_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `releaseable_flask_data_view`
--

/*!50001 DROP TABLE IF EXISTS `releaseable_flask_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `releaseable_flask_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `releaseable_flask_data_view` AS select case when `p`.`data_num` is not null then 1 when `v`.`program_num` <> 8 and `rp`.`site_num` is null and `re`.`site_num` is null then 1 when ucase(`rp`.`data`) = 'S' and `rp`.`begin` <= `v`.`ev_date` and `rp`.`end` >= `v`.`ev_date` or ucase(`rp`.`data`) = 'M' and `rp`.`begin` <= `v`.`a_date` and `rp`.`end` >= `v`.`a_date` then 1 else 0 end AS `prelim`,case when `e`.`data_num` is not null then 1 when ucase(`re`.`data`) = 'S' and `re`.`begin` <= `v`.`ev_date` and `re`.`end` >= `v`.`ev_date` or ucase(`re`.`data`) = 'M' and `re`.`begin` <= `v`.`a_date` and `re`.`end` >= `v`.`a_date` then 1 else 0 end AS `excluded`,`v`.`data_num` AS `data_num`,`v`.`event_num` AS `event_num`,`v`.`site_num` AS `site_num`,`v`.`project_num` AS `project_num`,`v`.`strategy_num` AS `strategy_num`,`v`.`program_num` AS `program_num`,`v`.`parameter_num` AS `parameter_num`,`v`.`ev_date` AS `ev_date`,`v`.`ev_time` AS `ev_time`,`v`.`ev_dd` AS `ev_dd`,`v`.`ev_datetime` AS `ev_datetime`,`v`.`a_date` AS `a_date`,`v`.`a_time` AS `a_time`,`v`.`a_dd` AS `a_dd`,`v`.`a_datetime` AS `a_datetime`,`v`.`inst` AS `inst`,`v`.`flag` AS `flag`,`v`.`method` AS `method` from ((((`ccgg`.`flask_ev_data_view` `v` left join `ccgg`.`flask_data_tag_view` `p` on(`v`.`data_num` = `p`.`data_num` and `p`.`prelim_data` = 1)) left join `ccgg`.`flask_data_tag_view` `e` on(`v`.`data_num` = `e`.`data_num` and `e`.`exclusion` = 1)) left join `ccgg`.`data_release` `re` on(`re`.`site_num` = `v`.`site_num` and `re`.`project_num` = `v`.`project_num` and `re`.`strategy_num` = `v`.`strategy_num` and `re`.`program_num` = `v`.`program_num` and `re`.`parameter_num` = `v`.`parameter_num` and ucase(`re`.`type`) = 'E')) left join `ccgg`.`data_release` `rp` on(`rp`.`site_num` = `v`.`site_num` and `rp`.`project_num` = `v`.`project_num` and `rp`.`strategy_num` = `v`.`strategy_num` and `rp`.`program_num` = `v`.`program_num` and `rp`.`parameter_num` = `v`.`parameter_num` and ucase(`rp`.`type`) = 'P')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tag_list`
--

/*!50001 DROP TABLE IF EXISTS `tag_list`*/;
/*!50001 DROP VIEW IF EXISTS `tag_list`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`140.172.193.%` SQL SECURITY DEFINER */
/*!50001 VIEW `tag_list` AS select `tag_view`.`num` AS `Tag_number`,`tag_view`.`name` AS `Name`,`tag_view`.`group_name` AS `Tag_Type`,case when `tag_view`.`reject` = 1 then 'Reject' when `tag_view`.`selection` = 1 then 'Selection' when `tag_view`.`information` = 1 then 'Information' else '' end AS `Severity`,`tag_view`.`internal_flag` AS `Old_style_flag` from `ccgg`.`tag_view` order by `tag_view`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tag_range_info_view`
--

/*!50001 DROP TABLE IF EXISTS `tag_range_info_view`*/;
/*!50001 DROP VIEW IF EXISTS `tag_range_info_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tag_range_info_view` AS select `r`.`num` AS `range_num`,`r`.`tag_num` AS `tag_num`,`r`.`comment` AS `tag_comment`,`r`.`description` AS `tag_description`,`r`.`prelim` AS `prelim`,`r`.`json_selection_criteria` AS `json_selection_criteria`,`r`.`data_source` AS `data_source`,`t`.`display_name` AS `display_name`,`t`.`internal_flag` AS `internal_flag`,`t`.`flag` AS `flag`,`t`.`reject` AS `reject`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`group_name` AS `group_name`,`t`.`sort_order` AS `sort_order`,`t`.`sort_order2` AS `sort_order2`,`t`.`automated` AS `automated` from (`ccgg`.`tag_view` `t` join `ccgg`.`tag_ranges` `r`) where `t`.`num` = `r`.`tag_num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tag_view`
--

/*!50001 DROP TABLE IF EXISTS `tag_view`*/;
/*!50001 DROP VIEW IF EXISTS `tag_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `tag_view` AS select `t`.`num` AS `tag_num`,concat(case when `t`.`reject` = 1 then ifnull(`t`.`flag`,'?') else '.' end,case when `t`.`selection` = 1 then ifnull(`t`.`flag`,'?') else '.' end,case when `t`.`information` = 1 then ifnull(`t`.`flag`,'?') else '.' end) AS `internal_flag`,convert(case when `t`.`reject` = 0 and `t`.`selection` = 0 and `t`.`information` = 0 then concat_ws(' - ',`t`.`flag`,`t`.`name`) else concat(case when `t`.`parent_tag_num` > 0 then '    ' else '' end,'(',case when `t`.`reject` = 1 then ifnull(`t`.`flag`,'?') else '.' end,case when `t`.`selection` = 1 then ifnull(`t`.`flag`,'?') else '.' end,case when `t`.`information` = 1 then ifnull(`t`.`flag`,'?') else '.' end,') ',`t`.`name`,case when `t`.`automated` = 1 then ' (automatic)' else '' end,' [',`t`.`num`,']') end using latin1) collate latin1_general_cs AS `display_name`,convert(concat_ws(' ',`proj`.`abbr`,`str`.`abbr`,case when `prg`.`num` = 8 and `t`.`hats_perseus` = 1 and `t`.`hats_ng` = 1 then 'HATS' when `prg`.`num` = 8 and `t`.`hats_perseus` = 1 then 'Perseus' when `prg`.`num` = 8 and `t`.`hats_ng` = 1 then 'Fe/M*' else `prg`.`abbr` end,`pa`.`formula`,case when `t`.`collection_issue` = 1 then 'Collection issues' when `t`.`measurement_issue` = 1 then 'Measurement issues' when `t`.`selection_issue` = 1 then 'Selection issues' when `t`.`unknown_issue` = 1 then 'Unknown issues' when `t`.`hats_interpolation` = 1 then 'Interpolation' else '' end) using latin1) collate latin1_general_cs AS `group_name`,trim(convert(concat_ws(' ',case when `t`.`automated` = 1 then 'Automated' else '' end,`proj`.`abbr`,`str`.`abbr`,case when `prg`.`num` = 8 and `t`.`hats_perseus` = 1 and `t`.`hats_ng` = 1 then 'HATS' when `prg`.`num` = 8 and `t`.`hats_perseus` = 1 then 'Perseus' when `prg`.`num` = 8 and `t`.`hats_ng` = 1 then 'Fe/M*' else `prg`.`abbr` end,`pa`.`formula`,case when `t`.`collection_issue` = 1 then 'Collection issues' when `t`.`measurement_issue` = 1 then 'Measurement issues' when `t`.`selection_issue` = 1 then 'Selection issues' when `t`.`unknown_issue` = 1 then 'Unknown issues' when `t`.`hats_interpolation` = 1 then 'Interpolation' else '' end) using latin1) collate latin1_general_cs) AS `group_name2`,convert(concat_ws(' ',case when `t`.`collection_issue` = 1 then '0' else '1' end,case when `t`.`measurement_issue` = 1 then '0' else '1' end,case when `t`.`selection_issue` = 1 then '0' else '1' end,case when `t`.`unknown_issue` = 1 then '0' else '1' end,ifnull(`proj`.`num`,0) + ifnull(`str`.`num`,0) + ifnull(`prg`.`num`,0) + ifnull(`pa`.`num`,0),case when `proj`.`num` is not null then '0' else '1' end,case when `str`.`num` is not null then '0' else '1' end,case when `prg`.`num` is not null then '0' else '1' end,case when `pa`.`num` is not null then '0' else '1' end,`proj`.`abbr`,`str`.`abbr`,`prg`.`abbr`,`pa`.`formula`,`t`.`flag`,`t`.`automated`,`t`.`parent_tag_num`,`t`.`name`) using latin1) collate latin1_general_cs AS `sort_order`,convert(concat_ws(' ',case when `t`.`collection_issue` = 1 then '0' else '1' end,case when `t`.`measurement_issue` = 1 then '0' else '1' end,case when `t`.`selection_issue` = 1 then '0' else '1' end,case when `t`.`unknown_issue` = 1 then '0' else '1' end,ifnull(`proj`.`num`,0) + ifnull(`str`.`num`,0) + ifnull(`prg`.`num`,0) + ifnull(`pa`.`num`,0),case when `proj`.`num` is not null then '0' else '1' end,case when `str`.`num` is not null then '0' else '1' end,case when `prg`.`num` is not null then '0' else '1' end,case when `pa`.`num` is not null then '0' else '1' end,`proj`.`abbr`,`str`.`abbr`,`prg`.`abbr`,`pa`.`formula`,`t`.`automated`,`t`.`parent_tag_num`,`t`.`name`) using latin1) collate latin1_general_cs AS `sort_order2`,convert(concat_ws(' ',case when `t`.`measurement_issue` = 1 then '0' else '1' end,case when `t`.`collection_issue` = 1 then '0' else '1' end,case when `t`.`selection_issue` = 1 then '0' else '1' end,case when `t`.`unknown_issue` = 1 then '0' else '1' end,ifnull(`proj`.`num`,0) + ifnull(`str`.`num`,0) + ifnull(`prg`.`num`,0) + ifnull(`pa`.`num`,0),case when `proj`.`num` is not null then '0' else '1' end,case when `str`.`num` is not null then '0' else '1' end,case when `prg`.`num` is not null then '0' else '1' end,case when `pa`.`num` is not null then '0' else '1' end,`proj`.`abbr`,`str`.`abbr`,`prg`.`abbr`,`pa`.`formula`,`t`.`flag`,`t`.`automated`,`t`.`parent_tag_num`,`t`.`name`) using latin1) collate latin1_general_cs AS `sort_order3`,convert(concat_ws(' ',case when `t`.`collection_issue` = 1 then '0' else '1' end,case when `t`.`measurement_issue` = 1 then '0' else '1' end,case when `t`.`selection_issue` = 1 then '0' else '1' end,case when `t`.`unknown_issue` = 1 then '0' else '1' end,ifnull(`proj`.`num`,0) + ifnull(`str`.`num`,0) + ifnull(`prg`.`num`,0) + ifnull(`pa`.`num`,0),case when `proj`.`num` is not null then '0' else '1' end,case when `str`.`num` is not null then '0' else '1' end,case when `prg`.`num` is not null then '0' else '1' end,case when `pa`.`num` is not null then '0' else '1' end,`proj`.`abbr`,`str`.`abbr`,`prg`.`abbr`,`pa`.`formula`,`t`.`automated`,`t`.`flag`,`t`.`parent_tag_num`,`t`.`name`) using latin1) collate latin1_general_cs AS `sort_order4`,convert(concat_ws(' ',case when `t`.`hats_interpolation` = 1 then '0' else '1' end,case when `t`.`measurement_issue` = 1 then '0' else '1' end,case when `t`.`collection_issue` = 1 then '0' else '1' end,case when `t`.`selection_issue` = 1 then '0' else '1' end,case when `t`.`unknown_issue` = 1 then '0' else '1' end,ifnull(`proj`.`num`,0) + ifnull(`str`.`num`,0) + ifnull(`prg`.`num`,0) + ifnull(`pa`.`num`,0),case when `proj`.`num` is not null then '0' else '1' end,case when `str`.`num` is not null then '0' else '1' end,case when `prg`.`num` is not null then '0' else '1' end,case when `pa`.`num` is not null then '0' else '1' end,`proj`.`abbr`,`str`.`abbr`,`prg`.`abbr`,`pa`.`formula`,`t`.`flag`,`t`.`automated`,`t`.`parent_tag_num`,`t`.`name`) using latin1) collate latin1_general_cs AS `hats_sort`,`t`.`num` AS `num`,`t`.`deprecated` AS `deprecated`,`t`.`flag` AS `flag`,`t`.`name` AS `name`,`t`.`short_name` AS `short_name`,`t`.`reject` AS `reject`,`t`.`reject_min_severity` AS `reject_min_severity`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`unknown_issue` AS `unknown_issue`,`t`.`automated` AS `automated`,`t`.`comment` AS `comment`,`t`.`min_severity` AS `min_severity`,`t`.`max_severity` AS `max_severity`,`t`.`last_modified` AS `last_modified`,`t`.`hats_perseus` AS `hats_perseus`,`t`.`hats_ng` AS `hats_ng`,`t`.`exclusion` AS `exclusion`,`t`.`prelim_data` AS `prelim_data`,`t`.`parent_tag_num` AS `parent_tag_num`,`t`.`project_num` AS `project_num`,`t`.`program_num` AS `program_num`,`t`.`strategy_num` AS `strategy_num`,`t`.`parameter_num` AS `parameter_num`,`t`.`inst_num` AS `inst_num`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff` from ((((`ccgg`.`tag_dictionary` `t` left join `gmd`.`project` `proj` on(`t`.`project_num` = `proj`.`num`)) left join `ccgg`.`strategy` `str` on(`t`.`strategy_num` = `str`.`num`)) left join `gmd`.`program` `prg` on(`t`.`program_num` = `prg`.`num`)) left join `gmd`.`parameter` `pa` on(`t`.`parameter_num` = `pa`.`num`)) */;
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

-- Dump completed on 2025-04-17 10:06:01
