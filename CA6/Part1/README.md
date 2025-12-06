# CA6 Part 1 - Jenkins Pipeline & Infrastructure as Code

This assignment focuses on automating the build and deployment process of a Spring Boot application using a CI/CD pipeline with Jenkins, while managing infrastructure using Vagrant and Ansible.

The goal is to create a pipeline that builds the Gradle version of the "Building REST services with Spring" application and deploys it to local virtual machines (VMs).

## Infrastructure Setup

The infrastructure consists of two Virtual Machines (VMs) created using Vagrant and provisioned with Ansible.

### Vagrant

The `Vagrantfile` defines two VMs: **blue** and **green**.

- **Box**: `spox/ubuntu-arm` (optimized for Apple Silicon).
- **Provider**: `vmware_desktop`.
- **Network**: Private network with static IPs.
    - **Blue**: `192.168.56.10`
    - **Green**: `192.168.56.11`
- **Resources**: 2 CPUs, 2048MB RAM each.

```ruby
Vagrant.configure("2") do |config|
  # Use ARM64 box for Apple Silicon
  config.vm.box = "spox/ubuntu-arm"

  config.vm.define "blue" do |blue|
    blue.vm.network "private_network", ip: "192.168.56.10"
    blue.vm.hostname = "blue"
    blue.vm.provider "vmware_desktop" do |v|
      v.memory = "2048"
      v.cpus = 2
      v.gui = false
      v.allowlist_verified = true
    end
  end

  config.vm.define "green" do |green|
    green.vm.network "private_network", ip: "192.168.56.11"
    green.vm.hostname = "green"
    green.vm.provider "vmware_desktop" do |v|
      v.memory = "2048"
      v.cpus = 2
      v.gui = false
      v.allowlist_verified = true
    end
  end


end

```

### Ansible

Ansible is used to provision the VMs and deploy the application. The `playbook.yml` performs the following tasks:

1.  **Install OpenJDK 17**: Ensures the Java runtime is available.
2.  **Create Application Directory**: Sets up `/opt/spring-app`.
3.  **Copy Application JAR**: Transfers the built artifact (`basic_demo-0.1.0.jar`) from the host to the VM.
4.  **Create Systemd Service**: Defines a service `spring-app` to manage the application lifecycle.
5.  **Start Service**: Enables and starts the application.

```yaml
---
- name: Provision and Deploy Spring Boot App
  hosts: all
  become: yes
  vars:
    app_dir: /opt/spring-app
    jar_source: "{{ playbook_dir }}/../gradle_basic_demo/build/libs/basic_demo-0.1.0.jar" # Default path, can be overridden
    jar_dest: "{{ app_dir }}/app.jar"

  tasks:
    - name: Install OpenJDK 17
      apt:
        name: openjdk-17-jdk
        state: present
        update_cache: yes

    - name: Create application directory
      file:
        path: "{{ app_dir }}"
        state: directory
        mode: '0755'

    - name: Copy application JAR
      copy:
        src: "{{ jar_source }}"
        dest: "{{ jar_dest }}"
        mode: '0644'
      # Only copy if the source file exists (to avoid errors during initial provisioning if build hasn't run)
      ignore_errors: yes

    - name: Create systemd service
      copy:
        dest: /etc/systemd/system/spring-app.service
        content: |
          [Unit]
          Description=Spring Boot Application
          After=network.target

          [Service]
          User=root
          ExecStart=/usr/bin/java -jar {{ jar_dest }}
          SuccessExitStatus=143

          [Install]
          WantedBy=multi-user.target
      notify:
        - Restart Spring App

    - name: Enable and start Spring App service
      systemd:
        name: spring-app
        enabled: yes
        state: started
        daemon_reload: yes
      ignore_errors: yes # Ignore if jar is missing

  handlers:
    - name: Restart Spring App
      systemd:
        name: spring-app
        state: restarted
        daemon_reload: yes

```

## Jenkins Pipeline

The `Jenkinsfile` defines the CI/CD pipeline with the following stages:

### 1. Checkout
Pulls the latest source code from the repository.

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

### 2. Assemble
Compiles the code and produces the artifact files using Gradle.

```groovy
stage('Assemble') {
    steps {
        dir('CA6/Part1/gradle_basic_demo') {
            sh 'chmod +x gradlew'
            sh './gradlew clean assemble'
        }
    }
}
```

### 3. Test
Runs unit tests to verify the application's correctness and publishes the results.

```groovy
stage('Test') {
    steps {
        dir('CA6/Part1/gradle_basic_demo') {
            sh './gradlew test'
        }
    }
    post {
        always {
            junit 'build/test-results/test/*.xml'
        }
    }
}
```

### 4. Archive
Archives the generated JAR files in Jenkins for later use.

```groovy
stage('Archive') {
    steps {
        archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
    }
}
```

### 5. Provision Infrastructure
Brings up the Vagrant VMs (`blue` and `green`) using the `vmware_desktop` provider.

```groovy
stage('Provision Infrastructure') {
    steps {
        sh 'vagrant up --provider=vmware_desktop'
    }
}
```

### 6. Deploy to Blue
Deploys the application to the **blue** VM using Ansible. It passes the path to the JAR file and the SSH private key as extra variables.

```groovy
stage('Deploy to Blue') {
    steps {
        sh """
            ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} \
            --limit blue \
            --extra-vars "..."
        """
    }
}
```

### 7. Deploy to Production?
A manual approval step. The pipeline pauses here until a user manually approves the deployment to the production environment (green VM).

```groovy
stage('Deploy to Production?') {
    steps {
        input message: 'Deploy to Production?', ok: 'Deploy'
    }
}
```

### 8. Deploy
Deploys the application to the **green** VM (Production) using Ansible, similar to the blue deployment.

```groovy
stage('Deploy') {
    steps {
        sh """
            ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} \
            --limit green \
            --extra-vars "..."
        """
    }
}
```