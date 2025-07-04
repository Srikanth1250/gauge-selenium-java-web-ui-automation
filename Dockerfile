# ----------- Stage 1: Build the project -----------
FROM maven:3.9.6-eclipse-temurin-11 AS build

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Download Gauge CLI and required plugins
RUN curl -SsL https://downloads.gauge.org/stable | sh \
 && gauge install java \
 && gauge install html-report

# Build the project and download all dependencies
RUN mvn clean package -DskipTests

# ----------- Stage 2: Run specs -----------
FROM eclipse-temurin:11-jdk

# Set working directory
WORKDIR /app

# Copy built project and Gauge from the builder
COPY --from=build /app /app
COPY --from=build /root/.gauge /root/.gauge
COPY --from=build /usr/local/bin/gauge /usr/local/bin/gauge

# Run specs by default
CMD ["gauge", "run", "specs"]
