# daverona/cromwell

[![pipeline status](https://gitlab.com/daverona/docker/cromwell/badges/master/pipeline.svg)](https://gitlab.com/daverona/docker/cromwell/commits/master)

This is a repository for Docker images of [Cromwell](https://github.com/broadinstitute/cromwell).

* GitLab repository: [https://gitlab.com/daverona/docker/cromwell](https://gitlab.com/daverona/docker/cromwell)
* Docker Hub repository: [https://hub.docker.com/r/daverona/cromwell](https://hub.docker.com/r/daverona/cromwell)

Available versions are:

* [51](https://gitlab.com/daverona/docker/cromwell/-/blob/51/Dockerfile), [latest](https://gitlab.com/daverona/docker/cromwell/-/blob/51/Dockerfile)
* [50](https://gitlab.com/daverona/docker/cromwell/-/blob/50/Dockerfile)
* [49](https://gitlab.com/daverona/docker/cromwell/-/blob/49/Dockerfile)
* [48](https://gitlab.com/daverona/docker/cromwell/-/blob/48/Dockerfile)
* [47](https://gitlab.com/daverona/docker/cromwell/-/blob/47/Dockerfile)

## Quick Start

It's recommeded to build your own Docker image for security reason.
Build one using your UID and GID:

```bash
git clone https://gitlab.com/daverona/docker/cromwell.git
cd cromwell
docker image build \
  --build-arg CROMWELL_UID="$(id -u)" \
  --build-arg CROMWELL_GID="$(id -g)" \
  --tag daverona/cromwell \
  .
```

If an error occurs, your UID/GID are taken by Alpine system account. Try without GID.
Remove the source directory after build an image.

> An account `cromwell` which has the same UID and GID as the image builder's is created in the image.
> All cromwell instances will be run by `cromwell` account.

Run a container:

```bash
docker container run --rm \
  daverona/cromwell \
    cromwell --help
```

It will show how to use cromwell. Note that `cromwell` on the last line is an *alias* of:

```bash
java ${JAVA_OPTS} -jar /cromwell/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS}
```


Run cromwell in server mode with default configuration:

```bash
docker container run --rm \
  --detach \
  --publish 80:8000 \
  --volume $PWD/data:/data \
  daverona/cromwell
```

Then visit [http://localhost](http://localhost).
If you submit a workflow, the output will be generated under `$PWD/data` directory on the host.
Make sure that `$PWD/data` is readable and writable by the user who built the image on the host.
(Otherwise cromwell won't be able to write any output to `$PWD/data` on the host.)
Note that if the command is *omitted*, cromwell runs in *server* mode by default.

> Note that `cromwell` in the container runs cromwell server and this account accesses to `/data` 
> in the container, to which `$PWD/data` on the host bind-mounts. Therefore the image builder
> must be able to read from and write to `$PWD/data` on the host because `cromwell`
> in the container has the same UID and GID as the image builder's.

To use a custom configuration file, say `app.conf`, run a container:

```bash
docker container run --rm \
  --detach \
  --publish 80:8000 \
  --env JAVA_OPTS="-Dconfig.file=/cromwell/app.conf" \
  --volume $PWD/app.conf:/cromwell/app.conf:ro \
  --volume $PWD/data:/data \
  daverona/cromwell
```

## Advanced Usages

In this section we show how to log in to remote (or local) host and run workflows. 

### Local Backend with Docker

Since cromwell runs in a Docker container on your host, your host is surely 
able to run workflows which utilize Docker images. The catch is, since cromwell runs in a container,
a workflow cannot create another container in the cromwell container. However `cromwell` can log in 
to your host to run the workflow container.

For `cromwell` account to log in without password to your host, 
`cromwell`'s RSA public key needs to be added to your `${HOME}/.ssh/authorized_keys` file on the host:

```bash
docker container run --rm \
  daverona/cromwell \
    cat /cromwell/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

To make `cromwell` trust your host,
run this (after replace `host.example` with your host's address):

```bash
docker container run --rm \
  daverona/cromwell \
    ssh-keyscan -H host.example 2>/dev/null > known_hosts
```

Make sure your `app.conf` contains the following in `Local` section:

```hocon
submit = "/usr/bin/env bash ${script}"

submit-docker = """
  ssh tom@host.example '/bin/bash --login -c " \
    docker container run \
      --rm \
      --interactive \
      --gpus ... \
      --volume ${cwd}:${docker_cwd} \
      ${docker} ${job_shell} < ${script} \
  "'
"""
```

> Replace `host.example` and `tom` with your host name and your username on the host.
> *Never* use `localhost` or any loopback to specify your host.

Run a cromwell container to allow workflows to use Docker images on the host:

```bash
docker container run --rm \
  --detach \
  --publish 80:8000 \
  --env JAVA_OPTS="-Dconfig.file=/cromwell/app.conf" \
  --volume $PWD/known_hosts:/cromwell/.ssh/known_hosts:ro \
  --volume $PWD/app.conf:/cromwell/app.conf:ro \
  --volume $PWD/data:$PWD/data \
  --workdir $PWD/data \
  daverona/cromwell
```

Make sure that `$PWD/data` is readable/writable by the image builder.

> Note that the data directory in cromwell container (i.e. `$PWD/data` on the right hand side), 
> which cromwell reads from and writes to, is the same as the data directory on the host (`$PWD/data` on the left hand side). 
> This restriction is to share the same directory among cromwell container and workflow's containers.
> A workflow's containers point to this directory with `${cwd}` in `app.conf` file.

### Slurm Backend

For this to work, the following conditions must be satisfied:

* Disk volume is shared among hosts running slurm and the host running cromwell
* You have an account on the host running `slumrctld` daemon

For `cromwell` account to log in to without password to the slurm host,
`cromwell`'s RSA public key needs to be added to your `${HOME}/.ssh/authorized_keys` file on the host:

```bash
docker container run --rm \
  daverona/cromwell \
    cat /cromwell/.ssh/id_rsa.pub > authorized_keys
```

Copy the contents of `authorized keys` to your `${HOME}/.ssh/authorized_keys` on the host running slurmctld daemon
and remove `authorized_keys` in the current directory.

To make `cromwell` trust the host running slurmctld daemon,
run this (after replace `slurmctld.example` with the slurm host's address):

```bash
docker container run --rm \
  daverona/cromwell \
    ssh-keyscan -H slurmctld.example 2>/dev/null > known_hosts
```

Make sure `app.conf` contains `slurm` key and optional `submit-docker` key 
under `Slurm` backend section, like this:

```hocon
submit = """
  ssh tom@slurmctld.example '/bin/bash --login -c " \
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
  ssh tom@slurmctld.example '/bin/bash --login -c " \
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
          --volume ${cwd}:${docker_cwd} \
          ${docker} ${job_shell} < ${script} \
      \" \
  "'
"""
```

> Replace `slurmctld.example` and `tom` with the address of the host running slurmctld daemon
> and your username on this host.

To run a workflow using slurm:

```bash
docker container run --rm \
  --detach \
  --publish 80:8000 \
  --env JAVA_OPTS="-Dconfig.file=/cromwell/app.conf" \
  --volume $PWD/known_hosts:/cromwell/.ssh/known_hosts:ro \
  --volume $PWD/app.conf:/cromwell/app.conf:ro \
  --volume $PWD/data:$PWD/data \
  --workdir $PWD/data \
  daverona/cromwell
```

> Note that the data directory in cromwell container (i.e. `$PWD/data` on the right hand side), 
> which cromwell reads from and writes to, is the same as the data directory on the host (`$PWD/data` on the left hand side). 
> This restriction is to share the same directory among cromwell container, workflow's containers, and slurm workers.
> A workflow's containers point to this directory with `${cwd}` in `app.conf` file.

## References

* Cromwell: [https://cromwell.readthedocs.io/en/stable/](https://cromwell.readthedocs.io/en/stable/)
* Cromwell repository: [https://github.com/broadinstitute/cromwell](https://github.com/broadinstitute/cromwell)
