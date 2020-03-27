pipeline {
  agent any
  triggers {
    GenericTrigger(
     genericVariables: [
      [key: 'DEPLOY_IMAGE_TAG', value: '$.release.tag_name'],
      [key: 'RELEASE_NAME', value: '$.release.name']
     ],
     
     token: 'demo-app',

     printContributedVariables: true,
     printPostContent: true,

     regexpFilterText: '$RELEASE_NAME',
     regexpFilterExpression: env.MS_NAME

    )
  }

  stages {

    stage('Build app') {
      steps {
        // Stop and remove container if it exists
        sh "docker stop ${BUILD_CONTAINER_NAME} || true && docker rm ${BUILD_CONTAINER_NAME} || true"
        sh '''
          docker run --name ${BUILD_CONTAINER_NAME} \
                    --mount type=bind,source=\$HOST_HOME_PATH/.m2,target=/root/.m2 \
                    -e GITHUB_REPO=${GITHUB_REPO} \
                    -e FOLDER_NAME=${FOLDER_NAME} \
                    -e BRANCH_NAME=${BRANCH_NAME} \
                    -e MICROSERVICE=${MICROSERVICE} \
                    -e UID=\$(id -u) \
                    -e GID=\$(id -g) \
                    ${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG}
        '''
      }
    }

    stage('Copy jar file to host') {
      steps {
        sh "docker cp ${BUILD_CONTAINER_NAME}:${FOLDER_NAME}/${MICROSERVICE}/jar ."
        sh "docker cp ${BUILD_CONTAINER_NAME}:${FOLDER_NAME}/${MICROSERVICE}/target/${JAR_FILE}.jar jar/"
      }
    }

    stage('Build runtime image') {
      steps {
        sh "cd jar && docker build -t ${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG} ."
      }
    }

    stage('Tag and push the image to docker hub') {
      steps {
        withDockerRegistry([ credentialsId: "${DOCKER_HUB_CREDENTIALS}", url: "" ]) {
          sh "docker tag ${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG} ${DOCKER_HUB_USER}/${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG}"
          sh "docker push ${DOCKER_HUB_USER}/${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG}"
        }
      }
    }

    stage('Upgrade demo-app helm chart') {
      steps {
        sh '''
          git clone ${GITHUB_REPO} && cd ${FOLDER_NAME}
          git checkout ${BRANCH_NAME}
          helm upgrade ${CHART_NAME} ${CHART_PATH} --set=${MS_NAME}.dep.image=${DEPLOY_IMAGE_NAME}:${DEPLOY_IMAGE_TAG}
        '''
      }
    }
  }
}

