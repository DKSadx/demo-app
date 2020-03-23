#!/bin/bash

echo "=== Cloning the demo-app repository ==="
git clone $GITHUB_REPO
cd $FOLDER_NAME
git checkout $BRANCH_NAME

echo "=== Running tests and building app ==="
mvn package sonar:sonar -Dsonar.projectKey=$PROJECT_NAME -Dsonar.host.url=$PROJECT_URL -Dsonar.login=$PROJECT_LOGIN

echo "Tests finished!"
echo "For Sonarqube report visit $PROJECT_URL/dashboard?id=$PROJECT_NAME"
