## Pushing docker image into dockerhub

To push a Docker image to Docker Hub, follow these steps:

Login to Docker Hub using the Docker CLI:

`docker login`

Build your Docker image using the docker build command. For example:

`docker build -t yourdockerhubusername/yourimage:tag .`

This will build the Docker image and tag it with your Docker Hub username, the name of your image, and the desired tag.

Push the Docker image to Docker Hub using the docker push command. For example:

`docker push yourdockerhubusername/yourimage:tag`

This will push the Docker image to Docker Hub, making it available for other users to pull and use.

Note: Make sure that you have created a Docker Hub account and have permissions to push images to the repository you are targeting.
