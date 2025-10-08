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