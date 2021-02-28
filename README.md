# Docker-BIND9

Dockerfile to run BIND9 as Authoritative NameServer.  This container will get BIND9 started, but additional configuration will likely be required.  See [BIND9 Reference Manual](https://bind9.readthedocs.io/en/latest/index.html).  Of particular interest might be [split dns](https://bind9.readthedocs.io/en/latest/advanced.html#split-dns)

## Supported Architectures

The project is built with Docker Buildx to support multiple architectures such as `amd64` and `arm64`. 

Simply pulling `ninerealmlabs/bind9` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose (recommended)

Compatible with docker-compose v3 schemas.

```yaml
---
version: "3.7"
services:
  bind9:
    image: ninerealmlabs/bind9:latest
    container_name: bind9
    environment:
      - TZ=Europe/London
    volumes:
      - /path/to/appdata/config/conf:/config/bind/conf
      - /path/to/appdata/config/lib:/config/bind/lib
      - /path/to/appdata/logs:/config/logs
    ports:
      - 53:53/udp
      - 53:53/tcp
      - 953:953  # for RNDC (remote name daemon control)
    restart: unless-stopped
```

## Parameters
Container images are configured using parameters passed at runtime (such as those above).

| Parameter | Function |
| :----: | --- |
| `TZ=Europe/London` | Specify a timezone to use - e.g., Europe/London. |

## Volumes
### Notes on volume mapping
The following BIND9 configuration folders will be symlinked into /config to only mount a single volume:

/etc/bind --> /config/bind/conf - for configuration, your named.conf lives here
/var/lib/bind --> /config/bind/lib - this is usually the place where the secondary zones are placed
/var/log/bind --> config/log/bind - for logfiles

### Mounting /config/
The recommended configurations create local folders `/config` and `/letsencrypt`.  
`config/`  
    ├ `log/bind/`  - contains log files
    ├ `bind/conf/`  - contains named.conf  
    └ `bind/lib/`  - contains dns zones

## Updating Info

Below are the instructions for updating containers:

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull bind9`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d bind9`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run
* Update the image: `docker pull ninerealmlabs/bind9`
* Stop the running container: `docker stop bind9`
* Delete the container: `docker rm bind9`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

With Docker Compose for single testing:
```
git clone https://github.com/ninerealmlabs/docker-certbot-only.git
cd docker-bind9
docker-compose build
```

With [Docker buildx](https://docs.docker.com/buildx/working-with-buildx/) for multiarch support:
```
git clone https://github.com/ninerealmlabs/docker-certbot-only.git
cd docker-bind9
bash ./scripts/buildx.sh --tag {REPOSITORY}/bind9:{TAG}