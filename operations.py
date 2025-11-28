import pymysql
from datetime import datetime
import utils

'''
==============================
CALCULATIONS
==============================
'''

def get_sponsor_total(connection, sponsor_id):
    cursor = connection.cursor()
    cursor.execute("SELECT get_total_contributions(%s) AS total", (sponsor_id,))
    result = cursor.fetchone()
    cursor.close()
    return result['total'] if result else 0

def get_training_score(connection, participant_id):
    cursor = connection.cursor()
    cursor.execute("SELECT get_training_score(%s) AS score", (participant_id,))
    result = cursor.fetchone()
    cursor.close()
    return result['score'] if result else 0

def get_age_during_games(connection, participant_id):
    cursor = connection.cursor()
    cursor.execute("SELECT get_participant_age(%s) AS age", (participant_id))
    result = cursor.fetchone()
    cursor.close()
    return result['age'] if result else 0

def get_likeability(connection, participant_id):
    cursor = connection.cursor()
    cursor.execute("", (participant_id))
    result = cursor.fetchone()
    cursor.close()
    return result['likeability'] if result else 0

def get_intelligence(connection, participant_id):
    cursor = connection.cursor()
    cursor.execute("", (participant_id))
    result = cursor.fetchone()
    cursor.close()
    return result['intelligence'] if result else 0

def get_chances_of_winning(connection, participant_id, training_score, intelligence_score, likeability_score):
    """_summary_

    Args:
        connection (??): sql connection
        participant_id (string): the unique participant id 
        training_score (integer): the training score based on individual gamemaker scores
        intelligence_score (integer): how intelligent the participant is: 1-10
        likeability_score (integer): how likeable the participant is: 1-10

    Returns: (float)
        the participant's chances of winning, with 2 decimal places
    """
    training_score = get_training_score(connection, participant_id) * 0.5
    intelligence_score = get_intelligence(connection, participant_id) * 0.3
    likeability_score = get_likeability(connection, participant_id) * 0.2

    chances = (training_score + intelligence_score + likeability_score / 11) * 100
    return (f"{str(chances)}.2f")

# likeability = 0.20
# training = 0.5
# intelligence = 0.3

'''
==============================
SELECT GAME OPERATIONS
==============================
'''

def get_games(connection):
    cursor = connection.cursor()
    query = "SELECT game_number FROM game"
    cursor.execute (query)
    rows = cursor.fetchall()
    games = []
    for row in rows:
        games.append(row['game_number'])
        
    cursor.close()
    return games

'''
==============================
VIEW OPERATIONS
==============================
'''

# View Tributes
def view_tributes(connection, name=None, district=None):
    """View tributes with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_tributes', [name, district])
    tributes = cursor.fetchall()
    cursor.close()
    return tributes

# View Sponsors / Sponsorships
def view_sponsors(connection, name=None):
    """View sponsors by optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_sponsors', [name])
    sponsors = cursor.fetchall()
    cursor.close()
    return sponsors

def view_sponsorships(connection, game_number=None, tribute_name=None):
    """View sponsorships with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_sponsorships', [game_number, tribute_name])
    sponsorships = cursor.fetchall()
    cursor.close()
    return sponsorships

#VIEW-GAMES
def view_games(connection, game_number=None, tribute_name=None, victor_name=None):
    """View games with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_games', [game_number, tribute_name, victor_name])
    games = cursor.fetchall()
    cursor.close()
    return games


# View Gamemakers
def view_gamemakers(connection, name=None, game_number=None):
    """View gamemakers with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_gamemakers', [name, game_number])
    gamemakers = cursor.fetchall()
    cursor.close()
    return gamemakers


# View Team Member
def view_team_members(connection, name=None, member_type=None, tribute_name=None):
    """View team members with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_team_members', [name, member_type, tribute_name])
    team_members = cursor.fetchall()
    cursor.close()
    return team_members


# View Participants
def view_partipants(connection, tribute_name=None, age_during_games=None, game_number=None, training_score=None):
    """view participants with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_participants', [tribute_name, age_during_games, game_number, training_score])
    participants = cursor.fetchall()
    cursor.close()
    return participants


# View Victors
def view_victors(connection, tribute_name=None, game_number=None):
    """View victors with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_victors', tribute_name, game_number)
    victors = cursor.fetchall()
    cursor.close()
    return victors

# View Districts
def view_districts(connection):
    """View districts"""
    cursor = connection.cursor()
    cursor.callproc('view_districts')
    districts = cursor.fetchall()
    cursor.close()
    return districts


'''
==============================
MANAGE OPERATIONS
==============================
'''

# Generic View Table (FOR CRUD VIEW)
def view_table(connection, table_name):
    """View full table"""
    cursor = connection.cursor()
    cursor.callproc('view_table', [table_name])
    rows = cursor.fetchall()
    cursor.close()
    return rows


'''MANAGE TRIBUTES'''

# CREATE TRIBUTE
def create_tribute(connection, name, birth_date, gender, district):
    """Create tribute"""

    # Validate name
    if not name or len(name) > 64:
        print("\nInvalid name")
        return False
    
    # Validate gender
    if gender.lower() not in ['m', 'f']:
        print("\nGender must be 'm' or 'f'")
        return False
    
    # Validate district
    if district < 1 or district > 12:
        print("\nDistrict must be between 1-12")
        return False
    
    if birth_date is not None and birth_date != '':
        dob = validate_and_convert_date(birth_date)
    
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_tribute', [name, dob, gender.lower(), district])
        connection.commit()
        print("\nTribute successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT TRIBUTE
def edit_tribute(connection, tribute_id, name, birth_date, gender, district):
    # Validate name or set to None if empty
    name = utils.prepare_name_for_update(name, 64, 'name')
    
    # Validate dob or set to None if empty

    dob = utils.prepare_date_for_update(birth_date)

    # Validate gender or set to None if empty
    gender_list = ['m', 'f']
    gender = utils.prepare_enum_for_update(gender, gender_list, 'gender')
    
    # Validate district or set to None if empty
    district = utils.prepare_num_for_update(district, 'district', 1, 12)

    failures = 0
    attributes = [name, dob, gender, district]
    for attribute in attributes:
        if attribute == False:
            failures = failures + 1
    if failures > 0:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_tribute', [tribute_id, name, dob, gender, district])
        connection.commit()
        print("\nTribute successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE TRIBUTE
def delete_tribute(connection, tribute_id):
    """Delete tribute"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_tribute', [tribute_id])
        connection.commit()
        cursor.close()
        print("Tribute successfully deleted")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()





'''MANAGE SPONSORS'''

# CREATE SPONSOR
def create_sponsor(connection, name):
# verify exists before action
    """Create sponsor"""
    
    name = utils.prepare_name_for_update(name, 64, 'name')

    try:
        cursor = connection.cursor()
        cursor.callproc('create_sponsor', [name])
        connection.commit()
        print("\nSponsor successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT SPONSOR
def edit_sponsor(connection, id, name):
    """Edit sponsor"""
    # Validate name or set to None if empty
    name = utils.prepare_name_for_update(name, 64, 'name')

    if name == False:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_sponsor', [name, id])
        connection.commit()
        print("\nSponsor successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()


# DELETE SPONSOR
def delete_sponsor(connection, sponsor_id):
    """Delete sponsor"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_sponsor', [sponsor_id])
        connection.commit()
        cursor.close()
        print("\nSponsor successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()



'''MANAGE GAMES'''

# CREATE GAME
def create_game(connection, game_number, start_date, required_tribute_count=24):

    """Create game"""
    cursor = connection.cursor()
    cursor.callproc('create_game', [game_number, start_date, required_tribute_count])
    rows = cursor.fetchall()
    cursor.close()
    return rows

# EDIT GAME
def edit_game(connection, game_number, start, end, game_status, required_tribute_count):
    """edit game"""
    start_date = utils.prepare_date_for_update(start)
    end_date = utils.prepare_date_for_update(end)

    status_list = ['planned', 'in progress', 'completed']
    game_status = utils.prepare_enum_for_update(game_status, status_list, 'game')
    
    required_tribute_count = utils.prepare_num_for_update(required_tribute_count, 'required_tribute_count', 1)

    failures = 0
    attributes = [start_date, end_date, required_tribute_count, game_status]
    for attribute in attributes:
        if attribute == False:
            failures = failures + 1
    if failures > 0:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_game', [game_number, start_date, end_date, game_status, required_tribute_count])
        connection.commit()
        print("\nGame successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE GAME
def delete_game(connection, game_number):
    """Delete game"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_game', [game_number])
        connection.commit()
        cursor.close()
        print("\nGame successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()

'''MANAGE GAMEMAKERS'''

# # CREATE GAMEMAKER
# def create_gamemaker(name):


# # EDIT GAMEMAKER

# # DELETE GAMEMAKER


# '''MANAGE TEAM MEMBERS'''

# # CREATE TEAM MEMBER
# def create_team_member(name, victor_id=None):


# # EDIT TEAM MEMBER


# # DELETE TEAM MEMBER

# '''MANAGE PARTICIPANTS'''

# # CREATE PARTICIPANT
# def create_participant(tribute_id, game_number):

# # EDIT PARTICIPANT


# # DELETE PARTICIPANT

# '''MANAGE VICTORS'''

# # CREATE VICTOR
# def create_victor(tribute_id):

# # EDIT VICTOR


# # DELETE VICTOR



'''
==============
UTILITIES
==============
'''
def validate_and_convert_date(date_string):
    try:
        date_obj = datetime.strptime(date_string, "%Y-%m-%d").date()
        return date_obj
    except ValueError:
        return None 
    