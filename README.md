# pentaho-di-docker
pentaho data integration in docker instance

Replace parameters in <...>  with the local values in your system.

docker run --rm \
        -e APP_UID=<app_uid:1000> -e APP_GID=<app_gid:1000> \
  -e DATABASE_TYPE=<MYSQL> -e DATABASE_HOST=<mysql.example.com> -e DATABASE_DATABASE=<mydb> -e DATABASE_PORT=<3306> -e DATABASE_USER=<username> -e DATABASE_PASSWORD=<pwd> \
  schoolscout/pentaho-kettle kitchen.sh -rep repository -user <username> -pass <password> [ARGUMENTS]
