CREATE TABLE bank(id SERIAL PRIMARY KEY,
                       nazwa varchar(50) NOT NULL);
CREATE TABLE placowka(id SERIAL PRIMARY KEY,
						adres VARCHAR(50),
						NumerTel CHAR(9) UNIQUE,
						bilansGotowki DOUBLE PRECISION,
						bank INTEGER,
						CONSTRAINT fk_bank FOREIGN KEY (bank) REFERENCES bank(id));
CREATE TABLE pracownik(id SERIAL PRIMARY KEY,
						imie VARCHAR(30),
						stanowisko VARCHAR(30),
						pensja DOUBLE PRECISION,
						miejscePracy INTEGER,
						CONSTRAINT fk_miejsce FOREIGN KEY (miejscePracy) REFERENCES placowka(id));
CREATE TABLE klient(id SERIAL PRIMARY KEY,
                       NumerTel CHAR(9),
                       KiedyZostalKlientem DATE,
                       kredyt boolean);
CREATE TABLE konto(id SERIAL PRIMARY KEY,
                       waluta char(3) not NULL,
                       stan DOUBLE PRECISION,
					   klient INTEGER,
					   CONSTRAINT fk_klient FOREIGN KEY (klient) REFERENCES klient(id));
CREATE TABLE karta(id SERIAL PRIMARY KEY,
                       dataWaznosci DATE,
                       numerKarty char(16) NOT NULL UNIQUE,
                       imie varchar(50) NOT NULL,
                       DziennyLimit DOUBLE PRECISION,
					   konto INTEGER,
					   CONSTRAINT fk_konto FOREIGN KEY (konto) REFERENCES konto(id));
CREATE TABLE wizyty(id SERIAL PRIMARY KEY,
						klient INTEGER,
						data DATE,
						prowizja DOUBLE PRECISION,
						ktoObslugiwal INTEGER,
						CONSTRAINT fk_kli FOREIGN KEY (klient) REFERENCES klient(id),
						CONSTRAINT fk_kto FOREIGN KEY (ktoObslugiwal) REFERENCES pracownik(id));
CREATE TABLE transakcja(id SERIAL PRIMARY KEY,
                       suma DOUBLE PRECISION,
                       ZJakiegoKonta INTEGER,
                       NaJakieKonto INTEGER,
					   CONSTRAINT fk_skad FOREIGN KEY (ZJakiegoKonta) REFERENCES konto(id),
					   CONSTRAINT fk_dokad FOREIGN KEY (naJakieKonto) REFERENCES konto(id));
SELECT * FROM placowka;
ALTER TABLE klient ADD imie VARCHAR(20);
INSERT INTO bank(nazwa) VALUES('Millenium'),
                        ('MBank');
INSERT INTO placowka(adres, NumerTel, bilansGotowki, bank) VALUES('Gdansk','123123123',100000000,1),
                            ('Warszawa','123123124',100500000,1),
                            ('Gdansk','321321321',400000000,2);
INSERT INTO pracownik(imie, stanowisko, pensja, miejscePracy) VALUES('Jan', 'Obsluguje klientow',4000,1),
                             ('Krzysztof','Menadzer',8000,1);
INSERT INTO klient(numertel, kiedyzostalklientem, kredyt,imie) VALUES('999999999', '2005-03-24','t','Jan'),
                        ('111222333','2015-12-20','f','Frank'),
                          ('999987999', '2005-03-28','f','Katarzyna');

INSERT INTO konto(waluta, stan, klient) VALUES('PLN',1000.2,1),('USD',20,1),
                         ('PLN',541.2,2);
INSERT INTO karta(dataWaznosci, numerKarty, imie, DziennyLimit, konto)
                        VALUES('2025-08-12','2222000033331675','Janek F',100,1),
                         ('2025-03-01','2222000033121675','Franek N',10,2);
INSERT INTO wizyty(klient, data, prowizja, ktoObslugiwal) VALUES(1,'2020-10-01',5.1,1);
INSERT INTO transakcja(suma, ZJakiegoKonta, NaJakieKonto) VALUES(101.1,1,3);
INSERT INTO klient(numertel, kiedyzostalklientem, kredyt)
VALUES('957234123','2010-09-01','f');
UPDATE klient SET imie = 'Daniel' WHERE id=4;
INSERT INTO konto(waluta, stan, klient)
VALUES('PLN',10000,4);
INSERT INTO klient(numertel, kiedyzostalklientem, kredyt,imie)
VALUES ('900032657','2015-05-23','f','Lord');
INSERT INTO konto(waluta, stan, klient)
VALUES ('USD',13234.2,5);

CREATE VIEW widok AS SELECT k.NumerTel, k.imie, k.kredyt, kk.stan
FROM klient k, konto kk
WHERE (k.id = kk.klient AND kk.waluta = 'PLN' AND kk.stan > 9999)
        OR (k.id = kk.klient AND kk.waluta = 'USD' AND kk.stan > 1999);

SELECT * FROM widok;

DROP VIEW widok;



DROP FUNCTION func();
CREATE OR REPLACE FUNCTION func()
RETURNS trigger AS $trig$
    BEGIN
        UPDATE konto
        SET  stan = stan - new.suma
        WHERE id = new.ZJakiegoKonta AND waluta = 'PLN';
        UPDATE konto
        SET  stan = stan - (new.suma/3.7)
        WHERE id = new.ZJakiegoKonta AND waluta = 'USD';
        UPDATE konto
        SET  stan = stan + new.suma
        WHERE id = new.NaJakieKonto AND waluta = 'PLN';
        UPDATE konto
        SET  stan = (stan + new.suma * 3.7)
        WHERE id = new.NaJakieKonto AND waluta = 'USD';
        RETURN NEW;
    END;
    $trig$
LANGUAGE plpgsql;

CREATE TRIGGER trig
AFTER INSERT
ON transakcja
FOR EACH ROW
EXECUTE PROCEDURE func();

SELECT * FROM konto;

SELECT * FROM klient, konto
WHERE klient.id = konto.klient;

INSERT INTO transakcja(suma, ZJakiegoKonta, NaJakieKonto)
VALUES (100,4,5);

CREATE OR REPLACE FUNCTION fun2( dat date, name char,num char, lim double precision )
RETURNS VOID AS
    $$
    BEGIN
        UPDATE karta
        SET dziennylimit = lim
        WHERE dataWaznosci = dat AND
              imie = name AND
              numerKarty = num;
    END;
    $$
Language plpgsql;

SELECT * FROM karta;
DROP FUNCTION fun2;

SELECT fun2('2025-08-12','Janek F','2222000033331675',10);

DELETE FROM konto where id= 1;
SELECT * FROM konto;
