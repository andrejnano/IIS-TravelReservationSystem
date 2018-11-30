# Dokumentácia k rozhraniu API

## GET requests

### Search
Vráti vyhľadané lety vo formáte JSON.
Všetky argumenty GET requestu sú voliteľné, pokiaľ užívateľ nezadá ani jeden parameter, tak sa mu vypíše obsah tabuľky letov a nejaké ďalšie podrobnosti.

#### Vysvetlenie argumentov

- **origin** Definuje podmienku pre vyhľadanie počiatočného letiska. Vyhľadáva v troch rôznych stĺpcoch tabuľky **airport_code, city, country**. Pokiaľ sa zhoduje aspoň s jedným stĺpcom, tak je podmienka splnená. To znamená, že užívateľ může použiť vyhľadávacie reťazce ako napr.: VIE, Vienna, Austria. V prvom prípade vyhľadá z letisk s kódom VIE a v poslednom všetky lety s Rakúska. Default, podmienka je vynechaná.
- **destination** Definuje podmienku pre vyhľadanie cieľového letiska. Použitie je rovnaké ako u parametru origin. Default, podmienka je vynechaná.
- **tickets** Definuje počet lístkov, ktoré používateľ potrebuje. Celé číslo vačšie ako 0. Default 1.
- **min_t** Určuje minimálny čas, ktorý chce užívateľ stráviť v destinácii. Hodnota je v **dňoch** celé nezáporné číslo. Default 0.
- **max_t** Určuje maximálny čas, ktorý chce užívateľ stráviť v destinácii. Hodnota je v **dňoch** celé nezáporné číslo. Default, podmienka je vynechaná.
- **departure_date**
- **arrival_date**
- **min_price**
- **max_price**
- **class** Trieda sedadla, let musí mať definovaný počet voľných sedadiel v tejto triede. Tri
možnosti hodnoty argumentu triedy: **first, business, economy**. Default postupuje sa od najlacnejšej k najdrahšej a zisťuje sa či je dosť miest v tejto triede. To znamená že pokiaľ si užívateľ zadal že chce viac lístkov, tak všetky budú v jednej triede. Nikdy nerozdelí skupinu do viacerých tried.


### Flight
Vráti podrobnosti o konkrétnom lete vo formáte JSON.
Všetky jedine argument **f2** GET requestu je voliteľný. Ostatné sú povinné.
#### Vysvetlenie argumentov
- **f1** Povinný argument, ktorý označuje prvý let smerom tam. ID letu napr. AB3275.
- **f2** Voliteľný argument, označuje spiatočný let. Pokiaľ užívateľ nehladal spiatočný let, tak sa tento parameter nepoužije.
- **tickets** Povinný argument. Definuje počet lístkov, ktoré používateľ potrebuje. Celé číslo vačšie ako 0.
- **class** Povinný argument. Trieda sedadla, let musí mať definovaný počet voľných sedadiel v tejto triede. Inak sa vráti error 409 niekto si zarezervoval sedadlo a už nieje dosť voľných.

### airports
Bez parametra. Vráti obsah tabuľky airports v podobe JSON

### flights
Bez parametra. Vráti obsah tabuľky flights v podobe JSON

### airplanes
Bez parametra. Vráti obsah tabuľky airplanes v podobe JSON

### airlines
Bez parametra. Vráti obsah tabuľky airlines v podobe JSON

### users
Bez parametra. Vráti obsah tabuľky users v podobe JSON. **Túto operáciu môže spustiť iba prihlásený administrátor.**



## POST requests
### Login
Prihlásenie užívateľa
Vytvorí novú session a nastaví session parametre user (admin, user) a uid (id uzivatela z databazy)
#### Vysvetlenie argumentov
- **email** Unikátny reťazec z databázy, identifikujúci užívateľa.
- **password** Prihlasovacie heslo.
### Register
#### Vysvetlenie argumentov
Rovnako ako prihlásenie, vytvorí novú session a nastaví session parametre.
- **email** Unikátny reťazec, identifikujúci užívateľa, momentálne nieje kontrola na @.
- **password** Prihlasovacie heslo.
- **first_name** Meno
- **last_name** Priezvisko
### Reservation
Bez parametrov, vytvorí novú rezerváciu a vráti jej hodnotu, ako json. 
```json
{"new_reservation_id":"15"}
```
### Reserve
Priradí dočasnú letenku (ticket) k rezervácii. To znamená, že sa letenka rezervuje.
#### Vysvetlenie argumentov
- **res_id** ID rezervácie vytvorenej prihláseným užívateľom
- **ticket_id** ID letenky, ktorú chce užívateľ rezervovať.
- **email** Email na pasažiera, pre ktorého je letenka určená.
- **first_name** Meno pasažiera, pre ktorého je letenka určená.
- **last_name** Priezvisko pasažiera, pre ktorého je letenka určená.
### Logout
Bez parametrov, zruší súčasnú session. Odhlási užívateľa.
### Add_flight
Vytvori novy let v databazi v tabulce flights. Request musi provadet admin.
#### Vysvetlenie argumentov
- **flight_number** unikatni retezec oznacujici cislo letu (napr. LH1724)
- **departure_time** datum a cas odletu (ve formatu "2019-03-23 09:42:00.00")
- **arrival-time** datum a cas priletu (ve formatu "2019-03-23 09:42:00.00")
- **airplane** id letadla, odkaz do tabulky airplanes
- **airline** kod letecke spolecnosti (napr. "AF")
- **origin** startovni letiste (odkazujici do tabulky airports, napr. "LHR")
- **destination** cilove letiste (odkazujici do tabulky airports, napr. "LHR")
### Add_airline
Vytvori novou aerolinku v databazi v tabulce airlines. Request musi provadet admin.
#### Vysvetlenie argumentov
- **airline** unikatni retezec oznacujici aerolinku (napr. "AF")
- **full_name** retezec obsahujici cely nazev spolecnosti
- **nationality** retezec obsahujici cely nazev statu ze ktereho spolecnost pochazi
- **hub** rezezec oznacujici domovske letiste (odkazujici do tabulky airports, napr. "LHR")
- **id_logo** rezezec obsahujici kod shodny s oznacenim loga (napr. "AFR")
### Add_airport
Vytvori nove letiste v databazi v tabulce airports. Request musi provadet admin.
#### Vysvetlenie argumentov
- **airport_code** unikatni retezec oznacujici letiste (napr. "LHR")
- **city** retezec obsahujici cely nazev mesta
- **country** retezec obsahujici cely nazev statu
### Add_airplane
Vytvori nove letadlo v databazi v tabulce airplanes. Request musi provadet admin.
#### Vysvetlenie argumentov
- **producer** retezec oznacujici vyrobce letadla
- **model** retezec oznacujici model letadla
- **fclass_seats** cislo udavajici pocet sedadel prvni tridy
- **bclass_seats** cislo udavajici pocet sedadel business tridy
- **eclass_seats** cislo udavajici pocet sedadel economy tridy
- **airline** retezec oznacujici aerolinku (odkazujici do tabulky airlines, napr. "AF")
### Update_airline
Upravi udaje o aerolince v databazi v tabulce airlines. Jediny povinny parametr je airline.
Sloupce, ktere nemaji zadanou novou hodnotu jsou ponechany beze zmeny.
Request musi provadet admin.
#### Vysvetlenie argumentov
- **airline** unikatni retezec oznacujici aerolinku (napr. "AF")
- **full_name** retezec obsahujici cely nazev spolecnosti
- **nationality** retezec obsahujici cely nazev statu ze ktereho spolecnost pochazi
- **hub** rezezec oznacujici domovske letiste (odkazujici do tabulky airports, napr. "LHR")
- **id_logo** rezezec obsahujici kod shodny s oznacenim loga (napr. "AFR")
### Update_user
Upravi data ulozene u uzivatele. Jediny povinny parametr je id. Sloupce, ktere nemaji
zadanou novou hodnotu jsou ponechany beze zmeny. Upravu muze provadet admin nebo samotny
uzivatel, ktereho se zmena tyka. Pouze admin muze navic provest zmenu parametru is_admin
#### Vysvetlenie argumentov
- **id** unikatni cislo uzivatele, jediny povinny parametr
- **first_name** krestni jmeno uzivatele
- **last_name** prijmeni uzivatele
- **email** emailova adresa uzivatele
- **password** hashovane heslo
- **is_admin** bool hodnota (1 je admin, 0 neni admin), zmenu muze provest pouze admin
### Delete_user
Odstrani uzivatele se zadanym id z databaze. Opravneni ma pouze admin.

### my_reservations
Bez parametra. Iba pre prihláseného užívateľa. Vráti rezervácie daného užívateľa.
### reservation_tickets
Iba pre prihláseného užívateľa. Vráti obsah rezervácie to znamená všetky lístky, ktoré patria k rezervácii.
#### parameter
- **res_id** Číslo rezervácie, ktorú chce užívateľ zobraziť.
### return_ticket
Iba pre prihláseného užívateľa. Odstráni rezervovanú letenku z databázy.
#### parameter
- **ticket_id** Číslo letenky, ktorú chce užívateľ vrátiť.
### delete_flight
Iba pre admina. Odstráni let a všetky jeho závislosti z databázy.
#### parameter
- **flight_number** Identifikátor letu
### delete_airplane
Iba pre admina. odstráni lietadlo a všetky jeho závislosti z databázy.
#### parameter
- **airplane** Identifikátor lietadla
### delete_airline
Iba pre admina. Odstráni leteckú spoločnosť a všetky jej závislosti z databázy.
#### parameter
- **airline** Identifikátor leteckej spoločnosti vo formáte AA.
## V adresári sa nachádzajú vzorové súbory json s príkladmi použitia
