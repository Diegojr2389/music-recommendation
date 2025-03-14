-- USER Table
CREATE TABLE USER (
    U_Name VARCHAR(100) PRIMARY KEY,
    F_Name VARCHAR(50) NOT NULL,
    L_Name VARCHAR(50) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    U_DOB DATE NOT NULL,
    U_Age INT CHECK (U_Age > 0) NOT NULL,
    NumOfPlaylist INT CHECK (NumOfPlaylist > 0) NOT NULL,
    U_Location VARCHAR(50) NOT NULL,
    PreferredGenre VARCHAR(50) NOT NULL
);

-- ARTIST Table
CREATE TABLE ARTIST (
    Artist_ID VARCHAR(100) PRIMARY KEY,
    A_Name VARCHAR(100) NOT NULL,
    A_DOB DATE NOT NULL,
    DebutDate DATE NOT NULL,
    Nationality VARCHAR(50) NOT NULL,
    A_Genre VARCHAR(50) NOT NULL,
    Released_Albums INT NOT NULL
);

-- ALBUM Table
CREATE TABLE ALBUM (
    AlbumName VARCHAR(100),
    Artist_ID VARCHAR(100),
    AL_ReleasedDate DATE NOT NULL,
    Top_Song VARCHAR(100) NOT NULL,
    NumOfSongs INT CHECK (NumOfSongs > 0) NOT NULL,
    AL_Duration INT NOT NULL,
    PRIMARY KEY (AlbumName, Artist_ID),
    FOREIGN KEY (Artist_ID) REFERENCES ARTIST(Artist_ID)
);

-- SONG Table (Modified Streams to BIGINT)
CREATE TABLE SONG (
    Song_ID VARCHAR(100),
    Artist_ID VARCHAR(100),
    SongTitle VARCHAR(255) NOT NULL,
    S_Duration INT NOT NULL,
    S_Genre VARCHAR(50) NOT NULL,
    Mood VARCHAR(50) NOT NULL,
    Tempo INT CHECK (Tempo > 0) NOT NULL,
    S_ReleasedDate DATE NOT NULL,
    Streams BIGINT CHECK (Streams >= 0) NOT NULL, -- Changed to BIGINT
    PRIMARY KEY (Song_ID, Artist_ID),
    FOREIGN KEY (Artist_ID) REFERENCES ARTIST(Artist_ID)
);

-- USER_BEHAVIOR Table
CREATE TABLE USER_BEHAVIOR (
    Behavior_ID VARCHAR(100),
    U_Name VARCHAR(100),
    LikedSongs INT CHECK (LikedSongs >= 0),
    DislikedSongs INT CHECK (DislikedSongs >= 0),
    TotalListeningTime INT NOT NULL,
    Playlist_Interaction_Frequency INT CHECK (Playlist_Interaction_Frequency >= 0),
    PRIMARY KEY (Behavior_ID, U_Name),
    FOREIGN KEY (U_Name) REFERENCES USER(U_Name)
);

-- PLAYLIST Table
CREATE TABLE PLAYLIST (
    PlaylistName VARCHAR(100),
    U_Name VARCHAR(100),
    NumOfSong INT CHECK (NumOfSong >= 0) NOT NULL,
    P_Duration INT NOT NULL,
    Description TEXT,
    PRIMARY KEY (PlaylistName, U_Name),
    FOREIGN KEY (U_Name) REFERENCES USER(U_Name)
);

-- RECOMMENDATION Table
CREATE TABLE RECOMMENDATION (
    Rec_ID VARCHAR(100),
    A_ID VARCHAR(100),
    U_Name VARCHAR(100),
    S_ID VARCHAR(100),
    Artist_ID VARCHAR(100),
    Rec_Date DATE NOT NULL,
    PRIMARY KEY (Rec_ID, U_Name),
    FOREIGN KEY (A_ID) REFERENCES ARTIST(Artist_ID),
    FOREIGN KEY (U_Name) REFERENCES USER(U_Name),
    FOREIGN KEY (S_ID, Artist_ID) REFERENCES SONG(Song_ID, Artist_ID)
);

-- REFERENCE Table (Relationship between RECOMMENDATION and SONG)
CREATE TABLE REFERENCE (
    Rec_ID VARCHAR(100),
    Song_ID VARCHAR(100),
    Artist_ID VARCHAR(100),
    U_Name VARCHAR(100),
    PRIMARY KEY (Rec_ID, Song_ID, Artist_ID, U_Name),
    FOREIGN KEY (Rec_ID, U_Name) REFERENCES RECOMMENDATION(Rec_ID, U_Name),
    FOREIGN KEY (Song_ID, Artist_ID) REFERENCES SONG(Song_ID, Artist_ID),
    FOREIGN KEY (U_Name) REFERENCES USER(U_Name)
);

-- LISTEN Table (Relationship between USER and SONG)
CREATE TABLE LISTEN (
    Song_ID VARCHAR(100),
    Artist_ID VARCHAR(100),
    U_Name VARCHAR(100),
    PRIMARY KEY (Song_ID, Artist_ID, U_Name),
    FOREIGN KEY (Song_ID, Artist_ID) REFERENCES SONG(Song_ID, Artist_ID),
    FOREIGN KEY (U_Name) REFERENCES USER(U_Name)
);

-- PLAYLIST_SONG Table (Relationship between PLAYLIST and SONG)
CREATE TABLE PLAYLIST_SONG (
    PlaylistName VARCHAR(100),
    Song_ID VARCHAR(100),
    Artist_ID VARCHAR(100),
    U_Name VARCHAR(100),
    PRIMARY KEY (PlaylistName, Song_ID, Artist_ID, U_Name),
    FOREIGN KEY (PlaylistName, U_Name) REFERENCES PLAYLIST(PlaylistName, U_Name),
    FOREIGN KEY (Song_ID, Artist_ID) REFERENCES SONG(Song_ID, Artist_ID)
);

-- SONG_ALBUM Table (Relationship between ALBUM and SONG)
CREATE TABLE SONG_ALBUM (
    AlbumName VARCHAR(100),
    Artist_ID VARCHAR(100),
    Song_ID VARCHAR(100),
    PRIMARY KEY (AlbumName, Artist_ID, Song_ID),
    FOREIGN KEY (AlbumName, Artist_ID) REFERENCES ALBUM(AlbumName, Artist_ID),
    FOREIGN KEY (Song_ID, Artist_ID) REFERENCES SONG(Song_ID, Artist_ID)
);

-- Insert into ARTIST Table
INSERT INTO ARTIST (Artist_ID, A_Name, A_DOB, DebutDate, Nationality, A_Genre, Released_Albums)
VALUES
('artist1', 'The Beatles', '1900-01-01', '1960-01-01', 'UK', 'Rock', 13),
('artist2', 'Taylor Swift', '1989-12-13', '2006-10-24', 'USA', 'Pop', 10),
('artist3', 'Eminem', '1972-10-17', '1996-11-12', 'USA', 'Hip-Hop', 11),
('artist4', 'Drake', '1986-10-24', '2009-06-15', 'Canada', 'Hip-Hop', 8),
('artist5', 'Adele', '1988-05-05', '2008-01-28', 'UK', 'Soul', 4),
('artist6', 'Ed Sheeran', '1991-02-17', '2011-09-09', 'UK', 'Pop', 6),
('artist7', 'Beyoncé', '1981-09-04', '1997-10-05', 'USA', 'R&B', 7),
('artist8', 'Kanye West', '1977-06-08', '2004-02-10', 'USA', 'Hip-Hop', 11),
('artist9', 'Bruno Mars', '1985-10-08', '2010-07-20', 'USA', 'Pop', 4),
('artist10', 'Coldplay', '1900-01-01', '1996-01-01', 'UK', 'Alternative', 9),
('artist11', 'The Weeknd', '1990-02-16', '2013-01-01', 'Canada', 'R&B', 5),
('artist12', 'Billie Eilish', '2001-12-18', '2017-11-17', 'USA', 'Alternative', 2),
('artist13', 'Imagine Dragons', '1900-01-01', '2012-09-04', 'USA', 'Alternative', 4),
('artist14', 'Rihanna', '1988-02-20', '2005-05-30', 'Barbados', 'R&B', 8),
('artist15', 'Justin Bieber', '1994-03-01', '2009-11-17', 'Canada', 'Pop', 6),
('artist16', 'Ariana Grande', '1993-06-26', '2013-09-03', 'USA', 'Pop', 6),
('artist17', 'Post Malone', '1995-07-04', '2015-02-04', 'USA', 'Hip-Hop', 4),
('artist18', 'Shawn Mendes', '1998-08-08', '2014-04-14', 'Canada', 'Pop', 4),
('artist19', 'Dua Lipa', '1995-08-22', '2015-08-21', 'UK', 'Pop', 3),
('artist20', 'Harry Styles', '1994-02-01', '2017-05-12', 'UK', 'Pop', 3),
('artist21', 'Lady Gaga', '1986-03-28', '2008-08-19', 'USA', 'Pop', 7),
('artist22', 'Kendrick Lamar', '1987-06-17', '2011-07-02', 'USA', 'Hip-Hop', 5),
('artist23', 'Sabrina Carpenter', '1999-05-11', '2015-04-14', 'USA', 'Pop', 5),
('artist24', 'Chappell Roan', '1998-02-19', '2023-09-22', 'USA', 'Pop', 1),
('artist25', 'Doechii', '1992-10-21', '2018-08-31', 'USA', 'Hip-Hop', 1),
('artist26', 'Katy Perry', '1984-10-25', '2008-06-17', 'USA', 'Pop', 6),
('artist27', 'Nicki Minaj', '1982-12-08', '2010-11-22', 'Trinidad and Tobago', 'Hip-Hop', 5),
('artist28', 'Jay-Z', '1969-12-04', '1996-06-25', 'USA', 'Hip-Hop', 14),
('artist29', 'Alicia Keys', '1981-01-25', '2001-06-05', 'USA', 'R&B', 8),
('artist30', 'Maroon 5', '1900-01-01', '2002-06-25', 'USA', 'Pop', 7),
('artist31', 'SZA', '1989-11-08', '2012-10-29', 'USA', 'R&B', 2),
('artist32', 'Lil Wayne', '1982-09-27', '1999-11-02', 'USA', 'Hip-Hop', 13),
('artist33', 'Miley Cyrus', '1992-11-23', '2007-06-26', 'USA', 'Pop', 7),
('artist34', 'Sam Smith', '1992-05-19', '2014-05-26', 'UK', 'Pop', 4),
('artist35', 'Calvin Harris', '1984-01-17', '2007-06-15', 'UK', 'Electronic', 5),
('artist36', 'Cardi B', '1992-10-11', '2017-06-16', 'USA', 'Hip-Hop', 1),
('artist37', 'Megan Thee Stallion', '1995-02-15', '2019-05-17', 'USA', 'Hip-Hop', 2),
('artist38', 'Lana Del Rey', '1985-06-21', '2012-01-27', 'USA', 'Alternative', 9),
('artist39', 'J. Cole', '1985-01-28', '2011-11-01', 'USA', 'Hip-Hop', 6),
('artist40', 'Olivia Rodrigo', '2003-02-20', '2021-01-08', 'USA', 'Pop', 2),
('artist41', 'Red Hot Chili Peppers', '1900-01-01', '1984-08-10', 'USA', 'Rock', 13),
('artist42', 'Foo Fighters', '1900-01-01', '1995-07-04', 'USA', 'Rock', 11),
('artist43', 'Linkin Park', '1900-01-01', '2000-10-24', 'USA', 'Alternative', 7),
('artist44', 'Green Day', '1900-01-01', '1987-01-01', 'USA', 'Punk Rock', 14),
('artist45', 'Metallica', '1900-01-01', '1983-07-25', 'USA', 'Metal', 10),
('artist46', 'Nirvana', '1900-01-01', '1989-06-15', 'USA', 'Grunge', 3),
('artist47', 'Guns N'' Roses', '1900-01-01', '1987-07-21', 'USA', 'Rock', 6),
('artist48', 'Queen', '1900-01-01', '1973-07-13', 'UK', 'Rock', 15),
('artist49', 'The Rolling Stones', '1900-01-01', '1962-01-01', 'UK', 'Rock', 30),
('artist50', 'Pink Floyd', '1900-01-01', '1967-08-05', 'UK', 'Rock', 15),
('artist51', 'Elton John', '1947-03-25', '1969-10-27', 'UK', 'Pop', 31),
('artist52', 'David Bowie', '1947-01-08', '1967-06-01', 'UK', 'Rock', 27),
('artist53', 'Madonna', '1958-08-16', '1983-07-27', 'USA', 'Pop', 14),
('artist54', 'Michael Jackson', '1958-08-29', '1971-01-07', 'USA', 'Pop', 10),
('artist55', 'Prince', '1958-06-07', '1978-04-07', 'USA', 'Funk', 39),
('artist56', 'Bob Dylan', '1941-05-24', '1962-03-19', 'USA', 'Folk', 39),
('artist57', 'Bruce Springsteen', '1949-09-23', '1973-01-05', 'USA', 'Rock', 21),
('artist58', 'Whitney Houston', '1963-08-09', '1985-02-14', 'USA', 'R&B', 7),
('artist59', 'Mariah Carey', '1969-03-27', '1990-06-12', 'USA', 'R&B', 15),
('artist60', 'Celine Dion', '1968-03-30', '1990-11-09', 'Canada', 'Pop', 27),
('artist61', 'Frank Sinatra', '1915-12-12', '1939-01-01', 'USA', 'Jazz', 59),
('artist62', 'Aretha Franklin', '1942-03-25', '1961-01-10', 'USA', 'Soul', 38),
('artist63', 'Stevie Wonder', '1950-05-13', '1962-11-01', 'USA', 'Soul', 27),
('artist64', 'James Brown', '1933-05-03', '1956-03-01', 'USA', 'Funk', 37),
('artist65', 'Marvin Gaye', '1939-04-02', '1961-06-01', 'USA', 'Soul', 25),
('artist66', 'Tina Turner', '1939-11-26', '1960-01-01', 'USA', 'Rock', 10),
('artist67', 'Diana Ross', '1944-03-26', '1961-01-01', 'USA', 'R&B', 25),
('artist68', 'Patti LaBelle', '1944-05-24', '1962-01-01', 'USA', 'R&B', 20),
('artist69', 'Janet Jackson', '1966-05-16', '1982-09-21', 'USA', 'R&B', 11),
('artist70', 'Usher', '1978-10-14', '1994-08-30', 'USA', 'R&B', 9),
('artist71', 'Chris Brown', '1989-05-05', '2005-11-29', 'USA', 'R&B', 11),
('artist72', 'Ne-Yo', '1979-10-18', '2006-02-28', 'USA', 'R&B', 8),
('artist73', 'Trey Songz', '1984-11-28', '2005-07-26', 'USA', 'R&B', 7),
('artist74', 'John Legend', '1978-12-28', '2004-12-28', 'USA', 'R&B', 8),
('artist75', 'Alicia Keys', '1981-01-25', '2001-06-05', 'USA', 'R&B', 8),
('artist76', 'T-Pain', '1985-09-30', '2005-12-06', 'USA', 'R&B', 6),
('artist77', '50 Cent', '1975-07-06', '2003-02-06', 'USA', 'Hip-Hop', 5),
('artist78', 'Snoop Dogg', '1971-10-20', '1993-11-23', 'USA', 'Hip-Hop', 19),
('artist79', 'Nas', '1973-09-14', '1994-04-19', 'USA', 'Hip-Hop', 14),
('artist80', 'Ice Cube', '1969-06-15', '1990-05-16', 'USA', 'Hip-Hop', 10),
('artist81', 'OutKast', '1900-01-01', '1994-04-26', 'USA', 'Hip-Hop', 6),
('artist82', 'Wu-Tang Clan', '1900-01-01', '1993-11-09', 'USA', 'Hip-Hop', 8),
('artist83', 'A Tribe Called Quest', '1900-01-01', '1990-04-10', 'USA', 'Hip-Hop', 6),
('artist84', 'Run-DMC', '1900-01-01', '1984-03-27', 'USA', 'Hip-Hop', 7),
('artist85', 'Public Enemy', '1900-01-01', '1987-02-10', 'USA', 'Hip-Hop', 15),
('artist86', 'The Notorious B.I.G.', '1972-05-21', '1994-09-13', 'USA', 'Hip-Hop', 2),
('artist87', 'Tupac Shakur', '1971-06-16', '1991-11-12', 'USA', 'Hip-Hop', 7),
('artist88', 'LL Cool J', '1968-01-14', '1985-11-18', 'USA', 'Hip-Hop', 13),
('artist89', 'DMX', '1970-12-18', '1998-05-12', 'USA', 'Hip-Hop', 8),
('artist90', 'Future', '1983-11-20', '2012-04-16', 'USA', 'Hip-Hop', 9),
('artist91', 'Travis Scott', '1991-04-30', '2015-09-04', 'USA', 'Hip-Hop', 4),
('artist92', '21 Savage', '1992-10-22', '2016-07-15', 'UK', 'Hip-Hop', 3),
('artist93', 'Lil Uzi Vert', '1994-07-31', '2015-11-13', 'USA', 'Hip-Hop', 3),
('artist94', 'Young Thug', '1991-08-16', '2014-04-24', 'USA', 'Hip-Hop', 2),
('artist95', 'Gunna', '1993-06-14', '2018-05-11', 'USA', 'Hip-Hop', 3),
('artist96', 'Doja Cat', '1995-10-21', '2018-03-30', 'USA', 'Pop', 4),
('artist97', 'Lizzo', '1988-04-27', '2013-10-15', 'USA', 'Pop', 3),
('artist98', 'Halsey', '1994-09-29', '2015-08-28', 'USA', 'Alternative', 4),
('artist99', 'Tame Impala', '1900-01-01', '2010-05-21', 'Australia', 'Alternative', 4),
('artist100', 'The Killers', '1900-01-01', '2004-06-07', 'USA', 'Alternative', 7);

-- Insert into SONG Table
-- Insert into SONG Table
INSERT INTO SONG (Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams) 
VALUES 
('song1', 'artist1', 'Hey Jude', 431, 'Rock', 'Emotional', 72, '1968-08-26', 521636),
('song2', 'artist2', 'Shake It Off', 219, 'Pop', 'Upbeat', 160, '2014-08-18', 303549),
('song3', 'artist3', 'Lose Yourself', 326, 'Hip-Hop', 'Motivational', 171, '2002-10-28', 10466123),
('song4', 'artist4', 'God’s Plan', 198, 'Hip-Hop', 'Chill', 77, '2018-01-19', 5410814),
('song5', 'artist5', 'Rolling in the Deep', 228, 'Soul', 'Powerful', 105, '2010-11-29', 830109),
('song6', 'artist6', 'Shape of You', 233, 'Pop', 'Romantic', 92, '2017-01-06', 16262709),
('song7', 'artist7', 'Halo', 261, 'R&B', 'Uplifting', 88, '2008-01-20', 10844184),
('song8', 'artist8', 'Stronger', 311, 'Hip-Hop', 'Energetic', 128, '2007-09-10', 1375309),
('song9', 'artist9', 'Uptown Funk', 270, 'Pop', 'Funky', 115, '2014-11-10', 8321451),
('song10', 'artist10', 'Yellow', 269, 'Alternative', 'Melancholy', 77, '2000-06-26', 3596727),
('song11', 'artist11', 'Blinding Lights', 200, 'R&B', 'Energetic', 171, '2019-11-29', 14580737),
('song12', 'artist12', 'Bad Guy', 194, 'Alternative', 'Playful', 135, '2019-03-29', 3617941),
('song13', 'artist13', 'Radioactive', 186, 'Alternative', 'Dark', 135, '2012-10-29', 14179838),
('song14', 'artist14', 'Umbrella', 260, 'R&B', 'Cool', 120, '2007-03-29', 3069826),
('song15', 'artist15', 'Love Yourself', 233, 'Pop', 'Reflective', 100, '2015-11-09', 758963),
('song16', 'artist16', 'Into You', 247, 'Pop', 'Seductive', 110, '2016-05-06', 8664572),
('song17', 'artist17', 'Circles', 215, 'Hip-Hop', 'Relaxing', 120, '2019-08-30', 5755504),
('song18', 'artist18', 'Stitches', 206, 'Pop', 'Heartfelt', 87, '2015-03-17', 7496875),
('song19', 'artist19', 'Don’t Start Now', 183, 'Pop', 'Energetic', 124, '2019-10-31', 4978696),
('song20', 'artist20', 'Watermelon Sugar', 174, 'Pop', 'Summery', 110, '2019-11-16', 6301947),
('song21', 'artist1', 'Let It Be', 243, 'Rock', 'Hopeful', 70, '1970-03-06', 451236),
('song22', 'artist2', 'Love Story', 234, 'Pop', 'Romantic', 120, '2008-09-12', 275491),
('song23', 'artist3', 'Stan', 399, 'Hip-Hop', 'Dark', 80, '2000-11-21', 892341),
('song24', 'artist4', 'Hotline Bling', 264, 'Hip-Hop', 'Smooth', 100, '2015-07-31', 481029),
('song25', 'artist5', 'Someone Like You', 281, 'Soul', 'Sad', 135, '2011-01-24', 720584),
('song26', 'artist6', 'Perfect', 263, 'Pop', 'Romantic', 95, '2017-11-20', 1384502),
('song27', 'artist7', 'Single Ladies', 199, 'R&B', 'Empowering', 144, '2008-10-13', 947632),
('song28', 'artist8', 'Gold Digger', 227, 'Hip-Hop', 'Catchy', 92, '2005-08-08', 1156723),
('song29', 'artist9', 'Treasure', 179, 'Pop', 'Funky', 116, '2013-05-10', 694125),
('song30', 'artist10', 'Viva La Vida', 242, 'Alternative', 'Epic', 138, '2008-05-27', 832147),
('song31', 'artist11', 'Starboy', 231, 'R&B', 'Energetic', 186, '2016-09-22', 1264839),
('song32', 'artist12', 'Everything I Wanted', 248, 'Alternative', 'Melancholy', 120, '2019-11-13', 304571),
('song33', 'artist13', 'Demons', 173, 'Alternative', 'Dark', 90, '2013-02-25', 715892),
('song34', 'artist14', 'Diamonds', 223, 'R&B', 'Uplifting', 92, '2012-11-27', 583920),
('song35', 'artist15', 'Sorry', 201, 'Pop', 'Apologetic', 100, '2015-10-22', 649872),
('song36', 'artist16', 'Thank U, Next', 199, 'Pop', 'Grateful', 120, '2018-11-03', 1123456),
('song37', 'artist17', 'Sunflower', 164, 'Hip-Hop', 'Lighthearted', 100, '2018-10-09', 789123),
('song38', 'artist18', 'Treat You Better', 187, 'Pop', 'Protective', 108, '2016-06-03', 654321),
('song39', 'artist19', 'New Rules', 211, 'Pop', 'Empowering', 116, '2017-07-07', 483920),
('song40', 'artist20', 'Adore You', 201, 'Pop', 'Romantic', 99, '2019-12-06', 571234),
('song41', 'artist1', 'Yesterday', 125, 'Rock', 'Nostalgic', 85, '1965-09-13', 392147),
('song42', 'artist2', 'Blank Space', 223, 'Pop', 'Sassy', 140, '2014-11-10', 298765),
('song43', 'artist3', 'Rap God', 361, 'Hip-Hop', 'Fast', 148, '2013-10-15', 1045892),
('song44', 'artist4', 'One Dance', 173, 'Hip-Hop', 'Danceable', 92, '2016-04-05', 682391),
('song45', 'artist5', 'Make You Feel My Love', 193, 'Soul', 'Tender', 78, '2008-01-27', 503492),
('song46', 'artist6', 'Thinking Out Loud', 285, 'Pop', 'Romantic', 79, '2014-10-20', 1254789),
('song47', 'artist7', 'Crazy in Love', 234, 'R&B', 'Passionate', 99, '2003-05-14', 892341),
('song48', 'artist8', 'Heartless', 217, 'Hip-Hop', 'Emotional', 85, '2008-11-04', 743920),
('song49', 'artist9', '24K Magic', 223, 'Pop', 'Funky', 107, '2016-10-07', 694125),
('song50', 'artist10', 'Clocks', 313, 'Alternative', 'Atmospheric', 130, '2002-03-25', 571234);

-- Insert into ALBUM Table
INSERT INTO ALBUM (AlbumName, Artist_ID, AL_ReleasedDate, Top_Song, NumOfSongs, AL_Duration) 
VALUES 
('Abbey Road', 'artist1', '1969-09-26', 'Come Together', 17, 2800),
('1989', 'artist2', '2014-10-27', 'Shake It Off', 13, 3200),
('The Eminem Show', 'artist3', '2002-05-26', 'Without Me', 20, 4000),
('Scorpion', 'artist4', '2018-06-29', 'God’s Plan', 25, 5400),
('21', 'artist5', '2011-01-24', 'Rolling in the Deep', 11, 2900);

-- Insert into USER Table
INSERT INTO USER (U_Name, F_Name, L_Name, Password, Email, U_DOB, U_Age, NumOfPlaylist, U_Location, PreferredGenre) 
VALUES 
('user1', 'John', 'Doe', 'pass123', 'john.doe@email.com', '1995-06-15', 28, 3, 'New York', 'Rock'),
('user2', 'Emily', 'Clark', 'pass456', 'emily.clark@email.com', '1998-02-20', 26, 2, 'Los Angeles', 'Pop'),
('user3', 'Michael', 'Smith', 'pass789', 'michael.smith@email.com', '1990-11-05', 33, 4, 'Chicago', 'Hip-Hop'),
('user4', 'Sophia', 'Brown', 'pass111', 'sophia.brown@email.com', '2000-07-12', 23, 5, 'Houston', 'R&B'),
('user5', 'Daniel', 'Jones', 'pass222', 'daniel.jones@email.com', '1993-05-25', 31, 3, 'Miami', 'Alternative'),
('user6', 'Olivia', 'Miller', 'pass333', 'olivia.miller@email.com', '1999-08-14', 25, 2, 'Seattle', 'Soul'),
('user7', 'Matthew', 'Wilson', 'pass444', 'matthew.wilson@email.com', '2001-01-30', 23, 1, 'Denver', 'Pop'),
('user8', 'Ava', 'Anderson', 'pass555', 'ava.anderson@email.com', '1997-04-18', 27, 4, 'Boston', 'Rock'),
('user9', 'James', 'Martinez', 'pass666', 'james.martinez@email.com', '1989-12-07', 34, 2, 'Phoenix', 'Hip-Hop'),
('user10', 'Charlotte', 'Harris', 'pass777', 'charlotte.harris@email.com', '1996-09-22', 28, 3, 'San Francisco', 'Pop');

-- Insert into PLAYLIST Table
INSERT INTO PLAYLIST (PlaylistName, U_Name, NumOfSong, P_Duration, Description) 
VALUES 
('Rock Legends', 'user1', 10, 3600, 'Classic rock anthems'),
('Pop Hits', 'user2', 12, 3900, 'The biggest pop songs'),
('Hip-Hop Vibes', 'user3', 15, 4200, 'The best hip-hop tracks'),
('R&B Soul', 'user4', 8, 2900, 'Smooth R&B and soul'),
('Indie Chill', 'user5', 20, 4500, 'Indie and alternative chill vibes'),
('Old School Classics', 'user6', 18, 4300, 'Timeless classics from different eras'),
('90s Nostalgia', 'user7', 14, 4000, 'A throwback to the 90s'),
('Summer Jams', 'user8', 10, 3600, 'Perfect summer playlist'),
('Workout Hype', 'user9', 25, 5000, 'Energetic workout music'),
('Acoustic Love', 'user10', 16, 4100, 'Soft acoustic love songs');

-- Insert into USER_BEHAVIOR Table
INSERT INTO USER_BEHAVIOR (Behavior_ID, U_Name, LikedSongs, DislikedSongs, TotalListeningTime, Playlist_Interaction_Frequency) 
VALUES 
('behavior1', 'user1', 50, 5, 12000, 15),
('behavior2', 'user2', 40, 3, 9800, 12),
('behavior3', 'user3', 60, 8, 13500, 18),
('behavior4', 'user4', 30, 2, 7600, 10),
('behavior5', 'user5', 70, 9, 14500, 20),
('behavior6', 'user6', 55, 4, 11200, 14),
('behavior7', 'user7', 38, 6, 8700, 11),
('behavior8', 'user8', 45, 7, 10200, 13),
('behavior9', 'user9', 80, 10, 16000, 25),
('behavior10', 'user10', 36, 5, 8400, 9);

INSERT INTO ALBUM (AlbumName, Artist_ID, AL_ReleasedDate, Top_Song, NumOfSongs, AL_Duration) VALUES 
('Revolution', 'artist6', '2012-05-10', 'Shape of You', 10, 3000),
('Evolve', 'artist7', '2010-08-15', 'Halo', 12, 3200),
('Infinite', 'artist8', '2011-03-22', 'Stronger', 9, 2800),
('Mirage', 'artist9', '2013-07-11', 'Uptown Funk', 11, 3100),
('Odyssey', 'artist10', '2002-11-05', 'Yellow', 8, 2700),
('Serenity', 'artist11', '2015-04-17', 'Blinding Lights', 14, 3500),
('Eclipse', 'artist12', '2020-01-20', 'Bad Guy', 10, 3000),
('Fusion', 'artist13', '2014-09-09', 'Radioactive', 13, 3600),
('Renaissance', 'artist14', '2008-06-12', 'Umbrella', 12, 3300),
('Horizon', 'artist15', '2016-12-01', 'Love Yourself', 9, 2900),
('Momentum', 'artist16', '2018-03-03', 'Into You', 11, 3100),
('Rebirth', 'artist17', '2017-07-07', 'Circles', 10, 3000),
('Pulse', 'artist18', '2019-05-20', 'Stitches', 12, 3200),
('Vibes', 'artist19', '2020-08-25', 'Don’t Start Now', 9, 2800),
('Echoes', 'artist20', '2021-02-14', 'Watermelon Sugar', 11, 3100);

INSERT INTO USER_BEHAVIOR (Behavior_ID, U_Name, LikedSongs, DislikedSongs, TotalListeningTime, Playlist_Interaction_Frequency) VALUES 
('behavior11', 'user1', 55, 4, 12500, 16),
('behavior12', 'user2', 42, 2, 10000, 14),
('behavior13', 'user3', 65, 7, 14000, 19),
('behavior14', 'user4', 35, 3, 8000, 11),
('behavior15', 'user5', 75, 8, 15000, 21),
('behavior16', 'user6', 60, 5, 11500, 15),
('behavior17', 'user7', 40, 6, 9000, 12),
('behavior18', 'user8', 47, 7, 10500, 13),
('behavior19', 'user9', 85, 9, 16500, 26),
('behavior20', 'user10', 38, 5, 8500, 10);

INSERT INTO PLAYLIST (PlaylistName, U_Name, NumOfSong, P_Duration, Description) VALUES 
('Chill Vibes', 'user1', 8, 3000, 'Relaxing tunes'),
('Workout Mix', 'user2', 15, 4200, 'High energy tracks'),
('Throwback', 'user3', 12, 3600, 'Hits from the past'),
('Indie Gems', 'user4', 10, 3100, 'Best of indie music'),
('Jazz Nights', 'user5', 9, 2900, 'Smooth jazz tunes'),
('Country Roads', 'user6', 11, 3300, 'Country music favorites'),
('Electronic Beats', 'user7', 14, 4000, 'EDM and more'),
('Classical Essentials', 'user8', 7, 2500, 'Timeless classical pieces'),
('Reggae Rhythm', 'user9', 13, 3800, 'Island vibes'),
('Latin Fiesta', 'user10', 10, 3200, 'Hot Latin tracks');

INSERT INTO RECOMMENDATION (Rec_ID, A_ID, U_Name, S_ID, Artist_ID, Rec_Date) VALUES 
('rec1', 'artist1', 'user1', 'song1', 'artist1', '2022-01-10'),
('rec2', 'artist2', 'user2', 'song2', 'artist2', '2022-02-15'),
('rec3', 'artist3', 'user3', 'song3', 'artist3', '2022-03-20'),
('rec4', 'artist4', 'user4', 'song4', 'artist4', '2022-04-25'),
('rec5', 'artist5', 'user5', 'song5', 'artist5', '2022-05-30'),
('rec6', 'artist6', 'user6', 'song6', 'artist6', '2022-06-05'),
('rec7', 'artist7', 'user7', 'song7', 'artist7', '2022-07-10'),
('rec8', 'artist8', 'user8', 'song8', 'artist8', '2022-08-15'),
('rec9', 'artist9', 'user9', 'song9', 'artist9', '2022-09-20'),
('rec10', 'artist10', 'user10', 'song10', 'artist10', '2022-10-25'),
('rec11', 'artist11', 'user1', 'song11', 'artist11', '2022-11-30'),
('rec12', 'artist12', 'user2', 'song12', 'artist12', '2022-12-05'),
('rec13', 'artist13', 'user3', 'song13', 'artist13', '2023-01-10'),
('rec14', 'artist14', 'user4', 'song14', 'artist14', '2023-02-15'),
('rec15', 'artist15', 'user5', 'song15', 'artist15', '2023-03-20'),
('rec16', 'artist16', 'user6', 'song16', 'artist16', '2023-04-25'),
('rec17', 'artist17', 'user7', 'song17', 'artist17', '2023-05-30'),
('rec18', 'artist18', 'user8', 'song18', 'artist18', '2023-06-05'),
('rec19', 'artist19', 'user9', 'song19', 'artist19', '2023-07-10'),
('rec20', 'artist20', 'user10', 'song20', 'artist20', '2023-08-15');

INSERT INTO REFERENCE (Rec_ID, Song_ID, Artist_ID, U_Name) VALUES 
('rec1', 'song1', 'artist1', 'user1'),
('rec2', 'song2', 'artist2', 'user2'),
('rec3', 'song3', 'artist3', 'user3'),
('rec4', 'song4', 'artist4', 'user4'),
('rec5', 'song5', 'artist5', 'user5'),
('rec6', 'song6', 'artist6', 'user6'),
('rec7', 'song7', 'artist7', 'user7'),
('rec8', 'song8', 'artist8', 'user8'),
('rec9', 'song9', 'artist9', 'user9'),
('rec10', 'song10', 'artist10', 'user10'),
('rec11', 'song11', 'artist11', 'user1'),
('rec12', 'song12', 'artist12', 'user2'),
('rec13', 'song13', 'artist13', 'user3'),
('rec14', 'song14', 'artist14', 'user4'),
('rec15', 'song15', 'artist15', 'user5'),
('rec16', 'song16', 'artist16', 'user6'),
('rec17', 'song17', 'artist17', 'user7'),
('rec18', 'song18', 'artist18', 'user8'),
('rec19', 'song19', 'artist19', 'user9'),
('rec20', 'song20', 'artist20', 'user10');

INSERT INTO LISTEN (Song_ID, Artist_ID, U_Name) VALUES
('song1', 'artist1', 'user1'),    -- Listened
('song21', 'artist1', 'user1'),   -- Listened
('song2', 'artist2', 'user2'),    -- Listened
('song22', 'artist2', 'user2'),   -- Listened
('song3', 'artist3', 'user3'),    -- Listened
('song23', 'artist3', 'user3'),   -- Listened
('song4', 'artist4', 'user4'),    -- Listened
('song24', 'artist4', 'user4'),   -- Listened
('song5', 'artist5', 'user5'),    -- Listened
('song25', 'artist5', 'user5'),   -- Listened
('song6', 'artist6', 'user6'),    -- Listened
('song26', 'artist6', 'user6'),   -- Listened
('song7', 'artist7', 'user7'),    -- Listened
('song27', 'artist7', 'user7'),   -- Listened
('song8', 'artist8', 'user8'),    -- Listened
('song28', 'artist8', 'user8'),   -- Listened
('song9', 'artist9', 'user9'),    -- Listened
('song29', 'artist9', 'user9'),   -- Listened
('song10', 'artist10', 'user10'), -- Listened
('song30', 'artist10', 'user10'), -- Listened
('song11', 'artist11', 'user1'),  -- Listened
('song12', 'artist12', 'user2'),  -- Listened
('song13', 'artist13', 'user3'),  -- Listened
('song14', 'artist14', 'user4'),  -- Listened
('song15', 'artist15', 'user5'),  -- Listened
('song16', 'artist16', 'user6'),  -- Listened
('song17', 'artist17', 'user7'),  -- Listened
('song18', 'artist18', 'user8'),  -- Listened
('song19', 'artist19', 'user9'),  -- Listened
('song20', 'artist20', 'user10'); -- Listened

INSERT INTO PLAYLIST_SONG (PlaylistName, Song_ID, Artist_ID, U_Name) VALUES 
('Rock Legends', 'song1', 'artist1', 'user1'),
('Pop Hits', 'song2', 'artist2', 'user2'),
('Hip-Hop Vibes', 'song3', 'artist3', 'user3'),
('R&B Soul', 'song4', 'artist4', 'user4'),
('Indie Chill', 'song5', 'artist5', 'user5'),
('Old School Classics', 'song6', 'artist6', 'user6'),
('90s Nostalgia', 'song7', 'artist7', 'user7'),
('Summer Jams', 'song8', 'artist8', 'user8'),
('Workout Hype', 'song9', 'artist9', 'user9'),
('Acoustic Love', 'song10', 'artist10', 'user10'),
('Chill Vibes', 'song11', 'artist11', 'user1'),
('Workout Mix', 'song12', 'artist12', 'user2'),
('Throwback', 'song13', 'artist13', 'user3'),
('Indie Gems', 'song14', 'artist14', 'user4'),
('Jazz Nights', 'song15', 'artist15', 'user5'),
('Country Roads', 'song16', 'artist16', 'user6'),
('Electronic Beats', 'song17', 'artist17', 'user7'),
('Classical Essentials', 'song18', 'artist18', 'user8'),
('Reggae Rhythm', 'song19', 'artist19', 'user9'),
('Latin Fiesta', 'song20', 'artist20', 'user10');

INSERT INTO SONG_ALBUM (AlbumName, Artist_ID, Song_ID) VALUES
('Abbey Road', 'artist1', 'song21'),
('1989', 'artist2', 'song22'),
('The Eminem Show', 'artist3', 'song23'),
('Scorpion', 'artist4', 'song24'),
('21', 'artist5', 'song25'),
('Revolution', 'artist6', 'song26'),
('Evolve', 'artist7', 'song27'),
('Infinite', 'artist8', 'song28'),
('Mirage', 'artist9', 'song29'),
('Odyssey', 'artist10', 'song30'),
('Serenity', 'artist11', 'song31'),
('Eclipse', 'artist12', 'song32'),
('Fusion', 'artist13', 'song33'),
('Renaissance', 'artist14', 'song34'),
('Horizon', 'artist15', 'song35'),
('Momentum', 'artist16', 'song36'),
('Rebirth', 'artist17', 'song37'),
('Pulse', 'artist18', 'song38'),
('Vibes', 'artist19', 'song39'),
('Echoes', 'artist20', 'song40'),
('Abbey Road', 'artist1', 'song41'),
('1989', 'artist2', 'song42'),
('The Eminem Show', 'artist3', 'song43'),
('Scorpion', 'artist4', 'song44'),
('21', 'artist5', 'song45'),
('Revolution', 'artist6', 'song46'),
('Evolve', 'artist7', 'song47'),
('Infinite', 'artist8', 'song48'),
('Mirage', 'artist9', 'song49'),
('Odyssey', 'artist10', 'song50');