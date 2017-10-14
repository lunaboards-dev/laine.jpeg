CREATE DATABASE `{{dbname}}` DEFAULT CHARSET=utf8 COLLATE utf8_bin;
USE {{dbname}};
CREATE TABLE posts (
	`postid` BIGINT(33) UNSIGNED NOT NULL AUTO_INCREMENT,
	`date` BIGINT(33) UNSIGNED NOT NULL,
	`board` TEXT CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	`id` BIGINT(33) UNSIGNED NOT NULL,
	`ip` TEXT NOT NULL,
	`post` TEXT NOT NULL,
	`admin` TEXT NOT NULL,
	`hasimg` BOOLEAN NOT NULL,
	`img` TEXT NOT NULL,
	PRIMARY KEY (`postid`)
) ENGINE = InnoDB;
CREATE TABLE threads (
	`board` TEXT CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	`name` INT NOT NULL,
	`id` BIGINT(33) NOT NULL,
	`ip` TEXT CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
	`lastupdate` BIGINT(33) NOT NULL,
	`locked` BOOLEAN NOT NULL,
	`pinned` BOOLEAN NOT NULL,
	`marked` BOOLEAN NOT NULL
) ENGINE = InnoDB;
CREATE TABLE admins (
	name text NOT NULL,
	perm text NOT NULL,
	phash text NOT NULL,
	boardperm text NOT NULL,
	k text NOT NULL
) ENGINE = InnoDB;
GRANT ALL PRIVILEGES ON {{dbname}}.* TO '{{user}}'@'%' IDENTIFIED BY '{{pass}}';
