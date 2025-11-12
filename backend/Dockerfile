# Multi-stage Dockerfile: build with Maven then run on a lightweight JRE image
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml mvnw mvnw.cmd ./
COPY .mvn .mvn
COPY src ./src
# Run a package to build the application jar
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar
## If you want the app to serve the static frontend copied into the image,
## ensure the Docker build context includes the repository root so the `oops/`
## folder is available to copy. Render builds use the repo root as context when
## you point the service at `backend/Dockerfile`.
## Copy static frontend into the image (optional)
COPY ../oops /app/oops

# Allow the server port to be configured by the environment (Render provides $PORT)
ENV SPRING_WEB_RESOURCES_STATIC_LOCATIONS=file:/app/oops/,classpath:/static/
EXPOSE 8080
# Use sh -c so environment variable expansion works for -Dserver.port
ENTRYPOINT ["sh","-c","java -Dserver.port=${PORT:-8080} -jar /app/app.jar"]
