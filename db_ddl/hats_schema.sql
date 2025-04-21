-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: hats
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
-- Table structure for table `Glass_Flasks`
--

DROP TABLE IF EXISTS `Glass_Flasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Glass_Flasks` (
  `Flask_no` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Flask_no`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PR1_adsorbed_air`
--

DROP TABLE IF EXISTS `PR1_adsorbed_air`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PR1_adsorbed_air` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `inst_num` int(11) NOT NULL,
  `trap_id` varchar(45) DEFAULT NULL,
  `start_datetime` datetime NOT NULL,
  `adsorb_file` varchar(255) DEFAULT NULL,
  `comment` varchar(45) DEFAULT NULL,
  `formula` varchar(45) DEFAULT NULL,
  `xmean` double DEFAULT NULL,
  `xstd` double DEFAULT NULL,
  `ymean` double DEFAULT NULL,
  `ystd` double DEFAULT NULL,
  `p00` decimal(20,18) DEFAULT 0.000000000000000000,
  `p01` decimal(20,18) DEFAULT 0.000000000000000000,
  `p02` decimal(20,18) DEFAULT 0.000000000000000000,
  `p03` decimal(20,18) DEFAULT 0.000000000000000000,
  `p04` decimal(20,18) DEFAULT 0.000000000000000000,
  `p05` decimal(20,18) DEFAULT 0.000000000000000000,
  `p10` decimal(20,18) DEFAULT 0.000000000000000000,
  `p11` decimal(20,18) DEFAULT 0.000000000000000000,
  `p12` decimal(20,18) DEFAULT 0.000000000000000000,
  `p13` decimal(20,18) DEFAULT 0.000000000000000000,
  `p14` decimal(20,18) DEFAULT 0.000000000000000000,
  `p20` decimal(20,18) DEFAULT 0.000000000000000000,
  `p21` decimal(20,18) DEFAULT 0.000000000000000000,
  `p22` decimal(20,18) DEFAULT 0.000000000000000000,
  `p23` decimal(20,18) DEFAULT 0.000000000000000000,
  `p30` decimal(20,18) DEFAULT 0.000000000000000000,
  `p31` decimal(20,18) DEFAULT 0.000000000000000000,
  `p32` decimal(20,18) DEFAULT 0.000000000000000000,
  `p40` decimal(20,18) DEFAULT 0.000000000000000000,
  `p41` decimal(20,18) DEFAULT 0.000000000000000000,
  `p50` decimal(20,18) DEFAULT 0.000000000000000000,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `index2` (`inst_num`,`start_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PR1_blank_correction`
--

DROP TABLE IF EXISTS `PR1_blank_correction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PR1_blank_correction` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `parameter_num` int(11) NOT NULL,
  `parameter` varchar(45) NOT NULL,
  `inst_num` int(11) NOT NULL,
  `blank` int(11) NOT NULL DEFAULT 0,
  `start_datetime` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  PRIMARY KEY (`idx`),
  UNIQUE KEY `idx_UNIQUE` (`inst_num`,`parameter_num`,`start_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PR1_peak_response`
--

DROP TABLE IF EXISTS `PR1_peak_response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PR1_peak_response` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `formula` varchar(110) DEFAULT NULL,
  `parameter_num` int(11) NOT NULL,
  `inst_num` int(11) NOT NULL,
  `response` varchar(106) DEFAULT NULL,
  `area` int(11) DEFAULT NULL,
  `start_date` datetime NOT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `u` (`inst_num`,`parameter_num`,`start_date`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Status_MetData`
--

DROP TABLE IF EXISTS `Status_MetData`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Status_MetData` (
  `Station` varchar(50) DEFAULT NULL,
  `Flask_1` smallint(6) DEFAULT NULL,
  `Pressure_1` float DEFAULT NULL,
  `Flask_2` smallint(6) DEFAULT NULL,
  `Pressure_2` float DEFAULT NULL,
  `PairID` int(11) NOT NULL AUTO_INCREMENT,
  `Flask_Type` enum('G','S','SA','S85','SG') DEFAULT NULL,
  `Login_Date` datetime DEFAULT NULL,
  `Sample_Date` int(7) DEFAULT NULL,
  `sample_datetime_utc` datetime DEFAULT NULL,
  `Logout_Date` datetime DEFAULT NULL,
  `Logout_Location` varchar(50) DEFAULT NULL,
  `Operator` varchar(50) DEFAULT NULL,
  `Wind_Speed` double DEFAULT NULL,
  `Wind_Direction` double DEFAULT NULL,
  `Air_Temp` double DEFAULT NULL,
  `Dew_Point` double DEFAULT NULL,
  `Precipitation` varchar(10) DEFAULT NULL,
  `Sky` varchar(10) DEFAULT NULL,
  `Comments` varchar(1024) DEFAULT NULL,
  `CounterForInHouse` smallint(6) DEFAULT NULL,
  `HCFC_MS` varchar(50) DEFAULT NULL,
  `HFC_MS` varchar(50) DEFAULT NULL,
  `LEAPS` varchar(50) DEFAULT NULL,
  `Otto` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`PairID`),
  KEY `i2` (`Station`,`Flask_1`,`sample_datetime_utc`),
  KEY `i3` (`PairID`,`Flask_1`,`sample_datetime_utc`,`Station`),
  KEY `i4` (`PairID`,`Flask_2`,`sample_datetime_utc`,`Station`),
  KEY `i5` (`sample_datetime_utc`,`PairID`)
) ENGINE=InnoDB AUTO_INCREMENT=17413 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Status_MetData_21.8.11_unused`
--

DROP TABLE IF EXISTS `Status_MetData_21.8.11_unused`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Status_MetData_21.8.11_unused` (
  `Station` varchar(50) DEFAULT NULL,
  `Flask_1` smallint(6) DEFAULT NULL,
  `Pressure 1` float DEFAULT NULL,
  `Flask_2` smallint(6) DEFAULT NULL,
  `Pressure 2` float DEFAULT NULL,
  `PairID` int(11) DEFAULT NULL,
  `Login_Date` datetime DEFAULT NULL,
  `Sample_Date` float DEFAULT NULL,
  `Normal_Sample_Date` datetime DEFAULT NULL,
  `Logout_Date` datetime DEFAULT NULL,
  `GMT` datetime DEFAULT NULL,
  `Operator` varchar(50) DEFAULT NULL,
  `Wind_Speed` double DEFAULT NULL,
  `Wind_Direction` double DEFAULT NULL,
  `Air_Temp` double DEFAULT NULL,
  `Dew_Point` double DEFAULT NULL,
  `Precipitation` varchar(10) DEFAULT NULL,
  `Sky` varchar(10) DEFAULT NULL,
  `Comments` varchar(100) DEFAULT NULL,
  `CounterForInHouse` smallint(6) DEFAULT NULL,
  `HCFC-MS` varchar(50) DEFAULT NULL,
  `HFC-MS` varchar(50) DEFAULT NULL,
  `LEAPS` varchar(50) DEFAULT NULL,
  `Otto` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `Status_MetData_view`
--

DROP TABLE IF EXISTS `Status_MetData_view`;
/*!50001 DROP VIEW IF EXISTS `Status_MetData_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `Status_MetData_view` (
  `Normal_Sample_Date` tinyint NOT NULL,
  `GMT` tinyint NOT NULL,
  `Station` tinyint NOT NULL,
  `Flask_1` tinyint NOT NULL,
  `Pressure_1` tinyint NOT NULL,
  `Flask_2` tinyint NOT NULL,
  `Pressure_2` tinyint NOT NULL,
  `PairID` tinyint NOT NULL,
  `Login_date` tinyint NOT NULL,
  `sample_datetime_utc` tinyint NOT NULL,
  `Logout_Date` tinyint NOT NULL,
  `Operator` tinyint NOT NULL,
  `Wind_Speed` tinyint NOT NULL,
  `Wind_Direction` tinyint NOT NULL,
  `Air_Temp` tinyint NOT NULL,
  `Dew_Point` tinyint NOT NULL,
  `Precipitation` tinyint NOT NULL,
  `Sky` tinyint NOT NULL,
  `Comments` tinyint NOT NULL,
  `CounterForInHouse` tinyint NOT NULL,
  `HCFC_MS` tinyint NOT NULL,
  `HFC_MS` tinyint NOT NULL,
  `LEAPS` tinyint NOT NULL,
  `Otto` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Steel_Flasks`
--

DROP TABLE IF EXISTS `Steel_Flasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Steel_Flasks` (
  `Flask_no` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Flask_no`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Table_ChemBatchData`
--

DROP TABLE IF EXISTS `Table_ChemBatchData`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Table_ChemBatchData` (
  `Batch_Number` int(11) DEFAULT NULL,
  `Group` int(11) DEFAULT NULL,
  `FillDate` datetime DEFAULT NULL,
  `RegulatorSN` varchar(50) DEFAULT NULL,
  `Tank_Number` varchar(50) DEFAULT NULL,
  `Tank_Date` datetime DEFAULT NULL,
  `Tank_CO2` double DEFAULT NULL,
  `Tank_Press_Max` int(11) DEFAULT NULL,
  `Tank_Press_Min` int(11) DEFAULT NULL,
  `Flask_Avg-Delete` double DEFAULT NULL,
  `Flask_Dev-Delete` double DEFAULT NULL,
  `Flask_Range-Delete` double DEFAULT NULL,
  `GeneralComments` mediumtext DEFAULT NULL,
  `OLE_File` mediumblob DEFAULT NULL,
  `Operator` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Table_ChemBatchFlasks`
--

DROP TABLE IF EXISTS `Table_ChemBatchFlasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Table_ChemBatchFlasks` (
  `Batch_Number` int(11) DEFAULT NULL,
  `Flask` int(11) DEFAULT NULL,
  `Flask_CO2` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Table_ChemBatchPCPtoPFP`
--

DROP TABLE IF EXISTS `Table_ChemBatchPCPtoPFP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Table_ChemBatchPCPtoPFP` (
  `Batch_Number` int(11) DEFAULT NULL,
  `PCP_Number` varchar(50) DEFAULT NULL,
  `PFP_Number` varchar(50) DEFAULT NULL,
  `TestType` varchar(50) DEFAULT NULL,
  `Comment` varchar(50) DEFAULT NULL,
  `MAGICC2` varchar(50) DEFAULT NULL,
  `GCMS` varchar(50) DEFAULT NULL,
  `Disposition` varchar(50) DEFAULT NULL,
  `Flask-PFP` double DEFAULT NULL,
  `StdDev` double DEFAULT NULL,
  `F-Avg` double DEFAULT NULL,
  `P-Avg` double DEFAULT NULL,
  `Tank` double DEFAULT NULL,
  `Analysis_Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Table_PCP_Baseline`
--

DROP TABLE IF EXISTS `Table_PCP_Baseline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Table_PCP_Baseline` (
  `PCP_Number` varchar(7) DEFAULT NULL,
  `PCP_Location` varchar(50) DEFAULT NULL,
  `DateInLab` datetime DEFAULT NULL,
  `Firmware` varchar(50) DEFAULT NULL,
  `Category` varchar(255) DEFAULT NULL,
  `1stPumpSN` varchar(50) DEFAULT NULL,
  `1stPumpDiaType` varchar(50) DEFAULT NULL,
  `2ndPumpSN` varchar(50) DEFAULT NULL,
  `2ndPumpDiaType` varchar(50) DEFAULT NULL,
  `PumpComments` mediumtext DEFAULT NULL,
  `ChemTestPassed` varchar(50) DEFAULT NULL,
  `ChemTestComments` mediumtext DEFAULT NULL,
  `BatteryDate` datetime DEFAULT NULL,
  `BatteryComments` mediumtext DEFAULT NULL,
  `ChargerBoardType` varchar(50) DEFAULT NULL,
  `WeldedFlexTubes` bit(1) DEFAULT NULL,
  `FlexTubesComments` mediumtext DEFAULT NULL,
  `PCP_Status` varchar(50) DEFAULT NULL,
  `DateCompleted` datetime DEFAULT NULL,
  `GeneralComments` mediumtext DEFAULT NULL,
  `Pump Diaphragm Type` varchar(255) DEFAULT NULL,
  `Diaphragm Change Date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analysis`
--

DROP TABLE IF EXISTS `analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis` (
  `num` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `analysis_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `inst_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `sample_ID` tinytext NOT NULL DEFAULT '',
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `sample_type` tinytext NOT NULL DEFAULT '',
  `port` smallint(2) unsigned NOT NULL DEFAULT 0,
  `standards_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `std_serial_num` varchar(45) DEFAULT NULL,
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `lab_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`analysis_datetime`,`inst_num`),
  KEY `event_num` (`event_num`),
  KEY `i2` (`event_num`,`sample_ID`(255),`sample_type`(255)),
  KEY `i1` (`analysis_datetime`,`sample_type`(255))
) ENGINE=InnoDB AUTO_INCREMENT=331810 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analysis_20240308`
--

DROP TABLE IF EXISTS `analysis_20240308`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis_20240308` (
  `num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `analysis_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `inst_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `sample_ID` tinytext NOT NULL DEFAULT '',
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `sample_type` tinytext NOT NULL DEFAULT '',
  `port` smallint(2) unsigned NOT NULL DEFAULT 0,
  `standards_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `lab_num` tinyint(3) unsigned NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analysis_20240322`
--

DROP TABLE IF EXISTS `analysis_20240322`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis_20240322` (
  `num` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `analysis_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `inst_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `sample_ID` tinytext NOT NULL DEFAULT '',
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `sample_type` tinytext NOT NULL DEFAULT '',
  `port` smallint(2) unsigned NOT NULL DEFAULT 0,
  `standards_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `event_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `lab_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`),
  KEY `i1` (`analysis_datetime`),
  KEY `event_num` (`event_num`),
  KEY `i2` (`event_num`,`sample_ID`(255),`sample_type`(255))
) ENGINE=MyISAM AUTO_INCREMENT=307701 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analyte_list`
--

DROP TABLE IF EXISTS `analyte_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analyte_list` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `display_name` varchar(20) NOT NULL,
  `param_num` varchar(20) NOT NULL,
  `inst_num` int(11) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `channel` varchar(1) DEFAULT NULL,
  `ion` int(11) DEFAULT NULL,
  `disp_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u1` (`param_num`,`inst_num`,`start_date`,`channel`,`ion`),
  KEY `i2` (`display_name`,`param_num`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ancillary_data`
--

DROP TABLE IF EXISTS `ancillary_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ancillary_data` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `ancillary_num` smallint(5) unsigned NOT NULL,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  PRIMARY KEY (`analysis_num`,`ancillary_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ancillary_def`
--

DROP TABLE IF EXISTS `ancillary_def`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ancillary_def` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `diagnostic` tinytext NOT NULL DEFAULT '',
  `description` tinytext NOT NULL DEFAULT '',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `data_exclusions`
--

DROP TABLE IF EXISTS `data_exclusions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_exclusions` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `inst_num` int(11) NOT NULL,
  `sample_type` varchar(45) NOT NULL,
  `a_start_date` date NOT NULL,
  `a_end_date` date NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`,`sample_type`),
  UNIQUE KEY `u` (`inst_num`,`sample_type`,`parameter_num`,`a_start_date`),
  KEY `i` (`sample_type`,`parameter_num`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
  `program_num` tinyint(3) unsigned NOT NULL DEFAULT 5,
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `first` date NOT NULL DEFAULT '0000-00-00',
  `last` date NOT NULL DEFAULT '0000-00-00',
  `count` mediumint(8) NOT NULL DEFAULT 0,
  `prelim_start` date NOT NULL,
  `prelim_end` date NOT NULL,
  PRIMARY KEY (`site_num`,`project_num`,`program_num`,`parameter_num`),
  KEY `status_num` (`status_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dbedit_changelog`
--

DROP TABLE IF EXISTS `dbedit_changelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dbedit_changelog` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(20) NOT NULL,
  `date` datetime NOT NULL,
  `query_string` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=4905 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='log of changes made with dbedit';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dev_flags_internal`
--

DROP TABLE IF EXISTS `dev_flags_internal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dev_flags_internal` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `iflag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext NOT NULL,
  PRIMARY KEY (`analysis_num`,`parameter_num`,`iflag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dev_flags_sample`
--

DROP TABLE IF EXISTS `dev_flags_sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dev_flags_sample` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `sample_flag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext NOT NULL,
  PRIMARY KEY (`analysis_num`,`sample_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dev_flags_system`
--

DROP TABLE IF EXISTS `dev_flags_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dev_flags_system` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `sflag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext NOT NULL,
  PRIMARY KEY (`analysis_num`,`sflag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `extinguisher_exclusion`
--

DROP TABLE IF EXISTS `extinguisher_exclusion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `extinguisher_exclusion` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(6) NOT NULL,
  `project` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `display_name` varchar(45) NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `site_num_UNIQUE` (`idx`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fe3_raw_data`
--

DROP TABLE IF EXISTS `fe3_raw_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fe3_raw_data` (
  `analysis_num` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_time` datetime DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `peak_rt` double(12,2) DEFAULT NULL,
  `peak_ht` double(12,2) DEFAULT NULL,
  `peak_area` double(12,2) DEFAULT NULL,
  `molecule` varchar(8) DEFAULT NULL,
  `run_num` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`analysis_num`)
) ENGINE=InnoDB AUTO_INCREMENT=191641 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fi`
--

DROP TABLE IF EXISTS `fi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fi` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `iflag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext DEFAULT '',
  `tag_num` int(11) NOT NULL COMMENT 'Fkey to ccgg.tag_dictionary',
  PRIMARY KEY (`analysis_num`,`parameter_num`,`tag_num`),
  KEY `i1` (`tag_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_external`
--

DROP TABLE IF EXISTS `flags_external`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_external` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `flag` varchar(4) NOT NULL DEFAULT '..p',
  `comment` tinytext NOT NULL DEFAULT '',
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_internal`
--

DROP TABLE IF EXISTS `flags_internal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_internal` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `iflag` varchar(2) NOT NULL DEFAULT '',
  `comment` tinytext DEFAULT '',
  `tag_num` int(11) NOT NULL COMMENT 'Fkey to ccgg.tag_dictionary',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`analysis_num`,`parameter_num`,`tag_num`),
  KEY `i1` (`tag_num`)
) ENGINE=InnoDB AUTO_INCREMENT=2891855 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER `hats`.`flags_internal_BEFORE_INSERT` BEFORE INSERT ON `flags_internal` FOR EACH ROW
BEGIN
	if (new.tag_num is null) then 
		set new.tag_num = (select tv.tag_num from ccgg.tag_view tv join 
			hats.analysis a on  a.inst_num=tv.inst_num and tv.program_num=8 and tv.flag=new.iflag
            where a.num=new.analysis_num limit 1);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER hats._auditlog_flags_internal_after_insert after insert ON hats.flags_internal FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('analysis_num',':',ifnull(NEW.analysis_num,'null')), concat('parameter_num',':',ifnull(NEW.parameter_num,'null')), concat('iflag',':',ifnull(NEW.iflag,'null')), concat('comment',':',ifnull(NEW.comment,'null')), concat('tag_num',':',ifnull(NEW.tag_num,'null'))),'hats','flags_internal',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER hats._auditlog_flags_internal_after_update after update ON hats.flags_internal FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.analysis_num <> OLD.analysis_num, concat('analysis_num(Old:',OLD.analysis_num,' New:',NEW.analysis_num,')'), NULL), IF(NEW.parameter_num <> OLD.parameter_num, concat('parameter_num(Old:',OLD.parameter_num,' New:',NEW.parameter_num,')'), NULL), IF(NEW.iflag <> OLD.iflag, concat('iflag(Old:',OLD.iflag,' New:',NEW.iflag,')'), NULL), IF(NEW.comment <> OLD.comment, concat('comment(Old:',OLD.comment,' New:',NEW.comment,')'), NULL), IF(NEW.tag_num <> OLD.tag_num, concat('tag_num(Old:',OLD.tag_num,' New:',NEW.tag_num,')'), NULL)),'hats', 'flags_internal',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER hats._auditlog_flags_internal_before_delete before delete ON hats.flags_internal FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('analysis_num',':',ifnull(OLD.analysis_num,'null')), concat('parameter_num',':',ifnull(OLD.parameter_num,'null')), concat('iflag',':',ifnull(OLD.iflag,'null')), concat('comment',':',ifnull(OLD.comment,'null')), concat('tag_num',':',ifnull(OLD.tag_num,'null'))),'hats', 'flags_internal',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `flags_internal_def`
--

DROP TABLE IF EXISTS `flags_internal_def`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_internal_def` (
  `iflag` text DEFAULT NULL,
  `class` text DEFAULT NULL,
  `category` text DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_sample`
--

DROP TABLE IF EXISTS `flags_sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_sample` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `sample_flag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext NOT NULL DEFAULT '',
  PRIMARY KEY (`analysis_num`,`sample_flag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_sample_def`
--

DROP TABLE IF EXISTS `flags_sample_def`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_sample_def` (
  `flag` varchar(1) NOT NULL,
  `comment` tinytext NOT NULL,
  PRIMARY KEY (`flag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_system`
--

DROP TABLE IF EXISTS `flags_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_system` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `sflag` varchar(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL,
  `comment` tinytext NOT NULL DEFAULT '',
  `tag_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`analysis_num`,`sflag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flags_system_def`
--

DROP TABLE IF EXISTS `flags_system_def`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flags_system_def` (
  `sflag` text DEFAULT NULL,
  `Class` text DEFAULT NULL,
  `Description` text DEFAULT NULL
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
  `flag` varchar(4) NOT NULL DEFAULT '...',
  `inst` varchar(4) NOT NULL DEFAULT '',
  `system` varchar(12) NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `comment` text NOT NULL,
  `creation_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i2` (`parameter_num`),
  KEY `i3` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `inst` (`inst`),
  KEY `i1` (`event_num`,`program_num`,`parameter_num`,`inst`,`date`,`time`),
  KEY `cts` (`creation_datetime`)
) ENGINE=MyISAM AUTO_INCREMENT=10350875 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flask_data_20200416`
--

DROP TABLE IF EXISTS `flask_data_20200416`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data_20200416` (
  `event_num` mediumint(8) unsigned DEFAULT NULL,
  `program_num` int(11) unsigned NOT NULL DEFAULT 1,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `value` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `unc` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `flag` varchar(4) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL DEFAULT '...',
  `inst` varchar(4) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL DEFAULT '00:00:00',
  `dd` double(14,9) NOT NULL DEFAULT 0.000000000,
  `comment` tinytext NOT NULL,
  KEY `i2` (`parameter_num`),
  KEY `i3` (`date`,`time`),
  KEY `dd` (`dd`),
  KEY `inst` (`inst`),
  KEY `i1` (`event_num`,`program_num`,`parameter_num`,`inst`,`date`,`time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `flask_data_view`
--

DROP TABLE IF EXISTS `flask_data_view`;
/*!50001 DROP VIEW IF EXISTS `flask_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `flask_data_view` (
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
  `prettyEvDate` tinyint NOT NULL,
  `prettyADate` tinyint NOT NULL,
  `a_creation_datetime` tinyint NOT NULL
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
  `comment` tinytext NOT NULL,
  PRIMARY KEY (`num`),
  KEY `i1` (`site_num`),
  KEY `i2` (`project_num`),
  KEY `i3` (`strategy_num`),
  KEY `i4` (`date`,`time`),
  KEY `dd` (`dd`)
) ENGINE=MyISAM AUTO_INCREMENT=21648 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  `prettyEvDate` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `id` tinyint NOT NULL,
  `flask_id` tinyint NOT NULL,
  `me` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `comment` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `hats_analysis_flags`
--

DROP TABLE IF EXISTS `hats_analysis_flags`;
/*!50001 DROP VIEW IF EXISTS `hats_analysis_flags`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `hats_analysis_flags` (
  `analysis_num` tinyint NOT NULL,
  `rejected` tinyint NOT NULL,
  `suspicious` tinyint NOT NULL,
  `internal_flags` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `hats_data_tags_view`
--

DROP TABLE IF EXISTS `hats_data_tags_view`;
/*!50001 DROP VIEW IF EXISTS `hats_data_tags_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `hats_data_tags_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `hats_event_tags_view`
--

DROP TABLE IF EXISTS `hats_event_tags_view`;
/*!50001 DROP VIEW IF EXISTS `hats_event_tags_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `hats_event_tags_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `data_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `tag_comment` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `hats_flask_limits`
--

DROP TABLE IF EXISTS `hats_flask_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hats_flask_limits` (
  `parameter_num` int(11) NOT NULL,
  `inst_num` int(11) NOT NULL,
  `pair_diff_pct` double DEFAULT NULL,
  `inj_diff_pct` double DEFAULT NULL,
  PRIMARY KEY (`parameter_num`,`inst_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `hats_flask_view`
--

DROP TABLE IF EXISTS `hats_flask_view`;
/*!50001 DROP VIEW IF EXISTS `hats_flask_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `hats_flask_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `sample_ID` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `formula` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `rejected` tinyint NOT NULL,
  `suspicious` tinyint NOT NULL,
  `background` tinyint NOT NULL,
  `PairID` tinyint NOT NULL,
  `flask_pair_num` tinyint NOT NULL
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
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=373836 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Daily averaged in-situ data';
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
  `date` date NOT NULL,
  `hour` tinyint(4) NOT NULL,
  `intake_ht` decimal(8,2) NOT NULL DEFAULT 0.00,
  `value` decimal(10,3) NOT NULL DEFAULT -999.999,
  `std_dev` decimal(8,3) NOT NULL DEFAULT -999.999,
  `unc` decimal(8,3) NOT NULL DEFAULT -999.999,
  `n` smallint(6) NOT NULL DEFAULT 0,
  `flag` varchar(4) DEFAULT '*..',
  `system` varchar(8) DEFAULT '',
  `inst_num` smallint(6) DEFAULT 0,
  PRIMARY KEY (`num`),
  UNIQUE KEY `i1` (`date`,`hour`,`site_num`,`parameter_num`,`inst_num`,`system`)
) ENGINE=InnoDB AUTO_INCREMENT=8031440 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Hourly averaged in-situ data';
/*!40101 SET character_set_client = @saved_cs_client */;

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
  UNIQUE KEY `i1` (`date`,`site_num`,`parameter_num`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13813 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Daily averaged in-situ data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_parameters`
--

DROP TABLE IF EXISTS `inst_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inst_parameters` (
  `inst_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  PRIMARY KEY (`inst_num`,`parameter_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interp_std_response`
--

DROP TABLE IF EXISTS `interp_std_response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interp_std_response` (
  `analysis_num` int(11) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `interp_area` decimal(12,4) DEFAULT NULL,
  `interp_height` decimal(12,4) DEFAULT NULL,
  `interp_response` double DEFAULT NULL,
  `interp_sens` double DEFAULT NULL,
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lab`
--

DROP TABLE IF EXISTS `lab`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lab` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `abbr` varchar(30) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mole_fractions`
--

DROP TABLE IF EXISTS `mole_fractions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mole_fractions` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `C_area` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `C_height` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `C_reported` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `last_modified` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'last_modified date can be used to retrieve standard assigned value as of date of processing.  See reftank.get_tank_assignment or associated table and view documentation',
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_analysis`
--

DROP TABLE IF EXISTS `ng_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_analysis` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `run_time` datetime NOT NULL DEFAULT '1900-01-01 00:00:00' COMMENT 'start of run for 1 or more flasks and calibration cylinders',
  `analysis_time` datetime NOT NULL DEFAULT '1900-01-01 00:00:00' COMMENT 'aliquot measurement time',
  `run_type_num` int(11) NOT NULL DEFAULT 0,
  `inst_num` int(11) NOT NULL DEFAULT 0 COMMENT 'fk to ng_inst',
  `port` int(11) NOT NULL DEFAULT 0 COMMENT 'Main ssv port number',
  `port_info` varchar(45) DEFAULT NULL,
  `pair_id_num` int(11) NOT NULL DEFAULT 0 COMMENT 'fk to status_metdata (sample event)',
  `flask_id` int(11) NOT NULL DEFAULT 0 COMMENT 'Maps to status metadata port_id',
  `flask_port` int(11) DEFAULT NULL COMMENT 'Flask ssv port number',
  `ccgg_event_num` int(11) NOT NULL DEFAULT 0 COMMENT 'FK to ccgg.flask_event',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`analysis_time`,`inst_num`,`pair_id_num`,`flask_id`,`ccgg_event_num`) COMMENT 'Logically time, inst should unique each row, but some data (Steve’s) has same atime for multiple flasks like pfp.  That probably should be a runtime and have actual atime, but not possible to get from historical data.  Using these 5 which uniques for either statusmetdata flasks or ccggevent flasks',
  KEY `r` (`inst_num`,`run_type_num`),
  KEY `e` (`pair_id_num`)
) ENGINE=InnoDB AUTO_INCREMENT=348878 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_ancillary_data`
--

DROP TABLE IF EXISTS `ng_ancillary_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_ancillary_data` (
  `analysis_num` int(11) NOT NULL,
  `init_p` decimal(8,3) DEFAULT NULL,
  `final_p` decimal(8,3) DEFAULT NULL,
  `net_pressure` decimal(8,3) DEFAULT NULL,
  `initp_rsd` decimal(12,6) DEFAULT NULL,
  `finalp_rsd` decimal(12,6) DEFAULT NULL,
  `low_flow` int(11) DEFAULT 0,
  `cryocount` int(11) DEFAULT 0,
  `loflocount` int(11) DEFAULT NULL,
  `last_flow` decimal(8,3) DEFAULT NULL,
  `last_vflow` decimal(8,3) DEFAULT NULL,
  `pfpopen` int(11) DEFAULT NULL,
  `pfpclose` int(11) DEFAULT NULL,
  `pfp_press1` decimal(8,3) DEFAULT NULL,
  `pfp_press2` decimal(8,3) DEFAULT NULL,
  `pfp_press3` decimal(8,3) DEFAULT NULL,
  PRIMARY KEY (`analysis_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_calibration_assignments`
--

DROP TABLE IF EXISTS `ng_calibration_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_calibration_assignments` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `tankid` varchar(45) NOT NULL,
  `parameter_num` int(11) NOT NULL COMMENT 'fk to gmd.parameter',
  `analysis_datetime` date NOT NULL,
  `mole_fraction` decimal(16,8) NOT NULL,
  `unc` decimal(12,4) DEFAULT NULL,
  `on_date` date DEFAULT NULL,
  `off_date` date DEFAULT NULL,
  PRIMARY KEY (`num`),
  KEY `i` (`tankid`,`parameter_num`,`on_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `ng_data_view`
--

DROP TABLE IF EXISTS `ng_data_view`;
/*!50001 DROP VIEW IF EXISTS `ng_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `ng_data_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `port` tinyint NOT NULL,
  `standards_num` tinyint NOT NULL,
  `run_type` tinyint NOT NULL,
  `run_type_num` tinyint NOT NULL,
  `port_info` tinyint NOT NULL,
  `flask_port` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `ccgg_event_num` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `channel` tinyint NOT NULL,
  `detrend_method` tinyint NOT NULL,
  `detrend_method_num` tinyint NOT NULL,
  `height` tinyint NOT NULL,
  `area` tinyint NOT NULL,
  `retention_time` tinyint NOT NULL,
  `mole_fraction` tinyint NOT NULL,
  `unc` tinyint NOT NULL,
  `qc_status` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `rejected` tinyint NOT NULL,
  `suspicious` tinyint NOT NULL,
  `Wind_Speed` tinyint NOT NULL,
  `Wind_Direction` tinyint NOT NULL,
  `Air_Temp` tinyint NOT NULL,
  `Dew_Point` tinyint NOT NULL,
  `Precipitation` tinyint NOT NULL,
  `Sky` tinyint NOT NULL,
  `Comments` tinyint NOT NULL,
  `CounterForInHouse` tinyint NOT NULL,
  `HCFC_MS` tinyint NOT NULL,
  `HFC_MS` tinyint NOT NULL,
  `LEAPS` tinyint NOT NULL,
  `Otto` tinyint NOT NULL,
  `run_time` tinyint NOT NULL,
  `PairID` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ng_detrend_methods`
--

DROP TABLE IF EXISTS `ng_detrend_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_detrend_methods` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(10) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_flags`
--

DROP TABLE IF EXISTS `ng_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_flags` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `flag` varchar(3) DEFAULT NULL,
  `description` varchar(45) NOT NULL,
  `reject` tinyint(1) NOT NULL DEFAULT 0,
  `selection` tinyint(1) NOT NULL DEFAULT 0,
  `comment` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_mole_fraction_tags`
--

DROP TABLE IF EXISTS `ng_mole_fraction_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_mole_fraction_tags` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `ng_mole_fraction_num` int(11) NOT NULL,
  `tag_num` int(11) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `u1` (`ng_mole_fraction_num`,`tag_num`),
  KEY `i1` (`tag_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ng_mole_fractions`
--

DROP TABLE IF EXISTS `ng_mole_fractions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_mole_fractions` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `analysis_num` int(11) NOT NULL COMMENT 'fk to ng_analysis',
  `parameter_num` int(11) NOT NULL COMMENT 'fk to gmd.parameter',
  `channel` char(2) NOT NULL DEFAULT '',
  `detrend_method_num` int(11) NOT NULL DEFAULT 3 COMMENT 'fk to ng_detrend_methods',
  `height` decimal(12,4) DEFAULT NULL,
  `area` decimal(14,4) DEFAULT NULL,
  `retention_time` decimal(12,4) DEFAULT NULL,
  `mole_fraction` decimal(16,8) DEFAULT NULL,
  `unc` decimal(12,4) DEFAULT NULL,
  `qc_status` char(1) DEFAULT 'P' COMMENT 'P for preliminary (default), R for rejected, ‘.’ for QC’d, no issue',
  `flag` char(3) NOT NULL DEFAULT '...' COMMENT 'Three character flag field',
  PRIMARY KEY (`num`),
  UNIQUE KEY `u` (`analysis_num`,`parameter_num`,`channel`)
) ENGINE=InnoDB AUTO_INCREMENT=45605820 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `ng_pair_avg_view`
--

DROP TABLE IF EXISTS `ng_pair_avg_view`;
/*!50001 DROP VIEW IF EXISTS `ng_pair_avg_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `ng_pair_avg_view` (
  `site` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `Wind_Speed` tinyint NOT NULL,
  `Wind_Direction` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `pair_avg` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `pair_stdv` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ng_run_types`
--

DROP TABLE IF EXISTS `ng_run_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ng_run_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(10) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `normal_response`
--

DROP TABLE IF EXISTS `normal_response`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `normal_response` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `interp_Resp` decimal(30,15) DEFAULT NULL,
  `norm_Resp` decimal(30,15) DEFAULT NULL,
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pr1_non_linearity`
--

DROP TABLE IF EXISTS `pr1_non_linearity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pr1_non_linearity` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `start_datetime` datetime NOT NULL,
  `analyte` varchar(45) NOT NULL,
  `parameter_num` int(11) NOT NULL,
  `inst_num` int(11) NOT NULL,
  `fit` varchar(45) NOT NULL,
  `on_off` varchar(45) NOT NULL,
  `apply` int(11) NOT NULL,
  `c1` decimal(20,15) DEFAULT NULL,
  `c2` decimal(20,15) DEFAULT NULL,
  `c3` decimal(20,15) DEFAULT NULL,
  `c4` decimal(20,15) DEFAULT NULL,
  `c5` decimal(20,15) DEFAULT NULL,
  `c6` decimal(20,15) DEFAULT NULL,
  `c7` decimal(20,15) DEFAULT NULL,
  `c8` decimal(20,15) DEFAULT NULL,
  `c9` decimal(20,15) DEFAULT NULL,
  `c10` decimal(20,15) DEFAULT NULL,
  `maxNL` decimal(20,15) DEFAULT NULL,
  `minNL` decimal(20,15) DEFAULT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `u1` (`inst_num`,`parameter_num`,`start_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=17062 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `primaries`
--

DROP TABLE IF EXISTS `primaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `primaries` (
  `num` int(5) unsigned NOT NULL AUTO_INCREMENT,
  `serial` tinytext NOT NULL DEFAULT '',
  `manufacturer` tinytext NOT NULL DEFAULT '',
  `type` tinytext NOT NULL DEFAULT '',
  `creator` tinytext NOT NULL DEFAULT '',
  `date_created` date NOT NULL DEFAULT '0000-00-00',
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procedure_status`
--

DROP TABLE IF EXISTS `procedure_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procedure_status` (
  `proc_name` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `current_i` int(11) DEFAULT NULL,
  `total_i` int(11) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `currtime` datetime DEFAULT NULL,
  `period_start_date` date DEFAULT NULL,
  `period_end_date` date DEFAULT NULL,
  PRIMARY KEY (`proc_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Table to record status updates for long running procedures';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `procedure_status_view`
--

DROP TABLE IF EXISTS `procedure_status_view`;
/*!50001 DROP VIEW IF EXISTS `procedure_status_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `procedure_status_view` (
  `proc_name` tinyint NOT NULL,
  `total_months` tinyint NOT NULL,
  `completed_months` tinyint NOT NULL,
  `current_month_being_processed` tinyint NOT NULL,
  `start_time` tinyint NOT NULL,
  `last_update_time` tinyint NOT NULL,
  `elapsed_seconds` tinyint NOT NULL,
  `percent_complete` tinyint NOT NULL,
  `estimated_completion_time` tinyint NOT NULL,
  `estimated_seconds_remaining` tinyint NOT NULL,
  `avg_seconds_per_month` tinyint NOT NULL,
  `period_start_date` tinyint NOT NULL,
  `period_end_date` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_corrected_response_view`
--

DROP TABLE IF EXISTS `prs_corrected_response_view`;
/*!50001 DROP VIEW IF EXISTS `prs_corrected_response_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_corrected_response_view` (
  `analysis_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `std_serial_num` tinyint NOT NULL,
  `dd` tinyint NOT NULL,
  `blank_corrected_response` tinyint NOT NULL,
  `pre_interp_std_response` tinyint NOT NULL,
  `post_interp_std_response` tinyint NOT NULL,
  `interpolated_std_response` tinyint NOT NULL,
  `corrected_pressure` tinyint NOT NULL,
  `nl_x` tinyint NOT NULL,
  `normalized_response` tinyint NOT NULL,
  `raw_sensitivity` tinyint NOT NULL,
  `interpolated_sensitivity` tinyint NOT NULL,
  `rl` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_data_view`
--

DROP TABLE IF EXISTS `prs_data_view`;
/*!50001 DROP VIEW IF EXISTS `prs_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_data_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `ccgg_event_num` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `project_num` tinyint NOT NULL,
  `program_num` tinyint NOT NULL,
  `strategy_num` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `port` tinyint NOT NULL,
  `standards_num` tinyint NOT NULL,
  `event_num` tinyint NOT NULL,
  `lab_num` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `Wind_Speed` tinyint NOT NULL,
  `Wind_Direction` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `rejected` tinyint NOT NULL,
  `rejected_other_than_auto_inj_diff` tinyint NOT NULL,
  `rejected_other_than_auto_pair_diff` tinyint NOT NULL,
  `suspicious` tinyint NOT NULL,
  `background` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `data_exclusion` tinyint NOT NULL,
  `interp` tinyint NOT NULL,
  `PairID` tinyint NOT NULL,
  `flask_pair_num` tinyint NOT NULL,
  `alt` tinyint NOT NULL,
  `elev` tinyint NOT NULL,
  `lat` tinyint NOT NULL,
  `lon` tinyint NOT NULL,
  `hats_flask_type` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_inj_data_view`
--

DROP TABLE IF EXISTS `prs_inj_data_view`;
/*!50001 DROP VIEW IF EXISTS `prs_inj_data_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_inj_data_view` (
  `site` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `pairID` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `flask_pair_num` tinyint NOT NULL,
  `inj_avg` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL,
  `inj_diff_pct_of_avg` tinyint NOT NULL,
  `inj_diff_pct_threshold` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_intermediate_calcs_response_view`
--

DROP TABLE IF EXISTS `prs_intermediate_calcs_response_view`;
/*!50001 DROP VIEW IF EXISTS `prs_intermediate_calcs_response_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_intermediate_calcs_response_view` (
  `pre_interp_std_response` tinyint NOT NULL,
  `post_interp_std_response` tinyint NOT NULL,
  `blank_corrected_response` tinyint NOT NULL,
  `interpolated_std_response` tinyint NOT NULL,
  `interpolated_std_sensitivity` tinyint NOT NULL,
  `x` tinyint NOT NULL,
  `corrected_pressure` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `std_serial_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `is_blank` tinyint NOT NULL,
  `is_std` tinyint NOT NULL,
  `use_area` tinyint NOT NULL,
  `raw_response` tinyint NOT NULL,
  `peak_area` tinyint NOT NULL,
  `peak_height` tinyint NOT NULL,
  `use_blank_correction` tinyint NOT NULL,
  `pre_blank_analysis_num` tinyint NOT NULL,
  `pre_blank_analysis_datetime` tinyint NOT NULL,
  `pre_blank_area` tinyint NOT NULL,
  `pre_blank_height` tinyint NOT NULL,
  `pre_blank_raw_response` tinyint NOT NULL,
  `post_blank_analysis_num` tinyint NOT NULL,
  `post_blank_analysis_datetime` tinyint NOT NULL,
  `post_blank_area` tinyint NOT NULL,
  `post_blank_height` tinyint NOT NULL,
  `post_blank_raw_response` tinyint NOT NULL,
  `pressure` tinyint NOT NULL,
  `temp` tinyint NOT NULL,
  `pre_standard_analysis_num` tinyint NOT NULL,
  `post_standard_analysis_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_mole_fraction_tag_view`
--

DROP TABLE IF EXISTS `prs_mole_fraction_tag_view`;
/*!50001 DROP VIEW IF EXISTS `prs_mole_fraction_tag_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_mole_fraction_tag_view` (
  `analysis_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `tag_num` tinyint NOT NULL,
  `display_name` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `reject` tinyint NOT NULL,
  `selection` tinyint NOT NULL,
  `information` tinyint NOT NULL,
  `automated` tinyint NOT NULL,
  `collection_issue` tinyint NOT NULL,
  `measurement_issue` tinyint NOT NULL,
  `selection_issue` tinyint NOT NULL,
  `hats_interpolation` tinyint NOT NULL,
  `pair_diff` tinyint NOT NULL,
  `inj_diff` tinyint NOT NULL,
  `prelim` tinyint NOT NULL,
  `comment` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_pair_avg_view`
--

DROP TABLE IF EXISTS `prs_pair_avg_view`;
/*!50001 DROP VIEW IF EXISTS `prs_pair_avg_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_pair_avg_view` (
  `site` tinyint NOT NULL,
  `site_num` tinyint NOT NULL,
  `sample_datetime` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `inst_id` tinyint NOT NULL,
  `pair_id_num` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `parameter` tinyint NOT NULL,
  `Wind_Speed` tinyint NOT NULL,
  `Wind_Direction` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `analysis_num` tinyint NOT NULL,
  `sample_id` tinyint NOT NULL,
  `pair_avg` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `pair_stdv` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `prs_raw_response_view`
--

DROP TABLE IF EXISTS `prs_raw_response_view`;
/*!50001 DROP VIEW IF EXISTS `prs_raw_response_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `prs_raw_response_view` (
  `analysis_num` tinyint NOT NULL,
  `analysis_datetime` tinyint NOT NULL,
  `parameter_num` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `std_serial_num` tinyint NOT NULL,
  `inst_num` tinyint NOT NULL,
  `is_blank` tinyint NOT NULL,
  `is_std` tinyint NOT NULL,
  `use_area` tinyint NOT NULL,
  `raw_response` tinyint NOT NULL,
  `peak_area` tinyint NOT NULL,
  `peak_height` tinyint NOT NULL,
  `use_blank_correction` tinyint NOT NULL,
  `pre_blank_analysis_num` tinyint NOT NULL,
  `pre_blank_analysis_datetime` tinyint NOT NULL,
  `pre_blank_area` tinyint NOT NULL,
  `pre_blank_height` tinyint NOT NULL,
  `pre_blank_raw_response` tinyint NOT NULL,
  `post_blank_analysis_num` tinyint NOT NULL,
  `post_blank_analysis_datetime` tinyint NOT NULL,
  `post_blank_area` tinyint NOT NULL,
  `post_blank_height` tinyint NOT NULL,
  `post_blank_raw_response` tinyint NOT NULL,
  `pressure` tinyint NOT NULL,
  `temp` tinyint NOT NULL,
  `pre_standard_analysis_num` tinyint NOT NULL,
  `post_standard_analysis_num` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `raw_data`
--

DROP TABLE IF EXISTS `raw_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `raw_data` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `peak_area` decimal(12,4) DEFAULT NULL,
  `peak_height` decimal(12,4) DEFAULT NULL,
  `peak_width` decimal(12,4) DEFAULT NULL,
  `peak_RT` decimal(12,4) DEFAULT NULL,
  `pre_blank_analysis_num` mediumint(8) DEFAULT NULL,
  `post_blank_analysis_num` mediumint(8) DEFAULT NULL,
  `pre_standard_analysis_num` mediumint(8) DEFAULT NULL,
  `post_standard_analysis_num` mediumint(8) DEFAULT NULL,
  `last_modified` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'pre post columns expected to change if associated columns are flagged, area and height should match raw data files',
  PRIMARY KEY (`analysis_num`,`parameter_num`),
  KEY `i1` (`pre_standard_analysis_num`),
  KEY `i2` (`post_standard_analysis_num`),
  KEY `i3` (`pre_blank_analysis_num`),
  KEY `i4` (`post_blank_analysis_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relative_ratio`
--

DROP TABLE IF EXISTS `relative_ratio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relative_ratio` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `RL_area` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `RL_height` decimal(12,4) NOT NULL DEFAULT -999.9900,
  `RL_reported` decimal(12,4) NOT NULL DEFAULT -999.9900,
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `run_types`
--

DROP TABLE IF EXISTS `run_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `run_types` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `inst_num` int(11) DEFAULT NULL,
  `run_type` varchar(45) DEFAULT NULL,
  `description` varchar(45) DEFAULT NULL,
  `data_qc` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_other`
--

DROP TABLE IF EXISTS `sample_other`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_other` (
  `num` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
) ENGINE=MyISAM AUTO_INCREMENT=143673 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
-- Table structure for table `scale_tank_usage`
--

DROP TABLE IF EXISTS `scale_tank_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scale_tank_usage` (
  `species` varchar(255) DEFAULT NULL,
  `parameter_num` int(11) DEFAULT NULL,
  `serial_num` varchar(255) DEFAULT NULL,
  `use_for_scale` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensitivity`
--

DROP TABLE IF EXISTS `sensitivity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensitivity` (
  `analysis_num` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `parameter_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `interp_Sens` decimal(30,15) NOT NULL DEFAULT -999.990000000000000,
  `raw_Sens` decimal(30,15) NOT NULL DEFAULT -999.990000000000000,
  PRIMARY KEY (`analysis_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `code` char(3) NOT NULL,
  `global_network` tinyint(1) DEFAULT NULL,
  `ftp` int(11) DEFAULT NULL,
  `agage` int(11) DEFAULT NULL,
  `global_avg` int(11) NOT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `standards`
--

DROP TABLE IF EXISTS `standards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `standards` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `std_ID` tinytext NOT NULL,
  `tank_type` tinytext NOT NULL,
  `description` tinytext DEFAULT NULL,
  `fill_date` datetime DEFAULT NULL,
  `fill_code` varchar(45) DEFAULT NULL,
  `serial_number` varchar(45) DEFAULT NULL,
  `level` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=60 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `standards_PR1`
--

DROP TABLE IF EXISTS `standards_PR1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `standards_PR1` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(45) NOT NULL,
  `fill_code` varchar(2) NOT NULL,
  `tank_type` varchar(45) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `start_datetime` datetime DEFAULT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `inst_num` int(11) DEFAULT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `num_UNIQUE` (`num`),
  UNIQUE KEY `start_datetime_UNIQUE` (`start_datetime`),
  UNIQUE KEY `end_datetime_UNIQUE` (`end_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `standards_factors`
--

DROP TABLE IF EXISTS `standards_factors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `standards_factors` (
  `num` int(11) NOT NULL DEFAULT 0,
  `Species` varchar(111) DEFAULT NULL,
  `tank_num` int(11) DEFAULT NULL,
  `Factor` float DEFAULT NULL,
  `inst_num` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `Comment` varchar(265) DEFAULT NULL,
  `Scale` varchar(50) DEFAULT NULL,
  `units` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `standards_r1`
--

DROP TABLE IF EXISTS `standards_r1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `standards_r1` (
  `std_ID` int(11) DEFAULT NULL,
  `param_num` int(11) DEFAULT NULL,
  `r1` float DEFAULT NULL,
  `sec_num` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `upload_dev`
--

DROP TABLE IF EXISTS `upload_dev`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `upload_dev` (
  `num` int(11) NOT NULL DEFAULT 0,
  `param` varchar(20) DEFAULT NULL,
  `value` float DEFAULT NULL,
  `flag` varchar(5) DEFAULT NULL,
  `inst_num` int(11) DEFAULT NULL,
  `analysis_num` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`analysis_num`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'hats'
--
/*!50003 DROP FUNCTION IF EXISTS `DEV_get_tank_assignment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `DEV_get_tank_assignment`(v_serial_number varchar(20),v_scale varchar(20),v_datetime datetime, v_as_of_datetime datetime) RETURNS float
begin
        	declare dd float;
            declare val float;
        
			set dd=tmp.f_dt2dec(v_datetime);
			set val=(select 
				case when tzero=0 then coef0 
					else coef0+(coef1*(dd-tzero))+(coef2*pow((dd-tzero),2))
				end
			from hats.scale_assignments_hats a join reftank.scales s on s.idx=a.scale_num
			where s.name=v_scale and a.serial_number=v_serial_number 
				and a.start_date<=v_datetime  and a.assign_date<=v_as_of_datetime
                and v_datetime<ifnull((select min(date) from reftank.fill where serial_number=a.serial_number and date>a.start_date),'9999-12-31')
			order by a.start_date desc, a.assign_date desc limit 1);

			return val;
		end ;;
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
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_flagType`(flag varchar(2) binary, table_name varchar(25)) RETURNS int(11)
    NO SQL
    DETERMINISTIC
BEGIN
    declare ret int;
    set ret=case 
		when (table_name='flags_system' and flag regexp '[A-Z]') 
			or (table_name='flags_sample' and flag regexp '[A-Z]') 
            or (table_name='flags_internal' and flag not like 'T' and flag not like 'S%' and flag not like '*' and (flag regexp '[A-Z]' or flag in ('%','~','$')))
		then 1
        when table_name='flags_internal' and flag in ('<','>') then 2
        when table_name='flags_internal' and (flag regexp '[a-z]' or flag in ('<','>')) then 3
        else 0
	end;
    return ret;
   END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `callProcForPeriod` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `callProcForPeriod`(v_procname varchar(255),v_start_datetime datetime,v_end_datetime datetime, v_parameter_num int, v_verbose int, v_inst_num int)
BEGIN
	/*Iterate from start - end one month at a time calling proc.
    If end minus start is < 1 month, it just calls for that range
    Writes status information to table procedure_status:
    ex: select * from procedure_status where proc_name='prs_set_analysis_brackets';
    start, end, param passed through to SP
    */
    
    DECLARE v_sdt, v_edt , v_current_date DATETIME;
    DECLARE v_start_time , v_end_time DATETIME;
    DECLARE v_total_months,v_i,v_total INT DEFAULT 0;

    -- Record the start time
    SET v_start_time = NOW();
    SET v_sdt = v_start_datetime;

	#Set status entry so can track progress
	set v_total=PERIOD_DIFF(DATE_FORMAT(v_end_datetime, '%Y%m'),DATE_FORMAT(v_start_datetime, '%Y%m'));#for status counter
    replace procedure_status (proc_name,status,current_i,total_i,start,end,currtime,period_start_date,period_end_date) select v_procname,"Starting",v_i,v_total,now(),'0000-00-00',now(),v_start_datetime,v_end_datetime;
		
    WHILE v_sdt < v_end_datetime DO
		set v_i=v_i+1;
        SET v_edt = DATE_ADD(v_sdt, INTERVAL 1 MONTH);
        if (v_edt>v_end_datetime) then #If caller passed less than a full month or for period not ending on full month, just run for passed dates
			set v_edt=v_end_datetime;
		end if;
		SET v_total_months = v_total_months + 1;
        #update status table
        update procedure_status set status=concat("Running SP from:",v_sdt," to:",v_edt),current_i=v_i,currtime=now() where proc_name=v_procname;
		#Call proc
        if(v_procname="prs_set_analysis_brackets" ) then 
			CALL prs_set_analysis_brackets(v_sdt, v_edt, v_parameter_num);
		elseif (v_procname="prs_calc_mole_fractions") then 
			call prs_calc_mole_fractions(v_sdt,v_edt , v_parameter_num, v_inst_num);
		elseif (v_procname="updateICP2") then
			set @parameter_num=-1,@site_num=-1,@sample_type='', @inst_num=58, @asd='1900-01-01',@aed='9999-12-31',@vex=0,@writeTmpTable=1;
			call prs_get_pair_avg_data(v_sdt,v_edt,@parameter_num,@site_num,@sample_type, @inst_num, @asd, @aed,@vex,@writeTmpTable);
			call icp.icp_updateHATSTestData(@v_mssg);
        
		#elseif (v_procname="prs_inj_pair_diff_flagging") then ###not needed, its very fast
		#	call prs_calc_mole_fractions(v_sdt,v_edt , v_parameter_num);
		end if;
               
        SET v_sdt = DATE_ADD(v_sdt, INTERVAL 1 MONTH);
    END WHILE;
    SET v_end_time = NOW();
    
    update procedure_status set status=concat("Completed"),current_i=v_i,currtime=now(),end=now() where proc_name=v_procname;
	
    if(v_verbose=1) then 
		SELECT TIMESTAMPDIFF(SECOND, v_start_time, v_end_time) AS TotalExecutionTimeSeconds,
			ROUND(TIMESTAMPDIFF(SECOND, v_start_time, v_end_time) / v_total_months, 2) AS AvgTimePerMonthSeconds,
			v_total_months AS TotalMonthsProcessed, p.* from procedure_status p where proc_name=v_procname;
	end if;
		
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `hats_syncCalibrationsData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `hats_syncCalibrationsData`(v_cylinder_id varchar(11))
begin
	/*This procedure will syncronize any relevant calibration measurements in the HATS db to the reftank.calibrations table.

    */

    drop temporary table if exists t__targets,t__data,t__data2,t__episodes;

    #Create temp table of target cylinders.  These are any cyl for target species (currently just ethane) that have been in a calrequest
    create temporary table t__targets (index i (cylinder_id))as
		SELECT cylinder_id, species,parameter_num
        FROM refgas_orders.rgm_calrequest_view v
        where (v_cylinder_id='all' or v.cylinder_id=v_cylinder_id collate latin1_general_ci) and calservice_num in(12);

    #Pull out the target data
    create temporary table t__data (index i(cylinder_id,analysis_datetime))as
    select a.analysis_datetime,
		t.species,
        t.cylinder_id,
        i.id as inst,
        m.C_reported as value,
		case when isnull(fi.iflag) and isnull(fs.sflag) then '.' else ifnull(fs.sflag,fi.iflag) end as flag
		, a.num as analysis_num,m.parameter_num#debug cols.
	from t__targets t join analysis a on t.cylinder_id =a.sample_id collate latin1_general_ci
		join mole_fractions m on a.num=m.analysis_num and  t.parameter_num=m.parameter_num
        join ccgg.inst_description i on i.num=a.inst_num
        left join flags_internal fi on a.num=fi.analysis_num and m.parameter_num=fi.parameter_num and char_length(fi.iflag)=1 #multi char flags are for ben's internal use.
        left join flags_system fs on a.num=fs.analysis_num and char_length(fs.sflag)=1
	where a.inst_num in (58)
    ;
	#Create a copy for next query to use (can only ref tmp tables once)
    create temporary table t__data2  (index i(cylinder_id,analysis_datetime)) as select * from t__data;

    #create a final work table with episode dates
    create temporary table t__episodes (index i(cylinder_id,analysis_datetime)) as
    select t1.cylinder_id,t1.analysis_datetime,t1.species,t1.inst,t1.value,t1.flag,
		(select min(t2.analysis_datetime) from t__data2 t2
			where t1.species=t2.species and t1.cylinder_id=t2.cylinder_id  and t1.inst=t2.inst and t1.species=t2.species
				and abs(timestampdiff(hour,t1.analysis_datetime,t2.analysis_datetime))<24) as start_dt
    from t__data t1;

    #write out final results
    select cylinder_id, start_dt as dt, upper(species), upper(inst), flag, avg(value) as value, stddev(value) as std_dev,count(value) as n
    from t__episodes where flag='.'
    group by cylinder_id, start_dt, species, inst, flag
    having count(*) > 0 order by start_dt;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PR1_standards_transfer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`hfcms`@`%.cmdl.noaa.gov` PROCEDURE `PR1_standards_transfer`()
BEGIN
    drop temporary table if exists tmp_stds, tmp_match, tmp_last;
    
    create temporary table tmp_stds as
		select s.num, s.std_ID, s.fill_date, f.serial_number, f.code, f.date,
        if(s.fill_date is null,'last','match') as selection
		from hats.standards s, reftank.fill f 
		WHERE RIGHT(s.std_ID,5) = RIGHT(f.serial_number,5);
        
	create temporary table tmp_match as
		select num, std_ID, fill_date, serial_number, code, date
			FROM tmp_stds
            where selection LIKE 'match';
            
	create temporary table tmp_last as
		select num, std_ID, fill_date, serial_number, code, date
			FROM tmp_stds
            where selection LIKE 'last';

    create temporary table tmp_last_single as
		select distinct(num), std_ID, fill_date, serial_number, code, date
			FROM tmp_last
            where date = max(date)
            GROUP BY num
            order by num;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_calc_mole_fractions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`hfcms`@`%.cmdl.noaa.gov` PROCEDURE `prs_calc_mole_fractions`(v_start_datetime datetime, v_end_datetime datetime, v_parameter_num int, v_inst_num int)
begin
/*Inserts/updates mole_fractions table C_reported column with corrected mole_fraction values of v_parameter_num or all if v_parameter_num passed -1.
v_end_datetime is exclusive
1/23/25 - added inst_num filter.
2/20/25 - integrated in code from Isaac to handle sample interpolation flags better.
*/
 
	drop temporary table if exists t_tanks,t_assigns,t_int,t_nl2,t_nl,t_int_s,t_std_flags,t_std_resp,t_sample,t_for_calc;
    
    #set all current rows to -999.99 in case we aren't able to update the mf (like if no scale assignment for std tank).
    #Logic below only sets mf if it can actually match the standard assignment, so this prevents any old data from 
    #sticking around if it shouldn't.
    update mole_fractions mf join analysis a on a.num=mf.analysis_num 
		set mf.C_reported=-999.99 
		where a.analysis_datetime>=v_start_datetime and a.analysis_datetime<v_end_datetime
			and (v_parameter_num=-1 or mf.parameter_num=v_parameter_num)
            and a.inst_num=v_inst_num;
    
    #Create some work tables
    
    #grab all the standards in range
    create temporary table t_tanks as select distinct std_serial_num from analysis 
    where analysis_datetime between v_start_datetime and v_end_datetime and inst_num=v_inst_num;
    
    #pull assignment info for faster calc. Note end_date from scale_assignments_view is inclusive so we'll do date math for exclusive end date to make join easier below
    #Note; if inst_num is added to scale_assignments, we'll want to filter on that here.
    create temporary table t_assigns (index i(parameter_num, serial_number,start_date,end_date))
    as select s.*,case when end_date<'9999-12-31' then date_add(end_date, interval 1 day) else end_date end as exc_end_date 
		from scale_assignments_view s join t_tanks t on t.std_serial_num=s.serial_number 
			where (v_parameter_num=-1 or s.parameter_num=v_parameter_num)
				and s.current_assignment=1 and s.current_scale=1
                #uncoment if inst_num ever added... and s.inst_num=v_inst_num
			;
                
	#Create a non linearity table with end dates
    create temporary table t_nl (index i (inst_num, parameter_num, start_datetime,end_datetime)) as 
		select t.*,
		ifnull((select min(start_datetime) 
		from pr1_non_linearity
		where inst_num=t.inst_num and parameter_num=t.parameter_num and start_datetime>t.start_datetime),'9999-12-31') as end_datetime 
    from pr1_non_linearity t
    where (v_parameter_num=-1 or t.parameter_num=v_parameter_num)
		and inst_num=v_inst_num;
    
    #Create an fixed table of intermediate calc values.  This is just to flatten the view for performance
    create temporary table t_int (index i(parameter_num,analysis_datetime), index i2(parameter_num,std_serial_num)) as 
    select cr.analysis_num, cr.parameter_num, cr.blank_corrected_response,
    cr.corrected_pressure,cr.interpolated_std_response, cr.sample_type,
		cr.x,cr.analysis_datetime,tmp.f_dt2dec(cr.analysis_datetime) as dd,cr.std_serial_num,cr.interpolated_std_sensitivity
	from prs_intermediate_calcs_response_view cr 
	where cr.analysis_datetime>=v_start_datetime and cr.analysis_datetime<v_end_datetime
			#and cr.sample_type!='blank'
			and (v_parameter_num=-1 or cr.parameter_num=v_parameter_num)
            and cr.inst_num=v_inst_num;
    alter table t_int add column (corrected_rl decimal(20,15), raw_Sens decimal(30,15));

    /* Now create a series of tables to update t_int in cases where there are samples that have interpolation tags.  These samples
		have their normalized response and normalized sensitivity calculated using the fixed response of the standard immediately 
        following the samples */
        
    create temporary table t_int_s as 
		SELECT a.analysis_datetime, a.num, a.sample_type, fi.parameter_num, fi.tag_num, tv.flag, rd.post_standard_analysis_num 
			FROM flags_internal fi 
			JOIN analysis a ON a.num = fi.analysis_num 
			JOIN ccgg.tag_view tv ON tv.tag_num = fi.tag_num 
            JOIN raw_data rd on rd.analysis_num = fi.analysis_num and rd.parameter_num = fi.parameter_num
			WHERE a.analysis_datetime BETWEEN v_start_datetime AND v_end_datetime 
			AND a.sample_type NOT IN ("std") 
			AND a.inst_num = v_inst_num
			AND (v_parameter_num = -1 or fi.parameter_num = v_parameter_num)
			AND tv.hats_interpolation = 1;
	/* temporary table to get the flags for those standards*/	
            create temporary table t_std_flags as
				select fi.analysis_num, fi.parameter_num, fi.iflag, fi.tag_num 
					from flags_internal fi
                    join t_int_s t on t.post_standard_analysis_num = fi.analysis_num and t.parameter_num = fi.parameter_num
                    join ccgg.tag_view tv on tv.tag_num = fi.tag_num
                    where tv.hats_interpolation = 1;
        /* add columns to the table to get more information that we need 
        and then update the table from the other temp table*/            
            alter table t_int_s add column (std_tag_num int, std_flag varchar(5), 
						interp_std_response decimal(30,15),interp_std_sens decimal(30,15),
                        std_a_dt datetime, norm_response decimal(30,15));
		
			update t_int_s t left join t_std_flags ts on ts.analysis_num = t.post_standard_analysis_num 
									and ts.parameter_num = t.parameter_num 
				set t.std_tag_num = ts.tag_num, t.std_flag = ts.iflag,
                t.std_a_dt = (select analysis_datetime from analysis where num = t.post_standard_analysis_num);
                
       /* Now get the samples between the sample with the interpolation tag and the standard, 
			so we can get mole fractions for those as well. */       
			create temporary table t_sample as
				select a.analysis_datetime, a.num, a.sample_type, rd.parameter_num, rd.post_standard_analysis_num
                from analysis a 
                join raw_data rd on rd.analysis_num = a.num 
                join t_int_s t on t.parameter_num = rd.parameter_num
                where a.analysis_datetime > t.analysis_datetime
                and a.analysis_datetime < t.std_a_dt
                and (v_parameter_num = -1 or rd.parameter_num = v_parameter_num)
                and a.sample_type != "std";
                
			alter table t_sample add column (interp_std_response decimal(30,15),interp_std_sens decimal(30,15),
				std_a_dt datetime, norm_response decimal(30,15));
                
            update t_sample set std_a_dt = (select analysis_datetime from analysis where num = post_standard_analysis_num);
          /* combine these two so we can get the sensitivity and response so we can do the calculations later */  
			insert into t_int_s (analysis_datetime,num,sample_type,parameter_num,post_standard_analysis_num,std_a_dt) 
                  select analysis_datetime,num,sample_type,
                  parameter_num,post_standard_analysis_num,std_a_dt
                  from t_sample;
      /* Get the standard responses for those tables*/
      
            create temporary table t_std_resp as
				select ts.num, ts.parameter_num, ir.interp_response, ir.interp_sens
                from interp_std_response ir
                join t_int_s ts on ts.post_standard_analysis_num = ir.analysis_num and ts.parameter_num = ir.parameter_num;
                
			update t_int_s t left join t_std_resp ts on ts.num = t.num and ts.parameter_num= t.parameter_num
				set t.interp_std_response = ts.interp_response,
					t.interp_std_sens = ts.interp_sens;
 # Calculate the new responses for t_int                   
	create temporary table t_for_calc as
		select ts.analysis_datetime,ts.num,ts.sample_type,ts.parameter_num,
				ts.norm_response as x,ts.post_standard_analysis_num,
                ts.interp_std_response,ts.interp_std_sens, t.blank_corrected_response,t.corrected_pressure
			from t_int_s ts
            join t_int t on t.analysis_num = ts.num and t.parameter_num = ts.parameter_num;
            
        update t_for_calc 
			set x = (blank_corrected_response / interp_std_response);
            
		/* Now update t_int with the x (normalized response) values for these specific analysis_nums and parameter_nums */
        
        update t_int t
			join t_for_calc tc on tc.num = t.analysis_num and tc.parameter_num = t.parameter_num 
            set t.x = tc.x, t.interpolated_std_response = tc.interp_std_response, 
					t.interpolated_std_sensitivity = tc.interp_std_sens;
    /* End of calculating values for samples with interpolation tags */
    
    #There was a major performance hit doing a left join to pr1_non_linearity directly or t_nl using date range join.  Creating
    #this derived table of matches with direct key lookup for join below is much faster.
    create temporary table t_nl2 (index i(analysis_num,parameter_num))as 
		select cr.analysis_num, nl.*
        from t_int cr join t_nl nl 
			on cr.analysis_datetime>=nl.start_datetime and cr.analysis_datetime<nl.end_datetime and nl.parameter_num=cr.parameter_num;
    
    #Do the NL corrections to get final response values.  Note if these are wanted for analysis, we should add a column to raw_data or mole_fractions to store it,
    #probably mole_fractions so we can set it in the replace statement below.
    update t_int set raw_Sens = blank_corrected_response/corrected_pressure;
    update t_int set corrected_rl = ((blank_corrected_response/corrected_pressure)/interpolated_std_sensitivity );
    
    update t_int cr left join t_nl2 nl on cr.analysis_num=nl.analysis_num and cr.parameter_num=nl.parameter_num
    set corrected_rl=
    #Non linearity corrected RL:  RL / nl correction
    ((blank_corrected_response/corrected_pressure)/interpolated_std_sensitivity )

    /
    case when ifnull(apply,0)=0 then 1 #Defaults to no op.
    else 
		CASE fit
			WHEN 'fit_expo_2' THEN
				case when c2 * x > 709 then 1
					when c4 * x > 709 then 1
                else
				c1 * EXP(c2 * x) + c3 * EXP(c4 * x)
                end
			WHEN 'fit_expo_2_LAR' THEN
            case when c2 * x > 709 then 1
					when c4 * x > 709 then 1
                else
				c1 * EXP(c2 * x) + c3 * EXP(c4 * x)
                end
			WHEN 'fit_expo_2b' THEN
            case when c2 * x > 709 then 1
					when c4 * x > 709 then 1
                else
				c1 * EXP(c2 * x) + c3 * EXP(c4 * x)
                end
			WHEN 'fit_expo_LAR' THEN
            case when c2 * x > 709 then 1
                else
				c1 * EXP(c2 * x)
                end
			WHEN 'fit_poly_1' THEN
				c1 * x + c2
			WHEN 'fit_poly_2' THEN
				c1 * POW(x, 2) + c2 * x + c3
			WHEN 'fit_poly_2_LAR' THEN
				c1 * POW(x, 2) + c2 * x + c3
			WHEN 'fit_power_2' THEN
				case 
					when  x <= 0 then 1		# Needed because Mariadb cannot handle zero or negative numbers for values x in x^c2
                else
					c1 * POW(x, c2) + c3
				end
			WHEN 'fit_rational_1_1' THEN
				(c1 * x + c2) / (x + c3)
			WHEN 'fit_rational_1_2' THEN
				(c1 * x + c2) / (POW(x, 2) + c3 * x + c4)
			WHEN 'fit_rational_1_3' THEN
				(c1 * x + c2) / (POW(x, 3) + c3 * POW(x, 2) + c4 * x + c5)
			WHEN 'fit_rational_2_1' THEN
				(c1 * POW(x, 2) + c2 * x + c3) / (x + c4)
			WHEN 'fit_rational_2_2_LAR' THEN
				(c1 * POW(x, 2) + c2 * x + c3) / (POW(x, 2) + c4 * x + c5)
			WHEN 'fit_rational_2_2_non' THEN
				(c1 * POW(x, 2) + c2 * x + c3) / (POW(x, 2) + c4 * x + c5)
			WHEN 'fit_rational_2_2' THEN
				(c1 * POW(x, 2) + c2 * x + c3) / (POW(x, 2) + c4 * x + c5)
			WHEN 'fit_rational_2_3' THEN
				(c1 * POW(x, 2) + c2 * x + c3) / (POW(x, 3) + c4 * POW(x, 2) + c5 * x + c6)
			WHEN 'fit_rational_3_1' THEN
				(c1 * POW(x, 3) + c2 * POW(x, 2) + c3 * x + c4) / (x + c5)
			WHEN 'fit_rational_3_2' THEN
				(c1 * POW(x, 3) + c2 * POW(x, 2) + c3 * x + c4) / (POW(x, 2) + c5 * x + c6)
			WHEN 'fit_rational_3_2B' THEN
				(c1 * POW(x, 3) + c2 * POW(x, 2) + c3 * x + c4) / (POW(x, 2) + c5 * x + c6)
			WHEN 'fit_rational_3_2_center' THEN
				(c1 * POW(x, 3) + c2 * POW(x, 2) + c3 * x + c4) / (POW(x, 2) + c5 * x + c6)
			WHEN 'fit_rational_3_3' THEN
				(c1 * POW(x, 3) + c2 * POW(x, 2) + c3 * x + c4) / (POW(x, 3) + c5 * POW(x, 2) + c6 * x + c7)
			WHEN 'fit_rational_4_1' THEN
				(c1 * POW(x, 4) + c2 * POW(x, 3) + c3 * POW(x, 2) + c4 * x + c5) / (x + c6)
			else 0 #If function provided but not defined, error out the calculation to let caller know it needs to be added.
		END 
	end 
		where cr.sample_type not in ("blank","std","cal","burn","test");
    
    #Insert/replace mole_fractions with updated values.
    replace mole_fractions (analysis_num, parameter_num, C_reported)
	select cr.analysis_num, cr.parameter_num, 
		case when cr.corrected_rl is null or cr.corrected_rl=-999.999 then -999.999
			when 
				tzero=0 then cr.corrected_rl * coef0 
			else 
				cr.corrected_rl * (coef0+(coef1*(dd-tzero))+(coef2*pow((dd-tzero),2)))
			end
    from t_int cr join t_assigns a on a.parameter_num=cr.parameter_num
			and cr.std_serial_num=a.serial_number and  cr.analysis_datetime >= a.start_date and cr.analysis_datetime<a.exc_end_date
        
	;
    #Insert/replace normal_response with updated values.
		replace normal_response (analysis_num, parameter_num, interp_Resp, norm_Resp)
			select cr.analysis_num, cr.parameter_num, cr.interpolated_std_response, cr.x
            from t_int cr;
            
	#Insert/replace relative_ratio with updated values.
		replace relative_ratio (analysis_num, parameter_num, RL_reported)
			select cr.analysis_num, cr.parameter_num, cr.corrected_rl
            from t_int cr;
    
    #Insert/replace sensitivity with updated values.
		replace sensitivity (analysis_num, parameter_num, interp_Sens, raw_Sens)
			select cr.analysis_num, cr.parameter_num, cr.interpolated_std_sensitivity, cr.raw_Sens
            from t_int cr;
          
    
	#This worked better than other attempts to break it down, but is ~2x slower than above.  Note, requires NL logic in prs_corrected_response_view to be re-enabled
    /*replace mole_fractions (analysis_num, parameter_num, C_reported)
	select cr.analysis_num, cr.parameter_num, 
		case when cr.corrected_rl is null or cr.corrected_rl=-999.999 then -999.999
			when 
				tzero=0 then cr.corrected_rl * coef0 
			else 
				cr.corrected_rl * (coef0+(coef1*(dd-tzero))+(coef2*pow((dd-tzero),2)))
			end
    from prs_corrected_response_view cr join t_assigns a on a.parameter_num=cr.parameter_num
		and cr.std_serial_num=a.serial_number and  cr.analysis_datetime >= a.start_date and cr.analysis_datetime<a.exc_end_date
		#and a.current_assignment=1 #most recent edit of assignment wins
        
    where cr.analysis_datetime between v_start_datetime and v_end_datetime
			and (v_parameter_num=-1 or cr.parameter_num=v_parameter_num)
            and cr.sample_type!='blank'
	;
	*/
    
    #Update pair and injection diff flagging
    call prs_inj_pair_diff_flagging(v_start_datetime,v_end_datetime,v_parameter_num,1);

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_fetch_blank_corrected_standards` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`hfcms`@`%.cmdl.noaa.gov` PROCEDURE `prs_fetch_blank_corrected_standards`(v_start_datetime datetime, v_end_datetime datetime, v_parameter_num int, v_quick_mode int,v_inst_num int)
begin
	/*Get blank corrected standards for data in date range so can calculate interpolated values.  Pass v_parameter_num -1 to do all parameters
    Also returns interpolation tags in range.  If first standard doesn't have an interpolation tag, 
    we find most recent interpolation tag ( up to -6 weeks before v_start_datetime) and
    return all standards from there using that tag with the first standard (even if tag was applied to a sample).
    
    if v_quick_mode=1 then we update the raw_data pre/post blank/std brackets (next std, next blank, pre std, pre blank)
    for any blanks/stds that have been flagged, basically to skip them.  
    
    if v_quick_mode=0 then we remap all blank/stds in the range to catch any that may have been unflagged and now can be used
    and any that the daily processing may have missed for whatever reason.  This adds ~30seconds per month for all params.  This does a full
    reset of all the blank/std mapping.
    
    v_quick_mode should be passed 0 prior to any releases.
    */
    
    declare vadj_start,vadj_end,vbst datetime default null;
    set vadj_start = date_add(v_start_datetime, interval -6 week),vadj_end= date_add(v_end_datetime, interval 6 week);#Max window to look for interpolation tags
    
    drop temporary table if exists t_data, t_prior_int,t_post_int,t_starts,t_tags;#work tables
    
    #Update pre/post blank info for any new rows in the date range.  
    if (v_quick_mode=1) then 
		call prs_update_flagged_brackets(vadj_start,vadj_end,v_parameter_num,v_inst_num);
    else 
		#Call wrapper function that breaks calls up into 1 month chunks.  This is so you can monitor progress in table procedure_status (select * from procedure_status where proc_name='prs_set_analysis_brackets';)
        call callProcForPeriod('prs_set_analysis_brackets',vadj_start,vadj_end,v_parameter_num,0,v_inst_num);
	end if;
    
    #Create temp tables of all & prior & post interp tag dates so we can figure out start dates for each param and
    #get the next tag after our end date so we know what data we need to extend to.
    #We pull all tags in window because we'll join to it repeatedly.  
    #Also note, this is tags for any sample not just stds and blanks.  This is so we can apply an intep tag to first standard if needed.
    #NOTE; assumes that measurements aren't tagged with an interp tag and a reject tag!
    create temporary table t_tags (index i(analysis_num,parameter_num,analysis_datetime),index i2(parameter_num, analysis_datetime)) as
    select a.num as analysis_num, fi.parameter_num, td.flag, a.analysis_datetime, td.reject, td.hats_interpolation
    from analysis a join flags_internal fi on a.num=fi.analysis_num 
		join ccgg.tag_dictionary td on fi.tag_num=td.num 
	where td.hats_interpolation=1 
		and a.analysis_datetime<vadj_end
		and a.analysis_datetime>=vadj_start 
        and (v_parameter_num=-1 or fi.parameter_num=v_parameter_num)
        and a.inst_num=v_inst_num;
        
    #table of most recent tagged analysis rows prior to start so we can carry in if needed
    create temporary table t_prior_int (index i(parameter_num,analysis_datetime)) as
    select parameter_num, max(analysis_datetime) as analysis_datetime
    from t_tags
	where hats_interpolation=1 and analysis_datetime<=v_start_datetime
    group by parameter_num;
    
    #same for post
    create temporary table t_post_int (index i(parameter_num,analysis_datetime)) as
    select parameter_num, min(analysis_datetime) as analysis_datetime
    from t_tags
	where hats_interpolation=1 and analysis_datetime>=v_end_datetime
    group by parameter_num;
    
    
    #Find first and last to help with below query
   # select min(analysis_datetime) into vadj_start from t_prior_int;
   # select max(analysis_datetime) into vadj_end from t_prior_int;
    
    #Fill temp table with target data.  This includes data from first interp tag <= to start through end,
    #Note; we join to t_prior_int to figure out how much data prior to start to fetch
	create temporary table t_data (index i(analysis_num,parameter_num)) as 
    select a.analysis_num, a.parameter_num, a.analysis_datetime, a.sample_type, a.raw_response,a.blank_corrected_response,a.is_std,a.corrected_pressure
    from prs_intermediate_calcs_response_view a left join t_prior_int pi on a.parameter_num=pi.parameter_num
		left join t_post_int po on a.parameter_num=po.parameter_num
	where a.analysis_datetime<vadj_end and a.analysis_datetime>vadj_start #options for the query planner 
		and a.analysis_datetime>=ifnull(pi.analysis_datetime,v_start_datetime) #all rows from most recent interp tag(of anyrow) prior to or equal to start for parameter
		and a.analysis_datetime<ifnull(po.analysis_datetime,v_end_datetime) #all rows strictly less than the most recent interp tag >= end for parameter
		and(v_parameter_num=-1 or a.parameter_num=v_parameter_num)
        and a.inst_num=v_inst_num
        and a.raw_response>0
		and a.is_std=1;

    
    #Fetch & set interpolation tags. We do separate because left join slowed the query a lot.
	alter table t_data add column interpolation_tag varchar(5) default '';
    update t_data t join t_tags s on t.analysis_num=s.analysis_num and t.parameter_num=s.parameter_num
    set t.interpolation_tag=s.flag where s.hats_interpolation=1;
    
    
    #remove all rejected standards
    delete t from t_data t join flags_internal fi on t.analysis_num=fi.analysis_num and t.parameter_num=fi.parameter_num 
		join ccgg.tag_dictionary td on td.num=fi.tag_num
    where td.reject=1;
    
    #Temp table of all starting standards (first occurance) so we can figure out which to apply prior tag to if it wasn't from a standard
    create temporary table t_starts (index i(parameter_num,analysis_datetime)) as 
		select parameter_num, min(analysis_datetime) as analysis_datetime 
        from t_data 
        where is_std=1 
        group by parameter_num;
        
	#Add prior interpolation tags when needed
	update t_data d join t_starts s on d.parameter_num=s.parameter_num and d.analysis_datetime=s.analysis_datetime #update the first rows of each param
    set d.interpolation_tag=
		(select flag from t_tags t
		where t.parameter_num=d.parameter_num and t.hats_interpolation=1 
			and t.analysis_datetime<=s.analysis_datetime order by t.analysis_datetime desc limit 1)#We don't really expect there to be more than 1 due to above selection logic
	where d.interpolation_tag is null and d.is_std=1;
    
    #Select out target data for caller (matlab) to use as a result set.
    select analysis_num, parameter_num, analysis_datetime, sample_type, raw_response, blank_corrected_response as corrected_response,interpolation_tag,corrected_pressure
    from t_data t ORDER BY parameter_num, analysis_datetime;
    
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_fetch_plot_data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_fetch_plot_data`(v_start_datetime datetime, v_end_datetime datetime, v_datetype varchar(10), v_parameter_num int, v_sample_type tinytext, v_inst_num int)
begin
	/*Retrieve data for prs plotting routines.  We do this in a sp to optimize joins, particularly for getting tags which can be slow
    v_sample_type is one of valid analysis.sample_type values or 'All sample types'
    */
    
	#create base temp table with info we'll eventually want to retrieve
	drop temporary table if exists t_;
	create temporary table t_ (index i (analysis_num, parameter_num),index i2(ccgg_event_num,sample_type) )as 
	select *
	from prs_data_view
	where parameter_num=v_parameter_num 
		and (sample_type=v_sample_type or v_sample_type='All sample types')
        and inst_num=v_inst_num
        and ((v_datetype='analysis' and analysis_datetime between v_start_datetime and v_end_datetime)
			or (v_datetype='sample' and sample_datetime is not null and sample_datetime between v_start_datetime and v_end_datetime))
		;
	#add a varchar col for tags
	alter table t_ add column tags varchar(255) default '' collate latin1_bin;#same collation as tag dict

	#add tag info
    #update from each source separately to simplify the query opitimization.  Trim leading commas introduced by concat_ws on ''. 
	/*deprecated
    update t_ d set d.tags=TRIM(BOTH ',' FROM concat_ws(',',d.tags,(select group_concat(t.flag) 
			from flags_system flag join ccgg.tag_dictionary t on t.num=flag.tag_num 
			where flag.analysis_num=d.analysis_num )))
		where d.rejected=1 or d.suspicious=1 or interp=1;*/
	update t_ d set d.tags=TRIM(BOTH ',' FROM concat_ws(',',d.tags,(select group_concat(t.flag) 
			from flags_internal flag join ccgg.tag_dictionary t on t.num=flag.tag_num 
			where flag.analysis_num=d.analysis_num and flag.parameter_num=d.parameter_num)))
		where d.rejected=1 or d.suspicious=1 or interp=1;
	update t_ d set d.tags=TRIM(BOTH ',' FROM concat_ws(',',d.tags,(select group_concat(t.flag) 
			from ccgg.flask_event_tag_view t 
			where d.ccgg_event_num=t.event_num and d.sample_type in('PFP','CCGG') )))
		where d.rejected=1 or d.suspicious=1 or interp=1;
	update t_ d set d.tags=TRIM(BOTH ',' FROM concat_ws(',',d.tags,(select group_concat(dtv.flag)  
			from ccgg.flask_data_tag_view dtv join ccgg.flask_data fd on fd.num=dtv.data_num 
			where fd.event_num=d.ccgg_event_num and fd.parameter_num=d.parameter_num
					and d.sample_type in('PFP','CCGG') and dtv.data_source not in (11,12))))
		where d.rejected=1 or d.suspicious=1 or interp=1;



    select d.*, rr.RL_area, rr.RL_height, rr.RL_reported,rd.peak_area, rd.peak_height, rd.peak_width, rd.peak_RT,
	s.interp_Sens, s.raw_Sens, 
		(select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=8) as Manifold_Ppsia_evac,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=9) as Manifold_Ppsia_final,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=10) as Manifold_Ppsia_initial,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=26) as Sample_pressure_net,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=27) as Sample_pressure_initial,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=28) as Sample_pressure_final,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=29) as T1_trapping_temp,
        (select value from ancillary_data where analysis_num=d.analysis_num and ancillary_num=30) as Manifold_Ppsia_postflush
	from t_ d 
		join relative_ratio rr on d.analysis_num=rr.analysis_num and d.parameter_num=rr.parameter_num
		join raw_data rd on d.analysis_num=rd.analysis_num and d.parameter_num=rd.parameter_num
		join sensitivity s on d.analysis_num=s.analysis_num and d.parameter_num=s.parameter_num
		;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_get_pair_avg_data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_get_pair_avg_data`(v_start_datetime datetime, v_end_datetime datetime, v_parameter_num int, v_site_num int, v_sample_type varchar(45), v_inst_num int, v_a_start_datetime datetime, v_a_end_datetime datetime,v_return_excluded int,v_writeTmpTable int)
begin
	/*SP to optimize fetch of pair avg data.  We do this as a procedure to minimize complexity of views/query plan.  This
    does a select of output at the end, so is similar to doing query directly. 
    v_start_datetime/v_end_datetime are sample dates, can be 1900-01-01 and 1999-12-31
    v_a_start_datetime/v_a_end_datetime are analysis dates, can be 1900-01-01 and 1999-12-31
    v_parameter_num, v_site_num, v_inst_num can specify specific item or -1 for all
    v_sample_type can be pfp, ccgg, hats, flask or '' for all
    v_return_excluded =1 to include or 0 to filter out exclusion data
    v_writeTmpTable writes output to tmp table t_data instead of returning in result set.
    
	#Note from view defs that I keep referring to so am keeping here
    #  There are 2:
		#prs_pair_data_view returns all non rejected measurments with pair average, diff and n for use in flagging procedure
		#(superceded by this proc)prs_pair_avg_view summarizes and returns pair average values for external use.
    */
    #select v_start_datetime, v_end_datetime, v_parameter_num, v_site_num, v_sample_type, v_inst_num, v_a_start_datetime , v_a_end_datetime ;
    drop temporary table if exists t_prs_data_view, t_data;
    create temporary table t_prs_data_view as 
    select * from prs_data_view 
    where analysis_datetime>=v_a_start_datetime and analysis_datetime<v_a_end_datetime
		and sample_datetime>=v_start_datetime and sample_datetime<v_end_datetime
        and (parameter_num=v_parameter_num or v_parameter_num=-1)
        and (site_num=v_site_num or v_site_num=-1)
        and (sample_type=v_sample_type or v_sample_type='')
        and (inst_num=v_inst_num or v_inst_num=-1)
        and sample_type in('PFP','CCGG', 'HATS', 'FLASK')
        and rejected=0 #exclude all rejected, including auto pair diff rejections.
		and (data_exclusion=0 or @v_return_excluded=1)
		and event_num!=0 #pairid or ccgg_event_num
	;
	
	#Do groupings and select out to caller
    if(v_writeTmpTable)then
		create temporary table t_data as 
		select d.site,d.site_num, d.sample_datetime, d.sample_type, d.inst_num, d.inst_id,pair_id_num, d.parameter_num, d.parameter, #We don't include ccgg event_num so it will group by same dated samples
			d.Wind_Speed, d.Wind_Direction,
			min(d.analysis_datetime) as analysis_datetime,group_concat(d.analysis_num order by analysis_num separator '|') as analysis_num ,group_concat(d.sample_id order by sample_id separator '|') as sample_id,
			avg(d.value)  as pair_avg,
			count(d.value) as n,
			stddev(d.value) as pair_stdv
		from t_prs_data_view d 
		group by d.site,d.site_num, d.sample_datetime, d.sample_type, d.inst_num, d.inst_id,pair_id_num, d.parameter_num, d.parameter,d.Wind_Speed, d.Wind_Direction
		;
	else
		select d.site,d.site_num, d.sample_datetime, d.sample_type, d.inst_num, d.inst_id,pair_id_num, d.parameter_num, d.parameter, #We don't include ccgg event_num so it will group by same dated samples
			d.Wind_Speed, d.Wind_Direction,
			min(d.analysis_datetime) as analysis_datetime,group_concat(d.analysis_num order by analysis_num separator '|') as analysis_num ,group_concat(d.sample_id order by sample_id separator '|') as sample_id,
			avg(d.value)  as pair_avg,
			count(d.value) as n,
			stddev(d.value) as pair_stdv
		from t_prs_data_view d 
		group by d.site,d.site_num, d.sample_datetime, d.sample_type, d.inst_num, d.inst_id,pair_id_num, d.parameter_num, d.parameter,d.Wind_Speed, d.Wind_Direction
		;
	end if;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_inj_pair_diff_flagging` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_inj_pair_diff_flagging`(aStartDate datetime, aEndDate datetime, v_parameter_num int, v_update int)
BEGIN
	/*
		Procedure to flag injection differences and pair differences in HATS PR1 Data (hats flasks only).
        This removes flags if no longer appropriate.  We use hats.hats_flask_limits to get species/instrument specific limits for inj and pairs
        Pass v_parameter_num=-1 to do all parameters
        Pass v_update =0 to see all that will be done and to get data to set limits, 1 sets/removes tags
        jwm - last updated 2024-11-21
    */
	declare num_rows int;
    declare v_mssg,v_injFlag,v_pairFlag varchar(255);
    declare v_sDate, v_eDate date;
    
    declare v_injTagNum, v_pairTagNum int default 0;
    set v_mssg='', 
		v_injTagNum=(select max(num) from ccgg.tag_view where inj_diff=1 and automated=1),
        v_pairTagNum=(select max(num) from ccgg.tag_view where pair_diff=1 and automated=1);
    
    drop temporary table if exists t_iDiff_remove, t_pDiff_remove, t_iDiff_add, t_pDiff_add, t_injgrp,t_pairgrp, t_prs_inj_data_view, t_prs_pair_data_view, t_prs_data_view;
	
    #stage data in work tables to help the optimizer
    create temporary table t_prs_data_view as 
    select * from prs_data_view where analysis_datetime>=aStartDate and analysis_datetime<=aEndDate and PairID is not null and PairID!=0;
    alter table t_prs_data_view add index i1(pairID, sample_id,inst_num,parameter_num);
    alter table t_prs_data_view add index i2(pairID, inst_num,parameter_num);
    
    create temporary table t_prs_inj_data_view as
    select d.pairID, d.sample_id,d.inst_num,d.parameter_num,
		avg(d.value) as inj_avg, count(d.value) as n, abs(max(d.value) - min(d.value)) as inj_diff,
        (abs(max(d.value)- min(d.value) )/avg(d.value) )*100 as inj_diff_pct_of_avg,
        ip.inj_diff_pct as inj_diff_pct_threshold
	from t_prs_data_view d left join hats.hats_flask_limits ip on d.inst_num=ip.inst_num and d.parameter_num=ip.parameter_num
    where rejected_other_than_auto_inj_diff=0 #Only exclude if there was a rejection other than inj_diff or if inj_diff manually applied.  We want to leave auto inj_diff rejections so we can do stats on all valid data and reprocess.
		and d.value>0#We aren't sure if this is right way to handle.  These should ideally be flagged, although 0 is not a necessarily bad result for some species
    group by d.pairID, d.sample_id,d.inst_num,d.parameter_num,ip.inj_diff_pct;
    
    
	create temporary table t_prs_pair_data_view as 
	select d.pairID,d.inst_num,d.parameter_num,#d.site, d.sample_datetime, d.analysis_datetime, d.sample_type, d.inst_num, d.inst_id,pairID, d.sample_id, d.analysis_num, d.parameter_num, d.parameter ,d.value,d.flask_pair_num,
		avg(d.value)  as pair_avg,
		count(d.value) as n,
		#(select avg(value) from t_prs_data_view where pairID=d.pairID and inst_num=d.inst_num and flask_pair_num=1 and parameter_num=d.parameter_num and rejected=0) as sample1_avg,
		#(select avg(value) from t_prs_data_view where pairID=d.pairID and inst_num=d.inst_num and flask_pair_num=2 and parameter_num=d.parameter_num and rejected=0) as sample2_avg,
		abs((select avg(value) from t_prs_data_view where pairID=d.pairID and inst_num=d.inst_num and flask_pair_num=1 and parameter_num=d.parameter_num and rejected=0)-
		(select avg(value) from t_prs_data_view where pairID=d.pairID and inst_num=d.inst_num and flask_pair_num=2 and parameter_num=d.parameter_num and rejected=0)) as pair_diff,
		ip.pair_diff_pct as pair_diff_pct_threshold
		#d.rejected #This will allow filtering by caller, so can optionally in/exclude auto rejected items depending on whether used for stats/flagging or output.  
	from t_prs_data_view d left join hats.hats_flask_limits ip on d.inst_num=ip.inst_num and d.parameter_num=ip.parameter_num
	where PairID is not null #Limit to hats flask program that specifies PairID
		and value>0
		and d.rejected_other_than_auto_pair_diff=0#hard filter anything explicitly flagged for something else.
	group by d.pairID,d.inst_num,d.parameter_num,ip.pair_diff_pct
	;
	alter table t_prs_inj_data_view add index i1(pairID, sample_id, parameter_num, inst_num);
    alter table t_prs_pair_data_view add index i1(pairID, parameter_num, inst_num);
    
	# Injection Differences
	
    #Create temp table of data that is currently flagged, but shouldn't be, for removal of flags later
	create temporary table t_iDiff_remove as
		select distinct d.analysis_num, d.parameter_num
		from t_prs_inj_data_view i join t_prs_data_view d 
				on i.pairID=d.pairID and i.sample_id=d.sample_id and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			join flags_internal fi on d.analysis_num=fi.analysis_num and d.parameter_num=fi.parameter_num
		where i.inst_num=58 
			and abs(i.inj_diff_pct_of_avg) < i.inj_diff_pct_threshold 
			and fi.tag_num=v_injTagNum #currently tagged with auto tag 
        ;
    
    
	# Now table of data where there is currently NOT a flag, but the values are above the cut off threshold
	create temporary table t_iDiff_add as
		select distinct d.analysis_num, d.parameter_num
        from t_prs_inj_data_view i join t_prs_data_view d 
				on i.pairID=d.pairID and i.sample_id=d.sample_id and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			left join flags_internal fi on d.analysis_num=fi.analysis_num and d.parameter_num=fi.parameter_num and fi.tag_num=v_injTagNum #add tagnum to left join so we can invert to find when missing
		where i.inst_num=58 
			and abs(i.inj_diff_pct_of_avg) >= i.inj_diff_pct_threshold 
			and fi.analysis_num is null #not currently tagged with auto tag 
           ;
	
    # Pair Differences
	#Create temp table of data that is currently flagged, but shouldn't be, for removal of flags later
	create temporary table t_pDiff_remove as 
    	select distinct d.analysis_num, d.parameter_num
		from t_prs_pair_data_view i join t_prs_data_view d 
				on i.pairID=d.pairID and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			join flags_internal fi on d.analysis_num=fi.analysis_num and d.parameter_num=fi.parameter_num
		where i.inst_num=58 
			and (i.pair_diff/i.pair_avg)*100 < i.pair_diff_pct_threshold 
			and fi.tag_num=v_pairTagNum #currently tagged with auto tag 
		;
		
	  
    # Now table of data where there is currently NOT a flag, but the values are above the cut off threshold
	create temporary table t_pDiff_add as 
		select distinct d.analysis_num, d.parameter_num
		from t_prs_pair_data_view i join t_prs_data_view d 
				on i.pairID=d.pairID and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			left join flags_internal fi on d.analysis_num=fi.analysis_num and d.parameter_num=fi.parameter_num and fi.tag_num=v_pairTagNum #add tagnum to left join so we can invert to find when missing
		where i.inst_num=58 
			and (i.pair_diff/i.pair_avg)*100 >= i.pair_diff_pct_threshold 
			and fi.analysis_num is null #not currently tagged with auto tag 
		;
          
	alter table t_iDiff_add add index i(analysis_num,parameter_num);
	alter table t_iDiff_remove add index i(analysis_num,parameter_num);
	alter table t_pDiff_remove add index i(analysis_num,parameter_num);
	alter table t_pDiff_add add index i(analysis_num,parameter_num);
      
	if(v_update=0 ) then 
		select (select count(*) from t_iDiff_remove) as inj_diff_tags_to_remove,
		 (select count(*) from t_pDiff_remove) as pair_diff_tags_to_remove,
		 (select count(*) from t_iDiff_add) as inj_diff_tags_to_add,
		(select count(*) from t_pDiff_add) as pair_diff_tags_to_add;
        
        select 'add inj diff tag' as action,d.value,i.*,d.* from 
			t_prs_inj_data_view i join t_prs_data_view d 
				on i.pairID=d.pairID and i.sample_id=d.sample_id and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			join t_iDiff_add t on t.analysis_num=d.analysis_num and t.parameter_num=d.parameter_num ;
		select 'remove inj diff tag' as action,d.value,i.*,d.* from 
			t_prs_inj_data_view i join t_prs_data_view d on i.pairID=d.pairID and i.sample_id=d.sample_id and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
			join t_iDiff_remove t on t.analysis_num=d.analysis_num and t.parameter_num=d.parameter_num;
		select 'remove pair diff tag' as action,d.value,i.*,d.* from 
			t_prs_pair_data_view i join t_prs_data_view d on i.pairID=d.pairID and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
				join t_pDiff_remove t on t.analysis_num=d.analysis_num and t.parameter_num=d.parameter_num;
		select 'add pair diff tag' as action,d.value,i.*,d.* from 
			t_prs_pair_data_view i join t_prs_data_view d on i.pairID=d.pairID and i.parameter_num=d.parameter_num and i.inst_num=d.inst_num
				join t_pDiff_add t on t.analysis_num=d.analysis_num and t.parameter_num=d.parameter_num;
				
				
	else
		#delete unneeded flags
		delete fi.* from flags_internal fi join t_iDiff_remove r on fi.analysis_num=r.analysis_num and fi.parameter_num=r.parameter_num where fi.tag_num=v_injTagNum;
		delete fi.* from flags_internal fi join t_pDiff_remove r on fi.analysis_num=r.analysis_num and fi.parameter_num=r.parameter_num where fi.tag_num=v_pairTagNum;
		#insert new ones
		insert into flags_internal (analysis_num, parameter_num, tag_num, comment) 
			select analysis_num, parameter_num, v_injTagNum, "Automated injection difference filter" from t_iDiff_add 
            on duplicate key update tag_num = v_injTagNum, comment = "Automated injection difference filter";#shouldn't need on dup key update (because of left join filter above), but this prevents error if one somehow got in
		insert flags_internal (analysis_num, parameter_num, tag_num, comment) 
			select analysis_num, parameter_num, v_pairTagNum, "Automated pair difference filter" from t_pDiff_add
            on duplicate key update tag_num = v_pairTagNum, comment = "Automated pair difference filter";
	
		/*select (select count(*) from t_iDiff_remove) as inj_diff_tags_removed,
		 (select count(*) from t_pDiff_remove) as pair_diff_tags_removed,
		 (select count(*) from t_iDiff_add) as inj_diff_tags_added,
		(select count(*) from t_pDiff_add) as pair_diff_tags_added;*/
	end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_plot_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_plot_details`(v_parameter_num int, v_inst_num int, v_sdate datetime, v_edate datetime, v_sample_type varchar(10), v_date_type varchar(10))
begin
	/*This gathers and summerizes all tag information for selected rows.
    
    Procedure creates 2 temporary tables; t_tags & t_tag_summary.
    t_tags has all tags/columns similar to prs_mole_fraction_tag_view
    t_tag_summary_no_ex has analysis_num, parameter_num & a concat'd list rej_tags, sel_tags, inf_tags
		excluding exclusion tags (convienence table)
    
    Parameters:
	v_parameter_num - gmd.parameter.formula (same as hats.prs_data_view.parameter)
    v_inst_num - ccgg.inst_description.num
    v_sdate - either sample start date or analysis start date depending on v_date_type
    v_edate - either sample end date or analysis end date depending on v_date_type
    v_sample_type - 'all' or hats.analysis.sample_type
    v_date_type - 'sample' for v_sdate and v_edate to be sample dates, 'analysis' to have them be analysis dates
    
    We do this in procedure because union was slow for prs_mole_fraction_tag_view on large sets.
    Example:
    call hats.prs_tag_details(6, 58, '2024-06-01 00:00', '2024-08-17 15:00', 'HATS','sample');
    
    This returns a result set with 1 row per analysis,parameter_num with all the details for plots.
    */
	drop temporary table if exists t_tags,t_tag_summary_no_ex,t_data, t_ancil_data;
    
    #target data table
    create temporary table t_data as 
		SELECT pv.analysis_num, pv.parameter_num 
		FROM hats.prs_data_view pv 
		WHERE pv.inst_num = v_inst_num 
		   AND pv.parameter_num = v_parameter_num
           AND (v_sample_type='all' or pv.sample_type like v_sample_type)
		   AND ((v_date_type='analysis' and date(analysis_datetime) BETWEEN v_sdate AND v_edate)
				or (v_date_type='sample' and date(sample_datetime) BETWEEN v_sdate AND v_edate))
		;
           
	create temporary table  t_tags (index i(analysis_num, parameter_num)) as 
    #Tags from flags_internal 
	select f.analysis_num, f.parameter_num, f.tag_num, t.display_name, t.flag, t.reject,t.selection,t.information, t.automated, 
		t.collection_issue,t.measurement_issue, t.selection_issue, t.hats_interpolation, t.pair_diff, t.inj_diff,t.prelim_data as prelim,f.comment, t.exclusion
	from t_data t_ join hats.flags_internal f  on t_.analysis_num=f.analysis_num and t_.parameter_num=f.parameter_num
		join ccgg.tag_view t on f.tag_num=t.num 
	union 
	#Tags from flags_system (might be deprecated)
	select f.analysis_num, t_.parameter_num, f.tag_num, t.display_name, t.flag, t.reject,t.selection,t.information, t.automated, 
		t.collection_issue,t.measurement_issue, t.selection_issue, t.hats_interpolation, t.pair_diff, t.inj_diff,t.prelim_data as prelim,f.comment,  t.exclusion
	from t_data t_ join hats.flags_system f on t_.analysis_num=f.analysis_num
		join ccgg.tag_view t on f.tag_num=t.num 
    union 
	#Event tags from ccgg pfps/flasks
	select a.num as analysis_num, t_.parameter_num, t.tag_num, t.display_name, t.flag, t.reject,t.selection,t.information, t.automated, 
		t.collection_issue,t.measurement_issue, t.selection_issue, t.hats_interpolation, t.pair_diff, t.inj_diff,t.prelim_data as prelim,t.tag_comment as comment,  t.exclusion
	from t_data t_ join hats.analysis a on t_.analysis_num=a.num 
		join ccgg.flask_event_tag_view t on a.event_num=t.event_num
	where  a.sample_type in('PFP','CCGG')
	union 
	#CCGG data tags
	select a.num as analysis_num, m.parameter_num, t.tag_num, t.display_name, t.flag, t.reject,t.selection,t.information, t.automated, 
		t.collection_issue,t.measurement_issue, t.selection_issue, t.hats_interpolation, t.pair_diff, t.inj_diff,t.prelim_data as prelim,t.tag_comment as comment,  t.exclusion
	from t_data t_ join hats.analysis a on t_.analysis_num=a.num 
		join hats.mole_fractions m on a.num=m.analysis_num and m.parameter_num=t_.parameter_num
		join ccgg.flask_data d on d.event_num=a.event_num and d.parameter_num=m.parameter_num
		join ccgg.flask_data_tag_view t on d.num=t.data_num
	where  a.sample_type in('PFP','CCGG')
    
    ;
	#summary table
	create temporary table t_tag_summary_no_ex (index i(analysis_num, parameter_num)) as 
    select analysis_num,parameter_num, 
		group_concat(case when reject=1 then concat(flag,"(",tag_num,")") else null end) as rej_tags,
        group_concat(case when selection=1 then concat(flag,"(",tag_num,")") else null end) as sel_tags,
        group_concat(case when information=1 then concat(flag,"(",tag_num,")") else null end) as inf_tags,
        sum(prelim) as prelim, 
        group_concat(case when hats_interpolation=1 then concat(flag,'(',tag_num,')') else null end) as int_tags
	from t_tags where exclusion=0 group by analysis_num,parameter_num;
    
    #aggregate ancilliary data (1 each per analysis (not all))
    create temporary table t_ancil_data (index i(analysis_num)) as
		select t_.analysis_num,
			(select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=9 limit 1) as 'Manifold_Ppsia_final',
            (select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=10 limit 1) as 'Manifold_Ppsia_initial',
            (select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=26 limit 1) as 'Sample_pressure_net',
            (select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=27 limit 1) as 'Sample_pressure_initial',
            (select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=28 limit 1) as 'Sample_pressure_final',
            (select value from ancillary_data where analysis_num=t_.analysis_num and ancillary_num=29 limit 1) as 'T1_trapping_temp'
		from t_data t_;
        
    #Output all data
	select d.analysis_num, d.analysis_datetime, d.parameter_num,  d.sample_type, ts.rej_tags,ts.sel_tags,ts.inf_tags, d.data_exclusion,ifnull(ts.prelim,0) as prelim, ts.int_tags,
		s.raw_Sens, d.value, d.value as C_reported, #legacy plotting code
        ta.Manifold_Ppsia_final,ta.Manifold_Ppsia_initial,ta.Sample_pressure_net,ta.Sample_pressure_initial, ta.Sample_pressure_final, ta.T1_trapping_temp,
        rd.peak_area, rd.peak_height, rd.peak_width, rd.peak_RT, rr.RL_area, rr.RL_height, rr.RL_reported
	from t_data t_ 
		join prs_data_view d on t_.analysis_num=d.analysis_num and t_.parameter_num=d.parameter_num
		left join hats.sensitivity s ON t_.analysis_num = s.analysis_num AND t_.parameter_num = s.parameter_num
		left join hats.raw_data rd on t_.analysis_num=rd.analysis_num and t_.parameter_num=rd.parameter_num
        left join relative_ratio rr on t_.analysis_num=rr.analysis_num and t_.parameter_num=rr.parameter_num
        left join t_ancil_data ta on ta.analysis_num=t_.analysis_num
		
	#Left join t_tag_summary_no_ex to include all rows in prs_data_view and matching data from summary table
		left join t_tag_summary_no_ex ts on ts.analysis_num=t_.analysis_num and ts.parameter_num=t_.parameter_num;
    
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_set_analysis_brackets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_set_analysis_brackets`(v_start_datetime datetime, v_end_datetime datetime, v_parameter_num int)
begin
	/*Find bracketing blanks and standards for analysis rows in date range to optimize use in processing analysis data
    we find closest non rejected for each parameter.
    Pass v_parameter_num=-1 to process all parameters.
    Note this info isn't expected to change unless a blank or standard gets flagged rejected.
    Note; this runs on all blanks & stds but filters by inst_num below when calc'ing pre/next
    */
    declare vst, vend datetime;
    declare n int default 0;
    declare vblank_window int default 48;#hours pre/post to look for unflagged blank.  This is
    #set relatively small to optimize performance and because we don't actually want to use one too far outside of the window.
    declare vstd_window int default 3; #Same, tighter window
    
    set vst=date_add(v_start_datetime, interval -1*vblank_window hour), vend=date_add(v_end_datetime, interval vblank_window hour);#First/last entries in range will need to look back for matches. 
	
    #Reset some work tables
    drop temporary table if exists t_blanks, t_stds, t_a,t_rd,t_rd2;
    
    #Fetch blanks and stds
    create temporary table t_a (index i(analysis_num,parameter_num)) as
    select a.num as analysis_num, a.analysis_datetime, rd.parameter_num, a.sample_type, a.inst_num
    from analysis a join raw_data rd on a.num=rd.analysis_num 
		where a.analysis_datetime between vst and vend
        and (v_parameter_num=-1 or rd.parameter_num=v_parameter_num)
        and sample_type in ('blank', 'std');
	
    #remove rejected.  Separate step is faster than a left join above.
    delete t from t_a t join flags_internal fi on t.analysis_num=fi.analysis_num and t.parameter_num=fi.parameter_num
		join ccgg.tag_dictionary td on fi.tag_num=td.num 
        where td.reject=1;
			
	
    #blanks with 'next' unflagged row for param,inst.  We'll use this to find bracketing blanks for analsyis rows.
    #This is mostly for performance, a subquery would be clearer, but this allows us to use lead windowing to grab the next one for all rows very quick.
    #Note; we partition by inst to handle when new systems come online and data is merged together.
    create temporary table t_blanks (index i(inst_num, pre_parameter_num,pre_dt,post_dt)) as 
    select b.analysis_num as pre_analysis_num, b.parameter_num as pre_parameter_num, b.inst_num, b.analysis_datetime as pre_dt,
		ifnull(lead(b.analysis_datetime) over (partition by b.inst_num,b.parameter_num,sample_type order by b.analysis_datetime),'9999-12-31') as post_dt,
		lead(b.analysis_num) over (partition by b.inst_num, b.parameter_num,sample_type order by b.analysis_datetime) as post_analysis_num
    from t_a b where b.sample_type='blank';
    
	#stds with next unflagged row for param, inst
    create temporary table t_stds (index i(inst_num, pre_parameter_num,pre_dt,post_dt)) as 
    select b.analysis_num as pre_analysis_num, b.parameter_num as pre_parameter_num, b.inst_num, b.analysis_datetime as pre_dt,
		ifnull(lead(b.analysis_datetime) over (partition by b.inst_num,b.parameter_num,sample_type order by b.analysis_datetime),'9999-12-31') as post_dt,
		lead(b.analysis_num) over (partition by b.inst_num, b.parameter_num,sample_type order by b.analysis_datetime) as post_analysis_num
    from t_a b where b.sample_type='std';
   
    #Update primary table with matching pre/post blanks 
    
    #We stage into another tmp table to make the update quicker.  It was extremely slow doing this join and update in same query (10x)
    create temporary table t_rd (index i(analysis_num, parameter_num)) as
    select ab.analysis_num, ab.parameter_num, b.pre_analysis_num, b.post_analysis_num    
    from raw_data ab join analysis a on ab.analysis_num=a.num
		join t_blanks b on a.inst_num=b.inst_num and ab.parameter_num=b.pre_parameter_num 
			and a.analysis_datetime>b.pre_dt and a.analysis_datetime<b.post_dt
	where a.analysis_datetime between v_start_datetime and v_end_datetime 
		and a.sample_type!='blank'
		and (v_parameter_num=-1 or ab.parameter_num=v_parameter_num)
        ;
	update raw_data ab join t_rd b on ab.analysis_num=b.analysis_num and ab.parameter_num=b.parameter_num
	set ab.pre_blank_analysis_num=b.pre_analysis_num, ab.post_blank_analysis_num=b.post_analysis_num;
	set n=row_count();
    
    #Now the standards
    create temporary table t_rd2 (index i(analysis_num, parameter_num)) as
    select ab.analysis_num, ab.parameter_num,s.pre_analysis_num, s.post_analysis_num
    from raw_data ab join analysis a on ab.analysis_num=a.num
		join t_stds s on a.inst_num=s.inst_num and ab.parameter_num=s.pre_parameter_num
			and a.analysis_datetime>s.pre_dt and a.analysis_datetime<s.post_dt
	where a.analysis_datetime between v_start_datetime and v_end_datetime
		and a.sample_type!='std'
		and (v_parameter_num=-1 or ab.parameter_num=v_parameter_num)
        ;
	update raw_data ab join t_rd2 s on ab.analysis_num=s.analysis_num and ab.parameter_num=s.parameter_num
	set ab.pre_standard_analysis_num=s.pre_analysis_num, ab.post_standard_analysis_num=s.post_analysis_num;
    #select * from t_rd2;
	/*Previous attempt.  This actually runs fairly fast as a standalone query, but very slow in SP.  
		update raw_data ab join analysis a on ab.analysis_num=a.num
		join t_blanks b on a.inst_num=b.inst_num and ab.parameter_num=b.pre_parameter_num 
			and a.analysis_datetime>b.pre_dt and a.analysis_datetime<b.post_dt
        set ab.pre_blank_analysis_num=b.pre_analysis_num, ab.post_blank_analysis_num=b.post_analysis_num
	where a.analysis_datetime between v_start_datetime and v_end_datetime 
		and (v_parameter_num=-1 or ab.parameter_num=v_parameter_num)#This isn't really needed due to join with t_blanks but may help with indexing
        ;
	update raw_data ab join analysis a on ab.analysis_num=a.num
		join t_stds s on a.inst_num=s.inst_num and ab.parameter_num=s.pre_parameter_num
			and a.analysis_datetime>s.pre_dt and a.analysis_datetime<s.post_dt
        set ab.pre_standard_analysis_num=s.pre_analysis_num, ab.post_standard_analysis_num=s.post_analysis_num
	where a.analysis_datetime between v_start_datetime and v_end_datetime
		and (v_parameter_num=-1 or ab.parameter_num=v_parameter_num)#This isn't really needed due to join with t_blanks but may help with indexing
		;  */
	#drop temporary table if exists t_blanks, t_stds, t_a,t_rd,t_rd2;
    #select row_count() as stds_updated, n as blanks_updated;#Return something so matlab caller knows it is complete. 
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_set_analysis_parameter_brackets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_set_analysis_parameter_brackets`(v_analysis_num int,v_parameter_num int)
begin
	/*Added inst_num filter 1/23/25.*/
	declare vst,vend datetime;
    declare vblank_window int default 48;#hours pre/post to look for unflagged blank.  This is
    #set relatively small to optimize performance and because we don't actually want to use one too far outside of the window.
    declare vstd_window int default 3; #Same, tighter window
    
	update raw_data rd join analysis a on a.num=rd.analysis_num
        set rd.pre_blank_analysis_num=(
			select a2.num 
			from analysis a2 left join (flags_internal fi join ccgg.tag_dictionary td on fi.tag_num=td.num and td.reject=1)
					on fi.analysis_num=a2.num and fi.parameter_num=rd.parameter_num
						and a2.inst_num=a.inst_num
            where a2.sample_type='blank' 
				and a2.analysis_datetime<a.analysis_datetime
                and a2.analysis_datetime> date_add(a.analysis_datetime,interval -1*vblank_window hour)
				and fi.tag_num is null
			order by a2.analysis_datetime desc limit 1
			),
		rd.post_blank_analysis_num=(
			select a3.num 
			from analysis a3 left join (flags_internal fi join ccgg.tag_dictionary td on fi.tag_num=td.num and td.reject=1)
					on fi.analysis_num=a3.num and fi.parameter_num=rd.parameter_num
						and a3.inst_num=a.inst_num
            where a3.sample_type='blank' and a3.analysis_datetime>a.analysis_datetime 
				and a3.analysis_datetime< date_add(a.analysis_datetime,interval vblank_window hour)
				and fi.tag_num is null
			order by a3.analysis_datetime asc limit 1
			),
		rd.pre_standard_analysis_num=(
			select a2.num 
			from analysis a2 left join (flags_internal fi join ccgg.tag_dictionary td on fi.tag_num=td.num and td.reject=1)
					on fi.analysis_num=a2.num and fi.parameter_num=rd.parameter_num
						and a2.inst_num=a.inst_num
            where a2.sample_type='std' 
				and a2.analysis_datetime<a.analysis_datetime
                and a2.analysis_datetime> date_add(a.analysis_datetime,interval -1*vstd_window hour)
				and fi.tag_num is null
			order by a2.analysis_datetime desc limit 1
			),
		rd.post_standard_analysis_num=(
			select a3.num #skip rejected post standards.
			from analysis a3 left join (flags_internal fi join ccgg.tag_dictionary td on fi.tag_num=td.num and (td.reject=1 ))
					on fi.analysis_num=a3.num and fi.parameter_num=rd.parameter_num
						and a3.inst_num=a.inst_num
				
            where a3.sample_type='std' and a3.analysis_datetime>a.analysis_datetime 
				and a3.analysis_datetime< date_add(a.analysis_datetime,interval vstd_window hour)
				and fi.tag_num is null
			order by a3.analysis_datetime asc limit 1
			)
	where rd.analysis_num=v_analysis_num and rd.parameter_num=v_parameter_num
    ;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prs_update_flagged_brackets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `prs_update_flagged_brackets`(v_start_datetime datetime, v_end_datetime datetime, v_parameter_num int, v_inst_num int)
begin
	/*Update brackets for associated raw_data rows that	used a flagged std or blank and now should not.
    This is expected to be relatively few so we do a targeted approach for faster processing. 
    NOTE; this does not handle stds/blanks that were flagged, associated with raw_data and then unflagged!!
    Caller (prs_fetch_blank_corrected_standards()) handles that with a full reset prior to releases.
	*/
    declare done int default false;
    declare vanalysis_num, vparameter_num int;
	declare vadj_start,vadj_end datetime default null;
    declare vblank_window int default 48;#hours pre/post to look for unflagged blank.  This is
    #set relatively small to optimize performance and because we don't actually want to use one too far outside of the window.

	declare cur cursor for select distinct analysis_num, parameter_num from t_targets;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	set vadj_start=date_add(v_start_datetime, interval -1*vblank_window hour), vadj_end=date_add(v_end_datetime, interval vblank_window hour);#First/last entries in range will need to look back for matches. 
	
    drop temporary table if exists t_targets,t_fi;
    
    
    #Find all flagged stds and blanks in date range.  We do this in temp table to help optimizer
	create temporary table t_fi as 
		select fi.analysis_num, fi.parameter_num
		from analysis a join flags_internal fi on fi.analysis_num=a.num
			join ccgg.tag_dictionary td on fi.tag_num=td.num
			where td.reject=1 and a.sample_type in ('blank','std')
				and (fi.parameter_num=v_parameter_num or v_parameter_num=-1)
                and a.inst_num=v_inst_num
				and a.analysis_datetime>=vadj_start and a.analysis_datetime<vadj_end ;
	alter table t_fi add index i(analysis_num, parameter_num);
						
    #Find all analysis/parameters that are flagged and used in a bracket.  We'll do separate queries so can use indexes on raw_data
    create temporary table t_targets as #(index i(analysis_num, parameter_num)) as
		select rd.analysis_num, rd.parameter_num #Selecting the raw_data row that is using flagged  blank or std
		from raw_data rd join t_fi fi
				on rd.pre_blank_analysis_num=fi.analysis_num and rd.parameter_num=fi.parameter_num #rd has pre blank that is flagged, same param
		;
	#repeat for other 3 brackets. 
    insert t_targets(analysis_num, parameter_num) 
		select rd.analysis_num, rd.parameter_num 
		from raw_data rd join t_fi fi
				on rd.post_blank_analysis_num=fi.analysis_num and rd.parameter_num=fi.parameter_num #rd has post_blank_analysis_num that is flagged, same param
		;
	insert t_targets(analysis_num, parameter_num) 
		select rd.analysis_num, rd.parameter_num 
		from raw_data rd join t_fi fi
				on rd.pre_standard_analysis_num=fi.analysis_num and rd.parameter_num=fi.parameter_num #rd has pre_standard_analysis_num that is flagged, same param
		;
	insert t_targets(analysis_num, parameter_num) 
		select rd.analysis_num, rd.parameter_num 
		from raw_data rd join t_fi fi
				on rd.post_standard_analysis_num=fi.analysis_num and rd.parameter_num=fi.parameter_num #rd has post_standard_analysis_num that is flagged, same param
		;
	#select * from t_targets;
    #Loop through and update affected rows
    open cur;
		read_loop: LOOP
			fetch cur into vanalysis_num,vparameter_num ;
			if done then LEAVE read_loop; end if;
     		call prs_set_analysis_parameter_brackets(vanalysis_num,vparameter_num);

		END LOOP;
	close cur;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `Status_MetData_view`
--

/*!50001 DROP TABLE IF EXISTS `Status_MetData_view`*/;
/*!50001 DROP VIEW IF EXISTS `Status_MetData_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Status_MetData_view` AS select cast(`m`.`sample_datetime_utc` as date) AS `Normal_Sample_Date`,cast(`m`.`sample_datetime_utc` as time) AS `GMT`,`m`.`Station` AS `Station`,`m`.`Flask_1` AS `Flask_1`,`m`.`Pressure_1` AS `Pressure_1`,`m`.`Flask_2` AS `Flask_2`,`m`.`Pressure_2` AS `Pressure_2`,`m`.`PairID` AS `PairID`,`m`.`Login_Date` AS `Login_date`,`m`.`sample_datetime_utc` AS `sample_datetime_utc`,`m`.`Logout_Date` AS `Logout_Date`,`m`.`Operator` AS `Operator`,`m`.`Wind_Speed` AS `Wind_Speed`,`m`.`Wind_Direction` AS `Wind_Direction`,`m`.`Air_Temp` AS `Air_Temp`,`m`.`Dew_Point` AS `Dew_Point`,`m`.`Precipitation` AS `Precipitation`,`m`.`Sky` AS `Sky`,`m`.`Comments` AS `Comments`,`m`.`CounterForInHouse` AS `CounterForInHouse`,`m`.`HCFC_MS` AS `HCFC_MS`,`m`.`HFC_MS` AS `HFC_MS`,`m`.`LEAPS` AS `LEAPS`,`m`.`Otto` AS `Otto` from `Status_MetData` `m` */;
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
-- Final view structure for view `flask_data_view`
--

/*!50001 DROP TABLE IF EXISTS `flask_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `flask_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_data_view` AS select `d`.`event_num` AS `event_num`,`d`.`num` AS `data_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`d`.`program_num` AS `program_num`,`prog`.`abbr` AS `program`,`d`.`parameter_num` AS `parameter_num`,`pa`.`formula` AS `parameter`,`e`.`date` AS `ev_date`,`e`.`time` AS `ev_time`,`e`.`dd` AS `ev_dd`,timestamp(`e`.`date`,`e`.`time`) AS `ev_datetime`,`e`.`id` AS `flask_id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `ev_comment`,`d`.`value` AS `value`,`d`.`unc` AS `unc`,`d`.`flag` AS `flag`,`d`.`inst` AS `inst`,`d`.`system` AS `system`,`d`.`date` AS `date`,`d`.`time` AS `time`,`d`.`date` AS `adate`,`d`.`time` AS `atime`,`d`.`date` AS `a_date`,`d`.`time` AS `a_time`,`d`.`dd` AS `a_dd`,timestamp(`d`.`date`,`d`.`time`) AS `a_datetime`,`d`.`dd` AS `dd`,`d`.`comment` AS `comment`,date_format(timestamp(`e`.`date`,`e`.`time`),case when `e`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyEvDate`,date_format(timestamp(`d`.`date`,`d`.`time`),case when `d`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyADate`,`d`.`creation_datetime` AS `a_creation_datetime` from ((((((`hats`.`flask_event` `e` join `hats`.`flask_data` `d`) join `gmd`.`site` `si`) join `gmd`.`project` `proj`) join `ccgg`.`strategy` `st`) join `gmd`.`program` `prog`) join `gmd`.`parameter` `pa`) where `e`.`num` = `d`.`event_num` and `e`.`site_num` = `si`.`num` and `e`.`project_num` = `proj`.`num` and `e`.`strategy_num` = `st`.`num` and `d`.`program_num` = `prog`.`num` and `d`.`parameter_num` = `pa`.`num` */;
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
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `flask_event_view` AS select `e`.`num` AS `num`,`e`.`num` AS `event_num`,`e`.`site_num` AS `site_num`,`si`.`code` AS `site`,`e`.`project_num` AS `project_num`,`proj`.`abbr` AS `project`,`e`.`strategy_num` AS `strategy_num`,`st`.`abbr` AS `strategy`,`e`.`date` AS `date`,`e`.`date` AS `ev_date`,`e`.`time` AS `time`,`e`.`time` AS `ev_time`,timestamp(`e`.`date`,`e`.`time`) AS `datetime`,date_format(timestamp(`e`.`date`,`e`.`time`),case when `e`.`time` = '00:00:00' then '%b %e %Y' else '%b %e %Y %H:%i:%S' end) AS `prettyEvDate`,`e`.`dd` AS `dd`,`e`.`id` AS `id`,`e`.`id` AS `flask_id`,`e`.`me` AS `me`,`e`.`lat` AS `lat`,`e`.`lon` AS `lon`,`e`.`alt` AS `alt`,`e`.`elev` AS `elev`,`e`.`comment` AS `comment` from (((`hats`.`flask_event` `e` join `gmd`.`site` `si`) join `gmd`.`project` `proj`) join `ccgg`.`strategy` `st`) where `e`.`site_num` = `si`.`num` and `e`.`project_num` = `proj`.`num` and `e`.`strategy_num` = `st`.`num` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `hats_analysis_flags`
--

/*!50001 DROP TABLE IF EXISTS `hats_analysis_flags`*/;
/*!50001 DROP VIEW IF EXISTS `hats_analysis_flags`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `hats_analysis_flags` AS select `a`.`num` AS `analysis_num`,case when (select count(0) from `flags_system` where `flags_system`.`analysis_num` = `a`.`num` and `flags_system`.`sflag` regexp '[A-Z]') + (select count(0) from `flags_sample` where `flags_sample`.`analysis_num` = `a`.`num` and `flags_sample`.`sample_flag` regexp '[A-Z]') + (select count(0) from `flags_internal` where `flags_internal`.`analysis_num` = `a`.`num` and `flags_internal`.`parameter_num` = `m`.`parameter_num` and `flags_internal`.`iflag`  not like 'T' and `flags_internal`.`iflag`  not like 'S%' and `flags_internal`.`iflag`  not like '*' and (`flags_internal`.`iflag` regexp '[A-Z]' or `flags_internal`.`iflag` in ('%','~','$'))) > 0 then 1 else 0 end AS `rejected`,case when (select count(0) from `flags_internal` where `flags_internal`.`analysis_num` = `a`.`num` and `flags_internal`.`parameter_num` = `m`.`parameter_num` and (`flags_internal`.`iflag` regexp '[a-z]' or `flags_internal`.`iflag` in ('<','>'))) > 0 then 1 else 0 end AS `suspicious`,(select group_concat(`flags_internal`.`iflag` separator '|') from `flags_internal` where `flags_internal`.`analysis_num` = `a`.`num` and `flags_internal`.`parameter_num` = `m`.`parameter_num`) AS `internal_flags` from (`analysis` `a` join `mole_fractions` `m` on(`m`.`analysis_num` = `a`.`num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `hats_data_tags_view`
--

/*!50001 DROP TABLE IF EXISTS `hats_data_tags_view`*/;
/*!50001 DROP VIEW IF EXISTS `hats_data_tags_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `hats_data_tags_view` AS select `h`.`analysis_num` AS `analysis_num`,`a`.`analysis_datetime` AS `analysis_datetime`,timestamp(`e`.`date`,`e`.`time`) AS `sample_datetime`,`h`.`parameter_num` AS `parameter_num`,`h`.`data_num` AS `data_num`,`h`.`event_num` AS `event_num`,`tv`.`flag` AS `flag`,`tv`.`display_name` AS `display_name`,`tv`.`tag_comment` AS `tag_comment`,`tv`.`prelim` AS `prelim`,`tv`.`reject` AS `reject`,`tv`.`selection` AS `selection`,`tv`.`information` AS `information` from (((`ccgg`.`hats_data_view` `h` join `ccgg`.`flask_data_tag_view` `tv` on(`h`.`data_num` = `tv`.`data_num`)) join `hats`.`analysis` `a` on(`a`.`num` = `h`.`analysis_num`)) join `ccgg`.`flask_event` `e` on(`h`.`event_num` = `e`.`num`)) where `tv`.`data_source` not in (11,12) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `hats_event_tags_view`
--

/*!50001 DROP TABLE IF EXISTS `hats_event_tags_view`*/;
/*!50001 DROP VIEW IF EXISTS `hats_event_tags_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `hats_event_tags_view` AS select `a`.`num` AS `analysis_num`,`a`.`analysis_datetime` AS `analysis_datetime`,timestamp(`e`.`date`,`e`.`time`) AS `sample_datetime`,`h`.`parameter_num` AS `parameter_num`,`h`.`data_num` AS `data_num`,`h`.`event_num` AS `event_num`,`tv`.`flag` AS `flag`,`tv`.`display_name` AS `display_name`,`tv`.`tag_comment` AS `tag_comment`,`tv`.`prelim` AS `prelim`,`tv`.`reject` AS `reject`,`tv`.`selection` AS `selection`,`tv`.`information` AS `information` from (((`hats`.`analysis` `a` join `ccgg`.`hats_data_view` `h` on(`a`.`num` = `h`.`analysis_num`)) join `ccgg`.`flask_event_tag_view` `tv` on(`a`.`event_num` = `tv`.`event_num`)) join `ccgg`.`flask_event` `e` on(`a`.`event_num` = `e`.`num`)) where `tv`.`data_source` not in (11,12) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `hats_flask_view`
--

/*!50001 DROP TABLE IF EXISTS `hats_flask_view`*/;
/*!50001 DROP VIEW IF EXISTS `hats_flask_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `hats_flask_view` AS select `a`.`num` AS `analysis_num`,`a`.`analysis_datetime` AS `analysis_datetime`,`a`.`site_num` AS `site_num`,`s`.`code` AS `site`,`a`.`sample_ID` AS `sample_ID`,`a`.`inst_num` AS `inst_num`,`i`.`id` AS `inst_id`,`m`.`sample_datetime_utc` AS `sample_datetime`,`f`.`parameter_num` AS `parameter_num`,`p`.`formula` AS `formula`,`f`.`C_reported` AS `value`,`a`.`event_num` AS `event_num`,`a`.`sample_type` AS `sample_type`,case when (select count(0) from `hats`.`flags_system` where `hats`.`flags_system`.`analysis_num` = `a`.`num` and `hats`.`flags_system`.`sflag` regexp '[A-Z]') + (select count(0) from `hats`.`flags_sample` where `hats`.`flags_sample`.`analysis_num` = `a`.`num` and `hats`.`flags_sample`.`sample_flag` regexp '[A-Z]') + (select count(0) from `hats`.`flags_internal` where `hats`.`flags_internal`.`analysis_num` = `a`.`num` and `hats`.`flags_internal`.`parameter_num` = `f`.`parameter_num` and `hats`.`flags_internal`.`iflag`  not like 'T' and `hats`.`flags_internal`.`iflag`  not like 'S%' and `hats`.`flags_internal`.`iflag`  not like '*' and (`hats`.`flags_internal`.`iflag` regexp '[A-Z]' or `hats`.`flags_internal`.`iflag` in ('%','~','$'))) > 0 then 1 else 0 end AS `rejected`,case when (select count(0) from `hats`.`flags_internal` where `hats`.`flags_internal`.`analysis_num` = `a`.`num` and `hats`.`flags_internal`.`parameter_num` = `f`.`parameter_num` and (`hats`.`flags_internal`.`iflag` regexp '[a-z]' or `hats`.`flags_internal`.`iflag` in ('<','>'))) > 0 then 1 else 0 end AS `suspicious`,case when (select count(0) from `hats`.`flags_internal` where `hats`.`flags_internal`.`analysis_num` = `a`.`num` and `hats`.`flags_internal`.`parameter_num` = `f`.`parameter_num` and `hats`.`flags_internal`.`iflag` in ('<','>')) = 0 then 1 else 0 end AS `background`,`m`.`PairID` AS `PairID`,case when `a`.`sample_ID` = `m`.`Flask_1` then 1 else 2 end AS `flask_pair_num` from (((((`hats`.`analysis` `a` join `hats`.`Status_MetData` `m` on(`a`.`event_num` = `m`.`PairID`)) join `hats`.`mole_fractions` `f` on(`f`.`analysis_num` = `a`.`num`)) join `ccgg`.`inst_description` `i` on(`i`.`num` = `a`.`inst_num`)) join `gmd`.`site` `s` on(`a`.`site_num` = `s`.`num`)) join `gmd`.`parameter` `p` on(`f`.`parameter_num` = `p`.`num`)) where `a`.`event_num` <> 0 and `a`.`sample_type` not in ('PFP','CCGG') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ng_data_view`
--

/*!50001 DROP TABLE IF EXISTS `ng_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `ng_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `ng_data_view` AS select `a`.`num` AS `analysis_num`,`a`.`analysis_time` AS `analysis_datetime`,`i`.`id` AS `inst_id`,`a`.`inst_num` AS `inst_num`,ifnull(`fe`.`flask_id`,`a`.`flask_id`) AS `sample_id`,ifnull(`s`.`num`,`fe`.`site_num`) AS `site_num`,ifnull(`s`.`code`,`fe`.`site`) AS `site`,ifnull(`fe`.`strategy`,`e`.`Flask_Type`) AS `sample_type`,`a`.`port` AS `port`,NULL AS `standards_num`,`r`.`abbr` AS `run_type`,`a`.`run_type_num` AS `run_type_num`,`a`.`port_info` AS `port_info`,`a`.`flask_port` AS `flask_port`,`a`.`pair_id_num` AS `pair_id_num`,`a`.`ccgg_event_num` AS `ccgg_event_num`,ifnull(`e`.`sample_datetime_utc`,`fe`.`ev_datetime`) AS `sample_datetime`,ifnull(`fe`.`project_num`,6) AS `project_num`,8 AS `program_num`,ifnull(`fe`.`strategy_num`,1) AS `strategy_num`,`p`.`formula` AS `parameter`,`mf`.`parameter_num` AS `parameter_num`,`mf`.`mole_fraction` AS `value`,`mf`.`channel` AS `channel`,`m`.`abbr` AS `detrend_method`,`mf`.`detrend_method_num` AS `detrend_method_num`,`mf`.`height` AS `height`,`mf`.`area` AS `area`,`mf`.`retention_time` AS `retention_time`,`mf`.`mole_fraction` AS `mole_fraction`,`mf`.`unc` AS `unc`,`mf`.`qc_status` AS `qc_status`,`mf`.`flag` AS `flag`,case when `mf`.`flag` like '.%' then 0 else 1 end AS `rejected`,case when `mf`.`flag` like '%.' then 0 else 1 end AS `suspicious`,`e`.`Wind_Speed` AS `Wind_Speed`,`e`.`Wind_Direction` AS `Wind_Direction`,`e`.`Air_Temp` AS `Air_Temp`,`e`.`Dew_Point` AS `Dew_Point`,`e`.`Precipitation` AS `Precipitation`,`e`.`Sky` AS `Sky`,`e`.`Comments` AS `Comments`,`e`.`CounterForInHouse` AS `CounterForInHouse`,`e`.`HCFC_MS` AS `HCFC_MS`,`e`.`HFC_MS` AS `HFC_MS`,`e`.`LEAPS` AS `LEAPS`,`e`.`Otto` AS `Otto`,`a`.`run_time` AS `run_time`,`a`.`pair_id_num` AS `PairID`,ifnull(`fe`.`alt`,`s`.`elev`) AS `alt`,ifnull(`fe`.`elev`,`s`.`elev`) AS `elev`,ifnull(`fe`.`lat`,`s`.`lat`) AS `lat`,ifnull(`fe`.`lon`,`s`.`lon`) AS `lon` from ((((((((`hats`.`ng_analysis` `a` join `hats`.`ng_mole_fractions` `mf` on(`mf`.`analysis_num` = `a`.`num`)) join `hats`.`ng_run_types` `r` on(`r`.`num` = `a`.`run_type_num`)) join `hats`.`ng_detrend_methods` `m` on(`m`.`num` = `mf`.`detrend_method_num`)) join `ccgg`.`inst_description` `i` on(`i`.`num` = `a`.`inst_num`)) join `gmd`.`parameter` `p` on(`p`.`num` = `mf`.`parameter_num`)) left join `hats`.`Status_MetData` `e` on(`e`.`PairID` = `a`.`pair_id_num`)) left join `gmd`.`site` `s` on(`e`.`Station` = `s`.`code`)) left join `ccgg`.`flask_event_view` `fe` on(`a`.`ccgg_event_num` = `fe`.`event_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `ng_pair_avg_view`
--

/*!50001 DROP TABLE IF EXISTS `ng_pair_avg_view`*/;
/*!50001 DROP VIEW IF EXISTS `ng_pair_avg_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `ng_pair_avg_view` AS select `d`.`site` AS `site`,`d`.`site_num` AS `site_num`,`d`.`sample_datetime` AS `sample_datetime`,`d`.`sample_type` AS `sample_type`,`d`.`inst_num` AS `inst_num`,`d`.`inst_id` AS `inst_id`,`d`.`pair_id_num` AS `pair_id_num`,`d`.`parameter_num` AS `parameter_num`,`d`.`parameter` AS `parameter`,`d`.`Wind_Speed` AS `Wind_Speed`,`d`.`Wind_Direction` AS `Wind_Direction`,min(`d`.`analysis_datetime`) AS `analysis_datetime`,group_concat(`d`.`analysis_num` order by `d`.`analysis_num` ASC separator '|') AS `analysis_num`,group_concat(`d`.`sample_id` order by `d`.`sample_id` ASC separator '|') AS `sample_id`,avg(`d`.`value`) AS `pair_avg`,count(`d`.`value`) AS `n`,std(`d`.`value`) AS `pair_stdv` from `hats`.`ng_data_view` `d` where `d`.`rejected` = 0 and (`d`.`pair_id_num` > 0 or `d`.`ccgg_event_num` > 0) group by `d`.`site`,`d`.`site_num`,`d`.`sample_datetime`,`d`.`sample_type`,`d`.`inst_num`,`d`.`inst_id`,`d`.`pair_id_num`,`d`.`parameter_num`,`d`.`parameter`,`d`.`Wind_Speed`,`d`.`Wind_Direction` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `procedure_status_view`
--

/*!50001 DROP TABLE IF EXISTS `procedure_status_view`*/;
/*!50001 DROP VIEW IF EXISTS `procedure_status_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `procedure_status_view` AS select `procedure_status`.`proc_name` AS `proc_name`,`procedure_status`.`total_i` AS `total_months`,`procedure_status`.`current_i` AS `completed_months`,date_format(`procedure_status`.`period_start_date` + interval `procedure_status`.`current_i` - 1 month,'%M %Y') AS `current_month_being_processed`,`procedure_status`.`start` AS `start_time`,`procedure_status`.`currtime` AS `last_update_time`,timestampdiff(SECOND,`procedure_status`.`start`,`procedure_status`.`currtime`) AS `elapsed_seconds`,format(`procedure_status`.`current_i` / `procedure_status`.`total_i` * 100,2) AS `percent_complete`,case when `procedure_status`.`current_i` > 0 then `procedure_status`.`currtime` + interval timestampdiff(SECOND,`procedure_status`.`start`,`procedure_status`.`currtime`) / `procedure_status`.`current_i` * (`procedure_status`.`total_i` - `procedure_status`.`current_i`) second else NULL end AS `estimated_completion_time`,case when `procedure_status`.`current_i` > 0 then format(timestampdiff(SECOND,`procedure_status`.`start`,`procedure_status`.`currtime`) / `procedure_status`.`current_i` * (`procedure_status`.`total_i` - `procedure_status`.`current_i`),2) else NULL end AS `estimated_seconds_remaining`,case when `procedure_status`.`current_i` > 0 then format(timestampdiff(SECOND,`procedure_status`.`start`,`procedure_status`.`currtime`) / `procedure_status`.`current_i`,2) else NULL end AS `avg_seconds_per_month`,`procedure_status`.`period_start_date` AS `period_start_date`,`procedure_status`.`period_end_date` AS `period_end_date` from `procedure_status` where `procedure_status`.`total_i` > 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_corrected_response_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_corrected_response_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_corrected_response_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_corrected_response_view` AS select `cr`.`analysis_num` AS `analysis_num`,`cr`.`inst_num` AS `inst_num`,`cr`.`parameter_num` AS `parameter_num`,`cr`.`analysis_datetime` AS `analysis_datetime`,`cr`.`sample_type` AS `sample_type`,`cr`.`std_serial_num` AS `std_serial_num`,`tmp`.`f_dt2dec`(`cr`.`analysis_datetime`) AS `dd`,`cr`.`blank_corrected_response` AS `blank_corrected_response`,`cr`.`pre_interp_std_response` AS `pre_interp_std_response`,`cr`.`post_interp_std_response` AS `post_interp_std_response`,`cr`.`interpolated_std_response` AS `interpolated_std_response`,`cr`.`corrected_pressure` AS `corrected_pressure`,`cr`.`x` AS `nl_x`,`cr`.`blank_corrected_response` / `cr`.`interpolated_std_response` AS `normalized_response`,`cr`.`blank_corrected_response` / `cr`.`corrected_pressure` AS `raw_sensitivity`,`cr`.`interpolated_std_response` / `cr`.`corrected_pressure` AS `interpolated_sensitivity`,`cr`.`blank_corrected_response` / `cr`.`corrected_pressure` / `cr`.`interpolated_std_sensitivity` AS `rl` from `hats`.`prs_intermediate_calcs_response_view` `cr` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_data_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`hfcms`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_data_view` AS select `a`.`num` AS `analysis_num`,`a`.`analysis_datetime` AS `analysis_datetime`,`a`.`inst_num` AS `inst_num`,`i`.`id` AS `inst_id`,`a`.`sample_ID` AS `sample_id`,ifnull(`m`.`PairID`,0) AS `pair_id_num`,case when `a`.`sample_type` in ('ccgg','pfp') then `a`.`event_num` else 0 end AS `ccgg_event_num`,`a`.`site_num` AS `site_num`,`s`.`code` AS `site`,ifnull(`e`.`project_num`,6) AS `project_num`,8 AS `program_num`,ifnull(`e`.`strategy_num`,1) AS `strategy_num`,`a`.`sample_type` AS `sample_type`,`a`.`port` AS `port`,`a`.`standards_num` AS `standards_num`,`a`.`event_num` AS `event_num`,`a`.`lab_num` AS `lab_num`,ifnull(`m`.`sample_datetime_utc`,`e`.`ev_datetime`) AS `sample_datetime`,`m`.`Wind_Speed` AS `Wind_Speed`,`m`.`Wind_Direction` AS `Wind_Direction`,`f`.`parameter_num` AS `parameter_num`,`p`.`formula` AS `parameter`,`f`.`C_reported` AS `value`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`reject` = 1 limit 1) or exists(select 1 from `ccgg`.`flask_event_tag_view` `t` where `a`.`event_num` = `t`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `t`.`reject` = 1 limit 1) or exists(select 1 from (`ccgg`.`flask_data_tag_view` `dtv` join `ccgg`.`flask_data` `fd` on(`fd`.`num` = `dtv`.`data_num`)) where `fd`.`event_num` = `a`.`event_num` and `fd`.`parameter_num` = `f`.`parameter_num` and `a`.`sample_type` in ('PFP','CCGG') and `dtv`.`reject` = 1 and `dtv`.`data_source` not in (11,12) limit 1) then 1 else 0 end AS `rejected`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`reject` = 1 and (`t`.`inj_diff` = 0 or `t`.`inj_diff` = 1 and `t`.`automated` = 0) limit 1) or exists(select 1 from `ccgg`.`flask_event_tag_view` `t` where `a`.`event_num` = `t`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `t`.`reject` = 1 limit 1) or exists(select 1 from (`ccgg`.`flask_data_tag_view` `dtv` join `ccgg`.`flask_data` `fd` on(`fd`.`num` = `dtv`.`data_num`)) where `fd`.`event_num` = `a`.`event_num` and `fd`.`parameter_num` = `f`.`parameter_num` and `a`.`sample_type` in ('PFP','CCGG') and `dtv`.`reject` = 1 and `dtv`.`data_source` not in (11,12) limit 1) then 1 else 0 end AS `rejected_other_than_auto_inj_diff`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`reject` = 1 and (`t`.`pair_diff` = 0 or `t`.`pair_diff` = 1 and `t`.`automated` = 0) limit 1) or exists(select 1 from `ccgg`.`flask_event_tag_view` `t` where `a`.`event_num` = `t`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `t`.`reject` = 1 limit 1) or exists(select 1 from (`ccgg`.`flask_data_tag_view` `dtv` join `ccgg`.`flask_data` `fd` on(`fd`.`num` = `dtv`.`data_num`)) where `fd`.`event_num` = `a`.`event_num` and `fd`.`parameter_num` = `f`.`parameter_num` and `a`.`sample_type` in ('PFP','CCGG') and `dtv`.`reject` = 1 and `dtv`.`data_source` not in (11,12) limit 1) then 1 else 0 end AS `rejected_other_than_auto_pair_diff`,case when exists(select 1 from (`hats`.`flags_internal` `fi` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `fi`.`tag_num`)) where `fi`.`analysis_num` = `a`.`num` and `fi`.`parameter_num` = `f`.`parameter_num` and `t`.`information` = 1 and `t`.`prelim_data` = 0 and `t`.`hats_interpolation` = 0 limit 1) or exists(select 1 from `ccgg`.`flask_event_tag_view` `t` where `a`.`event_num` = `t`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `t`.`information` = 1 limit 1) or exists(select 1 from (`ccgg`.`flask_data_tag_view` `dtv` join `ccgg`.`flask_data` `fd` on(`fd`.`num` = `dtv`.`data_num`)) where `fd`.`event_num` = `a`.`event_num` and `fd`.`parameter_num` = `f`.`parameter_num` and `a`.`sample_type` in ('PFP','CCGG') and `dtv`.`information` = 1 and `dtv`.`data_source` not in (11,12) limit 1) then 1 else 0 end AS `suspicious`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`selection` = 1 limit 1) or exists(select 1 from `ccgg`.`flask_event_tag_view` `t` where `a`.`event_num` = `t`.`event_num` and `a`.`sample_type` in ('PFP','CCGG') and `t`.`selection` = 1 limit 1) or exists(select 1 from (`ccgg`.`flask_data_tag_view` `dtv` join `ccgg`.`flask_data` `fd` on(`fd`.`num` = `dtv`.`data_num`)) where `fd`.`event_num` = `a`.`event_num` and `fd`.`parameter_num` = `f`.`parameter_num` and `a`.`sample_type` in ('PFP','CCGG') and `dtv`.`selection` = 1 and `dtv`.`data_source` not in (11,12) limit 1) then 0 else 1 end AS `background`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`inj_diff` = 1 limit 1) then 1 else 0 end AS `inj_diff`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`prelim_data` = 1 limit 1) then 1 else 0 end AS `prelim`,case when `a`.`sample_type` in ('PFP','Flask','HATS','CCGG') and exists(select 1 from `hats`.`data_exclusions` `de` where `de`.`inst_num` = `a`.`inst_num` and (`de`.`sample_type` = `a`.`sample_type` or `de`.`sample_type` = 'All') and `de`.`parameter_num` = `f`.`parameter_num` and `de`.`a_start_date` <= `a`.`analysis_datetime` and `de`.`a_end_date` > `a`.`analysis_datetime` limit 1) then 1 else 0 end AS `data_exclusion`,case when exists(select 1 from (`hats`.`flags_internal` `flag` join `ccgg`.`tag_dictionary` `t` on(`t`.`num` = `flag`.`tag_num`)) where `flag`.`analysis_num` = `a`.`num` and `flag`.`parameter_num` = `f`.`parameter_num` and `t`.`hats_interpolation` = 1 limit 1) then 1 else 0 end AS `interp`,ifnull(`m`.`PairID`,0) AS `PairID`,case when `a`.`sample_ID` = `m`.`Flask_1` then 1 when `a`.`sample_ID` = `m`.`Flask_2` then 2 else NULL end AS `flask_pair_num`,ifnull(`e`.`alt`,`s`.`elev`) AS `alt`,ifnull(`e`.`elev`,`s`.`elev`) AS `elev`,ifnull(`e`.`lat`,`s`.`lat`) AS `lat`,ifnull(`e`.`lon`,`s`.`lon`) AS `lon`,`m`.`Flask_Type` AS `hats_flask_type` from ((((((`hats`.`analysis` `a` join `hats`.`mole_fractions` `f` on(`f`.`analysis_num` = `a`.`num`)) join `ccgg`.`inst_description` `i` on(`i`.`num` = `a`.`inst_num`)) left join `gmd`.`site` `s` on(`a`.`site_num` = `s`.`num`)) join `gmd`.`parameter` `p` on(`f`.`parameter_num` = `p`.`num`)) left join `hats`.`Status_MetData` `m` on(`a`.`event_num` = `m`.`PairID` and `a`.`event_num` <> 0 and `a`.`sample_type` not in ('pfp','ccgg'))) left join `ccgg`.`flask_event_view` `e` on(`a`.`event_num` = `e`.`event_num` and `a`.`sample_type` in ('pfp','ccgg'))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_inj_data_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_inj_data_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_inj_data_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_inj_data_view` AS select `d`.`site` AS `site`,`d`.`sample_datetime` AS `sample_datetime`,`d`.`analysis_datetime` AS `analysis_datetime`,`d`.`sample_type` AS `sample_type`,`d`.`inst_num` AS `inst_num`,`d`.`inst_id` AS `inst_id`,`d`.`PairID` AS `pairID`,`d`.`sample_id` AS `sample_id`,`d`.`analysis_num` AS `analysis_num`,`d`.`parameter_num` AS `parameter_num`,`d`.`parameter` AS `parameter`,`d`.`value` AS `value`,`d`.`flask_pair_num` AS `flask_pair_num`,avg(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`) AS `inj_avg`,count(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`) AS `n`,abs(max(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`) - min(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`)) AS `inj_diff`,abs(max(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`) - min(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`)) / avg(`d`.`value`) over ( partition by `d`.`PairID`,`d`.`sample_id`,`d`.`inst_num`,`d`.`parameter_num`) * 100 AS `inj_diff_pct_of_avg`,`ip`.`inj_diff_pct` AS `inj_diff_pct_threshold` from (`hats`.`prs_data_view` `d` left join `hats`.`hats_flask_limits` `ip` on(`d`.`inst_num` = `ip`.`inst_num` and `d`.`parameter_num` = `ip`.`parameter_num`)) where `d`.`PairID` is not null and `d`.`rejected_other_than_auto_inj_diff` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_intermediate_calcs_response_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_intermediate_calcs_response_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_intermediate_calcs_response_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`hfcms`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_intermediate_calcs_response_view` AS with t_adsorbed_air as (select `t`.`idx` AS `idx`,`t`.`inst_num` AS `inst_num`,`t`.`trap_id` AS `trap_id`,`t`.`start_datetime` AS `start_datetime`,`t`.`adsorb_file` AS `adsorb_file`,`t`.`comment` AS `comment`,`t`.`formula` AS `formula`,`t`.`xmean` AS `xmean`,`t`.`xstd` AS `xstd`,`t`.`ymean` AS `ymean`,`t`.`ystd` AS `ystd`,`t`.`p00` AS `p00`,`t`.`p01` AS `p01`,`t`.`p02` AS `p02`,`t`.`p03` AS `p03`,`t`.`p04` AS `p04`,`t`.`p05` AS `p05`,`t`.`p10` AS `p10`,`t`.`p11` AS `p11`,`t`.`p12` AS `p12`,`t`.`p13` AS `p13`,`t`.`p14` AS `p14`,`t`.`p20` AS `p20`,`t`.`p21` AS `p21`,`t`.`p22` AS `p22`,`t`.`p23` AS `p23`,`t`.`p30` AS `p30`,`t`.`p31` AS `p31`,`t`.`p32` AS `p32`,`t`.`p40` AS `p40`,`t`.`p41` AS `p41`,`t`.`p50` AS `p50`,ifnull((select min(`hats`.`PR1_adsorbed_air`.`start_datetime`) from `hats`.`PR1_adsorbed_air` where `hats`.`PR1_adsorbed_air`.`inst_num` = `t`.`inst_num` and `hats`.`PR1_adsorbed_air`.`start_datetime` > `t`.`start_datetime`),'9999-12-31') AS `end_datetime` from `hats`.`PR1_adsorbed_air` `t`)select ifnull(`pre_sr`.`interp_response`,0) AS `pre_interp_std_response`,ifnull(`post_sr`.`interp_response`,0) AS `post_interp_std_response`,`rr`.`raw_response` - case when `rr`.`use_blank_correction` = 0 then 0 when `rr`.`pre_blank_analysis_num` is null or `rr`.`post_blank_analysis_num` is null then `rr`.`pre_blank_raw_response` + `rr`.`post_blank_raw_response` else (`rr`.`pre_blank_raw_response` * timestampdiff(SECOND,`rr`.`analysis_datetime`,`rr`.`post_blank_analysis_datetime`) + `rr`.`post_blank_raw_response` * timestampdiff(SECOND,`rr`.`pre_blank_analysis_datetime`,`rr`.`analysis_datetime`)) / timestampdiff(SECOND,`rr`.`pre_blank_analysis_datetime`,`rr`.`post_blank_analysis_datetime`) end AS `blank_corrected_response`,case when `rr`.`sample_type` = 'std' then `sr`.`interp_response` when `pre_sr`.`interp_response` is null or `post_sr`.`interp_response` is null then ifnull(`pre_sr`.`interp_response`,0) + ifnull(`post_sr`.`interp_response`,0) when exists(select 1 from (`hats`.`flags_internal` `fi` join `ccgg`.`tag_dictionary` `td` on(`fi`.`tag_num` = `td`.`num`)) where `td`.`hats_interpolation` = 1 and `fi`.`analysis_num` = `post_sr`.`analysis_num` and `fi`.`parameter_num` = `post_sr`.`parameter_num` limit 1) then ifnull(`pre_sr`.`interp_response`,0) else (`pre_sr`.`interp_response` * timestampdiff(SECOND,`rr`.`analysis_datetime`,`post_a`.`analysis_datetime`) + `post_sr`.`interp_response` * timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`rr`.`analysis_datetime`)) / timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`post_a`.`analysis_datetime`) end AS `interpolated_std_response`,case when `rr`.`sample_type` = 'std' then `sr`.`interp_sens` when `pre_sr`.`interp_sens` is null or `post_sr`.`interp_sens` is null then ifnull(`pre_sr`.`interp_sens`,0) + ifnull(`post_sr`.`interp_sens`,0) when exists(select 1 from (`hats`.`flags_internal` `fi` join `ccgg`.`tag_dictionary` `td` on(`fi`.`tag_num` = `td`.`num`)) where `td`.`hats_interpolation` = 1 and `fi`.`analysis_num` = `post_sr`.`analysis_num` and `fi`.`parameter_num` = `post_sr`.`parameter_num` limit 1) then ifnull(`pre_sr`.`interp_sens`,0) else (`pre_sr`.`interp_sens` * timestampdiff(SECOND,`rr`.`analysis_datetime`,`post_a`.`analysis_datetime`) + `post_sr`.`interp_sens` * timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`rr`.`analysis_datetime`)) / timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`post_a`.`analysis_datetime`) end AS `interpolated_std_sensitivity`,(`rr`.`raw_response` - case when `rr`.`use_blank_correction` = 0 then 0 when `rr`.`pre_blank_analysis_num` is null or `rr`.`post_blank_analysis_num` is null then `rr`.`pre_blank_raw_response` + `rr`.`post_blank_raw_response` else (`rr`.`pre_blank_raw_response` * timestampdiff(SECOND,`rr`.`analysis_datetime`,`rr`.`post_blank_analysis_datetime`) + `rr`.`post_blank_raw_response` * timestampdiff(SECOND,`rr`.`pre_blank_analysis_datetime`,`rr`.`analysis_datetime`)) / timestampdiff(SECOND,`rr`.`pre_blank_analysis_datetime`,`rr`.`post_blank_analysis_datetime`) end) / case when `rr`.`sample_type` = 'std' then `sr`.`interp_response` when `pre_sr`.`interp_response` is null or `post_sr`.`interp_response` is null then ifnull(`pre_sr`.`interp_response`,0) + ifnull(`post_sr`.`interp_response`,0) when exists(select 1 from (`hats`.`flags_internal` `fi` join `ccgg`.`tag_dictionary` `td` on(`fi`.`tag_num` = `td`.`num`)) where `td`.`hats_interpolation` = 1 and `fi`.`analysis_num` = `post_sr`.`analysis_num` and `fi`.`parameter_num` = `post_sr`.`parameter_num` limit 1) then ifnull(`pre_sr`.`interp_response`,0) else (`pre_sr`.`interp_response` * timestampdiff(SECOND,`rr`.`analysis_datetime`,`post_a`.`analysis_datetime`) + `post_sr`.`interp_response` * timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`rr`.`analysis_datetime`)) / timestampdiff(SECOND,`pre_a`.`analysis_datetime`,`post_a`.`analysis_datetime`) end AS `x`,case when `rr`.`pressure` < 0 or `rr`.`temp` > -150.0 or `rr`.`temp` < -200.0 then 0 when `aa`.`formula` = 'poly55' then `aa`.`p00` + `aa`.`p10` * ((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`) + `aa`.`p01` * ((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`) + `aa`.`p20` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,2) + `aa`.`p11` * ((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`) * ((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`) + `aa`.`p02` * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,2) + `aa`.`p30` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,3) + `aa`.`p21` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,2) * ((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`) + `aa`.`p12` * ((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,2) + `aa`.`p03` * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,3) + `aa`.`p40` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,4) + `aa`.`p31` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,3) * ((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`) + `aa`.`p22` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,2) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,2) + `aa`.`p13` * ((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,3) + `aa`.`p04` * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,4) + `aa`.`p50` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,5) + `aa`.`p41` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,4) * ((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`) + `aa`.`p32` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,3) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,2) + `aa`.`p23` * pow((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`,2) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,3) + `aa`.`p14` * ((`rr`.`pressure` - `aa`.`xmean`) / `aa`.`xstd`) * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,4) + `aa`.`p05` * pow((`rr`.`temp` - `aa`.`ymean`) / `aa`.`ystd`,5) else 0 end + `rr`.`pressure` AS `corrected_pressure`,`rr`.`analysis_num` AS `analysis_num`,`rr`.`analysis_datetime` AS `analysis_datetime`,`rr`.`parameter_num` AS `parameter_num`,`rr`.`sample_type` AS `sample_type`,`rr`.`std_serial_num` AS `std_serial_num`,`rr`.`inst_num` AS `inst_num`,`rr`.`is_blank` AS `is_blank`,`rr`.`is_std` AS `is_std`,`rr`.`use_area` AS `use_area`,`rr`.`raw_response` AS `raw_response`,`rr`.`peak_area` AS `peak_area`,`rr`.`peak_height` AS `peak_height`,`rr`.`use_blank_correction` AS `use_blank_correction`,`rr`.`pre_blank_analysis_num` AS `pre_blank_analysis_num`,`rr`.`pre_blank_analysis_datetime` AS `pre_blank_analysis_datetime`,`rr`.`pre_blank_area` AS `pre_blank_area`,`rr`.`pre_blank_height` AS `pre_blank_height`,`rr`.`pre_blank_raw_response` AS `pre_blank_raw_response`,`rr`.`post_blank_analysis_num` AS `post_blank_analysis_num`,`rr`.`post_blank_analysis_datetime` AS `post_blank_analysis_datetime`,`rr`.`post_blank_area` AS `post_blank_area`,`rr`.`post_blank_height` AS `post_blank_height`,`rr`.`post_blank_raw_response` AS `post_blank_raw_response`,`rr`.`pressure` AS `pressure`,`rr`.`temp` AS `temp`,`rr`.`pre_standard_analysis_num` AS `pre_standard_analysis_num`,`rr`.`post_standard_analysis_num` AS `post_standard_analysis_num` from ((((`hats`.`prs_raw_response_view` `rr` left join (`hats`.`analysis` `pre_a` join `hats`.`interp_std_response` `pre_sr` on(`pre_a`.`num` = `pre_sr`.`analysis_num`)) on(`rr`.`pre_standard_analysis_num` = `pre_sr`.`analysis_num` and `rr`.`parameter_num` = `pre_sr`.`parameter_num`)) left join (`hats`.`analysis` `post_a` join `hats`.`interp_std_response` `post_sr` on(`post_a`.`num` = `post_sr`.`analysis_num`)) on(`rr`.`post_standard_analysis_num` = `post_sr`.`analysis_num` and `rr`.`parameter_num` = `post_sr`.`parameter_num`)) left join `t_adsorbed_air` `aa` on(`aa`.`inst_num` = `rr`.`inst_num` and `aa`.`start_datetime` <= `rr`.`analysis_datetime` and `aa`.`end_datetime` > `rr`.`analysis_datetime`)) left join `hats`.`interp_std_response` `sr` on(`rr`.`analysis_num` = `sr`.`analysis_num` and `rr`.`parameter_num` = `sr`.`parameter_num`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_mole_fraction_tag_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_mole_fraction_tag_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_mole_fraction_tag_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`hfcms`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_mole_fraction_tag_view` AS select `f`.`analysis_num` AS `analysis_num`,`f`.`parameter_num` AS `parameter_num`,`f`.`tag_num` AS `tag_num`,`t`.`display_name` AS `display_name`,`t`.`flag` AS `flag`,`t`.`reject` AS `reject`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`automated` AS `automated`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff`,`t`.`prelim_data` AS `prelim`,`f`.`comment` AS `comment` from (`hats`.`flags_internal` `f` join `ccgg`.`tag_view` `t` on(`f`.`tag_num` = `t`.`num`)) union all select `a`.`num` AS `analysis_num`,`m`.`parameter_num` AS `parameter_num`,`t`.`tag_num` AS `tag_num`,`t`.`display_name` AS `display_name`,`t`.`flag` AS `flag`,`t`.`reject` AS `reject`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`automated` AS `automated`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff`,`t`.`prelim_data` AS `prelim`,`t`.`tag_comment` AS `comment` from ((`hats`.`analysis` `a` join `hats`.`mole_fractions` `m` on(`a`.`num` = `m`.`analysis_num`)) join `ccgg`.`flask_event_tag_view` `t` on(`a`.`event_num` = `t`.`event_num`)) where `a`.`sample_type` in ('PFP','CCGG') union all select `a`.`num` AS `analysis_num`,`m`.`parameter_num` AS `parameter_num`,`t`.`tag_num` AS `tag_num`,`t`.`display_name` AS `display_name`,`t`.`flag` AS `flag`,`t`.`reject` AS `reject`,`t`.`selection` AS `selection`,`t`.`information` AS `information`,`t`.`automated` AS `automated`,`t`.`collection_issue` AS `collection_issue`,`t`.`measurement_issue` AS `measurement_issue`,`t`.`selection_issue` AS `selection_issue`,`t`.`hats_interpolation` AS `hats_interpolation`,`t`.`pair_diff` AS `pair_diff`,`t`.`inj_diff` AS `inj_diff`,`t`.`prelim_data` AS `prelim`,`t`.`tag_comment` AS `comment` from (((`hats`.`analysis` `a` join `hats`.`mole_fractions` `m` on(`a`.`num` = `m`.`analysis_num`)) join `ccgg`.`flask_data` `d` on(`d`.`event_num` = `a`.`event_num` and `d`.`parameter_num` = `m`.`parameter_num`)) join `ccgg`.`flask_data_tag_view` `t` on(`d`.`num` = `t`.`data_num`)) where `a`.`sample_type` in ('PFP','CCGG') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_pair_avg_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_pair_avg_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_pair_avg_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_pair_avg_view` AS select `d`.`site` AS `site`,`d`.`site_num` AS `site_num`,`d`.`sample_datetime` AS `sample_datetime`,`d`.`sample_type` AS `sample_type`,`d`.`inst_num` AS `inst_num`,`d`.`inst_id` AS `inst_id`,`d`.`pair_id_num` AS `pair_id_num`,`d`.`parameter_num` AS `parameter_num`,`d`.`parameter` AS `parameter`,`d`.`Wind_Speed` AS `Wind_Speed`,`d`.`Wind_Direction` AS `Wind_Direction`,min(`d`.`analysis_datetime`) AS `analysis_datetime`,group_concat(`d`.`analysis_num` order by `d`.`analysis_num` ASC separator '|') AS `analysis_num`,group_concat(`d`.`sample_id` order by `d`.`sample_id` ASC separator '|') AS `sample_id`,avg(`d`.`value`) AS `pair_avg`,count(`d`.`value`) AS `n`,std(`d`.`value`) AS `pair_stdv` from `hats`.`prs_data_view` `d` where `d`.`rejected` = 0 and `d`.`data_exclusion` = 0 and `d`.`event_num` <> 0 group by `d`.`site`,`d`.`site_num`,`d`.`sample_datetime`,`d`.`sample_type`,`d`.`inst_num`,`d`.`inst_id`,`d`.`pair_id_num`,`d`.`parameter_num`,`d`.`parameter`,`d`.`Wind_Speed`,`d`.`Wind_Direction` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `prs_raw_response_view`
--

/*!50001 DROP TABLE IF EXISTS `prs_raw_response_view`*/;
/*!50001 DROP VIEW IF EXISTS `prs_raw_response_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `prs_raw_response_view` AS with t_blank_correction as (select `t`.`idx` AS `idx`,`t`.`parameter_num` AS `parameter_num`,`t`.`parameter` AS `parameter`,`t`.`inst_num` AS `inst_num`,`t`.`blank` AS `blank`,`t`.`start_datetime` AS `start_datetime`,ifnull((select min(`PR1_blank_correction`.`start_datetime`) from `PR1_blank_correction` where `PR1_blank_correction`.`parameter_num` = `t`.`parameter_num` and `PR1_blank_correction`.`inst_num` = `t`.`inst_num` and `PR1_blank_correction`.`start_datetime` > `t`.`start_datetime`),'9999-12-31') AS `end_datetime` from `PR1_blank_correction` `t`), t_peak_response as (select `t`.`idx` AS `idx`,`t`.`formula` AS `formula`,`t`.`parameter_num` AS `parameter_num`,`t`.`inst_num` AS `inst_num`,`t`.`response` AS `response`,`t`.`area` AS `area`,`t`.`start_date` AS `start_date`,ifnull((select min(`PR1_peak_response`.`start_date`) from `PR1_peak_response` where `PR1_peak_response`.`parameter_num` = `t`.`parameter_num` and `PR1_peak_response`.`inst_num` = `t`.`inst_num` and `PR1_peak_response`.`start_date` > `t`.`start_date`),'9999-12-31') AS `end_date` from `PR1_peak_response` `t`)select `a`.`num` AS `analysis_num`,`a`.`analysis_datetime` AS `analysis_datetime`,`rd`.`parameter_num` AS `parameter_num`,`a`.`sample_type` AS `sample_type`,`a`.`std_serial_num` AS `std_serial_num`,`a`.`inst_num` AS `inst_num`,case when `a`.`sample_type` like 'Blank' then 1 else 0 end AS `is_blank`,case when `a`.`sample_type` like 'Std' then 1 else 0 end AS `is_std`,ifnull(`pr`.`area`,1) AS `use_area`,case when ifnull(`pr`.`area`,1) = 1 then `rd`.`peak_area` else `rd`.`peak_height` end AS `raw_response`,`rd`.`peak_area` AS `peak_area`,`rd`.`peak_height` AS `peak_height`,case when ifnull(`bc`.`blank`,0) = 1 then 1 else 0 end AS `use_blank_correction`,`b_pre`.`analysis_num` AS `pre_blank_analysis_num`,`b_pre_a`.`analysis_datetime` AS `pre_blank_analysis_datetime`,ifnull(`b_pre`.`peak_area`,0) AS `pre_blank_area`,ifnull(`b_pre`.`peak_height`,0) AS `pre_blank_height`,ifnull(case when ifnull(`pr`.`area`,1) = 1 then `b_pre`.`peak_area` else `b_pre`.`peak_height` end,0) AS `pre_blank_raw_response`,`b_post`.`analysis_num` AS `post_blank_analysis_num`,`b_post_a`.`analysis_datetime` AS `post_blank_analysis_datetime`,ifnull(`b_post`.`peak_area`,0) AS `post_blank_area`,ifnull(`b_post`.`peak_height`,0) AS `post_blank_height`,ifnull(case when ifnull(`pr`.`area`,1) = 1 then `b_post`.`peak_area` else `b_post`.`peak_height` end,0) AS `post_blank_raw_response`,ifnull(`press`.`value`,0) AS `pressure`,ifnull(`temp`.`value`,0) AS `temp`,`rd`.`pre_standard_analysis_num` AS `pre_standard_analysis_num`,`rd`.`post_standard_analysis_num` AS `post_standard_analysis_num` from (((((((`analysis` `a` join `raw_data` `rd` on(`a`.`num` = `rd`.`analysis_num`)) left join `ancillary_data` `press` on(`press`.`analysis_num` = `a`.`num` and `press`.`ancillary_num` = 26)) left join `ancillary_data` `temp` on(`temp`.`analysis_num` = `a`.`num` and `temp`.`ancillary_num` = 29)) left join `t_blank_correction` `bc` on(`bc`.`parameter_num` = `rd`.`parameter_num` and `bc`.`inst_num` = `a`.`inst_num` and `a`.`analysis_datetime` >= `bc`.`start_datetime` and `a`.`analysis_datetime` < `bc`.`end_datetime`)) left join `t_peak_response` `pr` on(`pr`.`parameter_num` = `rd`.`parameter_num` and `pr`.`inst_num` = `a`.`inst_num` and `a`.`analysis_datetime` >= `pr`.`start_date` and `a`.`analysis_datetime` < `pr`.`end_date`)) left join (`analysis` `b_pre_a` join `raw_data` `b_pre` on(`b_pre_a`.`num` = `b_pre`.`analysis_num`)) on(`b_pre`.`analysis_num` = `rd`.`pre_blank_analysis_num` and `b_pre`.`parameter_num` = `rd`.`parameter_num`)) left join (`analysis` `b_post_a` join `raw_data` `b_post` on(`b_post_a`.`num` = `b_post`.`analysis_num`)) on(`b_post`.`analysis_num` = `rd`.`post_blank_analysis_num` and `b_post`.`parameter_num` = `rd`.`parameter_num`)) */;
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
/*!50001 VIEW `scale_assignments_fill` AS select distinct `a`.`serial_number` AS `serial_number`,`a`.`start_date` AS `start_date`,(select max(`f2`.`code`) from `reftank`.`fill` `f2` where `f2`.`serial_number` = `a`.`serial_number` and `f2`.`date` = (select max(`reftank`.`fill`.`date`) from `reftank`.`fill` where `reftank`.`fill`.`date` <= `a`.`start_date` and `reftank`.`fill`.`serial_number` = `a`.`serial_number`)) AS `fill_code`,ifnull((select min(`f3`.`date`) from `reftank`.`fill` `f3` where `f3`.`date` > `a`.`start_date` and `f3`.`serial_number` = `a`.`serial_number`),'9999-12-31') AS `next_fill_date` from `hats`.`scale_assignments` `a` */;
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
/*!50001 VIEW `scale_assignments_view` AS select `s`.`name` AS `scale`,`s`.`idx` AS `scale_num`,`s`.`species` AS `species`,`a`.`serial_number` AS `serial_number`,`f`.`fill_code` AS `fill_code`,`a`.`start_date` AS `start_date`,case when ifnull((select min(`a4`.`start_date`) from `hats`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) = '9999-12-31' then '9999-12-31' else ifnull((select min(`a4`.`start_date`) from `hats`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) + interval -1 day end AS `end_date`,`f`.`next_fill_date` AS `next_fill_date`,`a`.`assign_date` AS `assign_date`,case when `c`.`scale_num` is not null then 1 else 0 end AS `current_assignment`,`a`.`tzero` AS `tzero`,`a`.`coef0` AS `coef0`,`a`.`coef1` AS `coef1`,`a`.`coef2` AS `coef2`,`a`.`unc_c0` AS `unc_c0`,`a`.`unc_c1` AS `unc_c1`,`a`.`unc_c2` AS `unc_c2`,`a`.`sd_resid` AS `sd_resid`,`a`.`standard_unc` AS `standard_unc`,`a`.`level` AS `level`,`a`.`comment` AS `comment`,`p`.`num` AS `parameter_num`,`a`.`num` AS `scale_assignment_num`,`s`.`current` AS `current_scale`,`a`.`n` AS `n` from ((((`hats`.`scale_assignments` `a` join `reftank`.`scales` `s` on(`s`.`idx` = `a`.`scale_num`)) join `gmd`.`parameter` `p` on(`p`.`formula` = `s`.`species`)) join `hats`.`scale_assignments_fill` `f` on(`f`.`serial_number` = `a`.`serial_number` and `f`.`start_date` = `a`.`start_date`)) left join `hats`.`current_scale_assignments_view` `c` on(`a`.`scale_num` = `c`.`scale_num` and `a`.`serial_number` = `c`.`serial_number` and `a`.`start_date` = `c`.`start_date` and `a`.`assign_date` = `c`.`assign_date`)) order by `s`.`name`,`a`.`serial_number`,`a`.`start_date` */;
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

-- Dump completed on 2025-04-17 10:08:47
