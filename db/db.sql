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
        WHERE airplanes.id = NEW.airplane);

        SET NEW.bclass_seats_free = 
        (SELECT bclass_seats
        FROM airplanes
        WHERE airplanes.id = NEW.airplane);
        
        SET NEW.eclass_seats_free = 
        (SELECT eclass_seats
        FROM airplanes
        WHERE airplanes.id = NEW.airplane);
      END$$

  DELIMITER ;


  CREATE TABLE users (
    id               INT PRIMARY KEY AUTO_INCREMENT,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL,
    password         VARCHAR(100) NOT NULL,
    updated_at       TIMESTAMP,
    remember_token   VARCHAR(100),
    created_at       TIMESTAMP,
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

  CREATE TABLE passengers (
    /* Personal ID number */
    -- id              INT NOT NULL PRIMARY KEY REGEXP_LIKE'[0-9][0-9][0-8][0-9][0-3][0-9][0-9]{3,4}', /* todo triiger */
    id              INT PRIMARY KEY AUTO_INCREMENT, 
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL
  );

  CREATE TABLE tickets (
    /* Flight Ticket number ; Example : 160-4837291830 */
    -- ticket_number   VARCHAR(14) NOT NULL PRIMARY KEY REGEXP_LIKE '[0-9]{3}(-)?[0-9]{10}', /* todo triiger */
    ticket_number   INT PRIMARY KEY AUTO_INCREMENT,
    cost            INT NOT NULL,
    reservation     INT NOT NULL,
    passenger       INT NOT NULL,
    flight          VARCHAR(6) NOT NULL,
    seat_number     VARCHAR(3),
    seat_class      VARCHAR(1),

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(id),
    CONSTRAINT ticket_for_passenger_fk    FOREIGN KEY (passenger)   REFERENCES passengers(id),
    CONSTRAINT ticket_for_flight_fk       FOREIGN KEY (flight)      REFERENCES flights(flight_number)
  );

  DROP TRIGGER IF EXISTS tickets_trig;
  DELIMITER $$

      CREATE TRIGGER tickets_trig BEFORE INSERT ON tickets
      FOR EACH ROW BEGIN
        IF (NOT NEW.seat_number REGEXP '[0-9][0-9][A-K]' OR NOT NEW.seat_class REGEXP '(F|B|E)') THEN
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong expression type at ticket insertion, expected regex  seat_number [0-9][0-9][A-K] and seat_class regex (F|B|E)';
        END IF;
      END$$

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
        END IF;
      IF (NEW.seat_class = 'B') THEN
        UPDATE flights
        SET bclass_seats_free = bclass_seats_free - 1
        WHERE flights.flight_number = NEW.flight;
        END IF;
      IF (NEW.seat_class = 'B') THEN
        UPDATE flights
        SET eclass_seats_free = eclass_seats_free - 1
        WHERE flights.flight_number = NEW.flight;
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
VALUES ('HEL', 'Helsinki', 'Finland');

INSERT INTO airports (airport_code, city, country)
VALUES ('VIE', 'Vienna', 'Austria');



-- info from wikipedia ; list of airlines
INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AA', 'American Airlines', 'USA', 'DFW');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('LH', 'Lufthansa', 'Germany', 'FRA');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AF', 'Air France', 'France', 'CDG');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('BA', 'British Airways', 'United Kingdom ', 'LHR');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('TK', 'Turkish Airlines', 'Turkey', 'IST');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('EK', 'Emirates', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('FZ', 'flydubai', 'United Arab Emirates', 'DXB');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('AY', 'Finnair Oyj', 'Finland', 'HEL');

INSERT INTO airlines (airline, full_name, nationality, hub)
VALUES ('OS', 'Austrian', 'Austria', 'VIE');


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
VALUES ('Boeing', '767-300', '0', '36', '176', 'OS');


INSERT INTO passengers (first_name, last_name)
VALUES ('Andrej', 'Nano');

INSERT INTO passengers (first_name, last_name)
VALUES ('Peter', 'Marko');

INSERT INTO passengers (first_name, last_name)
VALUES ('Sherwin', 'Hsu');

INSERT INTO passengers (first_name, last_name)
VALUES ('Ifor', 'Smoak');

INSERT INTO passengers (first_name, last_name)
VALUES ('Meno', 'Priezvisko');

INSERT INTO passengers (first_name, last_name)
VALUES ('Meno', 'Priezvisko');

INSERT INTO passengers (first_name, last_name)
VALUES ('Meno', 'Priezvisko');

INSERT INTO passengers (first_name, last_name)
VALUES ('Dalibor', 'Masaryk');

INSERT INTO passengers (first_name, last_name)
VALUES ('Aurélia', 'Dubovská');

INSERT INTO passengers (first_name, last_name)
VALUES ('Mohamed', 'Lee');

INSERT INTO passengers (first_name, last_name)
VALUES ('Teódor', 'Ladislav');


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
VALUES ('OS0089', CONVERT_TZ('2019-05-25 10:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 13:50:00.00', '-04:00', '+00:00'), 10, 'OS', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LH1235', CONVERT_TZ('2019-05-25 11:10:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-25 15:45:00.00', '-04:00', '+00:00'), 7, 'LH', 'VIE', 'JFK');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AZ2275', CONVERT_TZ('2019-05-30 8:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-30 10:15:00.00', '+01:00', '+00:00'), 2, 'BA', 'LGW', 'VIE');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AB3275', CONVERT_TZ('2019-05-04 08:00:00.00', '+02:00', '+00:00'), CONVERT_TZ('2019-05-04 08:45:00.00', '+00:00', '+00:00'), 5, 'AY', 'HEL', 'LGW');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('AC1275', CONVERT_TZ('2019-05-05 18:00:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-05 22:50:00.00', '+02:00', '+00:00'), 5, 'AY', 'LGW', 'HEL');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('BZ1275', CONVERT_TZ('2019-05-25 04:10:00.00', '+00:00', '+00:00'), CONVERT_TZ('2019-05-25 06:45:00.00', '+01:00', '+00:00'), 6, 'LH', 'LHR', 'FRA');

INSERT INTO flights (flight_number, departure_time, arrival_time, airplane, airline, origin, destination)
VALUES ('LI1725', CONVERT_TZ('2019-05-27 06:15:00.00', '+01:00', '+00:00'), CONVERT_TZ('2019-05-27 07:55:00.00', '+00:00', '+00:00'), 10, 'LH', 'TXL', 'LHR');




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
INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (410, 2, 1, 'BA0304', '12B', 'E');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (123, 4, 2, 'EK1234', '03F', 'B');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (142, 4, 3, 'LH1724', '01B', 'B');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (142, 6, 3, 'LH1725', '01B', 'B');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (172, 6, 4, 'LI1725', '01C', 'B');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (112, 5, 1, 'AZ2275', '01D', 'E');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (512, 5, 1, 'AA0001', '05D', 'E');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (512, 2, 4, 'AA0001', '05D', 'E');

INSERT INTO tickets (cost, reservation, passenger, flight, seat_number, seat_class)
VALUES (512, 4, 6, 'AA0001', '05D', 'E');



-- insert search records
INSERT INTO search_records (customer, flight)
VALUES (1, 'BA0304');

INSERT INTO search_records (customer, flight)
VALUES (1, 'LH1724');

INSERT INTO search_records (customer, flight)
VALUES (1, 'EK1234');
