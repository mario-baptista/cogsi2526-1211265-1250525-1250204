&nbsp;CA4 README.md with Part1 and Alternative Solution



&nbsp;CA4 — Part 1



We basically took the setup from CA3 Part 2 and improved it using Ansible.  

Now, instead of manually installing things inside the VMs, we used Vagrant to set up the VMs and Ansible (local provisioner) to configure and run the services.



The goal was to make everything: Automated, repeatable (idempotent), resilient to small failures (using ignore\_errors, failed\_when, retries, and until)



1\. Project Structure (Important Files)

&nbsp;   

img\_createFiles



2\. Vagrantfile Configuration



Each VM runs ansible\_local and is assigned a role through site.yml.



img\_VagrantfileChange.jpg)

img\_VagrantfileChange1.jpg)

img\_VagrantfileChange2.jpg)



3\. Ansible Inventory (Which VM is Which)



Both roles run locally within each VM:



!\[hosts.ini](images/img\_hosts.ini.jpg)



4\. site.yml (Role Assignment)



This file tells Ansible which role goes to which VM:



!\[site.yml](images/img\_site.yml.jpg)



5\. Role: Spring Application (spring\_app)



File: ansible/roles/spring\_app/tasks/main.yml

This:



\-Installs Java, Git, Gradle



\-Copies the Spring source code into /opt/gradle\_transformation



\-Configures connection to H2



\-Builds the app using Gradle



\-Creates and starts a Systemd service



!\[main.yml part 1](images/img\_main.yml1.jpg)

!\[main.yml part 2](images/img\_main.yml2.jpg)

!\[main.yml part 3](images/img\_main.yml3.jpg)



Error Handling Used Here



We used:



(ignore\_errors:true): For file sync issues



retries/until: For Gradle sometimes failing



failed\_when: To detect failed builds more accurately



!\[ignore\_errors example](images/img\_ignoreErrors.true.jpg)

!\[retry until example](images/img\_retryUntil.jpg)

!\[failed\_when example](images/img\_failedWhen.jpg)



6\. Role: H2 Database (h2)



File: ansible/roles/h2/tasks/main.yml



This :

-Installs Java and UFW firewall



-Downloads the H2 server JAR



\-Configures firewall access for port 9092



\-Sets up H2 as a Systemd service



!\[h2 main.yml](images/img\_main.yml.jpg)



Systemd Service Template

!\[h2.service.j2](images/img\_h2.service.j2.jpg)



7\. Running the Automation

First Provision Run:

!\[First Run](images/img\_firstRunProvision.jpg)



Second Run (idempotency confirmed):

!\[Second Run](images/img\_secondRunProvision.jpg)



8\. H2 Database Verification

H2 Running as Service:

!\[H2 Server Running](images/img\_H2Server.jpg)



Web Login:

!\[H2 Login](images/img\_H2Login.jpg)



Database Tables:

!\[H2 Tables](images/img\_H2Tables.jpg)



9\. Spring Application Working

Employees:

!\[Employees endpoint](images/img\_employeeWeb.jpg)



Orders:

!\[Orders endpoint](images/img\_ordersWeb.jpg)



Adding Frodo to employees:

!\[Add Frodo](images/img\_addFrodo.jpg)

