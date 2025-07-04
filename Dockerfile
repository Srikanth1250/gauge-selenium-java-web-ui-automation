# ----------- Stage 1: Build the project -----------
FROM maven:3.9.6-eclipse-temurin-11 AS build

# Install unzip for Gauge
RUN apt-get update && apt-get install -y unzip curl

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Gauge CLI and plugins
RUN curl -SsL https://downloads.gauge.org/stable | sh \
 && gauge install java \
 && gauge install html-report

# Build the Maven project
RUN mvn clean package -DskipTests

# ----------- Stage 2: Run specs -----------
FROM eclipse-temurin:11-jdk

# Set working directory
WORKDIR /app

# Copy Gauge, project files, and plugins from build stage
COPY --from=build /app /app
COPY --from=build /usr/local/bin/gauge /usr/local/bin/gauge
COPY --from=build /root/.gauge /root/.gauge

# Default command: run specs
CMD ["gauge", "run", "specs"]
