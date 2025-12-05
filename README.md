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

### Step 1: Import the Database (REQUIRES ROOT/ADMIN ACCESS)

The database dump file must be imported using MySQL **root** credentials (or equivalent admin user).

**Option A - Command Line (Recommended):**
```bash
mysql -u root -p < hunger_games_dump.sql
```
Enter your MySQL root password when prompted.

**Option B - MySQL Workbench:**
1. Open MySQL Workbench and connect as **root** user
2. Go to **Server → Data Import**
3. Select **"Import from Self-Contained File"**
4. Choose `hunger_games_dump.sql`
5. Click **"Start Import"**

### Step 2: Verify Database Creation

The dump file automatically creates:
- ✓ The `hunger_games` database with all tables, procedures, functions, and triggers
- ✓ A user account for the application: **username:** `snow` | **password:** `lucygray`

To verify, run:
```bash
mysql -u root -p
USE hunger_games;
SHOW TABLES;
```

You should see 13 tables including: `tribute`, `participant`, `victor`, `game`, `district`, `sponsor`, `gamemaker`, `team_member`, `sponsorship`, `team_role`, `game_victor`, `game_creator`, `gamemaker_score`

The database also includes:
- **60 stored procedures** for CRUD operations and analytics
- **7 functions** for calculations and data retrieval
- **6 triggers** for automatic data management
- **1 view** for easy access of information often displayed along with participant

To verify:
```bash
SHOW PROCEDURE STATUS WHERE Db = 'hunger_games';
SHOW FUNCTION STATUS WHERE Db = 'hunger_games';
SHOW TRIGGERS FROM hunger_games;
```

**Important:** You only need root access for importing the database. The application itself connects using the `snow` user

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

### Step 3: Login (Normal Mode Only)
When prompted, enter the application credentials:
- **Username:** `snow`
- **Password:** `lucygray`

*(These credentials are created automatically when you import the dump file)*

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
├── create_thg.sql             # Creates tables for testing
├── .gitignore                 # gitignore
└── README.md                  # This file
```

---

## APPLICATION FEATURES

### 1. Dashboard
View comprehensive game information including participants, sponsors, staff, and victors for any game in the database.

### 2. Browse Capitol Records
Filter and search database records across all entities including tributes, sponsors, games, gamemakers, team members, participants, victors, and districts.

### 3. Manage Capitol Records
Complete CRUD operations (Create, Read, Update, Delete) for all database entities with appropriate restrictions and validation based on business logic.

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
- Solution: Verify you're using the application credentials (`snow` / `lucygray`) not your personal MySQL credentials

**Issue: `Unknown database 'hunger_games'`**
- Solution: Re-import the database dump as root: `mysql -u root -p < hunger_games_dump.sql`

**Issue: Cannot import dump file - permission denied**
- Solution: Ensure you're running the import command as MySQL root user, not the application user

**Issue: Menu displays look broken**
- Solution: Ensure your terminal supports UTF-8 encoding for box-drawing characters. Modern terminals (Windows Terminal, iTerm2, etc.) support these by default.

**Issue: Tables wrap around and are unreadable**
- Solution: Expand your terminal window size and re-run

---

## NOTES
- **Database Import:** Root/admin access is required ONLY for importing the dump file. The application runs with the `snow` user.
- The application uses UTF-8 box-drawing characters for UI elements. Modern terminals support these, but older systems may display incorrect characters.
- Test mode (`--test` flag) is for development purposes and bypasses authentication with pre-configured credentials.
- All SQL queries are encapsulated in stored procedures and functions following database best practices and assignment requirements.
- The database includes triggers for automatic victor management when participant placements are updated.
- Sample data is included for various games and data from the books, along with full fake games data for games 16-33 for demonstration and testing purposes.

---
