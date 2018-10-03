<p align="center"><img src="https://laravel.com/assets/img/components/logo-laravel.svg"></p>

# ISS-projekt

Projekt z predmetu IIS (Informacne systemy) na FIT VUT Brno. Temou informacneho systemu je rezervacny system pre predaj leteniek.

**Project Repository**: https://github.com/andrejnano/IIS-projekt

## Setup guide

**Install prerequisites**:

- [Docker](https://docs.docker.com/install/)
- [Composer](https://getcomposer.org/)

1. `git clone https://github.com/andrejnano/IIS-projekt`
2. `cd IIS-projekt`
3. `docker-compose up --build` or `docker-compose up`

- CTRL+C to exit and stop the running container
- To stop all running containers: `docker-compose stop`
- To remove all containers locally: `docker-compose rm -f`
- To enter the running container: `docker-compose exec web /bin/bash`

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
