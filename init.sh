#!/bin/sh
# this script is used for initialization of eva web server

# before you run this script please
# change login xmarko15 to your login in this files .env.example, ./public/.htaccess, ./resources/views/inc/navbar.blade.php
printf "if you did not change login xmarko15 to your login in this files .env.example, ./public/.htaccess, ./resources/views/inc/navbar.blade.php, than change it and rerun this script\n"
yes | cp -i .env.example .env
yes | cp -ai ./public/. ../
chmod 755 ../
chmod 755 ../index.php
# chmod 755 -R ../

# next you have to initialize database
# mysql xlogin00 -u xlogin00 -p  < ./db/db.sql
# password can be found here https://wis.fit.vutbr.cz/FIT/st/csmeva.php