[![Image pulls](https://img.shields.io/docker/pulls/131hub/shellwin)](https://hub.docker.com/r/131hub/shellwin)
[![Image version](https://img.shields.io/docker/v/131hub/shellwin)](https://hub.docker.com/r/131hub/shellwin)
[![Image size](https://img.shields.io/docker/image-size/131hub/shellwin)](https://hub.docker.com/r/131hub/shellwin)

# Motivation
[`131hub/shellwin`](https://hub.docker.com/r/131hub/shellwin) is a **docker image** bringing simple OpenSSH shell server container to your windows host. You can use it as a DOCKER_HOST gateway (using ssh) to a windows host.

# Configuration
Define `SHELL_AUTHORIZED_USERS` (path to authorized key file) and `SHELL_SERVER_KEY_PATH` as environnement vars.
Permission on those file will be automaticaly set by the container.

# Forced user `root`
The only available user is `root`. So connect to this container using `ssh root@[host]`.


# Usage in a swarm
```
services:
  shellwin:
    image: 131hub/shellwin

    # publish ssh server
    ports:
      - 22:22

    networks:
      - default

    volumes:
      # forward docker pipe from host to container
      - type: npipe
        source: \\.\pipe\docker_engine
        target: \\.\pipe\docker_engine

```

# Credits
* [131](https://github.com/131)
