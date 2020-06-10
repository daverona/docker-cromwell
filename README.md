# daverona/cromwell

[![pipeline status](https://gitlab.com/daverona/docker/cromwell/badges/master/pipeline.svg)](https://gitlab.com/daverona/docker/cromwell/commits/master)

This is a repository for Docker images of [Cromwell](https://github.com/broadinstitute/cromwell).

* GitLab source repository: [https://gitlab.com/daverona/docker/cromwell](https://gitlab.com/daverona/docker/cromwell)
* Docker Hub repository: [https://hub.docker.com/r/daverona/cromwell](https://hub.docker.com/r/daverona/cromwell)

Available versions are:

* [50](https://gitlab.com/daverona/docker/cromwell/-/blob/50/Dockerfile), [latest](https://gitlab.com/daverona/docker/cromwell/-/blob/latest/Dockerfile)
* [49](https://gitlab.com/daverona/docker/cromwell/-/blob/49/Dockerfile)
* [48](https://gitlab.com/daverona/docker/cromwell/-/blob/48/Dockerfile)
* [47](https://gitlab.com/daverona/docker/cromwell/-/blob/47/Dockerfile)

## Installation

Pull the image from Docker Hub repository:

```bash
docker image pull daverona/cromwell
```

## Quick Start

Run the container:

```bash
docker container run --rm \
  daverona/cromwell \
  cromwell --version
```

It will show the version of cromwell built in the container.

To see the help text:

```bash
docker container run --rm \
  daverona/cromwell \
  cromwell --help
```

Notice that `cromwell` is an alias to `java -jar /path/to/cromwell.jar`.
If you don't specify anything, cromwell will run in server mode.
I.e. To run cromwell in server mode with default configuration:

```bash
docker container run --rm \
  --detach \
  --publish 8000:8000 \
  --volume $PWD/data:/var/local \
  daverona/cromwell
```

Then visit [http://localhost:8000](http://localhost:8000).

If you submit a workflow WDL with some input JSON, the result will be
placed under `data` directory.

## Advanced Usages

To run cromwell with a configuration file `app.conf`:

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/data:/var/local \
  --publish 8000:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  daverona/cromwell
```

### Local Backend with Docker

Since you are running cromwell using Docker on your host, you can also run workflows
using Docker on your host, say `host.example`. To do so:

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/ssh:/root/.ssh \
  --volume $PWD/data:/var/local \
  --publish 8000:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  --env EXTERNAL_HOSTS="host.example" \
  daverona/cromwell
```

To this work, your `app.conf` must contains `submit-docker` key
under `Local` backend next to `submit` key:

```
submit = "/usr/bin/env bash ${script}"

submit-docker = """
  ssh mine@host.example '/bin/bash --login -c " \
    docker container run \
      --rm \
      --interactive \
      --volume ${cwd}:${docker_cwd} \
      ${docker} ${job_shell} < ${script} \
  "'
"""
```

You can find an SSH public key under `ssh`. Append the contents of `id_rsa.pub` 
to `mine`'s `authorized_keys` on `host.example`.

### Slurm Backend on Same Host

If you have an HPC backend running on `hpc.example`:

```bash
docker container run --rm \
  --detach \
  --publish 8000:8000 \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/ssh:/root/.ssh \
  --volume $PWD/data:/var/local \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  --env EXTERNAL_HOSTS="host1.example,host2.example" \
  daverona/cromwell
```

The above will generate SSH key pairs under `$PWD/ssh`. 
Copy public key to `hpc.example`.

## References

* [https://github.com/broadinstitute/cromwell](https://github.com/broadinstitute/cromwell)
* [https://cromwell.readthedocs.io/en/stable/](https://cromwell.readthedocs.io/en/stable/)
