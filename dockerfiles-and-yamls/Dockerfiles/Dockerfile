1. Build an image using a Dockerfile: 
# Build an image.
$ docker build -t [username/]<image-name>[:tag] -f <dockerfile-path> 
# Build an image called myimage using the Dockerfile in the same folder where the command was executed. 
$ docker build -t myimage:latest .
2. Check the history of an image: 
# Check the history of the microsoft/sr[:tag] image.
$ docker history microsoft/sr[:tag] 
# Check the history of an image. 
$ docker history [username/]<image-name>[:tag]
3. List the images: 
$ docker images
# OR
$ docker image ls
4. Remove an image from the local registry: 
$ docker rmi [-f] [username/]<image-name>[:tag]
5. Tag an image: 
# Creates an image called "sr" with the tag "v1" for the image microsoft/sr:latest. 
# Repository name must be lowercase.
$ docker tag microsoft/sr:latest sr:v1 
# Creates a new image with the latest tag. 
$ docker tag <image-name> <new-image-name> 
# Creates a new image specifying the "new tag" from an existing image and tag. 
$ docker tag <image-name>[:tag][username/] <new-image-name>[:new-tag]
6. Exporting and importing an image to an external file: 
# Export the image to an external file.
$ docker save -o <filename>.tar 
# Import an image from an external file.
$ docker load -i <filename>.tar


1. Run a container in interactive mode: 
# Run a bash shell inside an image. 
$ docker run -it rhel7/rhel bash  
# Check the release inside a container [root@microsoft/]# cat /etc/centos-release
2. Run a container in detached mode: 
$ docker run --name sr -d -p 8080:8080 microsoft/sr:cmcc_patch
3. Run a detached container in a previously created container network: 
$ docker network create mynetwork 
$ docker run --name mynetwork-test -d --net mynetwork -p 8080:8080 microsoft/sr:cmcc_patch
4. Run a detached container mounting a local folder inside the container: 
$ docker run --name  microsoft-sr -volume -d -v /myfolder:/usr/local/models \
-p 8080:8080 microsoft/sr:cmcc_patch
5. Follow the logs of a specific container: 
$ docker logs -f  microsoft 
$ docker logs -f [container-name|container-id]
6. List containers: 
# List only active containers. 
$ docker ps 
# List all containers.
$ docker ps -a
7. Stop a container: 
# Stop a container. 
$ docker stop [container-name|container-id] 
# Stop a container (timeout = 1 second) 
$ docker stop -t 1
8. Remove a container: 
# Remove a stopped container. 
$ docker rm [container-name|container-id] 
# Force stop and remove a container. 
$ docker rm -f [container-name|container-id] 
# Remove all containers. 
$ docker rm -f $(docker ps-aq) 
# Remove all stopped containers. 
$ docker rm $(docker ps -q -f “status=exited”)
9. Execute a new process in an existing container: 
# Execute and access bash inside a WildFly container. 
$ docker exec -it  microsoft bash


FROM
# Sets the base image for subsequent.
RUN
# Execute commands in a new layer on top of the current image and commit the results.
CMD
# Allowed only once (if many then last one takes effect).
LABEL
# Adds metadata to an image.
EXPOSE
# Informs container runtime that the container listens on the specified network ports at runtime.
ENV
# Sets an environment variable.
ADD 
# Copy new files, directories, or remote file URLs from into the filesystem of the container.
COPY
# Copy new files or directories into the filesystem of the container.
ENTRYPOINT
# Allows you to configure a container that will run as an executable.
VOLUME
# Creates a mount point and marks it as holding externally mounted volumes from native
# host or other containers.
USER
# Sets the username or UID to use when running the image.
WORKDIR
# Sets the working directory for any RUN, CMD, ENTRYPOINT, COPY, and ADD commands.
ARG 
# Defines a variable that users can pass at build-time to the builder using --build-arg.
STOPSIGNAL
# Sets the system call signal that will be sent to the container to exit.

