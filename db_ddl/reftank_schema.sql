-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: reftank
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
-- Table structure for table `CH4_X2004`
--

DROP TABLE IF EXISTS `CH4_X2004`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CH4_X2004` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=190 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CH4_X2004A`
--

DROP TABLE IF EXISTS `CH4_X2004A`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CH4_X2004A` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=351 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2C13_X2007`
--

DROP TABLE IF EXISTS `CO2C13_X2007`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2C13_X2007` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=104 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2C13_X2019`
--

DROP TABLE IF EXISTS `CO2C13_X2019`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2C13_X2019` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc_c0` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef0',
  `unc_c1` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef1',
  `unc_c2` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef2',
  `sd_resid` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=75 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2O18_X2007`
--

DROP TABLE IF EXISTS `CO2O18_X2007`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2O18_X2007` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=104 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2O18_X2019`
--

DROP TABLE IF EXISTS `CO2O18_X2019`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2O18_X2019` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc_c0` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef0',
  `unc_c1` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef1',
  `unc_c2` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef2',
  `sd_resid` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=72 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2_Manometer`
--

DROP TABLE IF EXISTS `CO2_Manometer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2_Manometer` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=383 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2_X2007`
--

DROP TABLE IF EXISTS `CO2_X2007`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2_X2007` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL DEFAULT 0,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=1914 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2_X2019`
--

DROP TABLE IF EXISTS `CO2_X2019`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2_X2019` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc_c0` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef0',
  `unc_c1` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef1',
  `unc_c2` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef2',
  `sd_resid` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=4963 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO2_X2019_primary`
--

DROP TABLE IF EXISTS `CO2_X2019_primary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO2_X2019_primary` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc_c0` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef0',
  `unc_c1` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef1',
  `unc_c2` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef2',
  `sd_resid` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO_X2004`
--

DROP TABLE IF EXISTS `CO_X2004`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO_X2004` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=132 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO_X2014`
--

DROP TABLE IF EXISTS `CO_X2014`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO_X2014` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=200 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `CO_X2014A`
--

DROP TABLE IF EXISTS `CO_X2014A`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CO_X2014A` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=490 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `H2_X1996`
--

DROP TABLE IF EXISTS `H2_X1996`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `H2_X1996` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=135 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `H2_X2009`
--

DROP TABLE IF EXISTS `H2_X2009`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `H2_X2009` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc_c0` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef0',
  `unc_c1` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef1',
  `unc_c2` float NOT NULL DEFAULT 0 COMMENT 'uncertainty of coef2',
  `sd_resid` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `N2O_X2006A`
--

DROP TABLE IF EXISTS `N2O_X2006A`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `N2O_X2006A` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=258 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SF6_X2006`
--

DROP TABLE IF EXISTS `SF6_X2006`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SF6_X2006` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=79 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SF6_X2014`
--

DROP TABLE IF EXISTS `SF6_X2014`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SF6_X2014` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL,
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `tzero` float(10,6) NOT NULL DEFAULT 0.000000,
  `coef0` float NOT NULL DEFAULT 0,
  `coef1` float NOT NULL DEFAULT 0,
  `coef2` float NOT NULL DEFAULT 0,
  `unc` float NOT NULL,
  `standard_unc` float NOT NULL DEFAULT 0,
  `level` enum('Primary','Secondary','Tertiary','Other') NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=161 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aux`
--

DROP TABLE IF EXISTS `aux`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aux` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `barcode` varchar(30) NOT NULL,
  `serial_number` varchar(20) NOT NULL,
  `customer_owned` tinyint(1) NOT NULL DEFAULT 0,
  `user` varchar(40) NOT NULL DEFAULT '',
  `contents` varchar(50) NOT NULL,
  `company` varchar(50) NOT NULL DEFAULT '',
  `order_date` date NOT NULL DEFAULT '0000-00-00',
  `order_number` varchar(20) NOT NULL,
  `delivery_date` date NOT NULL DEFAULT '0000-00-00',
  `return_date` date NOT NULL DEFAULT '0000-00-00',
  `location` varchar(30) NOT NULL DEFAULT '',
  `sent_out_date` date NOT NULL DEFAULT '0000-00-00',
  `sent_in_date` date NOT NULL DEFAULT '0000-00-00',
  `entry_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `comments` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=116 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
) ENGINE=MyISAM AUTO_INCREMENT=252438 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_calibrations_after_insert after insert ON reftank.calibrations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('idx',':',ifnull(NEW.idx,'null')), concat('serial_number',':',ifnull(NEW.serial_number,'null')), concat('date',':',ifnull(NEW.date,'null')), concat('time',':',ifnull(NEW.time,'null')), concat('species',':',ifnull(NEW.species,'null')), concat('mixratio',':',ifnull(NEW.mixratio,'null')), concat('stddev',':',ifnull(NEW.stddev,'null')), concat('num',':',ifnull(NEW.num,'null')), concat('method',':',ifnull(NEW.method,'null')), concat('inst',':',ifnull(NEW.inst,'null')), concat('system',':',ifnull(NEW.system,'null')), concat('pressure',':',ifnull(NEW.pressure,'null')), concat('flag',':',ifnull(NEW.flag,'null')), concat('location',':',ifnull(NEW.location,'null')), concat('regulator',':',ifnull(NEW.regulator,'null')), concat('notes',':',ifnull(NEW.notes,'null')), concat('mod_date',':',ifnull(NEW.mod_date,'null')), concat('meas_unc',':',ifnull(NEW.meas_unc,'null')), concat('scale_num',':',ifnull(NEW.scale_num,'null')), concat('parameter_num',':',ifnull(NEW.parameter_num,'null')), concat('run_number',':',ifnull(NEW.run_number,'null'))),'reftank','calibrations',new.idx;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_calibrations_after_update after update ON reftank.calibrations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.idx <> OLD.idx, concat('idx(Old:',OLD.idx,' New:',NEW.idx,')'), NULL), IF(NEW.serial_number <> OLD.serial_number, concat('serial_number(Old:',OLD.serial_number,' New:',NEW.serial_number,')'), NULL), IF(NEW.date <> OLD.date, concat('date(Old:',OLD.date,' New:',NEW.date,')'), NULL), IF(NEW.time <> OLD.time, concat('time(Old:',OLD.time,' New:',NEW.time,')'), NULL), IF(NEW.species <> OLD.species, concat('species(Old:',OLD.species,' New:',NEW.species,')'), NULL), IF(NEW.mixratio <> OLD.mixratio, concat('mixratio(Old:',OLD.mixratio,' New:',NEW.mixratio,')'), NULL), IF(NEW.stddev <> OLD.stddev, concat('stddev(Old:',OLD.stddev,' New:',NEW.stddev,')'), NULL), IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.method <> OLD.method, concat('method(Old:',OLD.method,' New:',NEW.method,')'), NULL), IF(NEW.inst <> OLD.inst, concat('inst(Old:',OLD.inst,' New:',NEW.inst,')'), NULL), IF(NEW.system <> OLD.system, concat('system(Old:',OLD.system,' New:',NEW.system,')'), NULL), IF(NEW.pressure <> OLD.pressure, concat('pressure(Old:',OLD.pressure,' New:',NEW.pressure,')'), NULL), IF(NEW.flag <> OLD.flag, concat('flag(Old:',OLD.flag,' New:',NEW.flag,')'), NULL), IF(NEW.location <> OLD.location, concat('location(Old:',OLD.location,' New:',NEW.location,')'), NULL), IF(NEW.regulator <> OLD.regulator, concat('regulator(Old:',OLD.regulator,' New:',NEW.regulator,')'), NULL), IF(NEW.notes <> OLD.notes, concat('notes(Old:',OLD.notes,' New:',NEW.notes,')'), NULL), IF(NEW.mod_date <> OLD.mod_date, concat('mod_date(Old:',OLD.mod_date,' New:',NEW.mod_date,')'), NULL), IF(NEW.meas_unc <> OLD.meas_unc, concat('meas_unc(Old:',OLD.meas_unc,' New:',NEW.meas_unc,')'), NULL), IF(NEW.scale_num <> OLD.scale_num, concat('scale_num(Old:',OLD.scale_num,' New:',NEW.scale_num,')'), NULL), IF(NEW.parameter_num <> OLD.parameter_num, concat('parameter_num(Old:',OLD.parameter_num,' New:',NEW.parameter_num,')'), NULL), IF(NEW.run_number <> OLD.run_number, concat('run_number(Old:',OLD.run_number,' New:',NEW.run_number,')'), NULL)),'reftank', 'calibrations',new.idx;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_calibrations_before_delete before delete ON reftank.calibrations FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('idx',':',ifnull(OLD.idx,'null')), concat('serial_number',':',ifnull(OLD.serial_number,'null')), concat('date',':',ifnull(OLD.date,'null')), concat('time',':',ifnull(OLD.time,'null')), concat('species',':',ifnull(OLD.species,'null')), concat('mixratio',':',ifnull(OLD.mixratio,'null')), concat('stddev',':',ifnull(OLD.stddev,'null')), concat('num',':',ifnull(OLD.num,'null')), concat('method',':',ifnull(OLD.method,'null')), concat('inst',':',ifnull(OLD.inst,'null')), concat('system',':',ifnull(OLD.system,'null')), concat('pressure',':',ifnull(OLD.pressure,'null')), concat('flag',':',ifnull(OLD.flag,'null')), concat('location',':',ifnull(OLD.location,'null')), concat('regulator',':',ifnull(OLD.regulator,'null')), concat('notes',':',ifnull(OLD.notes,'null')), concat('mod_date',':',ifnull(OLD.mod_date,'null')), concat('meas_unc',':',ifnull(OLD.meas_unc,'null')), concat('scale_num',':',ifnull(OLD.scale_num,'null')), concat('parameter_num',':',ifnull(OLD.parameter_num,'null')), concat('run_number',':',ifnull(OLD.run_number,'null'))),'reftank', 'calibrations',old.idx;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `calibrations_20200507`
--

DROP TABLE IF EXISTS `calibrations_20200507`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrations_20200507` (
  `idx` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(11) NOT NULL DEFAULT '0',
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
  PRIMARY KEY (`idx`),
  KEY `cyl_date` (`serial_number`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=145864 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `calibrations_export_view`
--

DROP TABLE IF EXISTS `calibrations_export_view`;
/*!50001 DROP VIEW IF EXISTS `calibrations_export_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `calibrations_export_view` (
  `serial_number` tinyint NOT NULL,
  `datetime` tinyint NOT NULL,
  `species` tinyint NOT NULL,
  `scale` tinyint NOT NULL,
  `value` tinyint NOT NULL,
  `meas_unc` tinyint NOT NULL,
  `stddev` tinyint NOT NULL,
  `n` tinyint NOT NULL,
  `method` tinyint NOT NULL,
  `inst` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `pressure` tinyint NOT NULL,
  `flag` tinyint NOT NULL,
  `location` tinyint NOT NULL,
  `regulator` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL,
  `fill_date` tinyint NOT NULL,
  `notes` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

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
-- Table structure for table `calibrations_h2_x1996`
--

DROP TABLE IF EXISTS `calibrations_h2_x1996`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrations_h2_x1996` (
  `idx` mediumint(8) unsigned NOT NULL DEFAULT 0,
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
  `mod_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calibrations_qcdata`
--

DROP TABLE IF EXISTS `calibrations_qcdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calibrations_qcdata` (
  `cal_num` int(11) NOT NULL,
  `manifold` varchar(45) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  PRIMARY KEY (`cal_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_fill_after_insert after insert ON reftank.fill FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('idx',':',ifnull(NEW.idx,'null')), concat('serial_number',':',ifnull(NEW.serial_number,'null')), concat('date',':',ifnull(NEW.date,'null')), concat('code',':',ifnull(NEW.code,'null')), concat('location',':',ifnull(NEW.location,'null')), concat('method',':',ifnull(NEW.method,'null')), concat('type',':',ifnull(NEW.type,'null')), concat('h2o',':',ifnull(NEW.h2o,'null')), concat('notes',':',ifnull(NEW.notes,'null'))),'reftank','fill',new.idx;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_fill_after_update after update ON reftank.fill FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.idx <> OLD.idx, concat('idx(Old:',OLD.idx,' New:',NEW.idx,')'), NULL), IF(NEW.serial_number <> OLD.serial_number, concat('serial_number(Old:',OLD.serial_number,' New:',NEW.serial_number,')'), NULL), IF(NEW.date <> OLD.date, concat('date(Old:',OLD.date,' New:',NEW.date,')'), NULL), IF(NEW.code <> OLD.code, concat('code(Old:',OLD.code,' New:',NEW.code,')'), NULL), IF(NEW.location <> OLD.location, concat('location(Old:',OLD.location,' New:',NEW.location,')'), NULL), IF(NEW.method <> OLD.method, concat('method(Old:',OLD.method,' New:',NEW.method,')'), NULL), IF(NEW.type <> OLD.type, concat('type(Old:',OLD.type,' New:',NEW.type,')'), NULL), IF(NEW.h2o <> OLD.h2o, concat('h2o(Old:',OLD.h2o,' New:',NEW.h2o,')'), NULL), IF(NEW.notes <> OLD.notes, concat('notes(Old:',OLD.notes,' New:',NEW.notes,')'), NULL)),'reftank', 'fill',new.idx;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank._auditlog_fill_before_delete before delete ON reftank.fill FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('idx',':',ifnull(OLD.idx,'null')), concat('serial_number',':',ifnull(OLD.serial_number,'null')), concat('date',':',ifnull(OLD.date,'null')), concat('code',':',ifnull(OLD.code,'null')), concat('location',':',ifnull(OLD.location,'null')), concat('method',':',ifnull(OLD.method,'null')), concat('type',':',ifnull(OLD.type,'null')), concat('h2o',':',ifnull(OLD.h2o,'null')), concat('notes',':',ifnull(OLD.notes,'null'))),'reftank', 'fill',old.idx;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `fill_20200507`
--

DROP TABLE IF EXISTS `fill_20200507`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fill_20200507` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(11) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `code` varchar(5) NOT NULL DEFAULT '',
  `location` varchar(40) DEFAULT NULL,
  `method` varchar(40) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `h2o` float DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`idx`),
  KEY `cyl_code_date` (`serial_number`,`code`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=11278 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
-- Table structure for table `flask_data_h2_x1996`
--

DROP TABLE IF EXISTS `flask_data_h2_x1996`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flask_data_h2_x1996` (
  `num` int(10) unsigned NOT NULL DEFAULT 0,
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
  `creation_datetime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
-- Table structure for table `h2_scale_assignments_20211108`
--

DROP TABLE IF EXISTS `h2_scale_assignments_20211108`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `h2_scale_assignments_20211108` (
  `num` int(11) NOT NULL DEFAULT 0,
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
  `comment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `owner`
--

DROP TABLE IF EXISTS `owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `owner` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `organization` varchar(80) NOT NULL DEFAULT '',
  `name` varchar(40) NOT NULL DEFAULT '',
  `address` varchar(80) NOT NULL DEFAULT '',
  `phone` varchar(20) NOT NULL DEFAULT '',
  `email` varchar(50) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=10104 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
) ENGINE=MyISAM AUTO_INCREMENT=7082 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scale_assignment_calibrations`
--

DROP TABLE IF EXISTS `scale_assignment_calibrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scale_assignment_calibrations` (
  `scale_assignment_num` int(11) NOT NULL,
  `calibrations_idx` int(11) NOT NULL,
  PRIMARY KEY (`scale_assignment_num`,`calibrations_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank.scale_assignments_binsert_trigger before insert on scale_assignments
for each row begin

	
    
	if(new.assign_date='0000-00-00') then 	
        set new.assign_date=now();
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank.scale_assignments_ainsert_trigger after insert on scale_assignments
for each row begin

	
    insert reftank.scale_assignments_history select 'insert',now(),a.* from reftank.scale_assignments a where a.num=new.num;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank.scale_assignments_bupdate_trigger before update on scale_assignments
for each row begin

	
    
    
    if (new.tzero!=old.tzero or new.coef0!=old.coef0 or new.coef1!=old.coef1 or new.coef2!=old.coef2 
		or new.unc_c0!=old.unc_c0  
        or new.unc_c1!=old.unc_c1 or new.unc_c2!=old.unc_c2 
        or new.sd_resid!=old.sd_resid 
        or new.standard_unc!=old.standard_unc or new.level!=old.level
        or new.scale_num!=old.scale_num or new.serial_number!=old.serial_number 
		or new.start_date!=old.start_date 
        ) 
	then
	    signal sqlstate '45000' set message_text = "Updates not allowed to maintain history.  Delete, insert new row instead.  If updates required, temporarily disable the before update trigger";
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank.scale_assignments_aupdate_trigger after update on scale_assignments
for each row begin

	
    insert reftank.scale_assignments_history select 'update',now(),a.* from reftank.scale_assignments a where a.num=new.num;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER reftank.scale_assignments_bdel_trigger before delete on scale_assignments
for each row begin
	#log
    insert reftank.scale_assignments_history select 'delete',now(),a.* from reftank.scale_assignments a where a.num=old.num;
    #cascading delete
    delete from scale_assignment_calibrations where scale_assignment_num=old.num;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
-- Table structure for table `scale_assignments_history`
--

DROP TABLE IF EXISTS `scale_assignments_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scale_assignments_history` (
  `action` varchar(45) NOT NULL,
  `action_datetime` varchar(45) NOT NULL,
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
  PRIMARY KEY (`action`,`action_datetime`,`num`),
  KEY `i` (`scale_num`,`serial_number`,`start_date`,`assign_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `tank_gas`
--

DROP TABLE IF EXISTS `tank_gas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tank_gas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `history_id` int(11) NOT NULL,
  `gas` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1534 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
-- Temporary table structure for view `tank_history_fill_view`
--

DROP TABLE IF EXISTS `tank_history_fill_view`;
/*!50001 DROP VIEW IF EXISTS `tank_history_fill_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `tank_history_fill_view` (
  `id` tinyint NOT NULL,
  `site` tinyint NOT NULL,
  `system` tinyint NOT NULL,
  `gas` tinyint NOT NULL,
  `serial_number` tinyint NOT NULL,
  `label` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `mod_date` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `fill_code` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tank_history_old`
--

DROP TABLE IF EXISTS `tank_history_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tank_history_old` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(5) NOT NULL,
  `system` varchar(20) NOT NULL,
  `serial_number` varchar(20) NOT NULL,
  `label` varchar(5) NOT NULL,
  `start_date` datetime NOT NULL,
  `comment` text NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB AUTO_INCREMENT=1371 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='tank usage history';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tankinfo`
--

DROP TABLE IF EXISTS `tankinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tankinfo` (
  `idx` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(25) DEFAULT NULL,
  `hydrotest` date DEFAULT '0000-00-00',
  `valve` varchar(20) DEFAULT NULL,
  `tanksize` varchar(20) DEFAULT NULL,
  `material` varchar(50) DEFAULT NULL,
  `treatment` varchar(50) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=6916 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_fill`
--

DROP TABLE IF EXISTS `test_fill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test_fill` (
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
  KEY `cyl_code_date` (`serial_number`,`code`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=11901 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_grav_stds`
--

DROP TABLE IF EXISTS `test_grav_stds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test_grav_stds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fill_num` int(11) NOT NULL,
  `serial_number` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `project` varchar(100) NOT NULL,
  `notebook` smallint(6) NOT NULL,
  `pages` varchar(50) NOT NULL,
  `prepared_by` varchar(50) NOT NULL,
  `parent` varchar(20) NOT NULL,
  `o2_content` float NOT NULL,
  `calc_mw` float NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=303 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Information on preparation of gravimetric standards';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test_grav_values`
--

DROP TABLE IF EXISTS `test_grav_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test_grav_values` (
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
) ENGINE=MyISAM AUTO_INCREMENT=1169 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmpfill`
--

DROP TABLE IF EXISTS `tmpfill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmpfill` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(15) NOT NULL DEFAULT '0',
  `date` date DEFAULT '0000-00-00',
  `code` varchar(5) NOT NULL DEFAULT '',
  `location` varchar(40) DEFAULT NULL,
  `method` varchar(40) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `h2o` float DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=MyISAM AUTO_INCREMENT=9319 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'reftank'
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
/*!50003 DROP FUNCTION IF EXISTS `f_fuzzyCylMatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_fuzzyCylMatch`(serial_number varchar(25)) RETURNS varchar(255) CHARSET latin1 COLLATE latin1_swedish_ci
    NO SQL
BEGIN
   return case when serial_number='' or serial_number is null then '' else 
	concat('%',TRIM(LEADING '0' FROM TRIM(LEADING '-' FROM REGEXP_REPLACE(serial_number, '^[A-Za-z]+', ''))),'%') end;
   
   end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `f_getFillCode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `f_getFillCode`(v_cylinder_id varchar(20),v_as_of_dt datetime) RETURNS char(1) CHARSET latin1 COLLATE latin1_swedish_ci
begin
        	declare fill char(1);
			set fill=(select max(f1.code) from reftank.fill f1
				where serial_number=v_cylinder_id and f1.date=
					(select max(date) from reftank.fill where date<=v_as_of_dt and serial_number=v_cylinder_id))
                    ;

			return fill;
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
            RETURN 0.02; #jwm - changed from 1.0 7/19 with andy.
         ELSE
            RETURN 0.02; ##jwm - changed 7/19 with andy.. ROUND(0.0004*input_value,1);
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
/*!50003 DROP FUNCTION IF EXISTS `get_tank_assignment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `get_tank_assignment`(v_serial_number varchar(20),v_scale varchar(20),v_datetime datetime, v_as_of_datetime datetime) RETURNS float
begin
        	declare dd float;
            declare val float;

			set dd=tmp.f_dt2dec(v_datetime);
			set val=(select
				case when tzero=0 then coef0
					else coef0+(coef1*(dd-tzero))+(coef2*pow((dd-tzero),2))
				end
			from reftank.scale_assignments a join reftank.scales s on s.idx=a.scale_num
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
/*!50003 DROP FUNCTION IF EXISTS `get_tank_assignment2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` FUNCTION `get_tank_assignment2`(v_serial_number varchar(20),v_parameter_num int,v_datetime datetime) RETURNS float
begin
	/*Wrapper for below that accepts parameter_num instead of scale. 
    Returns the drift corrected assigned value for v_serial_number on current scale for v_parameter at v_datetime.  
    v_datetime can be passed as now() to get current assigned value.
    Returns null if the tank has been refilled and no new assignment made yet or if no assignment available for pass date.
    */
    
	declare scale_name varchar(20);
    set scale_name=(select name from scales where parameter_num=v_parameter_num and current=1);
    return get_tank_assignment(v_serial_number,scale_name,v_datetime,now());
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reftank_cal_episodes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `reftank_cal_episodes`()
begin
	#creates output table t_cal_episodes for each unique inst, sn, fillcode, species measurement episode (60 days average)
	declare done int default false;
	declare v_inst,v_serial_number,v_fill_code,v_species,v_series,v_seriesnew varchar(50) default '';
	declare v_i ,v_x int default 0;
	declare v_targetDate,v_date date default '1900-01-01';
	declare cur cursor for #iterator to loop through all entries
		select serial_number,inst, fill_code, species,date
		from reftank.calibrations_fill_view c
        where c.flag='.' and c.method!='mano' and c.mixratio>-999
		order by serial_number,inst, fill_code, species,date;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	#temp tables for working with..
	drop temporary table if exists t_cal1,t_cal_episodes;
	create temporary table t_cal1 (index i(serial_number, inst, fill_code, species,date)) as
		select c.* from  reftank.calibrations_fill_view c
			where c.flag='.' and c.method!='mano' and c.mixratio>-999 ;
	create temporary table t_cal_episodes (index i(series,episode_num))as select concat(v_serial_number,'-',v_inst,'-',v_fill_code,'-',v_species) as series, date as episode_start_date, date as episode_end_date,1 as episode_num,
		c.serial_number,c.inst,c.species,c.fill_code,mixratio as avg_mix_ratio, stddev as avg_std_dev, 1 as n, pressure as min_pressure
		from reftank.calibrations_fill_view c where 1=0;
	#start loop
	open cur;
	read_loop: LOOP
		fetch cur into v_serial_number,v_inst,v_fill_code,v_species,v_date;

        if done then LEAVE read_loop;	end if;

		set v_seriesnew=concat(v_serial_number,'-',v_inst,'-',v_fill_code,'-',v_species);
		if v_series!=v_seriesnew or abs(datediff(v_targetDate,v_date))>60 then
			if v_series!=v_seriesnew then
				set v_i=1;
                set v_series=v_seriesnew;
			else
				set v_i=v_i+1;
			end if;

			set v_targetDate=v_date; #new episode start date

			insert t_cal_episodes #select v_series, v_targetDate,v_date , v_i,v_serial_number, v_inst, v_species, v_fill_code,-999,-999,-999;
			 select v_series,
				min(c.date) as episode_start_date,
				max(c.date) as episode_end_date,
				v_i,
				 c.serial_number,c.inst,c.species,c.fill_code,
				avg(c.mixratio) as avg_mixratio,
				avg(c.stddev) as avg_stddev,
				count(c.mixratio) as n,
                min(c.pressure) as min_pressure
			from t_cal1 c
			where  c.serial_number=v_serial_number and c.inst=v_inst and c.fill_code=v_fill_code and c.species=v_species and abs(datediff(c.date,v_date))<61 and c.date>=v_date
			group by c.serial_number,c.inst,c.fill_code,c.species;

			set v_x=v_x+1;
            if mod(v_x,10000)=0 then select v_x; end if;
		end if;


		#
	END LOOP;
	close cur;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reftank_copy_scale_to_test` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`gmduser`@`%.cmdl.noaa.gov` PROCEDURE `reftank_copy_scale_to_test`(v_from_scale_name varchar(30), v_in_test_env_num int)
begin
	/*Copies all v_from_scale_name entries from reftank.scale_assignments to cal_scale_tests[in_test_env_num].scale_assignments.  
    Scale name is set to [v_from_scale_name]_test
    If that scale exists, all entries are removed first. 
    currently, in_test_env_num can be 1 or 2
    */
    declare vnew_scale_name varchar(255) default '';#concat(v_from_scale_name,'_Test');
    declare vtest_scale_num int default 0;
    if (select count(*) from reftank.scales where name= v_from_scale_name)=0 then
		select "unknown scale",v_from_scale_name;
	else
		#We've interated on scale name to work with existing code, this is latest try.
		select concat(species,'_Test') into vnew_scale_name from reftank.scales where name=v_from_scale_name;
        
		if v_in_test_env_num = 1 then
			#see if scale exists
			select idx into vtest_scale_num from cal_scale_tests.scales where name=vnew_scale_name;
			#create if needed
			if vtest_scale_num is null or vtest_scale_num=0 then 
				insert cal_scale_tests.scales (parameter_num, species,name) select parameter_num, species,vnew_scale_name from reftank.scales where name=v_from_scale_name;
				select idx into vtest_scale_num from cal_scale_tests.scales where name=vnew_scale_name;
			end if;
			#remove any previous entries
			delete from cal_scale_tests.scale_assignments where scale_num=vtest_scale_num;
            #Do response curve too to get flagged entries
            delete from cal_scale_tests.response where scale_num=vtest_scale_num;#remove any there
			#copy in entries from reftank
			insert cal_scale_tests.scale_assignments (scale_num,serial_number, start_date,tzero,coef0,coef1,coef2,unc_c0,unc_c1,unc_c2,sd_resid,standard_unc,level,assign_date,comment,n)
			select vtest_scale_num,a.serial_number, a.start_date,tzero,coef0,coef1,coef2,unc_c0,unc_c1,unc_c2,sd_resid,standard_unc,level,assign_date,a.comment,a.n
			from reftank.scale_assignments a join reftank.scales s on s.idx=a.scale_num where s.name=v_from_scale_name;
			
            insert cal_scale_tests.response (site, parameter_num,filename,inst_id, `system`,scale_num,start_date, start_date_id,flag,comment, analysis_date, covar)#we expect user to reprocess and fillin others
			select r.site, r.parameter_num,r.filename,r.inst_id, r.`system`,vtest_scale_num,r.start_date, r.start_date_id , r.flag,r.comment, r.analysis_date,'0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0'
            from reftank.response r join reftank.scales s on s.idx=r.scale_num where s.name=v_from_scale_name;
            
		elseif v_in_test_env_num=2 then 
			#see if scale exists
			select idx into vtest_scale_num from cal_scale_tests2.scales where name=vnew_scale_name;
			#create if needed
			if vtest_scale_num is null or vtest_scale_num=0 then 
				insert cal_scale_tests2.scales (parameter_num, species,name) select parameter_num, species,vnew_scale_name from reftank.scales where name=v_from_scale_name;
				select idx into vtest_scale_num from cal_scale_tests2.scales where name=vnew_scale_name;
			end if;
			#remove any previous entries
			delete from cal_scale_tests2.scale_assignments where scale_num=vtest_scale_num;
			#Do response curve too to get flagged entries
            delete from cal_scale_tests2.response where scale_num=vtest_scale_num;#remove any there
			#copy in entries from reftank
			insert cal_scale_tests2.scale_assignments (scale_num,serial_number, start_date,tzero,coef0,coef1,coef2,unc_c0,unc_c1,unc_c2,sd_resid,standard_unc,level,assign_date,comment,n)
			select vtest_scale_num,a.serial_number, a.start_date,tzero,coef0,coef1,coef2,unc_c0,unc_c1,unc_c2,sd_resid,standard_unc,level,assign_date,a.comment,a.n
			from reftank.scale_assignments a join reftank.scales s on s.idx=a.scale_num where s.name=v_from_scale_name;
            
            insert cal_scale_tests2.response (site, parameter_num,filename,inst_id, `system`,scale_num,start_date, start_date_id,flag,comment,analysis_date,covar)#we expect user to reprocess and fillin others
			select r.site, r.parameter_num,r.filename,r.inst_id, r.`system`,vtest_scale_num,r.start_date, r.start_date_id, r.flag,r.comment,r.analysis_date,'0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0'
            from reftank.response r join reftank.scales s on s.idx=r.scale_num where s.name=v_from_scale_name;
		else
			select 'invalid test env num',v_in_test_env_num;
		end if;
	end if;
    
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `calibrations_export_view`
--

/*!50001 DROP TABLE IF EXISTS `calibrations_export_view`*/;
/*!50001 DROP VIEW IF EXISTS `calibrations_export_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`gmduser`@`%.cmdl.noaa.gov` SQL SECURITY DEFINER */
/*!50001 VIEW `calibrations_export_view` AS select `c`.`serial_number` AS `serial_number`,timestamp(`c`.`date`,`c`.`time`) AS `datetime`,`c`.`species` AS `species`,`s`.`name` AS `scale`,`c`.`mixratio` AS `value`,`c`.`meas_unc` AS `meas_unc`,`c`.`stddev` AS `stddev`,`c`.`num` AS `n`,`c`.`method` AS `method`,`c`.`inst` AS `inst`,`c`.`system` AS `system`,`c`.`pressure` AS `pressure`,`c`.`flag` AS `flag`,`c`.`location` AS `location`,`c`.`regulator` AS `regulator`,`c`.`fill_code` AS `fill_code`,`c`.`fill_date` AS `fill_date`,`c`.`notes` AS `notes` from (`calibrations_fill_view` `c` left join `scales` `s` on(`s`.`idx` = `c`.`scale_num`)) where `c`.`serial_number` <> '' order by `c`.`serial_number`,`c`.`fill_code`,timestamp(`c`.`date`,`c`.`time`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

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
/*!50001 VIEW `calibrations_fill_view` AS select `c1`.`idx` AS `idx`,`c1`.`serial_number` AS `serial_number`,`c1`.`date` AS `date`,`c1`.`time` AS `time`,`c1`.`species` AS `species`,`c1`.`mixratio` AS `mixratio`,`c1`.`stddev` AS `stddev`,`c1`.`num` AS `num`,`c1`.`method` AS `method`,`c1`.`inst` AS `inst`,`c1`.`system` AS `system`,`c1`.`pressure` AS `pressure`,`c1`.`flag` AS `flag`,`c1`.`location` AS `location`,`c1`.`regulator` AS `regulator`,`c1`.`notes` AS `notes`,`c1`.`mod_date` AS `mod_date`,`c1`.`meas_unc` AS `meas_unc`,`c1`.`scale_num` AS `scale_num`,`c1`.`parameter_num` AS `parameter_num`,`c1`.`run_number` AS `run_number`,(select max(`f1`.`code`) from `fill` `f1` where `f1`.`serial_number` = `c1`.`serial_number` and `f1`.`date` = (select max(`fill`.`date`) from `fill` where `fill`.`date` <= `c1`.`date` and `fill`.`serial_number` = `c1`.`serial_number`)) AS `fill_code`,(select max(`fill`.`date`) from `fill` where `fill`.`date` <= `c1`.`date` and `fill`.`serial_number` = `c1`.`serial_number`) AS `fill_date` from `calibrations` `c1` */;
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
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
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
/*!50001 VIEW `scale_assignments_view` AS select `s`.`name` AS `scale`,`s`.`idx` AS `scale_num`,`s`.`species` AS `species`,`a`.`serial_number` AS `serial_number`,`f`.`fill_code` AS `fill_code`,`a`.`start_date` AS `start_date`,case when ifnull((select min(`a4`.`start_date`) from `reftank`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) = '9999-12-31' then '9999-12-31' else ifnull((select min(`a4`.`start_date`) from `reftank`.`scale_assignments` `a4` where `a`.`scale_num` = `a4`.`scale_num` and `a`.`serial_number` = `a4`.`serial_number` and `a4`.`start_date` > `a`.`start_date` and `a4`.`start_date` < `f`.`next_fill_date`),`f`.`next_fill_date`) + interval -1 day end AS `end_date`,`f`.`next_fill_date` AS `next_fill_date`,`a`.`assign_date` AS `assign_date`,case when `c`.`scale_num` is not null then 1 else 0 end AS `current_assignment`,`a`.`tzero` AS `tzero`,`a`.`coef0` AS `coef0`,`a`.`coef1` AS `coef1`,`a`.`coef2` AS `coef2`,`a`.`unc_c0` AS `unc_c0`,`a`.`unc_c1` AS `unc_c1`,`a`.`unc_c2` AS `unc_c2`,`a`.`sd_resid` AS `sd_resid`,`a`.`standard_unc` AS `standard_unc`,`a`.`level` AS `level`,`a`.`comment` AS `comment`,`p`.`num` AS `parameter_num`,`a`.`num` AS `scale_assignment_num`,`s`.`current` AS `current_scale`,`a`.`n` AS `n` from ((((`reftank`.`scale_assignments` `a` join `reftank`.`scales` `s` on(`s`.`idx` = `a`.`scale_num`)) join `gmd`.`parameter` `p` on(`p`.`formula` = `s`.`species`)) join `reftank`.`scale_assignments_fill` `f` on(`f`.`serial_number` = `a`.`serial_number` and `f`.`start_date` = `a`.`start_date`)) left join `reftank`.`current_scale_assignments_view` `c` on(`a`.`scale_num` = `c`.`scale_num` and `a`.`serial_number` = `c`.`serial_number` and `a`.`start_date` = `c`.`start_date` and `a`.`assign_date` = `c`.`assign_date`)) order by `s`.`name`,`a`.`serial_number`,`a`.`start_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tank_history_fill_view`
--

/*!50001 DROP TABLE IF EXISTS `tank_history_fill_view`*/;
/*!50001 DROP VIEW IF EXISTS `tank_history_fill_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tank_history_fill_view` AS select `c1`.`id` AS `id`,`c1`.`site` AS `site`,`c1`.`system` AS `system`,`c1`.`gas` AS `gas`,`c1`.`serial_number` AS `serial_number`,`c1`.`label` AS `label`,`c1`.`start_date` AS `start_date`,`c1`.`mod_date` AS `mod_date`,`c1`.`comment` AS `comment`,(select max(`f1`.`code`) from `fill` `f1` where `f1`.`serial_number` = `c1`.`serial_number` and `f1`.`date` = (select max(`fill`.`date`) from `fill` where `fill`.`date` <= `c1`.`start_date` and `fill`.`serial_number` = `c1`.`serial_number`)) AS `fill_code` from `tank_history` `c1` */;
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

-- Dump completed on 2025-04-17 10:10:38
