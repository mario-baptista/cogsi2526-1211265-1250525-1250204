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

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git /app

WORKDIR /app/CA2/Part1/gradle_basic_demo

RUN chmod +x ./gradlew

RUN ./gradlew jar

EXPOSE 59001

CMD ["java", "-cp", "build/libs/basic_demo-0.1.0.jar", "basic_demo.ChatServerApp", "59001"]
```
### Line-by-Line Breakdown:
- FROM eclipse-temurin:17: Starts with a full JDK 17 image needed for compilation
- RUN apt-get update && apt-get install -y git: Installs Git to clone repository
- RUN git clone...: Downloads entire source history and code into /app
- WORKDIR...: Sets working directory to the project folder
- RUN chmod +x ./gradlew: Makes Gradle wrapper executable
- RUN ./gradlew jar: Downloads Gradle, all dependencies, compiles code, and creates JAR
- EXPOSE 59001: Documentation-only port declaration (It informs users and other containers which ports the application inside the container is intended to use, it doesnt export the port).
- CMD...: Runs the chat server

### ChatApp Version 2:
- **Approach**: Build the application on the host machine and copy the resulting JAR file into the Docker image.

```dockerfile
FROM eclipse-temurin:17

COPY basic_demo-0.1.0.jar /app/app.jar

WORKDIR /app

EXPOSE 59001

CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
```
### Line-by-Line Breakdown:
- FROM eclipse-temurin:17: Uses JDK image
- COPY...: File copy from host build context into container
- WORKDIR /app: Sets working directory
- EXPOSE 59001: Port declaration
- CMD...: Runs the pre-built JAR

### Spring Application Version 1: 

- **Approach**: Clone the repository and compile the application directly within the Docker container.
```dockerfile
FROM eclipse-temurin:17

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git /app

WORKDIR /app/CA2/Part2/GradleProject_Transformation

RUN chmod +x ./gradlew

RUN ./gradlew bootJar

EXPOSE 8080

CMD ["java", "-jar", "build/libs/GradleProject_Transformation.jar"]
```

### Line by line breakdown:

- FROM eclipse-temurin:17: Starts with a full JDK 17 image needed for compilation
- RUN apt-get update && apt-get install -y git: Installs Git to clone repository
- RUN git clone...: Downloads entire source history and code into /app
- WORKDIR...: Sets working directory to the project folder
- RUN chmod +x ./gradlew: Makes Gradle wrapper executable
- RUN ./gradlew jar: Downloads Gradle, all dependencies, compiles code, and creates JAR
- EXPOSE 8080: Documentation-only port declaration.
- CMD...: Runs the spring application


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
### Line-by-Line Breakdown:
- FROM eclipse-temurin:17: Uses JDK image
- COPY...: File copy from host build context into container
- WORKDIR /app: Sets working directory
- EXPOSE 8080: Port declaration
- CMD...: Runs the pre-built JAR



### Build

```bash
docker build -t gradle_basic_demo_v1 .
docker build -t gradle_transformation_v1 .
docker build -t gradle_transformation_v2 .
docker build -t gradle_basic_demo_v2 .
```

### Run

```bash
docker run -d -p 59001:59001 --name basic_demo_v1 gradle_basic_demo_v1
docker run -d -p 59002:59001 --name basic_demo_v2 gradle_basic_demo_v2
docker run -d -p 8080:8080 --name transformation_v1 gradle_transformation_v1
docker run -d -p 8081:8080 --name transformation_v2 gradle_transformation_v2
```

### Port Mapping:
- Chat apps: 59001→59001 (v1) and 59002→59001 (v2)
- Spring apps: 8080→8080 (v1) and 8081→8080 (v2)


![alt text](<Screenshot 2025-11-11 at 21.12.07.png>)

## Docker History Analysis

Using `docker history <image>` to inspect layer composition:

![alt text](<Screenshot 2025-11-11 at 21.19.55.png>) 
![alt text](<Screenshot 2025-11-11 at 21.19.50.png>)

### Image Size Comparison
- **Version 1**: Typically larger due to inclusion of:
  - Git
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

**Key Differences**: Version 1 Dockerfiles include the full source and build process, resulting in larger images with build dependencies. Version 2 Dockerfiles are simpler, copying only the final JAR, leading to smaller, faster images.

| Version | Characteristics                                                 | Size Implication          |
| ------- | --------------------------------------------------------------- | ------------------------- |
| 1       | Full source, Gradle wrapper, Git, dependencies, build artifacts | Larger images             |
| 2       | Only runtime + JAR                                              | Smaller, efficient images |


## Alternative Solution

### 1. Introduction

This assignment required me to design, analyze, compare, and implement an alternative container management solution that does not rely on Docker. The goal was not just to replace Docker with another tool but to understand:

-How the alternative tool functions

-How it compares to Docker conceptually and technically

-How the alternative tool can be used to achieve the exact same goals of the original assignment

-How to implement the design in a real working setup

To satisfy all these requirements, I selected Podman as the alternative container engine. Podman is widely recognized as the most Docker compatible substitute while offering additional security and architectural benefits.

### 2. Why I chose Podman

Podman is a container engine created by Red Hat. Unlike Docker, Podman:

-Runs daemonless (no background service)

-Can run containers rootless, improving security

-Uses OCI standards (Open Container Initiative)

-Is Docker‑compatible (can use Dockerfiles, same commands)

Podman is therefore a perfect alternative to Docker for modern containerized development.

### 3. Installing Podman (Alternative to Docker)

Before doing anything, I had to install Podman using:

<img width="1073" height="207" alt="img1" src="https://github.com/user-attachments/assets/69b3e44b-3d6b-4d62-bce9-bd9c0aee98be" />

This ensures:

-podman → main container engine

-pip / curl / jq → tools needed for scripts

-podman-compose → Docker‑Compose equivalent for Podman

Afterwards we check the installation is complete

<img width="377" height="257" alt="img2" src="https://github.com/user-attachments/assets/80d564e7-0f51-4f69-ad84-aa14cdbeda6a" />


### 4. Building the application with Podman

We replaced Docker builds with Podman builds, because Podman can build Dockerfiles directly without changing them.


<img width="1461" height="142" alt="img3" src="https://github.com/user-attachments/assets/dd82e819-8e94-4c45-ad74-8adf0c748514" />

This produced the container image.
![img4](https://github.com/user-attachments/assets/59ed2034-2111-4797-bcaa-61c99a8326e4)

### 5. Running the application container

After building, we run it:

<img width="1377" height="421" alt="img9" src="https://github.com/user-attachments/assets/be512344-9bbb-4590-a76c-bb13389a4c1a" />

This:

-Starts Spring Boot

-Exposes port 8080 on the host

-Shows the application boot logs


### 6. Running H2 database inside Podman

Docker was not allowed, so we created an H2 server entirely using Podman. We ran H2 in Podman so the environment mirrors a real containerized stack

So the Spring Boot app can access a persistent DB

#### 6.1 Create folder for persistent H2 data
<img width="1373" height="208" alt="img7" src="https://github.com/user-attachments/assets/328f5003-eda1-4f38-93e3-e46b4f7eff0b" />

#### 6.2 Download the H2 database JAR
<img width="1467" height="126" alt="img10" src="https://github.com/user-attachments/assets/e6c6c444-e460-4e7a-821a-c68b97515597" />

#### 6.3 Start the H2 server
<img width="1377" height="421" alt="img9" src="https://github.com/user-attachments/assets/5db61385-7132-4667-8043-8e2a70921abd" />

### 7. Connecting to H2

Once H2 server was running, we navigated to:

http://localhost:8082

Then we logged in:

![imgh2_webConsole](https://github.com/user-attachments/assets/18833e6b-b72e-43f1-8f20-64b04ba6b031)

![img_h2LoggedIn](https://github.com/user-attachments/assets/1b9bb31a-f5af-4b0b-b85f-3c9ebdf151e6)


### 8. Comparison between Podman vs Docker

Feature                  | Docker	             | Podman	           |Which is Better?

------------------------------------------------------------------------------------
Runs daemon              | Yes (Docker Daemon) | No daemon	       | Podman is safer

Rootless                 | containers	 Limited | Full rootless	   | Podman

Dockerfile support	     | Yes	               | Yes	             | Equal

Docker CLI compatibility | Native	             | Mostly compatible | Almost equal

Compose support	         | docker‑compose	     | podman‑compose	   | Equal

Security	               | Medium	             | High	             | Podman

In conclusion:

-Podman is more secure (no daemon, rootless)

-Podman is Docker‑compatible (same commands)

-Podman uses systemd integration, better for servers

This makes Podman a good alternative solution to docker

### 9. How Podman solves the same goals 

The assignment required designing how the alternative tool (Podman) could solve the same goals as the original Docker solution.

- Build the application with podman build
- Run the application with podman run -p 8080:8080
- Run a database with Podman container running H2
- Connect application with database usingg same networking logic as Docker




