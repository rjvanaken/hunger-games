import random

# Configuration
GAMES = list(range(16, 34))
DISTRICTS = list(range(1, 13))
CAREER_DISTRICTS = [1, 2, 4]
BASE_YEAR = 18

# Name pools
FIRST_NAMES_M = ["Kai", "Ryker", "Atlas", "Phoenix", "Orion", "Zane", "Jasper", "Flint", 
                  "Stone", "Blade", "Hawk", "Reed", "Cole", "Ash", "Drake", "Fox", "Wolf",
                  "Archer", "Hunter", "Gauge", "Ridge", "Steel", "Storm", "Titan", "Saber",
                  "Flynn", "Knox", "Wyatt", "Colt", "Jett", "Pierce", "Dash", "Blaze"]

FIRST_NAMES_F = ["Luna", "Sage", "Ivy", "Nova", "Ember", "Willow", "Aurora", "Rain",
                  "Star", "River", "Sky", "Meadow", "Crystal", "Flora", "Dawn", "Brook",
                  "Rose", "Pearl", "Ruby", "Jade", "Coral", "Fern", "Echo", "Iris",
                  "Violet", "Hazel", "Scarlett", "Azure", "Sienna", "Autumn", "Summer", "Winter"]

LAST_NAMES = ["Stone", "Rivers", "Woods", "Steel", "Fields", "Waters", "Hills", "Vale",
              "Marsh", "Brook", "Ridge", "Dale", "Thorn", "Reed", "Moss", "Frost",
              "Storm", "Bright", "Swift", "Gray", "Dark", "Sharp", "Strong", "Wild",
              "North", "South", "East", "West", "Forest", "Lake", "Mountain", "Valley"]

TEAM_NAMES = ["Cassia Moonbeam", "Demetrius Glitterstein", "Sparkle McGlimmer", 
              "Fortunato Goldsworth", "Luminara Crystalshine", "Satin Velvetine",
              "Shimmerwick", "Glitz Radiance", "Luxe Prismstone", "Dazzle Brightmore",
              "Opulent Starweaver", "Glimmer Rosegold", "Silk Diamondust", "Jewel Silvercrest",
              "Shimmer Pearlwhite", "Gossamer Cloudspun", "Brocade Lavishmore", "Tinsel Sparksbury",
              "Velvet Goldshine", "Saffron Luxmore", "Crimson Sparkle", "Platinum Dazzle"]

SPONSOR_NAMES = ["Opulence Unlimited", "Capitol Elite Syndicate", "Glimmer & Gold Co.",
                 "Prestige Patrons LLC", "Luxe Life Sponsors", "Diamond District Donors",
                 "Glitz & Glamour Guild", "Sterling Success Society", "Platinum Pride Partners",
                 "Radiant Riches Network"]

GAMEMAKER_NAMES = ["Quinton Glitterbeard", "Seraphina Razzledazzle", "Maximus Spectacle",
                   "Celeste Grandioso", "Titus Bedazzle", "Lavender Prismlight",
                   "Augustus Flambeaux", "Crystalline Magnifico"]

def generate_dob(game_num):
    game_year = BASE_YEAR + game_num
    birth_year = random.randint(game_year - 18, game_year - 12)
    
    if birth_year == game_year - 18:
        month = random.randint(7, 12)
        if month == 7:
            day = random.randint(5, 31)
        elif month in [9, 11]:
            day = random.randint(1, 30)
        elif month in [8, 10, 12]:
            day = random.randint(1, 31)
        else:
            day = random.randint(1, 31)
    elif birth_year == game_year - 12:
        month = random.randint(1, 7)
        if month == 7:
            day = random.randint(1, 4)
        elif month in [4, 6]:
            day = random.randint(1, 30)
        elif month == 2:
            day = random.randint(1, 28)
        else:
            day = random.randint(1, 31)
    else:
        month = random.randint(1, 12)
        if month in [4, 6, 9, 11]:
            day = random.randint(1, 30)
        elif month == 2:
            day = random.randint(1, 28)
        else:
            day = random.randint(1, 31)
    
    return f"{birth_year:04d}-{month:02d}-{day:02d}"

def generate_tribute_name(gender, existing_names):
    first_pool = FIRST_NAMES_M if gender == 'm' else FIRST_NAMES_F
    for _ in range(100):
        first = random.choice(first_pool)
        last = random.choice(LAST_NAMES)
        name = f"{first} {last}"
        if name not in existing_names:
            existing_names.add(name)
            return name
    base_name = f"{random.choice(first_pool)} {random.choice(LAST_NAMES)}"
    counter = 1
    name = f"{base_name} {counter}"
    while name in existing_names:
        counter += 1
        name = f"{base_name} {counter}"
    existing_names.add(name)
    return name

def get_training_score(district):
    if district in CAREER_DISTRICTS:
        return random.choices(range(7, 13), weights=[1, 2, 3, 4, 5, 6])[0]
    else:
        return random.choices(range(3, 11), weights=[1, 2, 3, 4, 3, 2, 1, 1])[0]

def generate_victor_district():
    if random.random() < 0.65:
        return random.choice(CAREER_DISTRICTS)
    else:
        return random.choice([d for d in DISTRICTS if d not in CAREER_DISTRICTS])

def generate_sql_files():
    existing_names = set()
    filename = "hunger_games_data.sql"
    
    with open(filename, 'w') as f:
        f.write("-- ============================\n")
        f.write(f"-- HUNGER GAMES {GAMES[0]}-{GAMES[-1]} DATA\n")
        f.write("-- ============================\n\n")
        
        f.write("-- NEW SPONSORS (IDs 13-22)\n")
        f.write("INSERT INTO sponsor (name) VALUES\n")
        sponsor_lines = [f"('{name}')" for name in SPONSOR_NAMES]
        f.write(",\n".join(sponsor_lines) + ";\n\n")
        
        f.write("-- GAMEMAKERS (IDs 34-41)\n")
        f.write("INSERT INTO gamemaker (name) VALUES\n")
        gm_lines = [f"('{name}')" for name in GAMEMAKER_NAMES]
        f.write(",\n".join(gm_lines) + ";\n\n")
        
        f.write(f"-- TEAM MEMBERS FOR GAMES {GAMES[0]}-{GAMES[-1]}\n")
        f.write("-- 48 per game: 12 mentors + 12 escorts + 12 stylists + 12 prep\n")
        
        team_member_start = 37
        f.write("INSERT INTO team_member (name, victor_id) VALUES\n")
        team_lines = []
        
        for game_idx, game_num in enumerate(GAMES):
            for i in range(48):
                name = random.choice(TEAM_NAMES)
                team_lines.append(f"('{name}', NULL)")
        
        f.write(",\n".join(team_lines) + ";\n\n")
        
        for game_idx, game_num in enumerate(GAMES):
            f.write(f"\n-- ============================================\n")
            f.write(f"-- GAME {game_num} (Year {BASE_YEAR + game_num})\n")
            f.write(f"-- ============================================\n\n")
            
            f.write(f"INSERT INTO game (game_number, required_tribute_count) VALUES ({game_num}, DEFAULT);\n\n")
            
            num_gamemakers = random.randint(2, 3)
            gamemaker_ids = random.sample(range(34, 42), num_gamemakers)
            
            f.write(f"-- Assign gamemakers\n")
            for gm_id in gamemaker_ids:
                f.write(f"INSERT INTO game_creator (gamemaker_id, game_number) VALUES ({gm_id}, {game_num});\n")
            f.write("\n")
            
            f.write(f"-- Game {game_num} Tributes\n")
            game_tributes = []
            
            for district in DISTRICTS:
                for gender in ['m', 'f']:
                    name = generate_tribute_name(gender, existing_names)
                    dob = generate_dob(game_num)
                    game_tributes.append((name, dob, gender, district))
            
            f.write("INSERT INTO tribute (name, dob, gender, district) VALUES\n")
            tribute_lines = []
            for name, dob, gender, district in game_tributes:
                tribute_lines.append(f"('{name}', '{dob}', '{gender}', {district})")
            f.write(",\n".join(tribute_lines) + ";\n\n")
            
            f.write(f"-- Game {game_num} Participants\n")
            for name, dob, gender, district in game_tributes:
                f.write(f"CALL add_participant_by_name('{name}', {game_num});\n")
            f.write("\n")
            
            game_team_start = team_member_start + (game_idx * 48)
            mentor_ids = list(range(game_team_start, game_team_start + 12))
            escort_ids = list(range(game_team_start + 12, game_team_start + 24))
            stylist_ids = list(range(game_team_start + 24, game_team_start + 36))
            prep_ids = list(range(game_team_start + 36, game_team_start + 48))
            
            f.write(f"-- Game {game_num} Team Roles\n")
            for district in DISTRICTS:
                mentor_id = mentor_ids[district - 1]
                escort_id = escort_ids[district - 1]
                male_stylist_id = stylist_ids[district - 1]
                female_stylist_id = stylist_ids[district - 1]
                male_prep_id = prep_ids[district - 1]
                female_prep_id = prep_ids[district - 1]
                
                participant_id = f"{game_num}.{district}.m.1"
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({mentor_id}, '{participant_id}', 'mentor');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({escort_id}, '{participant_id}', 'escort');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({male_stylist_id}, '{participant_id}', 'stylist');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({male_prep_id}, '{participant_id}', 'prep');\n")
                
                participant_id = f"{game_num}.{district}.f.1"
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({mentor_id}, '{participant_id}', 'mentor');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({escort_id}, '{participant_id}', 'escort');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({female_stylist_id}, '{participant_id}', 'stylist');\n")
                f.write(f"INSERT INTO team_role (member_id, participant_id, member_type) VALUES ({female_prep_id}, '{participant_id}', 'prep');\n")
            
            f.write("\n")
            
            f.write(f"-- Game {game_num} Gamemaker Scores\n")
            for district in DISTRICTS:
                for gender in ['m', 'f']:
                    participant_id = f"{game_num}.{district}.{gender}.1"
                    for gm_id in gamemaker_ids:
                        score = get_training_score(district)
                        f.write(f"INSERT INTO gamemaker_score (gamemaker_id, participant_id, assessment_score) VALUES ({gm_id}, '{participant_id}', {score});\n")
            
            f.write("\n")
            
            f.write(f"-- Game {game_num} Sponsorships\n")
            available_sponsors = list(range(8, 23))
            
            for district in DISTRICTS:
                for gender in ['m', 'f']:
                    participant_id = f"{game_num}.{district}.{gender}.1"
                    
                    if random.random() < 0.3:
                        continue
                    
                    rand_val = random.random()
                    if rand_val < 0.4:
                        num_sponsors = 1
                    elif rand_val < 0.7:
                        num_sponsors = 2
                    else:
                        num_sponsors = 3
                    
                    sponsors = random.sample(available_sponsors, min(num_sponsors, len(available_sponsors)))
                    
                    for sponsor_id in sponsors:
                        if district in CAREER_DISTRICTS:
                            amount = random.randint(3000, 9000)
                        else:
                            amount = random.randint(1000, 6000)
                        f.write(f"INSERT INTO sponsorship (sponsor_id, participant_id, sponsor_amount) VALUES ({sponsor_id}, '{participant_id}', {amount});\n")
            
            f.write("\n")
            
            f.write(f"-- Game {game_num} Final Placements\n")
            victor_district = generate_victor_district()
            victor_gender = random.choice(['m', 'f'])
            victor_participant_id = f"{game_num}.{victor_district}.{victor_gender}.1"
            
            placements = list(range(1, 25))
            random.shuffle(placements)
            
            placement_idx = 0
            for district in DISTRICTS:
                for gender in ['m', 'f']:
                    participant_id = f"{game_num}.{district}.{gender}.1"
                    
                    if participant_id == victor_participant_id:
                        placement = 1
                    else:
                        placement = placements[placement_idx]
                        if placement == 1:
                            placement_idx += 1
                            placement = placements[placement_idx]
                        placement_idx += 1
                    
                    f.write(f"CALL edit_participant('{participant_id}', {placement}, NULL, NULL);\n")
            
            f.write("\n")
    
    print(f"Generated {filename}")

if __name__ == "__main__":
    generate_sql_files()
    print("Done! Generated hunger_games_data.sql")