# DevOps workflow for Java (Vaadin) app - microservices
<hr />

Table of contents
=================

<!--ts-->
   * [Description](#Description)
   * [Requirements](#Requirements)
   * [Setup](#Setup)
   * [Installation](#Installation)
     * [Automatic](#Automatic)
     * [Manual](#Manual)
        * [Demo-app](#Demo-app)
        * [Jenkins](#Jenkins)
          * [Environment setup](#Environment-setup)
          * [Build and deploy pipelines](#Build-and-deploy-pipelines)
          * [SonarQube job](#SonarQube-job)
          * [WebHooks](#WebHooks)
        * [SonarQube](#SonarQube)
        * [Monitoring](#Monitoring)
          * [Elasticsearch](#Elasticsearch)
          * [Filebeat](#Filebeat)
          * [Kibana](#Kibana)
<!--te-->

## Description:

- Every component is deployed with Helm (Kubernetes)
- On every pull request, GitHub will trigger Jenkins via a webhook and Jenkins will start the SonarQube code quality checks.
- After every new release (on GitHub), Jenkins will build the new Docker images, push them to Docker Hub and upgrade the app to a new version.
- Elastic stack is used for monitoring the logs.


## Requirements:

- Kubernetes cluster

- Helm v2.1x.x with **tiller** already deployed

- curl (optional)

## Setup

```sh
# Clone the repository
git clone https://github.com/DKSadx/demo-app.git && cd demo-app/
# Checkout v1 branch
git checkout v1
```

Installation
============
<hr />

## Automatic:

Run the `install.sh` script and all the components will be installed

```sh
./install.sh
```

## Manual:

```sh
cd helm-charts/
```
<br />

*NOTE: You can change the default chart values inside the `helm-charts/CHART_NAME/values.yaml` file*

## Demo-app


Install the demo-app chart

```sh
helm install -f demo-app/values.yaml ./demo-app --name demo-app --namespace demo-app
```
<br />

## Jenkins

<hr />

### Environment setup


Change the read and write permissions for docker.sock (required if using Jenkins with Docker)

```sh
chmod 666 /var/run/docker.sock
```

Set hosts **$HOME** path as an environment variable inside Jenkins slave container (required for .m2 caching)

```sh
sed -i 's@<HOST_HOME_PATH>@'"$HOME"'@' ./jenkins/values.yaml
```

Create ClusterRoleBinding for Jenkins (required if using kubectl or helm with Jenkins)

```sh
kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts:jenkins
```

Install Jenkins chart with custom values

```sh
helm install -f jenkins/values.yaml stable/jenkins --name jenkins --namespace jenkins
```

### Build and deploy pipelines

Required plugin: Generic Webhook Trigger Plugin

Pull the build image:
```sh
docker pull dkabh/build:v1
```

Create a Jenkins pipeline and use this repository as SCM for the Jenkinsfile

Define these parameters inside the pipeline job:

| Parameters   | Example
|----------|:-------------:
|MS_NAME  | admin
|FOLDER_NAME  | demo-app
|GITHUB_REPO  | https://github.com/DKSadx/demo-app.git
|MICROSERVICE  | admin-application
|BRANCH_NAME  | v1
|BUILD_IMAGE_NAME  | build
|BUILD_IMAGE_TAG  | v1
|BUILD_CONTAINER_NAME  | buildA
|DEPLOY_IMAGE_NAME  | admin-deploy
|JAR_FILE  | admin-application-0.0.1-SNAPSHOT
|DOCKER_HUB_USER  | [username or repo]
|DOCKER_HUB_CREDENTIALS  | [jenkins credentials id]
|CHART_NAME  | demo-app
|CHART_PATH  | ./helm-charts/demo-app

<br />

### SonarQube job

Required plugin: GitHub Pull Request Builder

Pull the SonarQube build image:
```sh
docker pull dkabh/sq:v1
```

Create a freestyle job, add a new build step (execute shell) and paste the code from `./helm-charts/sonarqube/jenkinsJob` into the input field

| Parameters   | Example
|----------|:-------------:
|FOLDER_NAME  | demo-app
|BUILD_CONTAINER_NAME  | buildSQ
|BUILD_IMAGE_NAME  | dkabh/sq
|BUILD_IMAGE_TAG  | v1
|PROJECT_NAME  | [SQ_PROJECT_NAME]
|PROJECT_URL  | [SQ_URL]
|PROJECT_LOGIN  | [SQ_LOGIN_TOKEN]

<br />

### WebHooks

_**1. For releases**_

Add a new webhook in the github repository settings and point it to the Jenkins public ip
`JENKINS_PUBLIC_IP/generic-webhook-trigger/invoke?token=TOKEN_HERE`

_**2. For pull requests**_

Add a new webhook in the github repository settings and point it to the Jenkins public ip
`JENKINS_PUBLIC_IP/ghprbhook/`

<br />

## SonarQube

Plugins installed:
  - SonarJava
  - Java I18n Rules

Add SonarQube repository (stable/sonarqube is deprecated)
```sh
helm repo add oteemocharts https://oteemo.github.io/charts
```

Install SonarQube with custom values

```sh
helm install -f sonarqube/values.yaml oteemocharts/sonarqube --name sonarqube --namespace sonarqube
```

<br />

Monitoring
============

Add elastic repository:

```sh
helm repo add elastic https://helm.elastic.co
```

Install Elasticsearch, Filebeat and Kibana


### Elasticsearch

```sh
helm install -f elasticsearch/values.yaml elastic/elasticsearch --name elasticsearch --namespace monitoring
```

### Filebeat

```sh
helm install -f filebeat/values.yaml elastic/filebeat --name filebeat --namespace monitoring
```

### Kibana

```sh
helm install -f kibana/values.yaml elastic/kibana --name kibana --namespace monitoring
```