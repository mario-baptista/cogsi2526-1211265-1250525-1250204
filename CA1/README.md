# COGSI CA1, Parte 1

Este relatório detalha a análise, o design e a implementação da primeira parte do trabalho prático de COGSI CA1, que se foca no controlo de versões com Git

## Primeiros passos

Foi inicializado o repositório (*cogsi2526-1211265-1250525*) com o comando ```git init```. 

Após a criação do repositório local, foi criado um repositório vazio no GitHub e estabelecida a sua ligação com o comando ```https://github.com/mario-baptista/cogsi2526-1211265-1250525.git```.

Após a ligação, foi realizado o 1º commit com os comandos ```git add .```, ```git commit -m "first commit"``` e ```git push -u origin main```.

Após o repositório estar conectado e verificarmos que funciona como esperado realizamos os seguintes passos:

1. Criar a pasta `CA1` no repositório do grupo.  
2. Copiar o código da aplicação **Spring Petclinic** para essa pasta.  
3. Realizar o commit do código:  
   ```bash
   git add .
   git commit -m "Ainitial version of spring-petclinic"
   git push
4. Criar a primeira tag de versão, segundo o padrão ```major.minor.revision```:
   ```sh
      git tag v1.1.0
      git push tags
    ```
5. Criar um campo chamado **professionalLicenseNumber** dentro da classe Vet.
   ```java
    @Column(name = "professionalLicenseNumber")
    @NotEmpty
    protected String professionalLicenseNumber;
    ```
    

6. Realizar git log para ver histórico de commits neste repositório.
   ```sh
    git log 
   ```

7. Realizar git revert para reverter alterações de um commit.
   ```sh
    git revert 7a8abfa91907774e097194045c4ddc21c87d6d56
   ```

8. Mostrar qual é a branch padrão do repositório e quando foi feito o seu último commit
   ```sh
   git remote show origin | grep "HEAD branch"
   ```
   Obter o último commit da branch padrão e a sua data:
   ```sh
   git log -1 --format="%H%n%an%n%ad%n%s" origin/main
   ```
   Os campos apresentados significam:
   - %H — hash completo do commit
   - %an — nome do autor
   - %ad — data completa do commit
   - %s — mensagem do commit

9. Mostrar quantos contribuintes distintos realizaram commits no repositório
   ```sh
   git shortlog -sne
   ```

10. Marcar o commit final da entrega com a tag ca1-part1
      ```sh
      # criar uma tag
      git tag -a ca1-part1 -m "CA1 - Parte 1: entrega da primeira parte"
      # enviar a tag para o repositório remoto
      git push origin ca1-part1
      ```
# Parte 2 - Branches

1. Criar a branch email-field
   ```sh
   git checkout -b email-field
   ```
   ```sh
   git add .
   git commit -m "Add email field to Vet class"
   git checkout main
   git merge email-field
   git tag v1.3.0
   git push origin main --tags
   ```

   ![alt text](image.png)

2. Criar conflitos de merge e resolvê-los
   Foram feitas edições propositadas em dois branches diferentes para gerar conflitos.
   Na branch conflict-a adicionamos um comentário (// Comentário conflict-a)
   Na branch conflict-b adicionamos um comentário (// Comentário conflict-b)

   Criar os branches:
   ```sh
   git checkout -b conflict-a
   git checkout main
   git checkout -b conflict-b
   ```

   Editar o branch "conflict-a":
   ```sh
   git checkout conflict-a
   # Adicionar o comentário na class Vet.java

   git add src/.../Vet.java
   git commit -m "Conflict-a"
   git push -u origin conflict-a
   ```

   Editar o branch "conflict-b":
   ```sh
   git checkout conflict-b
   # Adicionar o comentário na class Vet.java

   git add src/.../Vet.java
   git commit -m "Conflict-b"
   git push -u origin conflict-a
   ```

   Fazer o merge do conflict-a:
   ```sh
   git checkout main
   git merge conflict-a
   # Este merge aplica sem conflitos
   git push origin main
   ```

   Fazer o merge do conflict-b:
   ```sh
   git merge conflict-b
   # Merge conflict
   ```
   ![alt text](image-1.png)

   Editar o ficheiro para resolver o conflito (manteve-se os 2 comentários):

   ![alt text](<Screenshot 2025-09-30 at 22.09.03.png>)

   Realizar o commit agora sem conflito
   ```sh
   git add .
   git commit -m "Resolve merge conflicts (kept both)"
   git push origin main
   ```
3. Verificar configuração de tracking de branches

   Para ver qual branch local segue qual branch remota:
   ```sh
   git branch -vv
   ```
   ![alt text](<Screenshot 2025-09-30 at 22.27.20.png>)

   - main está a trackear origin/main
   - conflict-a está a trackear origin/conflict-a
   - conflict-b não está a trackear nenhuma branch remota
   - email-field não está a trackear nenhuma branch remota

   (Ao realizar git push no conflict-a usei -u mas no conflict-b não, é por essa razão que a branch conflict-a ficou ligada à branch remota (origin/conflict-a) e a branch conflict-b não.
4. Marcar entrega da Parte 2
   
   O commit final da Parte 2 foi marcado com a tag ca1-part2:
   ```sh
   git tag -a ca1-part2 -m "CA1 - Parte 2: entrega da segunda parte"
   git push origin ca1-part2
   ```


# Parte Extra - Soluções Alternativas de Versão de Controlo


Esta secção aborda soluções tecnológicas de controlo de versões **alternativas ao Git**, organizadas segundo os dois principais tipos de sistemas de controlo de versões:
**Distribuídos (SCVD)** e **Centralizados (SCVC)**.


### Sistema de Controlo de Versões Distribuído (SCVD)

Um **SCVD** é um sistema onde os repositórios **não dependem de um servidor central** — cada utilizador possui uma cópia completa do repositório, nomeadamente o histórico completo do projeto, e isso proporciona **maior redundância e flexibilidade**, uma vez que o trabalho pode continuar mesmo sem ligação à internet.


### Sistema de Controlo de Versões Centralizado (SCVC)

Por outro lado, um **SCVC** requer um **servidor central** responsável por armazenar o histórico e gerir o código-fonte.
Neste modelo, todos os utilizadores fazem *commit* diretamente no repositório principal.
Este tipo de sistema é **mais simples e fácil de configurar**, mas depende totalmente do servidor central — constituindo, assim, um **ponto único de falha**.


De seguida, demonstram-se exemplos de sistemas tecnológicos de controlo de versões distribuídos em alternativa ao Git:
- Mercurial: ferramenta gratuita e distribuída de gestão de controlo de código-fonte que gere projetos de qualquer tamanho com eficiência e oferece uma interface fácil e intuitiva. Contém comandos mais consistentes que o git e foi utilizado em grandes projetos como o famoso browser Firefox.
- Bazaar: é um sistema de controlo de versões escrito em Python e desenvolvido pela entidade Canonical que faz parte do conhecido sistema operativo Ubuntu, que atualmente encontra-se descontinuado, é efetivamente um sistema obsoleto, porém foi utilizado em projetos relacionados com o Ubuntu e por algumas comunidades menores. De facto, o Bazaar tentou competir com o Git e Mercurial, mas nunca chegou a atingir a mesma relevância que esses dois projetos.
- Fossil:  sistema de controlo de versão de código aberto, projetado e desenvolvido pelo criador do SQLite. Um executável independente do Fossil possui um mecanismo de gestão de controlo de versão, interface web, rastreador de problemas, wiki e servidor web integrado. O Fossil está disponível para Linux, Windows e macOS.

Em contrapartida, num sistema de controlo de versão centralizado, também conhecido como sistema de controlo de fonte ou de revisão centralizado, um servidor atua como o principal repositório centralizado que armazena todas as versões do código.

Os exemplos de ferramentas tecnológicas de controlo de versões centralizado são:
- Apache Subversion
- Perforce
- Concurrent Versions System

As vantagens da utilização de um sistema de controlo de versões centralizado é que existe uma visibilidade total do repositório por parte dos desenvolvedores, tanto naquilo que toca às alterações efetuadas, bem como para visualizar todo o código-fonte já produzido. Para além disso, um SCVC, é muito mais fácil de entender e utilizar, sem esquecer que a configuração deste tipo de controlo de versões não exige um investimento significativo de tempo e é simples.
Pelo contrário, existem algumas desvantagens, nomeadamente a existência de um único ponto de falha que coloca as informações em risco, isto tudo devido ao facto de ser um  servidor centralizado.
De forma a dar a conhecer outra forma de registar e gerir ficheiros com alterações consequentes ao longo do tempo, optamos por demonstrar, passo-a-passo, como utilizar um sistema de controlo de versões centralizado, isto é, o Apache Subversion. Assim sendo, posteriormente apresentamos os comandos, dando nota que serão apresentados os essenciais, desde a criação do repositório à gestão do repositório.

## Implementação Prática: Apache Subversion (SVN)

Nesta parte, é demonstrado o **processo de instalação, configuração e utilização** de um sistema **centralizado**, utilizando o **Apache Subversion** num ambiente **Ubuntu Desktop**.


### 1. Instalação dos Pacotes Necessários

Antes de criar o repositório, é necessário instalar o Subversion (SVN) e o módulo Apache que permite o acesso via HTTP:

   ```bash
   sudo apt install subversion apache2 libapache2-mod-svn -y
   ```

### 2. Criação do Repositório

Primeiramente, foi criada a pasta local onde o repositório ficará armazenado. O argumento -p e o comando mkdir assegura que as pastas intermédias, caso não existam, sejam criadas automaticamente.

```bash
sudo mkdir -p /svn/repositorio
```

Em seguida, o repositório SVN foi criado com:

```bash
sudo svnadmin create /svn/repositorio
```

Foi também atribuída a propriedade da pasta ao utilizador e grupo do Apache www-data, garantindo que o servidor tenha as permissões adequadas:

```bash
sudo chown -R www-data:www-data /svn/repositorio
```


### 3. Configuração do Servidor Apache para o SVN

De modo a permitir o acesso remoto ao repositório através do Apache, foi necessário editar o ficheiro de configuração do módulo dav_svn.

```bash
sudo nano /etc/apache2/mods-enabled/dav_svn.conf
```


No interior do ficheiro, foi adicionada a seguinte configuração:

```apache
<Location /svn>
   DAV svn
   SVNParentPath /svn
   AuthType Basic
   AuthName "Acesso ao SVN"
   AuthUserFile /etc/apache2/dav_svn.passwd
   Require valid-user
</Location>
```


Para proteger o acesso ao repositório, foi criado um ficheiro de autenticação com os utilizadores joaoaraujo e mariobatista e para cada utilizador a sua respetiva palavra-passe:

Nota: o argumento -c só aparece uma vez pois foi apenas para criar esse ficheiro designado por *dav_svn.passwd* visto que não existia, sendo importante mencionar que caso se faça um comando *cat* sobre esse ficheiro, na tentativa de o visualizar, apenas serão visiveis os nomes de utilizador, contudo as palavras-passes não aparecerão em plain text.

```apache
sudo htpasswd -c /etc/apache2/dav_svn.passwd joaoaraujo

sudo htpasswd /etc/apache2/dav_svn.passwd mariobatista
```

Abaixo, as duas imagens seguintes demonstram, respetivamente a inserção de uma palavra-passe duas vezes para o utilizador joaoaraujo, e noutra imagem consta o popup que diz respeito ao início de sessão para posteriormente, sendo o login validado, é dado o acesso ao repositório.

   ![alt text](<addpassword.png>)


   ![alt text](<login_interface.png>)


### 4. Gestão de Ficheiros e Pastas

A estrutura básica de um projeto no Apache SVN é um repositório com pastas trunk, branches e tags. A estrutura de pastas standard tem como explicação o seguinte para cada termo:

- trunk: É a pasta principal, o ramo principal do projeto, onde se encontra a versão estável e mais atual do código.
- branches: Contém os ramos de desenvolvimento, que são cópias do trunk para desenvolver funcionalidades ou corrigir bugs em paralelo, sem afetar o código principal.
- tags: Guarda etiquetas, que são cópias do trunk num ponto específico da história do projeto, utilizadas para marcar versões estáveis ​​e lançamentos (releases).

Neste próximo código criaram-se as pastas que fazem parte da tipica estrutura padrão de um repositório SVN.


```apache
svn mkdir http://192.168.68.57/svn/repositorio/trunk \
http://192.168.68.57/svn/repositorio/branches \
http://192.168.68.57/svn/repositorio/tags -m "Criar estrutura principal”
```

Nesta fase a seguir, o comando explanado vai inserir todo o conteúdo do repositório na pasta cogsi_projeto.


```apache
svn checkout http://192.168.68.57/svn/repositorio/trunk/ cogsi2526_projeto
```

De seguida são apresentados três comandos: o primeiro move o utilizador no terminal para a pasta cogsi2526_projeto, o segundo comando abre o editor de texto nano onde dentro dele foi inserida a mensagem “Ola”. Por fim o comando **svn add file.txt** que vai adicionar o ficheiro “file.txt” à lista do controlo de versão.


```bash
cd ~/cogsi2526_projeto
nano file.txt
svn add file.txt
```

Este comando efetua o commit no svn. Assim sendo, são enviadas as alterações para o servidor.


```apache
svn commit -m “criacao do ficheiro file.txt”
```

### 5. Implementação de Branches

As branches no SVN são criadas copiando uma pasta, é literalmente uma nova pasta dentro do repositório central e que vai ser para ocorrer o desenvolvimento paralelo.

```apache
svn copy http://192.168.68.57/svn/repositorio/trunk \
         http://192.168.68.57/svn/repositorio/branches/feature1 \
         -m "Criar branch feature1
```

Da mesma forma que se fez checkout para o ramo trunk anteriormente para se implementar uma pasta local vinculada, para a pasta feature1 do repositório, concebeu-se uma pasta local designada por **projetocogsi_feature1**. O comando demonstrado a seguir apresenta como se faz para criar essa pasta local.

```apache
svn checkout http://192.168.68.57/svn/repositorio/branches/feature1 projetocogsi_feature1
```

### 6. Realização do Merge

Para realizar o merge, sendo que cada pasta local está vinculada a uma pasta no repositório, em termos práticos, tem de se ir até à pasta local do trunk que se designa por cogsi2526_projeto e efetuar o seguinte comando:

```apache
svn merge http://192.168.68.57/svn/repositorio/branches/feature1
```


### 7. Ver diferenças entre Revisões

No Subversion, uma revisão é uma versão numerada do repositório. Cada vez que alguém faz um commit, o SVN cria uma nova revisão, incrementando o número (r1, r2, r3...). Esse número representa o estado completo do repositório naquele momento, permitindo voltar, comparar ou ver o histórico de qualquer ponto do projeto. No SVN, têm-se a possibilidade de realizar o comando **svn diff** para se ver então, as diferenças entre as revisões. Na imagem a seguir, consta a diferença entre a revisão 11 e a revisão 13.

   ![alt text](<svndiff.png>)

### 8. Visualização do Histórico de Commits

A partir do comando **svn log**, é possível ver a lista de commits já efetuados. De referir que também é oportuno utilizar também o comando **svn status** para se ver o estado atual das alterações efetuadas em certos documentos e pastas dentro da pasta local cogsi2526_projeto.

   ![alt text](<svnlog.png>)


### 9. Implementação de Tags

No SVN, as tags são apenas cópias imutáveis, quer isto dizer que uma vez concebidas, tornam-se inalteráveis. No comando a demonstrar de seguida, é criada uma etiqueta designada por v1.0 onde caso seja clicada, o utilizador do repositório vai parar à pasta trunk.

```apache
svn copy http://192.168.68.57/svn/repositorio/trunk \
         http://192.168.68.57/svn/repositorio/tags/v1.0 \
         --m "Cria tag v1.0 a partir do trunk"
```
