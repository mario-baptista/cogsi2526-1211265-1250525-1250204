# CA3 — Part 2

In this Class Assignment 3, Part 2, we continue the work from Part 1 but introduce a distributed architecture using two separate Virtual Machines (VMs). One VM hosts the application (`gradle_transformation`), while the other hosts the H2 database in server mode. This setup allows the application to connect to the database over the network, demonstrating a more realistic deployment scenario.

The key changes from Part 1 include:
- Splitting the single VM into two: an "app" VM and a "db" VM.
- Configuring H2 to run in server mode on the db VM, accessible via TCP on port 9092.
- Updating the Spring Boot application to connect to the remote H2 server instead of using an in-memory or file-based database.
- Ensuring secure communication between VMs using a private network.

## Setup Overview

### Prerequisites
- Vagrant installed on the host machine.
- VirtualBox (or another supported provider) installed.
- Internet connection for downloading dependencies.

### Step 1: Create Part2 Folder and Copy Base Files

First, within the local repository folder, create the Part2 folder under CA3:

```bash
mkdir -p CA3/Part2
```

Copy the necessary files from Part1:

```bash
cp CA3/Part1/Vagrantfile CA3/Part2/
cp CA3/Part1/provision.sh CA3/Part2/
cp CA3/Part1/automate_apps.sh CA3/Part2/
```

Copy the gradle_transformation application from CA2:

```bash
cp -r CA2/Part2/GradleProject_Transformation CA3/Part2/gradle_transformation
```

### Step 2: Modify Vagrantfile for Two VMs

Edit `CA3/Part2/Vagrantfile` to define two separate VMs: one for the application and one for the database.

The updated Vagrantfile looks like this:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :-

Vagrant.configure("2") do |config|
  # App VM
  config.vm.define "app" do |app|
    app.vm.box = "bento/ubuntu-22.04"
    app.vm.hostname = "app-vm"
    app.vm.network "forwarded_port", guest: 8080, host: 8080   # for REST API
    app.vm.network "private_network", ip: "192.168.33.11"

    # Provision Script
    app.vm.provision "shell", path: "provision.sh"

    # Automation Script for app
    app.vm.provision "shell", inline: <<-SHELL
      cd /vagrant
      export VM_TYPE=app
      export CLONE_REPOS=true
      export BUILD_APPS=true
      export START_SERVICES=true
      ./automate_apps.sh
    SHELL
  end

  # DB VM
  config.vm.define "db" do |db|
    db.vm.box = "bento/ubuntu-22.04"
    db.vm.hostname = "db-vm"
    db.vm.network "private_network", ip: "192.168.33.12"
    db.vm.synced_folder "./h2-data", "/vagrant/h2-data", create: true

    # Provision Script
    db.vm.provision "shell", path: "provision.sh"

    # Automation Script for db
    db.vm.provision "shell", inline: <<-SHELL
      cd /vagrant
      export VM_TYPE=db
      export CLONE_REPOS=true
      export BUILD_APPS=false
      export START_SERVICES=true
      ./automate_apps.sh
    SHELL
  end
end
```

Key changes:
- Two VMs defined: "app" and "db".
- App VM has port forwarding for the REST API and IP 192.168.33.11.
- DB VM has IP 192.168.33.12 and a synced folder for H2 data persistence.
- Each VM runs the provision script and automation script with specific environment variables.

### Step 3: Update Provision Script

Modify `CA3/Part2/provision.sh` to download the H2 database JAR file, required for the db VM.

Add the following line after installing Gradle:

```bash
# Download and install H2 database
wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar -O /usr/local/bin/h2.jar
```

The full provision.sh:

```bash
#!/usr/bin/env bash

# Update packages
sudo apt-get update -y

# Install git and basic utilities
sudo apt-get install -y git curl unzip

# Install Java (JDK 17)
sudo apt-get install -y openjdk-17-jdk

# Install Maven
sudo apt-get install -y maven

# Install Gradle
sudo apt-get install -y gradle

# Download and install H2 database
wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar -O /usr/local/bin/h2.jar

# Check installations
java -version
mvn -version
gradle -v
git --version
```

### Step 4: Update Automation Script

Modify `CA3/Part2/automate_apps.sh` to handle the two VM types.

Add VM_TYPE variable:

```bash
VM_TYPE=${VM_TYPE:-app}
```

Update the BASE_DIR to Part2:

```bash
BASE_DIR=/home/vagrant/cogsi2526-1211265-1250525-1250204/CA3/Part2
```

Modify the cloning section to conditionally copy and configure based on VM_TYPE:

For app VM: Copy gradle_transformation and configure application.properties for H2 server mode.

For db VM: Prepare the H2 data directory.

Modify build section: Only build on app VM.

Modify start services: Start gradle_transformation on app VM, start H2 server on db VM.

### Step 5: Start the VMs

Navigate to the Part2 folder and run Vagrant:

```bash
cd CA3/Part2
vagrant up
```

This will start both VMs. The app VM will build and run the gradle_transformation application, connecting to the H2 server on the db VM.

### Step 6: Verify the Setup

- Access the application at `http://localhost:8080` (forwarded from app VM).
- The H2 console can be accessed at `http://localhost:8080/h2` on the app VM, but it will connect to the remote database.
- Check VM communication by viewing logs or testing database operations.

### Networking and Security

- VMs communicate via private network (192.168.33.0/24).
- No external ports exposed for the database, ensuring isolation.
- Custom SSH keys can be added later for enhanced security (not implemented in this setup).

This setup demonstrates a basic distributed application architecture, separating concerns between application and data layers.</content>
</xai:function_call</xai:function_call name="todowrite">
<parameter name="todos">[{"content":"Create README.md with step-by-step guide","status":"completed","priority":"medium","id":"create_readme"}]