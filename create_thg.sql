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
    start_date DATE,
    end_date DATE,
    
    CONSTRAINT check_negative_tributes CHECK (required_tribute_count > 0)
);

CREATE TABLE IF NOT EXISTS participant(
	participant_id VARCHAR(64) PRIMARY KEY,
	tribute_id INT NOT NULL,
    game_number INT NOT NULL,
    age_during_games INT, -- calculate based on start date and birthday (REMOVE - FOUND IN QUERIES)
    final_placement INT, -- add logic -- limit based on number of tributes - trigger
    training_score INT, -- add range and logic (REMOVE - FOUND IN QUERIES)
    interview_score INT, -- decide on how this is calculated
    
	CONSTRAINT check_age CHECK (age_during_games BETWEEN 12 AND 18),
    CONSTRAINT check_training_score CHECK (training_score BETWEEN 1 AND 12),
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


-- ============================
-- INSERTION TRIGGER
-- ============================

DELIMITER $$

DROP TRIGGER IF EXISTS set_participant_id$$

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
END$$

DELIMITER ;


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
('Peeta Mellark', '0076-03-12', 'm', 12);

-- TEAM MEMBERS
INSERT INTO team_member (name) VALUES
-- 74th-75th
('Effie Trinket'),
('Haymitch Abernathy'),
('Cinna'),
('Portia'),
('Flavius'),
('Octavia'),
('Venia');


INSERT INTO gamemaker (name) VALUES
-- 71-74th games as head gamemaker
('Seneca Crane'),
('Lucia'), -- 74th games working under seneca
('Bobby Blueballs')
;

INSERT INTO game (game_number, required_tribute_count) VALUES
(74, DEFAULT);

INSERT INTO participant (tribute_id, game_number) VALUES
-- 74th
(1, 74),
(2, 74);

INSERT INTO sponsor (name) VALUES
("Pompous Heavensbee"),
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
(7, 'prep', '74.12.M.1');

INSERT INTO sponsorship (sponsor_id, participant_id, sponsor_amount) VALUES
(1, '74.12.M.1', 5000),
(2, '74.12.F.1', 7000);


INSERT INTO gamemaker_score (participant_id, gamemaker_id, assessment_score) VALUES
('74.12.F.1', 1, 11),
('74.12.F.1', 2, 12),
('74.12.F.1', 3, 10),
('74.12.M.1', 1, 8),
('74.12.M.1', 2, 8),
('74.12.M.1', 3, 9);