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

It will show how to use cromwell. Note that `cromwell` in the command is an *alias* of:

```bash
java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS}
```

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
Make sure that `$PWD/data` is owned by the user running the above command.
(Otherwise cromwell won't be able to write any output to `$PWD/data` on the host.)
Note that if the command is *omitted*, cromwell runs in *server* mode by default.

> Note that there is a user `cromwell` in the container who runs the cromwell instance.
> And note that `cromwell` user in the container is set to the user on the host running the command.
> Therefore the host directory (i.e. `$PWD/data`), which is bind-mounted to `/data` in the container,
> must be writable by the user on the host.
> If you have a specific user on the host to run cromwell, 
> replace `--user` option with the user's uid and gid
> and make sure whatever directory mounted to `/data` in the container is writable by the user.

## Advanced Usages

To run cromwell with a configuration file, say `app.conf`:

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

### Local Backend with Docker

Since cromwell runs in a Docker container on your host, the host
obviously has Docker server installed. To run a workflow using Docker on the host, 
say `host.example`:

```bash
docker container run --rm \
  --detach \
  --volume $PWD/app.conf:/app/app.conf:ro \
  --volume $PWD/ssh:/root/.ssh \
  --volume $PWD/data:/var/local \
  --publish 80:8000 \
  --env JAVA_OPTS="-Dconfig.file=/app/app.conf" \
  --env CROMWELL_ARGS="" \
  --env EXTERNAL_HOSTS="host.example" \
  daverona/cromwell
```

In this case the configuration file `app.conf` must contain `submit-docker` key
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

## References

* Cromwell: [https://cromwell.readthedocs.io/en/stable/](https://cromwell.readthedocs.io/en/stable/)
* Cromwell repository: [https://github.com/broadinstitute/cromwell](https://github.com/broadinstitute/cromwell)
