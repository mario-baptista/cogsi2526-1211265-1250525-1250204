# CA6 Part 1

This directory contains the setup for CA6 Part 1, which involves creating a pipeline to build and deploy a Spring Boot application to a local VM using Vagrant and Ansible.

## Structure

- `gradle_basic_demo/`: Contains the "Building REST services with Spring" application (Gradle version).
- `Vagrantfile`: Defines two VMs (`blue` and `green`) using `bento/ubuntu-22.04`.
- `playbook.yml`: Ansible playbook to provision the VMs.
  - Installs Java 17 on all VMs.
  - Deploys the application to the `blue` VM.
- `pipeline.sh`: Script to automate the build and deployment process.

## Prerequisites

- Vagrant
- VirtualBox
- Ansible
- Java 17+ (for building locally)

## Usage

Run the pipeline script:

```bash
./pipeline.sh
```

This script will:
1. Build the application using Gradle (`./gradlew bootJar`).
2. Start the VMs and provision them using Ansible (`vagrant up`).

The application will be deployed to the `blue` VM and accessible at `http://localhost:8080` (forwarded from the VM).
The `green` VM will be provisioned with Java but no application deployed.

## Jenkins Integration

To use this pipeline in Jenkins:

1.  **Prerequisites**:
    *   Jenkins must be installed and running.
    *   Jenkins must have access to `git`, `java`, `vagrant`, and `virtualbox`.
    *   If running Jenkins in a container, ensure it has access to the host's Docker/VirtualBox socket or is configured for nested virtualization (which can be complex). Running Jenkins directly on the host is recommended for Vagrant tasks.

2.  **Create a New Job**:
    *   Select **New Item**.
    *   Enter a name (e.g., `CA6-Part1`).
    *   Select **Pipeline** and click **OK**.

3.  **Configure Pipeline**:
    *   Scroll down to the **Pipeline** section.
    *   Set **Definition** to **Pipeline script from SCM**.
    *   Set **SCM** to **Git**.
    *   **Repository URL**: Enter the path to your local repository (e.g., `file:///Users/mariozito/Desktop/COGSI/cogsi2526-1211265-1250525-1250204`) or your remote git URL.
    *   **Script Path**: Enter `CA6/Part1/Jenkinsfile`.

4.  **Run**:
    *   Click **Save**.
    *   Click **Build Now**.
