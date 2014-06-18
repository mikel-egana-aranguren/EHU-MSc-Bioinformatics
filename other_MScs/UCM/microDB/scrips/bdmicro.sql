CREATE DATABASE microdb;

CREATE TABLE micro (
	Titulo TEXT ,
	Autores TEXT ,
	Pmid VARCHAR(12) NOT NULL,
	Fecha VARCHAR(50) NOT NULL,
	Isolation_source TEXT ,
	Metadatos TEXT,
	Gen VARCHAR(100) NOT NULL ,
	Secuencia TEXT NOT NULL ,
	UNIQUE(Pmid),
	PRIMARY KEY (Pmid)
);

CREATE TABLE ambiente (
	Pmid VARCHAR(100) NOT NULL,
	ID_ambiente VARCHAR(100),
	Nombre_tipo TEXT ,
	Metadata TEXT ,
	FOREIGN KEY (Pmid) REFERENCES micro(Pmid) ON DELETE CASCADE
);

CREATE TABLE muestra (
	Pmid VARCHAR(100) NOT NULL,
	Titulo TEXT ,
	Autores TEXT ,
	NUM_seq VARCHAR(10),
	ID_muestra VARCHAR(100),
	FOREIGN KEY (Pmid) REFERENCES micro(Pmid) ON DELETE CASCADE
);

CREATE TABLE especies (
	ID_cluster VARCHAR(100),
	Taxon TEXT ,
	NUM_seq VARCHAR(10),
	ID_seq_representante VARCHAR(100),
	PRIMARY KEY (ID_seq_representante),
	FOREIGN KEY (ID_seq_representante) REFERENCES secuencias(Pmid) ON DELETE CASCADE
);

CREATE TABLE Taxones (
	ID_seq_representante VARCHAR(100) NOT NULL,
	superkingdom_besthit TEXT ,
	superkingdom_bestAVG TEXT ,
	superkingdom_ID VARCHAR(8) ,
	phylum_besthit TEXT ,
	phylum_bestAVG TEXT ,
	phylum_ID VARCHAR(8) ,
	class_besthit TEXT ,
	class_bestAVG TEXT ,
	class_ID VARCHAR(8) ,
	orderbesthit TEXT ,
	orderbestAVG TEXT ,
	orderID VARCHAR(8) ,
	family_besthit TEXT ,
	family_bestAVG TEXT ,
	family_ID VARCHAR(8) ,
	genus_besthit TEXT ,
	genus_bestAVG TEXT ,
	genus_ID VARCHAR(8) ,
	species_besthit TEXT ,
	species_bestAVG TEXT ,
	species_ID VARCHAR(8) ,
	FOREIGN KEY (ID_seq_representante) REFERENCES especies(ID_seq_representante) ON DELETE CASCADE
);

CREATE TABLE secuencias (
	ID_cluster VARCHAR(100) NOT NULL,
	Pmid VARCHAR(100) NOT NULL,
	longitud_seq VARCHAR(10),
	secuencia TEXT ,
	FOREIGN KEY (Pmid) REFERENCES micro(Pmid) ON DELETE CASCADE 
);

