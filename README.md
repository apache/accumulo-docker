# Apache Accumulo Docker Image

## Obtain the Docker image

To obtain the docker image created by this project, you can either pull it from DockerHub at
`apache/accumulo` or build it yourself. To pull the image from DockerHub, run the command below:

    docker pull apache/accumulo

While it is easier to pull from DockerHub, the image will default to the software versions below:

| Software    | Version       |
|-------------|---------------|
| [Accumulo]  | 1.9.3         |
| [Hadoop]    | 2.8.5         |
| [Zookeeper] | 3.4.13        |

If these versions do not match what is running on your cluster, you should consider building
your own image with matching versions. However, Accumulo must be 2.0.0+. Below are instructions for
building an image:

1. Clone the Accumulo docker repo

        git clone git@github.com:apache/accumulo-docker.git

2. Build the default Accumulo docker image using the command below.

        cd /path/to/accumulo-docker
        docker build -t accumulo .

   Or build the Accumulo docker image with specific released versions of Hadoop, Zookeeper, etc that will downloaded from Apache using the command below:

        docker build --build-arg ZOOKEEPER_VERSION=3.4.8 --build-arg HADOOP_VERSION=2.7.0 -t accumulo .

   Or build with an Accumulo tarball (located in same directory as DockerFile) using the command below:

        docker build --build-arg ACCUMULO_VERSION=1.9.3-SNAPSHOT --build-arg ACCUMULO_FILE=accumulo-1.9.3-SNAPSHOT-bin.tar.gz -t accumulo .

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

[Accumulo]: https://accumulo.apache.org/
[Hadoop]: https://hadoop.apache.org/
[Zookeeper]: https://zookeeper.apache.org/
