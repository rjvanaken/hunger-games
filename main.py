import pymysql
import database
import operations as ops
import menu
from datetime import datetime

def main():
    """Main application loop"""
    connection = None
    
    print("\n Welcome to:")
    print("=" * 42)
    print(" THE HUNGER GAMES MANAGEMENT SYSTEM")
    print("=" * 42)

    # Get database credentials and connect
    while True:
        print("\nYOUR CAPITOL CREDENTIALS:")
        # username, password = database.get_credentials()
        username, password = "root", "test"
        print("\nVerifying identity...\n")
        connection = database.connect_to_database(username, password)
        if connection is not None:
            break  
        print("Your credentials are incorrect, capitol citizen. Please try again\n")

    # Successful Connection - Main menu loop
    while True:
        choice = menu.display_menu()  # ← menu.py not operations
        
        if choice == '1':
            # Select Game
            handle_select_game(connection)
            
        elif choice == '2':
            # Manage Capitol Records
            handle_manage_records(connection)
            
        elif choice == '3':
            # View Capitol Records
            handle_view_records(connection)
            
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
    games = ops.get_games(connection)  # ← Get from operations
    game_num = menu.get_game_input(games)     # ← Display/input from menu
    # Then handle game-specific operations...
    
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
            id = menu.get_number_input('Enter ID of tribute to edit')
            print(f"\nUpdating Tribute with ID of {id}")
            print("─" * 42)
            name, dob, gender, district = menu.get_tribute_inputs(True)
            ops.edit_tribute(connection, id, name, dob, gender, district)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'tribute')
            menu.display_tributes_full(rows)
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
            id = menu.get_number_input('Enter ID of sponsor to edit')
            print(f"\nUpdating Sponsor with ID of {id}")
            print("─" * 42)
            name = menu.get_string_input("Enter the new full name of the sponsor or ENTER to skip")
            ops.edit_sponsor(connection, id, name)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors_full(rows)
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
            game_number = menu.get_number_input('Enter the number of the game to edit')
            print(f"\nUpdating Game {game_number}")
            print("─" * 42)
            start_date, end_date, game_status, required_tribute_count = menu.get_games_inputs(True)
            ops.edit_game(connection, game_number, start_date, end_date, game_status, required_tribute_count)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'game')
            menu.display_games_full(rows)
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
            id = menu.get_number_input('Enter ID of gamemaker to edit')
            print(f"\nUpdating Gamemaker with ID of {id}")
            print("─" * 42)
            name = menu.get_string_input("Enter the new full name of the gamemaker or ENTER to skip")
            ops.edit_gamemaker(connection, id, name)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(rows)
            id = menu.get_number_input('Enter ID of gamemaker to delete')
            ops.delete_gamemaker(connection, id)
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
            id = menu.get_number_input('Enter ID of gamemaker to edit')
            print(f"\nUpdating Gamemaker with ID of {id}")
            print("─" * 42)
            name = menu.get_string_input("Enter the new full name of the gamemaker or ENTER to skip")
            ops.edit_gamemaker(connection, id, name)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'gamemaker')
            menu.display_gamemakers_full(rows)
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
            id = menu.get_number_input('Enter ID of team_member to edit')
            print(f"\nUpdating Team member with ID of {id}")
            print("─" * 42)
            name, victor_id = menu.get_team_member_inputs(True)
            ops.edit_team_member(connection, id, name, victor_id)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'team_member')
            menu.display_team_members_full(rows)
            id = menu.get_number_input('Enter ID of team_member to delete')
            ops.delete_team_member(connection, id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")



def handle_manage_participants(connection):
    while True:
        choice = menu.display_manage_entity_menu('participant')
        if choice == '1':
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
        elif choice == '2': # CREATE
            tribute_id, game_number = menu.get_participant_inputs()
            ops.create_participant(connection, tribute_id, game_number)
            
        elif choice == '3': # UPDATE
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
            participant_id = menu.get_string_input('Enter participant ID to edit')
            print(f"\nUpdating Participant with ID of {participant_id}")
            print("─" * 42)
            final_placement, intelligence_score, likeability_score = menu.get_participant_inputs_edit()
            ops.edit_participant(connection, participant_id, final_placement, intelligence_score, likeability_score)
            
        elif choice == '4': # DELETE
            rows = ops.view_table(connection, 'participant')
            menu.display_participants_full(rows)
            participant_id = menu.get_string_input('Enter participant ID to delete')
            ops.delete_participant(connection, participant_id)
        elif choice == '0':
            break
        else:
            print("Invalid entry")


def handle_manage_victors(connection):
    while True:
        choice = menu.display_manage_victors_menu()
        if choice == '1': # DELETE
            rows = ops.view_victors_for_delete(connection)
            menu.display_victors_full(rows)
            victor_id = menu.get_number_input('Enter the victor ID to delete')
            ops.delete_victor(connection, victor_id)
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





def handle_analytics(connection):
    """Handle stats & analytics"""
    # Your analytics routing here
    pass


def close_connection(connection):
    connection.close()
    print("Successfully disconnected from database")



if __name__ == "__main__":
    main()