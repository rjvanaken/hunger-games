import operations as ops

def display_menu():
    """Top menu options"""
    print("\n=== MENU ===")
    print("1: Select Game")
    print("2: Manage Capitol Records")
    print("3: View Capitol Records")
    print("4: Get Stats & Analytics")
    print("------------------------------")
    print("0: DISCONNECT FROM DATABASE\n")
    choice = input("Enter choice: ")
    return choice


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


    # NOT FINISHED


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
    print("0: RETURN TO MAIN MENU\n")
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
    print("0: RETURN TO MAIN MENU")
    choice = input("Enter choice: ")
    return choice

# VIEW TRIBUTES
def display_view_tributes_menu():
    """Displays the menu for viewing tributes"""
    print("\n=== VIEW TRIBUTES ===")
    print("1: View All Tributes")
    print("2: Search Tribute by Name")
    print("3: View Tributes From District")
    print("0: RETURN")
    choice = input("Enter choice: ")
    return choice

def display_tributes(tributes):
    """Display formatted list of tributes"""
    if not tributes:
        print("\nNo tributes found.")
        return
        
    print("\n" + "=" * 80)
    print("TRIBUTES")
    print("=" * 80)
    print(f"{'ID':<5} | {'Name':<25} | {'District':<8} | {'Gender':<8} | {'Birth Date':<12}")
    print("-" * 80)
    for tribute in tributes:
        print(f"{tribute['tribute_id']:<5} | {tribute['name']:<25} | {tribute['district']:<8} | {tribute['gender']:<8} | {str(tribute['dob']):<12}")
    print("=" * 80 + "\n")



    # VIEW SPONSORS
def display_view_sponsors_menu():
    """Displays the menu for viewing sponsors"""
    print("\n=== VIEW SPONSORS ===")
    print("1: View All Sponsors")
    print("2: Search Sponsor by Name")
    print("3: View All Sponsorships")
    print("4: View Sponsorships by Game and/or Tribute") 
    print("0: RETURN")
    choice = input("Enter choice: ")
    return choice

def display_sponsors(connection, sponsors):
    """Display formatted list of sponsors"""
    if not sponsors:
        print("\nNo sponsors found.")
        return
        
    print("\n" + "=" * 80)
    print("SPONSORS")
    print("=" * 80)
    print(f"{'ID':<5} | {'Name':<30} | {'Total Contributions':<20}")
    print("-" * 80)
    for sponsor in sponsors:
        total_contributions = ops.get_sponsor_total(connection, sponsor['sponsor_id'])
        print(f"{sponsor['sponsor_id']:<5} | {sponsor['name']:<30} | {total_contributions:<20}")
    print("=" * 80 + "\n")

def display_sponsorships(sponsorships):
    """Display formatted list of sponsorships"""
    if not sponsorships:
        print("\nNo sponsorships found.")
        return
        
    print("\n" + "=" * 100)
    print("SPONSORSHIPS")
    print("=" * 100)
    print(f"{'Sponsor ID':<15} | {'Participant ID':<15} | {'Sponsor Name':<30} | {'Tribute Name':<30} | {'Game Number':<12} | {'Amount':<10}")
    print("-" * 100)
    for sponsorship in sponsorships:
        print(f"{sponsorship['sponsor_id']:<15} | {sponsorship['participant_id']:<15} | {sponsorship['sponsor_name']:<30} | {sponsorship['tribute_name']:<30} | {sponsorship['game_number']:<12} | {sponsorship['amount']:<10}")
    print("=" * 100 + "\n")

    # VIEW GAMES
def display_view_games_menu():
    """Displays the menu for viewing games"""
    print("\n=== VIEW GAMES ===")
    print("1: View All Games")
    print("2: Search Game by Number")
    print("0: RETURN")
    choice = input("Enter choice: ")
    return choice

def display_games(games):
    """Display formatted list of games"""
    if not games:
        print("\nNo games found.")
        return
        
    print("\n" + "=" * 80)
    print("GAMES")
    print("=" * 80)
    print(f"{'Game Number':<12} | {'Start Date':<12} | {'End Date':<12} | {'Victor':<30} | {'Location':<30}")
    print("-" * 80)
    for game in games:
        victor = ', '.join([v['victor_name'] for v in game['victors']]) if game['victors'] else 'TBD'
        print(f"{game['game_number']:<12} | {str(game['start_date']):<12} | {str(game['end_date']):<12} | {victor:<30} | {game['location']:<30}")
    print("=" * 80 + "\n")


'''
ANALYTICS
'''


'''
INPUT FUNCTIONS
'''
def get_name_input(prompt):
    """Get name from user for:
    - tribute
    - sponsor
    - gamemaker
    - team member
    """
    name = input(f"{prompt}: ")
    return name

def get_number_input(prompt):
    """Get and validate number from user for:
    - game
    - district
    """
    while True:
        number = input(f"{prompt}: ").strip()
        if number.isdigit():
            return int(number)
        print("Invalid input. Please enter a number.")









