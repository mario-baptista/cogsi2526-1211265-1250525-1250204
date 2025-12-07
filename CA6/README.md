# Alternative solution

## 1. Introduction

In our original setup, I used Jenkins as the main configuration management and CI/CD automation tool. Jenkins is a well known, highly customizable automation server, but it requires a self managed environment (installations, plugins, agents, etc.).
For this alternative solution, I decided to explore GitHub Actions because it is cloud hosted, integrated directly into GitHub repositories, and generally easier to work with for small to medium projects.

Here i will ,explain how GitHub Actions compares with Jenkins, highlights the differences in features, and present how GitHub Actions could be used to achieve the same goals required for this assignment.

## 2. Alternative Tool: GitHub Actions

GitHub Actions is an automation platform built into GitHub that lets you create workflows triggered by events (push, pull request, schedules, etc.).
It can run CI/CD pipelines, build and test applications, deploy to servers or containers, and manage configuration tasks through scripts.

Key characteristics:

-Cloud based and maintained by GitHub

-YAML: defined workflows stored inside the repository

-Runs jobs on GitHub-hosted runners or self-hosted runners

-Large marketplace of pre made actions

-Strong integration with GitHub ecosystem (issues, PRs, secrets, packages)

## 3. Comparison: GitHub Actions vs Jenkins

|Feature	                        |Jenkins (Base Solution)	                                |GitHub Actions (Alternative)                                          |
|---------------------------------|---------------------------------------------------------|----------------------------------------------------------------------|
|Hosting    	                    |Self hosted (on-prem, local VM, cloud instance)	        |Cloud hosted by GitHub (optional self-hosted runners)                 |
|Setup Complexity	                |Requires installation, configuration, plugin management	|No installation; workflows created directly in repository             | 
|Pipeline Syntax	                |Jenkinsfile (Groovy like DSL)	                          |YAML workflows                                                        |
|Integration	                    |Integrates with many systems via plugins               	|Best integration with GitHub repos, supports container, cloud services|
|Plugins	                        |Very large plugin ecosystem	                            |“Actions” marketplace (simpler, but not as deep as Jenkins plugins)   |
|Scalability	                    |Requires infrastructure scaling and maintenance	        |Automatic scaling (GitHub-hosted runners)                             |
|Cost	                            |Free but needs own server, scaling costs	                |Free minutes for public repos, paid for private repo runners          |
|User Interface	                  |Traditional dashboard, plugins enhance UI	              |GitHub UI (modern, embedded into repo)                                |
|Configuration Management Support |	Strong integration with Ansible, Chef, Terraform, etc. 	|Also supports these tools, but often via community actions            |

GitHub Actions trades some of Jenkins depth and flexibility for simplicity, easier onboarding, and tighter repo integration. For student projects, small teams, or GitHub centred workflows, GitHub Actions is often more practical.

## 4. CI/CD Features Comparison
### 4.1 CI Pipeline

Jenkins:

-Build triggers (webhooks, SCM polling)

-Distributed build nodes

-Jenkinsfile stored in repo

-Requires manual setup of agents and environment

GitHub Actions:

-Event-based triggers (push, PR, tags, releases)

-Preconfigured runners (Ubuntu/Windows/macOS)

-Faster to set up since environment is prebuilt

-Marketplace actions simplify workflows (e.g., checkout, setup-node)

GitHub Actions is easier to get started with for CI, while Jenkins allows more fine tuned control for enterprise CI setups.

### 4.2 CD Pipeline

Jenkins:

-Integrates with servers through SSH, Docker, Kubernetes, cloud providers, etc.

-Many plugins but some require manual upkeep

-Can orchestrate complex, multistage deployments

GitHub Actions:

-Often uses actions such as “deploy to Azure/AWS/Heroku/DockerHub”

-Uses GitHub Environments for gated deployments (approval flow, secrets)

-Self hosted runners allow custom deployments to on-prem servers

GitHub Actions is very good for cloud deployments, especially GitHub Pages, Docker, Kubernetes, and cloud providers.
Jenkins might be better when the infrastructure is fully on-premise or very custom.

## 5. How GitHub Actions can solve the same goal (design only)

Below I describe how GitHub Actions would be used to achieve the same tasks that Jenkins was used for in the original assignment. This is a design explanation, not a full implementation.

5.1 Workflow Structure

In GitHub Actions, all workflows are stored inside:

``
.github/workflows/
``

For example:

``
.github/workflows/ci-cd-pipeline.yml
``

This file would define jobs like:

-Build job

-Test job

-Linting job

-Deployment job

These jobs can run in sequence or in parallel depending on the workflow design.

### 5.2 Example goals mapping (Conceptual)

Below I map common assignment goals to GitHub Actions equivalents:

#### Goal 1: Automated build

GitHub Actions Job:

```
runs-on: ubuntu-latest
steps:
  - uses: actions/checkout@v4
  - name: Install dependencies
    run: npm install   # example for JS project
  - name: Build project
    run: npm run build
```

#### Goal 2: Automated testing
```
- name: Run tests
  run: npm test
   ```

#### Goal 3: Static code analysis / linting
```
- name: Lint code
  run: npm run lint
```

#### Goal 4: Packaging / artifact creation

GitHub Actions supports uploading build artifacts:

```
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    name: build-files
    path: ./dist
```

#### Goal 5: Deployment to server / cloud

Depending on the environment:

Deploy to DockerHub:
```
- name: Login to DockerHub
  uses: docker/login-action@v3
- name: Build and push image
  run: docker build -t myimage:tag . && docker push myimage:tag
```

Deploy to a VM through SSH:
```
- name: Deploy via SSH
  uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.SERVER_IP }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    script: |
      docker pull myimage:tag
      docker compose up -d
```

#### Goal 6: Secrets and credential management

GitHub Actions uses GitHub Secrets, which are encrypted and injected into workflows.
This replaces Jenkins credentials storage.

### 6. Advantages of Using GitHub Actions for This Assignment

-No need to install or maintain Jenkins server

-Easy to embed workflows directly in repository for documentation

-Built-in security for secrets

-Automatic versioning of pipelines since they are stored in GitHub

-Works well even for small student projects

-Encourages good DevOps practices with minimal overhead

### 7. Disadvantages / Limitations

-Harder to implement extremely custom or legacy workflows

-Pipeline logic is restricted to GitHub environment unless using self hosted runners

-Paid minutes may become an issue for private repositories

-Jenkins has more enterprise-level plugins and integrations

### 8. Conclusion

GitHub Actions serves as a strong, modern alternative to Jenkins for CI/CD and configuration management activities. While Jenkins remains more flexible for large enterprise environments, GitHub Actions is easier to use, faster to set up, and deeply integrated into the GitHub ecosystem, making it very suitable for student projects or smaller development teams.
All the goals from the original Jenkins-based solution can be achieved using GitHub Actions through well designed YAML workflows, GitHub Secrets, and a combination of marketplace actions and custom scripts.






GitHub Actions trades some of Jenkins’ depth and flexibility for simplicity, easier onboarding, and tighter repo integration. For student projects, small teams, or GitHub-centric workflows, GitHub Actions is often more practical.
