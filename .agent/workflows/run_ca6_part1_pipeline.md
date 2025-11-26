---
description: How to configure and run the Jenkins pipeline for CA6 Part 1
---

# Run CA6 Part 1 Pipeline

This workflow guides you through setting up the Jenkins job to run the pipeline defined in `CA6/Part1/Jenkinsfile`.

## Prerequisites

1.  **Jenkins Installed**: Ensure Jenkins is running.
2.  **Plugins**: Install the **Ansible** plugin in Jenkins.
3.  **Tools**: Ensure `ansible` and `java` (JDK 17) are installed on the machine running Jenkins.
4.  **Vagrant VMs**: The VMs must be running.

## Steps

### 1. Start the VMs
Ensure the Blue and Green VMs are up and running.

```bash
cd CA6/Part1
vagrant up
```

### 2. Create a New Pipeline Job
1.  Open Jenkins in your browser (usually `http://localhost:8080`).
2.  Click **New Item**.
3.  Enter a name (e.g., `CA6-Part1-Pipeline`).
4.  Select **Pipeline**.
5.  Click **OK**.

### 3. Configure the Pipeline
1.  Scroll down to the **Pipeline** section.
2.  Set **Definition** to **Pipeline script from SCM**.
3.  Set **SCM** to **Git**.
4.  **Repository URL**:
    *   If running Jenkins locally: Enter the absolute path to your repository:
        `file:///Users/mariozito/Desktop/COGSI/cogsi2526-1211265-1250525-1250204`
    *   If using a remote Jenkins: Push your code to GitHub/GitLab and use that URL.
5.  **Branch Specifier**: `*/master` (or `*/main` depending on your branch).
6.  **Script Path**: `CA6/Part1/Jenkinsfile`.
7.  Click **Save**.

### 4. Run the Pipeline
1.  Click **Build Now** on the left menu.
2.  Click on the build number (e.g., `#1`) in the Build History.
3.  Click **Console Output** to monitor progress.

## Troubleshooting
-   **Ansible Plugin Error**: If `ansiblePlaybook` is not found, install the "Ansible" plugin via Manage Jenkins > Plugins.
-   **Permission Denied**: If Jenkins cannot access the private key, you may need to adjust permissions or run Jenkins as a user with access.
-   **Host Key Verification**: The inventory file sets `StrictHostKeyChecking=no`, so this should be handled, but ensure Jenkins can reach the VM IPs (192.168.56.10).
