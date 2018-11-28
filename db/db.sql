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
    flight_number     VARCHAR(6) NOT NULL PRIMARY KEY,
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


  DROP TRIGGER IF EXISTS flights_trig;

  DELIMITER $$

      CREATE TRIGGER flights_trig BEFORE INSERT ON flights
      FOR EACH ROW BEGIN
        IF (NOT NEW.flight_number REGEXP '[0-9a-zA-Z]{2}[0-9]{4}') THEN
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at flight insertion, expected regex [0-9a-zA-Z]{2}[0-9]{4}';
        END IF;

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

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id),
    CONSTRAINT ticket_for_flight_fk       FOREIGN KEY (flight)      REFERENCES flights(flight_number)
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

  CREATE TABLE search_records (
    id        INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    customer  INT NOT NULL,
    flight    VARCHAR(6) NOT NULL,

    CONSTRAINT searched_by_customer_fk  FOREIGN KEY (customer)  REFERENCES users(id),
    CONSTRAINT searched_for_flight_fk   FOREIGN KEY (flight)    REFERENCES flights(flight_number)
  );

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


-- insert flights
INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('BA0304', CONVERT_TZ('2019-05-20 07:20:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-20 09:35:00.00', '+01:00', '+00:00'), 9, 'BA', 'LHR', 'CDG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('EK1234', CONVERT_TZ('2019-05-14 11:20:00.00', '+04:00', '+00:00'), CONVERT_TZ('2019-05-14 14:55:00.00', '+03:00', '+00:00'), 2, 'EK', 'DXB', 'IST');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0000', CONVERT_TZ('2019-05-09 16:40:00.00', '+04:00', '+00:00'), CONVERT_TZ('2019-05-09 20:20:00.00', '+03:00', '+00:00'), 3, 'FZ', 'DXB', 'IST');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0001', CONVERT_TZ('2019-05-11 19:50:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-11 23:30:00.00', '-04:00', '+00:00'), 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0002', CONVERT_TZ('2019-05-20 8:30:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-20 12:10:00.00', '-04:00', '+00:00'), 1, 'BA', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AA0003', CONVERT_TZ('2019-05-21 8:30:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-21 12:10:00.00', '-04:00', '+00:00'), 7, 'AY', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1724', CONVERT_TZ('2019-05-20 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-20 07:55:00.00', '+01:00', '+00:00'), 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1725', CONVERT_TZ('2019-05-27 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-27 07:55:00.00', '+01:00', '+00:00'), 9, 'LH', 'FRA', 'TXL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('OS0089', CONVERT_TZ('2019-05-25 10:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 13:50:00.00', '-04:00', '+00:00'), 11, 'FR', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1235', CONVERT_TZ('2019-05-25 11:10:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 15:45:00.00', '-04:00', '+00:00'), 7, 'LH', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AZ2275', CONVERT_TZ('2019-05-30 8:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-30 10:15:00.00', '+01:00', '+00:00'), 2, 'BA', 'LGW', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AB3275', CONVERT_TZ('2019-05-04 08:00:00.00', '+02:00', '+00:00'), CONVERT_TZ('2019-05-04 08:45:00.00', '+00:00', '+00:00'), 5, 'AY', 'HEL', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AC1275', CONVERT_TZ('2019-05-05 18:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-05 22:50:00.00', '+02:00', '+00:00'), 5, 'AY', 'LGW', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('BZ1275', CONVERT_TZ('2019-05-25 04:10:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-25 06:45:00.00', '+01:00', '+00:00'),6, 'LH', 'LHR', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LI1725', CONVERT_TZ('2019-05-27 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-27 07:55:00.00', '+00:00', '+00:00'), 11, 'FR', 'TXL', 'LHR');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('MH0317', '2018-12-20 06:15:00.00', '2018-12-20 09:40:00.00', 10, 'MH', 'KUL', 'PEK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('MH0318', '2018-12-22 10:05:00.00', '2018-12-22 06:20:00.00', 10, 'MH', 'PEK', 'KUL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('MH0319', '2018-12-24 06:15:00.00', '2018-12-24 09:40:00.00', 10, 'MH', 'KUL', 'PEK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('MH0320', '2018-12-26 10:05:00.00', '2018-12-26 06:20:00.00', 10, 'MH', 'PEK', 'KUL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0017', '2018-12-20 06:19:00.00', '2018-12-20 09:44:00.00', 6, 'LH', 'LHR', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0018', '2018-12-22 10:09:00.00', '2018-12-22 06:24:00.00', 6, 'LH', 'HEL', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0019', '2018-12-24 06:19:00.00', '2018-12-24 09:44:00.00', 6, 'LH', 'BTS', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0020', '2018-12-26 10:09:00.00', '2018-12-26 06:24:00.00', 6, 'LH', 'BRQ', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0117', '2019-01-10 06:19:00.00', '2019-01-10 09:47:00.00', 6, 'LH', 'RME', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0118', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 6, 'LH', 'LYS', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0119', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 6, 'LH', 'MOW', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0120', '2019-01-16 10:09:00.00', '2019-01-16 06:27:00.00', 6, 'LH', 'BUD', 'FRA');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0217', '2018-12-20 06:19:00.00', '2018-12-20 09:44:00.00', 15, 'MH', 'FRA', 'LHR');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0218', '2018-12-22 10:09:00.00', '2018-12-22 06:24:00.00', 5, 'AF', 'FRA', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0219', '2018-12-24 06:19:00.00', '2018-12-24 09:44:00.00', 11, 'AA', 'FRA', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0220', '2018-12-26 10:09:00.00', '2018-12-26 06:24:00.00', 12, 'LH', 'FRA', 'BRQ');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0222', '2019-01-10 06:19:00.00', '2019-01-10 09:47:00.00', 11, 'LH', 'FRA', 'RME');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0243', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 14, 'AF', 'FRA', 'LYS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0229', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 2, 'LH', 'FRA', 'MOW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('FR0221', '2019-01-16 10:09:00.00', '2019-01-16 06:27:00.00', 3, 'LH', 'FRA', 'BUD');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 7, 'FR', 'LHR', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 11, 'AY', 'HEL', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0019', '2018-12-25 06:19:00.00', '2018-12-25 09:34:00.00', 9, 'FR', 'BTS', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0020', '2018-12-26 10:09:00.00', '2018-12-26 06:34:00.00', 11, 'AF', 'BRQ', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0117', '2019-01-10 06:19:00.00', '2019-01-10 09:37:00.00', 11, 'AY', 'RME', 'CFN');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0118', '2019-01-12 10:09:00.00', '2019-01-12 05:34:00.00', 11, 'FR', 'LYS', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0198', '2019-01-12 00:09:00.00', '2019-01-12 10:04:00.00', 11, 'AA', 'JFK', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0149', '2019-01-19 02:04:00.00', '2019-01-12 12:26:00.00', 9, 'AA', 'PRG', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0148', '2019-01-19 00:09:00.00', '2019-01-19 10:04:00.00', 11, 'MH', 'JFK', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0199', '2019-01-12 02:04:00.00', '2019-01-12 12:26:00.00', 11, 'MH', 'PRG', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0119', '2019-01-14 06:19:00.00', '2019-01-14 10:31:00.00', 6, 'AA', 'MOW', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR0120', '2019-01-16 10:09:00.00', '2019-01-16 06:37:00.00', 4, 'FZ', 'BUD', 'PRG');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1218', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 11, 'FR', 'PRG', 'CFN');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1219', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 11, 'FR', 'PRG', 'MOW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1220', '2019-01-16 10:09:00.00', '2019-01-16 06:27:00.00', 11, 'MH', 'PRG', 'BTS');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 11, 'FR', 'PRG', 'MOW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 11, 'FR', 'PRG', 'LYS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PR1019', '2018-12-25 06:19:00.00', '2018-12-25 06:59:00.00', 11, 'FR', 'PRG', 'TXL');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0229', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 11, 'FR', 'FRA', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0221', '2019-01-16 10:09:00.00', '2019-01-16 06:27:00.00', 11, 'FR', 'CDG', 'VIE');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 11, 'FR', 'LHR', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 11, 'AY', 'HEL', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0019', '2018-12-25 06:19:00.00', '2018-12-25 09:34:00.00', 11, 'FR', 'CFN', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0020', '2018-12-26 10:09:00.00', '2018-12-26 06:34:00.00', 11, 'FR', 'BRQ', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0117', '2019-01-10 06:19:00.00', '2019-01-10 09:37:00.00', 11, 'FR', 'CDG', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0118', '2019-01-12 10:09:00.00', '2019-01-12 05:34:00.00', 11, 'FR', 'LYS', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZZ0198', '2019-01-12 00:09:00.00', '2019-01-12 10:04:00.00', 11, 'FR', 'JFK', 'VIE');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0229', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 6, 'LH', 'VIE', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0221', '2019-01-16 10:09:00.00', '2019-01-16 06:27:00.00', 11, 'FR', 'VIE', 'CDG');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 15, 'OS', 'VIE', 'LHR');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 5, 'OS', 'VIE', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0019', '2018-12-25 06:19:00.00', '2018-12-25 09:34:00.00', 11, 'OS', 'VIE', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0020', '2018-12-26 10:09:00.00', '2018-12-26 06:34:00.00', 11, 'FR', 'VIE', 'BRQ');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0117', '2019-01-10 06:19:00.00', '2019-01-10 09:37:00.00', 11, 'FR', 'VIE', 'CDG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0118', '2019-01-12 10:09:00.00', '2019-01-12 05:34:00.00', 11, 'FR', 'CFN', 'LYS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('XZ0198', '2019-01-12 00:09:00.00', '2019-01-12 10:04:00.00', 11, 'FR', 'VIE', 'JFK');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC0089', '2019-01-25 10:15:00.00', '2019-01-25 22:50:00.00', 11, 'AA', 'KUL', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC1235', '2019-01-25 11:10:00.00', '2019-01-25 22:45:00.00', 7, 'LH', 'PEK', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC2275', '2019-05-30 8:00:00.00', '2019-05-30 16:15:00.00', 2, 'BA', 'CDG', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC3275', '2019-05-04 08:00:00.00', '2019-05-04 19:45:00.00', 5, 'AY', 'HEL', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC1242', '2019-05-05 18:00:00.00', '2019-05-06 04:50:00.00', 5, 'AY', 'LGW', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC1275', '2019-05-25 04:10:00.00', '2019-05-25 06:45:00.00', 6, 'LH', 'LHR', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('CC1725', '2019-05-27 06:15:00.00', '2019-05-27 07:55:00.00', 11, 'FR', 'DFW', 'JFK');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC1089', '2019-01-25 10:15:00.00', '2019-01-25 22:50:00.00', 11, 'AA', 'JFK', 'KUL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC1235', '2019-01-25 11:10:00.00', '2019-01-25 22:45:00.00', 7, 'LH', 'JFK', 'PEK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC2275', '2019-05-30 8:00:00.00', '2019-05-30 16:15:00.00', 2, 'BA', 'JFK', 'CDG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC3275', '2019-05-04 08:00:00.00', '2019-05-04 19:45:00.00',5, 'AY', 'JFK', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC1242', '2019-05-05 18:00:00.00', '2019-05-06 04:50:00.00', 5, 'AY', 'JFK', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC1275', '2019-05-25 04:10:00.00', '2019-05-25 06:45:00.00', 5, 'LH', 'JFK', 'LHR');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('DC1725', '2019-05-27 06:15:00.00', '2019-05-27 07:55:00.00', 11, 'FR', 'JFK', 'DFW');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 11, 'FR', 'LHR', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 11, 'AY', 'HEL', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0020', '2018-12-26 10:09:00.00', '2018-12-26 06:34:00.00', 11, 'FR', 'BRQ', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0117', '2019-01-10 06:19:00.00', '2019-01-10 09:37:00.00', 11, 'AF', 'CDG', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0118', '2019-01-12 10:09:00.00', '2019-01-12 05:34:00.00', 11, 'AF', 'LYS', 'BTS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('ZY0198', '2019-01-12 00:09:00.00', '2019-01-12 10:04:00.00', 11, 'AA', 'JFK', 'BTS');


INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0017', '2018-12-28 06:19:00.00', '2018-12-28 09:34:00.00', 11, 'FR', 'BTS', 'CFN');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0018', '2018-12-22 10:09:00.00', '2018-12-22 06:34:00.00', 5, 'AY', 'BTS', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0020', '2018-12-26 10:09:00.00', '2018-12-26 06:34:00.00', 11, 'FR', 'CFN', 'BRQ');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0117', '2019-01-10 06:19:00.00', '2019-01-10 09:37:00.00', 11, 'FR', 'BTS', 'CDG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0118', '2019-01-12 10:09:00.00', '2019-01-12 05:34:00.00', 11, 'FR', 'BTS', 'LYS');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AK0198', '2019-01-12 00:09:00.00', '2019-01-12 10:04:00.00', 11, 'AA', 'BTS', 'JFK');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PS0199', '2019-01-12 02:04:00.00', '2019-01-12 04:26:00.00', 11, 'FR', 'PRG', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PS0119', '2019-01-14 06:19:00.00', '2019-01-14 11:11:00.00', 11, 'FR', 'MOW', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PS0120', '2019-01-16 10:09:00.00', '2019-01-16 06:37:00.00', 11, 'FR', 'BUD', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PS1218', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 11, 'FR', 'PRG', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PS1219', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 11, 'FR', 'PRG', 'BRU');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PD0199', '2019-01-12 02:04:00.00', '2019-01-12 04:26:00.00', 11, 'FR', 'BRU', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PD0119', '2019-01-14 06:19:00.00', '2019-01-14 11:11:00.00', 11, 'FR', 'BRU', 'MOW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PD0120', '2019-01-16 10:09:00.00', '2019-01-16 06:37:00.00', 11, 'FR', 'BRU', 'BUD');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PD1218', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 11, 'FR', 'BRU', 'PRG');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('PD1219', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 11, 'FR', 'BRU', 'PRG');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AD0199', '2019-01-12 02:04:00.00', '2019-01-12 04:26:00.00', 1, 'BA', 'BRU', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AD0119', '2019-01-14 06:19:00.00', '2019-01-14 11:11:00.00', 1, 'BA', 'BRU', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AD0120', '2019-01-16 10:09:00.00', '2019-01-16 06:37:00.00', 1, 'BA', 'BRU', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AD1218', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 1, 'BA', 'BRU', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AD1219', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 1, 'BA', 'BRU', 'LGW');



INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AR0199', '2019-01-12 02:04:00.00', '2019-01-12 04:26:00.00', 1, 'BA', 'LGW', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AR0119', '2019-01-14 06:19:00.00', '2019-01-14 11:11:00.00', 1, 'BA', 'LGW', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AR0120', '2019-01-16 10:09:00.00', '2019-01-16 06:37:00.00', 1, 'BA', 'LGW', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AR1218', '2019-01-12 10:09:00.00', '2019-01-12 05:24:00.00', 1, 'BA', 'LGW', 'BRU');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AR1219', '2019-01-14 06:19:00.00', '2019-01-14 10:01:00.00', 1, 'BA', 'LGW', 'BRU');


-- insert reservations
INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', '2019-03-20 02:42:11.00', '1');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('0', '2019-03-25 21:12:12.00', '2');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', '2019-02-01 23:42:12.00', '3');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('0', '2019-05-01 23:42:12.00', '4');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', '2019-05-01 00:42:12.00', '4');

INSERT INTO reservations (payment_status, created_at, created_by)
VALUES ('1', '2019-05-03 5:42:12.00', '5');


-- insert tickets
INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (410, 2, 'BA0304', 'E', '2019-03-20 02:42:11.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (123, 4, 'EK1234', 'B', '2019-03-25 21:12:12.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (142, 4, 'LH1724', 'B', '2019-02-01 23:42:12.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (142, 6, 'LH1725', 'B', '2019-05-01 23:42:12.00');

-- reservation = NULL == tmp reservation
INSERT INTO tickets (cost, flight, seat_class, created_at)
VALUES (172, 'LI1725', 'B', '2018-11-24 02:02:12.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (112, 5, 'AZ2275', 'E', '2019-05-03 5:42:12.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (512, 5, 'AA0001', 'E', '2019-03-20 02:42:11.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (512, 2, 'AA0001', 'E', '2019-03-25 21:12:12.00');

INSERT INTO tickets (cost, reservation, flight, seat_class, created_at)
VALUES (512, 4, 'AA0001', 'E', '2019-02-01 23:42:12.00');



-- insert search records
INSERT INTO search_records (customer, flight)
VALUES (1, 'BA0304');

INSERT INTO search_records (customer, flight)
VALUES (1, 'LH1724');

INSERT INTO search_records (customer, flight)
VALUES (1, 'EK1234');
