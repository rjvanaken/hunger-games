import pymysql

def get_games(connection):
    """Step 14: Get valid games from database"""
    cursor = connection.cursor()
    query = "SELECT game_number FROM game"
    cursor.execute (query)
    rows = cursor.fetchall()
    games = []
    for row in rows:
        games.append(row['game_number'])
        
    cursor.close()
    return games

def display_menu():
    """Top menu options"""
    print("\n=== MENU ===")
    print("1: Select Game")
    print("2: Manage Capitol Records")
    choice = input("Enter choice (1 or 2): ")
    return choice

def display_records_menu():
    """Display menu for records"""
    print("\n=== MANAGE CAPITOL RECORDS ===")
    print("1: Manage Tributes")
    print("2: Manage Districts")
    print("3: Manage Sponsors")
    print("4: Manage Games")
    print("5: Manage Gamemakers")
    print("6: Manage Team Members")
    print("7: Manage Participants")
    print("8: Manage Victors")
    print("0: RETURN TO MAIN MENU")
    choice = input("Enter the record option number: ")
    return choice

def display_games(game_list):
    print("=================================")
    print("SELECT A GAME TO VIEW: ")
    for game in game_list:
        print("- " + game)
    print("=================================")

import pymysql
def get_game_input(game_list):
    """Steps 13-15a: Prompt and validate game input"""
    # Step 13: Get input
    
    display_games(game_list)
    game_type_input = input("Enter a game number from the above list: ")
    # Step 14: Validate | Step 15: Error message and repeat input request
    while game_type_input not in game_list:
        print("Invalid game number. Please try again.")
        display_games(game_list)
        game_input = input("Enter a game number from the above list: ")    
    
    # Find and return the correct case version
    index = game_list.index(game_input)
    return game_list[index]


def display_game_menu():
    pass

def view_tributes():
    pass

# etc...

# def display_spells_by_type(connection, spell_type):
#     """Steps 15b-17: call procedure and display results or handle error"""
#     try:
#         cursor = connection.cursor()
#         # Step 16: call procedure
#         cursor.callproc('spell_has_type', (spell_type,))
#         spells = cursor.fetchall()
#         # Step 17: display results
#         print("\n" + "=" * 80)
#         print(f"SPELLS: {spell_type.upper()}")
#         print("=" * 80)
#         print(f"{'ID':<8} | {'Name':<40} | {'Alias':<40}")
#         print("-" * 80)
#         for spell in spells:
#             spell_id = str(spell['spell_id'])
#             spell_name = spell['spell_name'] if spell['spell_name'] else 'N/A'
#             spell_alias = spell['spell_alias'] if spell['spell_alias'] else 'N/A'
#             print(f"{spell_id:<8} | {spell_name:<40} | {spell_alias:<40}")
#         print("=" * 80 + "\n")
#         cursor.close()
        
#     # Step 15b: error handling
#     except pymysql.Error as e:
#         print(f"Database error: {e}")

