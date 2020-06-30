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

Run the container:

```bash
docker container run --rm \
  daverona/cromwell \
    cromwell --help
```

It will show how to use cromwell. Note that `cromwell` on the last line is an *alias* of:

```bash
java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS}
```


## Usages

```bash
docker container exec cromwell cat /home/cromwell/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

```bash
docker container exec cromwell bash -c "ssh-keyscan -H 192.168.10.139 2>/dev/null > /home/cromwell/.ssh/known_hosts"
```

### Local Backend

Run cromwell in server mode with default configuration:

```bash
docker container run --rm \
  --detach \
  --user "$(id -u):$(id -g)" \
  --publish 80:8000 \
  --volume $PWD/data:/data \
  daverona/cromwell
```

Then visit [http://localhost](http://localhost).
If you submit a workflow, the output will be generated under `$PWD/data` directory on the host.
Make sure that `$PWD/data` is readable/writable by the user running the above command.
(Otherwise cromwell won't be able to write any output to `$PWD/data` on the host.)
Note that if the command is *omitted*, cromwell runs in *server* mode by default.

> Note that the user running the above command maps to a user `cromwell` in the container,
> which runs a cromwell instance. This `cromwell` user reads and writes to `/data` in the container, 
> to which `$PWD/data` on the host bind-mounts. Therefore the user on the host
> must be able to read and write to `$PWD/data` on the host.
> If you have a specific user on the host to run cromwell, 
> replace `--user` option with the user's uid and gid
> and make sure whatever directory mounted to `/data` in the container is accesible by the user.


To use a custom configuration file, say `app.conf`, run a container:

```bash
docker container run --rm \
  --detach \
  --user "$(id -u):$(id -g)" \
  --publish 80:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/data:/data \
  daverona/cromwell
```

## Advanced Usages

### Image Building

```bash
docker image build \
  --build-arg CROMWELL_UID="$(id -u)" \
  --tag daverona/cromwell \
  .
```

### Local Backend with Docker

Since cromwell runs in a Docker container on your host, your host
is surely able to run workflows which utilize Docker images.

Make sure your `app.conf` contains the following in `Local` section:

```hocon
submit = "/usr/bin/env bash ${script}"

submit-docker = """
  ssh-keyscan -H host.example 2>/dev/null >> /home/cromwell/.ssh/known_hosts \
  && sort /home/cromwell/.ssh/known_hosts | uniq > /tmp/known_hosts.unique \
  && mv /tmp/known_hosts.unique /home/cromwell/.ssh/known_hosts \
  && ssh tom@host.example '/bin/bash --login -c " \
    docker container run \
      --rm \
      --interactive \
      --gpus ... \
      --volume ${cwd}:${docker_cwd} \
      ${docker} ${job_shell} < ${script} \
  "'
"""
```

> Replace `host.example` and `tom` with your host name and your username on the host 
> in the above example. *Never* use `localhost` or any loopback to specify 
> your host. `localhost` and loopbacks in the container are *not* your host *but* 
> the container itself.

Run a cromwell container to allow workflows to use Docker images on the host:

```bash
docker container run --rm \
  --detach \
  --user "$(id -u):$(id -g)" \
  --publish 80:8000 \
  --env CROMWELL_KEYNAME="id_rsa" \
  --env CROMWELL_PRIVKEY="$(cat ${HOME}/.ssh/id_rsa)" \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/data:$PWD/data \
  --workdir $PWD/data \
  daverona/cromwell
```

Make sure that `$PWD/data` is readable/writable by the user running the above command.

> Note that the data directory in cromwell container (i.e. `$PWD/data` on the right hand side), 
> which cromwell reads and writes to, is the same as the data directory on the host (`$PWD/data` on the left hand side). 
> This restriction is to share a same readable/writable directory between cromwell container and workflow's containers.
> A workflow's containers point this directory by using `${cwd}` in `app.conf` file.

### Slurm Backend

For this To work, we assume the following conditions are satisfied:

* Disk volume is shared between slurm and the one running your cromwell
* You have an account on the host where `slumrctld` is running

To run a workflow using slurm:

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/ssh:/root/.ssh \
  --volume /var/local:/var/local \
  --publish 80:8000 \
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
          --volume ${cwd}:${docker_cwd} \
          ${docker} ${job_shell} < ${script} \
      \" \
  "'
"""
```

`mine` is your account on `slurm.example`. Don't forget to 
append the RSA SSH public key contents to `mine`'s `authorized_keys` on `slurm.example`.
I.e. append the contents of `ssh/id_rsa.pub` to `~/mine/.ssh/authorized_keys` on `slurm.example`.

## Building



## References

* Cromwell: [https://cromwell.readthedocs.io/en/stable/](https://cromwell.readthedocs.io/en/stable/)
* Cromwell repository: [https://github.com/broadinstitute/cromwell](https://github.com/broadinstitute/cromwell)
