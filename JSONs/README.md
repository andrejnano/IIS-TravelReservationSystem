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
- **class** Trieda sedadla, let musí mať definovaný počet voľných sedadiel v tejto triede. Tri možnosti hodnoty argumentu triedy: **first, business, economy**. Default postupuje sa od najlacnejšej k najdrahšej a zisťuje sa či je dosť miest v tejto triede. To znamená že pokiaľ si užívateľ zadal že chce viac lístkov, tak všetky budú v jednej triede. Nikdy nerozdelí skupinu do viacerých tried.


### Flight
Vráti podrobnosti o konkrétnom lete vo formáte JSON.
Všetky jedine argument **f2** GET requestu je voliteľný. Ostatné sú povinné.
#### Vysvetlenie argumentov
- **f1** Povinný argument, ktorý označuje prvý let smerom tam. ID letu napr. AB3275.
- **f2** Voliteľný argument, označuje spiatočný let. Pokiaľ užívateľ nehladal spiatočný let, tak sa tento parameter nepoužije.
- **tickets** Povinný argument. Definuje počet lístkov, ktoré používateľ potrebuje. Celé číslo vačšie ako 0.
- **class** Povinný argument. Trieda sedadla, let musí mať definovaný počet voľných sedadiel v tejto triede. Inak sa vráti error 409 niekto si zarezervoval sedadlo a už nieje dosť voľných.

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
- **flight_number** unikatni retezec oznacujici cislo letu
- **departure_time** datum a cas odletu (ve formatu "2019-03-23 09:42:00.00")
- **arrival-time** datum a cas priletu (ve formatu "2019-03-23 09:42:00.00")
- **airplane** id letadla, odkaz do tabulky airplanes
- **airline** kod letecke spolecnosti (napr. "AF")
- **origin** startovni letiste (napr. "LHR")
- **destination** cilove letiste (napr. "LHR")

## V adresári sa nachádzajú vzorové súbory json s príkladmi použitia
