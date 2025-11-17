use hunger_games;

-- Insert Districts (1-12)
INSERT INTO district (district_num, industry, size, wealth) VALUES
(1, 'Luxury', 'Medium', 'Wealthy'),
(2, 'Masonry', 'Large', 'Wealthy'),
(3, 'Technology', 'Large', 'Middle Class'),
(4, 'Fishing', 'Medium', 'Wealthy'),
(5, 'Power', 'Small', 'Working Class'),
(6, 'Transportation', 'Large', 'Working Class'),
(7, 'Lumber', 'Medium', 'Working Class'),
(8, 'Textiles', 'Medium', 'Poor'),
(9, 'Grain', 'Medium', 'Working Class'),
(10, 'Livestock', 'Medium', 'Working Class'),
(11, 'Agriculture', 'Large', 'Poor'),
(12, 'Coal Mining', 'Small', 'Poor');

-- Insert tributes
INSERT INTO tribute (name, dob, gender, district) VALUES
('Katniss Everdeen', '0076-05-08', 'f', 12),
('Peeta Mellark', '0076-03-12', 'm', 12),
('Rue', '0080-03-05', 'f', 11),
('Thresh', '0074-01-28', 'm', 11),
('Mags', '0012-02-10', 'f', 4),
('Finnick Odair', '0069-08-17', 'm', 4),
('Annie Cresta', '0069-11-05', 'f', 4),
('Maysilee Donner', '0052-06-20', 'f', 12),
('Haymitch Abernathy', '0052-07-04', 'm', 12),
('Johanna Mason', '0072-10-08', 'f', 7),
('Wiress', '0043-03-22', 'f', 3),
('Beetee Latier', '0045-07-14', 'm', 3),
('Glimmer', '0075-04-19', 'f', 1),
('Marvel', '0075-12-02', 'm', 1),
('Cashmere', '0068-05-30', 'f', 1),
('Gloss', '0066-05-30', 'm', 1),
('Cato', '0074-02-14', 'm', 2),
('Clove', '0077-01-23', 'f', 2),
('Enobaria', '0063-08-08', 'f', 2),
('Brutus', '0050-01-11', 'm', 2),
('Foxface', '0076-09-27', 'f', 5),

('Blight', '0055-03-15', 'm', 7),
('Cecelia', '0061-04-22', 'f', 8),

-- 10th games
('Facet', NULL, 'm', 1),
('Velvereen', NULL, 'f', 1),
('Marcus', '0010-01-08', 'm', 2), -- I am assuming he's Sejanus's age, so 18
('Sabyn', NULL, 'f', 2),
('Circ', NULL, 'm', 3),
('Teslee', NULL, 'f', 3),
('Mizzen', NULL, 'm', 4),
('Coral', NULL, 'f', 4),
('Hy', NULL, 'm', 5),
('Sol', NULL, 'f', 5),
('Otto', NULL, 'm', 6),
('Ginnee', NULL, 'f', 6),
('Treech', NULL, 'm', 7),
('Lamina', NULL, 'f', 7),
('Bobbin', NULL, 'm', 8),
('Wovey', '0016-11-08', 'f', 8),
('Panlo', NULL, 'm', 9),
('Sheaf', NULL, 'f', 9),
('Tanner', NULL, 'm', 10),
('Brandy', NULL, 'f', 10),
('Reaper Ash', '0010-05-05', 'm', 11), -- estimated 18
('Dill', NULL, 'f', 11),
('Jessup Diggs', NULL, 'm', 12), -- assumed 18 bc worked in mines
('Lucy Gray Baird', '0011-03-10', 'f', 12),

('Louella', NULL, 'f', 12),
('Wyatt', NULL, 'm', 12)
;


INSERT INTO team_member (name) VALUES
-- 74th-75th
('Effie Trinket'),
('Juvenia'),
('Cinna'),
('Portia'),
('Octavia'),
('Flavius'),
('Venia'),

-- unsure when but probably 74th and before
('Tigris'),

-- 50th
('Persephone Trinket'),
('Drusilla Sickle'),
('Magno Stift'),

-- 10th games mentors
('Sejanus Plinth'),
('Coriolanus Snow'),
('Lysistrata Vickers'),
('Clemensia Dovecote'),
('Arachne Crane'),
('Festus Creed'),
('Livia Cardew'),
('Pup Harrington'),
('Hilarius Heavensbee'),
('Juno Phipps'),
('Felix Ravinstill'),
('Vispania Sickle'),
('Io Jasper'),
('Androcles Anderson'),
('Gaius Breen'),
('Urban Canville'),
('Dennis Fling'),
('Florus Friend'),
('Palmyra Monty'),
('Iphigenia Moss'),
('Persephone Price'),
('Apollo Ring'),
('Diana Ring');

INSERT INTO gamemaker (name) VALUES

-- 75th games
('Plutarch Heavensbee'),

-- 71-74th games as head gamemaker
('Seneca Crane'),
('Lucia'), -- 74th games working under seneca

-- 1-10th +
('Dr. Volumina Gaul'),

('Random_Gm1'),
('Random_Gm2'),
('Random_Gm3'),

('Coriolanus Snow');


INSERT INTO game (game_number, required_tribute_count) VALUES
(1, DEFAULT),
(10, DEFAULT),
(11, DEFAULT),
(50, 48),
(74, DEFAULT),
(75, DEFAULT)

;

INSERT INTO participant (tribute_id, game_number) VALUES
-- 74th
(1, 74),
(2, 74),
(14, 74),
(13, 74),
(17, 74),
(18, 74),
(21, 74),
(3, 74),
(4, 74),

-- 11th
(5, 11),


-- 75th
(1, 75),
(2, 75),
(5, 75),
(6, 75),
(10, 75),
(11, 75),
(12, 75),
(15, 75),
(16, 75),
(19, 75),
(20, 75),
(22, 75),
(23, 75),

-- 10th
(24, 10),
(25, 10),
(26, 10),
(27, 10),
(28, 10),
(29, 10),
(30, 10),
(31, 10),
(32, 10),
(33, 10),
(34, 10),
(35, 10),
(36, 10),
(37, 10),
(38, 10),
(39, 10),
(40, 10),
(41, 10),
(42, 10),
(43, 10),
(44, 10),
(45, 10),
(46, 10),
(47, 10),

-- 50th
(8, 50),
(9, 50),
(48, 50),
(49, 50)

;

INSERT INTO sponsor (name) VALUES
('Pieceof CapitolHorseShit'),
("Catos's Groupies"),
("Glimmer's GlamSquad"),
("The Four Leaf CLOVErs"),
("Peeta Bread"),
("Capitol Bullshit"),
("Pompous Heavensbee"),
("Creme Brulee"),
("Twinkle Lowbottom"),
("Platinum Periwinkle"),
("Caviar Cardew"),
("Flambee Flickerman")
;











-- INSERT INTO team_role (name) VALUES
-- ('Effie Trinket'),
-- ('Juvenia'),
-- ('Cinna'),
-- ('Portia'),
-- ('Octavia'),
-- ('Flavius'),
-- ('Venia'),

-- -- unsure when but probably 74th and before -- probably started after a few games after 10
-- ('Tigris'),

-- -- 50th
-- ('Persephone Trinket'),
-- ('Drusilla Sickle'),
-- ('Magno Stift'),

-- -- 10th games mentors
-- ('Coriolanus Snow'),

