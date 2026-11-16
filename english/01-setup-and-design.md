# SQL Server setup

[English tutorial](../README.md) · [Persian tutorial](../README.fa.md)

## Connect to SQL Server

Use SQL Server 2022 or later on a development machine or instance. You need permission to create a database for the initial setup and to create objects in that database for the lessons. SSMS, VS Code, and `sqlcmd` are all clients that can send T-SQL to the engine.

- **Windows with SSMS.** Install the SQL Server Database Engine and SQL Server Management Studio. Connect using Windows Authentication when your account has access. The server name for a default local instance is typically `localhost`. A default Express installation uses `localhost\SQLEXPRESS`. [SQL Server downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) · [Install SSMS](https://learn.microsoft.com/en-us/ssms/install/install)
- **Linux or Docker.** Install SQL Server on a supported Linux distribution, or use the container example below on an x86-64 Docker host. Connect with the MSSQL extension for VS Code or `sqlcmd`. [Ubuntu installation](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu) · [Docker quickstart](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker) · [VS Code connection guide](https://learn.microsoft.com/en-us/sql/tools/visual-studio-code-extensions/mssql/mssql-database-connections)
- **An existing development instance.** Use the server name and authentication method you were given. Use the instance's configured TLS certificate validation when you connect remotely.

### Docker example with Bash

This starts SQL Server Developer Edition on loopback and saves the database files in the `retail-sql-data` Docker volume. Enter a strong password when prompted.

```bash
read -rsp 'SQL Server sa password: ' MSSQL_SA_PASSWORD
printf '\n'
export MSSQL_SA_PASSWORD

docker run --detach --name retail-sql \
  --env ACCEPT_EULA=Y \
  --env MSSQL_PID=Developer \
  --env MSSQL_SA_PASSWORD \
  --publish 127.0.0.1:1433:1433 \
  --volume retail-sql-data:/var/opt/mssql \
  mcr.microsoft.com/mssql/server:2022-latest

unset MSSQL_SA_PASSWORD
docker logs --tail 40 retail-sql
```

Wait for the log to say SQL Server is ready for client connections. Connect to `127.0.0.1,1433` using SQL Server Authentication and the `sa` login. If the local container uses a self-signed certificate, you can select **Trust Server Certificate** for this development connection. Use `docker start retail-sql` to resume the same container later.

## Create the tutorial database

| Edition | Practice database | Setup and sample data |
| --- | --- | --- |
| English | `SQLServerTutorialENDB` | [Getting started](../README.md#getting-started) |
| Persian | `SQLServerTutorialDB` | [Getting started](../README.fa.md#شروع-کار) |

Run the full database-and-table script, then the five sample data blocks in order. In SSMS or VS Code, paste the blocks into a query window on the same connection. The scripts use `GO` as a batch separator. If you run them through an application driver, send each batch separately.
