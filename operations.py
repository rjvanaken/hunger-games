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


def get_gamemaker_score(connection, participant_id, ):
    cursor = connection.cursor()
    cursor.execute("SELECT get_training_score(%s) AS score", (participant_id,))
    result = cursor.fetchone()
    cursor.close()
    return result['score'] if result else 0

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
# Generic View Table (with no foreign keys needed)
def view_table(connection, table_name):
    print("trying to view")
    """Get all tributes from database"""
    cursor = connection.cursor()
    query = f"SELECT * FROM {table_name}"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    print("ready to return")
    return rows


# View Tributes
def view_tributes(connection, name=None, district=None):
    print("entering view tribute handle function")
    cursor = connection.cursor()
    query = "SELECT * FROM tribute WHERE 1=1"
    params = []
    
    if name:
        query += " AND name LIKE %s"
        params.append(f"%{name}%")
    
    if district:
        query += " AND district = %s"
        params.append(district)

    cursor.execute(query, params)
    tributes = cursor.fetchall()
    cursor.close()
    return tributes

# View Sponsors / Sponsorships

def search_sponsor_by_name(connection, name):
    """Search for tribute by name in database"""
    cursor = connection.cursor()
    query = "SELECT * FROM sponsor WHERE name LIKE %s"
    cursor.execute(query, (f"%{name}%",))
    sponsors = cursor.fetchall()
    cursor.close()
    return sponsors

def view_sponsorships(connection, game_number=None, tribute_name=None):
    """View sponsorships with optional filters"""
    cursor = connection.cursor()
    
    query = """
        SELECT sp.sponsor_id as sponsor_id, sp.participant_id as participant_id, s.name as sponsor_name, t.name AS tribute_name, sp.sponsor_amount as amount, p.game_number
        FROM sponsorship sp
        JOIN sponsor s ON sp.sponsor_id = s.sponsor_id
        JOIN participant p ON sp.participant_id = p.participant_id
        JOIN tribute t ON p.tribute_id = t.tribute_id
        WHERE 1=1
    """
    params = []
    
    if game_number:
        query += " AND p.game_number = %s"
        params.append(game_number)
    
    if tribute_name:
        query += " AND t.name LIKE %s"
        params.append(f"%{tribute_name}%")
    
    query += " ORDER BY sp.sponsor_amount DESC"
    
    cursor.execute(query, params)
    sponsorships = cursor.fetchall()
    cursor.close()
    return sponsorships

#VIEW-GAMES
def view_games(connection, game_number=None, tribute_name=None, victor_name=None):
    """View games with optional filters"""
    cursor = connection.cursor()
    
    query = """
        SELECT g.game_number as game_number, g.required_tribute_count as tribute_count, g.start_date, g.end_date, 
            GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ', ') as victor_names 
        FROM game g
        LEFT JOIN game_victor gv ON g.game_number = gv.game_number
        LEFT JOIN victor v ON gv.victor_id = v.victor_id
        LEFT JOIN tribute t ON v.victor_id = t.tribute_id
       
    """

    if tribute_name:
        query += """
            LEFT JOIN participant p ON g.game_number = p.game_number
            LEFT JOIN tribute participant_t ON p.tribute_id = participant_t.tribute_id
        """

    query += " WHERE 1=1"
    params = []
    
    if game_number:
        query += " AND g.game_number = %s"
        params.append(game_number)

    if tribute_name:
        query += " AND participant_t.name LIKE %s"
        params.append(f"%{tribute_name}%")
    
    if victor_name:
        query += """ AND g.game_number IN (
            SELECT DISTINCT gv2.game_number 
            FROM game_victor gv2
            JOIN victor v2 ON gv2.victor_id = v2.victor_id
            JOIN tribute t2 ON v2.victor_id = t2.tribute_id
            WHERE t2.name LIKE %s
        )"""
        params.append(f"%{victor_name}%")

    query += """
    GROUP BY g.game_number, g.start_date, g.end_date, g.required_tribute_count
    ORDER BY g.game_number
    """
    
    cursor.execute(query, params)
    games = cursor.fetchall()
    cursor.close()
    return games


# View Gamemakers
def view_gamemakers(connection, name=None, game_number=None):
    cursor = connection.cursor()
    query = """
    SELECT g.gamemaker_id as gamemaker_id, g.name as name
    FROM gamemaker g
    JOIN game_creator gc ON g.gamemaker_id = gc.gamemaker_id
    WHERE 1=1
    """
    params = []
    
    if name:
        query += " AND name LIKE %s"
        params.append(f"%{name}%")
    
    if game_number:
        query += " AND gc.game_number = %s"
        params.append(game_number)

    cursor.execute(query, params)
    gamemakers = cursor.fetchall()
    cursor.close()
    return gamemakers


# View Team Member
def view_team_members(connection, name=None, member_type=None, tribute_name=None):
    cursor = connection.cursor()
    query = """SELECT tm.member_id, tm.name, GROUP_CONCAT(DISTINCT tr.member_type ORDER BY tr.member_type SEPARATOR ', ') as roles
            FROM team_member tm
            JOIN team_role tr ON tm.member_id = tr.member_id
            WHERE 1=1
            """
    params = []
    
    if name:
        query += " AND name LIKE %s"
        params.append(f"%{name}%")
    
    if member_type:
        query += """AND tm.member_id IN (
        SELECT DISTINCT tr2.member_id
        FROM team_role tr2
        WHERE tr2.member_type = %s
        )"""
        params.append(member_type)

    if tribute_name:
        query += """AND tm.member_id IN (
        SELECT DISTINCT tr2.member_id
        FROM team_role tr2
        JOIN participant p ON tr2.participant_id = p.participant_id
        JOIN tribute t ON p.tribute_id = t.tribute_id
        WHERE t.name LIKE %s
        )"""
        params.append(f"%{tribute_name}%")


    query += """
    GROUP BY tm.member_id, tm.name
    ORDER BY tm.member_id ASC
    """

    cursor.execute(query, params)
    team_members = cursor.fetchall()
    cursor.close()
    return team_members


# View Participants
def view_partipants(connection, tribute_name=None, age_during_games=None, game_number=None, training_score=None): # TODO: calculate age function needed
    cursor = connection.cursor()
    query = """SELECT *
            FROM participant p
            JOIN game g ON participant
            JOIN tribute t
            WHERE 1=1"
            """
    params = []
    
    if tribute_name:
        query += " AND name LIKE %s"
        params.append(f"%{tribute_name}%")
    
    if age_during_games:
        query += " AND age_during_games = %s"
        params.append(age_during_games)

    if game_number:
        query += " AND game_number = %s"
        params.append(game_number)

    if training_score:
        query += " AND training_score = %s"
        params.append(training_score)


    cursor.execute(query, params)
    participants = cursor.fetchall()
    cursor.close()
    return participants


# View Victors
def view_victors(connection, tribute_name=None, game_number=None):
    """View victors with optional filters"""
    cursor = connection.cursor()
    
    query = """SELECT v.victor_id, t.name, t.district, GROUP_CONCAT(DISTINCT gv.game_number ORDER BY gv.game_number SEPARATOR ', ') as games_won
            FROM victor v
            JOIN game_victor gv ON v.victor_id = gv.victor_id
            JOIN tribute t ON v.victor_id = t.tribute_id
            WHERE 1=1
            """
    params = []
    
    if tribute_name:
        query += " AND t.name LIKE %s"
        params.append(f"%{tribute_name}%")

    if game_number:
        query += " AND games_won LIKE %s"
        params.append(f"%{game_number}%")


    query += """
    GROUP BY v.victor_id, t.name, t.district
    ORDER BY v.victor_id ASC
    """
    
    cursor.execute(query, params)
    victors = cursor.fetchall()
    cursor.close()
    return victors


'''
==============================
MANAGE OPERATIONS
==============================
'''