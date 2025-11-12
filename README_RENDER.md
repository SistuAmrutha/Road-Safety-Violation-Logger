Render deployment notes

This project contains a Java Spring Boot backend in `backend/` and a static frontend in `oops/`.

Recommended deployment (Docker on Render):

1. Use the `backend/Dockerfile` (already prepared to read `$PORT` and copy the `oops/` folder into the image).
   - When creating the Web Service in Render, point to the repo and set the "Dockerfile path" to `backend/Dockerfile`.
   - Render will use the repository root as the build context so the Dockerfile can copy `oops/` into the image.

2. Database:
   - Provision a managed database (Postgres on Render or external MySQL).
   - Add environment variables to the Render service (in Settings → Environment):
     - `SPRING_DATASOURCE_URL` (JDBC URL)
     - `SPRING_DATASOURCE_USERNAME`
     - `SPRING_DATASOURCE_PASSWORD`
     - `SPRING_PROFILES_ACTIVE` (set to `mysql` if using MySQL)

3. Port handling:
   - The container respects Render's `$PORT` environment variable.
   - The Dockerfile sets the JVM system property `-Dserver.port=${PORT:-8080}`.

4. Static frontend:
   - The Dockerfile copies the `oops/` folder into `/app/oops` inside the image and sets Spring to serve static files from there.
   - Alternatively, deploy `oops/` as a separate Render Static Site and point it to the backend API.

5. Build & start options:
   - Leave the default build command when using Dockerfile (Render will build via Docker).
   - No custom start command is required; the Dockerfile's ENTRYPOINT handles `PORT`.

If you'd like, I can also:
- Add a small `application-render.properties` profile for Render-specific DB settings,
- Add a small health-check endpoint and configure Render's health check,
- Or prepare Postgres support (add dependency and profile) if you prefer Render managed Postgres.
