#!/usr/bin/env bash

# Automate cloning, building, and starting applications for CA3
# Controlled by environment variables

set -e  # Exit on error

# Default values for env vars (can be overridden)
CLONE_REPOS=${CLONE_REPOS:-false}
BUILD_APPS=${BUILD_APPS:-false}
START_SERVICES=${START_SERVICES:-false}
VM_TYPE=${VM_TYPE:-app}

echo "Starting automation script..."
echo "VM_TYPE: $VM_TYPE"
echo "CLONE_REPOS: $CLONE_REPOS"
echo "BUILD_APPS: $BUILD_APPS"
echo "START_SERVICES: $START_SERVICES"

BASE_DIR=/home/vagrant/cogsi2526-1211265-1250525-1250204/CA3/Part2

# Step 1: Clone repositories if enabled
if [ "$CLONE_REPOS" = "true" ]; then
    echo "Cloning main repository..."
    cd /home/vagrant
    git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git || echo "Main repo already exists"
    cd $BASE_DIR

    if [ "$VM_TYPE" = "app" ]; then
        echo "Copying gradle_transformation for app VM..."
        rm -rf ./gradle_transformation
        cp -r ../../CA2/Part2/GradleProject_Transformation ./gradle_transformation

        # Configure H2 server mode for gradle_transformation
        APP_PROPERTIES="$BASE_DIR/gradle_transformation/src/main/resources/application.properties"

        echo "=== Setting up H2 server mode for gradle_transformation ==="
        # Configure to connect to db VM
        if ! grep -q "spring.datasource.url" "$APP_PROPERTIES"; then
            cat >> "$APP_PROPERTIES" <<EOF

# =========================================
# H2 Server Mode Database Configuration
# =========================================
spring.datasource.url=jdbc:h2:tcp://192.168.33.12:9092/h2db;DB_CLOSE_DELAY=-1
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
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
        echo "H2 server mode configured to connect to db VM at 192.168.33.12:9092"
    elif [ "$VM_TYPE" = "db" ]; then
        echo "Preparing H2 server for db VM..."
        # Create data folder in synced directory
        SYNC_DIR="/vagrant"
        H2_DATA_DIR="$SYNC_DIR/h2-data"
        sudo mkdir -p "$H2_DATA_DIR"
        sudo chmod 777 "$H2_DATA_DIR"
        echo "H2 data directory: $H2_DATA_DIR"
    fi
fi

# Step 2: Build applications if enabled
if [ "$BUILD_APPS" = "true" ]; then
    cd $BASE_DIR
    echo "Building applications..."

    if [ "$VM_TYPE" = "app" ]; then
        # Build Gradle Transformation
        if [ -d "gradle_transformation" ]; then
            cd gradle_transformation
            chmod +x gradlew
            ./gradlew build
            cd ..
        fi
    fi
fi

# Step 3: Start services if enabled
if [ "$START_SERVICES" = "true" ]; then
    cd $BASE_DIR
    echo "Starting services..."

    if [ "$VM_TYPE" = "app" ]; then
        # Wait for H2 server to be ready
        echo "Waiting for H2 database server to be ready..."
        while ! nc -z 192.168.33.12 9092; do
            sleep 2
        done
        echo "H2 server is ready."

        # Start Gradle Transformation in background
        if [ -d "gradle_transformation" ]; then
            cd gradle_transformation
            chmod +x gradlew
            ./gradlew bootRun &
            cd ..
        fi
        echo "App services started. Access via forwarded port 8080."
    fi  # <-- ESTA LINHA FALTAVA!

    if [ "$VM_TYPE" = "db" ]; then
      echo "Configuring firewall (ufw) to secure the H2 database..."

      # Install UFW if it is not already installed
      sudo apt-get update -y
      sudo apt-get install -y ufw

      # Set secure default policies
      sudo ufw default deny incoming
      sudo ufw default allow outgoing

      # Allow SSH (remote access)
      sudo ufw allow 22/tcp

      # Allow only the app VM (192.168.33.11) to access the H2 port
      sudo ufw allow from 192.168.33.11 to any port 9092 proto tcp

      echo "y" | sudo ufw enable

      # Start H2 server in background
      SYNC_DIR="/vagrant"
      H2_DATA_DIR="$SYNC_DIR/h2-data"
      java -cp /usr/local/bin/h2.jar org.h2.tools.Server -tcp -tcpPort 9092 -tcpAllowOthers -ifNotExists -baseDir "$H2_DATA_DIR" &
      echo "H2 database server started on port 9092 and restricted to app VM."
    fi
fi

echo "Automation script completed."
