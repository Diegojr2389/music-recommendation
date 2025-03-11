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
('artist1', 'The Beatles', '1940-10-09', '1960-01-01', 'UK', 'Rock', 13),
('artist2', 'Taylor Swift', '1989-12-13', '2006-10-24', 'USA', 'Pop', 10),
('artist3', 'Eminem', '1972-10-17', '1996-11-12', 'USA', 'Hip-Hop', 11),
('artist4', 'Drake', '1986-10-24', '2009-06-15', 'Canada', 'Hip-Hop', 8),
('artist5', 'Adele', '1988-05-05', '2008-01-28', 'UK', 'Soul', 4),
('artist6', 'Ed Sheeran', '1991-02-17', '2011-09-09', 'UK', 'Pop', 6),
('artist7', 'Beyoncé', '1981-09-04', '1997-10-05', 'USA', 'R&B', 7),
('artist8', 'Kanye West', '1977-06-08', '2004-02-10', 'USA', 'Hip-Hop', 11),
('artist9', 'Bruno Mars', '1985-10-08', '2010-07-20', 'USA', 'Pop', 4),
('artist10', 'Coldplay', '1977-03-02', '1996-01-01', 'UK', 'Alternative', 9),
('artist11', 'The Weeknd', '1990-02-16', '2013-01-01', 'Canada', 'R&B', 5),
('artist12', 'Billie Eilish', '2001-12-18', '2017-11-17', 'USA', 'Alternative', 2),
('artist13', 'Imagine Dragons', '1987-06-15', '2012-09-04', 'USA', 'Alternative', 4),
('artist14', 'Rihanna', '1988-02-20', '2005-05-30', 'Barbados', 'R&B', 8),
('artist15', 'Justin Bieber', '1994-03-01', '2009-11-17', 'Canada', 'Pop', 6),
('artist16', 'Ariana Grande', '1993-06-26', '2013-09-03', 'USA', 'Pop', 6),
('artist17', 'Post Malone', '1995-07-04', '2015-02-04', 'USA', 'Hip-Hop', 4),
('artist18', 'Shawn Mendes', '1998-08-08', '2014-04-14', 'Canada', 'Pop', 4),
('artist19', 'Dua Lipa', '1995-08-22', '2015-08-21', 'UK', 'Pop', 3),
('artist20', 'Harry Styles', '1994-02-01', '2017-05-12', 'UK', 'Pop', 3);

-- Insert into SONG Table
INSERT INTO SONG (Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams) 
VALUES 
('song1', 'artist1', 'Hey Jude', 431, 'Rock', 'Emotional', 72, '1968-08-26', 1500000000),
('song2', 'artist2', 'Shake It Off', 219, 'Pop', 'Upbeat', 160, '2014-08-18', 3500000000),
('song3', 'artist3', 'Lose Yourself', 326, 'Hip-Hop', 'Motivational', 171, '2002-10-28', 2200000000),
('song4', 'artist4', 'God’s Plan', 198, 'Hip-Hop', 'Chill', 77, '2018-01-19', 2000000000),
('song5', 'artist5', 'Rolling in the Deep', 228, 'Soul', 'Powerful', 105, '2010-11-29', 2800000000),
('song6', 'artist6', 'Shape of You', 233, 'Pop', 'Romantic', 92, '2017-01-06', 4500000000),
('song7', 'artist7', 'Halo', 261, 'R&B', 'Uplifting', 88, '2008-01-20', 2300000000),
('song8', 'artist8', 'Stronger', 311, 'Hip-Hop', 'Energetic', 128, '2007-09-10', 1800000000),
('song9', 'artist9', 'Uptown Funk', 270, 'Pop', 'Funky', 115, '2014-11-10', 3700000000),
('song10', 'artist10', 'Yellow', 269, 'Alternative', 'Melancholy', 77, '2000-06-26', 1600000000),
('song11', 'artist11', 'Blinding Lights', 200, 'R&B', 'Energetic', 171, '2019-11-29', 4200000000),
('song12', 'artist12', 'Bad Guy', 194, 'Alternative', 'Playful', 135, '2019-03-29', 3400000000),
('song13', 'artist13', 'Radioactive', 186, 'Alternative', 'Dark', 135, '2012-10-29', 1900000000),
('song14', 'artist14', 'Umbrella', 260, 'R&B', 'Cool', 120, '2007-03-29', 3200000000),
('song15', 'artist15', 'Love Yourself', 233, 'Pop', 'Reflective', 100, '2015-11-09', 2400000000),
('song16', 'artist16', 'Into You', 247, 'Pop', 'Seductive', 110, '2016-05-06', 1900000000),
('song17', 'artist17', 'Circles', 215, 'Hip-Hop', 'Relaxing', 120, '2019-08-30', 2200000000),
('song18', 'artist18', 'Stitches', 206, 'Pop', 'Heartfelt', 87, '2015-03-17', 1800000000),
('song19', 'artist19', 'Don’t Start Now', 183, 'Pop', 'Energetic', 124, '2019-10-31', 2900000000),
('song20', 'artist20', 'Watermelon Sugar', 174, 'Pop', 'Summery', 110, '2019-11-16', 2600000000);

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
('song1', 'artist1', 'user1'),
('song2', 'artist2', 'user2'),
('song3', 'artist3', 'user3'),
('song4', 'artist4', 'user4'),
('song5', 'artist5', 'user5'),
('song6', 'artist6', 'user6'),
('song7', 'artist7', 'user7'),
('song8', 'artist8', 'user8'),
('song9', 'artist9', 'user9'),
('song10', 'artist10', 'user10'),
('song11', 'artist11', 'user1'),
('song12', 'artist12', 'user2'),
('song13', 'artist13', 'user3'),
('song14', 'artist14', 'user4'),
('song15', 'artist15', 'user5'),
('song16', 'artist16', 'user6'),
('song17', 'artist17', 'user7'),
('song18', 'artist18', 'user8'),
('song19', 'artist19', 'user9'),
('song20', 'artist20', 'user10');

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
('Abbey Road', 'artist1', 'song1'),
('1989', 'artist2', 'song2'),
('The Eminem Show', 'artist3', 'song3'),
('Scorpion', 'artist4', 'song4'),
('21', 'artist5', 'song5'),
('Revolution', 'artist6', 'song6'),
('Evolve', 'artist7', 'song7'),
('Infinite', 'artist8', 'song8'),
('Mirage', 'artist9', 'song9'),
('Odyssey', 'artist10', 'song10'),
('Serenity', 'artist11', 'song11'),
('Eclipse', 'artist12', 'song12'),
('Fusion', 'artist13', 'song13'),
('Renaissance', 'artist14', 'song14'),
('Horizon', 'artist15', 'song15'),
('Momentum', 'artist16', 'song16'),
('Rebirth', 'artist17', 'song17'),
('Pulse', 'artist18', 'song18'),
('Vibes', 'artist19', 'song19'),
('Echoes', 'artist20', 'song20');