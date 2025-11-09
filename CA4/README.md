# CA4 - README.md with Part1 and Alternative Solution


## CA4 — Part 1


We basically took the setup from CA3 Part 2 and improved it using Ansible.  
Now, instead of manually installing things inside the VMs, we used Vagrant to set up the VMs and Ansible (local provisioner) to configure and run the services.
The goal was to make everything: Automated, repeatable (idempotent), resilient to small failures (using ignore\_errors, failed\_when, retries, and until).

### 1. Project Structure (Important Files)

We organized the automation files into roles so that each component (Spring app and H2 database) is configured independently and cleanly.

![img_createFiles](https://github.com/user-attachments/assets/e6996ca6-68ab-470b-9732-accd9d7b3e90)

- The Vagrantfile defines and creates the two VMs.
- ansible/hosts.ini tells Ansible which VM belongs to which group.
- ansible/site.yml assigns roles to machines.
- Each role contains tasks to set up one component (Spring app or database).

This organization makes the setup modular and easy to maintain.


### 2. Vagrantfile Configuration

Each VM runs ansible\_local and is assigned a role through site.yml.

This is the step we use to open up the Vagrantfile:

![img_VagrantfileChange](https://github.com/user-attachments/assets/51a98e72-09d3-4bcc-b688-517f66037b71)

![img_VagrantfileChange1](https://github.com/user-attachments/assets/72588c06-b743-4e6f-9b2f-6d9dc2e23c61)

![img_VagrantfileChange2](https://github.com/user-attachments/assets/89743a79-1fbc-41d5-ab70-0121a3d7e00a)


Inside the Vagrantfile, i configured each VM  to automatically run Ansible from within the VM (using ansible_local). This means we don’t need Ansible installed on our host system.
This step ensures that as soon as the VM is created, Ansible provisions it automatically, no manual SSH or command running is needed.

### 3. Ansible Inventory (Which VM is Which)

Both roles run locally within each VM:

![img_hosts ini](https://github.com/user-attachments/assets/a32b283a-f782-40fd-ac8b-fcb6eca22e3d)

Because Ansible runs inside each VM, the connection type is local.
This avoids any SSH or network configuration issues.

### 4. site.yml (Role Assignment)

This file tells Ansible which role goes to which VM:

![img_site yml](https://github.com/user-attachments/assets/ec5b303f-be14-4d70-afe9-be371877a5a8)

This means:
- The app Vm installs and runs the Spring application
- The db VM installs and runs the H2 database

This keeps our deployment clean and organized.


### 5. Role: Spring Application (spring\_app)


The spring app role is responsible for installing, building, and running the Spring Boot application on the app VM.
This role is located in:
ansible/roles/spring\_app/tasks/main.yml

This:
1.	Installs Required Packages: the application needs Java to run so we use Git so we can copy the source code then we install Gradle because it builds the Spring Boot application.
Installing these via Ansible ensures they are always set up the same way on every provision run.
2.	Copies the Spring Source Code
The Spring project folder is copied to:
-  /opt/gradle_transformation
This makes the application code available to the VM so it is not dependent on the host.
3.	Configures Database Connection
Inside application.properties, the app is updated to use the H2 database running on the other VM.
This is important because the app and the database are not running on the same machine.
4.	Builds the Application Using Gradle
This step turns the source code into a  JAR file. In CA3, we did this manually so now it happens automatically during provisioning.
5.	Creates and Enables a Systemd Service
We create a service file so the Spring application runs in the background like a real server process.

![img_main yml1](https://github.com/user-attachments/assets/f9a950d4-0644-4904-a2d8-51642da068c8)

By doing this i automated the entire Spring app deployment, no manual compiling or running needed after booting.

### 6. Error Handling Used Here

Sometimes Gradle fails due to network timing or repo delays.

To avoid failed provisioning runs, i used:
- (ignore_errors:true) for skipping minor file sync issues
- retries/until for retrying Gradle when the network is unstable
- failed_when for detecting failed builds more accurately


![img_ignoreErrors](https://github.com/user-attachments/assets/2ac60d9c-2dea-412c-b686-3f39f4cd5c7e)

![img_failedWhen](https://github.com/user-attachments/assets/7cef8a22-3001-431b-8bb5-931a4d41fa49)

![img_ignoreErrors true](https://github.com/user-attachments/assets/f8f338b8-d218-4d8c-bb77-96303a3a4885)

![img_retryUntil](https://github.com/user-attachments/assets/f4500e1a-dd13-434f-9950-760c9e64c75f)


### 7. H2 Database (h2)

The second VM is responsible for running the H2 Database, which will store and serve the data used by the Spring Boot application.
To automate its setup, we created an Ansible role called h2 located at:
ansible/roles/h2/tasks/main.yml

This :
1.	Install Java and UFW: H2 requires Java to run because it is a Java based database and UFW is installed to manage firewall access so that communication stays secure.

2.	Download the H2 Database JAR: Instead of installing H2 manually, we download the h2.jar file. This keeps the installation lightweight and makes the setup repeatable.

3.	Open Firewall Port 9092: This port allows the Spring app (on the other VM) to connect to the database. Only necessary ports are opened for security.

4.	Create a Systemd Service: We create a service file (h2.service.j2) so that the H2 server starts automatically when the VM boots, keeps running in the background, restarts again if it crashes.


![img_main yml3](https://github.com/user-attachments/assets/bd16b394-5ef5-4f18-ab90-9722cdf497ef)


**Systemd Service Template**

By automating H2 in this way, we ensure that the database is always available and consistently configured, no matter how many times we rebuild the VM.

![img_h2 service j2](https://github.com/user-attachments/assets/eb2ac030-f076-4255-a9ff-77e92b226d1f)


### 8. Running the Automation

To start evrything we need to do : 

```bash
vagrant up
```

Running it a second time confirms idempotency, almost no tasks change so. This proves that our automation is stable and repeatable.

First Provision Run:

![img_firstRunProvision](https://github.com/user-attachments/assets/a04fcdd3-a3c6-43fb-95fc-28cc7e284245)

Second Run (idempotency confirmed):

![img_secondRunProvision](https://github.com/user-attachments/assets/3dba9ea3-aa64-4b55-8ab4-1fcf83e869a3)

### 9. H2 Database Verification

We checked that H2 is running:

![img_H2Server](https://github.com/user-attachments/assets/e30ac784-7f3f-4bc3-b81e-564fbeaa9412)


Then we accessed the H2 web console from a browser and confirmed that all tables were present:

![img_H2Login](https://github.com/user-attachments/assets/d3407358-9d41-46f7-870e-e012fec5df93)

Here we can also see our database tables:

![img_H2Tables](https://github.com/user-attachments/assets/c2ba396d-7964-4bc4-b509-d68e49fa185b)


### 10. Spring Application Working
    
Once both VMs were successfully provisioned, we tested that the Spring Boot application was running correctly and connected to the H2 database.
We accessed the application endpoints in a browser.

This displays the list of employees:

![img_employeeWeb](https://github.com/user-attachments/assets/62977a59-64c0-41e5-8753-47e1dad1e45f)

This displays the list of orders:

![img_ordersWeb](https://github.com/user-attachments/assets/fa0159dd-f807-4213-b8c6-1f7941480d0e)

This confirmed that:
- The Spring application started successfully
- It could access the H2 database running on the other VM
- The API endpoints were working normally


### Adding Data to Test Communication
To verify that the app was actually writing to the database, not just displaying static data, we added a new employee named Frodo.

![img_addFrodo](https://github.com/user-attachments/assets/661b9fa9-2218-4903-b613-8c93a1d3411e)

![img_updatedWeb](https://github.com/user-attachments/assets/9db48eb1-62fe-4c5d-8a99-9b41d3682b27)

### PAM Configuration 

To perform the PAM configuration, first in the *site.yml* file we add the following code:

```yml
- name: Configure PAM policy for all hosts
  hosts: all
  become: true
  roles:
    - pam_policy
```

Secondly, in the */ansible/roles* folder we create the *pam_policy* folder and within it the *tasks* folder. Within tasks, we develop the *main.yml* file that contains the following code:

```yml
---
- name: Ensure libpam-pwquality is installed
  apt:
    name: libpam-pwquality
    state: present
    update_cache: true

- name: Configure PAM password complexity
  lineinfile:
    path: /etc/security/pwquality.conf
    regexp: '^{{ item.key }}='
    line: "{{ item.key }}={{ item.value }}"
    create: yes
  loop:
    - { key: 'minlen', value: '12' }
    - { key: 'minclass', value: '3' }
    - { key: 'maxrepeat', value: '2' }
    - { key: 'dictcheck', value: '1' }
    - { key: 'usercheck', value: '1' }
    - { key: 'maxsequence', value: '3' }

- name: Enforce password history (remember last 5)
  lineinfile:
    path: /etc/pam.d/common-password
    regexp: '^password\s+required\s+pam_unix.so'
    line: 'password required pam_unix.so remember=5 use_authtok sha512'

- name: Configure account lockout policy
  blockinfile:
    path: /etc/pam.d/common-auth
    insertafter: 'pam_unix.so'
    block: |
      auth required pam_tally2.so deny=5 unlock_time=600 onerr=fail audit even_deny_root_account silent
```

After that, use the *vagrant up* command to upload both machines.
The PAM result (about H2 database VM) from the provisioning part from Ansible was as follows:

![alt text](image-3.png)


The PAM result (about APP Spring VM) from the provisioning part from Ansible was as follows:

![alt text](image-4.png)

Later, the *vagrant ssh app* command was written to access the app machine. On the app's machine, a test was carried out to change the password of the application's virtual machine. Password 1234 was entered and gave the following error:

 ```bash
  vagrant@app-vm:~$ sudo passwd vagrant
  New password:
  BAD PASSWORD: The password is shorter than 12 characters
  Retype new password:
 ```

In this case below, the password *mariobatistanajoaoaraujo1* was typed and gave the following error:

```bash
vagrant@app-vm:~$ sudo passwd vagrant
New password:
BAD PASSWORD: The password contains less than 3 character classes
Retype new password:
 ```

The two errors above are normal and comply with what is required to be carried out in this work: the password policy dictates that there must be three of the four-character classes: uppercase letters, lowercase letters, digits, and symbols.

### Ansible Proof of Inventory (Static Form)

The *hosts.ini* file in the *ansible* folder has the following content:

```bash
[app]
192.168.56.11 ansible_connection=local

[db]
192.168.56.12 ansible_connection=local
```

When executing the command *ansible-inventory -i ansible/hosts.ini --list*, the following result is obtained:

```bash
{
    "_meta": {
        "hostvars": {
            "192.168.56.11": {
                "ansible_connection": "local"
            },
            "192.168.56.12": {
                "ansible_connection": "local"
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "app",
            "db"
        ]
    },
    "app": {
        "hosts": [
            "192.168.56.11"
        ]
    },
    "db": {
        "hosts": [
            "192.168.56.12"
        ]
    }
}
```

## Groups and Users

In this part, we enhanced the setup with user and group management.

1. Developers Group and User

Using Ansible, we created a new role called "developers" to manage user and group creation across all VMs.

**New Files Added:**
- `ansible/roles/developers/tasks/main.yml`: Contains tasks to create the group and user.

**Tasks in `ansible/roles/developers/tasks/main.yml`:**
- Create the "developers" group using the `group` module.
- Create the "devuser" user, assigning it to the "developers" group, with a home directory and bash shell.

**Updated Files:**
- `ansible/site.yml`: Added a new play to run the "developers" role on all hosts before the application and database roles.

This ensures the group and user exist before setting directory ownerships.

**Code for `ansible/roles/developers/tasks/main.yml`:**
```yaml
- name: Create developers group
  group:
    name: developers
    state: present

- name: Create devuser
  user:
    name: devuser
    group: developers
    groups: developers
    state: present
    shell: /bin/bash
    create_home: yes
```

**Updated `ansible/site.yml`:**
```yaml
- name: Setup developers group and user on all hosts
  hosts: all
  become: true
  roles:
    - developers
```

## Directory Permissions

- On host1 (app VM): The Spring application directory `/opt/gradle_transformation` is owned by `devuser:developers` with permissions 770, restricting access to members of the developers group.
- On host2 (db VM): The H2 database directory `/opt/h2` is owned by `devuser:developers` with permissions 770.

**Updated `ansible/roles/spring_app/tasks/main.yml` (added ownership task):**
```yaml
- name: Set ownership of app directory
  file:
    path: /opt/gradle_transformation
    owner: devuser
    group: developers
    mode: '770'
    recurse: yes
```

**Updated `ansible/roles/h2/tasks/main.yml` (added ownership task):**
```yaml
- name: Set ownership of h2 directory
  file:
    path: /opt/h2
    owner: devuser
    group: developers
    mode: '770'
    recurse: yes
```

- Group: developers
- User: devuser (member of developers group)

![alt text](<Screenshot 2025-11-07 at 19.03.42.png>)
## Health Checks

We added health-check tasks to verify that services are running correctly after deployment.

- On host1: Use the `uri` module to send a GET request to `http://localhost:8080/` and confirm a 200 status code.
- On host2: Use the `wait_for` module to check that port 9092 is open and accepting connections.

**Updated `ansible/roles/spring_app/tasks/main.yml` (added health check):**
```yaml
- name: Health check for Spring app
  uri:
    url: http://localhost:8080/
    method: GET
  register: health_check
  failed_when: health_check.status != 200
  retries: 5
  delay: 3
```
![alt text](image-1.png)

**Updated `ansible/roles/h2/tasks/main.yml` (added health check):**
```yaml
- name: Health check for H2 port
  wait_for:
    port: 9092
    timeout: 30
```

![alt text](image.png)


## CA4 — Part 2: Alternative Configuration Management with Puppet

### Explanation

As an alternative to Ansible, we propose using Puppet. Puppet is a declarative tool that defines infrastructure as code through manifests written in its DSL. It uses a pull-based model where agents on nodes periodically apply configurations from a master, ensuring continuous compliance. This contrasts with Ansible's push-based, imperative approach.

### How Puppet Compares to Ansible

| **Feature**              | **Ansible**                                                 | **Puppet**                                                       |
|---------------------------|-------------------------------------------------------------|------------------------------------------------------------------|
| **Architecture**          | Agentless (runs over SSH or local)                          | Agent-based (requires master and agent setup)                    |
| **Language**              | YAML (Declarative Playbooks)                                | Puppet DSL (Ruby-like Declarative Syntax)                        |
| **Execution Model**       | Push (controller pushes configuration to hosts)             | Pull (agents periodically fetch configuration from master)       |
| **Idempotency**           | Yes, via module design                                      | Yes, native in its model                                         |
| **Ease of Use**           | Easier to set up for small environments                     | Better for large infrastructures with frequent syncs             |
| **Error Handling**        | Manual (ignore_errors, retries, etc.)                       | Automatic, with detailed reporting through PuppetDB              |
| **Extensibility**         | Simple roles and modules                                   | Complex module ecosystem (Forge)                                 |
| **Best For**              | Ad-hoc provisioning, testing labs                           | Persistent configuration management across many servers          |

### 1. Project Structure (Important Files)

The Puppet setup mirrors the Ansible structure but uses manifests and modules.

- `Vagrantfile.puppet`: Vagrant configuration for Puppet provisioning.
- `puppet/manifests/site.pp`: Main manifest assigning classes to nodes.
- `puppet/modules/developers/manifests/init.pp`: Creates developers group and devuser.
- `puppet/modules/h2/manifests/init.pp`: Configures H2 database service.
- `puppet/modules/spring_app/manifests/init.pp`: Configures Spring application service.
- `puppet/modules/pam_policy/manifests/init.pp`: Configures PAM security policies.
- Templates: `puppet/modules/h2/templates/h2.service.erb`, `puppet/modules/spring_app/templates/spring.service.erb`.

### 2. Vagrantfile.puppet Configuration

Similar to the Ansible Vagrantfile, but uses Puppet provisioner. It installs Puppet agent and stdlib module, then applies manifests.

Key differences:
- Provisioner: `puppet` instead of `ansible_local`.
- Paths: `manifests_path`, `module_path`, `manifest_file`.
- Options: `--verbose` for debugging.

### 3. Puppet Site Manifest (site.pp)

This file assigns classes to nodes based on hostname.

```
node default {
  include developers
  include pam_policy
}

node 'app-vm' {
  include spring_app
}

node 'db-vm' {
  include h2
}
```

### 4. Modules and Roles

#### Developers Module

File: `puppet/modules/developers/manifests/init.pp`

Creates the developers group and devuser.

```
class developers {

  group { 'developers':
    ensure => present,
  }

  user { 'devuser':
    ensure     => present,
    gid        => 'developers',
    groups     => ['developers'],
    shell      => '/bin/bash',
    home       => '/home/devuser',
    managehome => true,
  }

}
```

#### PAM Policy Module

File: `puppet/modules/pam_policy/manifests/init.pp`

Installs pwquality, configures password policies, and sets up account lockout.

```
class pam_policy {

  package { 'libpam-pwquality':
    ensure => installed,
  }

  file { '/etc/security/pwquality.conf':
    ensure  => file,
    content => "minlen=12\nminclass=3\nmaxrepeat=2\ndictcheck=1\nusercheck=1\nmaxsequence=3\n",
    require => Package['libpam-pwquality'],
  }

  exec { 'pam_unix_remember':
    command => "sed -i 's/^password required pam_unix.so/password required pam_unix.so remember=5 use_authtok sha512/' /etc/pam.d/common-password",
    unless  => "grep -q 'remember=5' /etc/pam.d/common-password",
    path    => ['/usr/bin', '/bin'],
  }

  exec { 'pam_tally2':
    command => "sed -i '/pam_unix.so/a auth required pam_tally2.so deny=5 unlock_time=600 onerr=fail audit even_deny_root_account silent' /etc/pam.d/common-auth",
    unless  => "grep -q 'pam_tally2.so' /etc/pam.d/common-auth",
    path    => ['/usr/bin', '/bin'],
  }

}
```

#### H2 Database Module

File: `puppet/modules/h2/manifests/init.pp`

Installs Java, downloads H2, configures firewall, sets up systemd service.

```
class h2 {

  package { ['openjdk-17-jdk', 'ufw', 'wget']:
    ensure => installed,
  }

  file { '/opt/h2':
    ensure => directory,
  }

  exec { 'download_h2':
    command => 'wget -O /opt/h2/h2.jar https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar',
    creates => '/opt/h2/h2.jar',
    require => File['/opt/h2'],
    path    => ['/usr/bin', '/bin'],
  }

  file { '/opt/h2_ownership':
    path    => '/opt/h2',
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0770',
    recurse => true,
    require => [Exec['download_h2'], Class['developers']],
  }

  # Firewall
  exec { 'ufw_enable':
    command => 'ufw --force enable',
    unless  => 'ufw status | grep -q "Status: active"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_deny_incoming':
    command => 'ufw default deny incoming',
    unless  => 'ufw status | grep -q "Default: deny (incoming)"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_ssh':
    command => 'ufw allow 22/tcp',
    unless  => 'ufw status | grep -q "22/tcp"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_9092':
    command => 'ufw allow from 192.168.56.11 to any port 9092 proto tcp',
    unless  => 'ufw status | grep -q "9092"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_outgoing':
    command => 'ufw default allow outgoing',
    unless  => 'ufw status | grep -q "Default: allow (outgoing)"',
    path    => ['/usr/sbin', '/sbin'],
  }

  # Systemd service
  file { '/etc/systemd/system/h2.service':
    ensure  => file,
    content => template('h2/h2.service.erb'),
  }

  service { 'h2':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/system/h2.service'],
  }

  # Health check
  exec { 'h2_health_check':
    command => 'ss -tulpn | grep :9092',
    unless  => 'ss -tulpn | grep -q :9092',
    require => Service['h2'],
    path    => ['/usr/bin', '/bin'],
  }

}
```

Systemd Service Template: `puppet/modules/h2/templates/h2.service.erb`

```
[Unit]
Description=H2 Database Server
After=network.target

[Service]
WorkingDirectory=/opt/h2
ExecStart=/usr/bin/java -cp /opt/h2/h2.jar org.h2.tools.Server -tcp -tcpPort 9092 -tcpAllowOthers -baseDir /opt/h2
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Spring Application Module

File: `puppet/modules/spring_app/manifests/init.pp`

Installs Java, Git, Gradle, copies app, builds, configures service.

```
class spring_app {

  package { ['openjdk-17-jdk', 'git', 'gradle']:
    ensure => installed,
  }

  file { '/opt/gradle_transformation':
    ensure => directory,
  }

  exec { 'copy_app_source':
    command => 'cp -r /vagrant/gradle_transformation/* /opt/gradle_transformation/',
    creates => '/opt/gradle_transformation/build.gradle',
    require => File['/opt/gradle_transformation'],
    path    => ['/usr/bin', '/bin'],
  }

  file { '/opt/gradle_transformation_ownership':
    path    => '/opt/gradle_transformation',
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0770',
    recurse => true,
    require => [Exec['copy_app_source'], Class['developers']],
  }

  file { '/opt/gradle_transformation/src/main/resources/application.properties':
    ensure  => file,
    content => "spring.datasource.url=jdbc:h2:mem:mydb\nspring.datasource.username=sa\nspring.datasource.password=\nserver.port=8080\n",
    require => Exec['copy_app_source'],
  }

  exec { 'gradle_build':
    command => 'cd /opt/gradle_transformation && ./gradlew build',
    unless  => 'test -f /opt/gradle_transformation/build/libs/GradleProject_Transformation.jar',
    require => [File['/opt/gradle_transformation/src/main/resources/application.properties'], Package['gradle']],
    path    => ['/usr/bin', '/bin'],
  }

  # Systemd service
  file { '/etc/systemd/system/spring.service':
    ensure  => file,
    content => template('spring_app/spring.service.erb'),
  }

  service { 'spring':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/system/spring.service'],
  }

  # Firewall
  exec { 'ufw_allow_8080':
    command => 'ufw allow 8080/tcp',
    unless  => 'ufw status | grep -q "8080"',
    path    => ['/usr/sbin', '/sbin'],
  }

  # Health check
  exec { 'spring_health_check':
    command => 'curl -f http://localhost:8080/',
    require => Service['spring'],
    path    => ['/usr/bin', '/bin'],
  }

}
```

Systemd Service Template: `puppet/modules/spring_app/templates/spring.service.erb`

```
[Unit]
Description=Spring Application
After=network.target

[Service]
WorkingDirectory=/opt/gradle_transformation
ExecStart=/bin/bash -lc 'exec java -jar $(ls /opt/gradle_transformation/build/libs/*.jar)'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 5. Running the Automation

First Provision Run:

Run `VAGRANT_VAGRANTFILE=Vagrantfile.puppet vagrant up`. Puppet installs dependencies, applies manifests, and starts services.

Second Run (idempotency confirmed):

Run `VAGRANT_VAGRANTFILE=Vagrantfile.puppet vagrant provision`. Changes are minimal, confirming idempotency.

### Groups and Users

Developers group and devuser are created on all VMs.

Directory Permissions:

- `/opt/h2` owned by devuser:developers, mode 770.
- `/opt/gradle_transformation` owned by devuser:developers, mode 770.

### Health Checks

- H2: `ss -tulpn | grep 9092` confirms listening.
- Spring: `curl http://localhost:8080/` returns 200.

This setup mirrors the Ansible functionality while demonstrating Puppet's declarative style.

