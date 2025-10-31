# CA3 — Part 2

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

Edit `CA3/Part2/Vagrantfile` to define two separate VMs: one for the database (started first to ensure availability) and one for the application.

The updated Vagrantfile looks like this:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :-

Vagrant.configure("2") do |config|
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
end
```

Key changes:
- Two VMs defined: "db" (started first) and "app".
- DB VM has IP 192.168.33.12 and a synced folder for H2 data persistence.
- App VM has port forwarding for the REST API and IP 192.168.33.11.
- Each VM runs the provision script and automation script with specific environment variables.
- Order ensures db VM starts before app VM to avoid timing issues.

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

Modify `CA3/Part2/automate_apps.sh` to handle the two VM types with proper sequencing and H2 configuration.

Add VM_TYPE variable:

```bash
VM_TYPE=${VM_TYPE:-app}
```

Update the BASE_DIR to Part2:

```bash
BASE_DIR=/home/vagrant/cogsi2526-1211265-1250525-1250204/CA3/Part2
```

Modify the cloning section to conditionally copy and configure based on VM_TYPE:

For app VM: Copy gradle_transformation and configure application.properties for H2 server mode (JDBC URL: `jdbc:h2:tcp://192.168.33.12:9092/h2db`).

For db VM: Prepare the H2 data directory.

Modify build section: Only build on app VM.

Modify start services:
- For db VM: Start H2 server with flags `-tcpAllowOthers` (allow remote connections) and `-ifNotExists` (allow database creation).
- For app VM: Wait for H2 server to be ready (using `nc` to check port 9092), then start gradle_transformation.

### Step 5: Start the VMs

Navigate to the Part2 folder and run Vagrant:

```bash
cd CA3/Part2
vagrant up
```

This will start both VMs. The app VM will build and run the gradle_transformation application, connecting to the H2 server on the db VM.

### Step 6: Verify the Setup

- Check VM status: `vagrant status`
- SSH into VMs: `vagrant ssh app` or `vagrant ssh db`
- Access the app: `http://localhost:8080/employees`
- Monitor logs for "H2 server is ready" and successful app startup.

![alt text](image.png)

![alt text](image-2.png)