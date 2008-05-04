--
-- Table: team
--
DROP TABLE team CASCADE;
CREATE TABLE team (
  pk1 bigserial NOT NULL,
  token_name character varying(255) NOT NULL,
  display_name character varying(255) NOT NULL,
  PRIMARY KEY (pk1),
  Constraint "unique_token_name" UNIQUE (token_name)
);



--
-- Table: network
--
DROP TABLE network CASCADE;
CREATE TABLE network (
  pk1 bigserial NOT NULL,
  display_name character varying(255) NOT NULL,
  token_name character varying(255) NOT NULL,
  region_pk1 bigint,
  PRIMARY KEY (pk1),
  Constraint "unique_token_name3" UNIQUE (token_name)
);



--
-- Table: link_league_team
--
DROP TABLE link_league_team CASCADE;
CREATE TABLE link_league_team (
  league_pk1 bigint NOT NULL,
  team_pk1 bigint NOT NULL,
  PRIMARY KEY (league_pk1, team_pk1)
);



--
-- Table: game_broadcast
--
DROP TABLE game_broadcast CASCADE;
CREATE TABLE game_broadcast (
  pk1 bigserial NOT NULL,
  game_pk1 bigint NOT NULL,
  network_pk1 bigint NOT NULL,
  start_time timestamp(0) NOT NULL,
  end_time timestamp(0) NOT NULL,
  PRIMARY KEY (pk1)
);



--
-- Table: game
--
DROP TABLE game CASCADE;
CREATE TABLE game (
  pk1 bigserial NOT NULL,
  league_pk1 bigint NOT NULL,
  team_pk1 bigint NOT NULL,
  team_pk2 bigint NOT NULL,
  start_time timestamp(0) NOT NULL,
  end_time timestamp(0) NOT NULL,
  PRIMARY KEY (pk1)
);



--
-- Table: league
--
DROP TABLE league CASCADE;
CREATE TABLE league (
  pk1 bigserial NOT NULL,
  display_name character varying(255) NOT NULL,
  token_name character varying(255) NOT NULL,
  PRIMARY KEY (pk1),
  Constraint "unique_token_name4" UNIQUE (token_name)
);

--
-- Foreign Key Definitions
--

ALTER TABLE link_league_team ADD FOREIGN KEY (league_pk1)
  REFERENCES league (pk1);

ALTER TABLE link_league_team ADD FOREIGN KEY (team_pk1)
  REFERENCES team (pk1);

ALTER TABLE game_broadcast ADD FOREIGN KEY (network_pk1)
  REFERENCES network (pk1) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE game_broadcast ADD FOREIGN KEY (game_pk1)
  REFERENCES game (pk1) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE game ADD FOREIGN KEY (team_pk2)
  REFERENCES team (pk1) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE game ADD FOREIGN KEY (league_pk1)
  REFERENCES league (pk1) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE game ADD FOREIGN KEY (team_pk1)
  REFERENCES team (pk1) ON DELETE CASCADE ON UPDATE CASCADE;
