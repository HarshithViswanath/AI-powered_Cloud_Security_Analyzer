# Use a multi-stage build to reduce the final image size
# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Create data directory for SQLite database
RUN mkdir -p /app/data

# Copy the application JAR
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Copy the database file from the host
COPY mydb.sqlite /app/data/mydb.sqlite

# Copy the ARFF data file from resources
COPY src/main/resources/threat_data.arff /app/data/threat_data.arff

# Set proper permissions for the database file
RUN chmod 644 /app/data/mydb.sqlite
RUN chmod 644 /app/data/threat_data.arff

# Expose the port the app runs on
EXPOSE 9090

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"] 