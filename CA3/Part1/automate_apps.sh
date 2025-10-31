#!/usr/bin/env bash

# Automate cloning, building, and starting applications for CA3
# Controlled by environment variables

set -e  # Exit on error

# Default values for env vars (can be overridden)
CLONE_REPOS=${CLONE_REPOS:-false}
BUILD_APPS=${BUILD_APPS:-false}
START_SERVICES=${START_SERVICES:-false}

echo "Starting automation script..."
echo "CLONE_REPOS: $CLONE_REPOS"
echo "BUILD_APPS: $BUILD_APPS"
echo "START_SERVICES: $START_SERVICES"

BASE_DIR=/home/vagrant/cogsi2526-1211265-1250525-1250204/CA3/Part1

# Step 1: Clone repositories if enabled
if [ "$CLONE_REPOS" = "true" ]; then
    echo "Cloning main repository..."
    cd /home/vagrant
    git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git || echo "Main repo already exists"
    cd $BASE_DIR
    echo "Copying application repositories from main repo..."
    rm -rf ./gradle_basic_demo
    cp -r ../../CA2/Part1/gradle_basic_demo ./gradle_basic_demo
     rm -rf ./gradle_transformation
     cp -r ../../CA2/Part2/GradleProject_Transformation ./gradle_transformation

     # Configure persistent H2 database for gradle_transformation
     SYNC_DIR="/vagrant"
     H2_DATA_DIR="$SYNC_DIR/h2-data"
     APP_PROPERTIES="$BASE_DIR/gradle_transformation/src/main/resources/application.properties"

     echo "=== Setting up persistent H2 database for gradle_transformation ==="
     # Create data folder in synced directory
     sudo mkdir -p "$H2_DATA_DIR"
     sudo chmod 777 "$H2_DATA_DIR"

     # Configure persistent H2 database
     echo "Configuring application.properties for persistent H2..."
     if ! grep -q "spring.datasource.url" "$APP_PROPERTIES"; then
         cat >> "$APP_PROPERTIES" <<EOF

# =========================================
# H2 Persistent Database Configuration
# =========================================
spring.datasource.url=jdbc:h2:file:$H2_DATA_DIR/h2db;DB_CLOSE_DELAY=-1;AUTO_SERVER=TRUE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2

# Hibernate auto DDL update
spring.jpa.hibernate.ddl-auto=update
EOF
     else
         echo "Database configuration already present in application.properties"
     fi

     echo "DONE"
     echo "Persistent H2 database path: $H2_DATA_DIR/h2db.mv.db"
     echo "H2 console available at: http://localhost:8080/h2"
 fi

# Step 2: Build applications if enabled
if [ "$BUILD_APPS" = "true" ]; then
    cd $BASE_DIR
    echo "Building applications..."

    # Build Gradle Basic Demo
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        chmod +x gradlew
        ./gradlew build
        cd ..
    fi

    # Build Gradle Transformation
    if [ -d "gradle_transformation" ]; then
        cd gradle_transformation
        chmod +x gradlew
        ./gradlew build
        cd ..
    fi
fi

# Step 3: Start services if enabled
if [ "$START_SERVICES" = "true" ]; then
    cd $BASE_DIR
    echo "Starting services..."

    # Start Gradle Basic Demo Chat Server in background
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        chmod +x gradlew
        ./gradlew runServer &
        cd ..
    fi

    # Start Gradle Transformation Chat Server in background
    if [ -d "gradle_transformation" ]; then
        cd gradle_transformation
        chmod +x gradlew
        ./gradlew bootRun &
        cd ..
    fi

    echo "Services started. Access via forwarded ports (5000 for basic demo chat, 59001 for transformation chat)."
fi

echo "Automation script completed."