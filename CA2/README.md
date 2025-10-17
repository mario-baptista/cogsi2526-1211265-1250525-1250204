# CA2 — Part 1


## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/lmpnogueira/gradle_basic_demo.git
   cd REPO/CA2/part1
   ````

## Adding the runServer Task

In the `build.gradle` file, add the following code:


```java
task runServer(type:JavaExec, dependsOn: classes){
    group = "DevOps"
    description = "Launches a chat server that listens on port 59001 "
  
    classpath = sourceSets.main.runtimeClasspath

    mainClass = 'basic_demo.ChatServerApp'

    args '59001'
}
```

Test the runServer task:

![alt text](<Screenshot 2025-10-08 at 19.00.31.png>)


## Adding a Unit Test

In the `build.gradle` file, add the following code:

```java
test {
    useJUnitPlatform()
    testLogging {
        events "passed", "skipped", "failed"
    }
}
```

In the folder `src/test/java/basic_demo`, add the following test:

```java
package basic_demo;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class SimpleTest {
    @Test
    void simpleTest() {
        assertEquals(2, 1 + 1);
    }
}
```

Test the unit test:

![alt text](<Screenshot 2025-10-08 at 19.03.26.png>)

## Adding the backup Task

In the `build.gradle` file, add the following code:

```java
task backup(type: Copy) {
    group = "DevOps"
    description = "Backs up source files to the backup directory"
  
    from 'src'
    into 'backup/src'
    include '**/*.java'
}
```

Test the backup task:

![alt text](<Screenshot 2025-10-08 at 19.04.47.png>)


## Adding the zipBackup Task


```java
tasks.register('zipBackup', Zip) {
    dependsOn tasks.named('backup')
    from 'backup/src'
    archiveFileName = "app-backup.zip"
    destinationDirectory = file("backup/zips")
}
```


## Running the zipBackup Task with backup Dependency

The following image illustrates the command ./gradlew zipBackup and its purpose: it first executes the backup task, then creates the app-backup.zip file, which is placed inside the /backup/zips folder.


![alt text](<executeziptask.png>)


## Explanation of Gradle Wrapper and JDK Toolchain

The Gradle wrapper is a small script contained in the project that ensures that all users and operating systems use the same version of Gradle without the need for manual installation. The *gradle-wrapper.properties* file contains the link to the specific version of Gradle used in the project in the *distributionUrl* field.
 
When the command **./gradlew build** is executed, Gradle checks whether the version indicated in *wrapper.properties* has already been downloaded to *~/.gradle/wrapper/dists/*. If it has not, it is downloaded automatically.
The Java Toolchain, on the other hand, is a modern feature of Gradle that ensures that the build uses the correct version of the JDK, even if other versions are installed on the machine.
In this project, the following code is contained in the *build.gradle* file:
```java
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
```
This code is nothing more than Gradle itself letting you know that it uses Java version 17 to compile and run this project.
When you run the command **./gradlew -q javaToolchain**, Gradle shows the following output:
![alt text](<outputgradlewjdktoolchain.png>)
In the first part of the output, Gradle presents two options:
- *Auto-detection: Enabled* -> which means that Gradle is configured to automatically detect the JDK versions that exist on the machine.
- *Auto-download: Enabled* -> which means that if Gradle cannot find a JDK version compatible with what is defined in the toolchain, Gradle automatically downloads the correct version without the user having to install it manually.

The second part of the output shows the JDK version that Gradle is using to compile and execute the project. And the following attributes are listed:
- The name Eclipse Temurin, which identifies the JDK distribution. Previously, version 17 was defined in the *build.gradle* file, and what happens is that Gradle automatically downloads this *Eclipse Temurin* distribution, which is based on JDK version 17.
- The *Location* field, which shows the path where Gradle automatically downloaded and installed the JDK within the */.gradle/jdks* folder itself.
- The *Language Version* field, which indicates the version of the Java language used to compile the code.
- The *Vendor* field, which shows the supplier of the JDK distribution.
- The *Architecture* field, which indicates that the JDK is for use on 64-bit systems.
- The *Is JDK* field, which displays a Boolean value of *true*, confirming that this package is indeed a JDK.
- Finally, the *Detected by* field, which simply indicates that Gradle automatically installed the JDK.


Before concluding this explanation, it should be noted that the operating system on which Gradle was installed was Ubuntu and, as can be seen in the image above this text, the JDK version on the operating system is 21, and Gradle ended up being intelligent, and based on what was written in the *build.gradle* file, it ended up installing the appropriate version itself. Therefore, the usefulness in the previous sentence reflects what makes the Gradle toolchain so beneficial.
 

## Mark commit Tag ca2-part1

At this stage, a commit was made with the tag ca2-part1, as shown below:

   ```bash
    git add .
    git commit -m "Adição de task zipBackup, explicação do gradle wrapper e jdk toolchain e marcação de tag"
    git tag ca2-part1
    git push origin main ca2-part1
   ```

## Create a task named deployToDev

To create the task deployToDev we created multiple smaller tasks with each of the required behaviours. 

```gradle
task cleanDeploy(type: Delete) {
    description = "Delete the dev deployment directory"
    delete "$buildDir/deployment/dev"
}


task copyArtifact(type: Copy) {
    description = "Copy the main application artifact (bootJar) to the deployment directory"
    dependsOn bootJar
    // bootJar.archiveFile is a Provider; use it inside a closure so it resolves at execution time
    from { bootJar.archiveFile } 
    into "$buildDir/deployment/dev"
}


task copyRuntimeDeps(type: Copy) {
    description = "Copy runtime JAR dependencies into deployment/lib"
    dependsOn classes
    from {
        configurations.runtimeClasspath.filter { it.name.endsWith('.jar') }
    }
    into "$buildDir/deployment/dev/lib"
}


task copyConfig(type: Copy) {
    description = "Copy properties files to deployment and replace tokens (version, buildTimestamp)"
    from('src/main/resources') {
        include '*.properties'
        filter(org.apache.tools.ant.filters.ReplaceTokens, 
               tokens: [
                   version: (project.hasProperty('version') ? project.version : 'unspecified'),
                   buildTimestamp: new Date().format("yyyy-MM-dd'T'HH:mm:ss")
               ])
    }
    into "$buildDir/deployment/dev"
}


task deployToDev {
    description = "Prepare a dev deployment: clean -> artifact -> runtime libs -> configs (with token replacement)"

    dependsOn cleanDeploy, copyArtifact, copyRuntimeDeps, copyConfig


    copyArtifact.mustRunAfter cleanDeploy
    copyRuntimeDeps.mustRunAfter copyArtifact
    copyConfig.mustRunAfter copyRuntimeDeps

    doLast {
        println "Deployment prepared at: ${buildDir}/deployment/dev"
    }
}
```











# Alternative Solution — Apache Maven

## Introduction

As an alternative to Gradle, this section presents **Apache Maven** — one of the most widely used Java build automation tools.  
While Gradle is known for its flexibility and performance, Maven provides a **declarative, XML-based approach** focused on convention and standardization.  

The following analysis compares both tools and describes how Maven could be used to accomplish the same tasks developed in Part 1 of this assignment.

---

## Comparison Between Gradle and Maven

| Feature | Gradle | Maven |
|----------|---------|--------|
| **Build Script Language** | Uses a **Groovy or Kotlin DSL**, which allows scripting logic directly in the build file. | Uses **XML (POM)** — more verbose but highly structured and standardized. |
| **Configuration Approach** | **Imperative and declarative** — combines logic with configuration. | **Fully declarative** — describes what to build, not how to build it. |
| **Performance** | Uses an incremental build system and build cache, leading to faster builds. | Slower for large projects since each goal executes independently. |
| **Dependency Management** | Flexible; supports dynamic versions and custom repositories. | Stable; uses a central repository system with strong version management. |
| **Extensibility** | Easy to create **custom tasks** in Groovy/Kotlin. | Extended via **plugins**, which are well-documented but less flexible. |
| **Learning Curve** | Slightly higher due to its scripting flexibility. | Easier for beginners due to its declarative structure. |
| **IDE Support** | Excellent in IntelliJ, Eclipse, and VS Code. | Equally strong across all major IDEs. |
| **Wrapper Tool** | `gradlew` script ensures consistent Gradle version across environments. | Uses `mvnw` wrapper script for the same purpose. |

---

## How Maven Could Achieve the Same Goals (Design)

To replicate the Gradle tasks created in Part 1, Maven would use its **plugin-based structure** with configuration blocks defined inside the `pom.xml` file.  
Below is a conceptual design showing how each Gradle feature could be achieved with Maven.

---


This section presents a practical Maven project that replicates the same automation tasks implemented in Gradle Part 1, including:

- Running the server (`mvn run-server`)
- Running unit tests (`mvn test`)
- Creating a backup of the source files (`mvn backup`)
- Zipping the backup (`mvn zip-backup`)
- Managing the Java version (JDK 17 via Maven Toolchains)

All configuration is done using **Maven plugins**, with each task linked to a custom goal that can be executed directly from the command line.

---

## 1. Creating the Maven Project

To initialize the project:
```bash
mvn archetype:generate -DgroupId=basic_demo -DartifactId=gradle_basic_demo_maven -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd gradle_basic_demo_maven
```
---

## 2. Running the Server

In Gradle, a custom `runServer` task was created.  
In Maven, this can be done using the **Exec Plugin**:

```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
        <execution>
            <id>run-server</id>
            <phase>none</phase>
            <goals>
                <goal>java</goal>
            </goals>
            <configuration>
                <mainClass>basic_demo.ChatServerApp</mainClass>
                <arguments>
                    <argument>59001</argument>
                </arguments>
            </configuration>
        </execution>
    </executions>
</plugin>
```

Execution command:

```cmd
mvn exec:java@run-server
```

### 2. Adding a Unit Test


Maven natively supports testing through the Surefire Plugin, which automatically runs JUnit tests located under src/test/java:
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.2.5</version>
</plugin>
```

Command:
```
mvn test
```

## 3. Backup of Source Files
Maven can use the Antrun Plugin to perform file operations such as copying files to a backup directory:


```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
        <execution>
            <id>backup</id>
            <phase>none</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <target name="backup">
                    <echo message="Creating source backup..." />
                    <mkdir dir="backup/src"/>
                    <copy todir="backup/src">
                        <fileset dir="src/main/java"/>
                    </copy>
                    <echo message="Backup completed successfully." />
                </target>
            </configuration>
        </execution>
    </executions>
</plugin>
```

command:

```xml
mvn antrun:run@backup
```

### 4. Creating a ZIP Backup

Maven supports packaging archives through the Assembly Plugin.
This can generate a .zip file containing the backup folder:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>3.7.1</version>
    <executions>
        <execution>
            <id>zip-backup</id>
            <phase>none</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <configuration>
                <descriptors>
                    <descriptor>src/assembly/backup.xml</descriptor>
                </descriptors>
            </configuration>
        </execution>
    </executions>
</plugin>
```

src/assembly/backup.xml descriptor:

```xml
<assembly xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.3
                               https://maven.apache.org/xsd/assembly-1.1.3.xsd">
  <id>backup</id>
  <formats>
    <format>zip</format>
  </formats>
  <fileSets>
    <fileSet>
      <directory>backup/src</directory>
      <outputDirectory>/</outputDirectory>
    </fileSet>
  </fileSets>
</assembly>

```

command:
```xml
mvn assembly:single@zip-backup
```


### 5. Managing Java Versions

Maven ensures JDK consistency through the Toolchains Plugin, similar to Gradle’s JDK Toolchain:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-toolchains-plugin</artifactId>
    <version>3.2.0</version>
    <configuration>
        <toolchains>
            <jdk>
                <version>17</version>
                <vendor>temurin</vendor>
            </jdk>
        </toolchains>
    </configuration>
</plugin>
```


| Aspect            | Gradle                          | Maven                          |
| ----------------- | ------------------------------- | ------------------------------ |
| Build Logic       | Scripted with Groovy/Kotlin     | Declarative XML configuration  |
| Custom Tasks      | Simple and flexible             | Implemented via Plugins        |
| Build Performance | Faster due to caching           | Slower but highly stable       |
| Plugin Ecosystem  | Growing and modern              | Mature and extensive           |
| Toolchain Support | Built-in                        | Through Toolchains Plugin      |
| Ideal Use Case    | Modern, multi-language projects | Large enterprise Java projects |


## Conclusion

Apache Maven provides a stable and structured alternative to Gradle, focusing on simplicity, conventions, and plugin-based extensibility.
Although it lacks the flexibility and performance optimizations of Gradle, Maven remains a powerful choice for projects where standardization and maintainability are prioritized.