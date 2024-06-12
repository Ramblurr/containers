# datomic

This image provides a quick and easy way to start [Datomic Pro or Datomic Console][datomic]

[datomic](https://docs.datomic.com/releases-pro.html)

### Volumes

* `/config` - (optional) where you can mount your own transactor properties or boot edn

### Transactor Mode

Runs a Datomic Transactor. This is the default mode when the container is run with no command.

The default port is `4334`.

A rw volume of `/config` is required.

Configure with env vars (see below) or add `/config/transactor.properties` to supply a config to the transactor.

A rw volume of `/data` is optional (for use in H2 mode).

**Env vars:**

Note: all env vars can be passed with `_FILE` to read the value from a file
(e.g, when using secrets). Example: `DATOMIC_STORAGE_ADMIN_PASSWORD` can be
passed as `DATOMIC_STORAGE_ADMIN_PASSWORD_FILE=/run/secrets/admin-password` and
the value from that file will be used as the admin password.

* `DATOMIC_TRANSACTOR_PROPERTIES_PATH` - The path to the properties file for the transactor. Defaults to `/config/transactor.properties`

The following environment vars configure the properties, refer to the datomic documentation for more information:

* `DATOMIC_ALT_HOST` - `alt-host`
* `DATOMIC_DATA_DIR` - `data-dir` (default: /data)
* `DATOMIC_ENCRYPT_CHANNEL` - `encrypt-channel`
* `DATOMIC_HEARTBEAT_INTERVAL_MSEC` - `heartbeat-interval-msec`
* `DATOMIC_HOST` - `host` (default: 0.0.0.0)
* `DATOMIC_MEMCACHED` - `memcached`
* `DATOMIC_MEMCACHED_AUTO_DISCOVERY` - `memcached-auto-discovery`
* `DATOMIC_MEMCACHED_CONFIG_TIMEOUT_MSEC` - `memcached-config-timeout-msec`
* `DATOMIC_MEMCACHED_PASSWORD` - `memcached-password`
* `DATOMIC_MEMCACHED_USERNAME` - `memcached-username`
* `DATOMIC_MEMORY_INDEX_MAX` - `memory-index-max` (default: 256m)
* `DATOMIC_MEMORY_INDEX_THRESHOLD` - `memory-index-threshold` (default: 32m)
* `DATOMIC_OBJECT_CACHE_MAX` - `object-cache-max` (default: 128m)
* `DATOMIC_PID_FILE` - `pid-file`
* `DATOMIC_HEALTHCHECK_CONCURRENCY` - `ping-concurrency`
* `DATOMIC_HEALTHCHECK_HOST` - `ping-host`
* `DATOMIC_HEALTHCHECK_PORT` - `ping-port`
* `DATOMIC_PORT` - `port` (default: 4334)
* `DATOMIC_PROTOCOL` - `protocol` (default: dev)
* `DATOMIC_READ_CONCURRENCY` - `read-concurrency`
* `DATOMIC_SQL_DRIVER_CLASS` - `sql-driver-class`
* `DATOMIC_SQL_URL` - `sql-url`
* `DATOMIC_STORAGE_ACCESS` - `storage-access` (default: remote)
* `DATOMIC_STORAGE_ADMIN_PASSWORD` - `storage-admin-password`
* `DATOMIC_STORAGE_DATOMIC_PASSWORD` - `storage-datomic-password`
* `DATOMIC_VALCACHE_MAX_GB` - `valcache-max-gb`
* `DATOMIC_VALCACHE_PATH` - `valcache-path`
* `DATOMIC_WRITE_CONCURRENCY` - `write-concurrency`

### Console Mode

Runs the Datomic Console.

Run this mode by passing the `console` as the first and only argument to the container.

The default port is `8080`.

**Env vars:**

* `DB_URI` - the database connection URI that console uses to connect to datomic
* `DB_URI_FILE` - will read the connection URI from the file specified by this env var

## Example Compose

### Datomic Pro with Local Storage

Please note the tag below may not be up to date.

``` yaml
---
services:
  datomic-transactor:
    image: ghcr.io/ramblurr/datomic-pro:1.0.7075
    environment:
      DATOMIC_STORAGE_ADMIN_PASSWORD: unsafe
      DATOMIC_STORAGE_DATOMIC_PASSWORD: unsafe
    volumes:
      - ./data:/data
    ports:
      - 127.0.0.1:4334:4334
    #user: 1000:1000 # if using rootful containers uncomment this

  datomic-console:
    image: ghcr.io/ramblurr/datomic-pro:1.0.7075
    command: console
    environment:
      DB_URI: datomic:dev://datomic-transactor:4334/?password=unsafe
    ports:
      - 127.0.0.1:8081:8080
    #user: 1000:1000 # if using rootful containers uncomment this
```

### Datomic Pro with Postgres Storage and memcached

This compose file is near-production ready. But you shouldn't manage the
lifecycle of the postgres schema this way. How you do it depends on your
environment.

Please note the tag below may not be up to date.

``` yaml
---
services:
  datomic-memcached:
    image: docker.io/memcached:latest
    command: memcached -m 1024
    ports:
      - 127.0.0.1:11211:11211
    restart: always
    healthcheck:
      test:
        [
          "CMD-SHELL",
          'bash -c ''echo "version" | (exec 3<>/dev/tcp/localhost/11211; cat >&3; timeout 0.1 cat <&3; exec 3<&-)''',
        ]
      interval: 5s
      retries: 60

  datomic-storage:
    image: docker.io/library/postgres:latest
    environment:
      POSTGRES_PASSWORD: unsafe
    command: postgres -c 'max_connections=1024'
    volumes:
      - ./data:/var/lib/postgresql/data
    ports:
      - 127.0.0.1:5432:5432
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 30

  datomic-storage-migrator:
    image: ghcr.io/ramblurr/datomic-pro:1.0.7075
    environment:
      PGUSER: postgres
      PGPASSWORD: unsafe
    volumes:
      - "./postgres-migrations:/migrations"
    entrypoint: /bin/sh
    command: >
      -c '(psql -h datomic-storage -lqt | cut -d \| -f 1 | grep -qw "datomic" || psql -h datomic-storage -f /opt/datomic-pro/bin/sql/postgres-db.sql) &&
             (psql -h datomic-storage -d datomic -c "\dt" | grep -q "datomic_kvs" || psql -h datomic-storage -d datomic -f /opt/datomic-pro/bin/sql/postgres-table.sql) &&
             (psql -h datomic-storage -d datomic -c "\du" | cut -d \| -f 1 | grep -qw "datomic" || psql -h datomic-storage -d datomic -f /opt/datomic-pro/bin/sql/postgres-user.sql)'
    depends_on:
      datomic-storage:
        condition: service_healthy

  datomic-transactor:
    image: ghcr.io/ramblurr/datomic-pro:1.0.7075
    environment:
      DATOMIC_STORAGE_ADMIN_PASSWORD: unsafe
      DATOMIC_STORAGE_DATOMIC_PASSWORD: unsafe
      DATOMIC_PROTOCOL: sql
      DATOMIC_SQL_URL: jdbc:postgresql://datomic-storage:5432/datomic?user=datomic&password=datomic
      DATOMIC_HEALTHCHECK_HOST: 127.0.0.1
      DATOMIC_HEALTHCHECK_PORT: 9999
      DATOMIC_MEMCACHED: datomic-memcached:11211
    ports:
      - 127.0.0.1:4334:4334
    #user: 1000:1000 # if using rootful containers uncomment this
    restart: always
    healthcheck:
      test:
        [
          "CMD-SHELL",
          'if [[ $(curl -s -o /dev/null -w "%{http_code}" -X GET http://127.0.0.1:9999/health)  = "200" ]]; then echo 0; else echo 1; fi',
        ]
      interval: 10s
      timeout: 3s
      retries: 30
    depends_on:
      datomic-storage:
        condition: service_healthy
      datomic-memcached:
        condition: service_healthy
      datomic-storage-migrator:
        condition: service_completed_successfully

  datomic-console:
    image: ghcr.io/ramblurr/datomic-pro:1.0.7075
    command: console
    environment:
      DB_URI: datomic:sql://?jdbc:postgresql://datomic-storage:5432/datomic?user=datomic&password=datomic
    ports:
      - 127.0.0.1:8081:8080
    #user: 1000:1000 # if using rootful containers uncomment this
```

## License

As of [April 2023 Datomic Pro is free][free] and the binaries are released under the [Apache 2.0 license][apache] which allows redistributing the binaries.

[free]: https://blog.datomic.com/2023/04/datomic-is-free.html
[apache]: https://www.apache.org/licenses/LICENSE-2.0.html
