FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && apt-get clean


COPY ./tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh

EXPOSE 3306
CMD ["/mariadb.sh"]
