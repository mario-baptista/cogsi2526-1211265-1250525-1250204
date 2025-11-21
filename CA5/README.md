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

Before starting the assignment, I had to pick one specific container tool to replace Docker. There are a few options out there (Podman, LXC/LXD, systemd-nspawn, containerd, etc.), after researching a bit, Podman ended up being the most logical choice.
This assignment required me to design, analyze, compare, and implement an alternative container management solution that does not rely on Docker. The goal was not just to replace Docker with another tool but to understand:

-How the alternative tool functions

-How it compares to Docker 

-How the alternative tool can be used to achieve the exact same goals of the original assignment

-How to implement the design in a working setup

To meet all these requirements, I selected Podman as the alternative container engine. Podman is widely recognized as the most Docker compatible substitute while offering additional security and architectural benefits.

### 2. Why I chose Podman

Out of all the Docker alternatives available today, Podman made the most sense for this assignment.
The main reasons were:

1.It doesn’t use a daemon, which makes it safer.
Docker relies heavily on a background service called the Docker daemon,while Podman does not have this, and it just runs the containers directly without needing a separate running process

This gives Podman two advantages:

-Better security (no daemon running all the time)

-Fewer failure points (if a service crashes, it doesn’t bring containers down)

2.It supports rootless containers.
This means containers can run without requiring admin permissions while Docker can’t always do this properly, especially on Windows.
This matters because running containers as root can sometimes be risky, and Podman avoids that by design.

3.It follows the same OCI standards as Docker.
This basically means Podman follows the same container standards that Docker does. Because of this, Podman can:

-use Docker images

-push/pull from Docker registries

-run containers using the same image format

So there is no need to convert anything and the transition is smooth.

4.It can use the same Dockerfiles and almost the same commands
This was the main reason choosing Podman made life easier for this assignment, since the goal wasn’t to redesign the whole workflow but just use an alternative tool, this compatibility was helpful

Basically, Podman works very similarly to Docker, but with a different architecture and some extra advantages.
Because of this, I could follow almost the same workflow as the Docker version of the assignment, just using Podman commands instead

| Feature                  | Docker	             | Podman	           | Which is Better? |
| ------------------------ | ------------------- | ----------------- | ---------------  | 
| Runs daemon              | Yes (Docker Daemon) | No daemon	       | Podman is safer  |
| Rootless                 | containers	 Limited | Full rootless	   | Podman           |
| Dockerfile support	     | Yes	               | Yes	             | Equal            |
| Docker CLI compatibility | Native	             | Mostly compatible | Almost equal     |
| Compose support	         | docker‑compose	     | podman‑compose	   | Equal            |
| Security	               | Medium	             | High	             | Podman           |

In conclusion:

-Podman is more secure (no daemon, rootless)

-Podman is Docker‑compatible (same commands)

-Podman uses systemd integration, better for servers

This makes Podman a good alternative solution to docker

The assignment required designing how the alternative tool (Podman) could solve the same goals as the original Docker solution.

- Build the application with podman build
- Run the application with podman run -p 8080:8080
- Run a database with Podman container running H2
- Connect application with database usingg same networking logic as Docker


### 3. Installing Podman

Before I could replace Docker with Podman, I needed to install all the tools required to run containers on my machine.
This part is important because Podman by itself is only the container engine and some extra tools are needed to make everything work smoothly, especially for scripting or running multi container setups.

Podman is the main tool I needed, so the first thing I did was install it using the official package command for my system

<img width="1073" height="207" alt="img1" src="https://github.com/user-attachments/assets/69b3e44b-3d6b-4d62-bce9-bd9c0aee98be" />

This ensures:

-podman - the engine (to run and build containers), the CLI interface (for Podman commands), the tools required for rootless mode

-pip / curl / jq - tools needed for scripts

-podman-compose - Docker‑Compose equivalent for Podman 
This tool behaves almost the same as docker-compose and allows me to run multiple containers together,combine the Spring Boot app + H2 database,treat the entire stack as a single environment

Afterwards we check the installation is complete

<img width="377" height="257" alt="img2" src="https://github.com/user-attachments/assets/80d564e7-0f51-4f69-ad84-aa14cdbeda6a" />

This step matters because if Podman is not properly installed, the later steps (building images, running containers) will fail

### 4. Building the application with Podman

We replaced Docker builds with Podman builds, because Podman can build Dockerfiles directly without changing them.
In Docker, you normally build an image like this:

```bash
docker build -t gradle_transformation
```
With Podman i simply replaced docker with :
<img width="1461" height="142" alt="img3" src="https://github.com/user-attachments/assets/dd82e819-8e94-4c45-ad74-8adf0c748514" />
This command reads the Dockerfile in the current folder then it downloads the required base image while compiling the code. After this it packages the Spring Boot application and creates a container image

Podman handled the entire build process smoothly because it understands Dockerfiles so this means zero configuration changes were needed.

While the image was building, I could see logs showing:

-dependencies being downloaded

-the Spring Boot project being compiled

-files being copied into the container

-the final image being created

The important part is that Podman produced the exact same final image that Docker would have produced but just with a different engine behind it and this allowed it to produce the container image

![img4](https://github.com/user-attachments/assets/59ed2034-2111-4797-bcaa-61c99a8326e4)

### 5. Running the application container

After building the Spring Boot application image with Podman, the next step was to actually run the container and confirm that the app starts correctly.
This part is basically the equivalent of what we usually do with Docker’s "docker run", but now we do it with Podman.

<img width="1377" height="421" alt="img9" src="https://github.com/user-attachments/assets/be512344-9bbb-4590-a76c-bb13389a4c1a" />

This command:

-starts a container from the image I built earlier

-maps port 8080 inside the container to 8080 on the host

-lets me access the Spring Boot app from my browser

-shows the Spring Boot logs directly in the terminal
This behavior is exactly the same as Docker, which is why Podman is considered Docker compatible

Once the logs showed everything was running, I opened:

```bash
http://localhost:8080
```

The Spring Boot app loaded the same way it did in the Docker version of the assignment.
This proves Podman can run the application fully by itself, without relying on Docker at all.

### 6. Running H2 database inside Podman

The original Docker based project used a Docker container to run an H2 database but since Docker wasn’t allowed in this assignment, I had to recreate the same environment using only Podman.

That meant:

-setting up H2 as a containerized service,

-making sure the database persisted somewhere, and ensuring that the Spring Boot app could still connect to it.

So I built the same setup using Podman.

#### 6.1 Create folder for persistent H2 data

Before starting the H2 server, I first created a local folder where the database files would be stored
<img width="1373" height="208" alt="img7" src="https://github.com/user-attachments/assets/328f5003-eda1-4f38-93e3-e46b4f7eff0b" />

This step matters because:

-without a mounted folder, H2 would store everything inside the container

-when the container stops, all data would be lost

By creating a local directory, I ensured that the H2 data survives restarts, just like with a real database container.

#### 6.2 Download the H2 database JAR

H2 is a lightweight Java database, and running it requires its JAR file.

So I downloaded it manually using this commandd
<img width="1467" height="126" alt="img10" src="https://github.com/user-attachments/assets/e6c6c444-e460-4e7a-821a-c68b97515597" />

This step ensures that:

-the container can actually run the H2 server

-the database engine exists in the environment

-Podman doesn’t have to pull anything from Docker Hub 

Basically, this was preparing the tools needed to start H2 in standalone mode.

#### 6.3 Start the H2 server

Once the folder and the JAR were ready, I used Podman to start the H2 server.
This shows the command running:
<img width="1377" height="421" alt="img9" src="https://github.com/user-attachments/assets/5db61385-7132-4667-8043-8e2a70921abd" />

Inside the container, H2 starts and:

-opens an HTTP console on port 8082

-listens for JDBC connections

-stores its files in the mounted directory

-behaves exactly as it would in a Docker container

This step recreates the same database environment as the Docker version of the assignment.

### 7. Connecting to H2

After getting the H2 server running inside Podman, the next thing I needed to do was actually connect to it.
This step is important because running the database alone doesn’t prove anything so the Spring Boot app needs to be able to use it, and I also needed to check if the H2 interface was accessible.

So, once H2 was running, I did two things:

##### 1.Open the H2 Web Console

H2 provides a small web interface that runs on port 8082.
So I opened the browser and went to:

```bash
http://localhost:8082
```

![imgh2_webConsole](https://github.com/user-attachments/assets/18833e6b-b72e-43f1-8f20-64b04ba6b031)

This page lets you:

-verify that H2 actually started correctly

-log into the database

-run SQL queries

-check if the mounted folders are working correctly

Just being able to load this page meant that Podman exposed the ports correctly and the H2 service was working exactly the same as it would in Docker.

##### Log into the H2 Database
Once the H2 console loaded, I used the login details

![img_h2LoggedIn](https://github.com/user-attachments/assets/1b9bb31a-f5af-4b0b-b85f-3c9ebdf151e6)

Logging in confirmed:

-the H2 server is running

-the directory where data is stored is configured correctly

-the JDBC URL is correct








