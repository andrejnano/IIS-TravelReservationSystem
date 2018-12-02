-- =================================================================
-- Name: IDS Projekt - SQL
-- Description: School Database Systems project, SQL for Oracle 12c 
-- Authors: Andrej Nano (xnanoa00)
--          Peter Marko (xmarko15)
-- Repository: https://github.com/andrejnano/IDS-projekt
-- =================================================================

/*
    Zadanie projektu:
    https://www.fit.vutbr.cz/study/courses/IDS/private/projekt.xhtml

    SQL Style Guide:
    http://www.sqlstyle.guide/

    Regexes (AvReg: The Aviation RegEx Match Toolkit)
    https://gist.github.com/yectep/4372d1166a192d5e9754
*/

-- =================================================================
-- [X] [1/5] ERD + USE CASE
-- =================================================================
    -- NO SCRIPT PDF odovzdane


-- =================================================================
-- [X] [2/5] SQL skript pro vytvoření základních objektů schématu
-- =================================================================

/*
    __SUMMARY__
    
    TABLES: 
      airlines
      airplanes
      airports
      flights
      customers
      passengers
      reservations
      tickets
      search_records
      
    RULES:
      - customers make reservations
      - reservations contain many tickets
      - each ticket is for 1 flight and 1 passenger
      - each flight has 1 airplane assigned
        & is issued by 1 airline
      - there may be multiple tickets for the same passenger and for the same flight
      - each ticket has seat
*/

/* DELETE TABLES for CLEAN START */

-- example of function
    
-- DELIMITER //

-- CREATE FUNCTION IncomeLevel ( monthly_value INT )
-- RETURNS varchar(20)

-- BEGIN
--     DECLARE income_level varchar(20);
--     SET income_level = 'AAA';


--   IF monthly_value <= 4000 THEN
--       SET income_level = 'Low Income';

--   ELSEIF monthly_value > 4000 AND monthly_value <= 7000 THEN
--       SET income_level = 'Avg Income';

--   ELSE
--       SET income_level = 'High Income';

--   END IF;

--   RETURN income_level;

-- END; //


-- DELIMITER ;

ALTER DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


  SET FOREIGN_KEY_CHECKS=0;
  DROP TABLE IF EXISTS users;
  DROP TABLE IF EXISTS reservations;
  DROP TABLE IF EXISTS tickets;
  DROP TABLE IF EXISTS flights;
  DROP TABLE IF EXISTS airplanes;
  DROP TABLE IF EXISTS airports;
  DROP TABLE IF EXISTS airlines;
  DROP TABLE IF EXISTS passengers;
  DROP TABLE IF EXISTS search_records;
  DROP TABLE IF EXISTS my_start;
  SET FOREIGN_KEY_CHECKS=1;

/* CREATE ALL TABLES */

  /* AVIATION MODEL */

  CREATE TABLE airports (
    /* Airport code in official IATA format; Example: JFK */
    airport_code    VARCHAR(3) NOT NULL PRIMARY KEY,
    city            VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL
  );


DROP TRIGGER IF EXISTS airports_trig;

DELIMITER $$

    CREATE TRIGGER airports_trig BEFORE INSERT ON airports
    FOR EACH ROW BEGIN
      IF (NOT NEW.airport_code REGEXP '[A-Z]{3}') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at airport insertion, expected regex [A-Z]{3}';
      END IF;
    END$$

DELIMITER ;

  CREATE TABLE airlines (
    /* Airline code in official IATA format; Example: CX */
    airline    VARCHAR(2) NOT NULL PRIMARY KEY,
    id_logo         VARCHAR(3),
    full_name       VARCHAR(100) NOT NULL,
    nationality     VARCHAR(100) NOT NULL,
    hub             VARCHAR(3),
    
    CONSTRAINT airline_hub_airport_fk FOREIGN KEY (hub) REFERENCES airports(airport_code)
  );

DROP TRIGGER IF EXISTS arlines_trig;

DELIMITER $$

    CREATE TRIGGER airlines_trig BEFORE INSERT ON airlines
    FOR EACH ROW BEGIN
      IF (NOT NEW.airline REGEXP '[A-Z0-9]{2}') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at airline insertion, expected regex [A-Z0-9]{2}';
      END IF;
    END$$

DELIMITER ;

  CREATE TABLE airplanes (
    id                INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    producer          VARCHAR(100),
    model             VARCHAR(100),
    fclass_seats      INT NOT NULL,  -- first class = 1.
    bclass_seats      INT NOT NULL,  -- business class = 2.
    eclass_seats      INT NOT NULL,  -- economy class = 3.
    airline           VARCHAR(2),

    CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(airline)
  );

/* Reservation system */
  CREATE TABLE flights (
    /* Flight Number in IATA official format; Example: BA026 */
    id                INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    flight_number     VARCHAR(6) NOT NULL,
    departure_time    DATETIME NOT NULL,
    arrival_time      DATETIME NOT NULL,
    airplane          INT,
    airline           VARCHAR(2) NOT NULL,
    origin            VARCHAR(3) NOT NULL,
    destination       VARCHAR(3) NOT NULL,
    fclass_seats_free INT,
    constraint fclass_uint_seats check (fclass_seats_free >= 0),
    bclass_seats_free INT,
    constraint bclass_uint_seats check (bclass_seats_free >= 0),
    eclass_seats_free INT,
    constraint eclass_uint_seats check (eclass_seats_free >= 0),

    CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(id),
    CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(airline),
    CONSTRAINT flight_origin_airport_fk       FOREIGN KEY (origin)      REFERENCES airports(airport_code),
    CONSTRAINT flight_destination_airport_fk  FOREIGN KEY (destination) REFERENCES airports(airport_code)
  );

  
  CREATE TABLE my_start (
    id INT NOT NULL PRIMARY KEY
  );

  INSERT INTO my_start (id) VALUES (1001);

  DROP TRIGGER IF EXISTS flights_trig;
  
  DELIMITER $$
      CREATE TRIGGER flights_trig BEFORE INSERT ON flights
      FOR EACH ROW BEGIN
        SET NEW.flight_number = concat(
              'AA',
              CAST(( SELECT id FROM my_start) AS CHAR(4))
             );
        IF (NOT NEW.flight_number REGEXP '[0-9a-zA-Z]{2}[0-9]{4}') THEN
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at flight insertion, expected regex [0-9a-zA-Z]{2}[0-9]{4}';
        END IF;

        SET @old_my_start := (SELECT id FROM my_start);
        UPDATE my_start
        SET id = @old_my_start + 1;

        SET NEW.fclass_seats_free =
        (SELECT fclass_seats
        FROM airplanes
        WHERE airplanes.id = NEW.airplane)
        ;
        SET NEW.fclass_seats_free = FLOOR(RAND() * NEW.fclass_seats_free / 2);

        SET NEW.bclass_seats_free =
        (SELECT bclass_seats
        FROM airplanes
        WHERE airplanes.id = NEW.airplane)
        ;
        SET NEW.bclass_seats_free = FLOOR(RAND() * NEW.bclass_seats_free / 2);
        
        SET NEW.eclass_seats_free =
        (SELECT eclass_seats
        FROM airplanes
        WHERE airplanes.id = NEW.airplane)
        ;
        SET NEW.eclass_seats_free = FLOOR(RAND() * NEW.eclass_seats_free / 2);
      END$$

  DELIMITER ;


  CREATE TABLE users (
    id               INT PRIMARY KEY AUTO_INCREMENT,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL,
    password         VARCHAR(100) NOT NULL,
    is_admin         INT DEFAULT 0 -- 0 == not admin, 1 == admin
    -- addr_street      VARCHAR(100) NOT NULL,
    -- addr_town        VARCHAR(100) NOT NULL,
    -- addr_post_code   INT NOT NULL,
    -- addr_state       VARCHAR(100) NOT NULL
  );

  CREATE TABLE reservations (
    id              INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    payment_status  INT NOT NULL CHECK(payment_status = 0 or payment_status = 1), -- true or false
    created_at      DATETIME NOT NULL,
    created_by      INT,

    CONSTRAINT reservation_creator_fk FOREIGN KEY (created_by) REFERENCES users(id)
  );

  CREATE TABLE tickets (
    /* Flight Ticket number ; Example : 160-4837291830 */
    -- id   VARCHAR(14) NOT NULL PRIMARY KEY REGEXP_LIKE '[0-9]{3}(-)?[0-9]{10}', /* todo triiger */
    id              INT PRIMARY KEY AUTO_INCREMENT,
    cost            INT NOT NULL,
    email           VARCHAR(100),
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    reservation     INT,
    flight          VARCHAR(6) NOT NULL,
    seat_number     INT NOT NULL,
    seat_class      VARCHAR(1),
    created_at      TIMESTAMP NOT NULL,

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id)
  );

  -- DROP TRIGGER IF EXISTS tickets_trig;
  -- DELIMITER $$

  --     CREATE TRIGGER tickets_trig BEFORE INSERT ON tickets
  --     FOR EACH ROW BEGIN
  --       IF (NOT NEW.seat_number REGEXP '[0-9][0-9][A-K]' OR NOT NEW.seat_class REGEXP '(F|B|E)') THEN
  --             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at ticket insertion, expected regex  seat_number [0-9][0-9][A-K] and seat_class regex (F|B|E)';
  --       END IF;
  --     END$$

  DELIMITER ;

  -- CREATE TABLE search_records (
  --   id        INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  --   customer  INT NOT NULL,
  --   flight    VARCHAR(6) NOT NULL,

  --   CONSTRAINT searched_by_customer_fk  FOREIGN KEY (customer)  REFERENCES users(id),
  --   CONSTRAINT searched_for_flight_fk   FOREIGN KEY (flight)    REFERENCES flights(flight_number)
  -- );

DROP TRIGGER IF EXISTS tickets_trig;
DELIMITER $$
CREATE TRIGGER tickets_trig BEFORE INSERT ON tickets
    FOR EACH ROW BEGIN
      IF (NEW.seat_class = 'F') THEN
        UPDATE flights
        SET fclass_seats_free = fclass_seats_free - 1
        WHERE flights.flight_number = NEW.flight;
        SET NEW.seat_number = 
          (SELECT fclass_seats_free
          FROM flights
          WHERE flights.flight_number = NEW.flight);
        END IF;
      IF (NEW.seat_class = 'B') THEN
        UPDATE flights
        SET bclass_seats_free = bclass_seats_free - 1
        WHERE flights.flight_number = NEW.flight;
        SET NEW.seat_number = 
          (SELECT bclass_seats_free
          FROM flights
          WHERE flights.flight_number = NEW.flight);
        END IF;
      IF (NEW.seat_class = 'E') THEN
        UPDATE flights
        SET eclass_seats_free = eclass_seats_free - 1
        WHERE flights.flight_number = NEW.flight;
        SET NEW.seat_number = 
          (SELECT eclass_seats_free
          FROM flights
          WHERE flights.flight_number = NEW.flight);
        END IF;
    END$$ 

DELIMITER ;


DROP TRIGGER IF EXISTS tickets_trig_del;
DELIMITER $$
CREATE TRIGGER tickets_trig_del BEFORE DELETE ON tickets
    FOR EACH ROW BEGIN
      IF (OLD.seat_class = 'F') THEN
        UPDATE flights
        SET fclass_seats_free = fclass_seats_free + 1
        WHERE flights.flight_number = OLD.flight;
      END IF;
      IF (OLD.seat_class = 'B') THEN
        UPDATE flights
        SET fclass_seats_free = bclass_seats_free + 1
        WHERE flights.flight_number = OLD.flight;
      END IF;
      IF (OLD.seat_class = 'E') THEN
        UPDATE flights
        SET fclass_seats_free = eclass_seats_free + 1
        WHERE flights.flight_number = OLD.flight;
      END IF;
    END$$ 

DELIMITER ;

/* ---------------------
  INSERT SAMPLE DATA 
---------------------- */

INSERT INTO airports (airport_code, city, country)
VALUES ('FRA', 'Frankfurt', 'Germany');

INSERT INTO airports (airport_code, city, country)
VALUES ('CDG', 'Paris', 'France');

INSERT INTO airports (airport_code, city, country)
VALUES ('IST', 'Istanbul', 'Turkey');

INSERT INTO airports (airport_code, city, country)
VALUES ('LHR', 'London', 'United Kingdom');

INSERT INTO airports (airport_code, city, country)
VALUES ('LGW', 'London', 'United Kingdom');

INSERT INTO airports (airport_code, city, country)
VALUES ('DXB', 'Dubai', 'United Arab Emirates');

INSERT INTO airports (airport_code, city, country)
VALUES ('DFW', 'Dallas', 'USA');

INSERT INTO airports (airport_code, city, country)
VALUES ('TXL', 'Berlin', 'Germany');

INSERT INTO airports (airport_code, city, country)
VALUES ('JFK', 'New York', 'USA');

INSERT INTO airports (airport_code, city, country)
VALUES ('KUL', 'Kuala Lumpur', 'Malaysia');

INSERT INTO airports (airport_code, city, country)
VALUES ('PEK', 'Beijing', 'China');

INSERT INTO airports (airport_code, city, country)
VALUES ('HEL', 'Helsinki', 'Finland');

INSERT INTO airports (airport_code, city, country)
VALUES ('VIE', 'Vienna', 'Austria');

INSERT INTO airports (airport_code, city, country)
VALUES ('BTS', 'Bratislava', 'Slovakia');

INSERT INTO airports (airport_code, city, country)
VALUES ('BRQ', 'Brno', 'Czech Republic');

INSERT INTO airports (airport_code, city, country)
VALUES ('PRG', 'Prague', 'Czech Republic');

INSERT INTO airports (airport_code, city, country)
VALUES ('RME', 'Rome', 'Italy');

INSERT INTO airports (airport_code, city, country)
VALUES ('MOW', 'Moscow', 'Russia');

INSERT INTO airports (airport_code, city, country)
VALUES ('BUD', 'Budapest', 'Hungary');

INSERT INTO airports (airport_code, city, country)
VALUES ('BRU', 'Brussels', 'Belgium');

INSERT INTO airports (airport_code, city, country)
VALUES ('LYS', 'Lyon', 'France');


INSERT INTO airports (airport_code, city, country)
VALUES ('MAD', 'Madrid', 'Spain');

INSERT INTO airports (airport_code, city, country)
VALUES ('MCN', 'Barcelona', 'Spain');

INSERT INTO airports (airport_code, city, country)
VALUES ('BZG', 'Warsaw', 'Poland');

INSERT INTO airports (airport_code, city, country)
VALUES ('CFN', 'Dublin', 'Ireland');



-- info from wikipedia ; list of airlines
INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('AA', 'American Airlines', 'USA', 'DFW', 'AAL');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('LH', 'Lufthansa', 'Germany', 'FRA', 'CLH');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('AF', 'Air France', 'France', 'CDG', 'AFR');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('BA', 'British Airways', 'United Kingdom ', 'LHR', 'BAW');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('TK', 'Turkish Airlines', 'Turkey', 'IST', 'LTU');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('EK', 'Emirates', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('FZ', 'flydubai', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('AY', 'Finnair Oyj', 'Finland', 'HEL', 'FIN');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('OS', 'Austrian', 'Austria', 'VIE', 'AUA');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('FR', 'Ryanair', 'Ireland', 'CFN', 'RYR');

INSERT INTO airlines (airline, full_name, nationality, hub, id_logo)
VALUES ('MH', 'Malaysia Airlines', 'Malaysia', 'KUL', 'MAS');


-- info from: https://seatguru.com/
-- TODO: pridat autoincrement na ID alebo pridat priamo ID 
INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A380-800', '14', '76', '399', 'EK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '777-300ER', '8', '42', '304', 'EK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '40', '147', 'AF');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '20', '224', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '28', '160', 'AY');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '28', '160', 'AA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '747-400', '14', '86', '145', 'BA');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-200', '0', '22', '228', 'TK');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A330-300', '8', '42', '145', 'LH');


INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Tupolev', 'Tu-154', '0', '0', '160', 'MH');


INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '737-400', '0', '62', '200', 'FR');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '767-300', '0', '36', '176', 'OS');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Airbus', 'A220-300', '0', '0', '165', 'FZ');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('McDonnell Douglas', 'MD-80', '0', '60', '110', 'MH');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Boeing', '777-200', '0', '42', '150', 'MH');

INSERT INTO airplanes (producer, model, fclass_seats, bclass_seats, eclass_seats, airline)
VALUES ('Bombardier', 'Q200', '0', '24', '50', 'BA');



-- generator used: https://names.igopaygo.com/people/fake-person
INSERT INTO users (first_name, last_name, email, password)
VALUES ('Chahaya', 'Miles', 'ch.mile@egl-inc.info', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password)
VALUES ('Ifor', 'Smoak', 'iforsmoa@diaperstack.com', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password)
VALUES ('Zelda', 'Reel', 'zelda.reel@autozone-inc.info', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password)
VALUES ('Sherwin', 'Hsu', 'sherwinhsu@diaperstack.com', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password)
VALUES ('Teódor', 'Ladislav', 'teodorL@gmail.com', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password)
VALUES ('a', 'a', 'a@a.a', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa');

INSERT INTO users (first_name, last_name, email, password, is_admin)
VALUES ('Ad', 'Min', 'a@d.min', '$2y$10$jXm7tEPX3m1YRWkcQDtzz.z3NnUQM1JdNhnYmNS2XP43eM2MD3TEa', 1);

DROP PROCEDURE IF EXISTS insert_many_flights;
DELIMITER $$

CREATE PROCEDURE insert_many_flights (IN start_time_o TIMESTAMP, IN start_time_d TIMESTAMP, IN max INT, IN diff_hours INT, IN airplane INT, IN airline VARCHAR(2), IN origin VARCHAR(3), IN destination VARCHAR(3))
BEGIN

    DECLARE v1 INT DEFAULT 0;

    WHILE v1 < max DO
      INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
      VALUES ( start_time_o + INTERVAL (v1 * diff_hours) HOUR, start_time_d + INTERVAL (v1 * diff_hours) HOUR, airplane, airline, origin, destination);
    
      SET v1 = v1 + 1;
    END WHILE;

END$$

DELIMITER ;

-- insert flights
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-20 07:20:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-20 09:35:00.00', '+01:00', '+00:00'), 9, 'BA', 'LHR', 'CDG');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-14 11:20:00.00', '+04:00', '+00:00'), CONVERT_TZ('2019-05-14 14:55:00.00', '+03:00', '+00:00'), 2, 'EK', 'DXB', 'IST');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-09 16:40:00.00', '+04:00', '+00:00'), CONVERT_TZ('2019-05-09 20:20:00.00', '+03:00', '+00:00'), 3, 'FZ', 'DXB', 'IST');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-11 19:50:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-11 23:30:00.00', '-04:00', '+00:00'), 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-20 8:30:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-20 12:10:00.00', '-04:00', '+00:00'), 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-21 8:30:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-21 12:10:00.00', '-04:00', '+00:00'), 7, 'AY', 'LHR', 'JFK');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-20 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-20 07:55:00.00', '+01:00', '+00:00'), 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-27 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-27 07:55:00.00', '+01:00', '+00:00'), 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-25 10:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 13:50:00.00', '-04:00', '+00:00'), 11, 'FR', 'VIE', 'JFK');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-25 11:10:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 15:45:00.00', '-04:00', '+00:00'), 7, 'LH', 'VIE', 'JFK');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-30 8:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-30 10:15:00.00', '+01:00', '+00:00'), 2, 'BA', 'LGW', 'VIE');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-04 08:00:00.00', '+02:00', '+00:00'), CONVERT_TZ('2019-05-04 08:45:00.00', '+00:00', '+00:00'), 5, 'AY', 'HEL', 'LGW');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-05 18:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-05 22:50:00.00', '+02:00', '+00:00'), 5, 'AY', 'LGW', 'HEL');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-25 04:10:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-25 06:45:00.00', '+01:00', '+00:00'),6, 'LH', 'LHR', 'FRA');

INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination)
VALUES (CONVERT_TZ('2019-05-27 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-27 07:55:00.00', '+00:00', '+00:00'), 11, 'FR', 'TXL', 'LHR');


CALL insert_many_flights('2018-12-5 06:15:00.00', '2018-12-5 09:40:00.00', 40, 70, 10, 'MH', 'KUL', 'PEK');
CALL insert_many_flights('2018-12-5 06:15:00.00', '2018-12-5 09:40:00.00', 40, 70, 10, 'MH', 'PEK', 'KUL');

CALL insert_many_flights('2018-12-20 06:19:00.00', '2018-12-20 09:44:00.00', 150, 62, 6, 'LH', 'LHR', 'FRA');
CALL insert_many_flights('2018-02-24 06:19:00.00', '2018-02-24 09:44:00.00', 40, 55, 6, 'LH', 'BTS', 'FRA');
CALL insert_many_flights('2018-02-26 06:24:00.00', '2018-02-26 10:09:00.00', 40, 55, 6, 'LH', 'BRQ', 'FRA');
CALL insert_many_flights('2019-01-10 06:19:00.00', '2019-01-10 09:47:00.00', 40, 55, 6, 'LH', 'RME', 'FRA');
CALL insert_many_flights('2019-01-12 05:24:00.00', '2019-01-12 10:09:00.00', 40, 55, 6, 'LH', 'LYS', 'FRA');
CALL insert_many_flights('2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 40, 55, 6, 'LH', 'MOW', 'FRA');
CALL insert_many_flights('2019-01-16 10:09:00.00', '2019-01-16 13:27:00.00', 40, 55, 6, 'LH', 'BUD', 'FRA');

CALL insert_many_flights('2018-02-20 06:19:00.00', '2018-02-20 09:44:00.00', 40, 55, 15, 'MH', 'FRA', 'LHR');
CALL insert_many_flights('2018-02-22 06:24:00.00', '2018-02-22 10:09:00.00', 40, 55, 5, 'AF', 'FRA', 'HEL');
CALL insert_many_flights('2018-02-24 06:19:00.00', '2018-02-24 09:44:00.00', 40, 55, 11, 'AA', 'FRA', 'BTS');
CALL insert_many_flights('2018-02-26 06:24:00.00', '2018-02-26 10:09:00.00', 40, 55, 12, 'LH', 'FRA', 'BRQ');
CALL insert_many_flights('2019-01-10 06:19:00.00', '2019-01-10 09:47:00.00', 40, 55, 11, 'LH', 'FRA', 'RME');
CALL insert_many_flights('2019-01-12 05:24:00.00', '2019-01-12 10:09:00.00', 40, 55, 14, 'AF', 'FRA', 'LYS');
CALL insert_many_flights('2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 40, 55, 2, 'LH', 'FRA', 'MOW');
CALL insert_many_flights('2019-01-16 10:09:00.00', '2019-01-16 13:27:00.00', 40, 55, 3, 'LH', 'FRA', 'BUD');

CALL insert_many_flights('2018-12-08 06:19:00.00', '2018-12-08 09:34:00.00', 30, 80, 7, 'FR', 'LHR', 'PRG');
CALL insert_many_flights('2018-12-02 06:34:00.00', '2018-12-02 10:09:00.00', 30, 80, 11, 'AY', 'HEL', 'PRG');
CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 09:34:00.00', 30, 80, 9, 'FR', 'BTS', 'PRG');
CALL insert_many_flights('2018-12-06 06:34:00.00', '2018-12-06 10:09:00.00', 30, 80, 11, 'AF', 'BRQ', 'PRG');
CALL insert_many_flights('2019-01-01 06:19:00.00', '2019-01-01 09:37:00.00', 30, 80, 11, 'AY', 'RME', 'CFN');
CALL insert_many_flights('2019-01-02 10:09:00.00', '2019-01-02 14:34:00.00', 30, 80, 11, 'FR', 'LYS', 'PRG');
CALL insert_many_flights('2019-01-02 00:09:00.00', '2019-01-02 10:04:00.00', 30, 80, 11, 'AA', 'JFK', 'PRG');
CALL insert_many_flights('2019-01-09 02:04:00.00', '2019-01-09 12:26:00.00', 30, 80, 9, 'AA', 'PRG', 'JFK');
CALL insert_many_flights('2019-01-09 00:09:00.00', '2019-01-09 10:04:00.00', 30, 80, 11, 'MH', 'JFK', 'PRG');
CALL insert_many_flights('2019-01-02 02:04:00.00', '2019-01-02 12:26:00.00', 30, 80, 11, 'MH', 'PRG', 'JFK');
CALL insert_many_flights('2019-01-04 06:19:00.00', '2019-01-04 10:31:00.00', 30, 80, 6, 'AA', 'MOW', 'PRG');
CALL insert_many_flights('2019-01-06 10:09:00.00', '2019-01-06 13:37:00.00', 30, 80, 4, 'FZ', 'BUD', 'PRG');


CALL insert_many_flights('2018-12-12 05:24:00.00', '2018-12-12 10:09:00.00', 35, 90, 11, 'FR', 'PRG', 'CFN');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 10:01:00.00', 35, 90, 11, 'FR', 'PRG', 'MOW');
CALL insert_many_flights('2018-12-16 10:09:00.00', '2018-12-16 13:27:00.00', 35, 90, 11, 'MH', 'PRG', 'BTS');

CALL insert_many_flights('2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 35, 90, 11, 'FR', 'PRG', 'MOW');
CALL insert_many_flights('2018-12-22 06:34:00.00', '2018-12-22 10:09:00.00', 35, 90, 11, 'FR', 'PRG', 'LYS');
CALL insert_many_flights('2018-12-25 06:19:00.00', '2018-12-25 06:59:00.00', 35, 90, 11, 'FR', 'PRG', 'TXL');


CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 10:01:00.00', 35, 90, 11, 'FR', 'FRA', 'VIE');
CALL insert_many_flights('2018-12-16 10:09:00.00', '2018-12-16 13:49:00.00', 35, 90, 11, 'FR', 'CDG', 'VIE');

CALL insert_many_flights('2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 35, 90, 11, 'FR', 'LHR', 'VIE');
CALL insert_many_flights('2018-12-22 06:34:00.00', '2018-12-22 10:09:00.00', 35, 90, 11, 'AY', 'HEL', 'VIE');
CALL insert_many_flights('2018-12-25 06:19:00.00', '2018-12-25 09:34:00.00', 35, 90, 11, 'FR', 'CFN', 'VIE');
CALL insert_many_flights('2018-12-26 06:34:00.00', '2018-12-26 10:09:00.00', 35, 90, 11, 'OS', 'BRQ', 'VIE');
CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 09:37:00.00', 35, 90, 11, 'OS', 'CDG', 'VIE');
CALL insert_many_flights('2018-12-12 10:09:00.00', '2018-12-12 12:34:00.00', 35, 90, 11, 'OS', 'LYS', 'VIE');
CALL insert_many_flights('2018-12-12 00:09:00.00', '2018-12-12 10:04:00.00', 35, 90, 11, 'FR', 'JFK', 'VIE');


CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 10:01:00.00', 35, 90, 6, 'LH', 'VIE', 'FRA');
CALL insert_many_flights('2018-12-16 10:09:00.00', '2018-12-16 13:27:00.00', 35, 90, 11, 'FR', 'VIE', 'CDG');

CALL insert_many_flights('2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 35, 90, 15, 'OS', 'VIE', 'LHR');
CALL insert_many_flights('2018-12-22 06:34:00.00', '2018-12-22 10:09:00.00', 35, 90, 5, 'OS', 'VIE', 'HEL');
CALL insert_many_flights('2018-12-25 06:19:00.00', '2018-12-25 06:49:00.00', 35, 90, 11, 'OS', 'VIE', 'BTS');
CALL insert_many_flights('2018-12-26 06:34:00.00', '2018-12-26 10:09:00.00', 35, 90, 11, 'OS', 'VIE', 'BRQ');
CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 09:37:00.00', 35, 90, 11, 'AF', 'VIE', 'CDG');
CALL insert_many_flights('2018-12-12 10:09:00.00', '2018-12-12 05:34:00.00', 35, 90, 11, 'FR', 'CFN', 'LYS');
CALL insert_many_flights('2018-12-12 00:09:00.00', '2018-12-12 10:04:00.00', 35, 90, 11, 'AA', 'VIE', 'JFK');

CALL insert_many_flights('2018-12-25 10:15:00.00', '2018-12-25 22:50:00.00', 35, 90, 11, 'AA', 'KUL', 'JFK');
CALL insert_many_flights('2018-12-25 11:10:00.00', '2018-12-25 22:45:00.00', 35, 90, 7, 'LH', 'PEK', 'JFK');
CALL insert_many_flights('2018-12-30 8:00:00.00', '2018-12-30 16:15:00.00', 35, 90, 2, 'BA', 'CDG', 'JFK');
CALL insert_many_flights('2018-12-04 08:00:00.00', '2018-12-04 19:45:00.00', 35, 90, 5, 'AY', 'HEL', 'JFK');
CALL insert_many_flights('2018-12-05 18:00:00.00', '2018-12-06 04:50:00.00', 35, 90, 5, 'AY', 'LGW', 'JFK');
CALL insert_many_flights('2018-12-25 04:10:00.00', '2018-12-25 11:45:00.00', 35, 90, 6, 'LH', 'LHR', 'JFK');
CALL insert_many_flights('2018-12-27 06:15:00.00', '2018-12-27 11:55:00.00', 35, 90, 11, 'AA', 'DFW', 'JFK');

CALL insert_many_flights('2018-12-25 10:15:00.00', '2018-12-25 22:50:00.00', 35, 90, 11, 'AA', 'JFK', 'KUL');
CALL insert_many_flights('2018-12-25 11:10:00.00', '2018-12-25 22:45:00.00', 35, 90, 7, 'LH', 'JFK', 'PEK');
CALL insert_many_flights('2018-12-30 8:00:00.00', '2018-12-30 16:15:00.00', 35, 90, 2, 'BA', 'JFK', 'CDG');
CALL insert_many_flights('2018-12-04 08:00:00.00', '2018-12-04 19:45:00.00', 35, 90,5, 'AY', 'JFK', 'HEL');
CALL insert_many_flights('2018-12-05 18:00:00.00', '2018-12-06 04:50:00.00', 35, 90, 5, 'AY', 'JFK', 'LGW');
CALL insert_many_flights('2018-12-25 04:10:00.00', '2018-12-25 11:55:00.00', 35, 90, 5, 'LH', 'JFK', 'LHR');
CALL insert_many_flights('2018-12-27 06:15:00.00', '2018-12-27 07:55:00.00', 35, 90, 11, 'AA', 'JFK', 'DFW');

CALL insert_many_flights('2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 35, 90, 11, 'FR', 'LHR', 'BTS');
CALL insert_many_flights('2018-12-22 06:34:00.00', '2018-12-22 10:09:00.00', 35, 90, 11, 'AY', 'HEL', 'BTS');
CALL insert_many_flights('2018-12-26 06:34:00.00', '2018-12-26 10:09:00.00', 35, 90, 11, 'FR', 'BRQ', 'BTS');
CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 09:37:00.00', 35, 90, 11, 'AF', 'CDG', 'BTS');
CALL insert_many_flights('2018-12-12 10:09:00.00', '2018-12-12 13:34:00.00', 35, 90, 11, 'AF', 'LYS', 'BTS');
CALL insert_many_flights('2018-12-12 00:09:00.00', '2018-12-12 10:04:00.00', 35, 90, 11, 'AA', 'JFK', 'BTS');

CALL insert_many_flights('2018-12-29 06:19:00.00', '2018-12-29 09:34:00.00', 35, 90, 11, 'FR', 'BTS', 'CFN');
CALL insert_many_flights('2018-12-23 06:34:00.00', '2018-12-23 10:09:00.00', 35, 90, 5, 'AY', 'BTS', 'HEL');
CALL insert_many_flights('2018-12-27 06:34:00.00', '2018-12-27 10:09:00.00', 35, 90, 11, 'FR', 'CFN', 'BRQ');
CALL insert_many_flights('2018-12-11 06:19:00.00', '2018-12-11 09:37:00.00', 35, 90, 11, 'FR', 'BTS', 'CDG');
CALL insert_many_flights('2018-12-13 10:09:00.00', '2018-12-13 14:44:00.00', 35, 90, 11, 'FR', 'BTS', 'LYS');
CALL insert_many_flights('2018-12-13 00:09:00.00', '2018-12-13 10:04:00.00', 35, 90, 11, 'AA', 'BTS', 'JFK');


CALL insert_many_flights('2018-12-12 02:04:00.00', '2018-12-12 04:26:00.00', 35, 90, 11, 'LH', 'PRG', 'BRU');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 11:11:00.00', 35, 90, 11, 'FR', 'MOW', 'BRU');
CALL insert_many_flights('2018-12-16 10:09:00.00', '2018-12-16 13:37:00.00', 35, 90, 11, 'FR', 'BUD', 'BRU');
CALL insert_many_flights('2018-12-12 05:24:00.00', '2018-12-12 10:09:00.00', 35, 90, 11, 'FR', 'PRG', 'BRU');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 10:01:00.00', 35, 90, 11, 'FR', 'PRG', 'BRU');

CALL insert_many_flights('2018-12-03 02:04:00.00', '2018-12-03 04:26:00.00', 40, 70, 11, 'FR', 'BRU', 'PRG');
CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 11:11:00.00', 40, 70, 11, 'FR', 'BRU', 'MOW');
CALL insert_many_flights('2018-12-07 10:09:00.00', '2018-12-07 13:37:00.00', 40, 70, 11, 'FR', 'BRU', 'BUD');
CALL insert_many_flights('2018-12-03 05:24:00.00', '2018-12-03 10:09:00.00', 40, 70, 11, 'FR', 'BRU', 'PRG');
CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 10:01:00.00', 40, 70, 11, 'FR', 'BRU', 'PRG');

CALL insert_many_flights('2018-12-02 02:04:00.00', '2018-12-02 04:26:00.00', 40, 70, 16, 'BA', 'BRU', 'LGW');
CALL insert_many_flights('2018-12-03 02:04:00.00', '2018-12-03 04:06:00.00', 40, 70, 16, 'BA', 'LGW', 'BRU');

CALL insert_many_flights('2018-12-04 06:19:00.00', '2018-12-04 10:01:00.00', 40, 70, 1, 'FZ', 'BRU', 'DXB');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 11:11:00.00', 35, 90, 1, 'FZ', 'MOW', 'DXB');
CALL insert_many_flights('2018-12-13 06:19:00.00', '2018-12-13 11:11:00.00', 35, 90, 1, 'FZ', 'FRA', 'DXB');
CALL insert_many_flights('2018-12-12 06:19:00.00', '2018-12-12 11:11:00.00', 35, 90, 2, 'FZ', 'CDG', 'DXB');
CALL insert_many_flights('2018-12-11 06:19:00.00', '2018-12-11 11:11:00.00', 35, 90, 2, 'TK', 'IST', 'DXB');
CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 11:11:00.00', 35, 90, 2, 'TK', 'LGW', 'DXB');
CALL insert_many_flights('2018-12-9 06:19:00.00', '2018-12-9 11:11:00.00', 35, 90, 7, 'TK', 'PEK', 'DXB');
CALL insert_many_flights('2018-12-4 06:19:00.00', '2018-12-4 11:11:00.00', 35, 90, 7, 'TK', 'KUL', 'DXB');

CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 15:41:00.00', 40, 70, 1, 'FZ', 'DXB', 'BRU');
CALL insert_many_flights('2018-12-15 06:19:00.00', '2018-12-15 14:51:00.00', 35, 90, 1, 'FZ', 'DXB', 'MOW');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 15:11:00.00', 35, 90, 1, 'FZ', 'DXB', 'FRA');
CALL insert_many_flights('2018-12-13 06:19:00.00', '2018-12-13 11:11:00.00', 35, 90, 2, 'FZ', 'DXB', 'CDG');
CALL insert_many_flights('2018-12-12 06:19:00.00', '2018-12-12 11:11:00.00', 35, 90, 2, 'TK', 'DXB', 'IST');
CALL insert_many_flights('2018-12-11 06:19:00.00', '2018-12-11 11:11:00.00', 35, 90, 2, 'TK', 'DXB', 'LGW');
CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 16:00:00.00', 35, 90, 7, 'TK', 'DXB', 'PEK');
CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 15:55:00.00', 35, 90, 7, 'TK', 'DXB', 'KUL');


CALL insert_many_flights('2018-12-10 06:19:00.00', '2018-12-10 11:11:00.00', 35, 90, 8, 'TK', 'LGW', 'IST');
CALL insert_many_flights('2018-12-9 06:19:00.00', '2018-12-9 11:11:00.00', 35, 90, 8, 'TK', 'PEK', 'IST');
CALL insert_many_flights('2018-12-4 06:19:00.00', '2018-12-4 11:11:00.00', 35, 90, 8, 'TK', 'KUL', 'IST');

CALL insert_many_flights('2018-12-05 06:19:00.00', '2018-12-05 15:01:00.00', 40, 70, 8, 'TK', 'IST', 'BRU');
CALL insert_many_flights('2018-12-15 06:19:00.00', '2018-12-15 10:11:00.00', 35, 90, 8, 'FZ', 'IST', 'MOW');
CALL insert_many_flights('2018-12-14 06:19:00.00', '2018-12-14 14:11:00.00', 35, 90, 8, 'FZ', 'IST', 'FRA');
CALL insert_many_flights('2018-12-13 06:19:00.00', '2018-12-13 14:43:00.00', 35, 90, 8, 'TK', 'IST', 'CDG');
-- -- insert reservations
-- INSERT INTO reservations (payment_status, created_at, created_by)
-- VALUES ('1', '2019-03-20 02:42:11.00', '1');

-- INSERT INTO reservations (payment_status, created_at, created_by)
-- VALUES ('0', '2019-03-25 21:12:12.00', '2');

-- INSERT INTO reservations (payment_status, created_at, created_by)
-- VALUES ('1', '2019-02-01 23:42:12.00', '3');

-- INSERT INTO reservations (payment_status, created_at, created_by)
-- VALUES ('0', '2019-05-01 23:42:12.00', '4');

-- INSERT INTO reservations (payment_status, created_at, created_by)
-- VALUES ('1', '2019-05-01 00:42:12.00', '4');

-- INSERT INTO reservations (payment_status, created_at, created_by)

-- VALUES ('1', '2019-05-03 5:42:12.00', '5');

-- -- insert tickets
-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (410, 2, 'AA1001', 'E', '2019-03-20 02:42:11.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (123, 4, 'AA1002', 'B', '2019-03-25 21:12:12.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (142, 4, 'AA1003', 'B', '2019-02-01 23:42:12.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (142, 6, 'AA1004', 'B', '2019-05-01 23:42:12.00');

-- -- reservation = NULL == tmp reservation
-- INSERT INTO tickets (cost, flight, seat_class, created_at)
-- VALUES (172, 'LI1725', 'B', '2018-11-24 02:02:12.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (112, 5, 'AA1006', 'E', '2019-05-03 5:42:12.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (512, 5, 'AA1007', 'E', '2019-03-20 02:42:11.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (512, 2, 'AA1008', 'E', '2019-03-25 21:12:12.00');

-- INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
-- VALUES (512, 4, 'AA1009', 'E', '2019-02-01 23:42:12.00');


-- insert search records
-- INSERT INTO search_records (customer, flight)
-- VALUES (1, 'BA0304');

-- INSERT INTO search_records (customer, flight)
-- VALUES (1, 'LH1724');

-- INSERT INTO search_records (customer, flight)
-- VALUES (1, 'EK1234');
