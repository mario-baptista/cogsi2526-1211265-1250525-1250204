# CA5: Dockerizing Gradle Applications

## Projects Overview

This assignment involves two Gradle-based projects:

- **gradle_basic_demo**: A simple chat server application built with Gradle, demonstrating basic Java application containerization.
- **gradle_transformation**: A Spring Boot web application that was originally a Maven project, transformed to use Gradle build system. It provides web services on port 8080.

Both projects implement two Docker containerization strategies to compare build approaches.

## Docker Strategies

### ChatApp Version 1:
- **Approach**: Clone the repository and compile the application directly within the Docker container.

```dockerfile
FROM eclipse-temurin:17

COPY . /app

WORKDIR /app

RUN ./gradlew jar

EXPOSE 59001

CMD ["java", "-cp", "build/libs/basic_demo-0.1.0.jar", "basic_demo.ChatServerApp", "59001"]
```
**Explanation**: Uses Eclipse Temurin JDK 17. Copies the entire project source, builds the JAR inside the container using Gradle, exposes port 59001, and runs the chat server application.

### ChatApp Version 2:
- **Approach**: Build the application on the host machine and copy the resulting JAR file into the Docker image.

```dockerfile
FROM eclipse-temurin:17

COPY basic_demo-0.1.0.jar /app/app.jar

WORKDIR /app

EXPOSE 59001

CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
```
**Explanation**: Uses Eclipse Temurin JDK 17. Copies a pre-built JAR file from the host, exposes port 59001, and runs the chat server application. No build step inside the container.

### Spring Application Version 1: 

- **Approach**: Clone the repository and compile the application directly within the Docker container.
```dockerfile
FROM eclipse-temurin:17

COPY . /app

WORKDIR /app

RUN ./gradlew bootJar

EXPOSE 8080

CMD ["java", "-jar", "build/libs/GradleProject_Transformation.jar"]
```
**Explanation**: Uses Eclipse Temurin JDK 17. Copies the entire Spring Boot project, builds the boot JAR inside the container, exposes port 8080, and runs the web application using `java -jar`.

### Spring Application Version 2:
- **Approach**: Build the application on the host machine and copy the resulting JAR file into the Docker image.
- 
```dockerfile
FROM eclipse-temurin:17

COPY GradleProject_Transformation.jar /app/app.jar

WORKDIR /app

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```
**Explanation**: Uses Eclipse Temurin JDK 17. Copies a pre-built Spring Boot JAR from the host, exposes port 8080, and runs the web application. No build step inside the container.

![alt text](<Screenshot 2025-11-11 at 19.34.48.png>)

![alt text](<Screenshot 2025-11-11 at 19.34.54.png>) 

![alt text](<Screenshot 2025-11-11 at 19.49.24.png>) 

## Docker History Analysis

Using `docker history <image>` to inspect layer composition:

![alt text](<Screenshot 2025-11-11 at 19.36.29.png>) 
![alt text](<Screenshot 2025-11-11 at 19.36.10.png>) 

### Image Size Comparison
- **Version 1**: Typically larger due to inclusion of:
  - Gradle wrapper and dependencies
  - Source code and intermediate build artifacts
  - Full JDK for compilation
- **Version 2**: Smaller and more efficient:
  - Only contains the runtime JRE
  - Single JAR file
  - Minimal base image layers

### Layer Composition Differences
- **Version 1** shows multiple layers for cloning, dependency resolution, and compilation steps.
- **Version 2** has fewer layers, primarily focused on copying the JAR and setting up the runtime.

### Performance Implications
- Version 1: Slower builds but consistent environments.
- Version 2: Faster image creation and smaller distribution size.

Both approaches were implemented for both demo projects to compare the methodologies in practice.

**Key Differences**: Version 1 Dockerfiles include the full source and build process, resulting in larger images with build dependencies. Version 2 Dockerfiles are simpler, copying only the final JAR, leading to smaller, faster images. The basic_demo uses classpath execution, while transformation uses executable JARs.