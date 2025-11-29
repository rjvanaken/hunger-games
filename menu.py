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

def display_manage_entity_menu(entity):
    """Display menu for managing entity records"""
    length = 42
    print("\n" + "=" * length)
    print(f" MANAGE {entity.upper()}S")
    print("=" * length)
    print(f" 1: View {entity.title()}s")
    print(f" 2: CREATE {entity.title()}")
    print(f" 3: UPDATE {entity.title()}")
    print(f" 4: DELETE {entity.title()}")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice


# VIEW TRIBUTES FULL
def display_tributes_full(tributes):
    """Display formatted list of tributes"""
    if not tributes:
        print("\nNo tributes found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(t['tribute_id'])) for t in tributes)
    id_width = max(id_width, len('tribute_id'))
    
    name_width = max(len(str(t['name'])) for t in tributes)
    name_width = max(name_width, len('name'))
    
    dob_width = max(len(str(t['dob'])) for t in tributes)
    dob_width = max(dob_width, len('birth_date'))
    
    gender_width = max(len(str(t['gender'])) for t in tributes)
    gender_width = max(gender_width, len('gender'))
    
    district_width = max(len(str(t['district'])) for t in tributes)
    district_width = max(district_width, len('district'))
    
    # Calculate total length
    length = id_width + name_width + dob_width + gender_width + district_width + 16  # +16 for separators
    
    print("\n" + "=" * length)
    print(" TRIBUTES")
    print("=" * length)
    print(f" {'tribute_id':<{id_width}} │ {'name':<{name_width}} │ {'birth_date':<{dob_width}} │ {'gender':<{gender_width}} │ {'district':<{district_width}}")
    
    for tribute in tributes:
        print("─" * length)
        dob_str = str(tribute['dob']) if isinstance(tribute['dob'], str) else tribute['dob'].strftime('%Y-%m-%d')
        print(f" {tribute['tribute_id']:<{id_width}} │ {tribute['name']:<{name_width}} │ {dob_str:<{dob_width}} │ {tribute['gender']:<{gender_width}} │ {tribute['district']:<{district_width}}")
    
    print("=" * length + "\n")

# DISPLAY SPONSORS FULL
def display_sponsors_full(sponsors):
    """Display formatted list of sponsors"""
    if not sponsors:
        print("\nNo sponsors found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(s['sponsor_id'])) for s in sponsors)
    id_width = max(id_width, len('sponsor_id'))
    
    name_width = max(len(str(s['name'])) for s in sponsors)
    name_width = max(name_width, len('name'))
    
    # Calculate total length
    length = id_width + name_width + 16
    
    print("\n" + "=" * length)
    print(" SPONSORS")
    print("=" * length)
    print(f" {'sponsor_id':<{id_width}} │ {'name':<{name_width}}")
    
    for sponsor in sponsors:
        print("─" * length)
        print(f" {sponsor['sponsor_id']:<{id_width}} │ {sponsor['name']:<{name_width}}")
    
    print("=" * length + "\n")


# DISPLAY GAMES FULL
def display_games_full(games):
    """Display formatted list of games"""
    if not games:
        print("\nNo games found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(g['game_number'])) for g in games)
    id_width = max(id_width, len('game_number'))

    required_tributes_width = max(len(str(g['required_tribute_count'])) for g in games)
    required_tributes_width = max(required_tributes_width, len('required_tribute_count'))
    
    start_date_width = max(len(str(g['start_date'])) for g in games)
    start_date_width = max(start_date_width, len('start_date'))

    end_date_width = max(len(str(g['end_date'])) for g in games)
    end_date_width = max(end_date_width, len('end_date'))
    
    game_status_width = max(len(str(g['game_status'])) for g in games)
    game_status_width = max(game_status_width, len('game_status'))
    
    # Calculate total length
    length = id_width + required_tributes_width + start_date_width + end_date_width + game_status_width + 16 
    
    print("\n" + "=" * length)
    print(" GAMES")
    print("=" * length)
    print(f" {'game_number':<{id_width}} │ {'required_tribute_count':<{required_tributes_width}} │ {'start_date':<{start_date_width}} │ {'end_date':<{end_date_width}} │ {'game_status':<{game_status_width}}")
    

    for game in games:
        print("─" * length)
        sd_str = str(game['start_date']) if isinstance(game['start_date'], str) else game['start_date'].strftime('%Y-%m-%d')
        ed_str = game['end_date'].strftime('%Y-%m-%d') if game['end_date'] else 'N/A'
        print(f" {game['game_number']:<{id_width}} │ {game['required_tribute_count']:<{required_tributes_width}} │ {sd_str:<{start_date_width}} │ {ed_str:<{end_date_width}} │ {game['game_status']:<{game_status_width}}")
    
    print("=" * length + "\n")


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
    print(" 8: View Districts")
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
def get_string_input(prompt, required=False):
    """Get string from user for:
    - names (tribute, gamemaker, team_member)
    - gender
    - dates
    """
    while True:
        string = input(f"{prompt}: ")
        if required and string == '':
            print("an entry is required")
        else:
            return string

def get_number_input(prompt, update=False):
    """Get and validate number from user for:
    - game
    - district
    - scores
    """
    while True:
        number = input(f"{prompt}: ").strip()
        if update and number == "":
            return str(number)

        if number.isdigit():
            return int(number)
        print("Invalid input. Please enter a number.")


def get_tribute_inputs(on_update=False):
    if on_update:
        name = get_string_input("Enter the tribute's full name or ENTER to skip", True)
        dob = get_string_input("Enter tribute's birthday in the format 'yyyy-mm-dd' or ENTER to skip")
        gender = get_string_input("Enter the tribute's gender (M or F) or ENTER to skip")
        district = get_number_input("Enter the tribute's district number (1-12) or ENTER to skip", True)
    else:

        name = get_string_input("Enter the tribute's full name", True)
        dob = get_string_input("Enter tribute's birthday in the format 'yyyy-mm-dd'", True)

        gender = get_string_input("Enter the tribute's gender (M or F)", True)
        district = get_number_input("Enter the tribute's district number (1-12)")

    return name, dob, gender, district


def get_games_inputs(on_update=False):
    if on_update:
        start_date = get_string_input("Enter game's start date in the format 'yyyy-mm-dd' or ENTER to skip")
        end_date = get_string_input("Enter game's end date in the format 'yyyy-mm-dd' or ENTER to skip")
        game_status = get_string_input("Enter the game status (planned, in progress, or completed) or ENTER to skip")
        required_tribute_count = get_number_input("Enter the required number of tributes or ENTER to skip", True)
        
        return start_date, end_date, game_status, required_tribute_count
    else:
        start_date = get_string_input("Enter game's start date in the format 'yyyy-mm-dd'", True)
        game_number = get_number_input("Enter the game number")
        required_tribute_count = get_number_input("Enter the required number of tributes")

        return game_number, start_date, required_tribute_count








