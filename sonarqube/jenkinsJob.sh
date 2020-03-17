docker stop ${BUILD_CONTAINER_NAME} || true && docker rm ${BUILD_CONTAINER_NAME} || true
[ ! -d "$HOME/.m2" ] && mkdir .m2 || true
docker run --name ${BUILD_CONTAINER_NAME} \
                 --mount type=bind,source=$HOME/.m2,target=/root/.m2 \
                 -e GITHUB_REPO=${ghprbAuthorRepoGitUrl} \
                 -e FOLDER_NAME=${FOLDER_NAME} \
                 -e BRANCH_NAME=${ghprbSourceBranch} \
                 -e PROJECT_NAME=${PROJECT_NAME} \
                 -e PROJECT_URL=${PROJECT_URL} \
                 -e PROJECT_LOGIN=${PROJECT_LOGIN} \
                 build:${BUILD_IMAGE_TAG}
