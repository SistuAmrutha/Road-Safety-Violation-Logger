# OOPS Backend (Spring Boot)

This is a simple Spring Boot backend for the OOPS project. It exposes CRUD endpoints for a Report entity and uses JPA for persistence.

How to run (dev / H2):

1. Build:

```powershell
cd backend
# If you have Maven installed:
mvn -DskipTests clean package

# Or use the Maven Wrapper (recommended if you don't have Maven):
# 1) Ensure the wrapper jar is present:
#    In PowerShell run (from the backend folder):
#
#    Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar' -OutFile .\\mvn\\wrapper\\maven-wrapper.jar
#
# 2) Run the wrapper to build (Windows PowerShell):
#    .\\mvnw.cmd -DskipTests clean package
```

2. Run:

```powershell
java -jar target\oops-backend-0.0.1-SNAPSHOT.jar
```

Run with MySQL profile:

```powershell
$env:SPRING_PROFILES_ACTIVE = 'mysql'; mvn spring-boot:run
```

API endpoints (base /api/reports):
- GET /api/reports
- GET /api/reports/{id}
- POST /api/reports
- PUT /api/reports/{id}
- DELETE /api/reports/{id}
- GET /api/reports/search?q=...

MySQL with Docker Compose

1. Start MySQL using Docker Compose (from the `backend` folder):

```powershell
docker compose up -d
```

This will start a MySQL 8 container with a database named `oopsdb` and root password `changeme`. The project mounts `src/main/resources/data.sql` into the container so the seed data is applied on first run.

2. Run the Spring Boot app using the `mysql` profile:

```powershell
# Use system Maven if available
mvn spring-boot:run -Dspring-boot.run.profiles=mysql

# Or build and run jar with profile
mvn -DskipTests package
java -jar target\oops-backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=mysql
```

Notes about the Maven wrapper

- The repository includes `mvnw`/`mvnw.cmd` scripts. If you see an error like
	"Unable to access jarfile .mvn\wrapper\maven-wrapper.jar", the wrapper JAR is missing from the `.mvn/wrapper/` directory.
- Workarounds:
	- Install Maven on your machine and run `mvn` directly.
	- Or download the missing wrapper JAR manually into `.mvn/wrapper/` (see comments above in this README on how to fetch it).

If you prefer a quick helper to fetch the missing wrapper JAR on Windows, run the included PowerShell script from the `backend` folder:

```powershell
# from backend folder
.\scripts\get-maven-wrapper.ps1
# then use the wrapper
.\mvnw.cmd -DskipTests clean package

Quick demo with Docker (no MySQL, uses embedded H2)
-------------------------------------------------
If you have Docker Desktop installed you can run the app only (uses H2 DB) with the included compose override:

PowerShell:

```powershell
cd backend
docker compose -f docker-compose.dev.yml up --build -d
```

Then open http://localhost:8080/index.html in your browser. This keeps the app running locally and is the recommended quick demo flow.

If Docker is not installed on your machine, install Docker Desktop for Windows (or install Maven) and follow one of the options above.

Making the app available for 60 days
-----------------------------------
I can't host the site for you from here, but you can keep it available for 60 days by running the Docker compose stack on a VM or a small cloud instance (DigitalOcean, Azure VM, AWS EC2) or by deploying the Docker image to a platform like Render or Railway. If you want, I can prepare a GitHub Actions workflow to build and push the Docker image to Docker Hub or deploy to one of those providers — tell me which provider/account you prefer and I will help set that up.
```

Committing the Maven wrapper JAR (optional)

If you choose to add `.mvn/wrapper/maven-wrapper.jar` to the repository so `./mvnw.cmd` works out-of-the-box for everyone, follow this pre-check and use the suggested commit message:

Pre-check (before committing):
- Ensure the file exists: `.mvn/wrapper/maven-wrapper.jar`.
- Ensure `.mvn/wrapper/` is not excluded by `.gitignore`.
- Verify the JAR size is reasonable (about 50–150 KB for the takari wrapper).

Suggested commit message (one-liner):

```
chore: add maven-wrapper.jar so mvnw works out-of-the-box
```

Note: committing the binary increases repository size slightly because Git stores the file in history. Keeping the helper script `scripts/get-maven-wrapper.ps1` is a lighter-weight alternative.

Local MySQL (no Docker)
------------------------

If you prefer not to use Docker but want the backend connected to a MySQL server, you can install MySQL locally (or use an existing remote MySQL) and run the app with the `mysql` profile.

Quick steps (PowerShell):

1. Install MySQL Server for Windows and start the MySQL service.

2. Create the database (you'll be prompted for the root password):

```powershell
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS oopsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

3. (Optional) Set the root password to `changeme` to match `application-mysql.properties`:

```powershell
mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'changeme'; FLUSH PRIVILEGES;"
```

4. Run the app with the MySQL profile (from the `backend` folder):

```powershell
$env:SPRING_PROFILES_ACTIVE='mysql'
.\mvnw.cmd spring-boot:run
```

Notes:
- If your MySQL uses different credentials or host/port, update `src/main/resources/application-mysql.properties`.
- You can also use the helper local runner that supports profiles: `./scripts/run-local.ps1 -Profile mysql`.

