CA4 - README.md with Part1 and Alternative Solution



CA4 — Part 1



We basically took the setup from CA3 Part 2 and improved it using Ansible.  
Now, instead of manually installing things inside the VMs, we used Vagrant to set up the VMs and Ansible (local provisioner) to configure and run the services.
The goal was to make everything: Automated, repeatable (idempotent), resilient to small failures (using ignore\_errors, failed\_when, retries, and until)

1. Project Structure (Important Files)

![img_createFiles](https://github.com/user-attachments/assets/e6996ca6-68ab-470b-9732-accd9d7b3e90)

2. Vagrantfile Configuration

Each VM runs ansible\_local and is assigned a role through site.yml.

![img_VagrantfileChange](https://github.com/user-attachments/assets/51a98e72-09d3-4bcc-b688-517f66037b71)

![img_VagrantfileChange1](https://github.com/user-attachments/assets/72588c06-b743-4e6f-9b2f-6d9dc2e23c61)

![img_VagrantfileChange2](https://github.com/user-attachments/assets/89743a79-1fbc-41d5-ab70-0121a3d7e00a)


3. Ansible Inventory (Which VM is Which)

Both roles run locally within each VM:

![img_hosts ini](https://github.com/user-attachments/assets/a32b283a-f782-40fd-ac8b-fcb6eca22e3d)


4. site.yml (Role Assignment)

This file tells Ansible which role goes to which VM:

![img_site yml](https://github.com/user-attachments/assets/ec5b303f-be14-4d70-afe9-be371877a5a8)


5. Role: Spring Application (spring\_app)

File: ansible/roles/spring\_app/tasks/main.yml
This:

-Installs Java, Git, Gradle

-Copies the Spring source code into /opt/gradle\_transformation

-Configures connection to H2

-Builds the app using Gradle

-Creates and starts a Systemd service

![img_main yml1](https://github.com/user-attachments/assets/f9a950d4-0644-4904-a2d8-51642da068c8)


6.Error Handling Used Here

We used:

-(ignore_errors:true): For file sync issues

-retries/until: For Gradle sometimes failing

-failed_when: To detect failed builds more accurately

![img_ignoreErrors](https://github.com/user-attachments/assets/2ac60d9c-2dea-412c-b686-3f39f4cd5c7e)

![img_failedWhen](https://github.com/user-attachments/assets/7cef8a22-3001-431b-8bb5-931a4d41fa49)

![img_ignoreErrors true](https://github.com/user-attachments/assets/f8f338b8-d218-4d8c-bb77-96303a3a4885)

![img_retryUntil](https://github.com/user-attachments/assets/f4500e1a-dd13-434f-9950-760c9e64c75f)


7. H2 Database (h2)

File: ansible/roles/h2/tasks/main.yml
This :
-Installs Java and UFW firewall

-Downloads the H2 server JAR

-Configures firewall access for port 9092

-Sets up H2 as a Systemd service

![img_main yml3](https://github.com/user-attachments/assets/bd16b394-5ef5-4f18-ab90-9722cdf497ef)


Systemd Service Template

![img_h2 service j2](https://github.com/user-attachments/assets/eb2ac030-f076-4255-a9ff-77e92b226d1f)


8. Running the Automation

First Provision Run:

![img_firstRunProvision](https://github.com/user-attachments/assets/a04fcdd3-a3c6-43fb-95fc-28cc7e284245)

Second Run (idempotency confirmed):

![img_secondRunProvision](https://github.com/user-attachments/assets/3dba9ea3-aa64-4b55-8ab4-1fcf83e869a3)

9. H2 Database Verification

H2 Running as Service:

![img_H2Server](https://github.com/user-attachments/assets/e30ac784-7f3f-4bc3-b81e-564fbeaa9412)


Web Login:

![img_H2Login](https://github.com/user-attachments/assets/d3407358-9d41-46f7-870e-e012fec5df93)

Database Tables:

![img_H2Tables](https://github.com/user-attachments/assets/c2ba396d-7964-4bc4-b509-d68e49fa185b)


10. Spring Application Working
    
Employees:

![img_employeeWeb](https://github.com/user-attachments/assets/62977a59-64c0-41e5-8753-47e1dad1e45f)

Orders:

![img_ordersWeb](https://github.com/user-attachments/assets/fa0159dd-f807-4213-b8c6-1f7941480d0e)

Adding Frodo to employees:

![img_addFrodo](https://github.com/user-attachments/assets/661b9fa9-2218-4903-b613-8c93a1d3411e)

![img_updatedWeb](https://github.com/user-attachments/assets/9db48eb1-62fe-4c5d-8a99-9b41d3682b27)


