FROM postgres:14

COPY /valiot-app-db/ssl/out/ ./var/lib/postgresql/
COPY /valiot-app-db/ssl/ssl-conf.sh /usr/local/bin

RUN chown postgres:postgres /var/lib/postgresql/postgresdb.key && \
    chown postgres:postgres /var/lib/postgresql/postgresdb.crt && \
    chown postgres:postgres /var/lib/postgresql/valiot.crt && \
    chown postgres:postgres /var/lib/postgresql/valiot.crl
RUN chmod 600 /var/lib/postgresql/postgresdb.key && \
    chmod 600 /var/lib/postgresql/postgresdb.crt && \
    chmod 600 /var/lib/postgresql/valiot.crt && \
    chmod 600 /var/lib/postgresql/valiot.crl

RUN chmod +x ./usr/local/bin/ssl-conf.sh
# WHY does this crashes?
# RUN ./usr/local/bin/ssl-conf.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD [\
  "-c", "ssl=on" ,\
  "-c", "ssl_cert_file=/var/lib/postgresql/postgresdb.crt",\
  "-c", "ssl_key_file=/var/lib/postgresql/postgresdb.key",\
  "-c", "ssl_ca_file=/var/lib/postgresql/valiot.crt",\
  "-c", "ssl_crl_file=/var/lib/postgresql/valiot.crl"\
]
