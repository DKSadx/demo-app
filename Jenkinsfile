node {
  def build

  stage('Build app') {
      // Stop and remove container if it exists
      sh "docker stop ${BUILD_CONTAINER_NAME} || true && docker rm ${BUILD_CONTAINER_NAME} || true"
      sh " [ ! -d \"\$HOME/.m2\" ] && mkdir -p \$HOME/.m2 || true"
      sh '''
      docker run --name ${BUILD_CONTAINER_NAME} \
                 --mount type=bind,source=\$HOME/.m2,target=/root/.m2 \
                 -e GITHUB_REPO=${GITHUB_REPO} \
                 -e FOLDER_NAME=${FOLDER_NAME} \
                 -e BRANCH_NAME=${BRANCH_NAME} \
                 -e MICROSERVICE=${MICROSERVICE} \
                 -e UID=\$(id -u) \
                 -e GID=\$(id -g) \
                 build:v1
      '''
  }

  stage('Copy jar file to host') {
      sh "docker cp ${BUILD_CONTAINER_NAME}:${FOLDER_NAME}/${MICROSERVICE}/jar ."
      sh "docker cp ${BUILD_CONTAINER_NAME}:${FOLDER_NAME}/${MICROSERVICE}/target/${JAR_FILE}.jar jar/"
  }

  stage('Build runtime image') {
    sh "cd jar && docker build -t ${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG} ."
  }

  stage('Tag and push the image to docker hub') {
    withDockerRegistry([ credentialsId: "${DOCKER_HUB_CREDENTIALS}", url: "" ]) {
      sh "docker tag ${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG} ${DOCKER_HUB_USER}/${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG}"
      sh "docker push ${DOCKER_HUB_USER}/${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG}"
    }
  }

}
