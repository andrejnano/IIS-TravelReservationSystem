<p align="center"><img src="https://laravel.com/assets/img/components/logo-laravel.svg"></p>

# ISS-projekt

Projekt z predmetu IIS (Informacne systemy) na FIT VUT Brno. Temou informacneho systemu je rezervacny system pre predaj leteniek.

**Project Repository**: https://github.com/andrejnano/IIS-projekt

## Setup guide

**Install prerequisites**:

- [Docker](https://docs.docker.com/install/)
- [Composer](https://getcomposer.org/)

### First setup

1. `git clone https://github.com/andrejnano/IIS-projekt`
2. `cd IIS-projekt`
3. `composer install` to install all the required dependencies
4. `cp .env.example .env` create a new environment config based on project's default
5. `php artisan key:generate` to create new APP_KEY in your local .env (**REQUIRED**)
6. `chmod -R o+rw bootstrap/ storage/` to allow Apache to edit project's files
7. `docker-compose up --build` (only for the first time or major changes) or `docker-compose up`
8. open http://localhost:8080 in a web browser

### General workflow

1. go to your project's root directory
2. `docker-compose up` to run containers (Apache+PHP & MySQL)
3. http://localhost:8080 in a web browser
4. make changes in the project's source files
5. see them reflected instantly in the container
6. `docker-compose stop && docker-compose rm -f` to stop the containers and clear up your local workspace

- CTRL+C to exit and stop the running container
- To stop all running containers: `docker-compose stop`
- To remove all containers locally: `docker-compose rm -f`
- To enter the running container: `docker-compose exec web /bin/bash`
- Use `--build` flag on `docker-compose up` to rebuild the whole image

## Learning Resources

- [Learn Docker in 12 Minutes🐳](https://www.youtube.com/watch?v=YFl2mCHdv24)
- [Docker for beginners](https://docker-curriculum.com/)
- [Laravel Docs](https://laravel.com/docs)

### About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel attempts to take the pain out of development by easing common tasks used in the majority of web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, yet powerful, providing tools needed for large, robust applications.

### Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of any modern web application framework, making it a breeze to get started learning the framework.

If you're not in the mood to read, [Laracasts](https://laracasts.com) contains over 1100 video tutorials on a range of topics including Laravel, modern PHP, unit testing, JavaScript, and more. Boost the skill level of yourself and your entire team by digging into our comprehensive video library.

## Complete development stack

- Docker
- Apache Server
- PHP-FPM
- MySQL
- Git
- Laravel
- HTML
- CSS
- Javascript
- SASS
- Gulp || Webpack
- Node.js
- Now.sh (deployment tool)

**Backend**:

- Docker images + environment setup
- Laravel / PHP
- Apache configs
- SQL + MySQL DB setup

**Frontend**:

- Node.js
- Gulp (code processing, minimizing, optimization, live reload, transpiling/compilation)
- SASS -> CSS
- HTML
- Javascript
- ? Angular || React || ...

**Apach config on Eva**
 - change login xmarko15 to your login in this files .env.example, ./public/.htaccess, ./resources/views/inc/navbar.blade.php
 - Inserted this lines into .htacess, allow laravel routing in your base route
 ```
 RewriteEngine On
 RewriteBase /~xlogin00/
 ```
 - if you have created mysql database, then run initialisation script <br>
    if you are using Eva, then your password for database can be found here https://wis.fit.vutbr.cz/FIT/st/csmeva.php
 ```
 mysql xlogin00 -u xlogin00 -p  < ./db/db.sql
 ```
 - set environment variables for database in .env.example and run
 ```
 cp .env.example .env
 ```
 - update project/ to your directory name
 ```
  cp -a ./public/. ../
  ```
  - allow read for others
  ```
    chmod 755 ../
    chmod 755 ../index.php
  ```
  - set links in WWW/index.php to apropriate values <br>
  before:
  ```
  require __DIR__.'/../vendor/autoload.php';
  $app = require_once __DIR__.'/../bootstrap/app.php';
  ```
  after:
  ```
  require __DIR__.'/IIS-projekt/vendor/autoload.php';
  $app = require_once __DIR__.'/IIS-projekt/bootstrap/app.php';
  ```
