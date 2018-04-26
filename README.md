# Virtuoso docker
Docker image specs for hosting Virtuoso.

# Building the image

    docker build -t htrc/virtuoso:7.2.4.2 -t htrc/virtuoso:latest .

Note: 
- Adjust the version number as needed by editing the `Dockerfile` and updating `VIRTUOSO_VERSION`.  
- For a list of available versions, see [the Virtuoso Github tags page](https://github.com/openlink/virtuoso-opensource/tags)

## Running your Virtuoso

### Host Virtuoso DB in Docker volume

    docker volume create virtuoso-db

    docker run --name virtuoso \
        -p 8080:8890 -p 1111:1111 \
        -v /host/dir/virtuoso.ini:/conf/virtuoso.ini:ro \
        -v /host/data/dir:/import \
        -v virtuoso-db:/db \
        -d htrc/virtuoso:latest

### Host Virtuoso DB in host filesystem

    docker run --name virtuoso \
        -p 8080:8890 -p 1111:1111 \
        -v /host/dir/virtuoso.ini:/conf/virtuoso.ini:ro \
        -v /host/data/dir:/import \
        -v /host/db/dir:/db \
        -d htrc/virtuoso:latest

### Run a simple Virtuoso instance with no customizations

    docker run --name virtuoso \
        -p 8080:8890 -p 1111:1111 \
        -d htrc/virtuoso:latest

The above example commands expose port 8080 and 1111 to the host, on all network interfaces.
To have Docker only expose these ports to `localhost` (so they can't be accessed from outside), use `-p localhost:8080:8890` and `-p localhost:1111:1111`.
