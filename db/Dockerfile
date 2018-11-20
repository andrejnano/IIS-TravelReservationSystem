FROM mysql:5.7

COPY ./db.sql /db.sql

WORKDIR /

CMD mysql source ./db.sql
