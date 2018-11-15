#!/bin/sh
# this script is used for initialization of eva web server


my_login=$(pwd | grep -Eoh x[a-z]{5}[0-9]{2} | head -1)

sed -i -e "s/x[a-z]\{5\}[0-9]\{2\}/$my_login/g" .env.example

sed -i -e "s/x[a-z]\{5\}[0-9]\{2\}/$my_login/g" ./public/.htaccess

sed -i -e "s/x[a-z]\{5\}[0-9]\{2\}/$my_login/g" ./resources/views/inc/navigation.blade.php

yes | cp -i .env.example .env

yes | cp -ai ./public/. ../

chmod 755 ../

chmod 755 ../index.php

# chmod 755 -R ../

sed -i -e "s/DIR__\\.\x27\\/\\.\\./DIR__\\.\x27\\/IIS-projekt/g" ../index.php

# next you have to initialize database
# mysql xlogin00 -u xlogin00 -p  < ./db/db.sql
# password can be found here https://wis.fit.vutbr.cz/FIT/st/csmeva.php
