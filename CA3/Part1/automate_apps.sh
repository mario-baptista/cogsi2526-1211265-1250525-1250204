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
    rm -rf ./spring-petclinic
    cp -r ../../CA1/spring-framework-petclinic ./spring-petclinic
    rm -rf ./payroll_app
    cp -r ../../CA2/AlternativeSolutionP1P2CA2/payroll ./payroll_app
    rm -rf ./gradle_basic_demo
    cp -r ../../CA2/Part1/gradle_basic_demo ./gradle_basic_demo
fi

# Step 2: Build applications if enabled
if [ "$BUILD_APPS" = "true" ]; then
    cd $BASE_DIR
    echo "Building applications..."
    
    # Build Spring PetClinic
    if [ -d "spring-petclinic" ]; then
        cd spring-petclinic
        sudo chmod +x mvnw
        ./mvnw clean install -DskipTests  # Skip tests for speed
        cd ..
    fi

    # Build Payroll
    #if [ -d "payroll_app" ]; then
    #    cd payroll_app
    #    sudo chmod +x mvnw
    #    ./mvnw clean install -DskipTests
    #    cd ..
    #fi

    # Build Gradle Basic Demo
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        #sudo chmod +x gradlew
        gradlew build
        cd ..
    fi
fi

# Step 3: Start services if enabled
if [ "$START_SERVICES" = "true" ]; then
    cd $BASE_DIR
    echo "Starting services..."
    
    # Start Spring PetClinic in background
    if [ -d "spring-petclinic" ]; then
        cd spring-petclinic
        sudo chmod +x mvnw
        ./mvnw spring-boot:run &
        cd ..
    fi

    # Start Payroll in background
    #if [ -d "payroll_app" ]; then
    #    cd payroll_app
    #    sudo chmod +x mvnw
    #    ./mvnw spring-boot:run &
    #    cd ..
    #fi

    # Start Gradle Chat Server in background
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        sudo chmod +x gradlew
        gradlew runServer &
        cd ..
    fi
    
    echo "Services started. Access via forwarded ports (8080 for APIs, 5000 for chat)."
fi

echo "Automation script completed."