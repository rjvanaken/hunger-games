-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: hunger_games
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `district`
--

DROP TABLE IF EXISTS `district`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `district` (
  `district_num` int NOT NULL,
  `industry` varchar(64) DEFAULT NULL,
  `size` enum('Small','Medium','Large') DEFAULT NULL,
  `wealth` enum('Poor','Working Class','Middle Class','Wealthy') DEFAULT NULL,
  PRIMARY KEY (`district_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `district`
--

LOCK TABLES `district` WRITE;
/*!40000 ALTER TABLE `district` DISABLE KEYS */;
INSERT INTO `district` VALUES (1,'Luxury','Medium','Wealthy'),(2,'Masonry','Large','Wealthy'),(3,'Technology','Large','Middle Class'),(4,'Fishing','Medium','Wealthy'),(5,'Power','Small','Working Class'),(6,'Transportation','Large','Working Class'),(7,'Lumber','Medium','Working Class'),(8,'Textiles','Medium','Poor'),(9,'Grain','Medium','Working Class'),(10,'Livestock','Medium','Working Class'),(11,'Agriculture','Large','Poor'),(12,'Coal Mining','Small','Poor');
/*!40000 ALTER TABLE `district` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game`
--

DROP TABLE IF EXISTS `game`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game` (
  `game_number` int NOT NULL,
  `required_tribute_count` int NOT NULL DEFAULT '24',
  `game_status` enum('planned','in progress','completed') DEFAULT 'planned',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`game_number`),
  CONSTRAINT `check_negative_tributes` CHECK ((`required_tribute_count` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game`
--

LOCK TABLES `game` WRITE;
/*!40000 ALTER TABLE `game` DISABLE KEYS */;
INSERT INTO `game` VALUES (10,24,'planned','0028-07-11',NULL),(11,24,'planned','0029-07-11',NULL),(34,24,'planned','0052-07-11',NULL),(49,24,'planned','0067-07-11',NULL),(50,48,'planned','0068-07-11',NULL),(62,24,'planned','0080-07-11',NULL),(63,24,'planned','0081-07-11',NULL),(64,24,'planned','0082-07-11',NULL),(65,24,'planned','0083-07-11',NULL),(70,24,'planned','0088-07-11',NULL),(71,24,'planned','0089-07-11',NULL),(74,24,'planned','0092-07-11',NULL),(75,24,'planned','0093-07-11',NULL);
/*!40000 ALTER TABLE `game` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_game_start_date` BEFORE INSERT ON `game` FOR EACH ROW BEGIN

	DECLARE base_year INT DEFAULT 0018; -- end of rebellion, first games in 19
    DECLARE game_year INT;
    
    SET game_year = base_year + NEW.game_number;

	IF NEW.start_date IS NULL THEN
		SET NEW.start_date = CAST(CONCAT(LPAD(game_year, 4, '0'), '-07-11') AS DATE);
	END IF;
    
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `game_creator`
--

DROP TABLE IF EXISTS `game_creator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_creator` (
  `gamemaker_id` int NOT NULL,
  `game_number` int NOT NULL,
  PRIMARY KEY (`game_number`,`gamemaker_id`),
  KEY `gamemaker_id` (`gamemaker_id`),
  CONSTRAINT `game_creator_ibfk_1` FOREIGN KEY (`game_number`) REFERENCES `game` (`game_number`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `game_creator_ibfk_2` FOREIGN KEY (`gamemaker_id`) REFERENCES `gamemaker` (`gamemaker_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game_creator`
--

LOCK TABLES `game_creator` WRITE;
/*!40000 ALTER TABLE `game_creator` DISABLE KEYS */;
INSERT INTO `game_creator` VALUES (1,75),(2,71),(2,74),(4,10),(4,11),(4,71),(4,74),(6,50),(6,64),(6,71),(7,50),(7,64),(7,71),(9,50),(9,64),(10,50),(10,64),(12,64),(12,65),(12,74),(13,65),(13,74),(14,34),(14,62),(14,65),(14,74),(15,34),(15,62),(15,65),(16,34),(16,62),(16,65),(17,34),(17,62),(18,62),(18,70),(19,70),(20,49),(20,63),(20,70),(20,75),(21,49),(21,63),(21,70),(21,75),(22,49),(22,50),(22,63),(22,70),(22,75),(23,49),(23,63),(23,75),(24,49),(24,63),(25,71);
/*!40000 ALTER TABLE `game_creator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game_victor`
--

DROP TABLE IF EXISTS `game_victor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_victor` (
  `victor_id` int NOT NULL,
  `game_number` int NOT NULL,
  PRIMARY KEY (`victor_id`,`game_number`),
  KEY `game_number` (`game_number`),
  CONSTRAINT `game_victor_ibfk_1` FOREIGN KEY (`victor_id`) REFERENCES `victor` (`victor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `game_victor_ibfk_2` FOREIGN KEY (`game_number`) REFERENCES `game` (`game_number`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game_victor`
--

LOCK TABLES `game_victor` WRITE;
/*!40000 ALTER TABLE `game_victor` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_victor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamemaker`
--

DROP TABLE IF EXISTS `gamemaker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gamemaker` (
  `gamemaker_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`gamemaker_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gamemaker`
--

LOCK TABLES `gamemaker` WRITE;
/*!40000 ALTER TABLE `gamemaker` DISABLE KEYS */;
INSERT INTO `gamemaker` VALUES (1,'Plutarch Heavensbee'),(2,'Seneca Crane'),(3,'Lucia'),(4,'Dr. Volumina Gaul'),(5,'Joe Shmoe'),(6,'Heaven Heavensbee'),(7,'Grapefruit Cornelius'),(8,'Coriolanus Snow'),(9,'Fabricius Lavish'),(10,'Octavia Glimmerstone'),(11,'Aurelius Grandeur'),(12,'Celestia Ravencrest'),(13,'Magnus Silverworth'),(14,'Persephone Nightshade'),(15,'Tiberius Goldleaf'),(16,'Lavinia Crystalline'),(17,'Maximus Opulence'),(18,'Seraphina Moonwhisper'),(19,'Claudius Velvetine'),(20,'Anastasia Starling'),(21,'Cassius Brightwell'),(22,'Temperance Frostbane'),(23,'Valentino Luxor'),(24,'Cordelia Ashworth'),(25,'Dominic Regalia'),(26,'Evangeline Silkwood'),(27,'Augustus Primerose'),(28,'Calliope Wintermere'),(29,'Marcellus Thornwick'),(30,'Isadora Gemstone'),(31,'Thaddeus Brightvale'),(32,'Ophelia Crystalheart'),(33,'Reginald Goldsworth');
/*!40000 ALTER TABLE `gamemaker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamemaker_score`
--

DROP TABLE IF EXISTS `gamemaker_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gamemaker_score` (
  `gamemaker_id` int NOT NULL,
  `participant_id` varchar(64) NOT NULL,
  `assessment_score` int DEFAULT NULL,
  PRIMARY KEY (`gamemaker_id`,`participant_id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `gamemaker_score_ibfk_1` FOREIGN KEY (`gamemaker_id`) REFERENCES `gamemaker` (`gamemaker_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `gamemaker_score_ibfk_2` FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `check_assessment` CHECK ((`assessment_score` between 1 and 12))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gamemaker_score`
--

LOCK TABLES `gamemaker_score` WRITE;
/*!40000 ALTER TABLE `gamemaker_score` DISABLE KEYS */;
INSERT INTO `gamemaker_score` VALUES (1,'10.1.F.1',8),(1,'10.1.M.1',10),(1,'10.10.F.1',2),(1,'10.10.M.1',8),(1,'10.11.F.1',1),(1,'10.11.M.1',9),(1,'10.12.F.1',10),(1,'10.12.M.1',6),(1,'10.2.F.1',9),(1,'10.2.M.1',8),(1,'10.3.F.1',7),(1,'10.3.M.1',6),(1,'10.4.F.1',10),(1,'10.4.M.1',11),(1,'10.5.F.1',7),(1,'10.5.M.1',8),(1,'10.6.F.1',9),(1,'10.6.M.1',5),(1,'10.7.F.1',2),(1,'10.7.M.1',11),(1,'10.8.F.1',9),(1,'10.8.M.1',9),(1,'10.9.F.1',4),(1,'10.9.M.1',5),(1,'11.4.F.1',7),(3,'71.7.F.1',10),(3,'74.1.F.1',8),(3,'74.1.M.1',8),(3,'74.11.F.1',5),(3,'74.11.M.1',7),(3,'74.12.F.1',9),(3,'74.12.M.1',10),(3,'74.2.F.1',8),(3,'74.2.M.1',10),(3,'74.5.F.1',6),(4,'74.1.F.1',6),(4,'74.1.M.1',11),(4,'74.11.F.1',8),(4,'74.11.M.1',11),(4,'74.12.F.1',11),(4,'74.12.M.1',8),(4,'74.2.F.1',11),(4,'74.2.M.1',10),(4,'74.5.F.1',5),(5,'75.1.F.1',11),(5,'75.1.M.1',10),(5,'75.12.F.1',11),(5,'75.12.M.1',10),(5,'75.2.F.1',11),(5,'75.2.M.1',11),(5,'75.3.F.1',12),(5,'75.3.M.1',11),(5,'75.4.F.1',11),(5,'75.4.M.1',11),(5,'75.7.F.1',7),(5,'75.7.M.1',11),(5,'75.8.F.1',11),(6,'50.12.F.1',5),(6,'50.12.F.2',6),(6,'50.12.M.1',8),(6,'50.12.M.2',3),(6,'64.1.F.1',10),(6,'71.7.F.1',9),(7,'50.12.F.1',3),(7,'50.12.F.2',2),(7,'50.12.M.1',9),(7,'50.12.M.2',1),(7,'64.1.F.1',9),(7,'71.7.F.1',11),(8,'50.12.F.1',6),(8,'50.12.F.2',6),(8,'50.12.M.1',5),(8,'50.12.M.2',1),(8,'64.1.F.1',9),(8,'71.7.F.1',12),(9,'50.12.F.1',4),(9,'50.12.F.2',6),(9,'50.12.M.1',5),(9,'50.12.M.2',1),(9,'64.1.F.1',10),(10,'50.12.F.1',7),(10,'50.12.F.2',1),(10,'50.12.M.1',8),(10,'50.12.M.2',1),(10,'64.1.F.1',12),(12,'65.4.M.1',10),(12,'74.1.F.1',7),(12,'74.1.M.1',7),(12,'74.11.F.1',7),(12,'74.11.M.1',8),(12,'74.12.F.1',10),(12,'74.12.M.1',7),(12,'74.2.F.1',9),(12,'74.2.M.1',11),(12,'74.5.F.1',3),(13,'65.4.M.1',9),(13,'74.1.F.1',9),(13,'74.1.M.1',9),(13,'74.11.F.1',6),(13,'74.11.M.1',7),(13,'74.12.F.1',10),(13,'74.12.M.1',6),(13,'74.2.F.1',8),(13,'74.2.M.1',11),(13,'74.5.F.1',7),(14,'34.3.M.1',8),(14,'62.2.F.1',11),(14,'65.4.M.1',12),(14,'74.1.F.1',10),(14,'74.1.M.1',10),(14,'74.11.F.1',9),(14,'74.11.M.1',12),(14,'74.12.F.1',12),(14,'74.12.M.1',9),(14,'74.2.F.1',12),(14,'74.2.M.1',8),(14,'74.5.F.1',4),(15,'34.3.M.1',7),(15,'62.2.F.1',12),(15,'65.4.M.1',10),(16,'34.3.M.1',5),(16,'62.2.F.1',11),(16,'65.4.M.1',12),(17,'34.3.M.1',8),(17,'62.2.F.1',10),(18,'62.2.F.1',12),(18,'70.4.F.1',7),(19,'70.4.F.1',8),(20,'49.3.F.1',4),(20,'63.1.M.1',10),(20,'70.4.F.1',7),(20,'75.1.F.1',12),(20,'75.1.M.1',12),(20,'75.12.F.1',11),(20,'75.12.M.1',11),(20,'75.2.F.1',10),(20,'75.2.M.1',10),(20,'75.3.F.1',11),(20,'75.3.M.1',9),(20,'75.4.F.1',9),(20,'75.4.M.1',10),(20,'75.7.F.1',6),(20,'75.7.M.1',11),(20,'75.8.F.1',9),(21,'49.3.F.1',3),(21,'63.1.M.1',10),(21,'70.4.F.1',8),(21,'75.1.F.1',9),(21,'75.1.M.1',12),(21,'75.12.F.1',10),(21,'75.12.M.1',11),(21,'75.2.F.1',10),(21,'75.2.M.1',10),(21,'75.3.F.1',11),(21,'75.3.M.1',12),(21,'75.4.F.1',10),(21,'75.4.M.1',10),(21,'75.7.F.1',9),(21,'75.7.M.1',10),(21,'75.8.F.1',12),(22,'49.3.F.1',4),(22,'63.1.M.1',12),(22,'70.4.F.1',12),(22,'75.1.F.1',11),(22,'75.1.M.1',11),(22,'75.12.F.1',12),(22,'75.12.M.1',11),(22,'75.2.F.1',11),(22,'75.2.M.1',11),(22,'75.3.F.1',10),(22,'75.3.M.1',12),(22,'75.4.F.1',11),(22,'75.4.M.1',11),(22,'75.7.F.1',5),(22,'75.7.M.1',9),(22,'75.8.F.1',11),(23,'49.3.F.1',2),(23,'63.1.M.1',11),(23,'75.1.F.1',7),(23,'75.1.M.1',10),(23,'75.12.F.1',12),(23,'75.12.M.1',12),(23,'75.2.F.1',12),(23,'75.2.M.1',8),(23,'75.3.F.1',11),(23,'75.3.M.1',11),(23,'75.4.F.1',12),(23,'75.4.M.1',12),(23,'75.7.F.1',8),(23,'75.7.M.1',12),(23,'75.8.F.1',12),(24,'49.3.F.1',2),(24,'63.1.M.1',12),(25,'71.7.F.1',10);
/*!40000 ALTER TABLE `gamemaker_score` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant`
--

DROP TABLE IF EXISTS `participant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `participant` (
  `participant_id` varchar(64) NOT NULL,
  `tribute_id` int NOT NULL,
  `game_number` int NOT NULL,
  `final_placement` int DEFAULT NULL,
  `interview_score` int DEFAULT NULL,
  PRIMARY KEY (`participant_id`),
  KEY `tribute_id` (`tribute_id`),
  KEY `game_number` (`game_number`),
  CONSTRAINT `participant_ibfk_1` FOREIGN KEY (`tribute_id`) REFERENCES `tribute` (`tribute_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `participant_ibfk_2` FOREIGN KEY (`game_number`) REFERENCES `game` (`game_number`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `check_interview_score` CHECK ((`interview_score` between 1 and 10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant`
--

LOCK TABLES `participant` WRITE;
/*!40000 ALTER TABLE `participant` DISABLE KEYS */;
INSERT INTO `participant` VALUES ('10.1.F.1',23,10,NULL,NULL),('10.1.M.1',22,10,NULL,NULL),('10.10.F.1',41,10,NULL,NULL),('10.10.M.1',40,10,NULL,NULL),('10.11.F.1',43,10,NULL,NULL),('10.11.M.1',42,10,NULL,NULL),('10.12.F.1',45,10,NULL,NULL),('10.12.M.1',44,10,NULL,NULL),('10.2.F.1',25,10,NULL,NULL),('10.2.M.1',24,10,NULL,NULL),('10.3.F.1',27,10,NULL,NULL),('10.3.M.1',26,10,NULL,NULL),('10.4.F.1',29,10,NULL,NULL),('10.4.M.1',28,10,NULL,NULL),('10.5.F.1',31,10,NULL,NULL),('10.5.M.1',30,10,NULL,NULL),('10.6.F.1',33,10,NULL,NULL),('10.6.M.1',32,10,NULL,NULL),('10.7.F.1',35,10,NULL,NULL),('10.7.M.1',34,10,NULL,NULL),('10.8.F.1',37,10,NULL,NULL),('10.8.M.1',36,10,NULL,NULL),('10.9.F.1',39,10,NULL,NULL),('10.9.M.1',38,10,NULL,NULL),('11.4.F.1',5,11,NULL,NULL),('34.3.M.1',10,34,NULL,NULL),('49.3.F.1',9,49,NULL,NULL),('50.12.F.1',46,50,NULL,NULL),('50.12.F.2',47,50,NULL,NULL),('50.12.M.1',48,50,NULL,NULL),('50.12.M.2',49,50,NULL,NULL),('62.2.F.1',17,62,NULL,NULL),('63.1.M.1',14,63,NULL,NULL),('64.1.F.1',13,64,NULL,NULL),('65.4.M.1',6,65,NULL,NULL),('70.4.F.1',7,70,NULL,NULL),('71.7.F.1',8,71,NULL,NULL),('74.1.F.1',11,74,NULL,NULL),('74.1.M.1',12,74,NULL,NULL),('74.11.F.1',3,74,NULL,NULL),('74.11.M.1',4,74,NULL,NULL),('74.12.F.1',1,74,NULL,NULL),('74.12.M.1',2,74,NULL,NULL),('74.2.F.1',16,74,NULL,NULL),('74.2.M.1',15,74,NULL,NULL),('74.5.F.1',19,74,NULL,NULL),('75.1.F.1',13,75,NULL,NULL),('75.1.M.1',14,75,NULL,NULL),('75.12.F.1',1,75,NULL,NULL),('75.12.M.1',2,75,NULL,NULL),('75.2.F.1',17,75,NULL,NULL),('75.2.M.1',18,75,NULL,NULL),('75.3.F.1',9,75,NULL,NULL),('75.3.M.1',10,75,NULL,NULL),('75.4.F.1',5,75,NULL,NULL),('75.4.M.1',6,75,NULL,NULL),('75.7.F.1',8,75,NULL,NULL),('75.7.M.1',20,75,NULL,NULL),('75.8.F.1',21,75,NULL,NULL);
/*!40000 ALTER TABLE `participant` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_participant_id` BEFORE INSERT ON `participant` FOR EACH ROW BEGIN
    DECLARE next_num INT;
    DECLARE trib_gender CHAR(1);
    DECLARE trib_district INT;
    
    -- Look up the tribute's district and gender from the tribute table
    SELECT district, gender 
    INTO trib_district, trib_gender
    FROM tribute
    WHERE tribute_id = NEW.tribute_id;
    
    -- Find the next number for this game/district/gender combination
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(participant_id, '.', -1) AS UNSIGNED)), 0) + 1
    INTO next_num
    FROM participant
    WHERE participant_id LIKE CONCAT(NEW.game_number, '.', trib_district, '.', trib_gender, '.%');
    
    -- Set the participant_id
    SET NEW.participant_id = CONCAT(NEW.game_number, '.', trib_district, '.', trib_gender, '.', next_num);
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
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `verify_participant_age` BEFORE INSERT ON `participant` FOR EACH ROW BEGIN
    DECLARE age_during_games INT;
    DECLARE game_year INT;
    DECLARE reaping_date DATE;
    DECLARE tribute_dob DATE;
    
    -- Get tribute's date of birth
    SELECT dob INTO tribute_dob
    FROM tribute
    WHERE tribute_id = NEW.tribute_id;
    
    -- Get game year
    SELECT YEAR(start_date) INTO game_year
    FROM game
    WHERE game_number = NEW.game_number;
    
    -- Calculate reaping date (July 4th)
    SET reaping_date = CAST(CONCAT(LPAD(game_year, 4, '0'), '-07-04') AS DATE);
    
    -- Calculate age on reaping day
    SET age_during_games = TIMESTAMPDIFF(YEAR, tribute_dob, reaping_date);
    
    -- Only enforce age constraint if NOT a Quarter Quell (not divisible by 25)
    IF NEW.game_number % 25 != 0 THEN
        IF age_during_games < 12 OR age_during_games > 18 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Participant must be between 12 and 18 at the start of the games. Verify tribute date of birth and game start date.';
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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `limit_participant_count` BEFORE INSERT ON `participant` FOR EACH ROW BEGIN

    DECLARE num_participants INT;
    DECLARE max_tributes INT;

    SELECT COUNT(*) INTO num_participants 
    FROM participant 
    WHERE game_number = NEW.game_number;
    
    SELECT required_tribute_count INTO max_tributes
	FROM game
    WHERE game_number = NEW.game_number;

    IF num_participants = max_tributes THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'required tribute count has been reached';
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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_victor_upon_winner_inserted` AFTER INSERT ON `participant` FOR EACH ROW BEGIN
	IF NEW.final_placement = 1 THEN
		-- create victor if not exists
		CALL create_victor_from_tribute(NEW.tribute_id);
		-- set victor
		CALL set_game_victor(NEW.game_number, NEW.tribute_id);
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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_victor_upon_winner_updated` AFTER UPDATE ON `participant` FOR EACH ROW BEGIN
	IF NEW.final_placement = 1 AND (OLD.final_placement IS NULL OR OLD.final_placement != 1) THEN
		-- create victor if not exists
		CALL create_victor_from_tribute(NEW.tribute_id);
		-- set victor
		CALL set_game_victor(NEW.game_number, NEW.tribute_id);
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `participant_details`
--

DROP TABLE IF EXISTS `participant_details`;
/*!50001 DROP VIEW IF EXISTS `participant_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `participant_details` AS SELECT 
 1 AS `participant_id`,
 1 AS `name`,
 1 AS `district`,
 1 AS `gender`,
 1 AS `game_number`,
 1 AS `age_during_games`,
 1 AS `training_score`,
 1 AS `interview_score`,
 1 AS `final_placement`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sponsor`
--

DROP TABLE IF EXISTS `sponsor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsor` (
  `sponsor_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`sponsor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsor`
--

LOCK TABLES `sponsor` WRITE;
/*!40000 ALTER TABLE `sponsor` DISABLE KEYS */;
INSERT INTO `sponsor` VALUES (1,'Pieceof CapitolHorseShit'),(2,'Catos\'s Groupies'),(3,'Glimmer\'s GlamSquad'),(4,'The Four Leaf CLOVErs'),(5,'Peeta Bread'),(6,'Capitol Bullshit'),(7,'Pompous Heavensbee'),(8,'Creme Brulee'),(9,'Twinkle Lowbottom'),(10,'Platinum Periwinkle'),(11,'Caviar Cardew'),(12,'Flambee Flickerman');
/*!40000 ALTER TABLE `sponsor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsorship`
--

DROP TABLE IF EXISTS `sponsorship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsorship` (
  `sponsor_id` int NOT NULL,
  `participant_id` varchar(64) NOT NULL,
  `sponsor_amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`sponsor_id`,`participant_id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `sponsorship_ibfk_1` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsor` (`sponsor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `sponsorship_ibfk_2` FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `check_sponsorship` CHECK ((`sponsor_amount` between 0 and 99999999.99))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsorship`
--

LOCK TABLES `sponsorship` WRITE;
/*!40000 ALTER TABLE `sponsorship` DISABLE KEYS */;
INSERT INTO `sponsorship` VALUES (1,'10.1.F.1',5221.00),(1,'10.2.F.1',3754.00),(1,'10.6.F.1',4963.00),(1,'11.4.F.1',3183.00),(1,'63.1.M.1',2617.00),(1,'74.11.M.1',3532.00),(1,'75.12.F.1',5499.00),(1,'75.7.F.1',5362.00),(2,'74.2.M.1',7000.00),(3,'74.1.F.1',6000.00),(4,'74.2.F.1',5500.00),(5,'74.12.M.1',8000.00),(6,'10.1.M.1',4029.00),(6,'10.2.M.1',2086.00),(6,'10.6.M.1',5038.00),(6,'34.3.M.1',3618.00),(6,'64.1.F.1',5130.00),(6,'74.12.F.1',2965.00),(6,'75.12.M.1',2122.00),(6,'75.7.M.1',6350.00),(7,'10.10.F.1',6759.00),(7,'10.3.F.1',3572.00),(7,'10.7.F.1',3669.00),(7,'49.3.F.1',6731.00),(7,'65.4.M.1',5602.00),(7,'74.12.M.1',6613.00),(7,'75.2.F.1',2283.00),(7,'75.8.F.1',5712.00),(8,'10.10.M.1',3644.00),(8,'10.3.M.1',5594.00),(8,'10.7.M.1',5020.00),(8,'50.12.F.1',3781.00),(8,'70.4.F.1',2132.00),(8,'74.2.F.1',3645.00),(8,'75.2.M.1',4648.00),(9,'10.11.F.1',4149.00),(9,'10.4.F.1',5478.00),(9,'10.8.F.1',5689.00),(9,'50.12.F.2',4914.00),(9,'71.7.F.1',6416.00),(9,'74.2.M.1',3818.00),(9,'75.3.F.1',2794.00),(10,'10.11.M.1',4562.00),(10,'10.4.M.1',4612.00),(10,'10.8.M.1',2198.00),(10,'50.12.M.1',4967.00),(10,'74.1.F.1',2735.00),(10,'74.5.F.1',5922.00),(10,'75.3.M.1',3975.00),(11,'10.12.F.1',5956.00),(11,'10.5.F.1',5948.00),(11,'10.9.F.1',5738.00),(11,'50.12.M.2',2643.00),(11,'74.1.M.1',6642.00),(11,'75.1.F.1',6740.00),(11,'75.4.F.1',4135.00),(12,'10.12.M.1',2579.00),(12,'10.5.M.1',3843.00),(12,'10.9.M.1',5491.00),(12,'62.2.F.1',3565.00),(12,'74.11.F.1',4105.00),(12,'75.1.M.1',4274.00),(12,'75.4.M.1',2094.00);
/*!40000 ALTER TABLE `sponsorship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_member`
--

DROP TABLE IF EXISTS `team_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_member` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `victor_id` int DEFAULT NULL,
  PRIMARY KEY (`member_id`),
  KEY `victor_id` (`victor_id`),
  CONSTRAINT `team_member_ibfk_1` FOREIGN KEY (`victor_id`) REFERENCES `victor` (`victor_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_member`
--

LOCK TABLES `team_member` WRITE;
/*!40000 ALTER TABLE `team_member` DISABLE KEYS */;
INSERT INTO `team_member` VALUES (1,'Effie Trinket',NULL),(2,'Haymith Abernathy',NULL),(3,'Cinna',NULL),(4,'Portia',NULL),(5,'Octavia',NULL),(6,'Flavius',NULL),(7,'Venia',NULL),(8,'Tigris',NULL),(9,'Persephone Trinket',NULL),(10,'Drusilla Sickle',NULL),(11,'Magno Stift',NULL),(12,'Sejanus Plinth',NULL),(13,'Coriolanus Snow',NULL),(14,'Lysistrata Vickers',NULL),(15,'Clemensia Dovecote',NULL),(16,'Arachne Crane',NULL),(17,'Festus Creed',NULL),(18,'Livia Cardew',NULL),(19,'Pup Harrington',NULL),(20,'Hilarius Heavensbee',NULL),(21,'Juno Phipps',NULL),(22,'Felix Ravinstill',NULL),(23,'Vispania Sickle',NULL),(24,'Io Jasper',NULL),(25,'Androcles Anderson',NULL),(26,'Gaius Breen',NULL),(27,'Urban Canville',NULL),(28,'Dennis Fling',NULL),(29,'Florus Friend',NULL),(30,'Palmyra Monty',NULL),(31,'Iphigenia Moss',NULL),(32,'Persephone Price',NULL),(33,'Apollo Ring',NULL),(34,'Diana Ring',NULL),(35,'Domitia Whimsiwick',NULL),(36,'Juvenia',NULL);
/*!40000 ALTER TABLE `team_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_role`
--

DROP TABLE IF EXISTS `team_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_role` (
  `member_id` int NOT NULL,
  `participant_id` varchar(64) NOT NULL,
  `member_type` enum('escort','stylist','mentor','prep') NOT NULL,
  PRIMARY KEY (`member_id`,`participant_id`),
  KEY `participant_id` (`participant_id`),
  CONSTRAINT `team_role_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `team_member` (`member_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `team_role_ibfk_2` FOREIGN KEY (`participant_id`) REFERENCES `participant` (`participant_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_role`
--

LOCK TABLES `team_role` WRITE;
/*!40000 ALTER TABLE `team_role` DISABLE KEYS */;
INSERT INTO `team_role` VALUES (1,'50.12.F.1','stylist'),(1,'50.12.F.2','stylist'),(1,'50.12.M.1','stylist'),(1,'50.12.M.2','stylist'),(1,'74.12.F.1','escort'),(1,'74.12.M.1','escort'),(1,'75.12.F.1','escort'),(1,'75.12.M.1','escort'),(2,'74.12.F.1','mentor'),(2,'74.12.M.1','mentor'),(2,'75.12.F.1','mentor'),(2,'75.12.M.1','mentor'),(3,'74.12.F.1','stylist'),(3,'75.12.F.1','stylist'),(4,'74.12.M.1','stylist'),(4,'75.12.M.1','stylist'),(5,'74.12.F.1','prep'),(5,'74.12.M.1','prep'),(5,'75.12.F.1','prep'),(5,'75.12.M.1','prep'),(6,'74.12.F.1','prep'),(6,'74.12.M.1','prep'),(6,'75.12.F.1','prep'),(6,'75.12.M.1','prep'),(7,'74.12.F.1','prep'),(7,'74.12.M.1','prep'),(7,'75.12.F.1','prep'),(7,'75.12.M.1','prep'),(9,'50.12.F.1','prep'),(9,'50.12.F.2','prep'),(9,'50.12.M.1','prep'),(9,'50.12.M.2','prep'),(10,'50.12.F.1','escort'),(10,'50.12.F.2','escort'),(10,'50.12.M.1','escort'),(10,'50.12.M.2','escort'),(11,'50.12.F.1','stylist'),(11,'50.12.F.2','stylist'),(11,'50.12.M.1','stylist'),(11,'50.12.M.2','stylist'),(12,'10.2.M.1','mentor'),(13,'10.12.F.1','mentor'),(14,'10.12.M.1','mentor'),(15,'10.11.M.1','mentor'),(16,'10.10.F.1','mentor'),(17,'10.4.F.1','mentor'),(18,'10.1.M.1','mentor'),(19,'10.7.F.1','mentor'),(20,'10.8.F.1','mentor'),(21,'10.8.M.1','mentor'),(22,'10.11.F.1','mentor'),(23,'10.7.M.1','mentor'),(24,'10.3.M.1','mentor'),(25,'10.9.M.1','mentor'),(26,'10.9.F.1','mentor'),(27,'10.3.F.1','mentor'),(28,'10.5.M.1','mentor'),(29,'10.2.F.1','mentor'),(30,'10.1.F.1','mentor'),(31,'10.5.F.1','mentor'),(32,'10.4.M.1','mentor'),(33,'10.6.M.1','mentor'),(34,'10.6.F.1','mentor'),(35,'10.10.M.1','mentor'),(36,'74.1.F.1','escort'),(36,'74.1.M.1','escort');
/*!40000 ALTER TABLE `team_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tribute`
--

DROP TABLE IF EXISTS `tribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tribute` (
  `tribute_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('M','F') NOT NULL,
  `district` int DEFAULT NULL,
  PRIMARY KEY (`tribute_id`),
  UNIQUE KEY `prevent_dupe_tributes` (`name`,`dob`,`gender`,`district`),
  KEY `district` (`district`),
  CONSTRAINT `tribute_ibfk_1` FOREIGN KEY (`district`) REFERENCES `district` (`district_num`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tribute`
--

LOCK TABLES `tribute` WRITE;
/*!40000 ALTER TABLE `tribute` DISABLE KEYS */;
INSERT INTO `tribute` VALUES (7,'Annie Cresta','0069-11-05','F',4),(10,'Beetee Latier','0034-07-14','M',3),(20,'Blight','0055-03-15','M',7),(36,'Bobbin','0015-08-28','M',8),(41,'Brandy','0011-06-30','F',10),(18,'Brutus','0050-01-11','M',2),(13,'Cashmere','0068-05-30','F',1),(15,'Cato','0074-02-14','M',2),(21,'Cecelia','0061-04-22','F',8),(26,'Circ','0013-08-03','M',3),(16,'Clove','0077-01-23','F',2),(29,'Coral','0010-12-30','F',4),(43,'Dill','0016-06-22','F',11),(17,'Enobaria','0063-08-08','F',2),(22,'Facet','0012-09-15','M',1),(6,'Finnick Odair','0069-08-17','M',4),(19,'Foxface','0076-09-27','F',5),(33,'Ginnee','0016-05-17','F',6),(11,'Glimmer','0075-04-19','F',1),(14,'Gloss','0066-05-30','M',1),(49,'Haymitch Abernathy','0052-07-04','M',12),(30,'Hy','0013-07-14','M',5),(44,'Jessup Diggs','0010-03-14','M',12),(8,'Johanna Mason','0072-10-08','F',7),(1,'Katniss Everdeen','0076-05-08','F',12),(35,'Lamina','0012-01-11','F',7),(46,'Louella McCoy','0055-10-09','F',12),(45,'Lucy Gray Baird','0012-03-10','F',12),(5,'Mags','0012-02-10','F',4),(24,'Marcus','0010-01-08','M',2),(12,'Marvel','0075-12-02','M',1),(47,'Maysilee Donner','0052-06-20','F',12),(28,'Mizzen','0015-04-22','M',4),(32,'Otto','0014-03-25','M',6),(38,'Panlo','0013-12-05','M',9),(2,'Peeta Mellark','0076-03-12','M',12),(42,'Reaper Ash','0010-05-05','M',11),(3,'Rue','0080-03-05','F',11),(25,'Sabyn','0012-06-12','F',2),(39,'Sheaf','0013-04-19','F',9),(31,'Sol','0012-10-08','F',5),(40,'Tanner','0012-02-27','M',10),(27,'Teslee','0012-11-18','F',3),(4,'Thresh','0074-01-28','M',11),(34,'Treech','0011-09-20','M',7),(23,'Velvereen','0013-02-20','F',1),(9,'Wiress','0049-03-22','F',3),(37,'Wovey','0016-03-08','F',8),(48,'Wyatt Callow','0050-05-21','M',12);
/*!40000 ALTER TABLE `tribute` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `victor`
--

DROP TABLE IF EXISTS `victor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `victor` (
  `victor_id` int NOT NULL,
  PRIMARY KEY (`victor_id`),
  CONSTRAINT `victor_ibfk_1` FOREIGN KEY (`victor_id`) REFERENCES `tribute` (`tribute_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `victor`
--

LOCK TABLES `victor` WRITE;
/*!40000 ALTER TABLE `victor` DISABLE KEYS */;
/*!40000 ALTER TABLE `victor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'hunger_games'
--

--
-- Dumping routines for database 'hunger_games'
--
/*!50003 DROP FUNCTION IF EXISTS `get_participant_age` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_participant_age`(p_participant_id VARCHAR(64)) RETURNS int
    DETERMINISTIC
BEGIN
	
	DECLARE age_during_games INT;
    DECLARE game_year INT;
    DECLARE reaping_date DATE;
    DECLARE tribute_dob DATE;
    
    SELECT YEAR(g.start_date), t.dob
    INTO game_year, tribute_dob
    FROM participant p
    JOIN tribute t ON p.tribute_id = t.tribute_id
    JOIN game g ON p.game_number = g.game_number
    WHERE p.participant_id = p_participant_id;

	SET reaping_date = CAST(CONCAT(LPAD(game_year, 4, '0'), '-07-04') AS DATE);
	
	SET age_during_games = TIMESTAMPDIFF(YEAR, tribute_dob, reaping_date);

	RETURN age_during_games;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_total_contributions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_total_contributions`(p_sponsor_id INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
	
	DECLARE total_contributions DECIMAL(10, 2);
	
	SELECT COALESCE(SUM(sponsor_amount), 0) INTO total_contributions
	FROM sponsorship
	WHERE sponsor_id = p_sponsor_id;
	
	
	RETURN total_contributions;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_training_score` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_training_score`(p_participant_id VARCHAR(64)) RETURNS decimal(2,0)
    DETERMINISTIC
BEGIN
    DECLARE training_score DECIMAL(2, 0);
    
    SELECT ROUND(AVG(assessment_score)) INTO training_score
    FROM gamemaker_score
    WHERE participant_id = p_participant_id;
    
    RETURN COALESCE(training_score, NULL);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_participant_by_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_participant_by_name`(
    p_tribute_name VARCHAR(64),
    p_game_number INT
)
BEGIN
    DECLARE v_tribute_id INT;

    SELECT tribute_id INTO v_tribute_id
    FROM tribute
    WHERE name = p_tribute_name
    LIMIT 1;
    
    IF v_tribute_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute not found';
    END IF;
    
    INSERT INTO participant (tribute_id, game_number)
    VALUES (v_tribute_id, p_game_number);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_team_role_by_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_team_role_by_name`(
    p_team_member_name VARCHAR(64),
    p_member_type VARCHAR(64),
    p_participant_id VARCHAR(64)
)
BEGIN
    DECLARE v_member_id INT;

    SELECT member_id INTO v_member_id
    FROM member
    WHERE name = p_team_member_name
    LIMIT 1;
    
    IF v_member_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team member not found';
    END IF;
    
    INSERT INTO team_role (member_id, member_type, participant_id)
    VALUES (v_member_id, p_member_type, p_participant_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_victor_from_tribute` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_victor_from_tribute`(p_tribute_id INT)
BEGIN
	IF p_tribute_id NOT IN (SELECT tribute_id FROM tribute) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute does not exist';
    
    INSERT INTO victor(victor_id) VALUES (p_tribute_id);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_game_victor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_game_victor`(p_game_number INT, p_victor_id INT)
BEGIN

	IF p_game_number NOT IN (SELECT game_number FROM game) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
	END IF;
	IF p_victor_id NOT IN (SELECT victor_id FROM victor) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Victor does not exist';
	END IF;

    INSERT INTO game_victor (game_number, victor_id) 
    VALUES (p_game_number, p_victor_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `participant_details`
--

/*!50001 DROP VIEW IF EXISTS `participant_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `participant_details` AS select `p`.`participant_id` AS `participant_id`,`t`.`name` AS `name`,`t`.`district` AS `district`,`t`.`gender` AS `gender`,`p`.`game_number` AS `game_number`,`get_participant_age`(`p`.`participant_id`) AS `age_during_games`,`get_training_score`(`p`.`participant_id`) AS `training_score`,`p`.`interview_score` AS `interview_score`,`p`.`final_placement` AS `final_placement` from (`participant` `p` join `tribute` `t` on((`p`.`tribute_id` = `t`.`tribute_id`))) */;
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

-- Dump completed on 2025-11-24 16:12:55
