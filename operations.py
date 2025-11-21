import pymysql


'''
==============================
CALCULATIONS
==============================
'''

def get_sponsor_total(connection, sponsor_id):
    cursor = connection.cursor()
    cursor.execute("SELECT get_total_contributions(%s)", (sponsor_id,))
    result = cursor.fetchone()
    return result[0] if result else 0

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
        SELECT sp.sponsor_id as sponsor_id, sp.participant_id as participant_id, s.name as sponsor_name, t.name AS tribute_name, sp.sponsor_amount, p.game_number
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


'''
==============================
MANAGE OPERATIONS
==============================
'''