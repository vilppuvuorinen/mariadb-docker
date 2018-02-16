FROM mariadb:10.3

ADD . /tmp/

RUN mkdir -p /workdir/sv-child-logs && \
  mkdir -p /volume && \
  apt-get update && \
  apt-get install -y gettext supervisor && \
  cp /tmp/unstable.list /etc/apt/sources.list.d/ && \
  apt-get update && \
  apt-get install -y -t unstable libnss-wrapper && \
  cp /tmp/passwd.template /opt/ && \
  cat /tmp/nss.sh >> /etc/bash.bashrc && \
  cp /tmp/nss.sh /workdir/ && \
  mv /tmp/entrypoint.sh /workdir/entrypoint.sh && \
  cp /tmp/backup.sh /workdir/ && \
  cp /tmp/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
  sed -i '/^datadir*/ s|/var/lib/mysql|/volume/mysql_data|' /etc/mysql/my.cnf && \
  chmod -R 777 /workdir /volume && \
  chmod a+w /etc/mysql && \
  rm -rf /tmp/* /var/lib/apt/lists/* /etc/apt/sources.list.d/unstable.list

WORKDIR /workdir

EXPOSE 3306

ENTRYPOINT ["/workdir/entrypoint.sh"]
CMD ["mysqld"]
