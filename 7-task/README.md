# Task 7. Setup two PostgreSQL servers with primary-standby configuration.
### Primary server configuration:
* postgresql.conf:
```sh
listen_addresses = '192.168.50.101'

#for pg_rewind
wal_log_hints = on

max_wal_senders = 8
wal_keep_segments = 64

#turn on sync mode of replication,
#comment to change back async mode
synchronous_standby_names = '*'
```
* pg_hba.conf:
```sh
#for pg_basebackup and pg_rewind
host    replication      postgres       192.168.50.0/24            md5
host    all              postgres       192.168.50.0/24            md5
```

### Standby server configuration:
* postgresql.conf and pg_hba.conf like on primary, except:
```sh
listen_addresses = '192.168.50.102'
```
* recovery.conf:
```sh
standby_mode = 'on'
primary_conninfo = 'user=postgres password=devops host=192.168.50.101 port=5432 \
    sslmode=prefer sslcompression=0 krbsrvname=postgres target_session_attrs=any'
recovery_target_timeline = 'latest'
```

## Analyze performance
### insert 10M rows in table
```sh
#connect, create DB and table, fill data
sudo -u postgres psql

create database lab;
\c lab
create table t1 (c1 integer, c2 text);

explain analyze insert into t1
 select i, md5(random()::text)
 from generate_series(1, 10000000) as i;
```
* monitoring lag value with pgcenter:
```sh
pgcenter top -h localhost -U postgres lab
```

### Replication mode ASYNC
* Execution Time: 19196.601 ms
* replay_lag up to 1 sec
* total_lag up to 117k

### Replication mode SYNC
* Execution Time: 18935.851 ms
* replay_lag up to 3 sec
* total_lag up to 190k

## Prepare reports with pgbadger
* configire postgresql.conf to work with pgbadger:
```sh
log_min_duration_statement = 0
log_line_prefix = 'user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 0
log_error_verbosity = default
lc_messages='en_US.UTF-8'
lc_messages='C'
```
* prepare report:
```sh
pgbadger /var/log/postgresql/postgresql-11-main.log
```