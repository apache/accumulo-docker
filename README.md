# Apache Accumulo Docker Image

**This is currently a work in progress that depends on unreleased features of Accumulo and will not be ready
for use until after Accumulo 2.0.0 is released.**  Sometime after Accumulo 2.0.0 is released this project
will make its first release. Eventually, this will project will create a `apache/accumulo` image at DockerHub.
Until then, you will need to build your own image.

## Obtain the Docker image

To obtain the docker image created by this project, you can either pull it from DockerHub at
`apache/accumulo` or build it yourself. To pull the image from DockerHub, run the command below:

    docker pull apache/accumulo

While it is easier to pull from DockerHub, the image will default to the software versions below:

| Software    | Version        |
|-------------|----------------|
| [Accumulo]  | 2.0.0-SNAPSHOT |
| [Hadoop]    | 2.7.3          |
| [Zookeeper] | 3.4.9          |

If these versions do not match what is running on your cluster, you should consider building
your own image with matching versions. However, Accumulo must be 2.0.0+. Below are instructions for
building an image:

1. Clone the Accumulo docker repo

        git clone git@github.com:apache/accumulo-docker.git

2. Until Accumulo 2.0.0 is released, build a Accumulo tarball distribution and copy it to the root
   directory of the repo.

        git clone git@github.com:apache/accumulo.git
        cd accumulo/
        mvn clean package
        cp assemble/target/accumulo-2.0.0-SNAPSHOT-bin.tar.gz /path/to/accumulo-docker/

3. Build the default Accumulo docker image using the command below.

        cd /path/to/accumulo-docker
        docker build -t accumulo .

   Or build the Accumulo docker image with specific versions of Hadoop, Zookeeper, etc using the command below:

        docker build --build-arg ZOOKEEPER_VERSION=3.4.8 --build-arg HADOOP_VERSION=2.7.0 -t accumulo .

## Image basics

The entrypoint for the Accumulo docker image is the `accumulo` script. While the primary use
case for this image is to start Accumulo processes (i.e tserver, master, etc), you can run other
commands in the `accumulo` script to test out the image:

```bash
# No arguments prints Accumulo command usage
docker run accumulo
# Print Accumulo version
docker run accumulo version
# Print Accumulo classpath
docker run accumulo classpath
```

# Run Accumulo using Docker

Before you can run Accumulo services in Docker, you will need to install Accumulo, configure `accumulo-site.xml`,
and initialize your instance with `--upload-accumulo-site`. This will upload configuration to Zookeeper and limit
how much configuration needs to be set on the command line.

```bash
$ accumulo init --upload-accumulo-site
...
Uploading properties in accumulo-site.xml to Zookeeper. Properties that cannot be set in Zookeeper will be skipped:
Skipped - instance.secret = <hidden>
Skipped - instance.volumes = hdfs://localhost:8020/accumulo
Skipped - instance.zookeeper.host = localhost:2181
Uploaded - table.durability = flush
Uploaded - tserver.memory.maps.native.enabled = false
Uploaded - tserver.readahead.concurrent.max = 64
Uploaded - tserver.server.threads.minimum = 64
Uploaded - tserver.walog.max.size = 512M
```

Any configuration that is skipped above will need to be passed in as a command line option to Accumulo services running
in Docker containers. These options can be set in an environment variable which is used in later commands.

```
export ACCUMULO_CL_OPTS="-o instance.secret=mysecret -o instance.volumes=hdfs://localhost:8020/accumulo -o instance.zookeeper.host=localhost:2181"
```

The Accumulo docker image expects that the HDFS path set by `instance.volumes` is owned by the `accumulo` user. This
can be accomplished by running the command below (replace the HDFS path with yours):

```bash
hdfs dfs -chown -R accumulo hdfs://localhost:8020/accumulo
```

## Docker engine

Use the `docker` command to start local docker containers. The commands below will start a local Accumulo cluster
with two tablet servers.

```
docker run -d --network="host" accumulo monitor $ACCUMULO_CL_OPTS
docker run -d --network="host" accumulo tserver $ACCUMULO_CL_OPTS
docker run -d --network="host" accumulo tserver $ACCUMULO_CL_OPTS
docker run -d --network="host" accumulo master $ACCUMULO_CL_OPTS
docker run -d --network="host" accumulo gc $ACCUMULO_CL_OPTS
```

## Marathon

Using the Marathon UI, you can start Accumulo services using the following
JSON configuration template.  The template is configured to start an Accumulo
monitor but it can be modified to start other Accumulo services such as
`master`, `tserver` and `gc`. For tablet servers, set `instances` to the number
of tablet servers that you want to run.

```
{
  "id": "accumulo-monitor",
  "cmd": "accumulo monitor -o instance.secret=mysecret -o instance.volumes=hdfs://localhost:8020/accumulo -o instance.zookeeper.host=localhost:2181",
  "cpus": 1,
  "mem": 512,
  "disk": 0,
  "instances": 1,
  "container": {
    "docker": {
      "image": "apache/accumulo",
      "network": "HOST"
    },
    "type": "DOCKER"
  }
}
```

[Accumulo]: https://accumulo.apache.org/
[Hadoop]: https://hadoop.apache.org/
[Zookeeper]: https://zookeeper.apache.org/
