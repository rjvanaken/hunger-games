
def display_menu():
    """Top menu options"""
    print("\n=== MENU ===")
    print("1: Select Game")
    print("2: Manage Capitol Records")
    print("3: View Capitol Records")
    print("4: Get Stats & Analytics")
    print("\n")
    print("0: DISCONNECT FROM DATABASE")
    choice = input("Enter choice: ")
    return choice


'''
MANAGE RECORDS
'''

def display_manage_records_menu():
    """Display menu for records"""
    print("\n=== MANAGE CAPITOL RECORDS ===")
    print("1: Manage Tributes")
    print("2: Manage Sponsors")
    print("3: Manage Games")
    print("4: Manage Gamemakers")
    print("5: Manage Team Members")
    print("6: Manage Participants")
    print("7: Manage Victors")
    print("0: RETURN TO MAIN MENU")
    choice = input("Enter choice: ")
    return choice



'''
VIEW RECORDS
'''

def display_view_records_menu():
    """Display menu for viewing records"""
    print("\n=== MANAGE CAPITOL RECORDS ===")
    print("1: View Tributes")
    print("2: View Sponsors")
    print("3: View Games")
    print("4: View Gamemakers")
    print("5: View Team Members")
    print("6: View Participants")
    print("7: View Victors")
    print("8: View Districts Victors")
    print("0: RETURN TO MAIN MENU")
    choice = input("Enter choice: ")
    return choice

def display_view_tribute_menu():
    """Displays the menu for viewing tributes"""
    print("\n=== VIEW TRIBUTES ===")
    print("1: View All Tributes")
    print("2: Search Tribute by Name")
    print("3: View Tributes by District")
    print("0: RETURN")
    choice = input("Enter choice: ")
    return choice


def get_tribute_name_input():
    """Get tribute name from user"""
    name = input("Enter tribute name to search: ")
    return name

def get_district_num_input():
    district = input("Enter district number: ")
    return district

def display_tributes(tributes):
    """Display formatted list of tributes"""
    if not tributes:
        print("\nNo tributes found.")
        return
        
    print("\n" + "=" * 80)
    print("TRIBUTES")
    print("=" * 80)
    print(f"{'ID':<5} | {'Name':<30} | {'District':<8} | {'Gender':<8} | {'Birth Date':<12}")
    print("-" * 80)
    for tribute in tributes:
        print(f"{tribute['tribute_id']:<5} | {tribute['name']:<30} | {tribute['district']:<8} | {tribute['gender']:<8} | {str(tribute['birth_date']):<12}")
    print("=" * 80 + "\n")








'''
SELECT GAME 
'''

def display_games(game_list):
    print("=================================")
    print("SELECT A GAME: ")
    for game in game_list:
        print("- " + game)
    # run function that handles this input
    print("=================================")



def get_game_input(game_list):
    """handle game input"""
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




