import pymysql
from colors import Colors

def get_credentials():
    """Prompt for username and password"""
    username = input("username: ")
    password = input("password: ")
    return username, password

def connect_to_database(username, password) :
    try:
        connection = pymysql.connect(
            host='localhost',
            port=3306,
            database='hunger_games',
            user=username,
            password=password,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.Error as e:
        # print(f"{Colors.RED}✗ Error connecting to database: {e}{Colors.RESET}")
        return None