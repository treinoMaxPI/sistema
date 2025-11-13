FROM maven:3.9-eclipse-temurin-17-alpine

WORKDIR /app

# Copy pom.xml for dependency resolution
COPY pom.xml .

COPY src ./src
# src will be mounted as a volume from docker-compose
# This allows hot reload with devtools

# Expose the application port
EXPOSE 8080

# Pre-build to download dependencies and install the app (skip tests for faster builds)
RUN mvn -DskipTests install --no-transfer-progress

# Run with Spring Boot Maven plugin (supports devtools hot reload)
CMD ["mvn", "spring-boot:run"]
