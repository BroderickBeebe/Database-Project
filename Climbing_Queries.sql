CREATE DATABASE RockClimbingDatabase;
USE RockClimbingDatabase;
CREATE TABLE CLIMBING_GYM (
    ID_NUM INT PRIMARY KEY,
    GYM_NAME VARCHAR(100) NOT NULL,
    GYM_TOTAL DECIMAL(10, 2)
);

CREATE TABLE TEAM (
    TEAM_NUM INT PRIMARY KEY,
    TEAM_NAME VARCHAR(100) NOT NULL,
    SCORE DECIMAL(10, 2),
    CAPT_NUM INT
);

CREATE TABLE TEAM_MEMBER (
    MEM_NUM INT PRIMARY KEY,
    FNAME VARCHAR(50) NOT NULL,
    LNAME VARCHAR(50) NOT NULL,
    AVG_SCORE DECIMAL(10, 2),
    CURRENT_SCORE DECIMAL(10, 2),
    TEAM_NUM INT,
    WEEKS_IN INT,
    FOREIGN KEY (TEAM_NUM) REFERENCES TEAM(TEAM_NUM)
);

CREATE TABLE LEAD_CLIMB (
    CLIMB_ID INT PRIMARY KEY,
    CLIMB_NAME VARCHAR(100) NOT NULL,
    YDS_GRADE DECIMAL(10,2),
    GYM_ID INT,
    FOREIGN KEY (GYM_ID) REFERENCES CLIMBING_GYM(ID_NUM)
);

CREATE TABLE BOULDER (
    BOULDER_ID INT PRIMARY KEY,
    BOULDER_NAME VARCHAR(100) NOT NULL,
    V_GRADE DECIMAL(10,2),
    GYM_ID INT,
    FOREIGN KEY (GYM_ID) REFERENCES CLIMBING_GYM(ID_NUM)
);
-- Insert CLIMBING_GYM data
INSERT INTO CLIMBING_GYM (ID_NUM, GYM_NAME, GYM_TOTAL) VALUES
(1, 'High Peak Climbing Gym', 10000.00),
(2, 'Rock Solid Gym', 8000.00);

-- Insert TEAM data
INSERT INTO TEAM (TEAM_NUM, TEAM_NAME, SCORE, CAPT_NUM) VALUES
(1, 'Mountain Goats', 850.50, 101),
(2, 'Cliff Climbers', 920.75, 102);

-- Insert TEAM_MEMBER data
INSERT INTO TEAM_MEMBER (MEM_NUM, FNAME, LNAME, AVG_SCORE, CURRENT_SCORE,TEAM_NUM,WEEKS_IN) VALUES
(101, 'John', 'Doe', 90.75, 95.00,1,8),
(102, 'Jane', 'Smith', 85.50, 88.00,2,9),
(103, 'Alice', 'Johnson', 78.25, 80.00,1,8);

-- Insert LEAD_CLIMB data
INSERT INTO LEAD_CLIMB (CLIMB_ID, CLIMB_NAME, YDS_GRADE, GYM_ID) VALUES
(1, 'Vertical Assault', '6', 1),
(2, 'Overhang Challenge', '5', 2);

-- Insert BOULDER data
INSERT INTO BOULDER (BOULDER_ID, BOULDER_NAME, V_GRADE, GYM_ID) VALUES
(1, 'Boulder Blitz', '5', 1),
(2, 'Rock Rodeo', '4', 2);
DELIMITER //

CREATE FUNCTION Add_climb(member_num INT, climb_id_val INT) RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE climb_exists INT;
    DECLARE yds_multiplied DECIMAL(10, 2);
    DECLARE updated_member_score DECIMAL(10, 2);

    -- Check if the climb exists
    SELECT COUNT(*) INTO climb_exists
    FROM LEAD_CLIMB
    WHERE CLIMB_ID = climb_id_val;

    IF climb_exists = 0 THEN
        RETURN -2; -- Climb ID does not exist
    END IF;

    -- Retrieve the YDS_GRADE and multiply by 2
    SELECT YDS_GRADE * 2 INTO yds_multiplied
    FROM LEAD_CLIMB
    WHERE CLIMB_ID = climb_id_val;

    -- Update the CURRENT_SCORE in TEAM_MEMBER
    UPDATE TEAM_MEMBER
    SET CURRENT_SCORE = CURRENT_SCORE + yds_multiplied
    WHERE MEM_NUM = member_num;

    -- Retrieve the updated CURRENT_SCORE
    SELECT CURRENT_SCORE INTO updated_member_score
    FROM TEAM_MEMBER
    WHERE MEM_NUM = member_num;

    RETURN updated_member_score;
END //

DELIMITER ;
DELIMITER //

CREATE FUNCTION Add_boulder(member_num INT, boulder_id_val INT) RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE boulder_exists INT;
    DECLARE v_multiplied DECIMAL(10, 2);
    DECLARE updated_member_score DECIMAL(10, 2);

    -- Check if the boulder exists
    SELECT COUNT(*) INTO boulder_exists
    FROM BOULDER
    WHERE BOULDER_ID = boulder_id_val;

    IF boulder_exists = 0 THEN
        RETURN -2; -- Boulder ID does not exist
    END IF;

    -- Retrieve the V_GRADE and multiply by 2
    SELECT V_GRADE  INTO v_multiplied
    FROM BOULDER
    WHERE BOULDER_ID = boulder_id_val;

    -- Update the CURRENT_SCORE in TEAM_MEMBER
    UPDATE TEAM_MEMBER
    SET CURRENT_SCORE = CURRENT_SCORE + v_multiplied
    WHERE MEM_NUM = member_num;

    -- Retrieve the updated CURRENT_SCORE
    SELECT CURRENT_SCORE INTO updated_member_score
    FROM TEAM_MEMBER
    WHERE MEM_NUM = member_num;

    RETURN updated_member_score;
END //

DELIMITER ;
DELIMITER //

CREATE FUNCTION Sum_score(member_num INT) RETURNS DECIMAL(10, 2)
reads sql data
BEGIN
    DECLARE curr_score DECIMAL(10, 2);
    DECLARE avg_member_score DECIMAL(10, 2);
    DECLARE score_diff DECIMAL(10, 2);
    DECLARE weeks_in_gym INT;
    DECLARE new_avg_member_score DECIMAL(10, 2);
    DECLARE total_team_score DECIMAL(10, 2);
    DECLARE team_number INT;

    -- Retrieve current score, average score, team number, and weeks in gym
    SELECT CURRENT_SCORE, AVG_SCORE, TEAM_NUM, WEEKS_IN INTO curr_score, avg_member_score, team_number, weeks_in_gym
    FROM TEAM_MEMBER
    WHERE MEM_NUM = member_num;

    -- Calculate the score difference
    SET score_diff = curr_score - avg_member_score;

    -- Update the team's total score
    UPDATE TEAM
    SET SCORE = SCORE + score_diff
    WHERE TEAM_NUM = team_number;

    -- Calculate the new average score
    SET new_avg_member_score = (curr_score + avg_member_score * (weeks_in_gym - 1)) / weeks_in_gym;

    -- Update the new average score in TEAM_MEMBER
    UPDATE TEAM_MEMBER
    SET AVG_SCORE = new_avg_member_score
    WHERE MEM_NUM = member_num;

    -- Set the CURRENT_SCORE to zero after processing
    UPDATE TEAM_MEMBER
    SET CURRENT_SCORE = 0
    WHERE MEM_NUM = member_num;

    -- Increment WEEKS_IN by one
    UPDATE TEAM_MEMBER
    SET WEEKS_IN = WEEKS_IN + 1
    WHERE MEM_NUM = member_num;

    -- Retrieve the updated team score
    SELECT SCORE INTO total_team_score
    FROM TEAM
    WHERE TEAM_NUM = team_number;

    RETURN total_team_score;
END //

DELIMITER ;
