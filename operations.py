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


'''
==============================
MANAGE OPERATIONS
==============================
'''