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

Adjust the Kafka daemon advertised host. This is the hostname of the `advertised.listeners` property in the `server.properties` file. Defaults to `ADVERTISED_HOST=127.0.0.1`

```console
advertised.listeners=PLAINTEXT://${ADVERTISED_HOST}:9092
```

### `KAFKA_HEAP_OPTS`

Adjust the Java heap available for Kafka. Defaults to `KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"`.

```console
$ docker run -e KAFKA_HEAP_OPTS="-Xmx1024M -Xms1024M" --name a-kafka -p 9092:9092 -d paperlib/kafka
```

### `ZOOKEEPER_HEAP_OPTS`

Adjust the Java heap available for Zookeeper. Defaults to `ZOOKEEPER_HEAP_OPTS="-Xmx128M -Xms128M"`.

### `LOG_DIRS`

Change Kafka's storage location (defauts to `/tmp/kafka-logs`.)
If we wanted to persist data between container restarts, we could simply mount a volume/directory (without the need to set `LOG_DIRS`):

```console
$ docker run --mount type=bind,source="$(pwd)"/your-dir-log,target=/tmp/kafka-logs --name a-kafka -p 9092:9092 -d paperlib/kafka
```

and `LOG_DIRS` lets us change that default `/tmp/kafka-logs` storage location to one of our liking:

```console
$ export LOG_DIRS=/usr/local/kafka/dirs
$ docker run --mount type=bind,source="$(pwd)"/your-dir-log,target=$LOG_DIRS -e LOG_DIRS=$LOG_DIRS --name a-kafka -p 9092:9092 -d paperlib/kafka
```

## Examples

The following examples are in python and use its `kafka-python` library, so we first have to install it:

```console
$ sudo -H pip install kafka-python
```

and create the `topic` over which we are going to be sending our messages:

```python
from kafka.admin import KafkaAdminClient, NewTopic

kafka = KafkaAdminClient(bootstrap_servers="localhost:9092")

topics = []
topics.append(NewTopic(name="example", num_partitions=1, replication_factor=1))
kafka.create_topics(topics)
```

Next we send a few messages over a topic named `example` with the following script:

```python
from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers='localhost:9092')

producer.send('example', b'Hello, World!')
producer.send('example', key=b'message-two', value=b'This is Kafka-Python')

producer.flush()
```

and then we get these messages with a receiver script:

```python
from kafka import KafkaConsumer

consumer = KafkaConsumer('example', group_id='a_readers_group', auto_offset_reset='earliest')

for message in consumer:
    print (message)
```

et voilà! 🙂

# Advanced Topics

This image image includes Confluence's JDBC Connector. Since its disk space requirements are negligible,
it doesn't impact image size, and it's extremely common and handy to push or pull data to/from a database
through such a Connector.

There are a number of new environment variables required to set it up, so we list them first here under.

## Additional Environment Variables (JDBC Connector)

### `JDBC_CONNECTOR_CONNECTION_URL`

The JDBC connection URL (required.) An example for MySQL would be of the form: `mysql://<db_server>:3306/<db_name>`

### `JDBC_CONNECTOR_CONNECTION_USER`

The user that will be used to connect to the database (could be part of the connection URL.)

### `JDBC_CONNECTOR_CONNECTION_PASSWORD`

The corresponding password for the user that will be used to connect to the database (could be part of the connection URL.)

### `JDBC_CONNECTOR_TIMESTAMP_COLUMN_NAME`

Comma separated list of one or more timestamp columns to detect new or modified rows.

### `JDBC_CONNECTOR_INCREMENTING_COLUMN_NAME`

The name of the strictly incrementing column to use to detect new rows.

### `JDBC_CONNECTOR_TABLE_WHITELIST`

List of tables to include.


## Examples

If no JDBC Connector environment variables are specified, no JDBC Connector is started.
If there are (in particular the `JDBC_CONNECTOR_CONNECTION_URL`) then a JDBC Connector process is started.

The following example boots the Kafka image with its JDBC Connector started:

```console
$ docker run --name a-kafka -p 9092:9092 -e JDBC_CONNECTOR_CONNECTION_URL="mysql://dbserver:3306/dbname" -e JDBC_CONNECTOR_CONNECTION_USER=a_db_user -e JDBC_CONNECTOR_CONNECTION_PASSWORD=a_db_user_password -e JDBC_CONNECTOR_TIMESTAMP_COLUMN_NAME=example_column_ts -e JDBC_CONNECTOR_INCREMENTING_COLUMN_NAME=id -e JDBC_CONNECTOR_TABLE_WHITELIST=a_table --network a-docker-net -d paperlib/kafka
```

