# daverona/cromwell

[![pipeline status](https://gitlab.com/daverona/docker/cromwell/badges/master/pipeline.svg)](https://gitlab.com/daverona/docker/cromwell/commits/master)

This is a repository for Docker images of cromwell.

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
  java -jar /app/cromwell.jar --version
```

It will show the version of cromwell built in the container.

If you like to run as a server with default configuration:

```bash
docker container run --rm \
  --detach \
  --publish 8000:8000 \
  daverona/cromwell
```

Then visit [http://localhost:8000](http://localhost:8000).

## Advanced Usages

If you want to apply your configuration file `app.conf`

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --publish 8000:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  daverona/cromwell
```

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
