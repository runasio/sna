Hacking
=======

Set up postgresql
-----------------

Set password for postgres user:

    $ sudo -u postgres psql

    postgres=# ALTER USER postgres WITH PASSWORD 'postgres';

Update `/var/lib/pgsql/data/pg_hba.conf` to allow password login (`password`, `md5` or `scram-sha-256`):

    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust

Restart postgresql

Check you can log-in:

    $ psql -h localhost -U postgres -W

Create the `sna_dev` database:

    $ sudo -u postgres createdb sna_dev
