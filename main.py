import pymysql
import database
import operations

def main():
    """Main application loop"""
    connection = None
    while True:
        username, password = database.get_credentials()
        connection = database.connect_to_database(username, password)
        if connection is not None:
            break  
        print("Your credentials are incorrect, capitol citizen. Please try again\n")

    # Successful Connection:
    type_list = get_spell_types(connection)

    # Step 12: Show menu options
    while True:
        choice = operations.display_menu()
        
        if choice == '1':
            # Steps 13-15a: Prompt and validate spell type input
            spell_type = get_spell_type_input(type_list)  
            # Steps 15b-17: Call procedure and display results or handle error
            display_spells_by_type(connection, spell_type)
            
        elif choice == '2':
            # Step 18: Disconnect from database
            connection.close()
            print("Successfully disconnected from database")
            break
            
        else:
            print("\nInvalid choice. Please try again.")

    

if __name__ == "__main__":
    main()