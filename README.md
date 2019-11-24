# All in one, minimal Kafka image

A quick and easy way to get Kafka up and running:

* starts a single Kafka message broker (including zookeeper)
* runs with minimal memory requirements (even [aws micro instances](https://aws.amazon.com/ec2/instance-types/t3/) can host it)

Use cases:

* if you are a developer and want to experiment with a messaging platform/kafka broker in no time,
* or if you are a startup and want to run [Kafka on AWS without breaking the bank](https://medium.com/investing-in-tech/cost-effective-kafka-on-aws-6c02f9b0d7de).

# How to use this image

## Start a `kafka` instance

Starting a Kafka instance is simple:

```console
$ docker run --name a-kafka -p 9092:9092 -d paperlib/kafka
```

... where `a-kafka` is the name you want to assign to your container.


## Environment Variables

When you start the `kafka` image, you can adjust the configuration of the Kafka and Zookeeper daemons by passing one or more environment variables on the `docker run` command line. All of them are optional.

### `ADVERTISED_HOST`

Adjust the Kafka daemon advertised host. This is the hostname of the `advertised.listeners` property in the `server.properties` file.

```console
advertised.listeners=PLAINTEXT://${override_host}:9092
```

### `KAFKA_HEAP_OPTS`

Adjust the Java heap available for Kafka. Defaults to `KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"`.

Example usage:

```console
$ docker run -e KAFKA_HEAP_OPTS="-Xmx1024M -Xms1024M" --name a-kafka -p 9092:9092 -d paperlib/kafka
```
