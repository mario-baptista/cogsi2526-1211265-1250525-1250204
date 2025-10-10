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
    git push origin master
   ````