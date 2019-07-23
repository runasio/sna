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


Prevent the runtime to take too much CPU making the machine unusable
--------------------------------------------------------------------

This trick can be useful, especially in case you have an infinite loop in your
program and the runtime start to consume CPU and IO with no reason, making your
machine unusable and forcing a hard-reboot.

[cpulimit][cpulimit] is a small utility that will put any process to sleep if
it consumes more than the configured amount of CPU. It can save your day. To
start the server with it, you can run:

    cpulimit -l 50 -i mix phx.server

[cpulimit]: http://cpulimit.sourceforge.net/
