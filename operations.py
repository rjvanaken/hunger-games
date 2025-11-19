import pymysql

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


def view_tributes(connection):
    """Get all tributes from database"""
    cursor = connection.cursor()
    query = "SELECT * FROM tribute"
    cursor.execute(query)
    tributes = cursor.fetchall()
    cursor.close()
    return tributes

def search_tribute_by_name(connection, name):
    """Search for tribute by name in database"""
    cursor = connection.cursor()
    query = "SELECT * FROM tribute WHERE name LIKE %s"
    cursor.execute(query, (f"%{name}%",))
    tributes = cursor.fetchall()
    cursor.close()
    return tributes

def view_tribute_by_district(connection, district):
    """View tributes by districts in database"""
    cursor = connection.cursor()
    query = "SELECT * FROM tribute WHERE district LIKE %s"
    cursor.execute(query, (f"%{district}%",))
    tributes = cursor.fetchall()
    cursor.close()
    return tributes