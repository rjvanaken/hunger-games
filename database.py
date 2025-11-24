import pymysql

def get_credentials():
    """Prompt for username and password"""
    username = input("username: ")
    password = input("password: ")
    return username, password

def connect_to_database(username, password) :
    """Step 11: Connect with retry on failure"""
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
        print("Successfully connected to the capitol database!")
        return connection
    except pymysql.Error as e:
        print(f"Error connecting to database: {e}")
        return None