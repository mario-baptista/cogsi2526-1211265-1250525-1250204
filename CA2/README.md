# CA2 — Part 1


## Primeiros passos
1. Clonar o repositório:
   ```bash
   git clone https://github.com/lmpnogueira/gradle_basic_demo.git
   cd REPO/CA2/part1
   ````

## Adicionar a task runServer

No ficheiro `build.gradle` adicionamos o seguinte código:

```java
task runServer(type:JavaExec, dependsOn: classes){
    group = "DevOps"
    description = "Launches a chat server that listens on port 59001 "
  
    classpath = sourceSets.main.runtimeClasspath

    mainClass = 'basic_demo.ChatServerApp'

    args '59001'
}
```

Testar o runServer:

![alt text](<Screenshot 2025-10-08 at 19.00.31.png>)


## Adicionar um teste unitário

No ficheiro `build.gradle` adicionamos o seguinte código:

```java
test {
    useJUnitPlatform()
    testLogging {
        events "passed", "skipped", "failed"
    }
}
```

Na pasta `src/test/java/basic_demo` adicionamos o seguinte teste:

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

Testar o teste:

![alt text](<Screenshot 2025-10-08 at 19.03.26.png>)

## Adicionar a task backup

No ficheiro `build.gradle` adicionamos o seguinte código:

```java
task backup(type: Copy) {
    group = "DevOps"
    description = "Backs up source files to the backup directory"
  
    from 'src'
    into 'backup/src'
    include '**/*.java'
}
```

Testar o backup:

![alt text](<Screenshot 2025-10-08 at 19.04.47.png>)


## Adicionar a task zipBackup 


```java
tasks.register('zipBackup', Zip) {
    dependsOn tasks.named('backup')
    from 'backup/src'
    archiveFileName = "app-backup.zip"
    destinationDirectory = file("backup/zips")
}
```

## Execução da tarefa zipBackup com dependência da tarefa backup:

Na imagem seguinte está explanado o comando *./gradlew zipBackup* e tem o seu intuito que é executar a tarefa do backup, de seguida, procede-se à criação do ficheiro app-backup.zip e o mesmo é inserido dentro da pasta */backup/zips*.


![alt text](<executeziptask.png>)


## Explicação sobre Gradle Wrapper e JDK Toolchain

O gradle wrapper é um pequeno script contido no projeto que garante que todos os utilizadores e sistemas operativos utilizam a mesma versão do gradle sem que haja a necessidade de existir a instalação manual. O ficheiro *gradle-wrapper.properties* contém no campo *distributionUrl* a hiperligação da versão especifica do gradle usada no projeto. 
Quando executado o comando **./gradlew build**, o gradle verifica se a versão indicada no *wrapper.properties* já está descarregada em *~/.gradle/wrapper/dists/*, sendo que caso não esteja, é realizado o download automático.

O Java Toolchain, por outro lado, é uma funcionalidade moderna do gradle que garante que o build usa a versão correta do JDK, mesmo tendo a máquina outras versões instaladas.
Neste projeto têm-se o seguinte código dentro do ficheiro *build.gradle*:

```java
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
```
Esse código, nada mais é do que o próprio gradle a dar a conhecer que utiliza a versão 17 do Java para compilar e executar este projeto.

Ao executar o comando **./gradlew -q javaToolchain**, o gradle mostra o seguinte output:

![alt text](<outputgradlewjdktoolchain.png>)

Na primeira parte do output, o gradle apresenta duas opções:
- *Auto-detection: Enabled* -> o que significa que o gradle está configurado para detetar automaticamente as versões do JDK que existem na máquina.
- *Auto-download: Enabled* -> o que significa que caso não seja possivel o gradle encontrar uma versão de JDK compatível com o que está definido na toolchain, o gradle faz o download automático da versão correta, sem que o utilizador precise de instalar manualmente.


Na segunda parte do output é apresentada a versão do JDK que o gradle está a usar para compilar e executar o projeto. E, constam-se os seguintes atributos:

- O nome Eclipse Temurin que identifica a distribuição do JDK. Anteriormente, defeniu-se a versão 17 no ficheiro *build.gradle*, e o que ocorre é que o gradle faz o download automático dessa distribuição *Eclipse Temurin* que tem por base a versão 17 de JDK.

- O campo *Location* que mostra o caminho no qual o gradle descarregou e instalou automaticamente o JDK dentro da própria pasta */.gradle/jdks*. 

- O campo *Language Version* que indica a versão da linguagem Java usada para compilar o código.

- O campo *Vendor* que demonstra qual é o fornecedor da distribuição do JDK.

- O campo *Architecture* que indica que o JDK é para ser utilizado em sistemas 64 bits.

- O campo *Is JDK* que apresenta um valor booleano *true* onde com isso, confirma-se que este pacote é de facto um JDK.

- Por último, o campo *Detected by*, muito sucintamente, o que transmite é que o gradle instalou automaticamente o JDK.

Antes de finalizar esta explicação, é de notar que o sistema operativo no qual foi instalado o gradle foi o Ubuntu e, como se pode ver na imagem logo acima deste texto, a versão do JDK no sistema operativo é a 21, e o gradle acabou por ser inteligente, e tendo por base o que foi escrito no ficheiro *build.gradle*, o próprio acabou por instalar a versão apropriada. Assim sendo, a utilidade na frase anteriormente apresentada é o reflexo do que torna o gradle toolchain tão benéfico. 


## Marcação de Commit com a tag ca2-part1

Nesta parte, foi dado um commit com tag ca2-part1, tal como se demonstra no código a seguir.

   ```bash
    git add .
    git commit -m "Adição de task zipBackup, explicação do gradle wrapper e jdk toolchain e marcação de tag"
    git tag ca2-part1
    git push origin main ca2-part1
   ````













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