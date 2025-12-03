import operations as ops
import colors as colors
from colors import Colors

def display_menu():
    """Top menu options"""
    length = 42
    print("\n" + "=" * length)
    print(" MENU")
    print("=" * length)
    print(" 1: View Game Dashboard")
    print(" 2: Manage Capitol Records")
    print(" 3: View Capitol Records")
    print(" 4: Get Stats & Analytics")
    print("─" * length)
    print(" 0: DISCONNECT FROM DATABASE\n")
    choice = input("Enter choice: ")
    return choice


'''
ANALYTICS
'''

# VIEW GAMEMAKERS
def display_analytics_menu():
    """Displays the menu for analytics"""
    length = 42
    print("\n" + "=" * length)
    print(" STATS & ANALYTICS")
    print("=" * length)
    print(" 1: Win Predictions")
    print(" 2: District Success Rates")
    print(" 3: Sponsorship Impact")
    print(" 4: Assessment Accuracy Analysis")
    print(" 5: Victor Age Analysis")
    print(" 6: Mentor Success Rates")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice






'''
SELECT GAME 
'''


def display_game_dashboard(connection, game):
    """Display dashboard for specific game"""
    if game[-1] == 1:
        ordinal_suffix = 'ST'
    elif game[-1] == 2:
        ordinal_suffix = 'ND'
    elif game[-1] == 3:
        ordinal_suffix = 'RD'
    else:
        ordinal_suffix = 'TH'

    print("\n")
    game_info = ops.view_games(connection, game)
    display_game_info_on_dashboard(connection, game_info, ordinal_suffix)

    participants = ops.view_partipants(connection, None, None, game)
    display_participants(participants)
    sponsorships = ops.view_sponsorships(connection, game)
    display_sponsorships(sponsorships)
    staff = ops.view_game_staff(connection, game)
    display_game_staff(staff)
    victors = ops.view_victors(connection, None, game)
    display_victors(victors)
    print("\n")

def display_game_staff(staff):
    """Display formatted list of game staff (team members and gamemakers)"""
    if not staff:
        print("\nNo game staff found.")
        return
    
    # Calculate column widths
    name_width = max(len(str(s['name'])) for s in staff)
    name_width = max(name_width, len('Name'))
    
    role_width = max(len(str(s['role'])) for s in staff)
    role_width = max(role_width, len('Role'))
    
    district_width = max(len(str(s['district'])) for s in staff)
    district_width = max(district_width, len('District')) + 5
    
    length = name_width + role_width + district_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAME STAFF" + " " * (length - 13) + "║")
    print("╠" + "═" * (length - 2) + "╣")
    print(f"║ {'Name':<{name_width}} │ {'Role':<{role_width}} │ {'District':<{district_width}} ║")
    for i, person in enumerate(staff):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {person['name']:<{name_width}} │ {person['role'].title():<{role_width}} │ {person['district']:<{district_width}} ║")
    print("╚" + "═" * (length - 2) + "╝\n")


def display_game_info_on_dashboard(connection, game_info, ordinal_suffix):
    game = game_info[0]
    game_status = game['game_status'].title()
    total_tributes = game['tribute_count']
    game_number = game['game_number']
    sd_str = game['start_date'].strftime('%Y-%m-%d') if game['start_date'] else 'N/A'
    ed_str = game['end_date'].strftime('%Y-%m-%d') if game['end_date'] else 'N/A'
    num_tributes_remaining = ops.get_num_tributes_remaining(connection, game_number)
    
    status_color = colors.get_status_color(game_status)

    arrow_back = " ➤➤➤──────────────────"
    arrow_front ="────────────────────➤ "
    arrow_front_with_color = f"{Colors.YELLOW}{Colors.BOLD}{arrow_front}{Colors.RESET}"
    arrow_back_with_color = f"{Colors.YELLOW}{Colors.BOLD}{arrow_back}{Colors.RESET}"
    title_text = f" THE {game_number}{ordinal_suffix} HUNGER GAMES DASHBOARD "

    full_text_length = len(arrow_back) + len(title_text) + len(arrow_front)

    print("\n╔" + "═" * 78 + "╗")
    print(f"║{arrow_back_with_color}{title_text}{arrow_front_with_color}" + " " * (78 - full_text_length) + "║")
    print("╠" + "═" * 78 + "╣")
    print(f"║  Status: {status_color}{game_status}{colors.Colors.RESET}" + " " * (78 - len(f"  Status: {game_status}")) + "║")
    print(f"║  Start Date: {sd_str}" + " " * (78 - len(f"  Start Date: {sd_str}")) + "║")
    print(f"║  End Date: {ed_str}" + " " * (78 - len(f"  End Date: {ed_str}")) + "║")
    print(f"║  Tributes Remaining: {num_tributes_remaining}/{total_tributes}" + " " * (78 - len(f"  Tributes Remaining: {num_tributes_remaining}/{total_tributes}")) + "║")
    print("╚" + "═" * 78 + "╝\n")
    

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
    print(" 8: Manage Team Roles")
    print(" 9: Manage Sponsorships")
    print(" 10: Manage Game Victors")
    print(" 11: Manage Game Creators")
    print(" 12: Manage Gamemaker Scores")
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

def display_manage_entity_menu_no_edit(entity):
    """Display menu for managing entity records without edit option"""
    length = 42
    print("\n" + "=" * length)
    print(f" MANAGE {entity.upper()}S")
    print("=" * length)
    print(f" 1: View {entity.title()}s")
    print(f" 2: CREATE {entity.title()}")
    print(f" 3: DELETE {entity.title()}")
    print("─" * length)
    print(" 0: RETURN\n")
    choice = input("Enter choice: ")
    return choice

def display_manage_entity_menu_view_delete_only(entity):
    """Display menu for managing entity records with view and delete only"""
    length = 42
    print("\n" + "=" * length)
    print(f" MANAGE {entity.upper()}S")
    print("=" * length)
    print(f" 1: View {entity.title()}s")
    print(f" 2: DELETE {entity.title()}")
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
    district_width = max(district_width, len('district')) + 5
    
    length = id_width + name_width + dob_width + gender_width + district_width + 16
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ TRIBUTES" + " " * (length - 11) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'tribute_id':<{id_width}} │ {'name':<{name_width}} │ {'birth_date':<{dob_width}} │ {'gender':<{gender_width}} │ {'district':<{district_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, tribute in enumerate(tributes):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        dob_str = str(tribute['dob']) if isinstance(tribute['dob'], str) else tribute['dob'].strftime('%Y-%m-%d')
        print(f"║ {tribute['tribute_id']:<{id_width}} │ {tribute['name']:<{name_width}} │ {dob_str:<{dob_width}} │ {tribute['gender']:<{gender_width}} │ {tribute['district']:<{district_width}} ║")
        
    print("╚" + "═" * (length - 2) + "╝\n")


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
    name_width = max(name_width, len('name')) + 5
    
    length = id_width + name_width + 7
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ SPONSORS" + " " * (length - 11) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'sponsor_id':<{id_width}} │ {'name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, sponsor in enumerate(sponsors):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {sponsor['sponsor_id']:<{id_width}} │ {sponsor['name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    game_status_width = max(game_status_width, len('game_status')) + 5
    
    length = id_width + required_tributes_width + start_date_width + end_date_width + game_status_width + 16
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAMES" + " " * (length - 8) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'game_number':<{id_width}} │ {'required_tribute_count':<{required_tributes_width}} │ {'start_date':<{start_date_width}} │ {'end_date':<{end_date_width}} │ {'game_status':<{game_status_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, game in enumerate(games):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        sd_str = str(game['start_date']) if isinstance(game['start_date'], str) else game['start_date'].strftime('%Y-%m-%d')
        ed_str = game['end_date'].strftime('%Y-%m-%d') if game['end_date'] else 'N/A'

        status_color = colors.get_status_color(game['game_status'])
        status_text = game['game_status'].title()
        status_display = f"{status_color}{status_text}{Colors.RESET}"
        status_padding = game_status_width - len(status_text)
        
        print(f"║ {game['game_number']:<{id_width}} │ {game['required_tribute_count']:<{required_tributes_width}} │ {sd_str:<{start_date_width}} │ {ed_str:<{end_date_width}} │ {status_display}{' ' * status_padding} ║")
        
    print("╚" + "═" * (length - 2) + "╝\n")



# DISPLAY GAMEMAKERS FULL
def display_gamemakers_full(gamemakers):
    """Display formatted list of gamemakers"""
    if not gamemakers:
        print("\nNo gamemakers found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(gm['gamemaker_id'])) for gm in gamemakers)
    id_width = max(id_width, len('gamemaker_id'))
    
    name_width = max(len(str(gm['name'])) for gm in gamemakers)
    name_width = max(name_width, len('name')) + 5
    
    length = id_width + name_width + 7
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAMEMAKERS" + " " * (length - 13) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'gamemaker_id':<{id_width}} │ {'name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, gamemaker in enumerate(gamemakers):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {gamemaker['gamemaker_id']:<{id_width}} │ {gamemaker['name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY TEAM_MEMBERS FULL
def display_team_members_full(team_members):
    """Display formatted list of team members"""
    if not team_members:
        print("\nNo team members found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(tm['member_id'])) for tm in team_members)
    id_width = max(id_width, len('member_id'))
    
    name_width = max(len(str(tm['name'])) for tm in team_members)
    name_width = max(name_width, len('name'))
    
    victor_width = max(len(str(tm['victor_id']) if tm['victor_id'] else 'N/A') for tm in team_members)
    victor_width = max(victor_width, len('victor_id')) + 5
    
    length = id_width + name_width + victor_width + 10
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ TEAM MEMBERS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'member_id':<{id_width}} │ {'name':<{name_width}} │ {'victor_id':<{victor_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, tm in enumerate(team_members):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        victor_display = str(tm['victor_id']) if tm['victor_id'] else 'N/A'
        print(f"║ {tm['member_id']:<{id_width}} │ {tm['name']:<{name_width}} │ {victor_display:<{victor_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


def display_participants_full(participants):
    """Display formatted list of participants"""
    if not participants:
        print("\nNo participants found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(p['participant_id'])) for p in participants)
    id_width = max(id_width, len('participant_id'))
    
    tribute_width = max(len(str(p['tribute_id'])) for p in participants)
    tribute_width = max(tribute_width, len('tribute_id'))
    
    game_width = max(len(str(p['game_number'])) for p in participants)
    game_width = max(game_width, len('game_number'))
    
    placement_width = max(len(str(p['final_placement']) if p['final_placement'] else 'N/A') for p in participants)
    placement_width = max(placement_width, len('final_placement'))
    
    intel_width = max(len(str(p['intelligence_score']) if p['intelligence_score'] else 'N/A') for p in participants)
    intel_width = max(intel_width, len('intelligence_score'))
    
    like_width = max(len(str(p['likeability_score']) if p['likeability_score'] else 'N/A') for p in participants)
    like_width = max(like_width, len('likeability_score')) + 5
    
    length = id_width + tribute_width + game_width + placement_width + intel_width + like_width + 19
    
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ PARTICIPANTS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'participant_id':<{id_width}} │ {'tribute_id':<{tribute_width}} │ {'game_number':<{game_width}} │ {'final_placement':<{placement_width}} │ {'intelligence_score':<{intel_width}} │ {'likeability_score':<{like_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, p in enumerate(participants):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        placement_display = str(p['final_placement']) if p['final_placement'] else 'N/A'
        intel_display = str(p['intelligence_score']) if p['intelligence_score'] else 'N/A'
        like_display = str(p['likeability_score']) if p['likeability_score'] else 'N/A'
        print(f"║ {p['participant_id']:<{id_width}} │ {p['tribute_id']:<{tribute_width}} │ {p['game_number']:<{game_width}} │ {placement_display:<{placement_width}} │ {intel_display:<{intel_width}} │ {like_display:<{like_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")

# DISPLAY VICTORS FULL
def display_victors_full(victors):
    """Display formatted list of victors"""
    if not victors:
        print("\nNo victors found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(v['victor_id'])) for v in victors)
    id_width = max(id_width, len('Victor ID'))
    
    name_width = max(len(str(v['tribute_name'])) for v in victors)
    name_width = max(name_width, len('Tribute Name')) + 5
    
    length = id_width + name_width + 7
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ VICTORS" + " " * (length - 10) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Victor ID':<{id_width}} │ {'Tribute Name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, victor in enumerate(victors):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {victor['victor_id']:<{id_width}} │ {victor['tribute_name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY TEAM_ROLES FULL
def display_team_roles_full(team_roles):
    """Display formatted list of team roles"""
    if not team_roles:
        print("\nNo team roles found.")
        return
    
    # Calculate column widths
    member_id_width = max(len(str(tr['member_id'])) for tr in team_roles)
    member_id_width = max(member_id_width, len('member_id'))
    
    participant_id_width = max(len(str(tr['participant_id'])) for tr in team_roles)
    participant_id_width = max(participant_id_width, len('participant_id'))
    
    member_name_width = max(len(str(tr['member_name'])) for tr in team_roles)
    member_name_width = max(member_name_width, len('member_name'))
    
    tribute_name_width = max(len(str(tr['tribute_name'])) for tr in team_roles)
    tribute_name_width = max(tribute_name_width, len('tribute_name'))
    
    type_width = max(len(str(tr['member_type'])) for tr in team_roles)
    type_width = max(type_width, len('member_type')) + 5
    
    length = member_id_width + participant_id_width + member_name_width + tribute_name_width + type_width + 16
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ TEAM ROLES" + " " * (length - 13) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'member_id':<{member_id_width}} │ {'participant_id':<{participant_id_width}} │ {'member_name':<{member_name_width}} │ {'tribute_name':<{tribute_name_width}} │ {'member_type':<{type_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, tr in enumerate(team_roles):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {tr['member_id']:<{member_id_width}} │ {tr['participant_id']:<{participant_id_width}} │ {tr['member_name']:<{member_name_width}} │ {tr['tribute_name']:<{tribute_name_width}} │ {tr['member_type']:<{type_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY SPONSORSHIPS FULL
def display_sponsorships_full(sponsorships):
    """Display formatted list of sponsorships"""
    if not sponsorships:
        print("\nNo sponsorships found.")
        return

    # Calculate column widths
    sponsor_id_width = max(len(str(s['sponsor_id'])) for s in sponsorships)
    sponsor_id_width = max(sponsor_id_width, len('sponsor_id'))

    participant_id_width = max(len(str(s['participant_id'])) for s in sponsorships)
    participant_id_width = max(participant_id_width, len('participant_id'))

    sponsor_name_width = max(len(str(s['sponsor_name'])) for s in sponsorships)
    sponsor_name_width = max(sponsor_name_width, len('sponsor_name'))

    tribute_name_width = max(len(str(s['tribute_name'])) for s in sponsorships)
    tribute_name_width = max(tribute_name_width, len('tribute_name'))

    game_width = max(len(str(s['game_number'])) for s in sponsorships)
    game_width = max(game_width, len('game_number'))

    amount_width = max(len(f"${s['sponsor_amount']:,.2f}") for s in sponsorships)
    amount_width = max(amount_width, len('sponsor_amount')) + 2

    length = sponsor_id_width + participant_id_width + sponsor_name_width + tribute_name_width + game_width + amount_width + 19
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ SPONSORSHIPS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'sponsor_id':<{sponsor_id_width}} │ {'participant_id':<{participant_id_width}} │ {'sponsor_name':<{sponsor_name_width}} │ {'tribute_name':<{tribute_name_width}} │ {'game_number':<{game_width}} │ {'sponsor_amount':<{amount_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, s in enumerate(sponsorships):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {s['sponsor_id']:<{sponsor_id_width}} │ {s['participant_id']:<{participant_id_width}} │ {s['sponsor_name']:<{sponsor_name_width}} │ {s['tribute_name']:<{tribute_name_width}} │ {s['game_number']:<{game_width}} │ ${s['sponsor_amount']:<{amount_width-1},.2f} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY GAME_CREATORS FULL
def display_game_creators_full(game_creators):
    """Display formatted list of game creators"""
    if not game_creators:
        print("\nNo game creators found.")
        return

    # Calculate column widths
    game_width = max(len(str(gc['game_number'])) for gc in game_creators)
    game_width = max(game_width, len('game_number'))

    gamemaker_id_width = max(len(str(gc['gamemaker_id'])) for gc in game_creators)
    gamemaker_id_width = max(gamemaker_id_width, len('gamemaker_id'))

    name_width = max(len(str(gc['gamemaker_name'])) for gc in game_creators)
    name_width = max(name_width, len('gamemaker_name')) + 5
    
    length = game_width + gamemaker_id_width + name_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAME CREATORS" + " " * (length - 16) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'game_number':<{game_width}} │ {'gamemaker_id':<{gamemaker_id_width}} │ {'gamemaker_name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, gc in enumerate(game_creators):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {gc['game_number']:<{game_width}} │ {gc['gamemaker_id']:<{gamemaker_id_width}} │ {gc['gamemaker_name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY GAME_VICTORS FULL
def display_game_victors_full(game_victors):
    """Display formatted list of game victors"""
    if not game_victors:
        print("\nNo game victors found.")
        return

    # Calculate column widths
    game_width = max(len(str(gv['game_number'])) for gv in game_victors)
    game_width = max(game_width, len('game_number'))

    victor_id_width = max(len(str(gv['victor_id'])) for gv in game_victors)
    victor_id_width = max(victor_id_width, len('victor_id'))

    name_width = max(len(str(gv['tribute_name'])) for gv in game_victors)
    name_width = max(name_width, len('tribute_name')) + 5

    length = game_width + victor_id_width + name_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAME VICTORS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'game_number':<{game_width}} │ {'victor_id':<{victor_id_width}} │ {'tribute_name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, gv in enumerate(game_victors):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {gv['game_number']:<{game_width}} │ {gv['victor_id']:<{victor_id_width}} │ {gv['tribute_name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


# DISPLAY GAMEMAKER_SCORES FULL
def display_gamemaker_scores_full(gamemaker_scores):
    """Display formatted list of gamemaker scores"""
    if not gamemaker_scores:
        print("\nNo gamemaker scores found.")
        return

    # Calculate column widths
    gamemaker_id_width = max(len(str(gs['gamemaker_id'])) for gs in gamemaker_scores)
    gamemaker_id_width = max(gamemaker_id_width, len('gamemaker_id'))

    participant_id_width = max(len(str(gs['participant_id'])) for gs in gamemaker_scores)
    participant_id_width = max(participant_id_width, len('participant_id'))

    gamemaker_name_width = max(len(str(gs['gamemaker_name'])) for gs in gamemaker_scores)
    gamemaker_name_width = max(gamemaker_name_width, len('gamemaker_name'))

    tribute_name_width = max(len(str(gs['tribute_name'])) for gs in gamemaker_scores)
    tribute_name_width = max(tribute_name_width, len('tribute_name'))

    game_width = max(len(str(gs['game_number'])) for gs in gamemaker_scores)
    game_width = max(game_width, len('game_number'))

    score_width = max(len(str(gs['assessment_score'])) for gs in gamemaker_scores)
    score_width = max(score_width, len('assessment_score')) + 5

    length = gamemaker_id_width + participant_id_width + gamemaker_name_width + tribute_name_width + game_width + score_width + 19
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAMEMAKER SCORES" + " " * (length - 19) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'gamemaker_id':<{gamemaker_id_width}} │ {'participant_id':<{participant_id_width}} │ {'gamemaker_name':<{gamemaker_name_width}} │ {'tribute_name':<{tribute_name_width}} │ {'game_number':<{game_width}} │ {'assessment_score':<{score_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, gs in enumerate(gamemaker_scores):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {gs['gamemaker_id']:<{gamemaker_id_width}} │ {gs['participant_id']:<{participant_id_width}} │ {gs['gamemaker_name']:<{gamemaker_name_width}} │ {gs['tribute_name']:<{tribute_name_width}} │ {gs['game_number']:<{game_width}} │ {gs['assessment_score']:<{score_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    if not tributes:
        print("\nNo tributes found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(t['tribute_id'])) for t in tributes)
    id_width = max(id_width, len('ID'))
    
    name_width = max(len(str(t['name'])) for t in tributes)
    name_width = max(name_width, len('Name'))
    
    district_width = max(len(str(t['district'])) for t in tributes)
    district_width = max(district_width, len('District'))
    
    gender_width = max(len('Male'), len('Female'))
    gender_width = max(gender_width, len('Gender'))
    
    dob_width = max(len(str(t['dob'])) for t in tributes)
    dob_width = max(dob_width, len('Birth Date')) + 5
    
    length = id_width + name_width + district_width + gender_width + dob_width + 16
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ TRIBUTES" + " " * (length - 11) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'ID':<{id_width}} │ {'Name':<{name_width}} │ {'District':<{district_width}} │ {'Gender':<{gender_width}} │ {'Birth Date':<{dob_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, tribute in enumerate(tributes):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        gender = "Male" if tribute['gender'] == 'm' else "Female"
        print(f"║ {tribute['tribute_id']:<{id_width}} │ {tribute['name']:<{name_width}} │ {tribute['district']:<{district_width}} │ {gender:<{gender_width}} │ {str(tribute['dob']):<{dob_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    if not sponsors:
        print("\nNo sponsors found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(s['sponsor_id'])) for s in sponsors)
    id_width = max(id_width, len('ID'))
    
    name_width = max(len(str(s['name'])) for s in sponsors)
    name_width = max(name_width, len('Name'))
    
    # Calculate contribution amounts to determine width
    contributions = [ops.get_sponsor_total(connection, s['sponsor_id']) for s in sponsors]
    contrib_width = max(len(f"${c:,.2f}") for c in contributions)
    contrib_width = max(contrib_width, len('Total Contributions')) + 5
    
    length = id_width + name_width + contrib_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ SPONSORS" + " " * (length - 11) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'ID':<{id_width}} │ {'Name':<{name_width}} │ {'Total Contributions':<{contrib_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, sponsor in enumerate(sponsors):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {sponsor['sponsor_id']:<{id_width}} │ {sponsor['name']:<{name_width}} │ ${contributions[i]:<{contrib_width-1},.2f} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


def display_sponsorships(sponsorships):
    """Display formatted list of sponsorships"""
    if not sponsorships:
        print("\nNo sponsorships found.")
        return
    
    # Calculate column widths
    sponsor_id_width = max(len(str(s['sponsor_id'])) for s in sponsorships)
    sponsor_id_width = max(sponsor_id_width, len('Sponsor ID'))
    
    participant_id_width = max(len(str(s['participant_id'])) for s in sponsorships)
    participant_id_width = max(participant_id_width, len('Participant ID'))
    
    sponsor_name_width = max(len(str(s['sponsor_name'])) for s in sponsorships)
    sponsor_name_width = max(sponsor_name_width, len('Sponsor Name'))
    
    tribute_name_width = max(len(str(s['tribute_name'])) for s in sponsorships)
    tribute_name_width = max(tribute_name_width, len('Tribute Name'))
    
    game_width = max(len(str(s['game_number'])) for s in sponsorships)
    game_width = max(game_width, len('Game Number'))
    
    amount_width = max(len(f"${s['sponsor_amount']:,.2f}") for s in sponsorships)
    amount_width = max(amount_width, len('sponsor_amount'))
    
    length = sponsor_id_width + participant_id_width + sponsor_name_width + tribute_name_width + game_width + amount_width + 19
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ SPONSORSHIPS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Sponsor ID':<{sponsor_id_width}} │ {'Participant ID':<{participant_id_width}} │ {'Sponsor Name':<{sponsor_name_width}} │ {'Tribute Name':<{tribute_name_width}} │ {'Game Number':<{game_width}} │ {'Amount':<{amount_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, sponsorship in enumerate(sponsorships):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {sponsorship['sponsor_id']:<{sponsor_id_width}} │ {sponsorship['participant_id']:<{participant_id_width}} │ {sponsorship['sponsor_name']:<{sponsor_name_width}} │ {sponsorship['tribute_name']:<{tribute_name_width}} │ {sponsorship['game_number']:<{game_width}} │ ${sponsorship['sponsor_amount']:<{amount_width-1},.2f} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    if not games:
        print("\nNo games found.")
        return
    
    # Calculate column widths
    game_width = max(len(str(g['game_number'])) for g in games)
    game_width = max(game_width, len('Game Number'))
    
    tribute_count_width = max(len(str(g['tribute_count'])) for g in games)
    tribute_count_width = max(tribute_count_width, len('Number of Tributes'))
    
    start_width = max(len(str(g['start_date'])) for g in games)
    start_width = max(start_width, len('Start Date'))
    
    end_width = max(len(str(g['end_date'])) for g in games)
    end_width = max(end_width, len('End Date'))
    
    status_width = max(len(str(g['game_status'])) for g in games)
    status_width = max(status_width, len('Status'))
    
    victor_width = max(len(str(g['victor_names']) if g['victor_names'] else 'TBD') for g in games)
    victor_width = max(victor_width, len('Victor(s)')) + 5
    
    length = game_width + tribute_count_width + start_width + end_width + status_width + victor_width + 19
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAMES" + " " * (length - 8) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Game Number':<{game_width}} │ {'Number of Tributes':<{tribute_count_width}} │ {'Start Date':<{start_width}} │ {'End Date':<{end_width}} │ {'Status':<{status_width}} │ {'Victor(s)':<{victor_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, game in enumerate(games):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        victors = game['victor_names'] if game['victor_names'] else 'TBD'
        
        status_color = colors.get_status_color(game['game_status'])
        status_text = game['game_status'].title()
        status_display = f"{status_color}{status_text}{Colors.RESET}"
        status_padding = status_width - len(status_text)
        
        print(f"║ {game['game_number']:<{game_width}} │ {game['tribute_count']:<{tribute_count_width}} │ {str(game['start_date']):<{start_width}} │ {str(game['end_date']):<{end_width}} │ {status_display}{' ' * status_padding} │ {victors:<{victor_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")

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
    """Display formatted list of gamemakers"""
    if not gamemakers:
        print("\nNo gamemakers found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(gm['gamemaker_id'])) for gm in gamemakers)
    id_width = max(id_width, len('Gamemaker ID'))
    
    name_width = max(len(str(gm['name'])) for gm in gamemakers)
    name_width = max(name_width, len('Name')) + 5
    
    length = id_width + name_width + 7
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ GAMEMAKERS" + " " * (length - 13) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Gamemaker ID':<{id_width}} │ {'Name':<{name_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, gamemaker in enumerate(gamemakers):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {gamemaker['gamemaker_id']:<{id_width}} │ {gamemaker['name']:<{name_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    if not team_members:
        print("\nNo team members found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(tm['member_id'])) for tm in team_members)
    id_width = max(id_width, len('Member ID'))
    
    name_width = max(len(str(tm['name'])) for tm in team_members)
    name_width = max(name_width, len('Name'))
    
    roles_width = max(len(str(tm['roles']).title() if tm['roles'] else 'TBD') for tm in team_members)
    roles_width = max(roles_width, len('Roles')) + 5
    
    length = id_width + name_width + roles_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ TEAM MEMBERS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Member ID':<{id_width}} │ {'Name':<{name_width}} │ {'Roles':<{roles_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, member in enumerate(team_members):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        roles = member['roles'].title() if member['roles'] else 'TBD'
        print(f"║ {member['member_id']:<{id_width}} │ {member['name']:<{name_width}} │ {roles:<{roles_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


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
    print(" 6: Search Participant by Intelligence Score")
    print(" 7: Search Participant by Likeability Score")
    print("─" * length)
    print(" 0: RETURN")
    print("\n")
    choice = input("Enter choice: ")
    return choice


def display_participants(participants):
    """Display formatted list of participants"""
    if not participants:
        print("\nNo participants found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(p['participant_id'])) for p in participants)
    id_width = max(id_width, len('ID'))
    
    name_width = max(len(str(p['name'])) for p in participants)
    name_width = max(name_width, len('Name'))
    
    district_width = max(len(str(p['district'])) for p in participants)
    district_width = max(district_width, len('District'))
    
    gender_width = max(len('Male'), len('Female'))
    gender_width = max(gender_width, len('Gender'))
    
    game_width = max(len(str(p['game_number'])) for p in participants)
    game_width = max(game_width, len('Game Number'))
    
    age_width = max(len(str(p['age_during_games'])) for p in participants)
    age_width = max(age_width, len('Age During Games'))
    
    training_width = max(len(str(p['training_score'])) for p in participants)
    training_width = max(training_width, len('Training Score'))
    
    intel_width = max(len(str(p['intelligence_score'])) for p in participants)
    intel_width = max(intel_width, len('Intelligence Score'))
    
    like_width = max(len(str(p['likeability_score'])) for p in participants)
    like_width = max(like_width, len('Likeability Score'))
    
    placement_width = max(len(str(p['final_placement'])) for p in participants)
    placement_width = max(placement_width, len('Final Placement')) + 5
    
    length = id_width + name_width + district_width + gender_width + game_width + age_width + training_width + intel_width + like_width + placement_width + 31
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ PARTICIPANTS" + " " * (length - 15) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'ID':<{id_width}} │ {'Name':<{name_width}} │ {'District':<{district_width}} │ {'Gender':<{gender_width}} │ {'Game Number':<{game_width}} │ {'Age During Games':<{age_width}} │ {'Training Score':<{training_width}} │ {'Intelligence Score':<{intel_width}} │ {'Likeability Score':<{like_width}} │ {'Final Placement':<{placement_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, participant in enumerate(participants):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        gender = "Male" if participant['gender'].lower() == 'm' else "Female"
        print(f"║ {participant['participant_id']:<{id_width}} │ {participant['name']:<{name_width}} │ {participant['district']:<{district_width}} │ {gender:<{gender_width}} │ {participant['game_number']:<{game_width}} │ {participant['age_during_games']:<{age_width}} │ {str(participant['training_score']):<{training_width}} │ {str(participant['intelligence_score']):<{intel_width}} │ {str(participant['likeability_score']):<{like_width}} │ {str(participant['final_placement']):<{placement_width}} ║")
        
    print("╚" + "═" * (length - 2) + "╝\n")

# VIEW VICTORS
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
    if not victors:
        print("\nNo victors found.")
        return
    
    # Calculate column widths
    id_width = max(len(str(v['victor_id'])) for v in victors)
    id_width = max(id_width, len('Victor ID'))
    
    name_width = max(len(str(v['name'])) for v in victors)
    name_width = max(name_width, len('Victor Name'))
    
    games_width = max(len(str(v['games_won']) if v['games_won'] else 'TBD') for v in victors)
    games_width = max(games_width, len('Games Won')) + 5
    
    length = id_width + name_width + games_width + 10
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ VICTORS" + " " * (length - 10) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'Victor ID':<{id_width}} │ {'Victor Name':<{name_width}} │ {'Games Won':<{games_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, victor in enumerate(victors):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        games_won = victor['games_won'] if victor['games_won'] else 'TBD'
        print(f"║ {victor['victor_id']:<{id_width}} │ {victor['name']:<{name_width}} │ {games_won:<{games_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")


def display_districts(districts):
    """Display formatted list of districts"""
    if not districts:
        print("\nNo districts found.")
        return
    
    # Calculate column widths
    num_width = max(len(str(d['district_num'])) for d in districts)
    num_width = max(num_width, len('District #'))
    
    industry_width = max(len(str(d['industry'])) for d in districts)
    industry_width = max(industry_width, len('Industry'))
    
    size_width = max(len(str(d['size'])) for d in districts)
    size_width = max(size_width, len('Size'))
    
    wealth_width = max(len(str(d['wealth'])) for d in districts)
    wealth_width = max(wealth_width, len('Wealth')) + 5
    
    length = num_width + industry_width + size_width + wealth_width + 13
        
    print("\n╔" + "═" * (length - 2) + "╗")
    print("║ DISTRICTS" + " " * (length - 12) + "║")
    print("╟" + "─" * (length - 2) + "╢")
    print(f"║ {'District #':<{num_width}} │ {'Industry':<{industry_width}} │ {'Size':<{size_width}} │ {'Wealth':<{wealth_width}} ║")
    print("╠" + "═" * (length - 2) + "╣")
    
    for i, district in enumerate(districts):
        if i > 0:
            print("╟" + "─" * (length - 2) + "╢")
        print(f"║ {district['district_num']:<{num_width}} │ {district['industry']:<{industry_width}} │ {district['size']:<{size_width}} │ {district['wealth']:<{wealth_width}} ║")
    
    print("╚" + "═" * (length - 2) + "╝\n")

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


def get_yes_no_input(prompt):
    """Get Y/N input from user, returns True for Y, False for N"""
    while True:
        response = input(f"{prompt}: ").strip().upper()
        if response in ['Y', 'YES']:
            return True
        elif response in ['N', 'NO']:
            return False
        else:
            print("Please enter Y or N")


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


def get_team_member_inputs(on_update=False):
    if on_update:

        name = get_string_input("Enter the team member's full name or ENTER to skip")
        victor_id = get_number_input("Enter the team member's victor_id or ENTER to skip", True)
    else:
        answer = get_string_input("Was this team member a past victor? (Y/N)")
        name = get_string_input("Enter the team_member's full name", True)
        if answer == 'Y' or answer == 'y':
            victor_id = get_number_input("Enter the team member's victor_id")
        else:
            victor_id = None;
        
    return name, victor_id


def get_participant_inputs(on_update=False):
    if on_update:

        final_placement = get_number_input("Enter the tribute's final placement or ENTER to skip", True)
        intelligence_score = get_number_input("Enter the tribute's intelligence score or ENTER to skip", True)
        likeability_score = get_number_input("Enter the tribute's likeability score or ENTER to skip", True)
         
        return final_placement, intelligence_score, likeability_score
    
    else:
        tribute_id = get_number_input("Enter the participant's tribute_id")
        game_number = get_number_input("Enter the game number")

        return tribute_id, game_number

def get_sponsorship_inputs(on_update=False):
    if on_update:
        sponsor_amount = get_number_input("Enter the new sponsor amount or ENTER to skip", True)
        return sponsor_amount
    else:
        participant_id = get_string_input("Enter the participant ID", True)
        sponsor_id = get_number_input("Enter the sponsor ID")
        sponsor_amount = get_number_input("Enter the sponsor amount")
        return participant_id, sponsor_id, sponsor_amount


def get_team_role_inputs(on_update=False):
    if on_update:
        member_type = get_string_input("Enter the new member type (escort, mentor, stylist, prep) or ENTER to skip")
        return member_type
    else:
        member_id = get_number_input("Enter the member ID")
        participant_id = get_string_input("Enter the participant ID", True)
        member_type = get_string_input("Enter the member type (escort, mentor, stylist, prep)", True)
        return member_id, participant_id, member_type


def get_gamemaker_score_inputs(on_update=False):
    if on_update:
        assessment_score = get_number_input("Enter the new assessment score (1-12) or ENTER to skip", True)
        return assessment_score
    else:
        gamemaker_id = get_number_input("Enter the gamemaker ID")
        participant_id = get_string_input("Enter the participant ID", True)
        assessment_score = get_number_input("Enter the assessment score (1-12)")
        return gamemaker_id, participant_id, assessment_score


def get_game_victor_inputs():
    game_number = get_number_input("Enter the game number")
    victor_id = get_number_input("Enter the victor ID")
    return game_number, victor_id


def get_game_creator_inputs():
    game_number = get_number_input("Enter the game number")
    gamemaker_id = get_number_input("Enter the gamemaker ID")
    return game_number, gamemaker_id






