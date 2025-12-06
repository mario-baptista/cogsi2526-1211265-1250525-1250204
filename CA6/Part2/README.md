# CA6 Part 2 - Docker Deployment with Jenkins & Ansible


## Infrastructure Setup

The infrastructure consists of a single **Production** Virtual Machine provisioned using Vagrant and Ansible.

### Vagrant

The `Vagrantfile` defines one VM: **production**.

- **Box**: `spox/ubuntu-arm` (optimized for Apple Silicon/ARM64).
- **Provider**: `vmware_desktop`.
- **Network**: Private network with static IP `192.168.56.11`.
- **Resources**: 2 CPUs, 2048MB RAM.
- **Provisioning**: Automatically copies the SSH private key to the VM to facilitate Ansible connections.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "spox/ubuntu-arm"
  provider_name = "vmware_desktop"

  config.vm.define "production" do |prod|
    prod.vm.hostname = "production"
    prod.vm.network "private_network", ip: "192.168.56.11"
    # ...
  end
end
```

### Ansible

Ansible is used to install Docker on the VM and deploy the application container. The `deploy_docker.yml` playbook performs the following tasks:
1.  **Install Docker**: Dynamically detects the OS release (e.g., Ubuntu Jammy vs. Focal) to configure the correct Docker repositories and install `docker-ce`.
2.  **Log into Docker Hub**: Authenticates using credentials passed from Jenkins (`docker_username`, `docker_password`) to allow pulling images from private repositories.
3.  **Pull Image**: Pulls the specific tagged image from Docker Hub (`mariozito/sprint_rest_app:${BUILD_NUMBER}`).
4.  **Manage Container**:
    - Forcefully stops and removes any existing container to ensure a clean deploy.
    - Starts the new container on port **8081** (mapped to internal port 8080).

```yaml
- name: Deploy Docker App
  hosts: production
  vars:
    image_name: "mariozito/sprint_rest_app"
    container_name: "sprint_rest_app"
    app_port: 8081

  tasks:
    # ... Docker Installation steps ...

    - name: Log into Docker Hub
      docker_login:
        username: "{{ docker_username }}"
        password: "{{ docker_password }}"

    - name: Run Docker container
      docker_container:
        name: "{{ container_name }}"
        image: "{{ image_name }}:{{ build_number }}"
        state: started
        ports:
          - "{{ app_port }}:8080"
        restart_policy: always
```

## Jenkins Pipeline

The `Jenkinsfile` defines the CI/CD pipeline with the following stages:

### 1. Checkout
Pulls the latest source code from the repository.

### 2. Assemble
Compiles the code using Gradle.

### 3. Test
Runs unit and integration tests (in parallel) to verify application correctness.

### 4. Tag Docker Image
Builds the Docker image from the source code and tags it with the Jenkins `BUILD_NUMBER`.

```groovy
stage('Tag Docker Image') {
    steps {
        script {
            sh "docker build -t ${IMAGE} ."
        }
    }
}
```

### 5. Archive
Archives the `Dockerfile` for traceability.

### 6. Push Docker Image
Authenticates with Docker Hub using Jenkins credentials (`docker-hub-credentials`) and pushes the tagged image.

```groovy
stage('Push Docker Image') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', ...)]) {
             sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
             sh "docker push ${IMAGE}"
             sh "docker logout"
        }
    }
}
```

### 7. Deploy
Deploys the Docker container to the **production** VM using Ansible. This stage is **conditional** and only executes when the pipeline runs on the `main` branch.

It securely passes Docker Hub credentials and the `BUILD_NUMBER` to the Ansible playbook, ensuring the correct image version is pulled from the private repository.

```groovy
stage('Deploy') {
    when {
        branch 'main'
    }
    steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
            sh "ansible-playbook -i inventory deploy_docker.yml --extra-vars 'build_number=${BUILD_NUMBER} docker_username=${DOCKER_USERNAME} docker_password=${DOCKER_PASSWORD}'"
        }
    }
}
```

### 8. Post Actions
The pipeline includes a `post` section that handles notifications based on the build result.

- **Success**: Sends a "Build Succeeded" message to Discord.
- **Failure**: Sends a "Build Failed" message to Discord.
- **Unstable**: Sends a "Build Unstable" message to Discord.

These notifications use a specific **Discord Webhook URL** which is stored securely in Jenkins credentials with the ID `discord-webhook`. The pipeline retrieves this credential and sends a formatted JSON payload using `curl`.

```groovy
post {
    success {
        script {
             // ... curl command to send success message ...
        }
    }
    // ... failure and unstable blocks ...
}
```
![Discord Webhook](image.png)