# CA5 - Part 1: Dockerizing Gradle Applications

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


## Docker Multi-Stage Build & Comparison with Version V1

Traditionally in v1, Docker contains all the tools needed to build and run the application, for example:

- Git
-Gradle
- Complete source code
- Cache and build artifacts

This results in very large (>1 GB) and less secure images. With multi-stage build, we create two images within the same Dockerfile. There are two stages: the build stage, which contains heavy tools such as git, gradle and certain source code from one or more projects and there is also the runtime stage, that is, a stage that only contains the final .jar file + JRE. Therefore, the final image is much smaller, and the fact is that nothing from the build goes into production.


The Dockerfile file looks like this:

```bash
#-------------- Step 1: Build---------------------------#
FROM eclipse-temurin:17 AS builder

RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git /app

WORKDIR /app/CA2/Part1/gradle_basic_demo

RUN chmod +x ./gradlew
RUN ./gradlew jar


#-------------------- Step 2: Runtime----------------------#

FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=builder /app/CA2/Part1/gradle_basic_demo/build/libs/basic_demo-0.1.0.jar /app/app.jar
EXPOSE 59001

CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
```


As already mentioned, there are two stage phases. In this first phase, the *FROM eclipse-temurin:17 AS builder* command chooses the base image with JDK 17 and the AS builder gives this stage a name and is then used in *COPY --from=builder*. 
Then apt is updated and git is installed. Next, the repository of this course unit is cloned to /app within the container. 
Subsequently, using the *WORKDIR* command, docker runs the command to enter the folder where the gradle project designated by *gradle_basic_demo* is located. From this folder, all *RUN* are executed in this folder.

The last two commands in the stage build phase, the first gives *gradlew* execution permission, and finally, when running *./gradlew jar* the file *basic_demo-0.1.0.jar* is generated within the *libs* folder in the path */app/CA2/Part1/gradle_basic_demo/build/libs/*.

In the runtime phase, you start with a new image based only on JRE 17 (runtime, lighter than the JDK) and everything that was installed in the builder (i.e.: git, gradle, code) does not go here. Then, the folder was defined as a working folder within the final image. Subsequently, only the build stage JAR is copied. The code instruction *--from=builder* copies files from the first stage image.


Basically, we copied the .jar file generated by gradle and which is in */app/CA2/Part1/gradle_basic_demo/build/libs/* to the working folder designed */app* with the file generated/copied to that folder called *app.jar*. Therefore, we get what we want: only the JAR is included in the final image and nothing related to Gradle, Git or even the source code. Finally, the last two commands indicate that the application uses port 59001 (the chat server) and finally, the app starts and the command has the following meaning:

- java -cp app.jar: sets the classpath for the app.jar.
- basic_demo.ChatServerApp: application main class.
- "59001": argument passed to the program (server port).

The same realization logic was applied to the *gradle_transformation* project. Note that the port changes to 8080, as this is a service (REST API) that is accessed on the web. The dockerfile code is as follows:

```bash
FROM eclipse-temurin:17 AS builder
RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git /app

WORKDIR /app/CA2/Part2/GradleProject_Transformation

RUN chmod +x ./gradlew

RUN ./gradlew bootJar

CMD ["java", "-jar", "build/libs/GradleProject_Transformation.jar"]


FROM eclipse-temurin:17

COPY --from=builder /app/CA2/Part2/GradleProject_Transformation/build/libs/GradleProject_Transformation.jar /app/app.jar

WORKDIR /app

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```
## Building Images

In the terminal, inside the CA5 folder, we execute:

```bash
docker build -t gradle_basic_demo:v1 -f gradle_basic_demo/v1/Dockerfile gradle_basic_demo/v1

docker build -t gradle_basic_demo:multi-stage -f multi_stage/gradle_basic_demo/Dockerfile multi_stage/gradle_basic_demo
```

The first command creates the image of version 1 (v1) of the gradle_basic_demo application, using a traditional Dockerfile located within the gradle_basic_demo/v1 folder.
This image includes the entire build environment within it (Gradle, Git, source code, dependencies), resulting in a larger and less optimized image. 

The second command creates the optimized image with multi-stage build, using a separate Dockerfile within multi_stage/gradle_basic_demo.
In this approach, the build occurs in a first stage, but only the final JAR file is included in the final image, removing unnecessary tools and code.

After compiling the two images, we run the **docker images** command, which immediately allows you to see the size/weight of the two images:

![alt text](image-1.png)

The difference in size between the two images is due to what each one carries internally:

| Image | Size | Reason |
| ------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `gradle_basic_demo:v1` | **3.1GB** | Contains *entire development environment*: Git, Gradle, dependencies, cache, source code, build tools, full JDK |
| `gradle_basic_demo:multi-stage` | **376MB** | Contains **only the final JAR + JRE needed to run the application**, eliminating build tools and artifacts |

To conclude:
- The v1 image is huge because it includes everything that was used to compile the application.
- The multi-stage image is small because it only includes what is necessary to run the application.

## Tagging and Publishing Images to Docker Hub

After building the Docker images for each application present in the project (gradle_basic_demo and gradle_transformation), appropriate tags were created for each one, following good versioning and deployment practices.

Tags allow you to easily identify each version of the image, distinguishing between the initial version (without optimization) and the version created using multi-stage build.


After building the images locally, we proceeded to create the tags:

```bash
docker tag gradle_basic_demo:v1 joaoaraujo1250525/gradle_basic_demo:v1
docker tag gradle_basic_demo:multi-stage joaoaraujo1250525/gradle_basic_demo:multi-stage
```
![alt text](image-3.png)

Now to publish, you must first log in to docker hub and run the command:

```bash
docker login
```

![alt text](image.png)

Images were published using the following commands:

```bash
docker push joaoaraujo1250525/gradle_basic_demo:v1
docker push joaoaraujo1250525/gradle_basic_demo:multi-stage
```

**gradle_basic_demo:v1 push:**

![alt text](image-2.png)

**gradle_basic_multi-stage:v1 push:**

![alt text](image-4.png)

# Part 2: Docker Compose with Database

## Running the Application

To start the application:

```bash
docker-compose up
```

To stop the application:

```bash
docker-compose down
```

```docker
version: "3.8"

services:
  db:
    image: oscarfonts/h2
    container_name: h2-server
    ports:
      - "1521:1521"     
      - "81:81"         
    environment:
      H2_OPTIONS: "-tcp -tcpAllowOthers -web -webAllowOthers -baseDir /opt/h2-data -ifNotExists"
    restart: always
    volumes:
      - h2-data:/opt/h2-data
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O - http://localhost:81 || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    build: ./gradle_transformation
    container_name: web-server
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:h2:tcp://db:1521/test
      - SPRING_DATASOURCE_USERNAME=sa
      - SPRING_DATASOURCE_PASSWORD=
      - SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver
      - SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.H2Dialect
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
    depends_on:
      db:
        condition: service_healthy

volumes:
  h2-data:
```

## Health Check

We added a `healthcheck` to the `db` service to ensure it is fully ready before the `web` service starts.

The check uses `wget` to ping the web console port (81).

The `web` service uses `depends_on` with `condition: service_healthy` to wait for the database.

## Data Persistence:
We defined a named volume `h2-data`.

This volume is mounted to `/opt/h2-data` inside the `db` container.

We configured `H2_OPTIONS` with `-baseDir /opt/h2-data` to ensure the database files are stored in the volume.
This ensures that data persists even if the container is removed or restarted.

## Network Connectivity

Docker Compose automatically creates a default network for the services. This allows containers to communicate with each other using their service names as hostnames.

- **web**: Can resolve the database at `db:1521` or `db:81`.
- **db**: Can resolve the web service at `web:8080`.

This eliminates the need for manual IP management and ensures reliable communication between services.

## Verification

### Network Connectivity
We verified that the containers can communicate with each other using their service names as hostnames.

**1. Web to DB**
The `web` container can resolve `db` and connect to port 81.

```bash
docker exec web-server curl -v http://db:81
```

**2. DB to Web**
The `db` container can resolve `web` and connect to port 8080.

```bash
docker exec h2-server curl http://web:8080
```

![alt text](image-6.png)

### Persistence
We verified persistence by creating a file in the volume, restarting the container, and confirming the file still existed.

1. Create a test file:
```bash
docker exec h2-server touch /opt/h2-data/test_persistence.txt
```

2. Restart the database container:
```bash
docker-compose restart db
```

3. Check if the file still exists:
```bash
docker exec h2-server ls -l /opt/h2-data/test_persistence.txt
```

![alt text](image-5.png)

### Environment Variables
We verified that the environment variables are correctly passed to the application container.

```bash
docker exec web-server env
```

![alt text](image-7.png)

## Push to Docker Hub

To publish the images to Docker Hub, we first need to tag them with our username and then push them.

### 1. Tagging Images

We tag the `web` image (built by compose) and the `db` image (used by compose).

**Web Image:**
```bash
docker tag part2-web mariozito/part2-web:latest
```

**DB Image:**
```bash
docker tag oscarfonts/h2 mariozito/part2-db:latest
```

![Insert screenshot of tagging images here]

### 2. Pushing Images

**Push Web Image:**
```bash
docker push mariozito/part2-web:latest
```

**Push DB Image:**
```bash
docker push mariozito/part2-db:latest
```

![alt text](image-8.png)

![alt text](image-9.png)