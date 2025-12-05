DROP DATABASE IF EXISTS hunger_games;
CREATE DATABASE IF NOT EXISTS hunger_games;

use hunger_games;

DROP USER IF EXISTS 'snow'@'localhost';

CREATE USER 'snow'@'localhost' IDENTIFIED BY 'lucygray';
GRANT ALL PRIVILEGES ON hunger_games.* TO 'snow'@'localhost';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS district (
	district_num INT PRIMARY KEY,
    industry VARCHAR(64),
    size ENUM ('Small', 'Medium', 'Large'), 
    wealth ENUM('Poor', 'Working Class', 'Middle Class', 'Wealthy') 
    
);

CREATE TABLE IF NOT EXISTS tribute (
	tribute_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64),
    dob DATE,
    gender ENUM ('m', 'f') NOT NULL,
    district INT,
	FOREIGN KEY (district) REFERENCES district(district_num)
        ON UPDATE CASCADE ON DELETE RESTRICT,
        
    CONSTRAINT prevent_dupe_tributes
        UNIQUE (name, dob, gender, district)
);

CREATE TABLE IF NOT EXISTS victor (
	victor_id INT PRIMARY KEY,
	FOREIGN KEY (victor_id) REFERENCES Tribute(tribute_id) -- tribute id transfers to be victor_id
		ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS team_member (
	member_id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(64),
    victor_id INT,
    FOREIGN KEY (victor_id) REFERENCES victor(victor_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS sponsor (
	sponsor_id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS gamemaker (
	gamemaker_id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS game (
	game_number INT PRIMARY KEY NOT NULL,-- no autoincrement
	required_tribute_count INT NOT NULL DEFAULT 24,
    game_status ENUM('planned', 'in progress', 'completed') DEFAULT 'planned',
    start_date DATE, -- calculated and stored based on game number and year of first games
    end_date DATE,
    
    CONSTRAINT check_negative_tributes CHECK (required_tribute_count > 0)
);

CREATE TABLE IF NOT EXISTS participant(
	participant_id VARCHAR(64) PRIMARY KEY,
	tribute_id INT NOT NULL,
    game_number INT NOT NULL,
    final_placement INT DEFAULT NULL, -- add logic -- limit based on number of tributes - trigger
    intelligence_score INT DEFAULT NULL,
    likeability_score INT DEFAULT NULL,
    
    CONSTRAINT check_intelligence_score CHECK (intelligence_score BETWEEN 1 AND 10),
    CONSTRAINT check_likeability_score CHECK (likeability_score BETWEEN 1 AND 10),

    FOREIGN KEY (tribute_id) REFERENCES tribute(tribute_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (game_number) REFERENCES game(game_number)
        ON UPDATE CASCADE ON DELETE RESTRICT
);



-- ============================
-- JUNCTION TABLES 
-- ============================


-- TeamMember -> Participant
CREATE TABLE IF NOT EXISTS team_role (
	member_id INT NOT NULL,
    participant_id VARCHAR(64) NOT NULL,
    member_type ENUM ('escort', 'stylist', 'mentor', 'prep') NOT NULL,
    PRIMARY KEY (member_id, participant_id),
    FOREIGN KEY (member_id) REFERENCES team_member(member_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);

-- gamemaker -> game
CREATE TABLE IF NOT EXISTS game_creator (
	gamemaker_id INT NOT NULL,
    game_number INT NOT NULL, 
    PRIMARY KEY (game_number, gamemaker_id),
    FOREIGN KEY (game_number) REFERENCES game(game_number)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (gamemaker_id) REFERENCES gamemaker(gamemaker_id)
		ON UPDATE CASCADE ON DELETE CASCADE
    
);
-- gamemaker -> participant
CREATE TABLE IF NOT EXISTS gamemaker_score (
	gamemaker_id INT NOT NULL,
    participant_id VARCHAR(64) NOT NULL,
    assessment_score INT,
    PRIMARY KEY (gamemaker_id, participant_id),
    FOREIGN KEY (gamemaker_id) REFERENCES gamemaker(gamemaker_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
        
	CONSTRAINT check_assessment CHECK (assessment_score BETWEEN 1 AND 12)
);

-- Sponsor -> Participant
CREATE TABLE IF NOT EXISTS sponsorship (
	sponsor_id INT NOT NULL,
    participant_id VARCHAR(64) NOT NULL,
    sponsor_amount DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY (sponsor_id, participant_id),
    FOREIGN KEY (sponsor_id) REFERENCES sponsor(sponsor_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	
    CONSTRAINT check_sponsorship CHECK (sponsor_amount BETWEEN 0 AND 99999999.99)
);

-- victor -> victor to specific game
CREATE TABLE IF NOT EXISTS game_victor (
    victor_id INT NOT NULL,
    game_number INT NOT NULL,
    PRIMARY KEY (victor_id, game_number),
    FOREIGN KEY (victor_id) REFERENCES victor(victor_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (game_number) REFERENCES game(game_number)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


-- ======================================
-- FUNCTIONS, PROCEDURES, AND TRIGGERS
-- ======================================


-- ===================================================================
-- FUNCTION: calculates and returns the training score
-- ===================================================================
DROP FUNCTION IF EXISTS get_training_score;
DELIMITER $$

CREATE FUNCTION get_training_score(p_participant_id VARCHAR(64))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE training_score INT;
    
    SELECT ROUND(AVG(assessment_score)) INTO training_score
    FROM gamemaker_score
    WHERE participant_id = p_participant_id;
    
    RETURN COALESCE(training_score, NULL);
END $$

DELIMITER ;



-- ===================================================================
-- FUNCTION: returns the participant's chances of winning
-- ===================================================================
DROP FUNCTION IF EXISTS calculate_win_prediction;
DELIMITER $$

CREATE FUNCTION calculate_win_prediction(
    p_training INT,
    p_intelligence INT, 
    p_likeability INT
)
RETURNS DECIMAL(5,4)
DETERMINISTIC
BEGIN
    RETURN (p_training * 0.5 + p_intelligence * 0.3 + p_likeability * 0.2) / 11;
END $$

DELIMITER ;


-- ===================================================================
-- FUNCTION: returns the participant's intelligence score
-- ===================================================================
DROP FUNCTION IF EXISTS get_intelligence_score;
DELIMITER $$

CREATE FUNCTION get_intelligence_score(p_participant_id VARCHAR(64))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE score INT;
    
    SELECT intelligence_score INTO score
    FROM participant
    WHERE participant_id = p_participant_id;
    
    RETURN score;

END $$

DELIMITER ;



-- ===================================================================
-- FUNCTION: returns the participant's likeability score
-- ===================================================================
DROP FUNCTION IF EXISTS get_likeability_score;
DELIMITER $$

CREATE FUNCTION get_likeability_score(p_participant_id VARCHAR(64))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE score INT;
    
    SELECT likeability_score INTO score
    FROM participant
    WHERE participant_id = p_participant_id;
    
    RETURN score;

END $$

DELIMITER ;


-- ===================================================================
-- FUNCTION: calculates and returns a sponsor's total contributions
-- ===================================================================
DROP FUNCTION IF EXISTS get_total_contributions;

DELIMITER $$
CREATE FUNCTION get_total_contributions(p_sponsor_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	
	DECLARE total_contributions DECIMAL(10, 2);
	
	SELECT COALESCE(SUM(sponsor_amount), 0) INTO total_contributions
	FROM sponsorship
	WHERE sponsor_id = p_sponsor_id;
	
	
	RETURN total_contributions;

END $$
	
DELIMITER ;	


-- ========================================================================
-- FUNCTION: calculates and returns the participant's age during the games
-- ========================================================================
DROP FUNCTION IF EXISTS get_participant_age;

DELIMITER $$
CREATE FUNCTION get_participant_age(p_participant_id VARCHAR(64))
RETURNS INT
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
    
END $$
	
DELIMITER ;	


-- ========================================================================
-- FUNCTION: calculates and determined the number of tributes remaining
-- ========================================================================
DROP FUNCTION IF EXISTS get_num_tributes_remaining;

DELIMITER $$
CREATE FUNCTION get_num_tributes_remaining(p_game_number INT)
RETURNS INT
DETERMINISTIC
BEGIN
	
	DECLARE num_tributes_remaining INT;

    IF (SELECT COUNT(*) from game WHERE game_status = 'completed' AND game_number = p_game_number) = 1 THEN
        SELECT '0' INTO num_tributes_remaining;

    ELSE
        SELECT COUNT(*)
        INTO num_tributes_remaining
        FROM participant
        WHERE final_placement IS NULL AND game_number = p_game_number;
    END IF;

	RETURN num_tributes_remaining;
    
END $$
	
DELIMITER ;	



-- ========================================================================
-- PROCEDURE: returns the number of victors per district
-- ========================================================================
DROP PROCEDURE IF EXISTS get_total_district_victors;
DELIMITER $$

CREATE PROCEDURE get_total_district_victors()
BEGIN

    SELECT d.district_num as district, COUNT(v.victor_id) as victors
    FROM district d
    LEFT JOIN tribute t ON d.district_num = t.district
    LEFT JOIN victor v ON t.tribute_id = v.victor_id
    GROUP BY d.district_num
    ORDER BY victors DESC, d.district_num ASC;
END $$

DELIMITER ;

CALL get_total_district_victors();



-- ========================================================================
-- PROCEDURE: gets correlation data between funding and placement
-- ========================================================================
DROP PROCEDURE IF EXISTS get_funding_placement_analysis;
DELIMITER $$

CREATE PROCEDURE get_funding_placement_analysis()
BEGIN
    SELECT 
        placement_group,
        AVG(total_funding) as avg_funding,
        COUNT(DISTINCT participant_id) as tribute_count
    FROM (
        SELECT 
            pd.participant_id,
            CASE 
                WHEN pd.final_placement = 1 THEN 'Winner (1st)'
                WHEN pd.final_placement BETWEEN 2 AND 5 THEN 'Top 5'
                WHEN pd.final_placement BETWEEN 6 AND 12 THEN 'Upper Half'
                ELSE 'Lower Half'
            END as placement_group,
            COALESCE(SUM(s.sponsor_amount), 0) as total_funding
        FROM participant_details pd
        LEFT JOIN sponsorship s ON pd.participant_id = s.participant_id
        GROUP BY pd.participant_id, pd.final_placement
    ) as participant_funding
    GROUP BY placement_group
    ORDER BY 
        CASE 
            WHEN placement_group = 'Winner (1st)' THEN 1
            WHEN placement_group = 'Top 5' THEN 2
            WHEN placement_group = 'Upper Half' THEN 3
            ELSE 4
        END;
END $$

DELIMITER ;

-- ========================================================================
-- PROCEDURE: returns the number of tributes per district
-- ========================================================================
DROP PROCEDURE IF EXISTS get_total_district_tributes;
DELIMITER $$

CREATE PROCEDURE get_total_district_tributes()
BEGIN

    SELECT d.district_num as district, COUNT(t.tribute_id) as tributes
    FROM district d
    LEFT JOIN tribute t ON d.district_num = t.district
    GROUP BY d.district_num
    ORDER BY d.district_num ASC;

END $$

DELIMITER ;


-- ========================================================================
-- PROCEDURE: returns the success rate for the districts
-- ========================================================================

DROP PROCEDURE IF EXISTS get_district_success_rates;
DELIMITER $$

CREATE PROCEDURE get_district_success_rates()
BEGIN

    SELECT d.district_num as district, COUNT(v.victor_id) as total_victors, COUNT(p.participant_id) as total_tributes, (COUNT(v.victor_id) / COUNT(p.participant_id)) as success_rate
    FROM district d
    LEFT JOIN tribute t ON d.district_num = t.district
    LEFT JOIN victor v ON t.tribute_id = v.victor_id
    LEFT JOIN participant p ON t.tribute_id = p.tribute_id
    GROUP BY d.district_num
    ORDER BY success_rate DESC, d.district_num ASC;


END $$

DELIMITER ;

-- ========================================================================
-- PROCEDURE: returns the success rate for the ages
-- ========================================================================

DROP PROCEDURE IF EXISTS get_victor_age_patterns;
DELIMITER $$

CREATE PROCEDURE get_victor_age_patterns()
BEGIN

    SELECT pd.age_during_games, COUNT(pd.participant_id) as total_tributes, COUNT(CASE WHEN pd.final_placement = 1 THEN 1 END) as total_victors, (COUNT(CASE WHEN pd.final_placement = 1 THEN 1 END) / COUNT(pd.participant_id)) as success_rate
    FROM participant_details pd
    WHERE pd.age_during_games BETWEEN 12 AND 18
    GROUP BY pd.age_during_games
    ORDER BY success_rate DESC, pd.age_during_games ASC;

END $$

DELIMITER ;

-- ========================================================================
-- PROCEDURE: returns the win predictions for a given game
-- ========================================================================

DROP PROCEDURE IF EXISTS get_win_predictions;
DELIMITER $$

CREATE PROCEDURE get_win_predictions(p_game_number INT)
BEGIN

    SELECT pd.participant_id, pd.name, pd.district, pd.training_score, pd.intelligence_score, pd.likeability_score, 
    calculate_win_prediction(pd.training_score, pd.intelligence_score, pd.likeability_score) as chances_of_winning
    FROM participant_details pd
    WHERE game_number = p_game_number
    ORDER BY chances_of_winning DESC;

END $$

DELIMITER ;

-- ===========================================================================
-- PROCEDURE: takes tribute_id and creates a victor if doesn't already exist
-- throws error if invalid parameter
-- ===========================================================================
DROP PROCEDURE IF EXISTS create_victor_from_tribute;
DELIMITER $$

CREATE PROCEDURE create_victor_from_tribute(p_tribute_id INT)
BEGIN
	IF p_tribute_id NOT IN (SELECT victor_id FROM victor) THEN
        INSERT INTO victor(victor_id) VALUES (p_tribute_id);
    END IF;
END $$

DELIMITER ;



-- ==========================================================================================
-- PROCEDURE: takes game_number and victor_id and inserts a game_victor if it doesn't exist
-- throws error if invalid parameters
-- ==========================================================================================
DROP PROCEDURE IF EXISTS set_game_victor;
DELIMITER $$

CREATE PROCEDURE set_game_victor(p_game_number INT, p_victor_id INT)
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
END $$
DELIMITER ;

-- ==========================================================================================
-- PROCEDURE: adds team_role by team member name
-- ==========================================================================================
DROP PROCEDURE IF EXISTS add_team_role_by_name;

DELIMITER $$
CREATE PROCEDURE add_team_role_by_name(
    p_team_member_name VARCHAR(64),
    p_member_type VARCHAR(64),
    p_participant_id VARCHAR(64)
)
BEGIN
    DECLARE v_member_id INT;

    SELECT member_id INTO v_member_id
    FROM team_member
    WHERE name = p_team_member_name
    LIMIT 1;
    
    IF v_member_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team member not found';
    END IF;
    
    INSERT INTO team_role (member_id, member_type, participant_id)
    VALUES (v_member_id, p_member_type, p_participant_id);
END $$

DELIMITER ;


-- ==========================================================================================
-- PROCEDURE: adds participant by their tribute name
-- ==========================================================================================
DROP PROCEDURE IF EXISTS add_participant_by_name;

DELIMITER $$
CREATE PROCEDURE add_participant_by_name(
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
END $$

DELIMITER ;



-- VIEW PROCEDURES


-- ======================================
-- View districts
-- ======================================
DROP PROCEDURE IF EXISTS view_districts;
DELIMITER $$

CREATE PROCEDURE view_districts()

BEGIN
    SELECT * FROM district;
END $$

DELIMITER ;



-- ====================================
-- View tributes with optional filters
-- ====================================
DROP PROCEDURE IF EXISTS view_tributes;

DELIMITER $$

CREATE PROCEDURE view_tributes(p_name VARCHAR(64), p_district INT)
BEGIN
    SELECT * FROM tribute WHERE 1=1
    AND (p_name IS NULL OR name LIKE CONCAT('%', p_name, '%'))
    AND (p_district IS NULL OR district = p_district)
    ORDER BY tribute_id;
END $$

DELIMITER ;


-- ======================================
-- View sponsors with optional filters
-- ======================================
DROP PROCEDURE IF EXISTS view_sponsors;
DELIMITER $$

CREATE PROCEDURE view_sponsors(p_name VARCHAR(64))
BEGIN
    SELECT * FROM sponsor WHERE 1=1
    AND (p_name IS NULL OR name LIKE CONCAT('%', p_name, '%'))
    ORDER BY sponsor_id;
END $$

DELIMITER ;


-- ========================================
-- View sponsorships with optional filters
-- ========================================
DROP PROCEDURE IF EXISTS view_sponsorships;
DELIMITER $$

CREATE PROCEDURE view_sponsorships(p_game_number INT, p_tribute_name VARCHAR(64))
BEGIN
    SELECT sp.sponsor_id as sponsor_id, sp.participant_id as participant_id, s.name as sponsor_name, t.name AS tribute_name, sp.sponsor_amount as sponsor_amount, p.game_number
    FROM sponsorship sp
    JOIN sponsor s ON sp.sponsor_id = s.sponsor_id
    JOIN participant p ON sp.participant_id = p.participant_id
    JOIN tribute t ON p.tribute_id = t.tribute_id
    WHERE 1=1
    AND (p_game_number IS NULL OR p.game_number = p_game_number)
    AND (p_tribute_name IS NULL OR t.name LIKE CONCAT('%', p_tribute_name, '%'))
    ORDER BY sp.sponsor_id;
END $$

DELIMITER ;


-- ==================================
-- View games with optional filters
-- ==================================
DROP PROCEDURE IF EXISTS view_games;
DELIMITER $$

CREATE PROCEDURE view_games(
    p_game_number INT,
    p_tribute_name VARCHAR(100),
    p_victor_name VARCHAR(100)
)
BEGIN
    SELECT g.game_number, g.required_tribute_count as tribute_count, 
           g.start_date, g.end_date, g.game_status,
           GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ", ") as victor_names 
    FROM game g
    LEFT JOIN game_victor gv ON g.game_number = gv.game_number
    LEFT JOIN victor v ON gv.victor_id = v.victor_id
    LEFT JOIN tribute t ON v.victor_id = t.tribute_id
    LEFT JOIN participant p ON g.game_number = p.game_number
    LEFT JOIN tribute participant_t ON p.tribute_id = participant_t.tribute_id
    WHERE 1=1
    AND (p_game_number IS NULL OR g.game_number = p_game_number)
    AND (p_tribute_name IS NULL OR participant_t.name LIKE CONCAT('%', p_tribute_name, '%'))
    AND (p_victor_name IS NULL OR t.name LIKE CONCAT('%', p_victor_name, '%'))
    GROUP BY g.game_number, g.start_date, g.end_date, g.required_tribute_count, g.game_status
    ORDER BY g.game_number;
END$$

DELIMITER ;


-- ======================================
-- View gamemakers with optional filters
-- ======================================
DROP PROCEDURE IF EXISTS view_gamemakers;
DELIMITER $$

CREATE PROCEDURE view_gamemakers(p_name VARCHAR(64), p_game_number INT)
BEGIN
    SELECT DISTINCT g.gamemaker_id as gamemaker_id, g.name as name
    FROM gamemaker g
    LEFT JOIN game_creator gc ON g.gamemaker_id = gc.gamemaker_id
    WHERE 1=1
    AND (p_name IS NULL OR g.name LIKE CONCAT('%', p_name, '%'))
    AND (p_game_number IS NULL OR gc.game_number = p_game_number)
    GROUP BY g.gamemaker_id
    ORDER BY g.gamemaker_id;
END $$

DELIMITER ;


-- ========================================
-- View team_members with optional filters
-- ========================================
DROP PROCEDURE IF EXISTS view_team_members;
DELIMITER $$

CREATE PROCEDURE view_team_members(p_name VARCHAR(64), p_member_type VARCHAR(64), p_tribute_name VARCHAR(64))
BEGIN
    SELECT tm.member_id, tm.name, 
           GROUP_CONCAT(DISTINCT tr.member_type ORDER BY tr.member_type SEPARATOR ", ") as roles
    FROM team_member tm
    LEFT JOIN team_role tr ON tm.member_id = tr.member_id
    LEFT JOIN participant p ON tr.participant_id = p.participant_id
    LEFT JOIN tribute t ON p.tribute_id = t.tribute_id
    WHERE 1=1
    AND (p_name IS NULL OR tm.name LIKE CONCAT('%', p_name, '%'))
    AND (p_member_type IS NULL OR tr.member_type = p_member_type)
    AND (p_tribute_name IS NULL OR t.name LIKE CONCAT('%', p_tribute_name, '%'))
    GROUP BY tm.member_id, tm.name
    ORDER BY tm.member_id ASC;
END $$

DELIMITER ;


-- ========================================
-- View participants with optional filters
-- ========================================
DROP PROCEDURE IF EXISTS view_participants;
DELIMITER $$

CREATE PROCEDURE view_participants(p_tribute_name VARCHAR(64), p_age_during_games INT, p_game_number INT, p_training_score INT, p_intelligence_score INT, p_likeability_score INT)
BEGIN
    SELECT * FROM participant_details
    WHERE 1=1 
    AND (p_tribute_name IS NULL OR name LIKE CONCAT('%', p_tribute_name, '%'))
    AND (p_age_during_games IS NULL OR age_during_games = p_age_during_games)
    AND (p_game_number IS NULL OR game_number = p_game_number)
    AND (p_training_score IS NULL OR training_score = p_training_score)
    AND (p_intelligence_score IS NULL OR intelligence_score = p_intelligence_score)
    AND (p_likeability_score IS NULL OR likeability_score = p_likeability_score)
    ORDER BY game_number, district, gender;
END $$
DELIMITER ;


-- ===================================
-- View victors with optional filters
-- ===================================
DROP PROCEDURE IF EXISTS view_victors;
DELIMITER $$

CREATE PROCEDURE view_victors(p_tribute_name VARCHAR(64), p_game_number INT)
BEGIN
    SELECT v.victor_id, t.name, t.district, GROUP_CONCAT(DISTINCT gv.game_number ORDER BY gv.game_number SEPARATOR ', ') as games_won
    FROM victor v
    JOIN game_victor gv ON v.victor_id = gv.victor_id
    JOIN tribute t ON v.victor_id = t.tribute_id
    WHERE 1=1 
    AND (p_tribute_name IS NULL OR t.name LIKE CONCAT('%', p_tribute_name, '%'))
    AND (p_game_number IS NULL OR gv.game_number = p_game_number)
    GROUP BY v.victor_id, t.name, t.district
    ORDER BY v.victor_id ASC;
END $$

DELIMITER ;




-- ===========================================
-- View game staff + gamemakers with filter
-- ===========================================

DROP PROCEDURE IF EXISTS view_game_staff;
DELIMITER $$

CREATE PROCEDURE view_game_staff(p_game_number INT)
BEGIN
    SELECT DISTINCT tm.name as name, tr.member_type as role, CAST(t.district AS CHAR) as district
    FROM participant p
    JOIN team_role tr ON p.participant_id = tr.participant_id
    JOIN team_member tm ON tr.member_id = tm.member_id
    JOIN tribute t ON p.tribute_id = t.tribute_id
    WHERE p.game_number = p_game_number
    UNION
    SELECT gm.name as name, 'Gamemaker' as role, 'Capitol' as district
    FROM game_creator gc
    JOIN gamemaker gm ON gc.gamemaker_id = gm.gamemaker_id
    WHERE gc.game_number = p_game_number;
END $$

DELIMITER ;



-- ============================
-- CRUD PROCEDURE: VIEW full table
-- ============================


DROP PROCEDURE IF EXISTS view_table;
DELIMITER $$

CREATE PROCEDURE view_table (p_table_name VARCHAR(64))
BEGIN
    IF p_table_name = 'tribute' THEN 
        SELECT * FROM tribute ORDER BY tribute_id;
    ELSEIF p_table_name = 'district' THEN 
        SELECT * FROM district ORDER BY district_num;
    ELSEIF p_table_name = 'sponsor' THEN 
        SELECT * FROM sponsor ORDER BY sponsor_id;
    ELSEIF p_table_name = 'gamemaker' THEN 
        SELECT * FROM gamemaker ORDER BY gamemaker_id;
    ELSEIF p_table_name = 'game' THEN 
        SELECT * FROM game ORDER BY game_number;
    ELSEIF p_table_name = 'participant' THEN 
        SELECT * FROM participant ORDER BY participant_id;
    ELSEIF p_table_name = 'team_member' THEN 
        SELECT * FROM team_member ORDER BY member_id;
    ELSEIF p_table_name = 'victor' THEN 
        SELECT * FROM victor ORDER BY victor_id;
    ELSEIF p_table_name = 'team_role' THEN 
        SELECT * FROM team_role ORDER BY member_id, participant_id;
    ELSEIF p_table_name = 'game_creator' THEN 
        SELECT * FROM game_creator ORDER BY game_number, gamemaker_id;
    ELSEIF p_table_name = 'gamemaker_score' THEN 
        SELECT * FROM gamemaker_score ORDER BY participant_id;
    ELSEIF p_table_name = 'sponsorship' THEN 
        SELECT * FROM sponsorship ORDER BY sponsor_id, participant_id;
    ELSEIF p_table_name = 'game_victor' THEN 
        SELECT * FROM game_victor ORDER BY game_number, victor_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid table name';
    END IF;
END $$

DELIMITER ;

-- ============================
-- CRUD PROCEDURES: MANAGE tribute
-- ============================

-- create tribute
DROP PROCEDURE IF EXISTS create_tribute;
DELIMITER $$

CREATE PROCEDURE create_tribute(p_name VARCHAR(64), p_dob DATE, p_gender VARCHAR(1), p_district INT)
BEGIN

    IF (SELECT COUNT(*) FROM district WHERE district_num = p_district) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'District does not exist';
    ELSE
        INSERT INTO tribute(name, dob, gender, district)
        VALUES (p_name, p_dob, p_gender, p_district);
    END IF;
END $$

DELIMITER ;


-- edit tribute
DROP PROCEDURE IF EXISTS edit_tribute;
DELIMITER $$

CREATE PROCEDURE edit_tribute(p_tribute_id INT, p_name VARCHAR(64), p_dob DATE, p_gender VARCHAR(1), p_district INT)
BEGIN
    IF (SELECT COUNT(*) FROM tribute WHERE tribute_id = p_tribute_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute does not exist';
    END IF;

    IF p_district IS NOT NULL AND (SELECT COUNT(*) FROM district WHERE district_num = p_district) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'District does not exist';
    END IF;

    IF p_gender IS NOT NULL AND p_gender NOT IN ('m', 'f') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid gender value';
    END IF;
        UPDATE tribute
        SET name = COALESCE(p_name, name),
            dob = COALESCE(p_dob, dob),
            gender = COALESCE(p_gender, gender),
            district = COALESCE(p_district, district)
        WHERE tribute_id = p_tribute_id;
END $$

DELIMITER ;


-- delete tribute
DROP PROCEDURE IF EXISTS delete_tribute;
DELIMITER $$

CREATE PROCEDURE delete_tribute(p_tribute_id INT)
BEGIN
    IF (SELECT COUNT(*) FROM tribute WHERE tribute_id = p_tribute_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute does not exist';
    ELSE
        DELETE FROM tribute
        WHERE tribute_id = p_tribute_id;
    END IF;
END $$

DELIMITER ;


-- ===============================
-- CRUD PROCEDURES: MANAGE sponsors
-- ===============================

-- create sponsor
DROP PROCEDURE IF EXISTS create_sponsor;
DELIMITER $$

CREATE PROCEDURE create_sponsor(p_name VARCHAR(64))
BEGIN
    INSERT INTO sponsor(name)
    VALUES (p_name);
END $$

DELIMITER ;

-- edit sponsor
DROP PROCEDURE IF EXISTS edit_sponsor;
DELIMITER $$

CREATE PROCEDURE edit_sponsor(p_name VARCHAR(64), p_sponsor_id INT)
BEGIN
    IF (SELECT COUNT(*) FROM sponsor WHERE sponsor_id = p_sponsor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor does not exist';
    ELSE
        UPDATE sponsor
            SET name = COALESCE(p_name, name)
        WHERE sponsor_id = p_sponsor_id;
    END IF;
END $$

DELIMITER ;


-- delete sponsor
DROP PROCEDURE IF EXISTS delete_sponsor;
DELIMITER $$

CREATE PROCEDURE delete_sponsor(p_sponsor_id INT)
BEGIN
    IF (SELECT COUNT(*) FROM sponsor WHERE sponsor_id = p_sponsor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor does not exist';
    ELSE
        DELETE FROM sponsor
        WHERE sponsor_id = p_sponsor_id;
    END IF;
END $$

DELIMITER ;

-- ===============================
-- CRUD PROCEDURES: MANAGE games
-- ===============================

-- create game
DROP PROCEDURE IF EXISTS create_game;
DELIMITER $$

CREATE PROCEDURE create_game(p_game_number INT, p_start_date DATE, p_required_tribute_count INT)
BEGIN
    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game already exists';
    END IF;
    INSERT INTO game(game_number, start_date, required_tribute_count)
    VALUES (p_game_number, p_start_date, p_required_tribute_count);

END $$

DELIMITER ;

-- edit game
DROP PROCEDURE IF EXISTS edit_game;
DELIMITER $$

CREATE PROCEDURE edit_game(p_game_number INT, p_start_date DATE, p_end_date DATE, p_game_status VARCHAR(64), p_required_tribute_count INT)
BEGIN
    
    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
    END IF;

    -- IF p_game_status = 'in progress' AND (SELECT COUNT(*) FROM game WHERE game_status = 'in progress') = 1 THEN
    --     SIGNAL SQLSTATE '45000'
    --     SET MESSAGE_TEXT = 'You already have another game in progress. Set it to complete before starting another one';
    -- END IF;

    UPDATE game
        SET start_date = COALESCE(p_start_date, start_date),
            end_date = COALESCE(p_end_date, end_date),
            game_status = COALESCE(p_game_status, game_status),
            required_tribute_count = COALESCE(p_required_tribute_count, required_tribute_count)
        WHERE game_number = p_game_number;
END $$

DELIMITER ;

-- delete game
DROP PROCEDURE IF EXISTS delete_game;
DELIMITER $$

CREATE PROCEDURE delete_game(p_game_number INT)

BEGIN
    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
    ELSE
        DELETE FROM game
        WHERE game_number = p_game_number;
    END IF;
END $$

DELIMITER ;

-- =================================
-- CRUD PROCEDURES: MANAGE gamemakers
-- =================================

-- create gamemaker
DROP PROCEDURE IF EXISTS create_gamemaker;
DELIMITER $$

CREATE PROCEDURE create_gamemaker(p_name VARCHAR(64))
BEGIN
    INSERT INTO gamemaker(name)
    VALUES (p_name);
END $$

DELIMITER ;

-- edit gamemaker
DROP PROCEDURE IF EXISTS edit_gamemaker;
DELIMITER $$

CREATE PROCEDURE edit_gamemaker(p_name VARCHAR(64), p_gamemaker_id INT)
BEGIN
    IF (SELECT COUNT(*) FROM gamemaker WHERE gamemaker_id= p_gamemaker_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker does not exist';
    ELSE 
        UPDATE gamemaker
            SET name = COALESCE(p_name, name)
            WHERE gamemaker_id = p_gamemaker_id;
    END IF;
END $$

DELIMITER ;

-- delete gamemaker
DROP PROCEDURE IF EXISTS delete_gamemaker;
DELIMITER $$

CREATE PROCEDURE delete_gamemaker(p_gamemaker_id INT)

BEGIN
    IF (SELECT COUNT(*) FROM gamemaker WHERE gamemaker_id= p_gamemaker_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker does not exist';
    ELSE 
        DELETE FROM gamemaker
        WHERE gamemaker_id = p_gamemaker_id;
    END IF;
END $$

DELIMITER ;

-- ===================================
-- CRUD PROCEDURES: MANAGE team members
-- ===================================

-- create team member
DROP PROCEDURE IF EXISTS create_team_member;
DELIMITER $$

CREATE PROCEDURE create_team_member(p_name VARCHAR(64), p_victor_id INT)
BEGIN
    IF p_victor_id IS NOT NULL THEN
        IF (SELECT COUNT(*) FROM victor WHERE victor_id = p_victor_id) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Victor does not exist';
        END IF;
    END IF;
    
        INSERT INTO team_member(name, victor_id)
        VALUES (p_name, p_victor_id);
END $$

DELIMITER ;

-- edit team_member
DROP PROCEDURE IF EXISTS edit_team_member;
DELIMITER $$

CREATE PROCEDURE edit_team_member(p_name VARCHAR(64), p_member_id INT, p_victor_id INT)
BEGIN
    IF p_victor_id IS NOT NULL THEN
        IF (SELECT COUNT(*) FROM victor WHERE victor_id = p_victor_id) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Victor does not exist';
        END IF;
    END IF;
    
    IF (SELECT COUNT(*) FROM team_member WHERE member_id= p_member_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team member does not exist';
    ELSE 
        UPDATE team_member
            SET name = COALESCE(p_name, name),
                victor_id = COALESCE(p_victor_id, victor_id)
                WHERE member_id = p_member_id;
    END IF;
END $$

DELIMITER ;

-- delete team_member
DROP PROCEDURE IF EXISTS delete_team_member;
DELIMITER $$

CREATE PROCEDURE delete_team_member(p_member_id INT)

BEGIN
    IF (SELECT COUNT(*) FROM team_member WHERE member_id= p_member_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team member does not exist';
    ELSE 
        DELETE FROM team_member
        WHERE member_id = p_member_id;
    END IF;
END $$

DELIMITER ;

-- ===================================
-- CRUD PROCEDURE: MANAGE participant
-- ===================================

-- create participant
DROP PROCEDURE IF EXISTS create_participant;
DELIMITER $$

CREATE PROCEDURE create_participant(p_tribute_id INT, p_game_number INT)
BEGIN
    -- Check if tribute exists
    IF (SELECT COUNT(*) FROM tribute WHERE tribute_id = p_tribute_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute does not exist';
    END IF;
    
    -- Check if game exists
    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
    END IF;
    
    -- Check if participant already exists for this tribute and game
    IF (SELECT COUNT(*) FROM participant WHERE tribute_id = p_tribute_id AND game_number = p_game_number) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant already exists for this tribute and game';
    END IF;
    
    INSERT INTO participant(tribute_id, game_number)
    VALUES (p_tribute_id, p_game_number);
END $$

DELIMITER ;



-- edit participant
DROP PROCEDURE IF EXISTS edit_participant;
DELIMITER $$

CREATE PROCEDURE edit_participant(
    p_participant_id VARCHAR(64), 
    p_final_placement INT, 
    p_intelligence_score INT, 
    p_likeability_score INT
)
BEGIN
    IF (SELECT COUNT(*) FROM participant WHERE participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant does not exist';
    ELSE
        -- Validate scores if being set (not NULL and not sentinel)
        IF p_intelligence_score IS NOT NULL AND p_intelligence_score != -1 AND (p_intelligence_score < 1 OR p_intelligence_score > 10) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Intelligence score must be between 1 and 10';
        END IF;
        
        IF p_likeability_score IS NOT NULL AND p_likeability_score != -1 AND (p_likeability_score < 1 OR p_likeability_score > 10) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Likeability score must be between 1 and 10';
        END IF;
        
        UPDATE participant
            SET final_placement = CASE 
                    WHEN p_final_placement = -1 THEN NULL 
                    ELSE COALESCE(p_final_placement, final_placement) 
                END,
                intelligence_score = CASE 
                    WHEN p_intelligence_score = -1 THEN NULL 
                    ELSE COALESCE(p_intelligence_score, intelligence_score) 
                END,
                likeability_score = CASE 
                    WHEN p_likeability_score = -1 THEN NULL 
                    ELSE COALESCE(p_likeability_score, likeability_score) 
                END
            WHERE participant_id = p_participant_id;
    END IF;
END $$


DELIMITER ;


-- delete participant
DROP PROCEDURE IF EXISTS delete_participant;
DELIMITER $$

CREATE PROCEDURE delete_participant(p_participant_id VARCHAR(64))
BEGIN
    IF (SELECT COUNT(*) FROM participant WHERE participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant does not exist';
    ELSE 
        DELETE FROM participant
        WHERE participant_id = p_participant_id;
    END IF;
END $$

DELIMITER ;


-- ================================
-- CRUD PROCEDURES: MANAGE victors
-- ================================

-- view victors (used for delete)
DROP PROCEDURE IF EXISTS view_victors_for_ref;
DELIMITER $$

CREATE PROCEDURE view_victors_for_ref()
BEGIN

    SELECT v.victor_id, t.name as tribute_name
    FROM victor v
    JOIN tribute t ON v.victor_id = t.tribute_id
    ORDER BY v.victor_id;
END $$

DELIMITER ;

-- delete victor
DROP PROCEDURE IF EXISTS delete_victor;
DELIMITER $$

CREATE PROCEDURE delete_victor(p_victor_id INT)

BEGIN
    IF (SELECT COUNT(*) FROM victor WHERE victor_id= p_victor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Victor does not exist';
    ELSE 
        DELETE FROM victor
        WHERE victor_id = p_victor_id;
    END IF;
END $$

DELIMITER ;


-- =================================
-- CRUD PROCEDURES: MANAGE team_role
-- =================================

-- create team role
DROP PROCEDURE IF EXISTS create_team_role;
DELIMITER $$

CREATE PROCEDURE create_team_role(p_member_id INT,  p_participant_id VARCHAR(64), p_member_type VARCHAR(64))
BEGIN
    IF 
    (SELECT COUNT(*) FROM participant WHERE participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant does not exist';
    END IF;

    IF 
    (SELECT COUNT(*) FROM team_member WHERE member_id = p_member_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team Member does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM team_role WHERE member_id = p_member_id AND participant_id = p_participant_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team role already exists for this participant and team member';
    END IF;
    
    INSERT INTO team_role(member_id, participant_id, member_type)
    VALUES (p_member_id, p_participant_id, p_member_type);
END $$

DELIMITER ;

-- edit team role
DROP PROCEDURE IF EXISTS edit_team_role;
DELIMITER $$

CREATE PROCEDURE edit_team_role(p_member_id INT, p_participant_id VARCHAR(64), p_member_type VARCHAR(64))
BEGIN
    
    IF (SELECT COUNT(*) FROM team_role WHERE member_id = p_member_id AND participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team role does not exist';
    ELSE
        
        IF p_member_type IS NOT NULL AND p_member_type NOT IN ('escort', 'mentor', 'stylist', 'prep') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Member type must be escort, mentor, stylist, or prep';
        END IF;
        
        UPDATE team_role
            SET member_type = COALESCE(p_member_type, member_type)
            WHERE member_id = p_member_id 
            AND participant_id = p_participant_id;
    END IF;
END $$

DELIMITER ;


-- view team_roles (used for delete and view)
DROP PROCEDURE IF EXISTS view_team_roles_for_ref;
DELIMITER $$

CREATE PROCEDURE view_team_roles_for_ref()
BEGIN
    SELECT tr.member_id, tr.participant_id, tm.name as member_name, t.name as tribute_name, tr.member_type
    FROM team_role tr
    JOIN team_member tm ON tr.member_id = tm.member_id
    JOIN participant p ON tr.participant_id = p.participant_id
    JOIN tribute t ON p.tribute_id = t.tribute_id
    ORDER BY tr.member_id, tr.participant_id;
END $$

DELIMITER ;

-- delete team role
DROP PROCEDURE IF EXISTS delete_team_role;
DELIMITER $$

CREATE PROCEDURE delete_team_role(p_member_id INT, p_participant_id VARCHAR(64))

BEGIN
    IF (SELECT COUNT(*) FROM team_role WHERE member_id = p_member_id AND participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team role does not exist';
    ELSE 
        DELETE FROM team_role
        WHERE member_id = p_member_id AND participant_id = p_participant_id;
    END IF;
END $$

DELIMITER ;



-- ===================================
-- CRUD PROCEDURES: MANAGE sponsorships
-- ===================================

-- create sponsorship
DROP PROCEDURE IF EXISTS create_sponsorship;
DELIMITER $$

CREATE PROCEDURE create_sponsorship(p_participant_id VARCHAR(64), p_sponsor_id INT, p_sponsor_amount DECIMAL(10, 2))
-- TEST THAT IT WORKS ENTERING IT WITHOUT .00
BEGIN

    IF (SELECT COUNT(*) FROM sponsor WHERE sponsor_id = p_sponsor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsor does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM participant WHERE participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM sponsorship WHERE participant_id = p_participant_id AND sponsor_id = p_sponsor_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsorship already exists for this participant and sponsor';
    END IF;

    INSERT INTO sponsorship(participant_id, sponsor_id, sponsor_amount)
    VALUES (p_participant_id, p_sponsor_id, p_sponsor_amount);

END $$


DELIMITER ;

-- edit sponsorship

DROP PROCEDURE IF EXISTS edit_sponsorship;
DELIMITER $$

CREATE PROCEDURE edit_sponsorship(
    p_sponsor_id INT,
    p_participant_id VARCHAR(64),
    p_sponsor_amount DECIMAL(10,2)
)
BEGIN

    IF (SELECT COUNT(*) FROM sponsorship WHERE sponsor_id = p_sponsor_id AND participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsorship does not exist';
    ELSE
        -- Validate amount if provided
        IF p_sponsor_amount IS NOT NULL AND p_sponsor_amount < 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Amount must be non-negative';
        END IF;
        
        UPDATE sponsorship
            SET sponsor_amount = COALESCE(p_sponsor_amount, sponsor_amount)
            WHERE sponsor_id = p_sponsor_id 
            AND participant_id = p_participant_id;
    END IF;

END $$

DELIMITER ;

-- view sponsorships (used for delete and view)
DROP PROCEDURE IF EXISTS view_sponsorships_for_ref;
DELIMITER $$

CREATE PROCEDURE view_sponsorships_for_ref()
BEGIN
    SELECT s.sponsor_id, s.participant_id, sp.name as sponsor_name, t.name as tribute_name, p.game_number, s.sponsor_amount
    FROM sponsorship s
    JOIN sponsor sp ON s.sponsor_id = sp.sponsor_id
    JOIN participant p ON s.participant_id = p.participant_id
    JOIN tribute t ON p.tribute_id = t.tribute_id
    ORDER BY s.sponsor_id, s.participant_id;
END $$

DELIMITER ;


-- delete sponsorship
DROP PROCEDURE IF EXISTS delete_sponsorship;
DELIMITER $$

CREATE PROCEDURE delete_sponsorship(p_sponsor_id INT, p_participant_id VARCHAR(64))

BEGIN
    IF (SELECT COUNT(*) FROM sponsorship WHERE p_sponsor_id = sponsor_id AND p_participant_id = participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sponsorship does not exist';
    ELSE 
        DELETE FROM sponsorship
        WHERE p_sponsor_id = sponsor_id AND p_participant_id = participant_id;
    END IF;
END $$

DELIMITER ;

-- ====================================
-- CRUD PROCEDURES: MANAGE game_creators
-- ====================================

-- create game creator
DROP PROCEDURE IF EXISTS create_game_creator;
DELIMITER $$

CREATE PROCEDURE create_game_creator(p_game_number INT, p_gamemaker_id INT)
BEGIN

    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM gamemaker WHERE gamemaker_id = p_gamemaker_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM game_creator WHERE game_number = p_game_number AND gamemaker_id = p_gamemaker_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game creator already exists for this gamemaker and game number';
    END IF;

    INSERT INTO game_creator(game_number, gamemaker_id)
    VALUES (p_game_number, p_gamemaker_id);
END $$

DELIMITER ;

-- view game_creators (used for delete and view)
DROP PROCEDURE IF EXISTS view_game_creators_for_ref;
DELIMITER $$

CREATE PROCEDURE view_game_creators_for_ref()
BEGIN
    SELECT gc.game_number, gc.gamemaker_id, gm.name as gamemaker_name
    FROM game_creator gc
    JOIN gamemaker gm ON gc.gamemaker_id = gm.gamemaker_id
    ORDER BY gc.game_number, gc.gamemaker_id;
END $$

DELIMITER ;


-- delete game creator

DROP PROCEDURE IF EXISTS delete_game_creator;
DELIMITER $$

CREATE PROCEDURE delete_game_creator(p_game_number INT, p_gamemaker_id INT)

BEGIN
    IF (SELECT COUNT(*) FROM game_creator WHERE p_game_number = game_number AND p_gamemaker_id = gamemaker_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game creator does not exist';
    ELSE 
        DELETE FROM game_creator
        WHERE p_game_number = game_number AND p_gamemaker_id = gamemaker_id;
    END IF;
END $$

DELIMITER ;

-- ===================================
-- CRUD PROCEDURES: MANAGE game_victor
-- ===================================

-- create game victor
DROP PROCEDURE IF EXISTS create_game_victor;
DELIMITER $$

CREATE PROCEDURE create_game_victor (p_game_number INT, p_victor_id INT)
BEGIN

    IF (SELECT COUNT(*) FROM game WHERE game_number = p_game_number) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM victor WHERE victor_id = p_victor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Victor does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM game_victor WHERE game_number = p_game_number AND victor_id = p_victory_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game victor already exists for this victor and game number';
    END IF;

    IF (SELECT COUNT(*) 
    FROM participant p
    JOIN tribute t ON p.tribute_id = t.tribute_id
    JOIN victor v ON t.tribute_id = v.victor_id
    WHERE p.game_number = p_game_number AND t.tribute_id = p_victor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Victor was not a participant in the provided games";
    END IF;

    INSERT INTO game_victor(game_number, victor_id)
    VALUES (p_game_number, p_victor_id);
END $$


DELIMITER ;

-- view game_victors (used for delete and view)
DROP PROCEDURE IF EXISTS view_game_victors_for_ref;
DELIMITER $$

CREATE PROCEDURE view_game_victors_for_ref()
BEGIN
    SELECT gv.game_number, gv.victor_id, t.name as tribute_name
    FROM game_victor gv
    JOIN victor v ON gv.victor_id = v.victor_id
    JOIN tribute t ON v.victor_id = t.tribute_id
    ORDER BY gv.game_number, gv.victor_id;
END $$

DELIMITER ;

-- delete game victor

DROP PROCEDURE IF EXISTS delete_game_victor;
DELIMITER $$

CREATE PROCEDURE delete_game_victor(p_game_number INT, p_victor_id INT)

BEGIN
    IF (SELECT COUNT(*) FROM game_victor WHERE p_game_number = game_number AND p_victor_id = victor_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Game victor does not exist';
    ELSE 
        DELETE FROM game_victor
        WHERE p_game_number = game_number AND p_victor_id = victor_id;
    END IF;
END $$

DELIMITER ;

-- =======================================
-- CRUD PROCEDURES: MANAGE gamemaker_scores
-- =======================================

-- create gamemaker score
DROP PROCEDURE IF EXISTS create_gamemaker_score;
DELIMITER $$

CREATE PROCEDURE create_gamemaker_score(p_gamemaker_id INT, p_participant_id VARCHAR(64), p_assessment_score INT)

BEGIN
    IF (SELECT COUNT(*) FROM participant WHERE participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participant does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM gamemaker WHERE gamemaker_id = p_gamemaker_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker does not exist';
    END IF;

    IF (SELECT COUNT(*) FROM gamemaker_score WHERE participant_id = p_participant_id AND gamemaker_id = p_gamemaker_id > 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker score already exists for this participant and gamemaker';
    END IF;

    INSERT INTO gamemaker_score(gamemaker_id, participant_id, assessment_score)
    VALUES (p_gamemaker_id, p_participant_id, p_assessment_score);

END $$

DELIMITER ;


-- edit gamemaker score
DROP PROCEDURE IF EXISTS edit_gamemaker_score;
DELIMITER $$

CREATE PROCEDURE edit_gamemaker_score(p_gamemaker_id INT, p_participant_id VARCHAR(64), p_assessment_score INT)
BEGIN
    
    IF (SELECT COUNT(*) FROM gamemaker_score WHERE gamemaker_id = p_gamemaker_id AND participant_id = p_participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gamemaker score does not exist';
    ELSE
        
        IF p_assessment_score IS NOT NULL AND (p_assessment_score < 1 OR p_assessment_score > 12) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Assessment score must be between 1 and 12';
        END IF;
        
        UPDATE gamemaker_score
            SET assessment_score = COALESCE(p_assessment_score, assessment_score)
            WHERE gamemaker_id = p_gamemaker_id 
            AND participant_id = p_participant_id;
    END IF;
END $$

DELIMITER ;

-- view gamemaker_scores (used for delete and view)
DROP PROCEDURE IF EXISTS view_gamemaker_scores_for_ref;
DELIMITER $$

CREATE PROCEDURE view_gamemaker_scores_for_ref()
BEGIN
    SELECT gs.gamemaker_id, gs.participant_id, gm.name as gamemaker_name, t.name as tribute_name, p.game_number, gs.assessment_score
    FROM gamemaker_score gs
    JOIN gamemaker gm ON gs.gamemaker_id = gm.gamemaker_id
    JOIN participant p ON gs.participant_id = p.participant_id
    JOIN tribute t ON p.tribute_id = t.tribute_id
    ORDER BY gs.gamemaker_id, gs.participant_id;
END $$

DELIMITER ;

-- delete gamemaker score
DROP PROCEDURE IF EXISTS delete_gamemaker_score;
DELIMITER $$

CREATE PROCEDURE delete_gamemaker_score(p_gamemaker_id INT, p_participant_id VARCHAR(64))

BEGIN
    IF (SELECT COUNT(*) FROM gamemaker_score WHERE p_gamemaker_id = gamemaker_id AND p_participant_id = participant_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This gamemaker score does not exist';
    ELSE 
        DELETE FROM gamemaker_score
        WHERE p_gamemaker_id = gamemaker_id AND p_participant_id = participant_id;
    END IF;
END $$

DELIMITER ;

-- ===========================================================================
-- TRIGGER: adds the intended start date based on the game number
-- which is used to get the year
-- ===========================================================================

DROP TRIGGER IF EXISTS set_game_start_date;
DELIMITER $$

CREATE TRIGGER set_game_start_date
BEFORE INSERT ON game
FOR EACH ROW
BEGIN

	DECLARE base_year INT DEFAULT 0018; -- end of rebellion, first games in 19
    DECLARE game_year INT;
    
    SET game_year = base_year + NEW.game_number;

	IF NEW.start_date IS NULL THEN
		SET NEW.start_date = CAST(CONCAT(LPAD(game_year, 4, '0'), '-07-11') AS DATE);
	END IF;
    
END $$

DELIMITER ;


-- ===========================================================================
-- TRIGGER: auto-generates participant_id in format: game.district.gender.num
-- ===========================================================================
DROP TRIGGER IF EXISTS set_participant_id;

DELIMITER $$
CREATE TRIGGER set_participant_id
BEFORE INSERT ON participant
FOR EACH ROW
BEGIN
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
END $$

DELIMITER ;

-- ===========================================================================
-- TRIGGER: verifies the participant's age is between 12 and 18
-- outputs a signal for the user to check the confirm one of the following and
-- make corrections as needed :
-- 	- game date
--  - tribute dob
-- ===========================================================================
DROP TRIGGER IF EXISTS verify_participant_age;
DELIMITER $$

CREATE TRIGGER verify_participant_age
BEFORE INSERT ON participant
FOR EACH ROW
BEGIN
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

END $$

DELIMITER ;


-- ===========================================================================
-- TRIGGER: prevents participant insertion if required number of tributes
-- for the games has already been reached
-- outputs a signal
-- ===========================================================================
DROP TRIGGER IF EXISTS limit_participant_count;
DELIMITER $$

CREATE TRIGGER limit_participant_count
BEFORE INSERT ON participant
FOR EACH ROW
BEGIN

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

END $$

DELIMITER ;


-- ===========================================================================
-- TRIGGER: when final_placement is set to 1, create victor if it doesn't 
-- exist and then insert into game_victor to set game's victor
-- ===========================================================================
DROP TRIGGER IF EXISTS set_victor_upon_winner_inserted;
DELIMITER $$

CREATE TRIGGER set_victor_upon_winner_inserted
AFTER INSERT ON participant
FOR EACH ROW
BEGIN
	IF NEW.final_placement = 1 THEN
		-- create victor if not exists
		CALL create_victor_from_tribute(NEW.tribute_id);
		-- set victor
		CALL set_game_victor(NEW.game_number, NEW.tribute_id);
	END IF;
END $$

DELIMITER ;


-- ===========================================================================
-- TRIGGER: when final_placement is updated to 1, create victor if it 
-- doesn't exist and then insert into game_victor to set game's victor

--          if the final_placement is updated from 1 to something else,
--          remove game_victor
-- ===========================================================================
DROP TRIGGER IF EXISTS set_victor_upon_winner_updated;

DELIMITER $$

CREATE TRIGGER set_victor_upon_winner_updated
AFTER UPDATE ON participant
FOR EACH ROW
BEGIN
    IF NEW.final_placement = 1 AND (OLD.final_placement IS NULL OR OLD.final_placement != 1) THEN
        -- create victor if not exists
        CALL create_victor_from_tribute(NEW.tribute_id);
        -- set victor
        CALL set_game_victor(NEW.game_number, NEW.tribute_id);

    -- delete game_victor if changed from 1 to something else
    ELSEIF (NEW.final_placement != 1 OR NEW.final_placement IS NULL) AND (OLD.final_placement = 1) THEN
        DELETE FROM game_victor 
        WHERE game_number = NEW.game_number 
            AND victor_id = NEW.tribute_id;

    END IF;
END $$

DELIMITER ;

-- ======================================================================
-- TRIGGER: delete victor after game_victor as long as victor_id 
-- is not used in another game_victor
-- ======================================================================
DROP TRIGGER IF EXISTS cleanup_victor_after_game_victor_delete;
DELIMITER $$
CREATE TRIGGER cleanup_victor_after_game_victor_delete
AFTER DELETE ON game_victor
FOR EACH ROW
BEGIN
    -- If this victor has no more wins, delete them
    IF NOT EXISTS (
        SELECT 1 FROM game_victor 
        WHERE victor_id = OLD.victor_id
    ) THEN
        DELETE FROM victor WHERE victor_id = OLD.victor_id;
    END IF;
END $$

DELIMITER ;
-- ===================================
-- VIEW: Displays participant details
-- ===================================
CREATE OR REPLACE VIEW participant_details AS
SELECT 
    p.participant_id,
    t.name,
    t.district,
    t.gender,
    p.game_number,
    get_participant_age(p.participant_id) AS age_during_games,
    get_training_score(p.participant_id) AS training_score,
    p.intelligence_score,
    p.likeability_score,
    p.final_placement
FROM participant p
JOIN tribute t ON p.tribute_id = t.tribute_id;







-- ============================
-- TESTING DATA DUMP
-- ============================

-- Insert Districts (1-12)
INSERT INTO district (district_num, industry, size, wealth) VALUES
(1, 'Luxury', 'Medium', 'Wealthy'),
(2, 'Masonry', 'Large', 'Wealthy'),
(3, 'Technology', 'Large', 'Middle Class'),
(4, 'Fishing', 'Medium', 'Wealthy'),
(5, 'Power', 'Small', 'Working Class'),
(6, 'Transportation', 'Large', 'Working Class'),
(7, 'Lumber', 'Medium', 'Working Class'),
(8, 'Textiles', 'Medium', 'Poor'),
(9, 'Grain', 'Medium', 'Working Class'),
(10, 'Livestock', 'Medium', 'Working Class'),
(11, 'Agriculture', 'Large', 'Poor'),
(12, 'Coal Mining', 'Small', 'Poor');

-- Insert tributes
INSERT INTO tribute (name, dob, gender, district) VALUES
('Katniss Everdeen', '0076-05-08', 'f', 12),
('Peeta Mellark', '0076-03-12', 'm', 12),
('Rue', '0080-03-05', 'f', 11),
('Thresh', '0074-01-28', 'm', 11),
('Mags', '0012-02-10', 'f', 4),
('Finnick Odair', '0069-08-17', 'm', 4),
('Annie Cresta', '0069-11-05', 'f', 4),
('Johanna Mason', '0072-10-08', 'f', 7),
('Wiress', '0049-03-22', 'f', 3),
('Beetee Latier', '0034-07-14', 'm', 3),
('Glimmer', '0075-04-19', 'f', 1),
('Marvel', '0075-12-02', 'm', 1),
('Cashmere', '0068-05-30', 'f', 1),
('Gloss', '0066-05-30', 'm', 1),
('Cato', '0074-02-14', 'm', 2),
('Clove', '0077-01-23', 'f', 2),
('Enobaria', '0063-08-08', 'f', 2),
('Brutus', '0050-01-11', 'm', 2),
('Foxface', '0076-09-27', 'f', 5),

('Blight', '0055-03-15', 'm', 7),
('Cecelia', '0061-04-22', 'f', 8),


('Facet', '0012-09-15', 'm', 1),           
('Velvereen', '0013-02-20', 'f', 1),       
('Marcus', '0010-01-08', 'm', 2),          
('Sabyn', '0012-06-12', 'f', 2),           
('Circ', '0013-08-03', 'm', 3),            
('Teslee', '0012-11-18', 'f', 3),          
('Mizzen', '0015-04-22', 'm', 4),          
('Coral', '0010-12-30', 'f', 4),           
('Hy', '0013-07-14', 'm', 5),              
('Sol', '0012-10-08', 'f', 5),             
('Otto', '0014-03-25', 'm', 6),            
('Ginnee', '0016-05-17', 'f', 6),          
('Treech', '0011-09-20', 'm', 7),          
('Lamina', '0012-01-11', 'f', 7),          
('Bobbin', '0015-08-28', 'm', 8),          
('Wovey', '0016-03-08', 'f', 8),           
('Panlo', '0013-12-05', 'm', 9),           
('Sheaf', '0013-04-19', 'f', 9),           
('Tanner', '0012-02-27', 'm', 10),         
('Brandy', '0011-06-30', 'f', 10),         
('Reaper Ash', '0010-05-05', 'm', 11),     
('Dill', '0016-06-22', 'f', 11),           
('Jessup Diggs', '0010-03-14', 'm', 12),   
('Lucy Gray Baird', '0012-03-10', 'f', 12),



('Louella McCoy', '0055-10-09', 'f', 12),        
('Maysilee Donner', '0052-06-20', 'f', 12),
('Wyatt Callow', '0050-05-21', 'm', 12),           
('Haymitch Abernathy', '0052-07-04', 'm', 12),

('Ampert Latier', '0056-02-05', 'm', 3),
('Silka Sharp', '0055-10-22', 'f', 1),
('Wellie', '0055-12-15', 'f', 6);


-- TEAM MEMBERS
INSERT INTO team_member (name) VALUES

('Effie Trinket'),
('Haymith Abernathy'),
('Cinna'),
('Portia'),
('Octavia'),
('Flavius'),
('Venia'),



('Tigris'),


('Persephone Trinket'),
('Drusilla Sickle'),
('Magno Stift'),


('Sejanus Plinth'),
('Coriolanus Snow'),
('Lysistrata Vickers'),
('Clemensia Dovecote'),
('Arachne Crane'),
('Festus Creed'),
('Livia Cardew'),
('Pup Harrington'),
('Hilarius Heavensbee'),
('Juno Phipps'),
('Felix Ravinstill'),
('Vispania Sickle'),
('Io Jasper'),
('Androcles Anderson'),
('Gaius Breen'),
('Urban Canville'),
('Dennis Fling'),
('Florus Friend'),
('Palmyra Monty'),
('Iphigenia Moss'),
('Persephone Price'),
('Apollo Ring'),
('Diana Ring'),
('Domitia Whimsiwick'),

('Juvenia');




INSERT INTO gamemaker (name) VALUES

('Plutarch Heavensbee'),

('Seneca Crane'),
('Lucia'), 

('Dr. Volumina Gaul'),

('Joe Shmoe'),
('Heaven Heavensbee'),
('Grapefruit Cornelius'),
('Coriolanus Snow'),


('Fabricius Lavish'),
('Octavia Glimmerstone'),
('Aurelius Grandeur'),
('Celestia Ravencrest'),
('Magnus Silverworth'),
('Persephone Nightshade'),
('Tiberius Goldleaf'),
('Lavinia Crystalline'),
('Maximus Opulence'),
('Seraphina Moonwhisper'),
('Claudius Velvetine'),
('Anastasia Starling'),
('Cassius Brightwell'),
('Temperance Frostbane'),
('Valentino Luxor'),
('Cordelia Ashworth'),
('Dominic Regalia'),
('Evangeline Silkwood'),
('Augustus Primerose'),
('Calliope Wintermere'),
('Marcellus Thornwick'),
('Isadora Gemstone'),
('Thaddeus Brightvale'),
('Ophelia Crystalheart'),
('Reginald Goldsworth');

INSERT INTO game (game_number, required_tribute_count) VALUES
(74, DEFAULT),
(75, DEFAULT),
(10, DEFAULT),
(62, DEFAULT),
(63, DEFAULT),
(64, DEFAULT),
(65, DEFAULT),
(50, 48),
(71, DEFAULT),
(11, DEFAULT),
(34, DEFAULT),
(49, DEFAULT),
(70, DEFAULT);

INSERT INTO game_creator (gamemaker_id, game_number) VALUES
-- Game 10 (Just Gaul)
(4, 10),
-- Game 11 (Just Gaul)
(4, 11),
-- Game 34 (4 gamemakers)
(14, 34), (15, 34), (16, 34), (17, 34),
-- Game 49 (5 gamemakers)
(20, 49), (21, 49), (22, 49), (23, 49), (24, 49),
-- Game 50 (5 gamemakers)
(6, 50), (7, 50), (22, 50), (9, 50), (10, 50),
-- Game 62 (5 gamemakers)
(14, 62), (15, 62), (16, 62), (17, 62), (18, 62),
-- Game 63 (5 gamemakers)
(20, 63), (21, 63), (22, 63), (23, 63), (24, 63),
-- Game 64 (5 gamemakers)
(6, 64), (7, 64), (12, 64), (9, 64), (10, 64),
-- Game 65 (5 gamemakers)
(12, 65), (13, 65), (14, 65), (15, 65), (16, 65),
-- Game 70 (5 gamemakers)
(18, 70), (19, 70), (20, 70), (21, 70), (22, 70),
-- Game 71 (5 gamemakers - Seneca's first year)
(2, 71), (25, 71), (6, 71), (7, 71), (4, 71),
-- Game 74 (5 gamemakers - Seneca with Lucia)
(2, 74), (3, 74), (12, 74), (13, 74), (14, 74),
-- Game 75 (5 gamemakers - Plutarch's Quarter Quell)
(1, 75), (20, 75), (21, 75), (22, 75), (23, 75);

-- INSERT PARTICIPANTS

CALL add_participant_by_name('Facet', 10);
CALL add_participant_by_name('Velvereen', 10);
CALL add_participant_by_name('Marcus', 10);
CALL add_participant_by_name('Sabyn', 10);
CALL add_participant_by_name('Circ', 10);
CALL add_participant_by_name('Teslee', 10);
CALL add_participant_by_name('Mizzen', 10);
CALL add_participant_by_name('Coral', 10);
CALL add_participant_by_name('Hy', 10);
CALL add_participant_by_name('Sol', 10);
CALL add_participant_by_name('Otto', 10);
CALL add_participant_by_name('Ginnee', 10);
CALL add_participant_by_name('Treech', 10);
CALL add_participant_by_name('Lamina', 10);
CALL add_participant_by_name('Bobbin', 10);
CALL add_participant_by_name('Wovey', 10);
CALL add_participant_by_name('Panlo', 10);
CALL add_participant_by_name('Sheaf', 10);
CALL add_participant_by_name('Tanner', 10);
CALL add_participant_by_name('Brandy', 10);
CALL add_participant_by_name('Reaper Ash', 10);
CALL add_participant_by_name('Dill', 10);
CALL add_participant_by_name('Jessup Diggs', 10);
CALL add_participant_by_name('Lucy Gray Baird', 10);

-- 50th Hunger Games (year 68)
CALL add_participant_by_name('Louella McCoy', 50);
CALL add_participant_by_name('Maysilee Donner', 50);
CALL add_participant_by_name('Wyatt Callow', 50);
CALL add_participant_by_name('Haymitch Abernathy', 50);
CALL add_participant_by_name('Silka Sharp', 50);
CALL add_participant_by_name('Ampert Latier', 50);
CALL add_participant_by_name('Wellie', 50);


-- 75th tributes past games
CALL add_participant_by_name('Mags', 11);
CALL add_participant_by_name('Finnick Odair', 65);
CALL add_participant_by_name('Annie Cresta', 70);
CALL add_participant_by_name('Johanna Mason', 71);
CALL add_participant_by_name('Wiress', 49);
CALL add_participant_by_name('Beetee Latier', 34);
CALL add_participant_by_name('Cashmere', 64);
CALL add_participant_by_name('Gloss', 63);
CALL add_participant_by_name('Enobaria', 62);


-- 74th Hunger Games (year 94)
CALL add_participant_by_name('Katniss Everdeen', 74);
CALL add_participant_by_name('Peeta Mellark', 74);
CALL add_participant_by_name('Rue', 74);
CALL add_participant_by_name('Thresh', 74);
CALL add_participant_by_name('Foxface', 74);
CALL add_participant_by_name('Glimmer', 74);
CALL add_participant_by_name('Marvel', 74);
CALL add_participant_by_name('Cato', 74);
CALL add_participant_by_name('Clove', 74);

-- 75th Hunger Games (Quarter Quell, year 95)
CALL add_participant_by_name('Katniss Everdeen', 75);
CALL add_participant_by_name('Peeta Mellark', 75);
CALL add_participant_by_name('Mags', 75);
CALL add_participant_by_name('Finnick Odair', 75);
CALL add_participant_by_name('Johanna Mason', 75);
CALL add_participant_by_name('Wiress', 75);
CALL add_participant_by_name('Beetee Latier', 75);
CALL add_participant_by_name('Cashmere', 75);
CALL add_participant_by_name('Gloss', 75);
CALL add_participant_by_name('Enobaria', 75);
CALL add_participant_by_name('Brutus', 75);
CALL add_participant_by_name('Blight', 75);
CALL add_participant_by_name('Cecelia', 75);


# ADD GAME VICTORS BY SETTING PLACEMENT TO 1
CAll edit_participant('10.12.f.1', 1, NULL, NULL);
CAll edit_participant('11.4.f.1', 1, NULL, NULL);
CAll edit_participant('65.4.m.1', 1, NULL, NULL);
CAll edit_participant('70.4.f.1', 1, NULL, NULL);
CAll edit_participant('71.7.f.1', 1, NULL, NULL);
CAll edit_participant('49.3.f.1', 1, NULL, NULL);
CAll edit_participant('34.3.m.1', 1, NULL, NULL);
CAll edit_participant('64.1.f.1', 1, NULL, NULL);
CAll edit_participant('63.1.m.1', 1, NULL, NULL);
CAll edit_participant('62.2.f.1', 1, NULL, NULL);
CAll edit_participant('50.12.m.2', 1, NULL, NULL);

# SETTING FINAL PLACEMENTS

-- 50th arena deaths
CALL edit_participant('10.11.m.1', 2, NULL, NULL);  -- Reaper Ash
CALL edit_participant('10.7.m.1', 3, NULL, NULL);   -- Treech
CALL edit_participant('10.3.f.1', 4, NULL, NULL);   -- Teslee
CALL edit_participant('10.4.m.1', 5, NULL, NULL);   -- Mizzen
CALL edit_participant('10.4.f.1', 6, NULL, NULL);   -- Coral
CALL edit_participant('10.3.m.1', 7, NULL, NULL);   -- Circ
CALL edit_participant('10.8.f.1', 8, NULL, NULL);   -- Wovey
CALL edit_participant('10.10.m.1', 9, NULL, NULL);  -- Tanner
CALL edit_participant('10.7.f.1', 10, NULL, NULL);  -- Lamina
CALL edit_participant('10.12.m.1', 11, NULL, NULL); -- Jessup Diggs
CALL edit_participant('10.5.f.1', 12, NULL, NULL);  -- Sol
CALL edit_participant('10.8.m.1', 13, NULL, NULL);  -- Bobbin
CALL edit_participant('10.11.f.1', 14, NULL, NULL); -- Dill
CALL edit_participant('10.2.m.1', 15, NULL, NULL);  -- Marcus

-- 50th Pre-Games Deaths (16-24)
CALL edit_participant('10.5.m.1', 16, NULL, NULL);  -- Hy
CALL edit_participant('10.9.m.1', 17, NULL, NULL);  -- Panlo
CALL edit_participant('10.9.f.1', 18, NULL, NULL);  -- Sheaf
CALL edit_participant('10.2.f.1', 19, NULL, NULL);  -- Sabyn
CALL edit_participant('10.1.m.1', 20, NULL, NULL);  -- Facet
CALL edit_participant('10.1.f.1', 21, NULL, NULL);  -- Velvereen
CALL edit_participant('10.6.m.1', 22, NULL, NULL);  -- Otto
CALL edit_participant('10.6.f.1', 23, NULL, NULL);  -- Ginnee
CALL edit_participant('10.10.f.1', 24, NULL, NULL); -- Brandy


# misc

CAll edit_participant('50.1.f.1', 2, NULL, NULL);
CAll edit_participant('50.6.f.1', 3, NULL, NULL);
CAll edit_participant('50.12.f.2', 4, NULL, NULL);
CAll edit_participant('74.2.m.1', 3, NULL, NULL);
CAll edit_participant('74.11.m.1', 4, NULL, NULL);


CALL edit_game(74, NULL, NULL, 'in progress', NULL);



INSERT INTO sponsor (name) VALUES
('Pieceof CapitolHorseShit'),
("Catos's Groupies"),
("Glimmer's GlamSquad"),
("The Four Leaf CLOVErs"),
("Peeta Bread"),
("Capitol Bullshit"),
("Pompous Heavensbee"),
("Creme Brulee"),
("Twinkle Lowbottom"),
("Platinum Periwinkle"),
("Caviar Cardew"),
("Flambee Flickerman")
;



INSERT INTO team_role (member_id, member_type, participant_id) VALUES
(1, 'escort', '74.12.F.1'),
(1, 'escort', '74.12.M.1'),
(2, 'mentor', '74.12.F.1'),
(2, 'mentor', '74.12.M.1'),
(3, 'stylist', '74.12.F.1'),
(4, 'stylist', '74.12.M.1'),
(5, 'prep', '74.12.F.1'),
(5, 'prep', '74.12.M.1'),
(6, 'prep', '74.12.F.1'),
(6, 'prep', '74.12.M.1'),
(7, 'prep', '74.12.F.1'),
(7, 'prep', '74.12.M.1'),

(1, 'escort', '75.12.F.1'),
(1, 'escort', '75.12.M.1'),
(2, 'mentor', '75.12.F.1'),
(2, 'mentor', '75.12.M.1'),
(3, 'stylist', '75.12.F.1'),
(4, 'stylist', '75.12.M.1'),
(5, 'prep', '75.12.F.1'),
(5, 'prep', '75.12.M.1'),
(6, 'prep', '75.12.F.1'),
(6, 'prep', '75.12.M.1'),
(7, 'prep', '75.12.F.1'),
(7, 'prep', '75.12.M.1'),

(36, 'escort', '74.1.M.1'),
(36, 'escort', '74.1.F.1'),

(1, 'stylist', '50.12.F.1'),
(1, 'stylist', '50.12.M.1'),
(1, 'stylist', '50.12.F.2'),
(1, 'stylist', '50.12.M.2'),

(9, 'prep', '50.12.F.1'),
(9, 'prep', '50.12.F.2'),
(9, 'prep', '50.12.M.1'),
(9, 'prep', '50.12.M.2'),

(10, 'escort', '50.12.F.1'),
(10, 'escort', '50.12.F.2'),
(10, 'escort', '50.12.M.1'),
(10, 'escort', '50.12.M.2'),

(11, 'stylist', '50.12.F.1'),
(11, 'stylist', '50.12.M.1'),
(11, 'stylist', '50.12.F.2'),
(11, 'stylist', '50.12.M.2'),


(18, 'mentor', '10.1.M.1'), 
(30, 'mentor', '10.1.F.1'), 
(12, 'mentor', '10.2.M.1'), 
(29, 'mentor', '10.2.F.1'), 
(24, 'mentor', '10.3.M.1'), 
(27, 'mentor', '10.3.F.1'), 
(32, 'mentor', '10.4.M.1'), 
(17, 'mentor', '10.4.F.1'), 
(28, 'mentor', '10.5.M.1'), 
(31, 'mentor', '10.5.F.1'), 
(33, 'mentor', '10.6.M.1'), 
(34, 'mentor', '10.6.F.1'), 
(23, 'mentor', '10.7.M.1'), 
(19, 'mentor', '10.7.F.1'), 
(21, 'mentor', '10.8.M.1'), 
(20, 'mentor', '10.8.F.1'), 
(25, 'mentor', '10.9.M.1'), 
(26, 'mentor', '10.9.F.1'), 
(16, 'mentor', '10.10.F.1'), 
(35, 'mentor', '10.10.M.1'), 
(15, 'mentor', '10.11.M.1'), 
(22, 'mentor', '10.11.F.1'), 
(14, 'mentor', '10.12.M.1'), 
(13, 'mentor', '10.12.F.1'); 



INSERT INTO sponsorship (sponsor_id, participant_id, sponsor_amount) VALUES
(2, '74.2.M.1', 7000),        -- Cato
(3, '74.1.F.1', 6000),        -- Glimmer
(4, '74.2.F.1', 5500),        -- Clove
(5, '74.12.M.1', 8000),       -- Peeta
(1, '10.1.F.1', 5221),
(6, '10.1.M.1', 4029),
(7, '10.10.F.1', 6759),
(8, '10.10.M.1', 3644),
(9, '10.11.F.1', 4149),
(10, '10.11.M.1', 4562),
(11, '10.12.F.1', 5956),
(12, '10.12.M.1', 2579),
(1, '10.2.F.1', 3754),
(6, '10.2.M.1', 2086),
(7, '10.3.F.1', 3572),
(8, '10.3.M.1', 5594),
(9, '10.4.F.1', 5478),
(10, '10.4.M.1', 4612),
(11, '10.5.F.1', 5948),
(12, '10.5.M.1', 3843),
(1, '10.6.F.1', 4963),
(6, '10.6.M.1', 5038),
(7, '10.7.F.1', 3669),
(8, '10.7.M.1', 5020),
(9, '10.8.F.1', 5689),
(10, '10.8.M.1', 2198),
(11, '10.9.F.1', 5738),
(12, '10.9.M.1', 5491),
(1, '11.4.F.1', 3183),
(6, '34.3.M.1', 3618),
(7, '49.3.F.1', 6731),
(8, '50.12.F.1', 3781),
(9, '50.12.F.2', 4914),
(10, '50.12.M.1', 4967),
(11, '50.12.M.2', 2643),
(12, '62.2.F.1', 3565),
(1, '63.1.M.1', 2617),
(6, '64.1.F.1', 5130),
(7, '65.4.M.1', 5602),
(8, '70.4.F.1', 2132),
(9, '71.7.F.1', 6416),
(10, '74.1.F.1', 2735),
(11, '74.1.M.1', 6642),
(12, '74.11.F.1', 4105),
(1, '74.11.M.1', 3532),
(6, '74.12.F.1', 2965),
(7, '74.12.M.1', 6613),
(8, '74.2.F.1', 3645),
(9, '74.2.M.1', 3818),
(10, '74.5.F.1', 5922),
(11, '75.1.F.1', 6740),
(12, '75.1.M.1', 4274),
(1, '75.12.F.1', 5499),
(6, '75.12.M.1', 2122),
(7, '75.2.F.1', 2283),
(8, '75.2.M.1', 4648),
(9, '75.3.F.1', 2794),
(10, '75.3.M.1', 3975),
(11, '75.4.F.1', 4135),
(12, '75.4.M.1', 2094),
(1, '75.7.F.1', 5362),
(6, '75.7.M.1', 6350),
(7, '75.8.F.1', 5712);


-- SCORES
-- Game 11 (1 tribute, 1 gamemaker)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('11.4.F.1', 4, 7);
-- Game 34 (1 tribute, 4 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('34.3.M.1', 14, 8), ('34.3.M.1', 15, 7), ('34.3.M.1', 16, 5), ('34.3.M.1', 17, 8);
-- Game 49 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('49.3.F.1', 20, 4), ('49.3.F.1', 21, 3), ('49.3.F.1', 22, 4), ('49.3.F.1', 23, 2), ('49.3.F.1', 24, 2);
-- Game 50 (4 tributes, 5 gamemakers each)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('50.12.F.1', 6, 5), ('50.12.F.1', 7, 3), ('50.12.F.1', 8, 6), ('50.12.F.1', 9, 4), ('50.12.F.1', 10, 7),
('50.12.F.2', 6, 6), ('50.12.F.2', 7, 2), ('50.12.F.2', 8, 6), ('50.12.F.2', 9, 6), ('50.12.F.2', 10, 1),
('50.12.M.1', 6, 8), ('50.12.M.1', 7, 9), ('50.12.M.1', 8, 5), ('50.12.M.1', 9, 5), ('50.12.M.1', 10, 8),
('50.12.M.2', 6, 3), ('50.12.M.2', 7, 1), ('50.12.M.2', 8, 1), ('50.12.M.2', 9, 1), ('50.12.M.2', 10, 1);
-- Game 62 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('62.2.F.1', 14, 11), ('62.2.F.1', 15, 12), ('62.2.F.1', 16, 11), ('62.2.F.1', 17, 10), ('62.2.F.1', 18, 12);
-- Game 63 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('63.1.M.1', 20, 10), ('63.1.M.1', 21, 10), ('63.1.M.1', 22, 12), ('63.1.M.1', 23, 11), ('63.1.M.1', 24, 12);
-- Game 64 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('64.1.F.1', 6, 10), ('64.1.F.1', 7, 9), ('64.1.F.1', 8, 9), ('64.1.F.1', 9, 10), ('64.1.F.1', 10, 12);
-- Game 65 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('65.4.M.1', 12, 10), ('65.4.M.1', 13, 9), ('65.4.M.1', 14, 12), ('65.4.M.1', 15, 10), ('65.4.M.1', 16, 12);
-- Game 70 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('70.4.F.1', 18, 7), ('70.4.F.1', 19, 8), ('70.4.F.1', 20, 7), ('70.4.F.1', 21, 8), ('70.4.F.1', 22, 12);
-- Game 71 (1 tribute, 5 gamemakers)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('71.7.F.1', 3, 10), ('71.7.F.1', 25, 10), ('71.7.F.1', 6, 9), ('71.7.F.1', 7, 11), ('71.7.F.1', 8, 12);
-- Game 74 (9 tributes, 5 gamemakers each)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('74.1.F.1', 2, 8), ('74.1.F.1', 3, 6), ('74.1.F.1', 12, 7), ('74.1.F.1', 13, 9), ('74.1.F.1', 14, 10),
('74.1.M.1', 2, 8), ('74.1.M.1', 3, 11), ('74.1.M.1', 12, 7), ('74.1.M.1', 13, 9), ('74.1.M.1', 14, 10),
('74.2.F.1', 2, 8), ('74.2.F.1', 3, 11), ('74.2.F.1', 12, 9), ('74.2.F.1', 13, 8), ('74.2.F.1', 14, 12),
('74.2.M.1', 2, 10), ('74.2.M.1', 3, 10), ('74.2.M.1', 12, 11), ('74.2.M.1', 13, 11), ('74.2.M.1', 14, 8),
('74.5.F.1', 2, 6), ('74.5.F.1', 3, 5), ('74.5.F.1', 12, 3), ('74.5.F.1', 13, 7), ('74.5.F.1', 14, 4),
('74.11.F.1', 2, 5), ('74.11.F.1', 3, 8), ('74.11.F.1', 12, 7), ('74.11.F.1', 13, 6), ('74.11.F.1', 14, 9),
('74.11.M.1', 2, 7), ('74.11.M.1', 3, 11), ('74.11.M.1', 12, 8), ('74.11.M.1', 13, 7), ('74.11.M.1', 14, 12),
('74.12.F.1', 2, 9), ('74.12.F.1', 3, 11), ('74.12.F.1', 12, 11), ('74.12.F.1', 13, 10), ('74.12.F.1', 14, 12),
('74.12.M.1', 2, 10), ('74.12.M.1', 3, 8), ('74.12.M.1', 12, 7), ('74.12.M.1', 13, 6), ('74.12.M.1', 14, 9);
-- Game 75 (13 tributes, 5 gamemakers each)

INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('75.1.F.1', 5, 11), ('75.1.F.1', 20, 12), ('75.1.F.1', 21, 9), ('75.1.F.1', 22, 11), ('75.1.F.1', 23, 7),
('75.1.M.1', 5, 10), ('75.1.M.1', 20, 12), ('75.1.M.1', 21, 12), ('75.1.M.1', 22, 11), ('75.1.M.1', 23, 10),
('75.2.F.1', 5, 11), ('75.2.F.1', 20, 10), ('75.2.F.1', 21, 10), ('75.2.F.1', 22, 11), ('75.2.F.1', 23, 12),
('75.2.M.1', 5, 11), ('75.2.M.1', 20, 10), ('75.2.M.1', 21, 10), ('75.2.M.1', 22, 11), ('75.2.M.1', 23, 8),
('75.3.F.1', 5, 12), ('75.3.F.1', 20, 11), ('75.3.F.1', 21, 11), ('75.3.F.1', 22, 10), ('75.3.F.1', 23, 11),
('75.3.M.1', 5, 11), ('75.3.M.1', 20, 9), ('75.3.M.1', 21, 12), ('75.3.M.1', 22, 12), ('75.3.M.1', 23, 11),
('75.4.F.1', 5, 11), ('75.4.F.1', 20, 9), ('75.4.F.1', 21, 10), ('75.4.F.1', 22, 11), ('75.4.F.1', 23, 12),
('75.4.M.1', 5, 11), ('75.4.M.1', 20, 10), ('75.4.M.1', 21, 10), ('75.4.M.1', 22, 11), ('75.4.M.1', 23, 12),
('75.7.F.1', 5, 7), ('75.7.F.1', 20, 6), ('75.7.F.1', 21, 9), ('75.7.F.1', 22, 5), ('75.7.F.1', 23, 8),
('75.7.M.1', 5, 11), ('75.7.M.1', 20, 11), ('75.7.M.1', 21, 10), ('75.7.M.1', 22, 9), ('75.7.M.1', 23, 12),
('75.8.F.1', 5, 11), ('75.8.F.1', 20, 9), ('75.8.F.1', 21, 12), ('75.8.F.1', 22, 11), ('75.8.F.1', 23, 12),
('75.12.F.1', 5, 11), ('75.12.F.1', 20, 11), ('75.12.F.1', 21, 10), ('75.12.F.1', 22, 12), ('75.12.F.1', 23, 12),
('75.12.M.1', 5, 10), ('75.12.M.1', 20, 11), ('75.12.M.1', 21, 11), ('75.12.M.1', 22, 11), ('75.12.M.1', 23, 12);


-- TODO: add more likeability and intellgence
CAll edit_participant('74.12.f.1', 1, 8, 9);