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