FROM mariadb:10.3

ENV WORKDIR /workdir

# install supervisord
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

# Change data directory
RUN sed -i '/^datadir*/ s|/var/lib/mysql|/volume/mysql_data|' /etc/mysql/my.cnf

# add backups
COPY backup.sh ${WORKDIR}/backup.sh

# copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

WORKDIR /workdir

COPY docker-entrypoint.sh /entrypoint.sh
COPY post-configuration.sh /opt/post-configuration.sh

RUN mkdir -p /volume && chmod -R 777 /volume && chmod a+w /etc/mysql/
RUN mkdir ${WORKDIR}/sv-child-logs/ && chmod -R 777 ${WORKDIR}

# Initialize NSS wrapper
COPY debian-nss.sh /opt/debian-nss.sh
RUN /opt/debian-nss.sh

USER 27

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
