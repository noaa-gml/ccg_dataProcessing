-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: icp
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
-- Table structure for table `_data`
--

DROP TABLE IF EXISTS `_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `abp_data`
--

DROP TABLE IF EXISTS `abp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregate_periods`
--

DROP TABLE IF EXISTS `aggregate_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregate_periods` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) DEFAULT NULL,
  `abbr` varchar(45) DEFAULT NULL,
  `granularity_sort` int(11) DEFAULT NULL,
  `default_match` int(11) DEFAULT NULL,
  `default_timeseries` int(11) DEFAULT NULL,
  `insitu_exact_match` int(11) DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `akd_data`
--

DROP TABLE IF EXISTS `akd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `akd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `all_data`
--

DROP TABLE IF EXISTS `all_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `all_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alt_data`
--

DROP TABLE IF EXISTS `alt_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alt_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amt_data`
--

DROP TABLE IF EXISTS `amt_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amt_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `amy_data`
--

DROP TABLE IF EXISTS `amy_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amy_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asc_data`
--

DROP TABLE IF EXISTS `asc_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asc_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bao_data`
--

DROP TABLE IF EXISTS `bao_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bao_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bck_data`
--

DROP TABLE IF EXISTS `bck_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bck_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bcs_data`
--

DROP TABLE IF EXISTS `bcs_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bcs_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bhd_data`
--

DROP TABLE IF EXISTS `bhd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bhd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bra_data`
--

DROP TABLE IF EXISTS `bra_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bra_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brw_data`
--

DROP TABLE IF EXISTS `brw_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brw_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bwd_data`
--

DROP TABLE IF EXISTS `bwd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bwd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calibrated_tanks`
--

DROP TABLE IF EXISTS `calibrated_tanks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrated_tanks` (
  `site_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `id` varchar(45) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `strategy_num` int(11) NOT NULL COMMENT 'This is strategy of the stored, measured result, ie magicc target, tst flasks Obs target…',
  `p1` decimal(12,4) NOT NULL COMMENT 'parameter 1 for adjusted assigned value, the assigned value if no other parameters passed.',
  `p2` decimal(12,4) DEFAULT 0.0000,
  `p3` decimal(12,4) DEFAULT 0.0000,
  `p4` decimal(12,4) DEFAULT 0.0000,
  `p5` decimal(12,4) DEFAULT 0.0000,
  `zero_dd` double(14,9) NOT NULL COMMENT 'Date of first calibration episode',
  `type` varchar(45) NOT NULL DEFAULT '' COMMENT 'type, level, method… this is to record which target tank it is (tgt, tgt1, tgt2…)',
  `unc` decimal(12,4) DEFAULT NULL COMMENT 'Note; most calibrated tanks get unc from tmp.f_expanded_uncertainty().  RRI have explicit unc stored here',
  PRIMARY KEY (`site_num`,`parameter_num`,`id`,`start_date`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Contains assigned values for target and test flask source tanks. End date is non-inclusive.  zero_dd is date of first calibration episode, P1 p2 p3 p4 p5 are parameters to calculate adjusted assigned value.  All can be zero, use function f_tankDrifValue to get adjusted assigned value.  See it for comments.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cba_data`
--

DROP TABLE IF EXISTS `cba_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cba_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdl_data`
--

DROP TABLE IF EXISTS `cdl_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdl_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cei_data`
--

DROP TABLE IF EXISTS `cei_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cei_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ceivpdb_data`
--

DROP TABLE IF EXISTS `ceivpdb_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ceivpdb_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cgo_data`
--

DROP TABLE IF EXISTS `cgo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cgo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chl_data`
--

DROP TABLE IF EXISTS `chl_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chl_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chm_data`
--

DROP TABLE IF EXISTS `chm_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chm_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chr_data`
--

DROP TABLE IF EXISTS `chr_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chr_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chs_data`
--

DROP TABLE IF EXISTS `chs_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chs_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cib_data`
--

DROP TABLE IF EXISTS `cib_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cib_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `corrections`
--

DROP TABLE IF EXISTS `corrections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `corrections` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `parameter_num` int(11) NOT NULL,
  `correction` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cps_data`
--

DROP TABLE IF EXISTS `cps_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cps_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cpt_data`
--

DROP TABLE IF EXISTS `cpt_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cpt_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crv_data`
--

DROP TABLE IF EXISTS `crv_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crv_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dai_data`
--

DROP TABLE IF EXISTS `dai_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dai_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dan_data`
--

DROP TABLE IF EXISTS `dan_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dan_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_summary`
--

DROP TABLE IF EXISTS `data_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_summary` (
  `site_num` smallint(5) unsigned NOT NULL,
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `first` date NOT NULL,
  `last` date NOT NULL,
  PRIMARY KEY (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_summary2`
--

DROP TABLE IF EXISTS `data_summary2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_summary2` (
  `site_num` int(11) DEFAULT NULL,
  `lab_num` int(11) DEFAULT NULL,
  `icpstrat_num` int(11) DEFAULT NULL,
  `parameter_num` int(11) DEFAULT NULL,
  `period_num` bigint(20) NOT NULL DEFAULT 0,
  `inst` varchar(45) DEFAULT NULL,
  `method` varchar(45) DEFAULT NULL,
  `intake_height` float DEFAULT NULL,
  `first` datetime DEFAULT NULL,
  `last` datetime DEFAULT NULL,
  `num_rows` bigint(21) NOT NULL DEFAULT 0,
  UNIQUE KEY `i` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`period_num`,`inst`,`method`,`intake_height`),
  KEY `i2` (`lab_num`,`site_num`),
  KEY `i4` (`icpstrat_num`),
  KEY `i5` (`parameter_num`),
  KEY `i6` (`inst`),
  KEY `lab` (`lab_num`,`icpstrat_num`,`site_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='for icp2 sample_data and insitu_data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `data_summary2_view`
--

DROP TABLE IF EXISTS `data_summary2_view`;
/*!50001 DROP VIEW IF EXISTS `data_summary2_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `data_summary2_view` (
  `site` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `first` tinyint NOT NULL,
  `last` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `inst` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `egb_data`
--

DROP TABLE IF EXISTS `egb_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `egb_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `esp_data`
--

DROP TABLE IF EXISTS `esp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `esp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `est_data`
--

DROP TABLE IF EXISTS `est_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `est_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `etl_data`
--

DROP TABLE IF EXISTS `etl_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `etl_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `flask_event_subsite_view`
--

DROP TABLE IF EXISTS `flask_event_subsite_view`;
/*!50001 DROP VIEW IF EXISTS `flask_event_subsite_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_event_subsite_view` (
  `subsite_num` tinyint NOT NULL,
  `num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `time` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `id` tinyint NOT NULL,
  `me` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `comment` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `fsd_data`
--

DROP TABLE IF EXISTS `fsd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fsd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ghg_data`
--

DROP TABLE IF EXISTS `ghg_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ghg_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hats_include_parameters`
--

DROP TABLE IF EXISTS `hats_include_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hats_include_parameters` (
  `parameter_num` int(11) NOT NULL,
  PRIMARY KEY (`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='list of parameters to include from hats';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hey_data`
--

DROP TABLE IF EXISTS `hey_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hey_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icpstrat`
--

DROP TABLE IF EXISTS `icpstrat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icpstrat` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `abbr` varchar(25) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  `comment` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `in1_data`
--

DROP TABLE IF EXISTS `in1_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `in1_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `in2_data`
--

DROP TABLE IF EXISTS `in2_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `in2_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insitu`
--

DROP TABLE IF EXISTS `insitu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu` (
  `num` bigint(20) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `icpstrat_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `period_num` int(11) NOT NULL DEFAULT 7,
  `date` date NOT NULL,
  `e_datetime` datetime NOT NULL,
  `method` varchar(45) NOT NULL DEFAULT '',
  `intake_height` float NOT NULL DEFAULT 0,
  `inst` varchar(45) NOT NULL DEFAULT ' ',
  `value` decimal(12,4) DEFAULT NULL,
  `unc` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) DEFAULT '...',
  `stddev` decimal(12,4) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`period_num`,`e_datetime`,`method`,`intake_height`,`inst`),
  KEY `i2` (`lab_num`,`site_num`),
  KEY `i3` (`date`),
  KEY `i` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3249163786 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `insitu_archive`
--

DROP TABLE IF EXISTS `insitu_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `insitu_archive` (
  `archive_datetime` datetime NOT NULL,
  `num` bigint(20) NOT NULL,
  `site_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `icpstrat_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `period_num` int(11) NOT NULL DEFAULT 7,
  `date` date NOT NULL,
  `e_datetime` datetime NOT NULL,
  `method` varchar(45) NOT NULL,
  `intake_height` float NOT NULL,
  `inst` varchar(45) NOT NULL,
  `value` decimal(12,4) DEFAULT NULL,
  `unc` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) DEFAULT NULL,
  `stddev` decimal(12,4) DEFAULT NULL,
  PRIMARY KEY (`num`,`archive_datetime`),
  KEY `i2` (`lab_num`,`site_num`),
  KEY `i3` (`date`),
  KEY `i` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `insitu_data_view`
--

DROP TABLE IF EXISTS `insitu_data_view`;
/*!50001 DROP VIEW IF EXISTS `insitu_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `insitu_data_view` (
  `num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `period_num` tinyint NOT NULL,
  `period` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `e_datetime` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `intake_height` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `stddev` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `inx_data`
--

DROP TABLE IF EXISTS `inx_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inx_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jsa_data`
--

DROP TABLE IF EXISTS `jsa_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jsa_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ker_data`
--

DROP TABLE IF EXISTS `ker_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ker_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kum_data`
--

DROP TABLE IF EXISTS `kum_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kum_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `laccalt_data`
--

DROP TABLE IF EXISTS `laccalt_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `laccalt_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `laccsu_data`
--

DROP TABLE IF EXISTS `laccsu_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `laccsu_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `laccsuf_data`
--

DROP TABLE IF EXISTS `laccsuf_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `laccsuf_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lacgrh_data`
--

DROP TABLE IF EXISTS `lacgrh_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lacgrh_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lacusc_data`
--

DROP TABLE IF EXISTS `lacusc_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lacusc_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lan_data`
--

DROP TABLE IF EXISTS `lan_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lan_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lef_data`
--

DROP TABLE IF EXISTS `lef_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lef_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lew_data`
--

DROP TABLE IF EXISTS `lew_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lew_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lfs_data`
--

DROP TABLE IF EXISTS `lfs_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lfs_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ljo_data`
--

DROP TABLE IF EXISTS `ljo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ljo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `llb_data`
--

DROP TABLE IF EXISTS `llb_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `llb_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lln_data`
--

DROP TABLE IF EXISTS `lln_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lln_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lmp_data`
--

DROP TABLE IF EXISTS `lmp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lmp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `site_num` smallint(5) unsigned NOT NULL,
  `user` varchar(20) NOT NULL,
  `datetime` datetime NOT NULL,
  `author` varchar(256) NOT NULL,
  `topic` varchar(256) NOT NULL,
  `text` blob NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_parameter`
--

DROP TABLE IF EXISTS `log_parameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_parameter` (
  `log_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  KEY `log_num` (`log_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `match_windows`
--

DROP TABLE IF EXISTS `match_windows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `match_windows` (
  `num` int(11) NOT NULL,
  `minutes` int(11) NOT NULL,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mbo_data`
--

DROP TABLE IF EXISTS `mbo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mbo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meni_data`
--

DROP TABLE IF EXISTS `meni_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meni_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mhd_data`
--

DROP TABLE IF EXISTS `mhd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mhd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mlo_data`
--

DROP TABLE IF EXISTS `mlo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mlo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mrc_data`
--

DROP TABLE IF EXISTS `mrc_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mrc_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `msh_data`
--

DROP TABLE IF EXISTS `msh_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `msh_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mvy_data`
--

DROP TABLE IF EXISTS `mvy_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mvy_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nat_data`
--

DROP TABLE IF EXISTS `nat_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nat_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `neb_data`
--

DROP TABLE IF EXISTS `neb_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `neb_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `no_import_from_icp1`
--

DROP TABLE IF EXISTS `no_import_from_icp1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `no_import_from_icp1` (
  `site_num` int(11) NOT NULL DEFAULT 0,
  `lab_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `strategy_num` int(11) NOT NULL,
  PRIMARY KEY (`site_num`,`lab_num`,`parameter_num`,`strategy_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nwb_data`
--

DROP TABLE IF EXISTS `nwb_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nwb_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nwr_data`
--

DROP TABLE IF EXISTS `nwr_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nwr_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nzd_data`
--

DROP TABLE IF EXISTS `nzd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nzd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `osi_data`
--

DROP TABLE IF EXISTS `osi_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osi_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oxk_data`
--

DROP TABLE IF EXISTS `oxk_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oxk_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pal_data`
--

DROP TABLE IF EXISTS `pal_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pal_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plot_config_users`
--

DROP TABLE IF EXISTS `plot_config_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plot_config_users` (
  `plot_config_num` int(11) NOT NULL,
  `user` varchar(45) NOT NULL,
  PRIMARY KEY (`user`,`plot_config_num`),
  KEY `i` (`plot_config_num`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='This table is used to store user specific plot configuration information.  It is editable by the ''readonly'' user used by the http server';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plot_configs`
--

DROP TABLE IF EXISTS `plot_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plot_configs` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `json` text NOT NULL,
  `label` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `default_plot` int(1) DEFAULT 0,
  `sort_num` int(11) DEFAULT NULL,
  `cron_weekly` int(1) DEFAULT 0,
  `cron_monthly` int(1) DEFAULT 0,
  `cron_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=319 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='This table is used to store user specific plot configuration information.  It is editable by the ''readonly'' user used by the http server';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plot_filter_log`
--

DROP TABLE IF EXISTS `plot_filter_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plot_filter_log` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `json` text NOT NULL,
  `user` varchar(255) NOT NULL,
  `datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=16755 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Logs all submitted plots.  Note this is a ver2 of plot_configs and will eventually replace it.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psa_data`
--

DROP TABLE IF EXISTS `psa_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psa_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qls_data`
--

DROP TABLE IF EXISTS `qls_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qls_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rri_data`
--

DROP TABLE IF EXISTS `rri_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rri_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `sample_data_view`
--

DROP TABLE IF EXISTS `sample_data_view`;
/*!50001 DROP VIEW IF EXISTS `sample_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `sample_data_view` (
  `num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `e_datetime` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `intake_height` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `reproducibility` tinyint NOT NULL,
  `pressure` tinyint NOT NULL,
  `sample_target` tinyint NOT NULL,
  `manifold` tinyint NOT NULL,
  `port` tinyint NOT NULL,
  `comparison_filter` tinyint NOT NULL,
  `comparison_target` tinyint NOT NULL,
  `comparison_round` tinyint NOT NULL,
  `data_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `samples`
--

DROP TABLE IF EXISTS `samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `icpstrat_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `flask_id` varchar(45) NOT NULL,
  `date` date NOT NULL,
  `e_datetime` datetime NOT NULL,
  `method` varchar(45) DEFAULT NULL,
  `intake_height` float DEFAULT NULL,
  `a_datetime` datetime NOT NULL,
  `inst` varchar(45) NOT NULL,
  `value` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) DEFAULT '...',
  `unc` decimal(12,4) DEFAULT NULL,
  `stddev` decimal(12,4) DEFAULT NULL,
  `reproducibility` decimal(12,4) DEFAULT NULL,
  `pressure` float DEFAULT NULL,
  `sample_target` varchar(45) DEFAULT NULL COMMENT 'For same air comparisions, this can be a designator (h,l,blind...)	',
  `creation_datetime` timestamp NULL DEFAULT current_timestamp(),
  `manifold` varchar(10) DEFAULT NULL,
  `port` varchar(10) DEFAULT NULL,
  `comparison_filter` varchar(255) DEFAULT NULL COMMENT 'Used in various comparison virtual sites like cei and rri.  This is the filter that defines comparison like rr7;tank xyzzy or cei:88,tank H',
  `comparison_round` int(11) DEFAULT NULL,
  `comparison_target` varchar(45) DEFAULT NULL,
  `data_num` int(11) DEFAULT NULL COMMENT 'Unique measurement identifier for lab.  For noaa data, flask_data->num',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`flask_id`,`e_datetime`,`a_datetime`,`inst`),
  KEY `inst` (`inst`),
  KEY `i3` (`lab_num`,`site_num`),
  KEY `site_lab_edate` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`date`),
  KEY `id` (`flask_id`,`parameter_num`),
  KEY `i4` (`data_num`),
  KEY `i5` (`site_num`,`parameter_num`,`flask_id`,`e_datetime`,`icpstrat_num`)
) ENGINE=InnoDB AUTO_INCREMENT=41424075 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='icpv2 combined data table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `samples_archive`
--

DROP TABLE IF EXISTS `samples_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples_archive` (
  `archive_datetime` datetime NOT NULL,
  `num` int(11) NOT NULL,
  `site_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `icpstrat_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `flask_id` varchar(45) NOT NULL,
  `date` date NOT NULL,
  `e_datetime` datetime NOT NULL,
  `method` varchar(45) DEFAULT NULL,
  `intake_height` float DEFAULT NULL,
  `a_datetime` datetime NOT NULL,
  `inst` varchar(45) NOT NULL,
  `value` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) DEFAULT NULL,
  `unc` decimal(12,4) DEFAULT NULL,
  `stddev` decimal(12,4) DEFAULT NULL,
  `reproducibility` decimal(12,4) DEFAULT NULL,
  `pressure` float DEFAULT NULL,
  `sample_target` varchar(45) DEFAULT NULL COMMENT 'For same air comparisions, this can be a designator (h,l,blind...)	',
  `modified_datetime` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `manifold` varchar(10) DEFAULT NULL,
  `port` varchar(10) DEFAULT NULL,
  `comparison_filter` varchar(255) DEFAULT NULL,
  `comparison_round` int(11) DEFAULT NULL,
  `comparison_target` varchar(45) DEFAULT NULL,
  `data_num` int(11) DEFAULT NULL COMMENT 'Unique measurement identifier for lab.  For noaa data, flask_data->num',
  PRIMARY KEY (`num`,`archive_datetime`),
  KEY `inst` (`inst`),
  KEY `i3` (`lab_num`,`site_num`),
  KEY `site_lab_edate` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`date`),
  KEY `i4` (`data_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='icpv2 combined data table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `samples_insitu_matches`
--

DROP TABLE IF EXISTS `samples_insitu_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples_insitu_matches` (
  `sample_num` int(11) NOT NULL,
  `match_window` int(11) NOT NULL DEFAULT 0,
  `insitu_num` bigint(20) NOT NULL,
  `time_diff_min` int(11) DEFAULT NULL,
  PRIMARY KEY (`sample_num`,`insitu_num`,`match_window`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `sausage_calibrated_values_view2`
--

DROP TABLE IF EXISTS `sausage_calibrated_values_view2`;
/*!50001 DROP VIEW IF EXISTS `sausage_calibrated_values_view2`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `sausage_calibrated_values_view2` (
  `site_num` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `group_num` tinyint NOT NULL,
  `round` tinyint NOT NULL,
  `target` tinyint NOT NULL,
  `cyl_id` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `zero_dd` tinyint NOT NULL,
  `ncoef` tinyint NOT NULL,
  `coef1` tinyint NOT NULL,
  `coef2` tinyint NOT NULL,
  `coef3` tinyint NOT NULL,
  `coef4` tinyint NOT NULL,
  `coef5` tinyint NOT NULL,
  `coef_unc` tinyint NOT NULL,
  `nvalues` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `num_pairs` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `flag` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `sausage_data_view`
--

DROP TABLE IF EXISTS `sausage_data_view`;
/*!50001 DROP VIEW IF EXISTS `sausage_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `sausage_data_view` (
  `num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `e_datetime` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `intake_height` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `comparison_filter` tinyint NOT NULL,
  `comparison_round` tinyint NOT NULL,
  `comparison_target` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `sausage_data_view2`
--

DROP TABLE IF EXISTS `sausage_data_view2`;
/*!50001 DROP VIEW IF EXISTS `sausage_data_view2`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `sausage_data_view2` (
  `num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `lab` tinyint NOT NULL,
  `icpstrat_num` tinyint NOT NULL,
  `strategy` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `date` tinyint NOT NULL,
  `e_datetime` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `intake_height` tinyint NOT NULL,
  `a_datetime` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `num_pairs` tinyint NOT NULL,
  `comparison_filter` tinyint NOT NULL,
  `comparison_round` tinyint NOT NULL,
  `comparison_target` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sct_data`
--

DROP TABLE IF EXISTS `sct_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sct_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sdo_data`
--

DROP TABLE IF EXISTS `sdo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sdo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sdz_data`
--

DROP TABLE IF EXISTS `sdz_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sdz_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sgp_data`
--

DROP TABLE IF EXISTS `sgp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sgp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_whitelist`
--

DROP TABLE IF EXISTS `site_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_whitelist` (
  `user` varchar(30) NOT NULL,
  `site_num` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`user`,`site_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sitelabset_whitelist`
--

DROP TABLE IF EXISTS `sitelabset_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitelabset_whitelist` (
  `user` varchar(30) NOT NULL,
  `site_num` int(10) unsigned NOT NULL,
  `lab_num` int(10) unsigned NOT NULL,
  `icpstrat_num` int(10) unsigned NOT NULL,
  PRIMARY KEY (`user`,`site_num`,`lab_num`,`icpstrat_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smo_data`
--

DROP TABLE IF EXISTS `smo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snp_data`
--

DROP TABLE IF EXISTS `snp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spo_data`
--

DROP TABLE IF EXISTS `spo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stp_data`
--

DROP TABLE IF EXISTS `stp_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stp_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `t_rri_data`
--

DROP TABLE IF EXISTS `t_rri_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t_rri_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(11) NOT NULL,
  `lab_num` int(11) NOT NULL,
  `icpstrat_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `flask_id` varchar(45) NOT NULL,
  `date` date NOT NULL,
  `e_datetime` datetime NOT NULL,
  `method` varchar(45) DEFAULT NULL,
  `intake_height` float DEFAULT NULL,
  `a_datetime` datetime NOT NULL,
  `inst` varchar(45) NOT NULL,
  `value` decimal(12,4) DEFAULT NULL,
  `flag` varchar(3) DEFAULT '...',
  `unc` decimal(12,4) DEFAULT NULL,
  `stddev` decimal(12,4) DEFAULT NULL,
  `reproducibility` decimal(12,4) DEFAULT NULL,
  `pressure` float DEFAULT NULL,
  `sample_target` varchar(45) DEFAULT NULL COMMENT 'For same air comparisions, this can be a designator (h,l,blind...)	',
  `creation_datetime` timestamp NULL DEFAULT current_timestamp(),
  `manifold` varchar(10) DEFAULT NULL,
  `port` varchar(10) DEFAULT NULL,
  `comparison_filter` varchar(255) DEFAULT NULL COMMENT 'Used in various comparison virtual sites like cei and rri.  This is the filter that defines comparison like rr7;tank xyzzy or cei:88,tank H',
  `comparison_round` int(11) DEFAULT NULL,
  `comparison_target` varchar(45) DEFAULT NULL,
  `data_num` int(11) DEFAULT NULL COMMENT 'Unique measurement identifier for lab.  For noaa data, flask_data->num',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`flask_id`,`e_datetime`,`a_datetime`,`inst`),
  KEY `inst` (`inst`),
  KEY `i3` (`lab_num`,`site_num`),
  KEY `site_lab_edate` (`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`date`),
  KEY `id` (`flask_id`,`parameter_num`),
  KEY `i4` (`data_num`)
) ENGINE=InnoDB AUTO_INCREMENT=2624241 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='icpv2 combined data table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thd_data`
--

DROP TABLE IF EXISTS `thd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tik_data`
--

DROP TABLE IF EXISTS `tik_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tik_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmd_data`
--

DROP TABLE IF EXISTS `tmd_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmd_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tot_data`
--

DROP TABLE IF EXISTS `tot_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tot_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tst_data`
--

DROP TABLE IF EXISTS `tst_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tst_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wbi_data`
--

DROP TABLE IF EXISTS `wbi_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wbi_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wgc_data`
--

DROP TABLE IF EXISTS `wgc_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wgc_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wkt_data`
--

DROP TABLE IF EXISTS `wkt_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wkt_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wlg_data`
--

DROP TABLE IF EXISTS `wlg_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wlg_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wlo_data`
--

DROP TABLE IF EXISTS `wlo_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wlo_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wsa_data`
--

DROP TABLE IF EXISTS `wsa_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wsa_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wud_data`
--

DROP TABLE IF EXISTS `wud_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wud_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `xgl_data`
--

DROP TABLE IF EXISTS `xgl_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xgl_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`dd`,`intake_ht`,`id_lab_num`,`inst`),
  KEY `date_idx` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zep_data`
--

DROP TABLE IF EXISTS `zep_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zep_data` (
  `lab_num` tinyint(3) unsigned NOT NULL,
  `icpstrat_num` smallint(5) unsigned NOT NULL,
  `parameter_num` tinyint(3) unsigned NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hr` int(2) NOT NULL DEFAULT 0,
  `mn` int(2) NOT NULL DEFAULT 0,
  `sc` int(2) NOT NULL DEFAULT 0,
  `dd` decimal(14,9) NOT NULL,
  `id` varchar(20) DEFAULT NULL,
  `id_lab_num` tinyint(3) unsigned DEFAULT NULL,
  `me` char(3) DEFAULT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9990,
  `flag` char(4) NOT NULL DEFAULT '...',
  `inst` varchar(8) DEFAULT NULL,
  `a_date` date DEFAULT NULL,
  `a_time` time DEFAULT NULL,
  `a_dd` decimal(14,9) DEFAULT NULL,
  `comment` tinytext NOT NULL,
  KEY `lab_num` (`lab_num`,`icpstrat_num`,`parameter_num`,`date`,`hr`,`mn`,`sc`,`id`,`me`,`intake_ht`),
  KEY `date` (`date`,`hr`,`mn`,`sc`),
  KEY `dd` (`dd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'icp'
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
/*!50003 DROP FUNCTION IF EXISTS `f_dt2dec` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_dt2dec`(v_datetime datetime) RETURNS double(14,9)
    NO SQL
begin
		return f_date2dec(date(v_datetime),time(v_datetime));
	end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_tankDriftValue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_tankDriftValue`(parameter_num int, zero_dd double(14,9),dd double(14,9),p1 double(14,9),p2 double(14,9),p3 double(14,9),p4 double(14,9),p5 double(14,9) ) RETURNS double(14,9)
    NO SQL
    DETERMINISTIC
BEGIN
	/*This calculates an adjusted assigned value for a calibrated tank.
	parameter_num is not currently used, but included in case we need a species dependent function
    zero_dd - date of first calibration episode for each tank filling, If parameters passed, zero_dd must be passed too.
    dd - is date to calculate the adjusted value for
    p1,2,3,4,5 are parameters of the calibration equation and can be 0.
    a(0) a(1) a(2)....a(n)

       example y=[a(0)]+[a(1)*(time - time_zero)]+[a(2)*(time-time_zero)^2]
	*/
    if zero_dd=0 then return p1; end if;
	return p1+(p2*(dd-zero_dd))+(p3*pow((dd-zero_dd),2))+(p4*pow((dd-zero_dd),3))+(p5*pow((dd-zero_dd),4));

   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp2_updateDataSummary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp2_updateDataSummary`(v_site_num int)
begin
	/*Updates the data summary2 table.
		Select into a tmp table then delete/insert datasummary to minimize downtime.*/
	drop temporary table if exists tmp.t_sum;
	create temporary table tmp.t_sum as select * from icp.data_summary2 where 1=0;
	insert tmp.t_sum
	select site_num,lab_num,icpstrat_num,parameter_num,period_num,inst,method,intake_height
		,min(e_datetime) as first, max(e_datetime) as last,count(*) as num_rows
	from icp.insitu
	where (v_site_num<0 or site_num=v_site_num) and value!=-999.99
	group by site_num,lab_num,icpstrat_num,parameter_num,period_num,inst,method,intake_height
	union
	select site_num,lab_num,icpstrat_num,parameter_num,7,inst,method,intake_height
		,min(e_datetime) as first, max(e_datetime) as last,count(*) as num_rows
	from icp.samples
	where (v_site_num<0 or site_num=v_site_num) and value!=-999.99
	group by site_num,lab_num,icpstrat_num,parameter_num,inst,method,intake_height;

	delete from icp.data_summary2 where (v_site_num<0 or site_num=v_site_num);
	insert icp.data_summary2 select * from tmp.t_sum;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp2_updateMatchData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp2_updateMatchData`(v_site_num int, v_lab_num int, v_parameter_num int,inout v_mssg varchar(2000))
begin
	/*Updates sample-insitu match data for passed site,lab param.  We do it in chuncks so that we don't
	lock up the table for too long.  Doing all(100 mil) took ~1hr.
	*/
	declare vDels,vIns int default 0;

	#Create a tmp table with target samples with insitu data for same param/site
	drop temporary table if exists tmp.t_base;
	create temporary table tmp.t_base (index i(d)) as (
	select distinct d.date as d,d.num as sample_num, w.num as match_window,
		s.site_num as insitu_site_num,s.lab_num as insitu_lab_num,s.parameter_num as insitu_parameter_num,
		d.e_datetime as dt,
		date_add(d.e_datetime, interval (-1*w.minutes) minute) as st,
		date_add(d.e_datetime, interval w.minutes minute) as et
	from samples d, match_windows w,data_summary2 s
	where d.site_num=v_site_num and d.site_num=s.site_num
		and d.parameter_num=v_parameter_num	and d.parameter_num=s.parameter_num
		and d.lab_num=v_lab_num #Limit to pass lab
		and s.icpstrat_num=2 and d.icpstrat_num=1 #flask samples, insitu matches
		and d.value>-999 and d.flag like '.%'
		and w.num=1#Limit to 45 window for now.
	);

	#Now fill matches with any insitu in the window
	drop temporary table if exists tmp.t_matches, tmp.t_dels;
	create temporary table tmp.t_matches(index i(sample_num,insitu_num,match_window)) as select * from samples_insitu_matches where 1=0;
	create temporary table tmp.t_dels(index i(sample_num,insitu_num,match_window)) as select * from samples_insitu_matches where 1=0;

	insert tmp.t_matches (sample_num,match_window,insitu_num,time_diff_min)
	select b.sample_num,b.match_window, d.num,abs(timestampdiff(MINUTE,b.dt,d.e_datetime))
	from tmp.t_base b,insitu d
	where b.insitu_site_num=d.site_num and b.insitu_lab_num=d.lab_num and b.insitu_parameter_num=d.parameter_num and d.icpstrat_num=2 and d.period_num=7 #only do the general case, others can do it dynamically (hourly)
		and d.value>-999 and d.flag like '.%'
		and d.date=b.d and d.e_datetime between b.st and b.et;
	#rinse/repeat for day before/after to catch any that crossed midnight.  This is so we can use the date index on insitu
	insert tmp.t_matches (sample_num,match_window,insitu_num,time_diff_min)
	select b.sample_num,b.match_window, d.num,abs(timestampdiff(MINUTE,b.dt,d.e_datetime))
	from tmp.t_base b,insitu d
	where b.insitu_site_num=d.site_num and b.insitu_lab_num=d.lab_num and b.insitu_parameter_num=d.parameter_num and d.icpstrat_num=2 and d.period_num=7
		and d.value>-999 and d.flag like '.%'
		and b.d!=date(b.st)#Prefilter base table to those that crossed midnight.
		and d.date=date(b.st) and d.e_datetime between b.st and b.et;
	insert tmp.t_matches (sample_num,match_window,insitu_num,time_diff_min)
	select b.sample_num,b.match_window, d.num,abs(timestampdiff(MINUTE,b.dt,d.e_datetime))
	from tmp.t_base b,insitu d
	where b.insitu_site_num=d.site_num and b.insitu_lab_num=d.lab_num and b.insitu_parameter_num=d.parameter_num and d.icpstrat_num=2 and d.period_num=7
		and d.value>-999 and d.flag like '.%'
		and b.d!=date(b.et)#Prefilter base table to those that crossed midnight.
		and d.date=date(b.et) and d.e_datetime between b.st and b.et;


	#Now we can update the actual table.  First delete any that are missing, then insert/update
	#Left join to matches to find ones to remove.
	insert tmp.t_dels (sample_num,insitu_num,match_window) select m.sample_num,m.insitu_num,m.match_window
		from samples_insitu_matches m join samples s on m.sample_num=s.num left join tmp.t_matches t
			on m.sample_num=t.sample_num and m.insitu_num=t.insitu_num and m.match_window=t.match_window
		where t.sample_num is null and s.site_num=v_site_num and s.lab_num=v_lab_num and s.parameter_num=v_parameter_num;
	#Now we can remove those.  (not actually expected to have many)
	delete m from samples_insitu_matches m, tmp.t_dels t
	where m.sample_num=t.sample_num and m.insitu_num=t.insitu_num and m.match_window=t.match_window;
	set vDels=row_count();
	#Now insert/update from the new matches table.
	insert into samples_insitu_matches (sample_num,match_window,insitu_num,time_diff_min)
	select t.sample_num,t.match_window,t.insitu_num,t.time_diff_min from tmp.t_matches t
	on duplicate key update time_diff_min=t.time_diff_min;
	set vIns=row_count();
	set v_mssg=concat("matchUpdate site_num:",v_site_num," lab_num:",v_lab_num," parameter_num:",v_parameter_num," del:",vDels," ins/upd:",vIns);
	#select v_mssg;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp2_updateMetaData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp2_updateMetaData`(v_site_num int,inout v_mssg varchar(2000))
begin
	/*Update the data_summary2 table and flask insitu match data
	This should be run after updating either the icp.samples or icp.insitu data tables.
	Pass v_site_num to limit to that site for some operations, pass -1 to update all.
	*/
	declare done int default false;
	declare vsite_num,vlab_num,vparameter_num int;
	#cursor that we'll need below to loop through sites to update match data.
	declare acur cursor for
		select distinct site_num,lab_num,parameter_num
		from icp.data_summary2 s
		where s.icpstrat_num=1 and s.site_num>0 and (v_site_num<0 or s.site_num=v_site_num);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	#summary table - This has to be run first.
	call icp2_updateDataSummary(v_site_num);

	#Now update match data
	/*3/3/21 turning off for now.. front end not using.
    open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vsite_num,vlab_num,vparameter_num;
		if (done=true) then LEAVE read_loop; end if;
		call icp2_updateMatchData(vsite_num,vlab_num,vparameter_num,v_mssg);
	END LOOP;
	close acur;	*/
	#select v_mssg;

    #NEED TO TEST THIS before turning on..optimize table calibrated_tanks, samples_insitu_matches, data_summary2, samples,insitu;
   # optimize table samples;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_createInsituPeriod` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_createInsituPeriod`(v_site_num int,v_lab_num int ,v_period_num int,inout v_mssg varchar(255))
begin
/*This creates averages entries from the 'all available' period for passed site,period.
NOTE; averages are entered as the beginning of period.*/
	declare agg_dt varchar(255) default 'none specified';
    declare query_text varchar(1000);
    if (v_period_num=2 ) then set agg_dt="str_to_date(date_format(e_datetime, '%Y-%m-%d %H:00:00'),'%Y-%m-%d %H:00:00')";end if;#Strip hour and turn back into a datetime

	#Insitu data.
	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,period_num)";
	set query_text=concat(query_text,"select 0,site_num,lab_num,icpstrat_num,parameter_num,date(",agg_dt,"),",agg_dt,",method,intake_height,inst,avg(value),avg(unc),min(flag),",v_period_num," ");
	set query_text=concat(query_text,"from icp.insitu where icpstrat_num=2 and value>-999 and lab_num=",v_lab_num," and site_num=",v_site_num," and period_num=7 ");
	set query_text=concat(query_text,"group by site_num,lab_num,icpstrat_num,parameter_num,date(",agg_dt,"),",agg_dt,",method,intake_height,inst,period_num");

	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu where date='2015-05-12' ;

	#Call sp to insert and archive if needed
	call icp_updateInsituData(now(),v_mssg);
	set v_mssg=concat('icp_createInsituPeriod:',v_site_num,' ',v_lab_num,' ',v_period_num,v_mssg);

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_deleteDataSet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_deleteDataSet`(v_site_num int, v_lab_num int, v_period_num int, v_parameter_num int, v_icpstrat_num int,v_remove_from_icp_import int)
begin
/*Removes data set from insitu/sample tables and archives (to reset).  period,param,strat can be passed -1 for wildcard
if v_remove_from_icp_import=1 then we take this site, lab, parameter,strat out of auto update from old icp tables.  Only call with all specified.*/
	delete from icp.samples
	where (site_num=v_site_num or v_site_num=-1) and lab_num=v_lab_num
		and (v_parameter_num=-1 or v_parameter_num=parameter_num) and (v_icpstrat_num=-1 or icpstrat_num=v_icpstrat_num) ;
	delete from icp.samples_archive
	where (site_num=v_site_num or v_site_num=-1) and lab_num=v_lab_num
		and (v_parameter_num=-1 or v_parameter_num=parameter_num) and (v_icpstrat_num=-1 or icpstrat_num=v_icpstrat_num) ;

	delete from icp.insitu
	where (site_num=v_site_num or v_site_num=-1) and lab_num=v_lab_num
		and (v_period_num=-1 or period_num=v_period_num) and (v_parameter_num=-1 or v_parameter_num=parameter_num) and (v_icpstrat_num=-1 or icpstrat_num=v_icpstrat_num) ;
	delete from icp.insitu_archive
	where (site_num=v_site_num or v_site_num=-1) and lab_num=v_lab_num
		and (v_period_num=-1 or period_num=v_period_num) and (v_parameter_num=-1 or v_parameter_num=parameter_num) and (v_icpstrat_num=-1 or icpstrat_num=v_icpstrat_num) ;

	if (v_remove_from_icp_import=1) then
		replace no_import_from_icp1 (site_num,lab_num,parameter_num,strategy_num) select v_site_num, v_lab_num, v_parameter_num, v_icpstrat_num ;
	end if;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_deleteMissingInsituData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_deleteMissingInsituData`(v_site_num int,v_parameter_num int,v_lab_num int, v_icpstrat_num int, v_period_num int, v_archive_dt datetime, inout v_mssg varchar(2000))
begin
/*Warning; this is prohibitively slow on full insitu records.  Should really only be used on hourlies.
This can be used for datasets that are updated en masse (not incremental) to prune out data that no longer exists in the source record.
See icp_updateInsituData for temp table reqs.  All new (good) data for site/param/lab/strat/period must be in temp table,
meaning this can't be used when just updating a single intake height or similar*/
	if (v_mssg is null) then set v_mssg=''; end if;#set default
	if (select count(*) from tmp.t_insitu)>0 then
		drop temporary table if exists tmp.t_;
        ALTER TABLE tmp.t_insitu ADD INDEX `s` (`site_num` ASC, `lab_num` ASC, `icpstrat_num` ASC, `parameter_num` ASC, `period_num` ASC);
		create temporary table tmp.t_ as
			select  i.num
			#unique joins
			from  icp.insitu i  left join tmp.t_insitu t on i.site_num=t.site_num and i.lab_num=t.lab_num and i.icpstrat_num=t.icpstrat_num and i.parameter_num=t.parameter_num
				and i.period_num=t.period_num and i.e_datetime=t.e_datetime and i.method=t.method and i.intake_height=t.intake_height and i.inst=t.inst
			where i.site_num=v_site_num and i.parameter_num=v_parameter_num
				and i.lab_num=v_lab_num and i.icpstrat_num=v_icpstrat_num and i.period_num=v_period_num
				and t.e_datetime is null;
		#archive
		insert icp.insitu_archive select v_archive_dt, i.* from icp_insitu i join tmp.t_ on t.num=i.num;
		#delete
		delete i from icp.insitu i join tmp.t_ t on i.num=t.num;
        set v_mssg=concat(row_count(),' existing inisut rows removed because no longer in source data');

	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_deleteMissingSampleData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_deleteMissingSampleData`(v_site_num int,v_parameter_num int,v_lab_num int, v_icpstrat_num int, v_archive_dt datetime, inout v_mssg varchar(2000))
begin
/*This can be used for datasets that are updated en masse (not incremental) to prune out data that no longer exists in the source record.
See icp_updateSampleData  for temp table reqs.*/
	declare t varchar(255) default '';
    declare i int default 0;
	if (v_mssg is null) then set v_mssg=''; end if;#set default
	if (select count(*) from tmp.t_samples)>0 then
		drop temporary table if exists tmp.t_;
		create temporary table tmp.t_ as
			select  s.num
			#unique joins
			from  icp.samples s  left join tmp.t_samples t on s.site_num=t.site_num and s.lab_num=t.lab_num and s.icpstrat_num=t.icpstrat_num and s.parameter_num=t.parameter_num
				and s.flask_id=t.flask_id and s.e_datetime=t.e_datetime and s.a_datetime=t.a_datetime and s.inst=t.inst
			where s.site_num=v_site_num and s.parameter_num=v_parameter_num and s.lab_num=v_lab_num and s.icpstrat_num=v_icpstrat_num
				and t.e_datetime is null;
		#archive
		insert icp.samples_archive select v_archive_dt, s.* from icp.samples s join tmp.t_ t on t.num=s.num;
		#delete
		delete s from icp.samples s join tmp.t_ t on s.num=t.num;
        set i=row_count();
        if (i > 0) then
			set t=concat(i,' existing sample rows removed because no longer in source data');
            #select t;
			set v_mssg=concat(v_mssg,t);
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_rematchArhiveIDs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_rematchArhiveIDs`(v_update int, inout v_mssg varchar(2000))
begin
/*This fixes up surrogate key mis-matches that may occur if a dataset is deleted from the insitu or samples table and then re-imported
Note; assumes unique key defined in u index on base table is accurate.
if v_update =0 then we just report, 1 fix.*/
	declare vUIcount,vOIcount,vEIcount,vUScount,vOScount,vEScount int default 0;

	if (v_mssg is null) then set v_mssg=''; end if;#set default
	#Count orphans
	select count(*) into vOIcount from insitu_archive a left join insitu i on a.num=i.num where i.num is null;
	select count(*) into vOScount from samples_archive a left join samples s on a.num=s.num where s.num is null;
	#count mismatches (should be same as orphans, but possible detects errors.
	select count(*) into vEIcount from insitu_archive t left join insitu i on i.site_num=t.site_num and i.lab_num=t.lab_num and i.icpstrat_num=t.icpstrat_num and i.parameter_num=t.parameter_num
				and i.period_num=t.period_num and i.e_datetime=t.e_datetime and i.method=t.method and i.intake_height=t.intake_height and i.inst=t.inst
	where t.num!=i.num;
	select count(*) into vEScount from samples_archive t left join samples s on s.site_num=t.site_num and s.lab_num=t.lab_num and s.icpstrat_num=t.icpstrat_num and s.parameter_num=t.parameter_num
			and s.flask_id=t.flask_id and s.e_datetime=t.e_datetime and s.a_datetime=t.a_datetime and s.inst=t.inst
	where t.num!=s.num;

	#fix if requested.
	if(v_update=1) then
		#Update pkey using u index cols.
		update insitu_archive t, insitu i set t.num=i.num
		where i.site_num=t.site_num and i.lab_num=t.lab_num and i.icpstrat_num=t.icpstrat_num and i.parameter_num=t.parameter_num
				and i.period_num=t.period_num and i.e_datetime=t.e_datetime and i.method=t.method and i.intake_height=t.intake_height and i.inst=t.inst;
		set vUIcount=row_count();

		update samples_archive t, samples s set t.num=s.num
		where s.site_num=t.site_num and s.lab_num=t.lab_num and s.icpstrat_num=t.icpstrat_num and s.parameter_num=t.parameter_num
			and s.flask_id=t.flask_id and s.e_datetime=t.e_datetime and s.a_datetime=t.a_datetime and s.inst=t.inst;
		set vUScount=row_count();
	end if;
	#output message
	set v_mssg=concat(
		case when vOIcount+vOScount=0 then 'No orphaned archive records.' else concat (vOIcount," orphaned insitu_archive record(s).  ",vOScount," orphaned samples_archive record(s).  ") end,
		case when vEIcount+vEScount=0 then 'No mismatched (ukey!= surrogate key) archive records.' else concat (vEIcount," mismatched (ukey!= surrogate key) insitu_archive record(s).  ",vEScount," mismatched (ukey!= surrogate key) samples_archive record(s).  ") end,
		case when vUIcount > 0 then concat(vUIcount,' icp.insitu_archive row(s) updated.  ') else '' end,
		case when vUScount > 0 then concat(vUScount,' icp.samples_archive row(s) updated.  ') else '' end, " | ",v_mssg);
	select v_mssg;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_update2007NOAAInsituSite` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_update2007NOAAInsituSite`(v_site_num int,v_parameter_num int,inout v_mssg varchar(2000))
begin
/*Inserts/updates noaa insitu x2007 co2 data into the icp2 tables.  Fairly annoying db structure of split tables by site/param.*/
	declare tble_name,site,parameter,dt,unc_col varchar(45);
	declare query_text varchar(1000);
	select lower(s.code) into site from gmd.site s where s.num=v_site_num;
	select lower(s.formula) into parameter from gmd.parameter s where s.num=v_parameter_num;
	select case when site in ('mlo','spo','brw','smo') then 'unc' else 'meas_unc' end into unc_col; #annoying col name differences...

	set dt="hr,':',min,':',sec";
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	#Super annoying... have to build query table using passed site code and parameter.
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
	set query_text=concat(query_text,"select 0,",v_site_num,",455,2,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,7 ");
	set query_text=concat(query_text,"from CO2_X2007_archive.",site,"_",parameter,"_insitu s ");

	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu;

	#Call sp to insert and archive if needed
	call icp_updateInsituData(now(),v_mssg);
	set v_mssg=concat(site,'_',parameter,'_insitu data:',v_mssg," | ");


	#repeat for hourly data.. we'll use this in time series graphing.
	set dt="hour,':00:',sec";
	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
	set query_text=concat(query_text,"select 0,",v_site_num,",455,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hour,':00:00')),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,2 ");
	set query_text=concat(query_text,"from CO2_X2007_archive.",site,"_",parameter,"_hour s ");

	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu;

	#Call sp to insert and archive if needed
	call icp_updateInsituData(now(),v_mssg);
	set v_mssg=concat(site,'_',parameter,'_hour data:',v_mssg," | ");


    #Once more for target tanks.
    if(v_site_num in (15,75,112,113)) then #observatories
		if(v_parameter_num = 1 or (v_parameter_num in (1,2,3) and v_site_num=75) or (v_parameter_num in (1,2,3,5) and v_site_num=15)) then #all have co2 targets, only barrow has ch4,co & n2o targets.3/20 mlo appears to have co/ch4/co2 now.
			set dt="hr,':',min,':',sec";
			drop temporary table if exists tmp.t_insitu;
			create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
			set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
			set query_text=concat(query_text,"select 0,",v_site_num,",455,9,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),type,0,s.inst,s.value,s.unc,s.flag,s.std_dev,7 ");
			set query_text=concat(query_text,"from CO2_X2007_archive.",site,"_",parameter,"_target s ");

			set @s=query_text;

			#select query_text;
			prepare stmt from @s;
			execute stmt;
			deallocate prepare stmt;
			#select * from tmp.t_insitu;

			#Call sp to insert and archive if needed
			call icp_updateInsituData(now(),v_mssg);
			set v_mssg=concat(site,'_',parameter,'_target data:',v_mssg," | ");
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateFromICP` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateFromICP`(v_site_num int, inout v_mssg varchar(255))
begin
/*Adds data from icp tables.  Pass v_site_num -1 for all.*/
	declare done int default false;
	declare vsite_num int default 0;

	#cursor that we'll need below.  This selects all sites with non-noaa data from data_summary
	declare acur cursor for 
		select distinct site_num 
		from icp.data_summary s
		where icpstrat_num in(1,2) and (s.site_num=310 or lab_num!=1) and (s.site_num=310 or lab_num!= 7)#get noaa data from cei table too as it's processed 
			and site_num>0
			and (v_site_num=-1 or site_num=v_site_num)
			and site_num not in (374,520,521,481)#dups in 575,374... in1 in2 combined into inx now, rri  |.. 5/19 - re-added 575.  didn't cause an issue?  must have fixed with a distinct or something.
			and site_num not in (647,869,785,787,786)#LA subsites.  We could do convoluted method/subsiting like inx if needed, leaving out for now.
            and site_num not in (520,521)#Old in1 in2 sites.
            and site_num not in (538,454,486,648)#old cma sites (they only update wlg now)
            and site_num not in (481)#hiding round robin for now...
            and site_num not in (396)#TIK data was updated from wdcgg.  Note; fmi data may be still coming in from icp, but I don't think so.  update- imported fmi from wdc too
            and lab_num not in (61,284,64,43)#KMA, SIO, bkt -- icp2 manual updates now., lnbl, agage moving to new ingest
            
			#and lab_num=4
            #NOTE; below insert/update stmt also filters site/lab/param from no_import_from_icp1 table.  
            ;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#Update all 
	open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vsite_num;
		if (done=true) then LEAVE read_loop; end if;
		call icp_updateFromICPTable(vsite_num,v_mssg);
	END LOOP;
	close acur;	
	
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateFromICPTable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateFromICPTable`(v_site_num int, inout v_mssg varchar(255))
begin
/*updates/adds data from existing icp table.  Note; this does not update matches or statistics.  It is assumed
that icp_updateNOAAData will be run after.*/
	declare tble_name,dt varchar(85);
    declare comp_filter,comp_round,comp_target varchar(1000);
	declare query_text varchar(4000);
	set dt="hr,':',mn,':',sc";
	select concat(lower(s.code),'_data') into tble_name from gmd.site s where s.num=v_site_num;

	#Sample data
	drop temporary table if exists tmp.t_samples;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
	/*Actually, comp_filter should now be null for official results, something else for re-submits (like submit date)
    set comp_filter=concat("case when ",v_site_num,"=310 then case when  comment =  ''  then 'unk' else 
        concat(convert(tmp.f_getCol(tmp.f_getCsvCol(comment,1),2,':'),signed),tmp.f_getCol(tmp.f_getCsvCol(tmp.f_getCol(comment,1,'~+~'),2),2,':'))collate latin1_general_ci end 
			else '' end ");*/
	set comp_filter='NULL';	
	set comp_round=concat("case when ",v_site_num,"=310 then case when  comment =  ''  then NULL else convert(tmp.f_getCol(tmp.f_getCsvCol(comment,1),2,':'),signed) end else NULL end");
	set comp_target=concat("case when ",v_site_num,"=310 then case when  comment =  ''  then 'unk' 
		else tmp.f_getCol(tmp.f_getCsvCol(tmp.f_getCol(comment,1,'~+~'),2),2,':')collate latin1_general_ci end else '' end ");
	set query_text="insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,comparison_filter,comparison_round,comparison_target)";
	set query_text=concat(query_text,"select distinct ",v_site_num,",lab_num,case when ",v_site_num,"=310 then 4 else icpstrat_num end,parameter_num,id,date,timestamp(date,concat(",dt,")),me,intake_ht,timestamp(a_date,a_time),inst,value,flag,unc,",comp_filter,", ",comp_round,", ",comp_target," ");
	set query_text=concat(query_text,"from icp.",tble_name," s where icpstrat_num=1 and (",v_site_num,"=310 or lab_num!=1)");#Noaa data is updated elsewhere except for cei
    set query_text=concat(query_text," and (",v_site_num,"!=310 or (",comp_round,"!=0 and ",comp_target," in ('H','M','L')))");
	set query_text=concat(query_text," and not exists (select * from no_import_from_icp1 
				where site_num=",v_site_num," and lab_num=s.lab_num and parameter_num=s.parameter_num and strategy_num=s.icpstrat_num) and s.value>-999.0");
	set @s=query_text;
    #select query_text;

	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;

	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);

	#Insitu data.  I didn't note, but think there were dups for datetime, hence the averaging.  
	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,period_num)";
	#set query_text=concat(query_text,"select distinct 0,",v_site_num,",lab_num,icpstrat_num,parameter_num,date,timestamp(date,concat(",dt,")),me,intake_ht,inst,value,unc,flag,7 ");
	#set query_text=concat(query_text,"from icp.",tble_name," where icpstrat_num=2 and lab_num!=1");
	set query_text=concat(query_text,"select 0,",v_site_num,",lab_num,icpstrat_num,parameter_num,date,timestamp(date,concat(",dt,")),me,intake_ht,inst,avg(value),avg(unc),min(flag),7 ");
	set query_text=concat(query_text,"from icp.",tble_name," s where icpstrat_num=2 and lab_num!=1 ");
	set query_text=concat(query_text," and not exists (select * from no_import_from_icp1 
				where site_num=",v_site_num," and lab_num=s.lab_num and parameter_num=s.parameter_num and strategy_num=s.icpstrat_num)");
	set query_text=concat(query_text,"group by lab_num,icpstrat_num,parameter_num,date,timestamp(date,concat(",dt,")),me,intake_ht,inst");
	
	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu;

	#Call sp to insert and archive if needed
	call icp_updateInsituData(now(),v_mssg);
	set v_mssg=concat(v_site_num,':',v_mssg,' ');

	#Make hourlys for select sets
    if(v_site_num = 673 ) then call icp_createInsituPeriod(673,60,2,v_mssg); end if;#mrc, psu
    #if(v_site_num = 506 ) then call icp_createInsituPeriod(506,60,2,v_mssg); end if;#inx, psu. #commenting out for now (7.23) because being provided in hourly
	if(v_site_num = 922 ) then call icp_createInsituPeriod(922,112,2,v_mssg); end if;#en
    if(v_site_num = 562 ) then call icp_createInsituPeriod(562,112,2,v_mssg); end if;
    if(v_site_num = 792 ) then call icp_createInsituPeriod(792,112,2,v_mssg); end if;
    if(v_site_num = 246 ) then call icp_createInsituPeriod(246,112,2,v_mssg); end if;
    if(v_site_num = 897 ) then call icp_createInsituPeriod(897,112,2,v_mssg); end if;
    if(v_site_num = 124 ) then call icp_createInsituPeriod(124,112,2,v_mssg); end if;
    if(v_site_num = 867 ) then call icp_createInsituPeriod(867,112,2,v_mssg); end if;
	
	
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateHATSData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateHATSData`(v_site_num int, inout v_mssg varchar(255))
begin #
/*updates/adds any HATS  flask and insitu data for all sites in the icp2 tables.  Pass v_site_num -1 for all*/
	drop temporary table if exists tmp.t_samples,tmp.t_locs,tmp.t_locs2;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
	create temporary table tmp.t_locs as 
		select distinct site_num from data_summary2 where (v_site_num=-1 or site_num=v_site_num);
        /*Too slow...
        #We could select from data_summary2, but then we'd have dependicies on order that it's called.
		select distinct site_num from icp.samples where (v_site_num=-1 or site_num=v_site_num)
			union 
		select distinct site_num from icp.insitu where (v_site_num=-1 or site_num=v_site_num);*/
	create temporary table tmp.t_locs2 as select * from tmp.t_locs;
    
    #PR1 data
	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc)
	select h.site_num,97,1,h.parameter_num,h.sample_id,date(h.sample_datetime),h.sample_datetime,sample_type,0,h.analysis_datetime,h.inst_id,h.pair_avg,
    '...',#concat(case when rejected=1 then 'R' else '.' end, case when background=1 then '.' else 'X' end, '.') as flag. #Src view filters rejected
    -999.99
    from hats.prs_pair_avg_view h join tmp.t_locs2 l on h.site_num=l.site_num 
    where 1=1#rejected=0 
		#and parameter_num in (select parameter_num from hats_include_parameters) #jwm - 5/23 - including all so Isaac can use for qc
		and h.sample_type in('PFP','CCGG', 'HATS', 'FLASK')
	; 
        
    #next gen system
    insert  tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc)
	select h.site_num,97,1,h.parameter_num,h.sample_id,date(h.sample_datetime),h.sample_datetime,sample_type,0,h.analysis_datetime,h.inst_id,h.pair_avg,
    '...',#concat(case when rejected=1 then 'R' else '.' end, case when background=1 then '.' else 'X' end, '.') as flag.  #Src view filters rejected
    -999.99
    from hats.ng_pair_avg_view h join tmp.t_locs2 l on h.site_num=l.site_num 
    where 1=1#rejected=0 
		#and parameter_num in (select parameter_num from hats_include_parameters) #jwm - 5/23 - including all so Isaac can use for qc
		
    ;
    
	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);
    ######disable insitu update for now.  Data tables have moved, i think they're on the dmz server now.  will need to rethink how this works, only used by ed i believe, so will revisit when someone asks.
    if(v_site_num=-1 and 1=0) then
		#Fetch hats obs insitu data
		drop temporary table if exists tmp.t_insitu;
		create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
		
		#n2o data
		insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 15,97,2,5,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.brw_n2o_hour	group by timestamp(date,concat(hour,":00:00"))
		;
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 75,97,2,5,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.mlo_n2o_hour	group by timestamp(date,concat(hour,":00:00"))
		;
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 112,97,2,5,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.smo_n2o_hour	group by timestamp(date,concat(hour,":00:00"))
		;
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 113,97,2,5,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.spo_n2o_hour	group by timestamp(date,concat(hour,":00:00"))
		;
		call icp_updateInsituData(now(),v_mssg);
        
		#sf6 data
		drop temporary table if exists tmp.t_insitu;
		create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
		
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 15,97,2,6,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.brw_sf6_hour	group by timestamp(date,concat(hour,":00:00"))
        ;
		insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 75,97,2,6,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.mlo_sf6_hour	group by timestamp(date,concat(hour,":00:00"))
        ;
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 112,97,2,6,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.smo_sf6_hour	group by timestamp(date,concat(hour,":00:00"))
        ;
        insert tmp.t_insitu (site_num,lab_num,icpstrat_num,parameter_num,period_num,date,e_datetime,method,intake_height,inst,value,unc,flag)
		select 113,97,2,6,7,date,timestamp(date,concat(hour,":00:00")),null,0,'cats',avg(value),avg(sdev),min(flag)
		from hats.spo_sf6_hour	group by timestamp(date,concat(hour,":00:00"))
        ;
		#Call sp to insert and archive if needed
		call icp_updateInsituData(now(),v_mssg);
	end if;
    
	set v_mssg=concat('hats update: ',v_mssg);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateHATSTestData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateHATSTestData`(inout v_mssg varchar(255))
begin
	/*Update hats_test data.  Trying new method of chunking.  Caller is prs_callProcForPeriod(), which sets up t_data by month*/
	drop temporary table if exists tmp.t_samples,tmp.t_locs,tmp.t_locs2;
	if (v_mssg is null) then set v_mssg=''; end if;#set default
	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
	#PR1 data
	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc)
	/*select h.site_num,711,1,h.parameter_num,h.sample_id,date(h.sample_datetime),h.sample_datetime,sample_type,0,h.analysis_datetime,h.inst_id,h.pair_avg,
    '...',#concat(case when rejected=1 then 'R' else '.' end, case when background=1 then '.' else 'X' end, '.') as flag. #Src view filters rejected
    -999.99
    from hats_test.prs_pair_avg_view h join tmp.t_locs2 l on h.site_num=l.site_num 
	where 1=1#rejected=0 
		#and parameter_num in (select parameter_num from hats_include_parameters) #jwm - 5/23 - including all so Isaac can use for qc
		and h.sample_type in('PFP','CCGG', 'HATS', 'FLASK')
	;*/
    select t.site_num,711,1,t.parameter_num,t.sample_id,date(t.sample_datetime),t.sample_datetime,'',0,t.analysis_datetime,t.inst_id,t.pair_avg,'...',t.pair_stdv
    from hats_test.t_data t
    where 1=1
		#and h.sample_type in('PFP','CCGG', 'HATS', 'FLASK')
	; 
    call icp_updateSamplesData(now(),v_mssg);
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
...started working on delete logic, but ran out of time to make it work.. see notes below.3/20

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

	/*This doesn't work because source files are often incremental.  Should be made a switch so it would work when copying from another table (noaa/icp)
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
	*/

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
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateMagiccTargetDataFromCals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateMagiccTargetDataFromCals`(inout v_mssg varchar(2000))
begin
/*Pulls any noaa calibration results for the magicc target tanks into the icp2 tables.*/
	drop temporary table if exists tmp.t_samples;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

    create temporary table tmp.t_samples as select * from samples where 1=0;

	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,stddev,reproducibility,pressure,sample_target,manifold,port)

    select 199,1,10,p.num,c.serial_number,c.date,timestamp(c.date,c.time),c.method,0,timestamp(c.date,c.time),
		c.inst,c.mixratio,concat(c.flag,'..'),
		case when lower(c.species) in ('co2','ch4','co','n2o','sf6') then refgas_orders.f_expanded_uncertainty(c.species,c.mixratio,c.date)/2 #the official unc is 2 sigma, we want to plot/output 1 sigma
			else -999.99 end,
		c.stddev,
		case when lower(c.species) in ('co2','ch4','co','n2o','sf6') then refgas_orders.f_reproducibility(c.species,c.mixratio,c.date)/2 #the official rep is 2 sigma, we want to plot/output 1 sigma
			when lower(c.species) in ('h2') then 1.0 else null end,#Hard code 1.0 for h2 (per andy c)
		c.pressure,null,q.manifold,q.port
	from reftank.calibrations c join gmd.parameter p on lower(c.species)=lower(p.formula) join icp.calibrated_tanks t on t.id=c.serial_number and t.site_num=199 and t.parameter_num=p.num
		left join reftank.calibrations_qcdata q on c.idx=q.cal_num
	where c.location='BLD'  and t.start_date<=timestamp(c.date,c.time) and t.end_date>timestamp(c.date,c.time)
		#and flag like '.' #this was causing flagged data to never get updated (flagged in icp)
    ;
	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);
	set v_mssg=concat('magicc_targets:',v_mssg," | ");
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateMENIDataFromCals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateMENIDataFromCals`(inout v_mssg varchar(2000))
begin
/*Pulls any noaa calibration results for the MENI experiment into the icp2 tables.*/
	drop temporary table if exists tmp.t_samples;
	if (v_mssg is null) then set v_mssg=''; end if;#set default
	create temporary table tmp.t_samples as select * from samples where 1=0;
	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,stddev,reproducibility,pressure,sample_target)
	select 879,1,7,p.num,c.serial_number,'0000-00-00','0000-00-00 00:00:00',c.method,0,timestamp(c.date,c.time),
		c.inst,c.mixratio,concat(c.flag,'..'),
		case when lower(c.species) in ('co2','ch4','co','n2o','sf6') then refgas_orders.f_expanded_uncertainty(c.species,c.mixratio,c.date)/2 #the official unc is 2 sigma, we want to plot/output 1 sigma
			else -999.99 end,
		c.stddev,
		case when lower(c.species) in ('co2','ch4','co','n2o','sf6') then refgas_orders.f_reproducibility(c.species,c.mixratio,c.date)/2 #the official rep is 2 sigma, we want to plot/output 1 sigma
			when lower(c.species) in ('h2') then 1.0 else null end,#Hard code 1.0 for h2 (per andy c)
		c.pressure,null
	from reftank.calibrations c join gmd.parameter p on lower(c.species)=lower(p.formula)
	where c.serial_number in('D232733','D232721','D232717')#Hard coded list of tanks.
			and lower(c.species) in ('co2','ch4','co','n2o','sf6','h2')#Limit to our 6 for now (no isotopes) as our results aren't as definitive as SIL
			and (lower(c.species)!='n2o' or inst!='LGR2')
    ;
	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);
	set v_mssg=concat('MENI NOAA data update: ',v_mssg);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAACalScaleTestData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAACalScaleTestData`(v_site_num int, v_parameter_num int, inout v_mssg varchar(255))
begin
/*updates/adds any noaa pfp/flask calscale test results for site/parameter in the icp2 tables.  Pass v_site_num -1 for all*/
	drop temporary table if exists tmp.t_samples,tmp.t_locs;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
	create temporary table tmp.t_locs as #We could select from data_summary2, but then we'd have dependicies on order that it's called.
    select distinct site_num from icp.data_summary2;#Actually, just doing it that way for this data as other way is too slow;
		#select distinct site_num from icp.samples where (v_site_num=-1 or site_num=v_site_num)
		#	union 
		#select site_num from icp.insitu where (v_site_num=-1 or site_num=v_site_num)
		#	union select v_site_num ;#make sure passed site is included.

	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,manifold,port)
	select distinct e.site_num,
		449,#NOAA_test
         case when e.site_num=274 then 8 else 1 end,#For tst site, use strategy 8 so we can special handle it
		d.parameter_num,e.id,e.date,timestamp(e.date,e.time),
		e.me,
		ccgg.f_intake_ht(e.alt,e.elev),timestamp(d.date,d.time),d.inst,d.value,d.flag,d.unc, a.manifold, a.port
	from cal_scale_tests.flask_data d join ccgg.flask_event e on e.num=d.event_num 
		join tmp.t_locs l on e.site_num=l.site_num 
        left join ccgg.flask_analysis a on d.event_num=a.event_num and timestamp(d.date,d.time)=a.start_datetime
    where d.parameter_num=v_parameter_num
		and e.project_num=1 and d.value!=-888.88
		and e.site_num not in (199,114)#('bld','spf')
    
	;

      
	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);
	set v_mssg=concat('NOAA flask_data update: ',v_mssg);
    
    #update summary
    if(v_site_num>0) then
		call icp2_updateDataSummary(v_site_num);
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAData`(v_site_num int, inout v_mssg varchar(2000))
begin
/*Inserts noaa data into the icp2 tables. pass v_site_num -1 for all.*/
	declare done int default false;
	declare vUcount,vIcount,vUcount_f,vIcount_f int default 0;
	declare vsite_num, vparameter_num,vprev_site_num int default 0;

	#cursor that we'll need below.  This selects all tower & obs insitu from data summary
    #jwm - 11/24/21 this was missing newly desginated mbo surface insitu, so removed project filter (will catch aircraft insitu to be added soon too.)
    #2/22 - removed chs insitu as there is only ch4 and it kept erroring out (col names).  can add it back if needed but have to add filter for no co2 table.
	declare acur cursor for select distinct site_num,parameter_num from ccgg.data_summary
		where strategy_num=3 and (v_site_num=-1 or site_num=v_site_num) and site_num!=439 order by site_num;#project_num in(3,4)
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	set v_mssg='';

    #Update all the insitu tables by looping through tower/obs tables in data_summary
	open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vsite_num,vparameter_num;
		if (done=true) then LEAVE read_loop; end if;
		if(vsite_num!=vprev_site_num) then select concat('updating insitu site:',code) as 'status' from gmd.site where num=vsite_num;end if;
		call icp_updateNOAAInsituSite(vsite_num,vparameter_num,v_mssg);
        set vprev_site_num=vsite_num;
	END LOOP;
	close acur;

	#Fetch all flask/pfp data
	select 'updating flask/pfp data' as 'status';
    if (v_site_num=-1) then call icp_updateNOAAFlaskData2(v_mssg);
    else call icp_updateNOAAFlaskDataSite(v_site_num,v_mssg);
    end if;
	#call icp_updateNOAAFlaskData(v_site_num,v_mssg);

	#Pull MENI data from calibrations db
	if(v_site_num=-1) then call icp_updateMENIDataFromCals(v_mssg); end if;

	#Update magicc calibrations data
    if(v_site_num=-1) then call icp_updateMagiccTargetDataFromCals(v_mssg); end if;

    #Add in any HATS data we're interested in
	select 'updating hats data' as 'status';
	call icp_updateHATSData(v_site_num,v_mssg);

	#update the data_summary2 table and pre-matching data
    #This is called from script now.
	#call icp2_updateMetaData(-1,v_mssg);

	#update table/index stats on all related tables.
	#optimize table samples_insitu_matches, data_summary2, samples,insitu;

	#set v_mssg=concat(v_mssg,' ',case when vUcount+vIcount+vAcount=0 then 'No changes.' else
	#	concat(case when vUcount > 0 then concat(vUcount,' icp.insitu rows updated.  ') else '' end,
	#			case when vAcount > 0 then concat(vAcount,' icp.insitu rows archived.  ') else '' end,
	#			case when vIcount > 0 then concat(vIcount, ' icp.insitu rows inserted.  ') else '' end,
	#			case when vIcount_f > 0 then concat(vIcount_f, ' icp.samples rows inserted.  ') else '' end,
	#			case when vUcount_f > 0 then concat(vUcount_f, ' icp.samples rows updated.  ') else '' end
	#)# end);
	#select v_mssg;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAFlaskData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAFlaskData`(v_site_num int, inout v_mssg varchar(255))
begin
/*updates/adds any noaa pfp/flask results for all sites in the icp2 tables.  Pass v_site_num -1 for all*/
	#cursor for below loop
    declare done int default false;
    declare vsite_num,vlab_num,vicpstrat_num,vparameter_num int default 0;
    declare acur cursor for select distinct site_num,lab_num,icpstrat_num,parameter_num from tmp.t_samples;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	drop temporary table if exists tmp.t_samples,tmp.t_locs;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#create temporary table tmp.t_samples as select * from icp.samples where 1=0;
    create temporary table tmp.t_samples like icp.samples;#create with indexes
	create temporary table tmp.t_locs as
    #We could select from data_summary2, but then we'd have dependicies on order that it's called.
    #actually, this is so slow, that I'm switching to use data_summary2.  You may need to run after updating stats to catch new sites
		select distinct site_num from icp.data_summary2 where (v_site_num=-1 or site_num=v_site_num) union select v_site_num;
    #	select distinct site_num from icp.samples where (v_site_num=-1 or site_num=v_site_num)
	#		union select site_num from icp.insitu where (v_site_num=-1 or site_num=v_site_num)
	#		union select v_site_num ;#make sure passed site is included.

	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,manifold,port)
	select d.site_num,
		case #map ccg programs to obspack.lab
			when d.program_num=12 then 7 #sil
			when d.program_num=11 then 448 #arl
			when d.program_num=8 then 97 #hats
            when d.program_num=1 then 1 #ccgg
			else 0 end,
        case when d.site_num=274 then 8 else 1 end,#For tst site, use strategy 8 so we can special handle it
		d.parameter_num,d.flask_id,d.ev_date,d.ev_datetime,
		case when d.site='MRC' then #Special logic for mrc so we can get the tower info into the method.. kind of a kludge to handle subsites, but I didn't want to add subsite logic at this time.
			concat(d.me,
				case when d.ev_comment like '%Tower:South%' then '-Tower:South'
					when d.ev_comment like '%Tower:East%' then '-Tower:East'
				else '' end)
		when d.site='INX' then #lame way to handle subsites at inx.
			concat(d.me,
				case when d.ev_comment like '%Tower:1%' then '-Tower:1'
					when d.ev_comment like '%Tower:2%' then '-Tower:2'
					when d.ev_comment like '%Tower:3%' then '-Tower:3'
					when d.ev_comment like '%Tower:6%' then '-Tower:6'
					when d.ev_comment like '%Tower:9%' then '-Tower:9'
					when d.ev_comment like '%Tower:10%' then '-Tower:10'
				else '' end)
		else d.me end,
		ccgg.f_intake_ht(d.alt,d.elev),d.a_datetime,d.inst,d.value,d.flag,d.unc, a.manifold, a.port
	from ccgg.flask_data_view d join tmp.t_locs l on d.site_num=l.site_num left join ccgg.flask_analysis a on d.event_num=a.event_num and d.a_datetime=a.start_datetime
    #NOTE need to pull sil from here and insert as it's own lab to make more rational (and like hats).  Sylvia is using nooa/sil lab designations now though to compare her scale change.
	where d.program_num in (1,8,11,12) and parameter_num not in (58,59,60,61,62)
		and d.project_num=1
		and site not in ('bld','spf')
        and (d.program_num!=8 or d.parameter_num in (select parameter_num from hats_include_parameters))#Limit hats parameters to ones that have comparisons (see below for query)
        #and (d.site!='tst' or d.ev_date>='2000-01-01')#2020-11-18.  not sure why this was limited to 2000+.  Opened up for andy.
        #and d.parameter_num in (9)
	;

    #Loop through distinct datasets and remove any rows that are no longer there.  These will generally be pfp's with a time correction.
    #SLOOOW!
    /*open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into vsite_num,vlab_num,vicpstrat_num,vparameter_num;
		if (done=true) then LEAVE read_loop; end if;
        call icp.icp_deleteMissingSampleData(vsite_num,vparameter_num, vlab_num, vicpstrat_num, now(), v_mssg);
	END LOOP;
	close acur;
    */
    ##

	#Call sp to insert and archive if needed
	call icp_updateSamplesData(now(),v_mssg);
	set v_mssg=concat('NOAA flask_data update: ',v_mssg);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAFlaskData2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAFlaskData2`(inout v_mssg varchar(2048))
begin
	declare done int default false;
    declare v_site_num int default 0;
	declare acur cursor for select distinct site_num from icp.data_summary2 where site_num not in (879,310,199,114);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#Update all the flask data by going through tables in data_summary
	open acur;
	set done=false;
	read_loop: LOOP
		fetch acur into v_site_num;
		if (done=true) then LEAVE read_loop; end if;
		call icp_updateNOAAFlaskDataSite(v_site_num,v_mssg);
	END LOOP;
	close acur;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAFlaskDataSite` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAFlaskDataSite`(v_site_num int, inout v_mssg varchar(2048))
begin 
	/*2nd try at this;skip generic logic, operate directly.*/
    declare vUcount,vIcount,vDcount int default 0;

    
    drop temporary table if exists tmp.t_samples,tmp.t_new_nums,tmp.t_del_nums;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
    
    insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,manifold,port,data_num)
	select d.site_num,
		case #map ccg programs to obspack.lab
			when d.program_num=12 then 7 #sil
			when d.program_num=11 then 448 #arl
			#when d.program_num=8 then 97 #hats jwm - 6/24, moving to new proc
            when d.program_num=1 then 1 #ccgg
			else 0 end,
        case when d.site_num=274 then 8 else 1 end,#For tst site, use strategy 8 so we can special handle it
		d.parameter_num,d.flask_id,d.ev_date,d.ev_datetime,
		case when d.site='MRC' then #Special logic for mrc so we can get the tower info into the method.. kind of a kludge to handle subsites, but I didn't want to add subsite logic at this time.
			concat(d.me,
				case when d.ev_comment like '%Tower:South%' then '-Tower:South'
					when d.ev_comment like '%Tower:East%' then '-Tower:East'
				else '' end)
		when d.site='INX' then #lame way to handle subsites at inx.
			concat(d.me,
				case when d.ev_comment like '%Tower%1%' and d.lat=39.5805 then '-Tower:1'#separate from 10/15
					when d.ev_comment like '%Tower%2%' then '-Tower:2'
					when d.ev_comment like '%Tower%3%' then '-Tower:3'
					when d.ev_comment like '%Tower%6%' then '-Tower:6'
					when d.ev_comment like '%Tower%9%' then '-Tower:9'
					when d.ev_comment like '%Tower%10%' then '-Tower:10'
                    when d.ev_comment like '%Tower%15%' then '-Tower:15'
				else '' end)
		else d.me end,
		ccgg.f_intake_ht(d.alt,d.elev),d.a_datetime,d.inst,d.value,d.flag,d.unc, a.manifold, a.port, d.data_num
	from ccgg.flask_data_view d left join ccgg.flask_analysis a on d.event_num=a.event_num and d.a_datetime=a.start_datetime
    where d.site_num=v_site_num and d.program_num in (1,11,12) and parameter_num not in (58,59,60,61,62)
		and d.project_num=1
		and site not in ('bld','spf')
        and d.program_num!=8 #Hats data now coming in below in hats specific proc
        
	;
    alter table tmp.t_samples ADD INDEX i (data_num ASC);#we'll use this for all syncing.
    
    
    #update existing
    update icp.samples s, tmp.t_samples t
		set s.site_num=t.site_num, s.lab_num=t.lab_num, s.icpstrat_num=t.icpstrat_num,s.parameter_num=t.parameter_num,s.flask_id=t.flask_id,
			s.date=t.date,s.e_datetime=t.e_datetime, s.method=t.method,s.intake_height=t.intake_height,s.a_datetime=t.a_datetime, s.inst=t.inst,
            s.value=t.value,s.flag=t.flag,s.unc=t.unc,s.manifold=t.manifold,s.port=t.port
    where s.data_num=t.data_num and s.site_num=v_site_num;
    set vUcount=row_count();
    #select vUcount;
    
    #insert new
    create temporary table tmp.t_new_nums as 
		select t.data_num from tmp.t_samples t left join icp.samples s on t.data_num=s.data_num and s.site_num=v_site_num where s.data_num is null;
	alter table tmp.t_new_nums add index i(data_num);#shouldn't really be needed, but potential helps optimizer.
    
    insert icp.samples #(site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,manifold,port,data_num)
    select t.* from tmp.t_samples t join tmp.t_new_nums n on t.data_num=n.data_num;
    set vIcount=row_count();
    
    #delete missing
    create temporary table tmp.t_del_nums as 
		select s.data_num from icp.samples s left join tmp.t_samples t on s.data_num=t.data_num
        where s.data_num is not null and s.site_num=v_site_num and t.data_num is null and s.icpstrat_num in (1,8) and s.lab_num in (7,448,97,1);
    alter table tmp.t_del_nums add index i(data_num);
    
    delete s from icp.samples s, tmp.t_del_nums t where s.data_num=t.data_num
		and s.icpstrat_num in (1,8) and s.lab_num in (7,448,97,1);
    #select * from tmp.t_del_nums;#test
    set vDcount=row_count();
    #select vUcount,vIcount,vDcount;
    set v_mssg=concat('updateNOOAFlaskDataSite:',v_site_num,' ',case when vUcount+vIcount+vDcount=0 then '.' else
		concat(case when vUcount > 0 then concat(vUcount,' icp.samples row(s) updated.  ') else '' end,
				case when vDcount > 0 then concat(vDcount,' icp.samples row(s) deleted.  ') else '' end,
				case when vIcount > 0 then concat(vIcount, ' icp.samples row(s) inserted.  ') else '' end
	) end, " | ",v_mssg);
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAInsituSite` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAInsituSite`(v_site_num int,v_parameter_num int,inout v_mssg varchar(2000))
updateNOAAInsitu: begin 
/*Inserts/updates noaa insitu data into the icp2 tables.  Fairly annoying db structure of split tables by site/param, but that
is getting switched to single table..*/
	
	declare tble_name,site,parameter,dt,unc_col varchar(45);
	declare query_text varchar(1000);
	declare is_merged int default 0;
	if(v_site_num=439) then #skip chs for now. not getting updated and table structure caused issues
		set v_mssg='Skipping CHS';
	else
		select lower(s.code) into site from gmd.site s where s.num=v_site_num;
		select lower(s.formula) into parameter from gmd.parameter s where s.num=v_parameter_num;
		select case when site in ('chs') then 'unc' else 'meas_unc' end into unc_col; #annoying col name differences... (only chs now)('mlo','spo','brw','smo','chs','mko','cao') 
		select case when site in ('mlo','spo','brw','smo','mko','cao') then 1 else 0 end into is_merged;
		
		set dt="hr,':',min,':',sec";
		if (v_mssg is null) then set v_mssg=''; end if;#set default

		drop temporary table if exists tmp.t_insitu;
		#create temporary table tmp.t_insitu (index i(`site_num`,`lab_num`,`icpstrat_num`,`parameter_num`,`period_num`,`e_datetime`,`method`,`intake_height`,`inst`)) 
		#	as select * from icp.insitu where 1=0;
		create temporary table tmp.t_insitu like icp.insitu;#this is about same speed as single index above, but easier to maintain if table def changes.  Index reduces 
		#time significantly
		if (is_merged=1 ) then
			call icp.icp_deleteDataSet(v_site_num,1, 7, v_parameter_num , 2,0);
			insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)
			select 0, i.site_num, 1,2,i.parameter_num, date(i.date), i.date,'',i.intake_ht,inst.id,i.value, i.meas_unc,i.flag, i.std_dev,7
			from ccgg.insitu_data i join ccgg.inst_description inst on i.inst_num=inst.num
			where i.site_num=v_site_num and i.parameter_num=v_parameter_num and target=0;
		else
			# have to build query table using passed site code and parameter.
			set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
			set query_text=concat(query_text,"select 0,",v_site_num,",1,2,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,7 ");
			set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_insitu s ");
		
			set @s=query_text;
			
			#select query_text;
			prepare stmt from @s;
			execute stmt;
			deallocate prepare stmt;
		end if;
		#select * from tmp.t_insitu;
		#leave updateNOAAInsitu;
		
		#call proc to prune missing data (no longer in source tables)
		##Too slooow on insitu table.  After talking with Kirk, these shouldn't get removed once inserted, so we don't need this check.
		#call icp_deleteMissingInsituData(v_site_num, v_parameter_num, 1,2, 7, now(),v_mssg);
				
		#Call sp to insert and archive if needed
		call icp_updateInsituData(now(),v_mssg);
		set v_mssg=concat(site,'_',parameter,'_insitu data:',v_mssg," | ");
		
		#repeat for hourly data.. we'll use this in time series graphing and for towers, hourly comparisons between insts.
			
		if(site = 'lab') then #lab has no hourlies at this time, so create some
			drop temporary table if exists tmp.t_insitu;
			create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
			call icp.icp_deleteDataSet(v_site_num,1, 2, v_parameter_num , 2,0);

			set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
			set query_text=concat(query_text,"select 0,",v_site_num,",1,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hr,':00:00')),'',intake_ht,s.inst,avg(s.value),stddev(s.value),'...',stddev(value),2 ");
			set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_insitu s where s.flag like '.%' group by s.date,s.hr, intake_ht, s.inst ");
			
			set @s=query_text;
			
			#select query_text;
			prepare stmt from @s;
			execute stmt;
			deallocate prepare stmt;
			call icp_updateInsituData(now(),v_mssg);
		else
			
			#reset all because the source table is regenerated each night and hours may disappear.  We tried using icp_deleteMissingInsituData but its too slow and
			#not worth optimizing.
			call icp.icp_deleteDataSet(v_site_num,1, 2, v_parameter_num , 2,0);

			set dt="hour,':00:',sec";
			drop temporary table if exists tmp.t_insitu;
			create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
			
			if (is_merged=1 ) then
				call icp.icp_deleteDataSet(v_site_num,1, 2, v_parameter_num , 2,0);
				insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)
				select 0, i.site_num, 1,2,i.parameter_num, date(i.date), i.date,'',i.intake_ht,inst.id,i.value, i.meas_unc,i.flag, i.std_dev,2
				from ccgg.insitu_data i join ccgg.inst_description inst on i.inst_num=inst.num
				where i.site_num=v_site_num and i.parameter_num=v_parameter_num and target=0;
			else
				#added handling for mko because some (mko) had numerous dups for some reason.12-27-22
				set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
				if(site='mko') then
					set query_text=concat(query_text,"select  0,",v_site_num,",1,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hour,':00:00')),'',intake_ht,max(s.inst),max(s.value),max(",unc_col,"),max(s.flag),max(s.std_dev),2 ");
					set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_hour s group by s.date,timestamp(s.date,concat(hour,':00:00')),intake_ht ");
				else
					set query_text=concat(query_text,"select 0,",v_site_num,",1,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hour,':00:00')),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,2 ");
					set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_hour s");
				end if;
				set @s=query_text;

				#select query_text;
				prepare stmt from @s;
				execute stmt;
				deallocate prepare stmt;
				#select * from tmp.t_insitu;
			end if;
			
			#repeat for hourly data for other instruments (towers only).. we'll calculate from insitu. Natash's request
			if site not in ('mlo','spo','brw','smo','chs') and is_merged=0 then
				set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
				set query_text=concat(query_text,"select 0,",v_site_num,",1,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hr,':00:00')),'',intake_ht,s.inst,avg(s.value) as 'value',avg(",unc_col,") as unc,min(s.flag) as flag,stddev(s.value),2 ");
				set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_insitu s ");
				set query_text=concat(query_text,"where flag like '.%' and not exists (select * from ccgg.",site,"_",parameter,"_hour where inst=s.inst) group by s.date,hr,intake_ht,s.inst ");
				set @s=query_text;
				prepare stmt from @s;
				execute stmt;
				deallocate prepare stmt;
			end if;
			
			#call proc to prune missing data (no longer in source tables)
			#Too slow... call icp_deleteMissingInsituData(v_site_num, v_parameter_num, 1,2,2,now(),v_mssg);
					
			#Call sp to insert and archive if needed
			call icp_updateInsituData(now(),v_mssg);
			set v_mssg=concat(site,'_',parameter,'_hour data:',v_mssg," | ");
		end if;
		
		#Once more for target tanks.  
		if (is_merged=1 ) then
				drop temporary table if exists tmp.t_insitu;
				create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
				call icp.icp_deleteDataSet(v_site_num,1, 7, v_parameter_num , 9,0);
				insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)
				select 0, i.site_num, 1,9,i.parameter_num, date(i.date), i.date,i.inlet,i.intake_ht,inst.id,i.value, i.meas_unc,i.flag, i.std_dev,7
				from ccgg.insitu_data i join ccgg.inst_description inst on i.inst_num=inst.num
				where i.site_num=v_site_num and i.parameter_num=v_parameter_num and target=1;
		elseif(v_site_num in (15,75,112,113)) then #observatories
			if(v_parameter_num = 1 or (v_parameter_num in (1,2,3) and v_site_num=75) or (v_parameter_num in (1,2,3,5) and v_site_num=15)) then #all have co2 targets, only barrow has ch4,co & n2o targets.3/20 mlo appears to have co/ch4/co2 now.
				set dt="hr,':',min,':',sec";
				drop temporary table if exists tmp.t_insitu;
				create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
				set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
				set query_text=concat(query_text,"select 0,",v_site_num,",1,9,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),type,0,s.inst,s.value,s.unc,s.flag,s.std_dev,7 ");
				set query_text=concat(query_text,"from ccgg.",site,"_",parameter,"_target s ");

				set @s=query_text;

				#select query_text;
				prepare stmt from @s;
				execute stmt;
				deallocate prepare stmt;
				#select * from tmp.t_insitu;
			
				#call proc to prune missing data (no longer in source tables)
				#Too slow.. call icp_deleteMissingInsituData(v_site_num, v_parameter_num, 1,9,7,now(),v_mssg);
				
				#Call sp to insert and archive if needed
				call icp_updateInsituData(now(),v_mssg);
				set v_mssg=concat(site,'_',parameter,'_target data:',v_mssg," | ");
			end if;
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAx2019Data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAx2019Data`()
begin
#wipe all
#delete from icp.insitu where lab_num=449;
#delete from icp.samples where lab_num=449;
#delete from icp.insitu_archive where lab_num=449;
#delete from icp.samples_archive where lab_num=449;

#flask dataw
drop temporary table if exists tmp.t_samples,tmp.t_locs;
create temporary table tmp.t_samples as select * from icp.samples where 1=0;
insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc)
	select e.site_num, 449, 1, cd.parameter_num, e.id, e.date, timestamp(e.date,e.time),
		e.me, ccgg.f_intake_ht(e.alt,e.elev),timestamp(cd.date,cd.time),cd.inst,cd.value,cd.flag,cd.unc
    from cal_scale_tests.flask_data cd join ccgg.flask_event e on cd.event_num=e.num
    where cd.parameter_num=1 and value!=-888.00;
	#Call sp to insert and archive if needed
	call icp.icp_updateSamplesData(now(),@v_mssg);

	#INSITU
	call icp.icp_updateNOAAx2019InsituSite(75,1,@v_mssg);
	call icp.icp_updateNOAAx2019InsituSite(15,1,@v_mssg);
	call icp.icp_updateNOAAx2019InsituSite(112,1,@v_mssg);
	call icp.icp_updateNOAAx2019InsituSite(113,1,@v_mssg);


end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateNOAAx2019InsituSite` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateNOAAx2019InsituSite`(v_site_num int,v_parameter_num int,inout v_mssg varchar(2000))
begin
    declare tble_name,site,parameter,dt,unc_col varchar(45);
	declare query_text varchar(1000);
	select lower(s.code) into site from gmd.site s where s.num=v_site_num;
	select lower(s.formula) into parameter from gmd.parameter s where s.num=v_parameter_num;
	select case when site in ('mlo','spo','brw','smo') then 'unc' else 'meas_unc' end into unc_col; #annoying col name differences...

	set dt="hr,':',min,':',sec";
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	#Super annoying... have to build query table using passed site code and parameter.
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
	set query_text=concat(query_text,"select 0,",v_site_num,",449,2,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,7 ");
	set query_text=concat(query_text,"from cal_scale_tests.",site,"_",parameter,"_insitu s where value!=-888.00");

	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu;

	#Call sp to insert and archive if needed
	call icp.icp_updateInsituData(now(),v_mssg);

    set v_mssg=concat(site,'_',parameter,'_insitu data:',v_mssg," | ");


	#repeat for hourly data.. we'll use this in time series graphing.
	set dt="hour,':00:',sec";
	drop temporary table if exists tmp.t_insitu;
	create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
	set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
	set query_text=concat(query_text,"select 0,",v_site_num,",449,2,",v_parameter_num,",s.date,timestamp(s.date,concat(hour,':00:00')),'',intake_ht,s.inst,s.value,",unc_col,",s.flag,s.std_dev,2 ");
	set query_text=concat(query_text,"from cal_scale_tests.",site,"_",parameter,"_hour s where value!=-888.00");

	set @s=query_text;

	#select query_text;
	prepare stmt from @s;
	execute stmt;
	deallocate prepare stmt;
	#select * from tmp.t_insitu;

	#Call sp to insert and archive if needed
	call icp.icp_updateInsituData(now(),v_mssg);
	set v_mssg=concat(site,'_',parameter,'_hour data:',v_mssg," | ");


    #Once more for target tanks.
    if(v_site_num in (15,75,112,113)) then #observatories
		if(v_parameter_num = 1 or (v_parameter_num in (1,2,3) and v_site_num=75) or (v_parameter_num in (1,2,3,5) and v_site_num=15)) then #all have co2 targets, only barrow has ch4,co & n2o targets.3/20 mlo appears to have co/ch4/co2 now.
			set dt="hr,':',min,':',sec";
			drop temporary table if exists tmp.t_insitu;
			create temporary table tmp.t_insitu as select * from icp.insitu where 1=0;
			set query_text="insert tmp.t_insitu (num,site_num,lab_num,icpstrat_num,parameter_num,date,e_datetime,method,intake_height,inst,value,unc,flag,stddev,period_num)";
			set query_text=concat(query_text,"select 0,",v_site_num,",449,9,",v_parameter_num,",s.date,timestamp(s.date,concat(",dt,")),type,0,s.inst,s.value,s.unc,s.flag,s.std_dev,7 ");
			set query_text=concat(query_text,"from cal_scale_tests.",site,"_",parameter,"_target s where value!=-888.00");

			set @s=query_text;

			#select query_text;
			prepare stmt from @s;
			execute stmt;
			deallocate prepare stmt;
			#select * from tmp.t_insitu;

			#Call sp to insert and archive if needed
			call icp.icp_updateInsituData(now(),v_mssg);
			set v_mssg=concat(site,'_',parameter,'_target data:',v_mssg," | ");
		end if;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateSamplesData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateSamplesData`(v_archive_dt datetime, inout v_mssg varchar(2000))
begin
/*This is a common method to insert/update the samples table so that we can control archiving when needed.
You can pass v_archive_dt as now() or some past date to reconstruct history.

Requires a filled temp table tmp.t_samples with same cols as icp.samples like this:

create temporary table tmp.t_samples as select * from samples where 1=0;

Existing rows will be updated (and archived), new rows will be inserted.
NOTE; icp_deleteMissingData should be called prior to this for non-incremental updates (whole record updates) to remove records that no longer exist 
or had a primary key changed

If you want/need to delete and reimport; delete from samples table, re-import then call icp_rematchArhiveIDs to fix up ids
This is because some sources give incremental updates.

Only insert columns that actually have data, ie - if no stddev available, do not insert that col or set to null.
values in tmp.t_samples.num col are ignored.
######
When adding cols to samples table
#####; 
add to samples_archive to (in same order)too both default null
add to insert stmt below (make sure to do null check and != check) 
and update stmt below.  Then can fill in caller
*/
	declare vUcount,vIcount,vAcount int default 0;
	if(v_archive_dt is null) then set v_archive_dt=now(); end if;#This will be the 'archive date' (if needed)
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#Drop the num col from tmp table to make queries easier
	alter table tmp.t_samples DROP COLUMN `num`;

	#Fill a tmp table with all the new rows, joining to existing to see if they need update or inserts
	#Unique key defined in the u index on samples table.  
	drop temporary table if exists tmp.t_;
	create temporary table tmp.t_ as select * from icp.samples where 1=0;
    #create temporary table tmp.t_ like icp.samples;#use indexes. (caused issues with dup pk)
					#insert tmp.t_ (num,site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,a_datetime,inst,method,intake_height,value,flag,unc,stddev,reproducibility,pressure,sample_target)
					#select s.num,t.site_num,t.lab_num,t.icpstrat_num,t.parameter_num,t.flask_id,t.date,t.e_datetime,t.a_datetime,t.inst,
					#	t.method,t.intake_height,t.value,t.flag,t.unc,t.stddev,t.reproducibility,t.pressure,t.sample_target
	insert tmp.t_ select case when s.num is null then 0 else s.num end ,t.* #num is non-null, so be explicit in convert to 0	
	#unique joins
	from tmp.t_samples t left join icp.samples s on s.site_num=t.site_num and s.lab_num=t.lab_num and s.icpstrat_num=t.icpstrat_num and s.parameter_num=t.parameter_num
		and s.flask_id=t.flask_id and s.e_datetime=t.e_datetime and s.a_datetime=t.a_datetime and s.inst=t.inst
	where s.num is null or 
		#These cols should be in update statement below.
		#s.value!=t.value or s.flag!=t.flag 
		#I started doing all these, but this seems like overkill, especially since this isn't actual archive (just display of text archive)
		#Actually, switched again, because you can't update things (like method) otherwise...
		s.intake_height!=t.intake_height or s.method!=t.method or s.value!=t.value or s.flag!=t.flag or s.unc!=t.unc or s.stddev!=t.stddev or s.reproducibility!=t.reproducibility
		or s.pressure!=t.pressure or s.sample_target!=t.sample_target or (s.comparison_filter is null and t.comparison_filter is not null) or s.comparison_filter!=t.comparison_filter
        or (s.comparison_target is null and t.comparison_target is not null) or (s.comparison_round is null and t.comparison_round is not null) 
        or s.comparison_target!=t.comparison_target or s.comparison_round!=t.comparison_round
		;
		#select * from tmp.t_;
	#Archive all changes.  We'll let plot logic filter on value if desired.
	#We'll assume the columns are the same (except for archive_date).
	insert icp.samples_archive 
	select v_archive_dt,s.*
	from tmp.t_ t join icp.samples s on t.num=s.num
    on duplicate key update archive_datetime=v_archive_dt;
	set vAcount=row_count();

	#Update changed samples rows.  We'll update anything that changed, but only archive significant changes.
	update icp.samples s, tmp.t_ t 
	set s.intake_height=t.intake_height, s.method=t.method, s.value=t.value, s.flag=t.flag, s.unc=t.unc, s.stddev=t.stddev, 
		s.reproducibility=t.reproducibility, s.pressure=t.pressure, s.sample_target=t.sample_target, s.comparison_filter=t.comparison_filter, s.comparison_target=t.comparison_target, s.comparison_round=t.comparison_round
	where s.num=t.num;
	set vUcount=row_count();

	#Insert any new ones.  Assumes NO_AUTO_VALUE_ON_ZERO mode is not enabled.
	insert icp.samples select * from tmp.t_ t where t.num=0;
	set vIcount=row_count();

	set v_mssg=concat(case when vUcount+vIcount+vAcount=0 then '.' else
		concat(case when vUcount > 0 then concat(vUcount,' icp.samples row(s) updated.  ') else '' end,
				case when vAcount > 0 then concat(vAcount,' icp.samples row(s) archived.  ') else '' end,
				case when vIcount > 0 then concat(vIcount, ' icp.samples row(s) inserted.  ') else '' end
	) end, " | ",v_mssg);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateSite` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateSite`(v_site_num int, inout v_mssg varchar(2000))
begin
/*Updates passed site; icpdata, noaa, data summary and matchdata.  You may want to call icp_deleteDataSet (below) to clean up any previous submissions first.
Note this does not update calibrated tanks (need to call /ccg/non-gmd/src/icp/dbupdate/icp2_updateCalibratedTanks.py)
*/
	declare done int default false;
    declare vsite_num,vlab_num,vparameter_num int;
	declare v_mssg2 varchar(255) default '';
    #cursor that we'll need below to loop through sites to update match data.
	declare acur2 cursor for
		select distinct site_num,lab_num,parameter_num
		from icp.data_summary2 s
		where s.icpstrat_num=1 and s.site_num=v_site_num;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	if (v_mssg is null) then set v_mssg=''; end if;#set default

	#Copy in data from icp tables (do this first so flask data updater knows which noaa data to pull in.
	call icp_updateFromICP(v_site_num,v_mssg);

    #Update NOAA data
    call icp_updateNOAAData(v_site_num,v_mssg);

    #Update datasummary
    call icp2_updateDataSummary(v_site_num);

    #Update target data
    call icp_updateMagiccTargetDataFromCals(v_mssg);

    #Update hats data
    call icp_updateHATSData(v_site_num,v_mssg);

     #Meni -
    call icp_updateMENIDataFromCals(v_mssg);


    #Update match data
    #Disabling for now...  Front end not using it.
    /*open acur2;
	set done=false;
	read_loop: LOOP
		fetch acur2 into vsite_num,vlab_num,vparameter_num;
		if (done=true) then LEAVE read_loop; end if;
		call icp2_updateMatchData(vsite_num,vlab_num,vparameter_num,v_mssg2);
	END LOOP;
	close acur2;
*/
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `icp_updateWMORRData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `icp_updateWMORRData`(inout v_mssg varchar(255))
begin
/*updates/adds any noaa pfp/flask results for all sites in the icp2 tables.  Pass v_site_num -1 for all*/
	#cursor for below loop
    declare done int default false;
    declare vsite_num int default 481;#rri
    declare vicpstrat_num int default 3;#rr
    declare vlab_num,vparameter_num int default 0;

	drop temporary table if exists tmp.t_samples;
	if (v_mssg is null) then set v_mssg=''; end if;#set default

	create temporary table tmp.t_samples as select * from icp.samples where 1=0;
    #create temporary table tmp.t_samples like icp.samples;#create with indexes
	#NOTE; use wmorr.wmorr_data_view.lab_data_num to lookup comparison_filter info in icp logic.
    #select * from wmorr.wmorr_data_view;
	insert tmp.t_samples (site_num,lab_num,icpstrat_num,parameter_num,flask_id,date,e_datetime,method,intake_height,a_datetime,inst,value,flag,unc,comparison_filter,pressure,comparison_round,comparison_target)
	select vsite_num,lab_num,vicpstrat_num,parameter_num,cyl_id,cyl_fill_date,cyl_fill_date, method, 0,
		#annoyingly there are duplicate entries, not sure why.  Will need to check idl code to see how it handles, but for now including all which may mess with stats.
        #adding uniq id # of seconds to adate to uniqify.
		timestamp(case when (select count(*) from wmorr.wmorr_data_view where lab_num=d.lab_num and parameter_num=d.parameter_num and cyl_id=d.cyl_id
			and cyl_fill_date=d.cyl_fill_date and measurement_date=d.measurement_date and (inst=d.inst or inst is null))>1 then date_add(measurement_date,interval lab_data_num second)
            else measurement_date end) as measurement_date,
	inst, value,'...', unc, group_num,final_pressure,rr_num, cyl_range

	from wmorr.wmorr_data_view d
    #where lab_data_num not in (124) #annoying duplicate entries. not sure why.
	;

	call icp_updateSamplesData(now(),v_mssg);
	set v_mssg=concat('wmorr update: ',v_mssg);
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `data_summary2_view`
--

/*!50001 DROP TABLE IF EXISTS `data_summary2_view`*/;
/*!50001 DROP VIEW IF EXISTS `data_summary2_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `data_summary2_view` AS select `s`.`code` AS `site`,`l`.`abbr` AS `lab`,`st`.`abbr` AS `strategy`,`p`.`formula` AS `parameter`,min(`d`.`first`) AS `first`,max(`d`.`last`) AS `last`,sum(`d`.`num_rows`) AS `n`,`d`.`site_num` AS `site_num`,`d`.`lab_num` AS `lab_num`,`d`.`icpstrat_num` AS `icpstrat_num`,`d`.`parameter_num` AS `parameter_num`,`d`.`inst` AS `inst` from ((((`icp`.`data_summary2` `d` join `gmd`.`site` `s` on(`d`.`site_num` = `s`.`num`)) join `obspack`.`lab` `l` on(`d`.`lab_num` = `l`.`num`)) join `icp`.`icpstrat` `st` on(`d`.`icpstrat_num` = `st`.`num`)) join `gmd`.`parameter` `p` on(`d`.`parameter_num` = `p`.`num`)) group by `s`.`code`,`l`.`abbr`,`st`.`abbr`,`p`.`formula`,`d`.`site_num`,`d`.`lab_num`,`d`.`icpstrat_num`,`d`.`parameter_num`,`d`.`inst` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `flask_event_subsite_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_event_subsite_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_event_subsite_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`140.172.193.%` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_subsite_view` AS select case when `e`.`site_num` = 647 then case when `e`.`lat` > 33.87 and `e`.`lat` < 33.89 and `e`.`lon` > -117.89 and `e`.`lon` < -117.87 then 785 when `e`.`lat` > 34.01 and `e`.`lat` < 34.03 and `e`.`lon` > -118.29 and `e`.`lon` < -118.27 then 786 when `e`.`lat` > 34.27 and `e`.`lat` < 34.29 and `e`.`lon` > -118.48 and `e`.`lon` < -118.46 then 787 when `e`.`lat` = 34.14 and `e`.`lon` = -118.13 then 869 else 'unknown LAC subsite' end else `s`.`num` end AS `subsite_num`,`e`.`num` AS `num`,`e`.`site_num` AS `site_num`,`e`.`project_num` AS `project_num`,`e`.`strategy_num` AS `strategy_num`,`e`.`date` AS `date`,`e`.`time` AS `time`,`e`.`dd` AS `dd`,`e`.`id` AS `id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `comment` from (`ccgg`.`flask_event` `e` join `gmd`.`site` `s`) where `e`.`site_num` = `s`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `insitu_data_view`
--

/*!50001 DROP TABLE IF EXISTS `insitu_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `insitu_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `insitu_data_view` AS select `i`.`num` AS `num`,`i`.`site_num` AS `site_num`,`s`.`code` AS `site`,`i`.`lab_num` AS `lab_num`,`l`.`abbr` AS `lab`,`i`.`icpstrat_num` AS `icpstrat_num`,`st`.`abbr` AS `strategy`,`i`.`parameter_num` AS `parameter_num`,`p`.`formula` AS `parameter`,`i`.`period_num` AS `period_num`,`per`.`abbr` AS `period`,`i`.`date` AS `date`,`i`.`e_datetime` AS `e_datetime`,`i`.`method` AS `method`,`i`.`intake_height` AS `intake_height`,`i`.`inst` AS `inst`,`i`.`value` AS `value`,`i`.`unc` AS `unc`,`i`.`flag` AS `flag`,`i`.`stddev` AS `stddev` from (((((`icp`.`insitu` `i` join `gmd`.`site` `s` on(`i`.`site_num` = `s`.`num`)) join `obspack`.`lab` `l` on(`i`.`lab_num` = `l`.`num`)) join `icp`.`icpstrat` `st` on(`i`.`icpstrat_num` = `st`.`num`)) join `gmd`.`parameter` `p` on(`i`.`parameter_num` = `p`.`num`)) join `icp`.`aggregate_periods` `per` on(`i`.`period_num` = `per`.`num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sample_data_view`
--

/*!50001 DROP TABLE IF EXISTS `sample_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `sample_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `sample_data_view` AS select `i`.`num` AS `num`,`i`.`site_num` AS `site_num`,`s`.`code` AS `site`,`i`.`lab_num` AS `lab_num`,`l`.`abbr` AS `lab`,`i`.`icpstrat_num` AS `icpstrat_num`,`st`.`abbr` AS `strategy`,`i`.`parameter_num` AS `parameter_num`,`p`.`formula` AS `parameter`,`i`.`flask_id` AS `flask_id`,`i`.`date` AS `date`,`i`.`e_datetime` AS `e_datetime`,`i`.`method` AS `method`,`i`.`intake_height` AS `intake_height`,`i`.`a_datetime` AS `a_datetime`,`i`.`inst` AS `inst`,`i`.`value` AS `value`,`i`.`unc` AS `unc`,`i`.`flag` AS `flag`,`i`.`stddev` AS `stddev`,`i`.`reproducibility` AS `reproducibility`,`i`.`pressure` AS `pressure`,`i`.`sample_target` AS `sample_target`,`i`.`manifold` AS `manifold`,`i`.`port` AS `port`,`i`.`comparison_filter` AS `comparison_filter`,`i`.`comparison_target` AS `comparison_target`,`i`.`comparison_round` AS `comparison_round`,`i`.`data_num` AS `data_num` from ((((`icp`.`samples` `i` join `gmd`.`site` `s` on(`i`.`site_num` = `s`.`num`)) join `obspack`.`lab` `l` on(`i`.`lab_num` = `l`.`num`)) join `icp`.`icpstrat` `st` on(`i`.`icpstrat_num` = `st`.`num`)) join `gmd`.`parameter` `p` on(`i`.`parameter_num` = `p`.`num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sausage_calibrated_values_view2`
--

/*!50001 DROP TABLE IF EXISTS `sausage_calibrated_values_view2`*/;
/*!50001 DROP VIEW IF EXISTS `sausage_calibrated_values_view2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `sausage_calibrated_values_view2` AS select `c`.`site_num` AS `site_num`,`c`.`lab_num` AS `lab_num`,`c`.`lab` AS `lab`,`c`.`icpstrat_num` AS `icpstrat_num`,NULL AS `group_num`,`c`.`comparison_round` AS `round`,`c`.`comparison_target` AS `target`,group_concat(`c`.`flask_id` order by `c`.`flask_id` ASC separator ',') AS `cyl_id`,`c`.`parameter_num` AS `parameter_num`,`c`.`date` AS `start_date`,`c`.`date` AS `end_date`,0 AS `zero_dd`,1 AS `ncoef`,avg(`c`.`value`) AS `coef1`,0 AS `coef2`,0 AS `coef3`,0 AS `coef4`,0 AS `coef5`,avg(`c`.`unc`) AS `coef_unc`,count(0) AS `nvalues`,max(`c`.`value`) - min(`c`.`value`) AS `pair_diff`,case when count(0) = 1 then 0 else 1 end AS `num_pairs`,max(`c`.`a_datetime`) AS `a_datetime`,group_concat(`c`.`flag` order by `c`.`flask_id` ASC separator ',') AS `flag` from `icp`.`sample_data_view` `c` where `c`.`site_num` = 310 and `c`.`icpstrat_num` = 4 and `c`.`flag` like '.%' and (`c`.`lab_num` <> 45 or `c`.`flag` like '%1') group by `c`.`site_num`,`c`.`lab_num`,`c`.`lab`,`c`.`icpstrat_num`,`c`.`comparison_round`,`c`.`comparison_target`,`c`.`parameter_num`,`c`.`date` order by `c`.`date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sausage_data_view`
--

/*!50001 DROP TABLE IF EXISTS `sausage_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `sausage_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `sausage_data_view` AS select group_concat(`sample_data_view`.`num` separator ',') AS `num`,`sample_data_view`.`site_num` AS `site_num`,`sample_data_view`.`site` AS `site`,`sample_data_view`.`lab_num` AS `lab_num`,`sample_data_view`.`lab` AS `lab`,`sample_data_view`.`icpstrat_num` AS `icpstrat_num`,`sample_data_view`.`strategy` AS `strategy`,`sample_data_view`.`parameter_num` AS `parameter_num`,`sample_data_view`.`parameter` AS `parameter`,group_concat(`sample_data_view`.`flask_id` separator ',') AS `flask_id`,`sample_data_view`.`date` AS `date`,`sample_data_view`.`e_datetime` AS `e_datetime`,`sample_data_view`.`method` AS `method`,`sample_data_view`.`intake_height` AS `intake_height`,min(`sample_data_view`.`a_datetime`) AS `a_datetime`,`sample_data_view`.`inst` AS `inst`,avg(`sample_data_view`.`value`) AS `value`,max(`sample_data_view`.`flag`) AS `flag`,avg(`sample_data_view`.`unc`) AS `unc`,std(`sample_data_view`.`value`) AS `stddev`,`sample_data_view`.`comparison_filter` AS `comparison_filter`,`sample_data_view`.`comparison_round` AS `comparison_round`,`sample_data_view`.`comparison_target` AS `comparison_target` from `icp`.`sample_data_view` where `sample_data_view`.`site_num` = 310 and `sample_data_view`.`icpstrat_num` = 4 and `sample_data_view`.`flag` like '.%' and `sample_data_view`.`flag`  not like '%1' and `sample_data_view`.`flag`  not like '%2' group by `sample_data_view`.`site_num`,`sample_data_view`.`site`,`sample_data_view`.`lab_num`,`sample_data_view`.`lab`,`sample_data_view`.`icpstrat_num`,`sample_data_view`.`strategy`,`sample_data_view`.`parameter_num`,`sample_data_view`.`parameter`,`sample_data_view`.`date`,`sample_data_view`.`e_datetime`,`sample_data_view`.`method`,`sample_data_view`.`intake_height`,`sample_data_view`.`inst`,`sample_data_view`.`comparison_filter`,`sample_data_view`.`comparison_round`,`sample_data_view`.`comparison_target` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `sausage_data_view2`
--

/*!50001 DROP TABLE IF EXISTS `sausage_data_view2`*/;
/*!50001 DROP VIEW IF EXISTS `sausage_data_view2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `sausage_data_view2` AS select group_concat(`sample_data_view`.`num` separator ',') AS `num`,`sample_data_view`.`site_num` AS `site_num`,`sample_data_view`.`site` AS `site`,`sample_data_view`.`lab_num` AS `lab_num`,`sample_data_view`.`lab` AS `lab`,`sample_data_view`.`icpstrat_num` AS `icpstrat_num`,`sample_data_view`.`strategy` AS `strategy`,`sample_data_view`.`parameter_num` AS `parameter_num`,`sample_data_view`.`parameter` AS `parameter`,group_concat(`sample_data_view`.`flask_id` order by `sample_data_view`.`flask_id` ASC separator ',') AS `flask_id`,`sample_data_view`.`date` AS `date`,`sample_data_view`.`e_datetime` AS `e_datetime`,`sample_data_view`.`method` AS `method`,`sample_data_view`.`intake_height` AS `intake_height`,min(`sample_data_view`.`a_datetime`) AS `a_datetime`,`sample_data_view`.`inst` AS `inst`,avg(`sample_data_view`.`value`) AS `value`,group_concat(`sample_data_view`.`flag` order by `sample_data_view`.`flask_id` ASC separator ',') AS `flag`,max(`sample_data_view`.`unc`) AS `unc`,std(`sample_data_view`.`value`) AS `stddev`,max(`sample_data_view`.`value`) - min(`sample_data_view`.`value`) AS `pair_diff`,case when count(0) = 1 then 0 else 1 end AS `num_pairs`,`sample_data_view`.`comparison_filter` AS `comparison_filter`,`sample_data_view`.`comparison_round` AS `comparison_round`,`sample_data_view`.`comparison_target` AS `comparison_target` from `icp`.`sample_data_view` where `sample_data_view`.`site_num` = 310 and `sample_data_view`.`icpstrat_num` = 4 and `sample_data_view`.`flag` like '.%' and (`sample_data_view`.`lab_num` <> 45 or `sample_data_view`.`flag` like '%1') group by `sample_data_view`.`site_num`,`sample_data_view`.`site`,`sample_data_view`.`lab_num`,`sample_data_view`.`lab`,`sample_data_view`.`icpstrat_num`,`sample_data_view`.`strategy`,`sample_data_view`.`parameter_num`,`sample_data_view`.`parameter`,`sample_data_view`.`date`,`sample_data_view`.`e_datetime`,`sample_data_view`.`method`,`sample_data_view`.`intake_height`,`sample_data_view`.`inst`,`sample_data_view`.`comparison_filter`,`sample_data_view`.`comparison_round`,`sample_data_view`.`comparison_target` */;
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

-- Dump completed on 2025-04-17 10:09:10
