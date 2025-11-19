import pymysql
import database
import operations
import menu

def main():
    """Main application loop"""
    connection = None
    
    # Get database credentials and connect
    while True:
        username, password = database.get_credentials()
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
    games = operations.get_games(connection)  # ← Get from operations
    game_num = menu.get_game_input(games)     # ← Display/input from menu
    # Then handle game-specific operations...
    
def handle_manage_records(connection):
    """Handle manage records submenu"""
    # Your submenu routing here
    pass

def handle_view_records(connection):
    """Handle view records submenu"""
    # Your submenu routing here
    pass

def handle_analytics(connection):
    """Handle stats & analytics"""
    # Your analytics routing here
    pass

if __name__ == "__main__":
    main()