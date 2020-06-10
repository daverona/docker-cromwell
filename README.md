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
If the command (in this case `cromwell --help`) is omitted after image name,
cromwell will run in server mode.
I.e. To run cromwell in server mode with default configuration:

```bash
docker container run --rm \
  --detach \
  --publish 8000:8000 \
  --volume $PWD/data:/var/local \
  daverona/cromwell
```

Then visit [http://localhost:8000](http://localhost:8000).
If you submit a workflow (WDL file) with inputs (JSON file), the output will be
under `data` directory.

## Advanced Usages

To run cromwell with a configuration file, say `app.conf`:

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

Since cromwell runs in a Docker container on your host, your host
is Docker-capable. To run a workflow using Docker on your host, 
say `host.example`:

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

To this work the configuration file `app.conf` must contain `submit-docker` key
under `Local` backend section next to `submit` key. Like this:

```hocon
submit = "/usr/bin/env bash ${script}"

submit-docker = """
  ssh mine@host.example '/bin/bash --login -c " \
    docker container run \
      --rm \
      --interactive \
      --gpus ... \
      --volume ${cwd}:${docker_cwd} \
      ${docker} ${job_shell} < ${script} \
  "'
"""
```

And you can find an RSA SSH public key at `ssh/id_rsa.pub`. Append it
to `mine`'s `authorized_keys` on `host.example`, where `mine` is your account
on your host `host.example`.

### Slurm Backend

To this work, we assume the following conditions are satisfied:

* Disk volume is shared between slurm and the one running your cromwell
* You have an account on the host where `slumrctld` is running

To run a workflow using slurm:

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/ssh:/root/.ssh \
  --volume /var/local:/var/local \
  --publish 8000:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  --env EXTERNAL_HOSTS="slurm.example" \
  daverona/cromwell
```

Note that bind-mount for data is changed to `/var/local`. This is because
slurm needs to access what cromwell generates and vice versa. 
`slurm.example` is the host running `slurmctld`.

`app.conf` must contain `slurm` key and optional `submit-docker` key under `Slurm` backend section,
like this:

```hocon
submit = """
  ssh mine@slurm.example '/bin/bash --login -c " \
    sbatch \
      --partition=... \
      --job-name=${job_name} \
      --chdir=${cwd} \
      --output=${out} \
      --error=${err} \
      --cpus-per-task=... \
      --gres=gpu:... \
      --mem-per-cpu=... \
      --time=... \
      --wrap=\"/bin/bash ${script}\" \
  "'
"""

submit-docker = """
  ssh mine@slurm.example '/bin/bash --login -c " \
    sbatch \
      --partition=... \
      --job-name=${job_name} \
      --chdir=${cwd} \
      --cpus-per-task=... \
      --gres=gpu:... \
      --mem-per-cpu=... \
      --time=... \
      --wrap=\" \
        docker container run \
          --cidfile ${docker_cid} \
          --rm \
          --interactive \
          --gpus ... \
          ${true="--gpus " false="" defined(gpu)}${gpu} \
          --volume ${cwd}:${docker_cwd} \
          ${docker} ${job_shell} < ${script} \
      \" \
  "'
"""
```

`mine` is your account on `slurm.example`. Don't forget to 
append the RSA SSH public key contents to `mine`'s `authorized_keys` on `slurm.example`.
I.e. append the contents of `ssh/id_rsa.pub` to `~/mine/.ssh/authorized_keys` on `slurm.example`.

## References

* [https://github.com/broadinstitute/cromwell](https://github.com/broadinstitute/cromwell)
* [https://cromwell.readthedocs.io/en/stable/](https://cromwell.readthedocs.io/en/stable/)
