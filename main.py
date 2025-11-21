import pymysql
import database
import operations as ops
import menu

def main():
    """Main application loop"""
    connection = None
    
    print("==================================")
    print("THE HUNGER GAMES MANAGEMENT SYSTEM")
    print("==================================")

    # Get database credentials and connect
    while True:
        # username, password = database.get_credentials()
        username, password = "root", "test"
        connection = database.connect_to_database(username, password)
        if connection is not None:
            break  
        print("Your credentials are incorrect, capitol citizen. Please try again\n")

    # Successful Connection - Main menu loop
    while True:
        print("menu display")
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
    
def handle_manage_records(connection):
    """Handle manage records submenu"""
    # Your submenu routing here
    pass

def handle_view_records(connection):
    print("handle view records submenu")
    """Handle view records submenu"""
    while True:
        view_choice = menu.display_view_records_menu()
        if view_choice == '1':
            handle_view_tributes(connection)
        elif view_choice == '2':
            handle_view_sponsors(connection)
        elif view_choice == '3':
            pass
        elif view_choice == '4':
            pass
        elif view_choice == '5':
            pass
        elif view_choice == '6':
            pass
        elif view_choice == '7':
            pass
        elif view_choice == '0':
            pass
        else:
            print("Invalid entry")

# VIEW-TRIBUTES
def handle_view_tributes(connection):
    while True:
        choice = menu.display_view_tributes_menu()
        if choice == "1":
            rows = ops.view_table(connection, 'tribute')
            menu.display_tributes(rows) 

        elif choice == "2":
            name = menu.get_name_input("Enter tribute name")
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
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors(connection, rows)
        
        elif choice == "2":
            name = menu.get_name_input("Enter sponsor name")
            rows = ops.view_table(connection, 'sponsor')
            menu.display_sponsors(connection, rows)
        
        elif choice == "3":
            rows = ops.view_table(connection, 'sponsorship')
            menu.display_sponsorships(rows)
            
        elif choice == "4":
            name = menu.get_name_input("Enter tribute name (0 to skip)")
            if name == "0":
                name = None
            district = menu.get_number_input("Enter district number (0 to skip)")
            if district == "0":
                district = None
            rows =  ops.view_sponsorships(connection, name, district)
            menu.display_sponsorships(rows)

        elif choice == "0":
            break
        else:
            print("Invalid entry")
        

def handle_analytics(connection):
    """Handle stats & analytics"""
    # Your analytics routing here
    pass


def close_connection(connection):
    connection.close()
    print("Successfully disconnected from database")



if __name__ == "__main__":
    main()