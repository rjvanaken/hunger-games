import operations as ops

def display_menu():
    """Top menu options"""
    length = 42
    print("\n" + "=" * length)
    print(" MENU")
    print("=" * length)
    print(" 1: Select Game")
    print(" 2: Manage Capitol Records")
    print(" 3: View Capitol Records")
    print(" 4: Get Stats & Analytics")
    print("─" * length)
    print(" 0: DISCONNECT FROM DATABASE\n")
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
    # Step 14: Validate │ Step 15: Error message and repeat input request
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
    length = 42
    print("\n" + "=" * length)
    print(" MANAGE CAPITOL RECORDS")
    print("=" * length)
    print(" 1: Manage Tributes")
    print(" 2: Manage Sponsors")
    print(" 3: Manage Games")
    print(" 4: Manage Gamemakers")
    print(" 5: Manage Team Members")
    print(" 6: Manage Participants")
    print(" 7: Manage Victors")
    print("─" * length)
    print(" 0: RETURN TO MAIN MENU\n")
    choice = input("Enter choice: ")
    return choice



'''
VIEW RECORDS
'''

def display_view_records_menu():
    """Display menu for viewing records"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW CAPITOL RECORDS")
    print("=" * length)
    print(" 1: View Tributes")
    print(" 2: View Sponsors")
    print(" 3: View Games")
    print(" 4: View Gamemakers")
    print(" 5: View Team Members")
    print(" 6: View Participants")
    print(" 7: View Victors")
    print("─" * length)
    print(" 0: RETURN TO MAIN MENU\n")
    choice = input("Enter choice: ")
    return choice


# VIEW TRIBUTES
def display_view_tributes_menu():
    """Displays the menu for viewing tributes"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW TRIBUTES")
    print("=" * length)
    print(" 1: View All Tributes")
    print(" 2: Search Tribute by Name")
    print(" 3: View Tributes From District")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_tributes(tributes):
    """Display formatted list of tributes"""
    length = 80
    if not tributes:
        print("\nNo tributes found.")
        return
        
    print("\n" + "=" * length)
    print(" TRIBUTES")
    print("=" * length)
    print(f" {'ID':<5} │ {'Name':<25} │ {'District':<8} │ {'Gender':<8} │ {'Birth Date':<12}")
    for tribute in tributes:
        if tribute['gender'] == 'm':
            gender = "Male"
        else:
            gender = "Female"
        print("─" * length)
        print(f" {tribute['tribute_id']:<5} │ {tribute['name']:<25} │ {tribute['district']:<8} │ {gender:<8} │ {str(tribute['dob']):<12}")
    print("=" * length + "\n")



    # VIEW SPONSORS
def display_view_sponsors_menu():
    """Displays the menu for viewing sponsors"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW SPONSORS")
    print("=" * length)
    print(" 1: View All Sponsors")
    print(" 2: Search Sponsor by Name")
    print(" 3: View All Sponsorships")
    print(" 4: View Sponsorships by Game and/or Tribute")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_sponsors(connection, sponsors):
    """Display formatted list of sponsors"""
    length = 70
    if not sponsors:
        print("\nNo sponsors found.")
        return
        
    print("\n" + "=" * length)
    print(" SPONSORS")
    print("=" * length)
    print(f" {'ID':<5} │ {'Name':<35} │ {'Total Contributions':<10}")
    for sponsor in sponsors:
        total_contributions = ops.get_sponsor_total(connection, sponsor['sponsor_id'])
        print("─" * length)
        print(f" {sponsor['sponsor_id']:<5} │ {sponsor['name']:<35} │ ${total_contributions:<10,.2f}")
    print("=" * length + "\n")


def display_sponsorships(sponsorships):
    """Display formatted list of sponsorships"""
    length = 130
    if not sponsorships:
        print("\nNo sponsorships found.")
        return
        
    print("\n" + "=" * length)
    print(" SPONSORSHIPS")
    print("=" * length)
    print(f" {'Sponsor ID':<12} │ {'Participant ID':<15} │ {'Sponsor Name':<30} │ {'Tribute Name':<30} │ {'Game Number':<12} │ {'Amount':<10}")
    for sponsorship in sponsorships:
        print("─" * length)
        print(f" {sponsorship['sponsor_id']:<12} │ {sponsorship['participant_id']:<15} │ {sponsorship['sponsor_name']:<30} │ {sponsorship['tribute_name']:<30} │ {sponsorship['game_number']:<12} │ ${sponsorship['amount']:<10,.2f}")
    print("=" * length + "\n")



    # VIEW GAMES
def display_view_games_menu():
    """Displays the menu for viewing games"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW GAMES")
    print("=" * length)
    print(" 1: View All Games")
    print(" 2: Search Game by Number")
    print(" 3: Search Game by Tribute")
    print(" 4: Search Game by Victor")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_games(games):
    """Display formatted list of games"""
    length = 115
    if not games:
        print("\nNo games found.")
        return
        
    print("\n" + "=" * length)
    print(" GAMES")
    print("=" * length)
    print(f" {'Game Number':<12} │ {'Number of Tributes':<20} │ {'Start Date':<12} │ {'End Date':<12} │ {'Victor(s)':<}")
    for game in games:
        victors = game['victor_names'] if game['victor_names'] else 'TBD'
        print("─" * length)
        print(f" {game['game_number']:<12} │ {game['tribute_count']:<20} │ {str(game['start_date']):<12} │ {str(game['end_date']):<12} │ {victors:<30}")
    print("=" * length + "\n")



    # VIEW GAMEMAKERS
def display_view_gamemakers_menu():
    """Displays the menu for viewing gamemakers"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW GAMEMAKERS")
    print("=" * length)
    print(" 1: View All Gamemakers")
    print(" 2: Search Gamemaker by Name")
    print(" 3: Search Gamemaker by Game Number")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_gamemakers(gamemakers):
    """Display formatted list of games"""
    length = 80
    if not gamemakers:
        print("\nNo gamemakers found.")
        return
        
    print("\n" + "=" * length)
    print(" GAMEMAKERS")
    print("=" * length)
    print(f" {'Gamemaker ID':<12} │ {'Name':<20}")
    for gamemaker in gamemakers:
        print("─" * length)
        #victors = game['victor_names'] if game['victor_names'] else 'TBD'
        print(f" {gamemaker['gamemaker_id']:<12} │ {gamemaker['name']:<20} ")
        # │ {victors:<30}
    print("=" * length + "\n")


    # VIEW TEAM MEMBERS
def display_view_team_members_menu():
    """Displays the menu for viewing team members"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW TEAM MEMBERS")
    print("=" * length)
    print(" 1: View All Team Members")
    print(" 2: Search Team Member by Name")
    print(" 3: Search Team Member by Role Type")
    print(" 4: Search Team Member by Tribute Name")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_member_types():
    """Displays the menu for viewing member types"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW TEAM MEMBERS")
    print("=" * length)
    print(" 1: Escort")
    print(" 2: Mentor")
    print(" 3: Stylist")
    print(" 4: Prep Team")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_team_members(team_members):
    """Display formatted list of team members"""
    length = 80
    if not team_members:
        print("\nNo team members found.")
        return
        
    print("\n" + "=" * length)
    print(" TEAM MEMBERS")
    print("=" * length)
    print(f" {'Member ID':<12} │ {'Name':<30} │ {'Roles':<15}")
    for member in team_members:
        roles = member['roles'].title() if member['roles'] else 'TBD'
        print("─" * length)
        print(f" {member['member_id']:<12} │ {member['name']:<30} │ {roles:<15}")
    print("=" * length + "\n")



    # VIEW PARTICIPANTS
def display_view_participants_menu():
    length = 42
    """Displays the menu for viewing participants"""
    print("\n" + "=" * length)
    print(" VIEW PARTICIPANTS")
    print("=" * length)
    print(" 1: View All Participants")
    print(" 2: Search Participant by Name")
    print(" 3: Search Participant by Age")
    print(" 4: Search Participant by Game Number")
    print(" 5: Search Participant by Training Score")
    print("─" * length)
    print(" 0: RETURN")
    print("\n")
    choice = input("Enter choice: ")
    return choice


def display_participants(participants):
    """Display formatted list of sponsors"""
    length = 175
    if not participants:
        print("\nNo participants found.")
        return
        
    print("\n" + "=" * length)
    print(" PARTICIPANTS")
    print("=" * length)
    print(f" {'ID':<12} │ {'Name':<30} │ {'District':<8} │ {'Gender':<8} │ {'Game Number':<12} │ {'Age During Games':<20} │ {'Training Score':<20} │ {'Interview Score':<20} │ {'Final Placement':<10}")
    # print("─" * length)
    for participant in participants:
        if participant['gender'] == 'M':
            gender = "Male"
        else:
            gender = "Female"
        print("─" * length)
        print(f" {participant['participant_id']:<12} │ {participant['name']:<30} │ {participant['district']:<8} │ {gender:<8} │ {participant['game_number']:<12} │ {participant['age_during_games']:<20} │ {str(participant['training_score']):<20} │ {str(participant['interview_score']):<20} │ {str(participant['final_placement']):<10}")
        
    print("=" * length + "\n")

    #VIEW VICTORS
def display_view_victors_menu():
    """Displays the menu for viewing victors"""
    length = 42
    print("\n" + "=" * length)
    print(" VIEW VICTORS")
    print("=" * length)
    print(" 1: View All Victors")
    print(" 2: Search Victor by Name")
    print(" 3: Search Victor by Game Number")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice


def display_victors(victors):
    """Display formatted list of victors"""
    length = 80
    if not victors:
        print("\nNo victors found.")
        return
        
    print("\n" + "=" * length)
    print(" VICTORS")
    print("=" * length)
    print(f" {'Tribute ID':<12} │ {'Victor Name':<30} │ {'Game Number(s)':<15}")
    print("─" * length)
    for victor in victors:
        games_won = victor['games_won'] if victor['games_won'] else 'TBD'
        print(f" {victor['victor_id']:<12} │ {victor['name']:<30} │ {games_won:<15}")
    print("=" * length + "\n")

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









