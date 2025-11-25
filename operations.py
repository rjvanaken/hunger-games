import pymysql


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
    cursor.execute("SELECT get_participant_age(%s) AS age", (participant_id,))
    result = cursor.fetchone()
    cursor.close()
    return result['age'] if result else 0

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
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_tributes', [name, district])
    tributes = next(cursor.stored_results()).fetchall()
    cursor.close()
    return tributes

# View Sponsors / Sponsorships
def view_sponsors(connection, name=None):
    """View sponsors by optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_sponsors', [name])
    sponsors = next(cursor.stored_results()).fetchall()
    cursor.close()
    return sponsors

def view_sponsorships(connection, game_number=None, tribute_name=None):
    """View sponsorships with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_sponsorships', [game_number, tribute_name])
    sponsorships = next(cursor.stored_results()).fetchall()
    cursor.close()
    return sponsorships

#VIEW-GAMES
def view_games(connection, game_number=None, tribute_name=None, victor_name=None):
    """View games with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_games', [game_number, tribute_name, victor_name])
    games = next(cursor.stored_results()).fetchall()
    cursor.close()
    return games


# View Gamemakers
def view_gamemakers(connection, name=None, game_number=None):
    """View gamemakers with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_gamemakers', [name, game_number])
    gamemakers = next(cursor.stored_results()).fetchall()
    cursor.close()
    return gamemakers


# View Team Member
def view_team_members(connection, name=None, member_type=None, tribute_name=None):
    """View team members with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_team_members', [name, member_type, tribute_name])
    team_members = next(cursor.stored_results()).fetchall()
    cursor.close()
    return team_members


# View Participants
def view_partipants(connection, tribute_name=None, age_during_games=None, game_number=None, training_score=None):
    """view participants with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_participants', [tribute_name, age_during_games, game_number, training_score])
    participants = next(cursor.stored_results()).fetchall()
    cursor.close()
    return participants


# View Victors
def view_victors(connection, tribute_name=None, game_number=None):
    """View victors with optional filters"""
    cursor = connection.cursor(dictionary=True)
    cursor.callproc('view_victors', tribute_name, game_number)
    victors = next(cursor.stored_results()).fetchall()
    cursor.close()
    return victors


'''
==============================
MANAGE OPERATIONS
==============================
'''