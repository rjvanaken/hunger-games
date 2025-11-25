DROP DATABASE IF EXISTS hunger_games;
CREATE DATABASE IF NOT EXISTS hunger_games;

use hunger_games;


CREATE TABLE IF NOT EXISTS district (
	district_num INT PRIMARY KEY,
    industry VARCHAR(64),
    size ENUM ('Small', 'Medium', 'Large'), -- add to diagram
    wealth ENUM('Poor', 'Working Class', 'Middle Class', 'Wealthy') -- add to diagram
);

CREATE TABLE IF NOT EXISTS tribute (
	tribute_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64),
    dob DATE,
    gender ENUM ('M', 'F') NOT NULL,
    district INT,
	FOREIGN KEY (district) REFERENCES district(district_num)
        ON UPDATE CASCADE ON DELETE RESTRICT,
        
    CONSTRAINT prevent_dupe_tributes
        UNIQUE (name, dob, gender, district) -- keep or leave out?
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
    final_placement INT, -- add logic -- limit based on number of tributes - trigger
    interview_score INT, -- decide on how this is calculated
    
    CONSTRAINT check_interview_score CHECK (interview_score BETWEEN 1 AND 10),
    
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
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

-- gamemaker -> game
CREATE TABLE IF NOT EXISTS game_creator (
	gamemaker_id INT NOT NULL,
    game_number INT NOT NULL, 
    PRIMARY KEY (game_number, gamemaker_id),
    FOREIGN KEY (game_number) REFERENCES game(game_number)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (gamemaker_id) REFERENCES gamemaker(gamemaker_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
    
);
-- gamemaker -> participant
CREATE TABLE IF NOT EXISTS gamemaker_score (
	gamemaker_id INT NOT NULL,
    participant_id VARCHAR(64) NOT NULL,
    assessment_score INT,
    PRIMARY KEY (gamemaker_id, participant_id),
    FOREIGN KEY (gamemaker_id) REFERENCES gamemaker(gamemaker_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
        
	CONSTRAINT check_assessment CHECK (assessment_score BETWEEN 1 AND 12)
);

-- Sponsor -> Participant
CREATE TABLE IF NOT EXISTS sponsorship (
	sponsor_id INT NOT NULL,
    participant_id VARCHAR(64) NOT NULL,
    sponsor_amount DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY (sponsor_id, participant_id),
    FOREIGN KEY (sponsor_id) REFERENCES sponsor(sponsor_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
	
    CONSTRAINT check_sponsorship CHECK (sponsor_amount BETWEEN 0 AND 99999999.99)
);

-- victor -> victor to specific game
CREATE TABLE IF NOT EXISTS game_victor (
    victor_id INT NOT NULL,
    game_number INT NOT NULL,
    PRIMARY KEY (victor_id, game_number),
    FOREIGN KEY (victor_id) REFERENCES victor(victor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (game_number) REFERENCES game(game_number)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


-- ======================================
-- FUNCTIONS, PROCEDURES, AND TRIGGERS
-- ======================================


-- ===========================================================================
-- FUNCTION: calculates and returns the training score
-- ===========================================================================
DROP FUNCTION IF EXISTS get_training_score;
DELIMITER $$

CREATE FUNCTION get_training_score(p_participant_id VARCHAR(64))
RETURNS DECIMAL(2, 0)
DETERMINISTIC
BEGIN
    DECLARE training_score DECIMAL(2, 0);
    
    SELECT ROUND(AVG(assessment_score)) INTO training_score
    FROM gamemaker_score
    WHERE participant_id = p_participant_id;
    
    RETURN COALESCE(training_score, NULL);
END $$

DELIMITER ;

-- ===========================================================================
-- FUNCTION: calculates and returns a sponsor's total contributions
-- ===========================================================================
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


-- ===========================================================================
-- FUNCTION: calculates and returns the participant's age during the games
-- ===========================================================================
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


-- ===========================================================================
-- PROCEDURE: takes tribute_id and creates a victor if doesn't already exist
-- throws error if invalid parameter
-- ===========================================================================
DROP PROCEDURE IF EXISTS create_victor_from_tribute;
DELIMITER $$

CREATE PROCEDURE create_victor_from_tribute(p_tribute_id INT)
BEGIN
	IF p_tribute_id NOT IN (SELECT tribute_id FROM tribute) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tribute does not exist';
    
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
    FROM member
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

-- ====================================
-- View tributes with optional filters
-- ====================================
DROP PROCEDURE view_tributes;

DELIMITER $$

CREATE PROCEDURE view_tributes(p_name VARCHAR(64), p_district INT)

BEGIN
    SELECT * FROM tribute WHERE 1=1
    AND (p_name is NULL OR name LIKE p_name)
    AND (p_district is NULL OR district = p_district)
END $$

DELIMITER ;


-- ======================================
-- View sponsors with optional filters
-- ======================================
DROP PROCEDURE view_sponsors;
DELIMITER $$

CREATE PROCEDURE view_sponsor(p_name VARCHAR(64))

BEGIN
    SELECT * FROM sponsor WHERE 1=1
    AND (p_name is NULL OR name LIKE p_name);
END $$

DELIMITER ;


-- ========================================
-- View sponsorships with optional filters
-- ========================================
DROP PROCEDURE view_sponsorships;
DELIMITER $$

CREATE PROCEDURE view_sponsorships(p_game_number INT, p_tribute_name VARCHAR(64))

BEGIN
        SELECT sp.sponsor_id as sponsor_id, sp.participant_id as participant_id, s.name as sponsor_name, t.name AS tribute_name, sp.sponsor_amount as amount, p.game_number
        FROM sponsorship sp
        JOIN sponsor s ON sp.sponsor_id = s.sponsor_id
        JOIN participant p ON sp.participant_id = p.participant_id
        JOIN tribute t ON p.tribute_id = t.tribute_id
        WHERE 1=1
        AND (p_game_number is NULL or p.game_number = p_game_number)
        AND (p_tribute_name is NULL or t.name LIKE p_tribute_name)
        ORDER BY sp.sponsor_amount DESC;

END $$

DELIMITER ;


-- ==================================
-- View games with optional filters
-- ==================================
DROP PROCEDURE view_games;
DELIMITER $$

CREATE PROCEDURE view_games(
    p_game_number INT,
    p_tribute_name VARCHAR(100),
    p_victor_name VARCHAR(100)
)
BEGIN
    SET @sql = 'SELECT g.game_number, g.required_tribute_count as tribute_count, 
                g.start_date, g.end_date, 
                GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ", ") as victor_names 
                FROM game g
                LEFT JOIN game_victor gv ON g.game_number = gv.game_number
                LEFT JOIN victor v ON gv.victor_id = v.victor_id
                LEFT JOIN tribute t ON v.victor_id = t.tribute_id';
    
    -- Only add participant joins if tribute_name filter is used
    IF p_tribute_name IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' LEFT JOIN participant p ON g.game_number = p.game_number
                                  LEFT JOIN tribute participant_t ON p.tribute_id = participant_t.tribute_id');
    END IF;
    
    SET @sql = CONCAT(@sql, ' WHERE 1=1');
    
    -- Add game_number filter
    IF p_game_number IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND g.game_number = ', p_game_number);
    END IF;
    
    -- Add tribute_name filter
    IF p_tribute_name IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND participant_t.name LIKE "%', p_tribute_name, '%"');
    END IF;
    
    -- Add victor_name filter
    IF p_victor_name IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND g.game_number IN (
            SELECT DISTINCT gv2.game_number 
            FROM game_victor gv2
            JOIN victor v2 ON gv2.victor_id = v2.victor_id
            JOIN tribute t2 ON v2.victor_id = t2.tribute_id
            WHERE t2.name LIKE "%', p_victor_name, '%")');
    END IF;
    
    
    SET @sql = CONCAT(@sql, ' GROUP BY g.game_number, g.start_date, g.end_date, g.required_tribute_count
                              ORDER BY g.game_number');
    
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;


-- ======================================
-- View gamemakers with optional filters
-- ======================================
DROP PROCEDURE view_gamemakers;
DELIMITER $$

CREATE PROCEDURE view_gamemakers(p_name VARCHAR(64), p_game_number INT)

BEGIN
    SELECT DISTINCT g.gamemaker_id as gamemaker_id, g.name as name
    FROM gamemaker g
    LEFT JOIN game_creator gc ON g.gamemaker_id = gc.gamemaker_id
    WHERE 1=1 -- for easy visuals for the and conditions below to line up 
    AND (p_name is NULL OR name = p_name)
    AND (p_game_number is NULL OR gc.game_number = p_game_number)
    GROUP BY g.gamemaker_id
    ORDER BY g.gamemaker_id;
END $$

DELIMITER ;


-- ========================================
-- View team_members with optional filters
-- ========================================
DROP PROCEDURE view_team_members;
DELIMITER $$

CREATE PROCEDURE view_team_members(p_name VARCHAR(64), p_member_type VARCHAR(64), p_tribute_name VARCHAR(64))

BEGIN
    SELECT * from team_member; -- placeholder

END $$

DELIMITER ; 


-- ========================================
-- View participants with optional filters
-- ========================================
DROP PROCEDURE view_participants;
DELIMITER $$

CREATE PROCEDURE view_participants(p_tribute_name VARCHAR(64), p_age_during_games INT, p_game_number INT, p_training_score INT)

BEGIN
    SELECT * FROM participant_details
    WHERE 1=1 
    AND (p_tribute_name is NULL OR name LIKE p_tribute_name)
    AND (p_age_during_games is NULL OR age_during_games = p_age_during_games)
    AND (p_game_number is NULL OR game_number = p_game_number)
    AND (p_training_score is NULL OR training_score = p_training_score)
    ORDER BY game_number, district, gender;
END $$

DELIMITER ;


-- ===================================
-- View victors with optional filters
-- ===================================
DROP PROCEDURE view_victors;
DELIMITER $$

CREATE PROCEDURE view_victors(p_tribute_name VARCHAR(64), p_game_number INT)

BEGIN
    SELECT v.victor_id, t.name, t.district, GROUP_CONCAT(DISTINCT gv.game_number ORDER BY gv.game_number SEPARATOR ', ') as games_won
    FROM victor v
    JOIN game_victor gv ON v.victor_id = gv.victor_id
    JOIN tribute t ON v.victor_id = t.tribute_id
    WHERE 1=1 
    AND (p_tribute_name is NULL OR t.name = p_tribute_name)
    AND (p_game_number is NULL OR games_won LIKE p_game_number)
    GROUP BY v.victor_id, t.name, t.district
    ORDER BY v.victor_id ASC;
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
    p.interview_score,
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

-- 10th games (year 28, so ages 12-18 means birth years 0010-0016)
('Facet', '0012-09-15', 'm', 1),           -- 15 years old
('Velvereen', '0013-02-20', 'f', 1),       -- 15 years old
('Marcus', '0010-01-08', 'm', 2),          -- 18 years old
('Sabyn', '0012-06-12', 'f', 2),           -- 16 years old
('Circ', '0013-08-03', 'm', 3),            -- 14 years old
('Teslee', '0012-11-18', 'f', 3),          -- 15 years old
('Mizzen', '0015-04-22', 'm', 4),          -- 13 years old (young)
('Coral', '0010-12-30', 'f', 4),           -- 17 years old (older, strong)
('Hy', '0013-07-14', 'm', 5),              -- 14 years old
('Sol', '0012-10-08', 'f', 5),             -- 15 years old
('Otto', '0014-03-25', 'm', 6),            -- 14 years old
('Ginnee', '0016-05-17', 'f', 6),          -- 12 years old (young)
('Treech', '0011-09-20', 'm', 7),          -- 16 years old
('Lamina', '0012-01-11', 'f', 7),          -- 16 years old
('Bobbin', '0015-08-28', 'm', 8),          -- 12 years old (young)
('Wovey', '0016-03-08', 'f', 8),           -- 12 years old at reaping
('Panlo', '0013-12-05', 'm', 9),           -- 14 years old
('Sheaf', '0013-04-19', 'f', 9),           -- 15 years old
('Tanner', '0012-02-27', 'm', 10),         -- 16 years old
('Brandy', '0011-06-30', 'f', 10),         -- 16 years old
('Reaper Ash', '0010-05-05', 'm', 11),     -- 18 years old (as you noted)
('Dill', '0016-06-22', 'f', 11),           -- 12 years old (sick/weak)
('Jessup Diggs', '0010-03-14', 'm', 12),   -- 18 years old (mines worker)
('Lucy Gray Baird', '0012-03-10', 'f', 12),-- 16 years old 

-- 50th games (year 68, Reaping Day July 4, 0068)
('Louella McCoy', '0055-10-09', 'f', 12),        
('Maysilee Donner', '0052-06-20', 'f', 12),
('Wyatt Callow', '0050-05-21', 'm', 12),           
('Haymitch Abernathy', '0052-07-04', 'm', 12);

-- TEAM MEMBERS
INSERT INTO team_member (name) VALUES
-- 74th-75th
('Effie Trinket'),
('Haymith Abernathy'),
('Cinna'),
('Portia'),
('Octavia'),
('Flavius'),
('Venia'),



-- unsure when but probably 74th and before
('Tigris'),

-- 50th
('Persephone Trinket'),
('Drusilla Sickle'),
('Magno Stift'),

-- 10th games mentors
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
-- 75th games
('Plutarch Heavensbee'),
-- 71-74th games as head gamemaker
('Seneca Crane'),
('Lucia'), -- 74th games working under seneca
-- 1-10th +
('Dr. Volumina Gaul'),

('Joe Shmoe'),
('Heaven Heavensbee'),
('Grapefruit Cornelius'),
('Coriolanus Snow'),

-- Random
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
(2, 74), (4, 74), (12, 74), (13, 74), (14, 74),
-- Game 75 (5 gamemakers - Plutarch's Quarter Quell)
(1, 75), (20, 75), (21, 75), (22, 75), (23, 75);

# INSERT PARTICIPANTS
-- 10th Hunger Games (year 28)
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

-- 10TH GAMES MENTORS
(18, 'mentor', '10.1.M.1'), -- Livia Cardew → Facet
(30, 'mentor', '10.1.F.1'), -- Palmyra Monty → Velvereen
(12, 'mentor', '10.2.M.1'), -- Sejanus Plinth → Marcus
(29, 'mentor', '10.2.F.1'), -- Florus Friend → Sabyn
(24, 'mentor', '10.3.M.1'), -- Io Jasper → Circ
(27, 'mentor', '10.3.F.1'), -- Urban Canville → Teslee
(32, 'mentor', '10.4.M.1'), -- Persephone Price → Mizzen
(17, 'mentor', '10.4.F.1'), -- Festus Creed → Coral
(28, 'mentor', '10.5.M.1'), -- Dennis Fling → Hy
(31, 'mentor', '10.5.F.1'), -- Iphigenia Moss → Sol
(33, 'mentor', '10.6.M.1'), -- Apollo Ring → Otto
(34, 'mentor', '10.6.F.1'), -- Diana Ring → Ginnee
(23, 'mentor', '10.7.M.1'), -- Vipsania Sickle → Treech
(19, 'mentor', '10.7.F.1'), -- Pup Harrington → Lamina
(21, 'mentor', '10.8.M.1'), -- Juno Phipps → Bobbin
(20, 'mentor', '10.8.F.1'), -- Hilarius Heavensbee → Wovey
(25, 'mentor', '10.9.M.1'), -- Androcles Anderson → Panlo
(26, 'mentor', '10.9.F.1'), -- Gaius Breen → Sheaf
(16, 'mentor', '10.10.F.1'), -- Arachne Crane → Brandy
(35, 'mentor', '10.10.M.1'), -- Domitia Whimsiwick → Tanner
(15, 'mentor', '10.11.M.1'), -- Clemensia Dovecote → Reaper
(22, 'mentor', '10.11.F.1'), -- Felix Ravinstill → Dill
(14, 'mentor', '10.12.M.1'), -- Lysistrata Vickers → Jessup
(13, 'mentor', '10.12.F.1'); -- Coriolanus Snow → Lucy Gray

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
-- Game 10 (24 tributes, 1 gamemaker each)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('10.1.F.1', 1, 8), ('10.1.M.1', 1, 10), ('10.2.F.1', 1, 9), ('10.2.M.1', 1, 8), ('10.3.F.1', 1, 7), ('10.3.M.1', 1, 6), ('10.4.F.1', 1, 10), ('10.4.M.1', 1, 11), ('10.5.F.1', 1, 7), ('10.5.M.1', 1, 8), ('10.6.F.1', 1, 9), ('10.6.M.1', 1, 5), ('10.7.F.1', 1, 2), ('10.7.M.1', 1, 11), ('10.8.F.1', 1, 9), ('10.8.M.1', 1, 9), ('10.9.F.1', 1, 4), ('10.9.M.1', 1, 5), ('10.10.F.1', 1, 2), ('10.10.M.1', 1, 8), ('10.11.F.1', 1, 1), ('10.11.M.1', 1, 9), ('10.12.F.1', 1, 10), ('10.12.M.1', 1, 6);
-- Game 11 (1 tribute, 1 gamemaker)
INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('11.4.F.1', 1, 7);
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
('74.1.F.1', 3, 8), ('74.1.F.1', 4, 6), ('74.1.F.1', 12, 7), ('74.1.F.1', 13, 9), ('74.1.F.1', 14, 10),
('74.1.M.1', 3, 8), ('74.1.M.1', 4, 11), ('74.1.M.1', 12, 7), ('74.1.M.1', 13, 9), ('74.1.M.1', 14, 10),
('74.2.F.1', 3, 8), ('74.2.F.1', 4, 11), ('74.2.F.1', 12, 9), ('74.2.F.1', 13, 8), ('74.2.F.1', 14, 12),
('74.2.M.1', 3, 10), ('74.2.M.1', 4, 10), ('74.2.M.1', 12, 11), ('74.2.M.1', 13, 11), ('74.2.M.1', 14, 8),
('74.5.F.1', 3, 6), ('74.5.F.1', 4, 5), ('74.5.F.1', 12, 3), ('74.5.F.1', 13, 7), ('74.5.F.1', 14, 4),
('74.11.F.1', 3, 5), ('74.11.F.1', 4, 8), ('74.11.F.1', 12, 7), ('74.11.F.1', 13, 6), ('74.11.F.1', 14, 9),
('74.11.M.1', 3, 7), ('74.11.M.1', 4, 11), ('74.11.M.1', 12, 8), ('74.11.M.1', 13, 7), ('74.11.M.1', 14, 12),
('74.12.F.1', 3, 9), ('74.12.F.1', 4, 11), ('74.12.F.1', 12, 10), ('74.12.F.1', 13, 10), ('74.12.F.1', 14, 12),
('74.12.M.1', 3, 10), ('74.12.M.1', 4, 8), ('74.12.M.1', 12, 7), ('74.12.M.1', 13, 6), ('74.12.M.1', 14, 9);
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