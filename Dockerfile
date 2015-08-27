FROM tutum/lamp:latest
MAINTAINER Sunchan Lee <sunchanlee@inslab.co.kr>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-ldap
RUN rm -fr /app && mkdir -p /app

ADD testlink.sh /testlink.sh
RUN chmod 755 /testlink.sh
ADD clean.sh /clean.sh
RUN chmod 755 /clean.sh
ADD import_mysql_testlink_data.sh /import_mysql_testlink_data.sh
RUN chmod 755 /import_mysql_testlink_data.sh

COPY . /app

RUN mkdir -p /var/testlink/logs/
RUN chmod 777 /var/testlink/logs/

RUN mkdir -p /var/testlink/upload_area/
RUN chmod 777 /var/testlink/upload_area/

RUN chmod 777 /var/lib/php5

WORKDIR /app
RUN tar -zxvf testlink-1.9.13.tar.gz && rm -f testlink-1.9.13.tar.gz
RUN mv testlink-1.9.13 testlink && rm -fr testlink-1.9.13
RUN mkdir -p /tmp/testlink_conf && cp testlink/config*.php /tmp/testlink_conf/

RUN chmod 777 /app/testlink/gui/templates_c
RUN cp config_db.inc.php /app/testlink/

EXPOSE 80 3306

VOLUME ["/var/lib/mysql"]

CMD ["/testlink.sh"]
