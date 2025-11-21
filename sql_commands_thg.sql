-- Sponsorship effectiveness analysis
/*
SELECT 
    p.interview_score,
    AVG(COALESCE(s.total_sponsorship, 0)) as avg_sponsorship
FROM participant p
LEFT JOIN (
    SELECT participant_id, SUM(sponsor_amount) as total_sponsorship
    FROM sponsorship
    GROUP BY participant_id
) s ON p.participant_id = s.participant_id
GROUP BY p.interview_score
ORDER BY p.interview_score;
*/

/*
-- show predicted win table
SELECT 
    ROW_NUMBER() OVER (ORDER BY win_probability_score DESC) as predicted_rank,
    t.name,
    d.district_num,
    d.wealth,
    p.training_score,
    COALESCE(SUM(s.sponsor_amount), 0) as total_sponsorship,
    
    -- Win Probability Score (0-100)
    (
        (p.training_score / 12.0 * 50) +
        (LEAST(COALESCE(SUM(s.sponsor_amount), 0) / 100000, 1) * 30) +
        (CASE d.wealth
            WHEN 'Wealthy' THEN 20
            WHEN 'Middle Class' THEN 12
            WHEN 'Working Class' THEN 6
            WHEN 'Poor' THEN 0
        END)
    ) as win_probability_score
    
FROM participant p
JOIN tribute t ON p.tribute_id = t.tribute_id
JOIN district d ON t.district = d.district_num
LEFT JOIN sponsorship s ON p.participant_id = s.participant_id
WHERE p.game_number = 74
GROUP BY p.participant_id
ORDER BY win_probability_score DESC;
*/

/*
-- calculating and displaying age during games
-- VIEW
CREATE VIEW participation_with_age AS
SELECT 
    gp.*,
    TIMESTAMPDIFF(YEAR, t.birthdate, g.games_date) AS age_at_games
FROM game_participation gp
JOIN tributes t USING (tribute_id)
JOIN games g USING (games_number);
*/

/*
    -- Calculate age_during_games
    SELECT TIMESTAMPDIFF(YEAR, t.dob, g.start_date)
    INTO NEW.age_during_games
    FROM tribute t
    JOIN game g ON g.game_number = NEW.game_number
    WHERE t.tribute_id = NEW.tribute_id;
END$$
*/



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
END$$

DELIMITER ;
    


-- trigger ideas
-- when placement is set as 1 for a tribute (or more), check if victor for that tribute_id exists and if not, victor is created
-- 		also add entry into game_victor junction table
-- when new gamemaker score is added, update the average for tribute - continuous
-- trigger to limit adding more than set tribute count for game once created
-- trigger to update participant id from NULL to composite key



-- ===========================================================================
-- FUNCTION: calculates and returns the training score
-- ===========================================================================
DROP FUNCTION IF EXISTS get_training_score;
DELIMITER $$

CREATE FUNCTION get_training_score(p_participant_id VARCHAR(64), p_game_number)
RETURNS DECIMAL(2, 0)
DETERMINISTIC
BEGIN


    DECLARE training_score DECIMAL(2, 0);

    SELECT ROUND(AVG(assessment_score)) INTO training_score
    FROM
    (SELECT gs.assessment_score
    FROM gamemaker_score gs
    WHERE participant_id = p_participant_id)

    RETURN COALESCE(avg_score, NULL);
END $$

DELIMITER ;


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

-- FUNCTIONS
-- CREATE FUNCTION NAME (FIELD1 FIELD1_DATATYPE, ...)
-- RETURNS data_type
-- DETERMINISTIC OR NOT
-- Contains SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA

-- WRITE FUNCTION THAT RETURNS AN INTEGER
-- THAT IS THE BUMBER OF DISTINCT school names
-- within the student table


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
DELIMITER $$

DROP TRIGGER IF EXISTS set_victor_upon_winner_updated;

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

    SELECT COUNT INTO num_participants FROM participant;
    SELECT required_tribute_count INTO max_tributes FROM game;

    IF num_participants = max_tributes THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'required tribute count has been reached';
    END IF;

END $$

DELIMITER ;
    