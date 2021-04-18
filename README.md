<!-- markdownlint-configure-file { "MD004": { "style": "consistent" } } -->
<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD033 -->
<p align="center">
    <a href="https://docs.cardano.org/en/latest/">
        <img src="https://docs.cardano.org/en/latest/_static/cardano-logo.png" width="150" alt="Cardano">
    </a>
    <br>
    <strong>Cardano the decentralized third-generation proof-of-stake blockchain platform.</strong>
</p>
<!-- markdownlint-enable MD033 -->

# Multiarch cardano docker container. 🐳
Cardano docker is can now be supported as container a in Raspberri Pi or AWS Gravitron container platform.
It is based in ubuntu focal builder in a documented and formal way (supply chain review).

Access to the multi-platform docker [image](https://hub.docker.com/r/juampe/cardano).
# Minimize supply chain attack. 🔗
You can supervise all the sources, all the build steps, build yourserlf.
# Multi-platform image 👪
This is an efford to build cardano for several architectures.
Supported platforms:

* linux/amd64
* linux/arm64/v8

Access to the git [repository](https://github.com/juampe/cardano-docker)

🙏If you apprecciate the effort, please consider to support us making an ADA donation or staking ADA into the Nutcracker [NUTCK](https://nutcracker.work/) pool. 
> addr1qys8y92emhj6r5rs7puw6df9ahcvna6gtdm7jlseg8ek7xf46xjc0eelmgtjvmcl9tjgaamz93f4e5nu86dus6grqyrqd28l0r

# Running a Cardano-Node ⚡
## Cardano directory scheme
```
/home/cardano/cnode|
                   +config
                   +db
                   +sockets
                   +keys|
                        +pool
                   +logs
                   +scripts
```
## Environment and defaults. 🛌
|VARIABLE|DEFAULT|DESCRIPTION|
|--------|-------|-----------|
|NODE_NETWORK|"mainnet"|The kind of cardano network|
|NODE_IP|""|The ip assigned is the one with the default route, but it can be assigned|
|NODE_PORT|"6000"|This is the port and defaults the port used by Guild|
|NODE_UPNP|false|If true the container will use upnpc to map the port in your router|
|NODE_CORE|""|For relays, define core using this format host1:port1:1|
|NODE_RUNAS_CORE|false|By default run only as relay|
|NODE_UPDATE_TOPOLOGY|true|Force update topology file|
|NODE_CUSTOM_PEERS|""|You can define peers using this format host1:port1:valency1,host2:port2:valency2,...|
|NODE_HOME|"/home/cardano/cnode"|The default home, useful to create a permanent docker volume|
|NODE_CONFIG|"$NODE_HOME/config/mainnet-config.json"|If not exist init.sh try to download a fresh copy from IOHK|
|NODE_TOPOLOGY|"$NODE_HOME/config/mainnet-topology.json"|If not exist init.sh try to download a fresh copy from IOHK|
|NODE_SHELLEY_KES_KEY|"$NODE_HOME/keys/pool/kes.skey"|Must be generated and updated previously to be producer node|
|NODE_SHELLEY_VRF_KEY|"$NODE_HOME/keys/pool/vrf.skey"|Must be generated previously to be producer node| 
|NODE_SHELLEY_OPERATIONAL_CERTIFICATE|"$NODE_HOME/keys/pool/node.cert"|Must be generated previously to be producer node|
|NODE_SCRIPTS|false|Install aditional and useful operator scripts and tools|
|NODE_TOPOLOGY_PUSH|false|On relay push node information to api.clio.one in order to pull peers|
|NODE_TOPOLOGY_PULL|false|On relay start pull peer information from api.clio.one, $NODE_CORE defined recomended. IMPORTANT to have pull rights the node need at least 4 hours of pushing status|
|NODE_TOPOLOGY_PULL_MAX|10|Number of peers to pull into topology file|
|NODE_PROM_LISTEN|""|Listen address for prometheus monitor|


## Examples. 🗜️

* For relay in ARM64 v8

```
docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode  -e "NODE_CORE=yourcore1:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_TOPOLOGY_PUSH=true" -e "NODE_TOPOLOGY_PULL=true" juampe/cardano:arm64-1.26.1
```

* For relay in AMD64

```
docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode  -e "NODE_CORE=yourcore1:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_TOPOLOGY_PUSH=true" -e "NODE_TOPOLOGY_PULL=true" juampe/cardano:amd64-1.26.1
```

* For core in ARM64 v8

```
docker run --init -d --restart=always --network=host --name="core1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode -e "NODE_RUNAS_CORE=true" -e "NODE_CUSTOM_PEERS=relay1.nutcracker.work:6000:1,relay2.nutcracker.work:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" juampe/cardano:arm64-1.26.1
```

* For core in AMD64

```
docker run --init -d --restart=always --network=host --name="core1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode  -e "NODE_RUNAS_CORE=true" -e "NODE_CUSTOM_PEERS=relay1.nutcracker.work:6000:1,relay2.nutcracker.work:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" juampe/cardano:amd64-1.26.1
```

* Relay launch script for ARM64.

Keep in mind that the docker daemon must be enabled and running in startup. Gracefully restart cardano too.

```
cat > run.sh << EOF
#!/bin/bash
DNAME="relay1"
CVER="juampe/cardano:arm64-1.26.1"
docker pull $CVER
docker stop -t 60 $DNAME
docker rm $DNAME
docker run --init -d --restart=always --network=host --name="$DNAME" -v /home/cardano/cnode:/home/cardano/cnode -e "TZ=Europe/Madrid"  -e "NODE_CORE=core1:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_TOPOLOGY_PUSH=true" -e "NODE_TOPOLOGY_PULL=true" -e "NODE_TOPOLOGY_PULL_MAX=20" -e "NODE_PROM_LISTEN=0.0.0.0" $CVER
dockerlog $DNAME
EOF
chmod 755 run.sh
./run.sh
```

* Core launch script for AMD64.

Keep in mind that the docker daemon must be enabled and running in startup. Gracefully restart cardano too.

```
cat > run.sh << EOF
#!/bin/bash
DNAME="core1"
CVER="juampe/cardano:amd64-1.26.1"
docker pull $CVER
docker stop -t 60 $DNAME
docker rm $DNAME
docker run --init -d --restart=always --network=host --name="core1" -v /home/cardano/cnode:/home/cardano/cnode -e "TZ=Europe/Madrid"  -e "NODE_CUSTOM_PEERS=relay0.nutcracker.work:6000:1,relay1.nutcracker.work:6000:1,relay2.nutcracker.work:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_PROM_LISTEN=0.0.0.0" -e "NODE_RUNAS_CORE=true" -e "NODE_TRACE_MEMPOOL=true" $CVER
dockerlog $DNAME
EOF
chmod 755 run.sh
./run.sh
```


# A complex building proccess recipe to build cardano.🔥

* Unable to use Github action due to service limitations
* Unable to use qemu with amd64 due to ghc-pkg OFD hLock 
* Build in amd64 2VCPU 8GMEM 30GSSD with 4G swapfile
* Build in arm64v8 t4g.large 2VCPU 8GMEM 30GSSD Gravitron with 4G swapfile

# Build your own container. 🏗️
From a ubuntu:groovy prepare for docker buildx multiarch environment
At the moment, due to described qemu emulation problems, the container is built in the same architecture.

```
sudo apt-get update
sudo apt-get -y install git make docker.io byobu

git clone https://github.com/juampe/cardano-docker.git
cd cardano-docker
git checkout 1.26.1

#Adapt Makefile to DOCKER_TAG to tag and fit your own docker registry
make
```

# Build using cache repo pre-compiled cardano binaries. ⌛
This uses a pre-builded cardano binary created in the full build process "/cardano.tgz".

From a ubuntu:groovy prepare for docker buildx multiarch environment
At the moment, due to described qemu emulation problems, the container is built in the same architecture.

```
sudo apt-get update
sudo apt-get -y install git make docker.io byobu

git clone https://github.com/juampe/cardano-docker.git
cd cardano-docker
git checkout 1.26.1

#Adapt Makefile to DOCKER_TAG to tag and fit your own docker registry
make cache
```