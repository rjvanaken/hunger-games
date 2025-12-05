# Hunger Games Capitol Database System
**CS5200 Database Management - Final Project**

---

## SYSTEM REQUIREMENTS

### Software Dependencies
- **Python 3.12 or higher**
  - Download: https://www.python.org/downloads/
- **MySQL 8.0 or higher**
  - Download: https://dev.mysql.com/downloads/mysql/

### Required Python Libraries
- `pymysql` - MySQL database connector

*Note: All other libraries (`datetime`, `sys`, `time`) are part of Python's standard library and require no installation.*

---

## INSTALLATION INSTRUCTIONS

### Step 1: Install Python
1. Download Python 3.12+ from https://www.python.org/downloads/
2. During installation, ensure "Add Python to PATH" is checked
3. Verify installation:

```bash
   python --version
```

### Step 2: Install MySQL
1. Download MySQL 8.0+ from https://dev.mysql.com/downloads/mysql/
2. Follow installation wizard
3. Remember your root password
4. Verify installation:
```bash
   mysql --version
```

### Step 3: Install Python Dependencies
Navigate to the project directory and run:
```bash
pip install pymysql
```

---

## DATABASE SETUP

### Step 1: Load Database Dump
1. Open terminal/command prompt
2. Navigate to the project directory containing the dump file
3. Execute:
```bash
   mysql -u root -p < hunger_games_dump.sql
```
4. Enter your MySQL root password when prompted
5. 

### Step 2: Verify Database Creation
```bash
mysql -u root -p
USE hunger_games;
SHOW TABLES;
```

You should see 12+ tables including: `tribute`, `participant`, `victor`, `game`, `district`, `sponsor`, `gamemaker`, `team_member`, `sponsorship`, `team_role`, `game_victor`, `game_creator`, `gamemaker_score`

You should see the following procedures:

You should see the following functions:

You should see the following triggers:

---

## RUNNING THE APPLICATION

### Step 1: Navigate to Project Directory
```bash
cd path/to/hunger-games
```

### Step 2: Run the Application

**Normal Mode (with login):**
```bash
python main.py
```

**Test Mode (skip login for development):**
```bash
python main.py --test
```

### Step 3: Login
When prompted, enter your MySQL credentials:
- Username: `your_mysql_username`
- Password: `your_mysql_password`

*(For test mode, default credentials are pre-configured)*

---

## PROJECT STRUCTURE
```
hunger-games/
├── main.py                    # Main application entry point
├── operations.py              # Database operations (CRUD)
├── database.py                # Database connection utilities
├── menu.py                    # Menu display functions
├── utils.py                   # Utility functions
├── colors.py                  # Terminal color formatting
└── hunger_games_dump.sql      # Database dump file
```

---

## APPLICATION FEATURES

### 1. Dashboard
View comprehensive game information including participants, sponsors, staff, and victors for any game in the database.

### 2. Browse Capitol Records
Filter and search database records across all entities including tributes, sponsors, games, gamemakers, team members, participants, victors, and districts.

### 3. Manage Capitol Records
Complete CRUD operations (Create, Read, Update, Delete) for all database entities with proper validation and error handling.

### 4. Stats & Analytics
- **Win Predictions**: Calculate probability of victory for game participants based on training, intelligence, and likeability scores
- **District Success Rates**: Analyze win rates and performance metrics by district
- **Sponsorship Impact Analysis**: Examine correlation between tribute funding and final placement
- **Victor Age Analysis**: Success rates and patterns by tribute age (restricted to standard Games ages 12-18)

---

## TROUBLESHOOTING

**Issue: `ModuleNotFoundError: No module named 'pymysql'`**
- Solution: Run `pip install pymysql`

**Issue: `Access denied for user` when connecting to MySQL**
- Solution: Verify your MySQL credentials are correct

**Issue: `Unknown database 'hunger_games'`**
- Solution: Re-run the database dump: `mysql -u root -p < hunger_games_dump.sql`

**Issue: Menu displays look broken**
- Solution: Ensure your terminal supports UTF-8 encoding for box-drawing characters. Modern terminals (Windows Terminal, iTerm2, etc.) support these by default.

---

## NOTES
- The application uses UTF-8 box-drawing characters for UI elements. Modern terminals support these, but older systems may display incorrect characters.
- Test mode (`--test` flag) is for development purposes and bypasses authentication with pre-configured credentials.
- All SQL queries are encapsulated in stored procedures and functions following database best practices and assignment requirements.
- The database includes triggers for automatic victor management when participant placements are updated.
- Sample data is included for Games 10, 11, 50, 74, and 75 for demonstration and testing purposes.

---