CREATE TABLE `rookeri` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`kauppa` varchar(100) NOT NULL,
	`item` varchar(100) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `rookeri` (kauppa, item, price) VALUES
	('Kasitavarat','blowpipe',30),
	('Kasitavarat','drill',15)
;