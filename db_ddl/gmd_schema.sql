-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: db-int2    Database: gmd
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
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `database` varchar(255) NOT NULL,
  `table_name` varchar(255) NOT NULL,
  `pkey` int(11) NOT NULL,
  `action` varchar(45) NOT NULL,
  `action_datetime` datetime NOT NULL,
  `action_user` varchar(255) NOT NULL,
  `columns_values` text NOT NULL,
  PRIMARY KEY (`num`),
  KEY `i1` (`database`,`table_name`,`pkey`),
  KEY `i2` (`database`,`table_name`,`action_datetime`)
) ENGINE=InnoDB AUTO_INCREMENT=1508513 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB AUTO_INCREMENT=332 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='log of changes made with dbedit';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_summary`
--

DROP TABLE IF EXISTS `data_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_summary` (
  `site_num` smallint(5) unsigned NOT NULL DEFAULT 0,
  `parameter_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `project_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `program_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `strategy_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status_num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `first` date NOT NULL DEFAULT '0000-00-00',
  `last` date NOT NULL DEFAULT '0000-00-00',
  `count` mediumint(8) NOT NULL DEFAULT 0,
  `prelim_start` date NOT NULL,
  `prelim_end` date NOT NULL,
  KEY `slg` (`site_num`,`parameter_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `date` date NOT NULL,
  `url` varchar(255) NOT NULL,
  `abstract` text NOT NULL,
  `tags` text NOT NULL,
  `image` varchar(250) NOT NULL,
  `internal` tinyint(1) NOT NULL DEFAULT 0,
  `highlight` tinyint(1) NOT NULL,
  `category` enum('news','publication','','') NOT NULL DEFAULT 'news',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=202 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parameter`
--

DROP TABLE IF EXISTS `parameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameter` (
  `num` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `formula` varchar(20) NOT NULL,
  `name` varchar(60) NOT NULL DEFAULT '',
  `unit` varchar(30) NOT NULL DEFAULT '',
  `unit_name` varchar(40) NOT NULL DEFAULT '',
  `formula_html` varchar(100) NOT NULL DEFAULT '',
  `unit_html` varchar(100) NOT NULL DEFAULT '',
  `formula_idl` varchar(100) NOT NULL DEFAULT '',
  `unit_idl` varchar(100) NOT NULL DEFAULT '',
  `formula_matplotlib` varchar(100) NOT NULL,
  `unit_matplotlib` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `old_formula` varchar(20) DEFAULT '',
  `iupac_name` varchar(100) DEFAULT '',
  `other_names` varchar(100) DEFAULT '',
  `chemical_formula` varchar(100) DEFAULT '',
  `sources` varchar(100) DEFAULT '',
  PRIMARY KEY (`num`),
  KEY `i` (`formula`)
) ENGINE=MyISAM AUTO_INCREMENT=182 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_parameter_after_insert after insert ON gmd.parameter FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('formula',':',ifnull(NEW.formula,'null')), concat('name',':',ifnull(NEW.name,'null')), concat('unit',':',ifnull(NEW.unit,'null')), concat('unit_name',':',ifnull(NEW.unit_name,'null')), concat('formula_html',':',ifnull(NEW.formula_html,'null')), concat('unit_html',':',ifnull(NEW.unit_html,'null')), concat('formula_idl',':',ifnull(NEW.formula_idl,'null')), concat('unit_idl',':',ifnull(NEW.unit_idl,'null')), concat('formula_matplotlib',':',ifnull(NEW.formula_matplotlib,'null')), concat('unit_matplotlib',':',ifnull(NEW.unit_matplotlib,'null')), concat('description',':',ifnull(NEW.description,'null')), concat('old_formula',':',ifnull(NEW.old_formula,'null')), concat('iupac_name',':',ifnull(NEW.iupac_name,'null')), concat('other_names',':',ifnull(NEW.other_names,'null')), concat('chemical_formula',':',ifnull(NEW.chemical_formula,'null')), concat('sources',':',ifnull(NEW.sources,'null'))),'gmd','parameter',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_parameter_after_update after update ON gmd.parameter FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.formula <> OLD.formula, concat('formula(Old:',OLD.formula,' New:',NEW.formula,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL), IF(NEW.unit <> OLD.unit, concat('unit(Old:',OLD.unit,' New:',NEW.unit,')'), NULL), IF(NEW.unit_name <> OLD.unit_name, concat('unit_name(Old:',OLD.unit_name,' New:',NEW.unit_name,')'), NULL), IF(NEW.formula_html <> OLD.formula_html, concat('formula_html(Old:',OLD.formula_html,' New:',NEW.formula_html,')'), NULL), IF(NEW.unit_html <> OLD.unit_html, concat('unit_html(Old:',OLD.unit_html,' New:',NEW.unit_html,')'), NULL), IF(NEW.formula_idl <> OLD.formula_idl, concat('formula_idl(Old:',OLD.formula_idl,' New:',NEW.formula_idl,')'), NULL), IF(NEW.unit_idl <> OLD.unit_idl, concat('unit_idl(Old:',OLD.unit_idl,' New:',NEW.unit_idl,')'), NULL), IF(NEW.formula_matplotlib <> OLD.formula_matplotlib, concat('formula_matplotlib(Old:',OLD.formula_matplotlib,' New:',NEW.formula_matplotlib,')'), NULL), IF(NEW.unit_matplotlib <> OLD.unit_matplotlib, concat('unit_matplotlib(Old:',OLD.unit_matplotlib,' New:',NEW.unit_matplotlib,')'), NULL), IF(NEW.description <> OLD.description, concat('description(Old:',OLD.description,' New:',NEW.description,')'), NULL), IF(NEW.old_formula <> OLD.old_formula, concat('old_formula(Old:',OLD.old_formula,' New:',NEW.old_formula,')'), NULL), IF(NEW.iupac_name <> OLD.iupac_name, concat('iupac_name(Old:',OLD.iupac_name,' New:',NEW.iupac_name,')'), NULL), IF(NEW.other_names <> OLD.other_names, concat('other_names(Old:',OLD.other_names,' New:',NEW.other_names,')'), NULL), IF(NEW.chemical_formula <> OLD.chemical_formula, concat('chemical_formula(Old:',OLD.chemical_formula,' New:',NEW.chemical_formula,')'), NULL), IF(NEW.sources <> OLD.sources, concat('sources(Old:',OLD.sources,' New:',NEW.sources,')'), NULL)),'gmd', 'parameter',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_parameter_before_delete before delete ON gmd.parameter FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('formula',':',ifnull(OLD.formula,'null')), concat('name',':',ifnull(OLD.name,'null')), concat('unit',':',ifnull(OLD.unit,'null')), concat('unit_name',':',ifnull(OLD.unit_name,'null')), concat('formula_html',':',ifnull(OLD.formula_html,'null')), concat('unit_html',':',ifnull(OLD.unit_html,'null')), concat('formula_idl',':',ifnull(OLD.formula_idl,'null')), concat('unit_idl',':',ifnull(OLD.unit_idl,'null')), concat('formula_matplotlib',':',ifnull(OLD.formula_matplotlib,'null')), concat('unit_matplotlib',':',ifnull(OLD.unit_matplotlib,'null')), concat('description',':',ifnull(OLD.description,'null')), concat('old_formula',':',ifnull(OLD.old_formula,'null')), concat('iupac_name',':',ifnull(OLD.iupac_name,'null')), concat('other_names',':',ifnull(OLD.other_names,'null')), concat('chemical_formula',':',ifnull(OLD.chemical_formula,'null')), concat('sources',':',ifnull(OLD.sources,'null'))),'gmd', 'parameter',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `program` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL DEFAULT '',
  `abbr` varchar(40) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
  `program_num` tinyint(4) NOT NULL DEFAULT 0,
  `data_available` tinyint(1) NOT NULL,
  `description` text NOT NULL,
  `url` varchar(50) NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=36 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publications`
--

DROP TABLE IF EXISTS `publications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publications` (
  `eprintid` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `title` longtext DEFAULT NULL,
  `ispublished` varchar(255) DEFAULT NULL,
  `full_text_status` varchar(255) DEFAULT NULL,
  `monograph_type` varchar(255) DEFAULT NULL,
  `pres_type` varchar(255) DEFAULT NULL,
  `keywords` longtext DEFAULT NULL,
  `note` longtext DEFAULT NULL,
  `abstract` longtext DEFAULT NULL,
  `date_year` smallint(6) DEFAULT NULL,
  `date_month` smallint(6) DEFAULT NULL,
  `date_day` smallint(6) DEFAULT NULL,
  `series` varchar(255) DEFAULT NULL,
  `publication` varchar(255) DEFAULT NULL,
  `volume` varchar(6) DEFAULT NULL,
  `number` varchar(6) DEFAULT NULL,
  `publisher` varchar(255) DEFAULT NULL,
  `place_of_pub` varchar(255) DEFAULT NULL,
  `pagerange` varchar(255) DEFAULT NULL,
  `start_page` varchar(20) DEFAULT NULL,
  `end_page` varchar(20) DEFAULT NULL,
  `pages` int(11) DEFAULT NULL,
  `event_title` varchar(255) DEFAULT NULL,
  `event_location` varchar(255) DEFAULT NULL,
  `event_dates` varchar(255) DEFAULT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `id_number` varchar(255) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `refereed` varchar(5) DEFAULT NULL,
  `isbn` varchar(255) DEFAULT NULL,
  `issn` varchar(255) DEFAULT NULL,
  `book_title` varchar(255) DEFAULT NULL,
  `chapter` varchar(255) DEFAULT NULL,
  `official_url` longtext DEFAULT NULL,
  `document` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`eprintid`),
  KEY `eprint_type_1` (`type`),
  KEY `eprint_ispublished_1` (`ispublished`),
  KEY `eprint_full_text_status_1` (`full_text_status`),
  KEY `eprint_monograph_type_1` (`monograph_type`),
  KEY `eprint_pres_type_1` (`pres_type`),
  KEY `eprint_date_year_3` (`date_year`,`date_month`,`date_day`),
  KEY `eprint_event_type_1` (`event_type`),
  KEY `eprint_refereed_1` (`refereed`)
) ENGINE=MyISAM AUTO_INCREMENT=8997 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publications_authors`
--

DROP TABLE IF EXISTS `publications_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publications_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eprintid` int(11) NOT NULL,
  `pos` int(11) NOT NULL COMMENT 'Position in author list',
  `creators_name_family` varchar(64) DEFAULT NULL,
  `creators_name_given` varchar(64) DEFAULT NULL,
  `ismember` tinyint(1) NOT NULL COMMENT 'True if author is part of GMD',
  PRIMARY KEY (`id`),
  KEY `eprint_creators_name_creators_name_family_1` (`creators_name_family`)
) ENGINE=MyISAM AUTO_INCREMENT=35650 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publications_documents`
--

DROP TABLE IF EXISTS `publications_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publications_documents` (
  `docid` int(11) NOT NULL,
  `eprintid` int(11) DEFAULT NULL,
  `format` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `formatdesc` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `main` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`docid`),
  KEY `document_eprintid_1` (`eprintid`),
  KEY `document_format_1` (`format`),
  KEY `document_main_1` (`main`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `seminars`
--

DROP TABLE IF EXISTS `seminars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seminars` (
  `id` mediumint(9) NOT NULL AUTO_INCREMENT,
  `speaker` varchar(100) NOT NULL DEFAULT '',
  `speaker_desc` text NOT NULL,
  `date` date NOT NULL DEFAULT '0000-00-00',
  `time` time NOT NULL,
  `location` text NOT NULL,
  `title` text NOT NULL,
  `abstract` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=79 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site` (
  `num` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(150) NOT NULL DEFAULT '',
  `country` varchar(80) NOT NULL DEFAULT '',
  `lat` decimal(8,4) NOT NULL DEFAULT -99.9999,
  `lon` decimal(8,4) NOT NULL DEFAULT -999.9999,
  `elev` decimal(8,2) NOT NULL DEFAULT -9999.99,
  `lst2utc` decimal(5,1) NOT NULL DEFAULT -99.0,
  `flag` varchar(80) NOT NULL DEFAULT '',
  `URL` varchar(150) DEFAULT NULL,
  `description` text NOT NULL,
  `map_coords` varchar(15) NOT NULL DEFAULT '',
  `galleryURL` varchar(150) DEFAULT NULL,
  `image` varchar(80) NOT NULL DEFAULT '',
  `comments` text NOT NULL,
  PRIMARY KEY (`num`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=1085 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_after_insert after insert ON gmd.site FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('code',':',ifnull(NEW.code,'null')), concat('name',':',ifnull(NEW.name,'null')), concat('country',':',ifnull(NEW.country,'null')), concat('lat',':',ifnull(NEW.lat,'null')), concat('lon',':',ifnull(NEW.lon,'null')), concat('elev',':',ifnull(NEW.elev,'null')), concat('lst2utc',':',ifnull(NEW.lst2utc,'null')), concat('flag',':',ifnull(NEW.flag,'null')), concat('URL',':',ifnull(NEW.URL,'null')), concat('description',':',ifnull(NEW.description,'null')), concat('map_coords',':',ifnull(NEW.map_coords,'null')), concat('galleryURL',':',ifnull(NEW.galleryURL,'null')), concat('image',':',ifnull(NEW.image,'null')), concat('comments',':',ifnull(NEW.comments,'null'))),'gmd','site',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_after_update after update ON gmd.site FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.code <> OLD.code, concat('code(Old:',OLD.code,' New:',NEW.code,')'), NULL), IF(NEW.name <> OLD.name, concat('name(Old:',OLD.name,' New:',NEW.name,')'), NULL), IF(NEW.country <> OLD.country, concat('country(Old:',OLD.country,' New:',NEW.country,')'), NULL), IF(NEW.lat <> OLD.lat, concat('lat(Old:',OLD.lat,' New:',NEW.lat,')'), NULL), IF(NEW.lon <> OLD.lon, concat('lon(Old:',OLD.lon,' New:',NEW.lon,')'), NULL), IF(NEW.elev <> OLD.elev, concat('elev(Old:',OLD.elev,' New:',NEW.elev,')'), NULL), IF(NEW.lst2utc <> OLD.lst2utc, concat('lst2utc(Old:',OLD.lst2utc,' New:',NEW.lst2utc,')'), NULL), IF(NEW.flag <> OLD.flag, concat('flag(Old:',OLD.flag,' New:',NEW.flag,')'), NULL), IF(NEW.URL <> OLD.URL, concat('URL(Old:',OLD.URL,' New:',NEW.URL,')'), NULL), IF(NEW.description <> OLD.description, concat('description(Old:',OLD.description,' New:',NEW.description,')'), NULL), IF(NEW.map_coords <> OLD.map_coords, concat('map_coords(Old:',OLD.map_coords,' New:',NEW.map_coords,')'), NULL), IF(NEW.galleryURL <> OLD.galleryURL, concat('galleryURL(Old:',OLD.galleryURL,' New:',NEW.galleryURL,')'), NULL), IF(NEW.image <> OLD.image, concat('image(Old:',OLD.image,' New:',NEW.image,')'), NULL), IF(NEW.comments <> OLD.comments, concat('comments(Old:',OLD.comments,' New:',NEW.comments,')'), NULL)),'gmd', 'site',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_before_delete before delete ON gmd.site FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('code',':',ifnull(OLD.code,'null')), concat('name',':',ifnull(OLD.name,'null')), concat('country',':',ifnull(OLD.country,'null')), concat('lat',':',ifnull(OLD.lat,'null')), concat('lon',':',ifnull(OLD.lon,'null')), concat('elev',':',ifnull(OLD.elev,'null')), concat('lst2utc',':',ifnull(OLD.lst2utc,'null')), concat('flag',':',ifnull(OLD.flag,'null')), concat('URL',':',ifnull(OLD.URL,'null')), concat('description',':',ifnull(OLD.description,'null')), concat('map_coords',':',ifnull(OLD.map_coords,'null')), concat('galleryURL',':',ifnull(OLD.galleryURL,'null')), concat('image',':',ifnull(OLD.image,'null')), concat('comments',':',ifnull(OLD.comments,'null'))),'gmd', 'site',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `site_contact`
--

DROP TABLE IF EXISTS `site_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT 0,
  `address1` varchar(100) NOT NULL DEFAULT '',
  `address2` varchar(100) NOT NULL DEFAULT '',
  `city` varchar(80) NOT NULL DEFAULT '',
  `state` varchar(50) NOT NULL DEFAULT '',
  `zip` varchar(10) NOT NULL DEFAULT '',
  `country` varchar(80) NOT NULL DEFAULT '',
  `contact_name` varchar(80) NOT NULL DEFAULT '',
  `organization` varchar(80) NOT NULL DEFAULT '',
  `phone` varchar(30) NOT NULL DEFAULT '',
  `fax` varchar(30) NOT NULL DEFAULT '',
  `email` varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_contact_after_insert after insert ON gmd.site_contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('id',':',ifnull(NEW.id,'null')), concat('site_id',':',ifnull(NEW.site_id,'null')), concat('address1',':',ifnull(NEW.address1,'null')), concat('address2',':',ifnull(NEW.address2,'null')), concat('city',':',ifnull(NEW.city,'null')), concat('state',':',ifnull(NEW.state,'null')), concat('zip',':',ifnull(NEW.zip,'null')), concat('country',':',ifnull(NEW.country,'null')), concat('contact_name',':',ifnull(NEW.contact_name,'null')), concat('organization',':',ifnull(NEW.organization,'null')), concat('phone',':',ifnull(NEW.phone,'null')), concat('fax',':',ifnull(NEW.fax,'null')), concat('email',':',ifnull(NEW.email,'null'))),'gmd','site_contact',new.id;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_contact_after_update after update ON gmd.site_contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.id <> OLD.id, concat('id(Old:',OLD.id,' New:',NEW.id,')'), NULL), IF(NEW.site_id <> OLD.site_id, concat('site_id(Old:',OLD.site_id,' New:',NEW.site_id,')'), NULL), IF(NEW.address1 <> OLD.address1, concat('address1(Old:',OLD.address1,' New:',NEW.address1,')'), NULL), IF(NEW.address2 <> OLD.address2, concat('address2(Old:',OLD.address2,' New:',NEW.address2,')'), NULL), IF(NEW.city <> OLD.city, concat('city(Old:',OLD.city,' New:',NEW.city,')'), NULL), IF(NEW.state <> OLD.state, concat('state(Old:',OLD.state,' New:',NEW.state,')'), NULL), IF(NEW.zip <> OLD.zip, concat('zip(Old:',OLD.zip,' New:',NEW.zip,')'), NULL), IF(NEW.country <> OLD.country, concat('country(Old:',OLD.country,' New:',NEW.country,')'), NULL), IF(NEW.contact_name <> OLD.contact_name, concat('contact_name(Old:',OLD.contact_name,' New:',NEW.contact_name,')'), NULL), IF(NEW.organization <> OLD.organization, concat('organization(Old:',OLD.organization,' New:',NEW.organization,')'), NULL), IF(NEW.phone <> OLD.phone, concat('phone(Old:',OLD.phone,' New:',NEW.phone,')'), NULL), IF(NEW.fax <> OLD.fax, concat('fax(Old:',OLD.fax,' New:',NEW.fax,')'), NULL), IF(NEW.email <> OLD.email, concat('email(Old:',OLD.email,' New:',NEW.email,')'), NULL)),'gmd', 'site_contact',new.id;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_contact_before_delete before delete ON gmd.site_contact FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('id',':',ifnull(OLD.id,'null')), concat('site_id',':',ifnull(OLD.site_id,'null')), concat('address1',':',ifnull(OLD.address1,'null')), concat('address2',':',ifnull(OLD.address2,'null')), concat('city',':',ifnull(OLD.city,'null')), concat('state',':',ifnull(OLD.state,'null')), concat('zip',':',ifnull(OLD.zip,'null')), concat('country',':',ifnull(OLD.country,'null')), concat('contact_name',':',ifnull(OLD.contact_name,'null')), concat('organization',':',ifnull(OLD.organization,'null')), concat('phone',':',ifnull(OLD.phone,'null')), concat('fax',':',ifnull(OLD.fax,'null')), concat('email',':',ifnull(OLD.email,'null'))),'gmd', 'site_contact',old.id;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `site_coop`
--

DROP TABLE IF EXISTS `site_coop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_coop` (
  `site_num` int(10) unsigned NOT NULL DEFAULT 0,
  `project_num` int(10) unsigned NOT NULL DEFAULT 0,
  `name` varchar(200) NOT NULL,
  `url` varchar(200) NOT NULL DEFAULT '',
  `logo` varchar(150) NOT NULL,
  `description` blob DEFAULT NULL,
  KEY `site_num` (`site_num`,`project_num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_project`
--

DROP TABLE IF EXISTS `site_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_project` (
  `num` int(11) NOT NULL AUTO_INCREMENT,
  `site_num` int(10) unsigned DEFAULT NULL,
  `project_num` int(10) unsigned DEFAULT NULL,
  `status_num` int(10) unsigned DEFAULT NULL,
  `iadv` tinyint(1) NOT NULL DEFAULT 1,
  `description` text NOT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=709 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_project_after_insert after insert ON gmd.site_project FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'insert', concat_ws(', ',concat('num',':',ifnull(NEW.num,'null')), concat('site_num',':',ifnull(NEW.site_num,'null')), concat('project_num',':',ifnull(NEW.project_num,'null')), concat('status_num',':',ifnull(NEW.status_num,'null')), concat('iadv',':',ifnull(NEW.iadv,'null')), concat('description',':',ifnull(NEW.description,'null'))),'gmd','site_project',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_project_after_update after update ON gmd.site_project FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'update', CONCAT_WS(', ', IF(NEW.num <> OLD.num, concat('num(Old:',OLD.num,' New:',NEW.num,')'), NULL), IF(NEW.site_num <> OLD.site_num, concat('site_num(Old:',OLD.site_num,' New:',NEW.site_num,')'), NULL), IF(NEW.project_num <> OLD.project_num, concat('project_num(Old:',OLD.project_num,' New:',NEW.project_num,')'), NULL), IF(NEW.status_num <> OLD.status_num, concat('status_num(Old:',OLD.status_num,' New:',NEW.status_num,')'), NULL), IF(NEW.iadv <> OLD.iadv, concat('iadv(Old:',OLD.iadv,' New:',NEW.iadv,')'), NULL), IF(NEW.description <> OLD.description, concat('description(Old:',OLD.description,' New:',NEW.description,')'), NULL)),'gmd', 'site_project',new.num;

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
/*!50003 CREATE*/ /*!50017 DEFINER=`gmduser`@`%.cmdl.noaa.gov`*/ /*!50003 TRIGGER gmd._auditlog_site_project_before_delete before delete ON gmd.site_project FOR EACH ROW

    BEGIN

        INSERT INTO gmd.audit_log (action_datetime, action_user, action, columns_values, `database`, table_name,pkey)
                      select now(), USER(), 'delete', concat_ws(', ',concat('num',':',ifnull(OLD.num,'null')), concat('site_num',':',ifnull(OLD.site_num,'null')), concat('project_num',':',ifnull(OLD.project_num,'null')), concat('status_num',':',ifnull(OLD.status_num,'null')), concat('iadv',':',ifnull(OLD.iadv,'null')), concat('description',':',ifnull(OLD.description,'null'))),'gmd', 'site_project',old.num;

    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `status` (
  `num` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `name` varchar(80) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'gmd'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-17 10:08:22
