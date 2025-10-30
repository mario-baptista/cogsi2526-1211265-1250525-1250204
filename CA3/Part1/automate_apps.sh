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

# Step 1: Clone repositories if enabled
if [ "$CLONE_REPOS" = "true" ]; then
    echo "Cloning/copying repositories..."
    git clone https://github.com/spring-projects/spring-petclinic.git || echo "Spring PetClinic already exists"
    # Copy payroll from local repo (assuming main repo is cloned)
    if [ -d "../cogsi2526-1211265-1250525-1250204/CA2/AlternativeSolutionP1P2CA2/payroll" ]; then
        cp -r ../cogsi2526-1211265-1250525-1250204/CA2/AlternativeSolutionP1P2CA2/payroll ./payroll_app || echo "Payroll app already exists"
    else
        echo "Payroll app not found in local repo, cloning tut-rest as base"
        git clone https://github.com/spring-guides/tut-rest.git payroll_app || echo "Payroll app (tut-rest) already exists"
    fi
    git clone https://github.com/lmpnogueira/gradle_basic_demo.git || echo "Gradle Basic Demo already exists"
fi

# Step 2: Build applications if enabled
if [ "$BUILD_APPS" = "true" ]; then
    echo "Building applications..."
    
    # Build Spring PetClinic
    if [ -d "spring-petclinic" ]; then
        cd spring-petclinic
        ./mvnw clean install -DskipTests  # Skip tests for speed
        cd ..
    fi
    
    # Build Payroll (assuming tut-rest is the base)
    if [ -d "payroll_app" ]; then
        cd payroll_app
        ./mvnw clean install -DskipTests
        cd ..
    fi
    
    # Build Gradle Basic Demo
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        gradle build
        cd ..
    fi
fi

# Step 3: Start services if enabled
if [ "$START_SERVICES" = "true" ]; then
    echo "Starting services..."
    
    # Start Spring PetClinic in background
    if [ -d "spring-petclinic" ]; then
        cd spring-petclinic
        ./mvnw spring-boot:run &
        cd ..
    fi
    
    # Start Payroll in background
    if [ -d "payroll_app" ]; then
        cd payroll_app
        ./mvnw spring-boot:run &
        cd ..
    fi
    
    # Start Gradle Chat Server in background
    if [ -d "gradle_basic_demo" ]; then
        cd gradle_basic_demo
        gradle runServer &
        cd ..
    fi
    
    echo "Services started. Access via forwarded ports (8080 for APIs, 5000 for chat)."
fi

echo "Automation script completed."