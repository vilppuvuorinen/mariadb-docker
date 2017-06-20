FROM mariadb:10.3

ENV WORKDIR /workdir

# install supervisord
RUN apt-get update && apt-get install -y supervisor gettext && rm -rf /var/lib/apt/lists/*

# install nss-wrapper from unstable
ADD apt/unstable.pref /etc/apt/preferences.d/unstable.pref
ADD apt/unstable.list /etc/apt/sources.list.d/unstable.list
RUN apt-get update && apt-get install -y -t unstable libnss-wrapper \ 
					&& rm -rf /var/lib/apt/lists/* \
					&& rm -rf /etc/apt/sources.list.d/unstable.list \
					&& rm -rf /etc/apt/preferences.d/unstable.pref

# Change data directory
RUN sed -i '/^datadir*/ s|/var/lib/mysql|/volume/mysql_data|' /etc/mysql/my.cnf

# add backups
COPY backup.sh ${WORKDIR}/backup.sh

# copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

VOLUME /var/lib/mysql
WORKDIR /workdir

COPY passwd.template ${WORKDIR}/passwd.template
COPY docker-entrypoint.sh /entrypoint.sh
COPY post-configuration.sh /opt/post-configuration.sh

RUN mkdir -p /volume && chmod -R 777 /volume && chmod a+w /etc/mysql/
RUN mkdir ${WORKDIR}/sv-child-logs/ && chmod -R 777 ${WORKDIR}

USER 27

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
