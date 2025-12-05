import database
import operations as ops
import menu
import colors as colors
from colors import Colors
import sys
import time

def main():
    """Main application loop"""
    connection = None
    
    arrow_back = " ➤➤➤──────────────────"
    arrow_front ="───────────────────➤ "
    arrow_back_with_color = f"{Colors.YELLOW}{Colors.BOLD}{arrow_back}{Colors.RESET}"
    arrow_front_with_color = f"{Colors.YELLOW}{Colors.BOLD}{arrow_front}{Colors.RESET}"
    title_text = " THE HUNGER GAMES MANAGEMENT SYSTEM "
    
    full_text_length = len(arrow_back) + len(title_text) + len(arrow_front)
    print("\n")
    print("=" * 80)
    print(f"{arrow_back_with_color}{title_text}{arrow_front_with_color}" + " " * (80 - full_text_length))
    print("=" * 80)
    
    
    # Get database credentials and connect
    while True:
        
        print(f"\n{Colors.BOLD}ENTER YOUR CAPITOL CREDENTIALS:{Colors.RESET}")
        if '--test' in sys.argv:
            username, password = "snow", "lucygray"

        else:
            username, password = database.get_credentials()

            print(f"\n{Colors.BLUE}Verifying identity", end="", flush=True)
            for i in range(3):
                time.sleep(0.25)
                print(".", end="", flush=True)
                time.sleep(0.5)
            print(f"{Colors.RESET}\n")

        connection = database.connect_to_database(username, password)
        if connection is not None:
            print(f"{Colors.GREEN}✓ Successfully connected to the capitol database!{Colors.RESET}")
            break  
        print(f"{Colors.RED}✗ Your credentials are incorrect, capitol citizen. Please try again.{Colors.RESET}\n")

    print("\nUse the menu below to proceed into the application\n")



    # Successful Connection - Main menu loop
    while True:
        choice = menu.display_menu()        
        if choice == '1':
            # View Game Dashboard
            handle_select_game(connection)
            
        elif choice == '2':
            # View Capitol Records
            handle_view_records(connection)
            
        elif choice == '3':
            # Manage Capitol Records
            handle_manage_records(connection)
            
        elif choice == '4':
            # Stats & Analytics
            handle_analytics(connection)
            
        elif choice == '0':
            # Disconnect from database
            connection.close()
            print("Successfully disconnected from database")
            break
            
        else:
            print("\nInvalid choice. Please try again.")



def handle_select_game(connection):
    """Handle game selection and game operations"""
    rows = ops.view_games(connection)
    menu.display_games(rows)
    while True:
        game_number = menu.get_number_input("\nEnter the game number to view its game dashboard or 0 to RETURN")
        if game_number == 0:
            break
        rows = ops.view_games(connection, game_number)
        if not rows:
            print("\nGame does not exist. Please try again.\n")
            continue
        menu.display_game_dashboard(connection, str(game_number))
        if not menu.get_yes_no_input('Would you like to view another game? (Y/N)'):
            break
        
        rows = ops.view_games(connection)
        menu.display_games(rows)
                    
    
#-----------------------------------
# HANDLE MANAGE RECORDS
#-----------------------------------
def handle_manage_records(connection):
    """Handle manage records submenu"""
    while True:
        manage_choice = menu.display_manage_records_menu()
        if manage_choice == '1':
            handle_manage_tributes(connection)
        elif manage_choice == '2':
            handle_manage_sponsors(connection)
        elif manage_choice == '3':
            handle_manage_games(connection)
        elif manage_choice == '4':
            handle_manage_gamemakers(connection)
        elif manage_choice == '5':
            handle_manage_team_members(connection)
        elif manage_choice == '6':
            handle_manage_participants(connection)
        elif manage_choice == '7':
            handle_manage_victors(connection)
        elif manage_choice == '8':
            handle_manage_team_roles(connection)
        elif manage_choice == '9':
            handle_manage_sponsorships(connection)
        elif manage_choice == '10':
            handle_manage_game_victors(connection)
        elif manage_choice == '11':
            handle_manage_game_creators(connection)
        elif manage_choice == '12':
            handle_manage_gamemaker_scores(connection)
        elif manage_choice == '0':
            break
        else:
            print("Invalid entry")
# MANAGE TRIBUTES
def handle_manage_tributes(connection):
    while True:
        choice = menu.display_manage_entity_menu('tribute')
        if choice == '1':
            rows = ops.view_table(connection, 'tribute')
            menu.display_tributes_full(rows)
        elif choice == '2': # CREATE
            name, dob, gender, district = menu.get_tribute_inputs()
            ops.create_tribute(connection, name, dob, gender, district)
            
        elif choice == '3': # EDIT
            rows = ops.view_table(connection, 'tribute')
            menu.display_tributes_full(rows)
            if not rows:
                print("No tributes available to edit.")
                continue
            id = menu.get_number_input('Enter ID of tribute to edit')
            print(f"\nUpdating Tribute with ID of {id}")
            print("─" * 42)
            name, dob, gender, district = menu.get_tribute_inputs(True)
            ops.edit_tribute(connection, id, name, dob, gender, district)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'tribute')
            menu.display_tributes_full(rows)
            if not rows:
                print("No tributes available to delete.")
                continue
            id = menu.get_number_input('Enter ID of tribute to delete')
            ops.delete_tribute(connection, id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE SPONSORS
def handle_manage_sponsors(connection):
    while True:
        choice = menu.display_manage_entity_menu('sponsor')
        if choice == '1':
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors_full(rows)
        elif choice == '2': # CREATE
            name = menu.get_string_input("Enter the full name of the sponsor", True)
            ops.create_sponsor(connection, name)
            
        elif choice == '3': # UPDATE
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors_full(rows)
            if not rows:
                print("No sponsors available to edit.")
                continue
            id = menu.get_number_input('Enter ID of sponsor to edit')
            print(f"\nUpdating Sponsor with ID of {id}")
            print("─" * 42)
            name = menu.get_string_input("Enter the new full name of the sponsor or ENTER to skip")
            ops.edit_sponsor(connection, id, name)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors_full(rows)
            if not rows:
                print("No sponsors available to delete.")
                continue
            id = menu.get_number_input('Enter ID of sponsor to delete')
            ops.delete_sponsor(connection, id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE GAMES
def handle_manage_games(connection):
    while True:
        choice = menu.display_manage_entity_menu('game')
        if choice == '1':
            rows = ops.view_table(connection, 'game')
            menu.display_games_full(rows)
        elif choice == '2': # CREATE
            game_number, start_date, required_tribute_count = menu.get_games_inputs()
            ops.create_game(connection, game_number, start_date, required_tribute_count)
            
        elif choice == '3': # EDIT
            rows = ops.view_table(connection, 'game')
            menu.display_games_full(rows)
            if not rows:
                print("No games available to edit.")
                continue
            game_number = menu.get_number_input('Enter the number of the game to edit')
            print(f"\nUpdating Game {game_number}")
            print("─" * 42)
            start_date, end_date, game_status, required_tribute_count = menu.get_games_inputs(True)
            ops.edit_game(connection, game_number, start_date, end_date, game_status, required_tribute_count)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'game')
            menu.display_games_full(rows)
            if not rows:
                print("No games available to delete.")
                continue
            game_number = menu.get_number_input('Enter the number of the game to delete')
            ops.delete_game(connection, game_number)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE GAMEMAKERS
def handle_manage_gamemakers(connection):
    while True:
        choice = menu.display_manage_entity_menu('gamemaker')
        if choice == '1':
            rows = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(rows)
        elif choice == '2': # CREATE
            name = menu.get_string_input("Enter the full name of the gamemaker", True)
            ops.create_gamemaker(connection, name)
            
        elif choice == '3': # UPDATE
            rows = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(rows)
            if not rows:
                print("No gamemakers available to edit.")
                continue
            id = menu.get_number_input('Enter ID of gamemaker to edit')
            print(f"\nUpdating Gamemaker with ID of {id}")
            print("─" * 42)
            name = menu.get_string_input("Enter the new full name of the gamemaker or ENTER to skip")
            ops.edit_gamemaker(connection, id, name)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(rows)
            if not rows:
                print("No gamemakers available to delete.")
                continue
            id = menu.get_number_input('Enter ID of gamemaker to delete')
            ops.delete_gamemaker(connection, id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE TEAM MEMBERS
def handle_manage_team_members(connection):
    while True:
        choice = menu.display_manage_entity_menu('team_member')
        if choice == '1':
            rows = ops.view_table(connection, 'team_member')
            menu.display_team_members_full(rows)
        elif choice == '2': # CREATE
            name, victor_id = menu.get_team_member_inputs()
            ops.create_team_member(connection, name, victor_id)
            
        elif choice == '3': # UPDATE
            rows = ops.view_table(connection, 'team_member')
            menu.display_team_members_full(rows)
            if not rows:
                print("No team members available to edit.")
                continue
            id = menu.get_number_input('Enter ID of team_member to edit')
            print(f"\nUpdating Team member with ID of {id}")
            print("─" * 42)
            name, victor_id = menu.get_team_member_inputs(True)
            ops.edit_team_member(connection, id, name, victor_id)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'team_member')
            menu.display_team_members_full(rows)
            if not rows:
                print("No team members available to delete.")
                continue
            id = menu.get_number_input('Enter ID of team_member to delete')
            ops.delete_team_member(connection, id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE PARTICIPANTS
def handle_manage_participants(connection):
    while True:
        choice = menu.display_manage_entity_menu('participant')
        if choice == '1':
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
        elif choice == '2': # CREATE
            games = ops.view_table(connection, 'game')
            menu.display_games_full(games)
            tributes = ops.view_table(connection, 'tribute')
            menu.display_tributes_full(tributes)

            print("Use the above tables to help create your Participant\n")
            
            tribute_id, game_number = menu.get_participant_inputs()
            ops.create_participant(connection, tribute_id, game_number)
            
        elif choice == '3': # UPDATE
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
            if not rows:
                print("No participants available to edit.")
                continue
            participant_id = menu.get_string_input('Enter participant ID to edit')
            print(f"\nUpdating Participant with ID of {participant_id}")
            print("─" * 42)
            final_placement, intelligence_score, likeability_score = menu.get_participant_inputs_edit()
            ops.edit_participant(connection, participant_id, final_placement, intelligence_score, likeability_score)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
            if not rows:
                print("No participants available to delete.")
                continue
            participant_id = menu.get_string_input('Enter participant ID to delete')
            ops.delete_participant(connection, participant_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE VICTORS
def handle_manage_victors(connection):
    while True:
        choice = menu.display_manage_entity_menu_view_delete_only('victor')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_victors_for_ref')
            menu.display_victors_full(rows)
        elif choice == '2': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_victors_for_ref')
            menu.display_victors_full(rows)
            if not rows:
                print("No victors available to delete.")
                continue
            victor_id = menu.get_number_input('Enter the victor ID to delete')
            ops.delete_victor(connection, victor_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")

# MANAGE SPONSORSHIPS
def handle_manage_sponsorships(connection):
    while True:
        choice = menu.display_manage_entity_menu('sponsorship')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_sponsorships_for_ref')
            menu.display_sponsorships_full(rows)
        elif choice == '2': # CREATE
            sponsors = ops.view_table(connection, 'sponsor')
            menu.display_sponsors_full(sponsors)
            participants = ops.view_table(connection, 'participant')
            menu.display_participants_full(participants)

            print("Use the above tables to help create your Sponsorship\n")

            participant_id, sponsor_id, sponsor_amount = menu.get_sponsorship_inputs()
            ops.create_sponsorship(connection, participant_id, sponsor_id, sponsor_amount)
        elif choice == '3': # EDIT
            rows = ops.view_entity_for_ref(connection, 'view_sponsorships_for_ref')
            menu.display_sponsorships_full(rows)
            if not rows:
                print("No sponsorships available to edit.")
                continue
            sponsor_id = menu.get_number_input('Enter sponsor ID of the sponsorship to edit')
            participant_id = menu.get_string_input('Enter participant ID of the sponsorship to edit', True)
            print(f"\nUpdating Sponsorship")
            print("─" * 42)
            amount = menu.get_sponsorship_inputs(True)
            ops.edit_sponsorship(connection, sponsor_id, participant_id, amount)
        elif choice == '4': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_sponsorships_for_ref')
            menu.display_sponsorships_full(rows)
            if not rows:
                print("No sponsorships available to delete.")
                continue
            sponsor_id = menu.get_number_input('Enter sponsor ID of the sponsorship to delete')
            participant_id = menu.get_string_input('Enter participant ID of the sponsorship to delete', True)
            ops.delete_sponsorship(connection, sponsor_id, participant_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")
            


# MANAGE TEAM_ROLES
def handle_manage_team_roles(connection):
    while True:
        choice = menu.display_manage_entity_menu('team_role')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_team_roles_for_ref')
            menu.display_team_roles_full(rows)
        elif choice == '2': # CREATE
            participants = ops.view_table(connection, 'participant')
            menu.display_participants_full(participants)
            members = ops.view_table(connection, 'team_member')
            menu.display_team_members_full(members)
    
            print("Use the above tables to help create your Team Role\n")

            member_id, participant_id, member_type = menu.get_team_role_inputs()
            ops.create_team_role(connection, member_id, participant_id, member_type)
        elif choice == '3': # EDIT
            rows = ops.view_entity_for_ref(connection, 'view_team_roles_for_ref')
            menu.display_team_roles_full(rows)
            if not rows:
                print("No team roles available to edit.")
                continue
            member_id = menu.get_number_input('Enter member ID of the team role to edit')
            participant_id = menu.get_string_input('Enter participant ID of the team role to edit')
            print(f"\nUpdating Team Role")
            print("─" * 42)
            member_type = menu.get_team_role_inputs(True)
            ops.edit_team_role(connection, member_id, participant_id, member_type)
        elif choice == '4': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_team_roles_for_ref')
            menu.display_team_roles_full(rows)
            if not rows:
                print("No team roles available to delete.")
                continue
            member_id = menu.get_number_input('Enter member ID of the team role to delete')
            participant_id = menu.get_string_input('Enter participant ID of the team role to delete', True)
            ops.delete_team_role(connection, member_id, participant_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")


# MANAGE GAMEMAKER_SCORES
def handle_manage_gamemaker_scores(connection):
    while True:
        choice = menu.display_manage_entity_menu('gamemaker_score')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_gamemaker_scores_for_ref')
            menu.display_gamemaker_scores_full(rows)
        elif choice == '2': # CREATE
            participants = ops.view_table(connection, 'participant')
            menu.display_participants_full(participants)
            gamemakers = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(gamemakers)
            
            print("Use the above tables to help create your Gamemaker Score\n")

            gamemaker_id, participant_id, assessment_score = menu.get_gamemaker_score_inputs()
            ops.create_gamemaker_score(connection, gamemaker_id, participant_id, assessment_score)
        elif choice == '3': # EDIT
            rows = ops.view_entity_for_ref(connection, 'view_gamemaker_scores_for_ref')
            menu.display_gamemaker_scores_full(rows)
            if not rows:
                print("No gamemaker scores available to edit.")
                continue
            gamemaker_id = menu.get_number_input('Enter gamemaker ID of the gamemaker score to edit')
            participant_id = menu.get_string_input('Enter participant ID of the gamemaker score to edit', True)
            print(f"\nUpdating Gamemaker Score")
            print("─" * 42)
            assessment_score = menu.get_gamemaker_score_inputs(True)
            ops.edit_gamemaker_score(connection, gamemaker_id, participant_id, assessment_score)
        elif choice == '4': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_gamemaker_scores_for_ref')
            menu.display_gamemaker_scores_full(rows)
            if not rows:
                print("No gamemaker scores available to delete.")
                continue
            gamemaker_id = menu.get_number_input('Enter gamemaker ID of the gamemaker score to delete')
            participant_id = menu.get_string_input('Enter participant ID of the gamemaker score to delete', True)
            ops.delete_gamemaker_score(connection, gamemaker_id, participant_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")


# MANAGE GAME_VICTORS
def handle_manage_game_victors(connection):
    while True:
        choice = menu.display_manage_entity_menu_view_delete_only('game_victor')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_game_victors_for_ref')
            menu.display_game_victors_full(rows)
        elif choice == '2': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_game_victors_for_ref')
            menu.display_game_victors_full(rows)
            if not rows:
                print("No game victors available to delete.")
                continue
            game_number = menu.get_number_input('Enter game number of the game victor to delete')
            victor_id = menu.get_number_input('Enter victor ID of the game victor to delete')
            ops.delete_game_victor(connection, game_number, victor_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")


# MANAGE GAME_CREATORS
def handle_manage_game_creators(connection):
    while True:
        choice = menu.display_manage_entity_menu_no_edit('game_creator')
        if choice == '1': # VIEW
            rows = ops.view_entity_for_ref(connection, 'view_game_creators_for_ref')
            menu.display_game_creators_full(rows)
        elif choice == '2': # CREATE
            gamemakers = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(gamemakers)
            games = ops.view_table(connection, 'game')
            menu.display_games_full(games)

            print("Use the above tables to help create your Game Creator\n")

            game_number, gamemaker_id = menu.get_game_creator_inputs()
            ops.create_game_creator(connection, game_number, gamemaker_id)
        elif choice == '3': # DELETE
            rows = ops.view_entity_for_ref(connection, 'view_game_creators_for_ref')
            menu.display_game_creators_full(rows)
            if not rows:
                print("No game creators available to delete.")
                continue
            game_number = menu.get_number_input('Enter game number of the game creator to delete')
            gamemaker_id = menu.get_number_input('Enter gamemaker ID of the game creator to delete')
            ops.delete_game_creator(connection, game_number, gamemaker_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")


#-------------------------------------
# HANDLE VIEW RECORDS
#-------------------------------------
def handle_view_records(connection):
    """Handle view records submenu"""
    while True:
        view_choice = menu.display_view_records_menu()
        if view_choice == '1':
            handle_view_tributes(connection)
        elif view_choice == '2':
            handle_view_sponsors(connection)
        elif view_choice == '3':
            handle_view_games(connection)
        elif view_choice == '4':
            handle_view_gamemakers(connection)
        elif view_choice == '5':
            handle_view_team_members(connection)
        elif view_choice == '6':
            handle_view_participants(connection)
        elif view_choice == '7':
            handle_view_victors(connection)
        elif view_choice == '8':
            handle_view_districts(connection)
        elif view_choice == '0':
            break
        else:
            print("Invalid entry")
        

# VIEW-TRIBUTES
def handle_view_tributes(connection):
    while True:
        choice = menu.display_view_tributes_menu()
        if choice == "1":
            rows = ops.view_tributes(connection)
            menu.display_tributes(rows) 

        elif choice == "2":
            name = menu.get_string_input("Enter tribute name")
            rows =  ops.view_tributes(connection, name, None)
            menu.display_tributes(rows)

        elif choice == "3":
            district = menu.get_number_input("Enter district number")
            if int(district) < 13:
                rows = ops.view_tributes(connection, None, district)
                menu.display_tributes(rows)
            else:
                print("District does not exist")
                
        elif choice == "0":
            break
        else:
            print("Invalid entry")

#VIEW-SPONSORS
def handle_view_sponsors(connection):
    while True:
        choice = menu.display_view_sponsors_menu()
        if choice == "1":
            rows = ops.view_sponsors(connection)
            menu.display_sponsors(connection, rows)
        
        elif choice == "2":
            name = menu.get_string_input("Enter sponsor name")
            rows = ops.search_sponsor_by_name(connection, name)
            menu.display_sponsors(connection, rows)
        
        elif choice == "3":
            rows = ops.view_sponsorships(connection, None, None)
            menu.display_sponsorships(rows)
            
        elif choice == "4":
            game = menu.get_number_input("Enter game number (0 to skip)")
            if game == "0":
                game = None
            name = menu.get_string_input("Enter tribute name (0 to skip)")
            if name == "0":
                name = None
            rows =  ops.view_sponsorships(connection, game, name)
            menu.display_sponsorships(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")


#VIEW-GAMES
def handle_view_games(connection):
    while True:
        choice = menu.display_view_games_menu()
        if choice == "1":
            rows = ops.view_games(connection)
            menu.display_games(rows)
        
        elif choice == "2":
            game = menu.get_number_input("Enter game number")
            rows = ops.view_games(connection, game)
            menu.display_games(rows)

        elif choice == "3":
            name = menu.get_string_input("Enter tribute name")
            rows = ops.view_games(connection, None, name)
            menu.display_games(rows)

        elif choice == "4":
            name = menu.get_string_input("Enter victor name")
            rows = ops.view_games(connection, None, None, name)
            menu.display_games(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")

# VIEW GAMEMAKERS
def handle_view_gamemakers(connection):
    while True:
        choice = menu.display_view_gamemakers_menu()
        if choice == "1":
            rows = ops.view_gamemakers(connection)
            menu.display_gamemakers(rows)
        
        elif choice == "2":
            name = menu.get_string_input("Enter gamemaker name")
            rows = ops.view_gamemakers(connection, name)
            menu.display_gamemakers(rows)

        elif choice == "3":
            game = menu.get_number_input("Enter game number")
            rows = ops.view_gamemakers(connection, None, game)
            menu.display_gamemakers(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")

# VIEW TEAM MEMBERS
def handle_view_team_members(connection):
    while True:
        choice = menu.display_view_team_members_menu()
        if choice == "1":
            rows = ops.view_team_members(connection) #TODO
            menu.display_team_members(rows) #TODO
        
        elif choice == "2":
            name = menu.get_string_input("Enter team member name")
            rows = ops.view_team_members(connection, name) #TODO
            menu.display_team_members(rows) #TODO

        elif choice == "3":
            type = menu.display_member_types()
            if type == "1":
                rows = ops.view_team_members(connection, member_type='escort')
                menu.display_team_members(rows)
            elif type == '2':
                rows = ops.view_team_members(connection, member_type='mentor')
                menu.display_team_members(rows)
            elif type == '3':
                rows = ops.view_team_members(connection, member_type='stylist')
                menu.display_team_members(rows)
            elif type == '4':
                rows = ops.view_team_members(connection, member_type='prep')
                menu.display_team_members(rows)
            elif choice == "0":
                break
            else:
                print("Invalid entry")

        elif choice == "4":
            tribute_name = menu.get_string_input("Enter tribute name")
            rows = ops.view_team_members(connection, None, None, tribute_name) #TODO
            menu.display_team_members(rows) #TODO

        elif choice == "0":
            break
        else:
            print("Invalid entry")
        
# VIEW PARTICIPANTS
def handle_view_participants(connection):
    while True:
        choice = menu.display_view_participants_menu()
        if choice == '1':
            rows = ops.view_partipants(connection)
            menu.display_participants(rows)

        elif choice == '2':
            tribute_name = menu.get_string_input("Enter participant name")
            rows = ops.view_partipants(connection, tribute_name)
            menu.display_participants(rows)

        elif choice == '3':
            age = menu.get_number_input("Enter age")
            rows = ops.view_partipants(connection, age_during_games=age)
            menu.display_participants(rows)

        elif choice == '4':
            game = menu.get_number_input("Enter game number")
            rows = ops.view_partipants(connection, game_number=game)
            menu.display_participants(rows)

        elif choice == '5':
            score = menu.get_number_input("Enter training score (1-12)")
            rows = ops.view_partipants(connection, training_score=score)
            menu.display_participants(rows)

        elif choice == '6':
            score = menu.get_number_input("Enter intelligence score (1-10)")
            rows = ops.view_partipants(connection, intelligence_score=score)
            menu.display_participants(rows)

        elif choice == '7':
            score = menu.get_number_input("Enter likeability score (1-10)")
            rows = ops.view_partipants(connection, likeability_score=score)
            menu.display_participants(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")

#VIEW-VICTORS
def handle_view_victors(connection):
    while True:
        choice = menu.display_view_victors_menu()
        if choice == '1':
            rows = ops.view_victors(connection)
            menu.display_victors(rows)

        elif choice == '2':
            tribute_name = menu.get_string_input("Enter tribute name")
            rows = ops.view_victors(connection, tribute_name)
            menu.display_victors(rows)

        elif choice == '3':
            game = menu.get_number_input("Enter game number")
            rows = ops.view_victors(connection, None, game)
            menu.display_victors(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")

def handle_view_districts(connection):
    rows = ops.view_districts(connection)
    menu.display_districts(rows)



'''
ANALYTICS
'''

def handle_analytics(connection):
    """Handle stats & analytics"""
    while True:
        choice = menu.display_analytics_menu()
        if choice == '1':
            handle_win_predictions(connection)
        elif choice == '2':
            handle_district_success_rates(connection)
        elif choice == '3':
            handle_sponsorship_impact(connection)
        elif choice == '4':
            handle_victor_age_analysis(connection)

        elif choice == "0":
            break
        else:
            print("Invalid entry")


def handle_win_predictions(connection):
    rows = ops.view_games(connection)
    menu.display_games(rows)
    while True:
        game_number = menu.get_number_input("\nEnter the game number to view its win predictions or 0 to RETURN")
        if game_number == 0:
            break
        rows = ops.view_games(connection, game_number)
        if not rows:
            print("\nGame does not exist. Please try again.\n")
            continue
        rows = ops.get_win_predictions(connection, game_number)
        menu.display_win_predictions(rows, game_number)

        if not menu.get_yes_no_input('Would you like to view another game? (Y/N)'):
            break
        rows = ops.view_games(connection)
        menu.display_games(rows)

def handle_district_success_rates(connection):
    rows = ops.get_raw_district_success_rates(connection)
    menu.display_district_success(rows)
def handle_sponsorship_impact(connection):
    rows = ops.get_funding_placement_analysis(connection)
    menu.display_sponsorship_impact(rows)
def handle_victor_age_analysis(connection):
    rows = ops.get_raw_victor_age_patterns(connection)
    menu.display_victor_age_analysis(rows)



def close_connection(connection):
    connection.close()
    print("Successfully disconnected from database")



if __name__ == "__main__":
    main()