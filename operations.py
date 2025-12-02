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

def get_num_tributes_remaining(connection, game_number):
    cursor = connection.cursor()
    cursor.execute("SELECT get_num_tributes_remaining(%s) AS remaining", (game_number))
    result = cursor.fetchone()
    cursor.close()
    return result['remaining'] if result else 0

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


def view_game_staff(connection, game):
    """View game staff list for dashboard, combines members and gamemakers"""
    cursor = connection.cursor()
    cursor.callproc('view_game_staff', [game])
    staff = cursor.fetchall()
    cursor.close()
    return staff



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
def view_partipants(connection, tribute_name=None, age_during_games=None, game_number=None, training_score=None, intelligence_score=None, likeability_score=None):
    """view participants with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_participants', [tribute_name, age_during_games, game_number, training_score, intelligence_score, likeability_score])
    participants = cursor.fetchall()
    cursor.close()
    return participants


# View Victors
def view_victors(connection, tribute_name=None, game_number=None):
    """View victors with optional filters"""
    cursor = connection.cursor()
    cursor.callproc('view_victors', [tribute_name, game_number])
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

def view_entity_for_delete(connection, procedure_name):
    """Generic function to call view  that return data"""
    cursor = connection.cursor()
    cursor.callproc(procedure_name)
    results = cursor.fetchall()
    cursor.close()
    return results


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
    
    # Validate name
    if not name or len(name) > 64:
        print("\nInvalid name")
        return False
    
    """Create sponsor"""
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
    
    # Validate game number
    if game_number < 1:
        print("\nGame number must be greater than 0")
        return False
    
    start_date = validate_and_convert_date(start_date)
    if start_date == None:
        print("\nStart date is required")
        False

    try:
        cursor = connection.cursor()
        cursor.callproc('create_game', [game_number, start_date, required_tribute_count])
        connection.commit()
        print("\nGame successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

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

# CREATE GAMEMAKER
def create_gamemaker(connection, name):
# verify exists before action
    """Create gamemaker"""  
    # Validate name
    if not name or len(name) > 64:
        print("\nInvalid name")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_gamemaker', [name])
        connection.commit()
        print("\nGamemaker successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT GAMEMAKER
def edit_gamemaker(connection, id, name):
    """Edit gamemaker"""
    # Validate name or set to None if empty
    name = utils.prepare_name_for_update(name, 64, 'name')

    if name == False:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_gamemaker', [name, id])
        connection.commit()
        print("\nGamemaker successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()


# DELETE GAMEMAKER
def delete_gamemaker(connection, gamemaker_id):
    """Delete gamemaker"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_gamemaker', [gamemaker_id])
        connection.commit()
        cursor.close()
        print("\nGamemaker successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()


'''MANAGE TEAM MEMBERS'''


# CREATE TEAM MEMBER
def create_team_member(connection, name, victor_id=None):
    """Create team member"""
        
    # Validate name
    if not name or len(name) > 64:
        print("\nInvalid name")
        return False
    
    # Validate victor_id if provided
    if victor_id is not None and victor_id < 1:
        print("\nVictor ID must be greater than 0")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_team_member', [name, victor_id])
        connection.commit()
        print("\Team member successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT TEAM MEMBER
def edit_team_member(connection, id, name, victor_id=None):
    """Edit team member"""
    
    name = utils.prepare_name_for_update(name, 64, 'name')
    victor_id = utils.prepare_num_for_update(victor_id, 'victor_id', 1)

    if name == False:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_team_member', [name, id, victor_id])
        connection.commit()
        print("\nTeam member successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

    
# DELETE TEAM MEMBER
def delete_team_member(connection, member_id):
    """Delete team member"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_team_member', [member_id])
        connection.commit()
        cursor.close()
        print("\nTeam member successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()


'''MANAGE PARTICIPANTS'''

# CREATE PARTICIPANT
def create_participant(connection, tribute_id, game_number):
    # Validate tribute_id
    if tribute_id < 1:
        print("\nTribute ID must be greater than 0")
        return False
    
    # Validate game_number
    if game_number < 1:
        print("\nGame number must be greater than 0")
        return False
    
    """Create participant"""
    try:
        cursor = connection.cursor()
        cursor.callproc('create_participant', [tribute_id, game_number])
        connection.commit()
        print("\nParticipant successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT PARTICIPANT
def edit_participant(connection, participant_id, final_placement, intelligence_score, likeability_score):
    """Edit participant"""
    
    # Validate final_placement or set to None if empty
    final_placement = utils.prepare_num_for_update(final_placement, 'final_placement', 1, 24)
    
    # Validate intelligence_score or set to None if empty
    intelligence_score = utils.prepare_num_for_update(intelligence_score, 'intelligence_score', 1, 10)
    
    # Validate likeability_score or set to None if empty
    likeability_score = utils.prepare_num_for_update(likeability_score, 'likeability_score', 1, 10)

    failures = 0
    attributes = [final_placement, intelligence_score, likeability_score]
    for attribute in attributes:
        if attribute == False:
            failures = failures + 1
    if failures > 0:
        print('\nUpdate failed')
        return False

    try:
        cursor = connection.cursor()
        cursor.callproc('edit_participant', [participant_id, final_placement, intelligence_score, likeability_score])
        connection.commit()
        print("\nParticipant successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE PARTICIPANT
def delete_participant(connection, participant_id):
    """Delete participant"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_participant', [participant_id])
        connection.commit()
        cursor.close()
        print("\nParticipant successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()

'''MANAGE VICTORS'''

# DELETE VICTOR
def delete_victor(connection, victor_id):
    """Delete team member"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_victor', [victor_id])
        connection.commit()
        cursor.close()
        print("\nVictor successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()


'''MANAGE TEAM ROLES'''

# CREATE TEAM ROLE
def create_team_role(connection, member_id, participant_id, member_type):
    """Create team role"""

    # Validate member_id
    if member_id is None or member_id < 1:
        print("\nInvalid member ID")
        return False
    
    # Validate participant_id
    if not participant_id or len(participant_id) > 64:
        print("\nInvalid participant ID")
        return False
    
    # Validate member_type
    valid_types = ['escort', 'mentor', 'stylist', 'prep']
    if member_type.lower() not in valid_types:
        print(f"\nMember type must be one of: {', '.join(valid_types)}")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_team_role', [member_id, participant_id, member_type.lower()])
        connection.commit()
        print("\nTeam role successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT TEAM ROLE
def edit_team_role(connection, member_id, tribute_id, member_type):
    """Edit team role"""
    
    # Validate member_type
    type_list = ['escort', 'mentor', 'stylist', 'prep']
    member_type = utils.prepare_enum_for_update(member_type, type_list, 'member_type')
    
    if member_type == False:
        print('\nUpdate failed')
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('edit_team_role', [member_id, tribute_id, member_type])
        connection.commit()
        print("\nTeam role successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE TEAM ROLE
def delete_team_role(connection, member_id, participant_id):
    """Delete team role"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_team_role', [member_id, participant_id])
        connection.commit()
        cursor.close()
        print("\nTeam role successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()

'''MANAGE SPONSORSHIPS'''

# CREATE SPONSORSHIP
def create_sponsorship(connection, participant_id, sponsor_id, sponsor_amount):
    """Create sponsorship"""

    # Validate participant_id
    if not participant_id or len(participant_id) > 64:
        print("\nInvalid participant ID")
        return False
    
    # Validate sponsor_id
    if sponsor_id is None or sponsor_id < 1:
        print("\nInvalid sponsor ID")
        return False
    
    # Validate sponsor_amount
    if sponsor_amount is None or sponsor_amount < 0:
        print("\nSponsor amount must be non-negative")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_sponsorship', [participant_id, sponsor_id, sponsor_amount])
        connection.commit()
        print("\nSponsorship successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# EDIT SPONSORSHIP
def edit_sponsorship(connection, sponsor_id, participant_id, sponsor_amount):
    """Edit sponsorship"""
    
    # Validate sponsor_amount or set to None if empty
    sponsor_amount = utils.prepare_num_for_update(sponsor_amount, 'sponsor_amount', 0, None)
    
    if sponsor_amount == False:
        print('\nUpdate failed')
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('edit_sponsorship', [sponsor_id, participant_id, sponsor_amount])
        connection.commit()
        print("\nSponsorship successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE SPONSORSHIP
def delete_sponsorship(connection, sponsor_id, participant_id):
    """Delete sponsorship"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_sponsorship', [sponsor_id, participant_id])
        connection.commit()
        cursor.close()
        print("\nSponsorship successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()


'''MANAGE GAME CREATORS'''

# CREATE GAME CREATOR
def create_game_creator(connection, game_number, gamemaker_id):
    """Create game creator"""

    # Validate game_number
    if game_number is None or game_number < 1:
        print("\nInvalid game number")
        return False
    
    # Validate gamemaker_id
    if gamemaker_id is None or gamemaker_id < 1:
        print("\nInvalid gamemaker ID")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_game_creator', [game_number, gamemaker_id])
        connection.commit()
        print("\nGame creator successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE GAME CREATOR
def delete_game_creator(connection, game_number, gamemaker_id):
    """Delete game creator"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_game_creator', [game_number, gamemaker_id])
        connection.commit()
        cursor.close()
        print("\nGame creator successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()




'''MANAGE GAME VICTORS'''

# CREATE GAME VICTOR
def create_game_victor(connection, game_number, victor_id):
    """Create game victor"""

    # Validate game_number
    if game_number is None or game_number < 1:
        print("\nInvalid game number")
        return False
    
    # Validate victor_id
    if victor_id is None or victor_id < 1:
        print("\nInvalid victor ID")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_game_victor', [game_number, victor_id])
        connection.commit()
        print("\nGame victor successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE GAME VICTOR
def delete_game_victor(connection, game_number, victor_id):
    """Delete game victor"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_game_victor', [game_number, victor_id])
        connection.commit()
        cursor.close()
        print("\Game victor successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()



'''MANAGE GAMEMAKER SCORES'''

# CREATE GAMEMAKER SCORE
def create_gamemaker_score(connection, gamemaker_id, participant_id, assessment_score):
    """Create gamemaker score"""

    # Validate gamemaker_id
    if gamemaker_id is None or gamemaker_id < 1:
        print("\nInvalid gamemaker ID")
        return False
    
    # Validate participant_id
    if not participant_id or len(participant_id) > 64:
        print("\nInvalid participant ID")
        return False
    
    # Validate assessment_score
    if assessment_score is None or assessment_score < 1 or assessment_score > 12:
        print("\nAssessment score must be between 1 and 12")
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('create_gamemaker_score', [gamemaker_id, participant_id, assessment_score])
        connection.commit()
        print("\nGamemaker score successfully created!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()


# EDIT GAMEMAKER SCORE
def edit_gamemaker_score(connection, gamemaker_id, participant_id, assessment_score):
    """Edit gamemaker assessment score"""
    
    # Validate assessment_score or set to None if empty
    assessment_score = utils.prepare_num_for_update(assessment_score, 'assessment_score', 1, 12)
    
    if assessment_score == False:
        print('\nUpdate failed')
        return False
    
    try:
        cursor = connection.cursor()
        cursor.callproc('edit_gamemaker_score', [gamemaker_id, participant_id, assessment_score])
        connection.commit()
        print("\nGamemaker score successfully updated!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"\nDatabase error: {err}")
        return False
    finally:
        cursor.close()

# DELETE GAMEMAKER SCORE
def delete_gamemaker_score(connection, gamemaker_id, participant_id):
    """Delete gamemaker score"""
    try: 
        cursor = connection.cursor()
        cursor.callproc('delete_gamemaker_score', [gamemaker_id, participant_id])
        connection.commit()
        cursor.close()
        print("\nGamemaker score successfully deleted!")
        return True
    except pymysql.Error as err:
        connection.rollback()
        print(f"Database error: {err}")
        return False
    finally:
        cursor.close()






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
    