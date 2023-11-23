# Jupyter-Deploy-Docker-Sudo
Deploying JupyterHub reference with Docker and Sudo enabled for each user

jupyterhub-deploy-docker provides a reference deployment of **[JupyterHub](https://github.com/jupyterhub/jupyterhub)**, a multi-user **[Jupyter Notebook](https://jupyter.org/)** environment, on a single host using **[Docker](https://docs.docker.com/)**.

This repository was cloned from [jupyterhub-deploy-docker](https://github.com/jupyterhub/jupyterhub-deploy-docker) created by [Minrk](https://github.com/minrk)

## Technical Overview

- Key components of this reference deployment are:

- Host: Runs the JupyterHub components in a Docker container on the host.

- Authenticator: Uses Native Authenticator to authenticate users. Any user will be allowed to sign up.

- Spawner:Uses DockerSpawner to spawn single-user Jupyter Notebook servers in separate Docker containers on the same host.

- Persistence of Hub data: Persists JupyterHub data in a Docker volume on the host.

- Persistence of user notebook directories: Persists user notebook directories in Docker volumes on the host.

## Prerequisites

### Docker

This deployment uses Docker, via [Docker Compose](https://docs.docker.com/compose/), for all the things.

1. Use [Docker's installation instructions](https://docs.docker.com/engine/install/)
   to set up Docker for your environment.

## Authenticator setup

This deployment uses [JupyterHub Native Authenticator](https://native-authenticator.readthedocs.io/en/latest/) to authenticate users.

1. An single `admin` user will be enabled by default. Any user will be allowed to sign up.

## Build the JupyterHub Docker image

1. Use [docker-compose](https://docs.docker.com/compose/reference/) to build
   the JupyterHub Docker image, this image is used by docker compose:

   ```bash
   docker-compose build
   ```

## Sudo enabled

Sudo is enabled with a custom image in the dockerfile found in `config/`, this image is passed through Docker Compose so that every container created by the user has the ability to use sudo.

1. Build image

```bash
docker build -t jupyter-sudo:latest -f Dockerfile.sudo .

```

## Customization: Jupyter Notebook Image

You can configure JupyterHub to spawn Notebook servers from any Docker image, as
long as the image's `ENTRYPOINT` and/or `CMD` starts a single-user instance of
Jupyter Notebook server that is compatible with JupyterHub.

To specify which Notebook image to spawn for users, you set the value of the
`DOCKER_NOTEBOOK_IMAGE` environment variable to the desired container image.

Whether you build a custom Notebook image or pull an image from a public or
private Docker registry, the image must reside on the host.

If the Notebook image does not exist on the host, Docker will attempt to pull the
image the first time a user attempts to start his or her server. In such cases,
JupyterHub may timeout if the image being pulled is large, so it is better to
pull the image to the host before running JupyterHub.

This deployment defaults to the
[jupyter/base-notebook](https://hub.docker.com/r/jupyter/base-notebook/)
Notebook image, which is built from the `base-notebook`
[Docker stacks](https://github.com/jupyter/docker-stacks).

You can pull the image using the following command:

```bash
docker pull jupyter/base-notebook:latest
```

## Run JupyterHub

Run the JupyterHub container on the host.

To run the JupyterHub container in detached mode:

```bash
docker compose up -d
```

Once the container is running, you should be able to access the JupyterHub console at `http://localhost:8000`.

To bring down the JupyterHub container:

```bash
docker compose down
```

---

## FAQ

### How can I view the logs for JupyterHub or users' Notebook servers?

Use `docker logs <container>`. For example, to view the logs of the `jupyterhub` container

```bash
docker logs jupyterhub
```

### How do I specify the Notebook server image to spawn for users?

In this deployment, JupyterHub uses DockerSpawner to spawn single-user
Notebook servers. You set the desired Notebook server image in a
`DOCKER_NOTEBOOK_IMAGE` environment variable.

JupyterHub reads the Notebook image name from `jupyterhub_config.py`, which
reads the Notebook image name from the `DOCKER_NOTEBOOK_IMAGE` environment
variable:

```python
# DockerSpawner setting in jupyterhub_config.py
c.DockerSpawner.image = os.environ['DOCKER_NOTEBOOK_IMAGE']
```

### If I change the name of the Notebook server image to spawn, do I need to restart JupyterHub?

Yes. JupyterHub reads its configuration, which includes the container image
name for DockerSpawner. JupyterHub uses this configuration to determine the
Notebook server image to spawn during startup.

If you change DockerSpawner's name of the Docker image to spawn, you will
need to restart the JupyterHub container for changes to occur.

In this reference deployment, cookies are persisted to a Docker volume on the
Hub's host. Restarting JupyterHub might cause a temporary blip in user
service as the JupyterHub container restarts. Users will not have to login
again to their individual notebook servers. However, users may need to
refresh their browser to re-establish connections to the running Notebook
kernels.

### How can I back up a user's notebook directory?

There are multiple ways to [Back up and restore data](https://docs.docker.com/desktop/backup-and-restore/) in Docker containers.

Suppose you have the following running containers:

```bash
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"

    CONTAINER ID        IMAGE                    NAMES
    bc02dd6bb91b        jupyter/minimal-notebook jupyter-jtyberg
    7b48a0b33389        jupyterhub               jupyterhub
```

In this deployment, the user's notebook directories (`/home/jovyan/work`) are backed by Docker volumes.

```bash
    docker inspect -f '{{ .Mounts }}' jupyter-jtyberg

    [{jtyberg /var/lib/docker/volumes/jtyberg/_data /home/jovyan/work local rw true rprivate}]
```
