-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Jan  3 10:48:43 2008
-- 
BEGIN TRANSACTION;


--
-- Table: team
--
DROP TABLE team;
CREATE TABLE team (
  pk1 INTEGER PRIMARY KEY NOT NULL,
  token_name varchar(255) NOT NULL,
  display_name varchar(255) NOT NULL
);

CREATE UNIQUE INDEX unique_token_name_team on team (token_name);

--
-- Table: network
--
DROP TABLE network;
CREATE TABLE network (
  pk1 INTEGER PRIMARY KEY NOT NULL,
  display_name varchar(255) NOT NULL,
  token_name varchar(255) NOT NULL,
  region_pk1 integer(16)
);

CREATE UNIQUE INDEX unique_token_name_network on network (token_name);

--
-- Table: link_league_team
--
DROP TABLE link_league_team;
CREATE TABLE link_league_team (
  league_pk1 integer(16) NOT NULL,
  team_pk1 integer(16) NOT NULL,
  PRIMARY KEY (league_pk1, team_pk1)
);


--
-- Table: game_broadcast
--
DROP TABLE game_broadcast;
CREATE TABLE game_broadcast (
  pk1 INTEGER PRIMARY KEY NOT NULL,
  game_pk1 integer(16) NOT NULL,
  network_pk1 integer(16) NOT NULL,
  start_time datetime NOT NULL,
  end_time datetime NOT NULL
);


--
-- Table: game
--
DROP TABLE game;
CREATE TABLE game (
  pk1 INTEGER PRIMARY KEY NOT NULL,
  league_pk1 integer(16) NOT NULL,
  team_pk1 integer(16) NOT NULL,
  team_pk2 integer(16) NOT NULL,
  start_time datetime NOT NULL,
  end_time datetime NOT NULL
);


--
-- Table: league
--
DROP TABLE league;
CREATE TABLE league (
  pk1 INTEGER PRIMARY KEY NOT NULL,
  display_name varchar(255) NOT NULL,
  token_name varchar(255) NOT NULL
);

CREATE UNIQUE INDEX unique_token_name_league on league (token_name);

COMMIT;
