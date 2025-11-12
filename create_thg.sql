DROP DATABASE IF EXISTS hunger_games;
CREATE DATABASE IF NOT EXISTS hunger_games;

use hunger_games;


CREATE TABLE IF NOT EXISTS district (
	district_num INT PRIMARY KEY,
    industry varchar(64),
    population INT
);

CREATE TABLE IF NOT EXISTS tribute (
	tribute_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    dob DATE NOT NULL,
    gender enum ('male', 'female') NOT NULL,
    district INT,
	FOREIGN KEY (district) REFERENCES district(district_num)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS victor (
	victor_id INT AUTO_INCREMENT PRIMARY KEY,
    tribute_id INT NOT NULL,
    FOREIGN KEY (tribute_id) REFERENCES tribute(tribute_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS team_member (
	member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    victor_id INT,
    FOREIGN KEY (victor_id) REFERENCES victor(victor_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS sponsor (
	sponsor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(64),
    last_name VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS gamemaker (
	gamemaker_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(64),
    last_name VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS game (
	game_number INT PRIMARY KEY NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS participant(
	participant_id INT AUTO_INCREMENT PRIMARY KEY,
    age_during_games INT NOT NULL, -- calculate based on start date and birthday
    final_placement INT, -- add logic
    training_score INT, -- add range and logic
    interview_score INT, -- decide on how this is calculated
    tribute_id INT NOT NULL,
    game_number INT NOT NULL,
    
	CONSTRAINT check_age CHECK (age_during_games BETWEEN 12 AND 18),
    CONSTRAINT check_placement CHECK (final_placement BETWEEN 1 AND 24),
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
    participant_id INT NOT NULL,
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
    participant_id INT NOT NULL,
    assessment_score INT,
	CONSTRAINT check_assessment CHECK (assessment_score BETWEEN 1 AND 12),
    PRIMARY KEY (gamemaker_id, participant_id),
    FOREIGN KEY (gamemaker_id) REFERENCES gamemaker(gamemaker_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Sponsor -> Participant
CREATE TABLE IF NOT EXISTS sponsorship (
	sponsor_id INT NOT NULL,
    participant_id INT NOT NULL,
    sponsor_amount DECIMAL (10, 2),
    PRIMARY KEY (sponsor_id, participant_id),
    FOREIGN KEY (sponsor_id) REFERENCES sponsor(sponsor_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (participant_id) REFERENCES participant(participant_id)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

-- victor -> victor to specific game
CREATE TABLE IF NOT EXISTS victor_game (
    victor_id INT NOT NULL,
    game_number INT NOT NULL,
    PRIMARY KEY (victor_id, game_number),
    FOREIGN KEY (victor_id) REFERENCES victor(victor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (game_number) REFERENCES game(game_number)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


