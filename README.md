<!-- markdownlint-configure-file { "MD004": { "style": "consistent" } } -->
<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD033 -->
<p align="center" valign="center">
   <div>
        <img align="center" src="https://github.com/juampe/cardano-docker/blob/1.26.2/img/cardano-logo.png?raw=true" width="200" alt="Heart">
        <img align="center" src="https://github.com/juampe/cardano-docker/blob/1.26.2/img/heart.png?raw=true" width="40" alt="Heart">
        <img align="center" src="https://github.com/juampe/cardano-docker/blob/1.26.2/img/rpi.png?raw=true" width="60" alt="RPi">
        <img align="center" src="https://github.com/juampe/cardano-docker/blob/1.26.2/img/heart.png?raw=true" width="40" alt="Heart">
        <img align="center"  src="https://github.com/juampe/cardano-docker/blob/1.26.2/img/graviton.png?raw=true" width="200" alt="Graviton">
    </div>
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

🙏If you like our work, we will appreciate any ADA donation:
> addr1qys8y92emhj6r5rs7puw6df9ahcvna6gtdm7jlseg8ek7xf46xjc0eelmgtjvmcl9tjgaamz93f4e5nu86dus6grqyrqd28l0r
Come and see our stake pool Nutcracker [NUTCK](https://nutcracker.work/) ADA pool. 

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
|NODE_TRACE_FETCH_DECISIONS|true|Trace fetch decisions, usefull to monitor peers vía prometheus|
|NODE_TRACE_MEMPOOL|false|For producer/core, trace mempool, usefull to monitor Tx vía prometheus|
|NODE_PROM_LISTEN|""|Listen address for prometheus monitor|
|NODE_HEALTH|false|Enable tip health monitoring, disable it for upgrade from a db previous version|
|NODE_HEALTH_TIMEOUT|180|Timeout to get tip health test|
|NODE_LOW_PRIORITY|false|Run the node with CPU low priority and best-effort IO scheduler|


## Examples. 🗜️

* For relay

```
docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode  -e "NODE_CORE=yourcore1:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_TOPOLOGY_PUSH=true" -e "NODE_TOPOLOGY_PULL=true" juampe/cardano
```

* For core in ARM64

```
docker run --init -d --restart=always --network=host --name="core1" -e "TZ=Europe/Madrid" -v /home/cardano/cnode:/home/cardano/cnode -e "NODE_RUNAS_CORE=true" -e "NODE_CUSTOM_PEERS=relay1.nutcracker.work:6000:1,relay2.nutcracker.work:6000:1" -e "NODE_UPDATE_TOPOLOGY=true" juampe/cardano
```

* Relay launch script for ARM64.

Keep in mind that the docker daemon must be enabled and running in startup. Gracefully restart cardano too.

```
cat > run.sh << EOF
#!/bin/bash
DNAME="relay1"
CVER="juampe/cardano"
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
CVER="juampe/cardano"
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
From a ubuntu:groovy prepare for docker build multiarch environment.

At the moment, due to described qemu emulation problems, the container is built in the same architecture.

```
sudo apt-get update
sudo apt-get -y install git make docker.io byobu

git clone https://github.com/juampe/cardano-docker.git
cd cardano-docker
git checkout 1.26.2

#Adapt Makefile to DOCKER_TAG to tag and fit your own docker registry
make
```

# Build using cache repo pre-compiled cardano binaries. ⌛
This uses a pre-builded cardano binary created in the full build process "/cardano.tgz".

From a ubuntu:groovy prepare for docker build multiarch environment.

At the moment, due to described qemu emulation problems, the container is built in the same architecture.

```
sudo apt-get update
sudo apt-get -y install git make docker.io byobu

git clone https://github.com/juampe/cardano-docker.git
cd cardano-docker
git checkout 1.26.2

#Adapt Makefile to DOCKER_TAG to tag and fit your own docker registry
make cache
```

# Experimental low resource procedure. 💸
## Use cases only for cardano dedicated resources

* Raspberri Pi 4 with 4GibRAM and USB3.0 UASP+TRIM SSD (Homebrew)
* Old laptop x64 with 4GibRAM with SATA SSD (Homebrew)
* AWS t4g.medium with gp2 disk (~2$/day)

## Procedure
### 1. Install Ubuntu server (20.04, 20.10 or 21.04 best for zram)
### 2. Prepare docker runtime
From ubuntu user login
```
sudo apt-get update
sudo DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
sudo DEBIAN_FRONTEND="noninteractive" apt-get -y install jq docker.io net-tools prometheus-node-exporter wget curl bc tcptraceroute
sudo adduser --disabled-password --gecos "cardano" cardano #You can set the password later 
sudo sudo usermod -aG docker cardano
#dockerlog script
cat > /usr/local/bin/dockerlog << EOF
#!/bin/bash
docker logs --tail 50 --follow --timestamps \$1
EOF
#dockerps script
cat > /usr/local/bin/dockerps << EOF
#!/bin/bash
docker ps --format '{{.Names}} => {{ .Status }}'|grep -v portainer_agent|sort
EOF
chmod 755 /usr/local/bin/dockerps /usr/local/bin/dockerlog
#enable docker
systemctl enable docker
systemctl start docker
#remove disable snaps
snap list --all|grep disabled|awk '{print "snap remove " $1 " --revision=" $3}'|sh
```

### 3. Prepare SSD swap
From ubuntu user login (fstab not sudo friendly)
```
sudo bash
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
#This is for minimize swap IO usage
cat > /etc/sysctl.d/90-swapiness.conf << EOF
vm.swappiness = 1
EOF
```

### 4. Prepare zram swap
From ubuntu user login
```
sudo apt-get -y install zram-tools #Not in AWS
sudo apt-get -y install zram-tools linux-modules-extra-aws #In case of AWS needs extra zram.ko module
sudo /bin/echo -e "PERCENTAGE=20\nPERCENT=20\n" >> /etc/default/zramswap
sudo systemctl enable zramswap
sudo systemctl start zramswap
swapon #Check swap + zram
```

### 5. Prepare a cardano relay
From cardano user login
```
#Some environment
echo export NODE_HOME=$HOME/cnode >> $HOME/.bashrc
echo PATH="$HOME/cnode/scripts:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc
#Launch script
mkdir -p ~/cnode/scripts
cat > ~/cnode/scripts/run.sh << EOF
#!/bin/bash
DNAME="relay0"
CVER="juampe/cardano" #You may want freeze the version
docker pull $CVER #You may want to delete this and freeze the version
docker stop -t 60 $DNAME
docker rm $DNAME
docker run --init -d --restart=always --network=host --name="$DNAME" --hostname "$DNAME" -v /home/cardano/cnode:/home/cardano/cnode -e "TZ=Europe/Madrid" -e "NODE_UPDATE_TOPOLOGY=true" -e "NODE_TOPOLOGY_PUSH=true" -e "NODE_TOPOLOGY_PULL=true" -e "NODE_TOPOLOGY_PULL_MAX=10" -e "NODE_PROM_LISTEN=0.0.0.0" -e "NODE_HEALTH=true"  -e "NODE_LOW_PRIORITY=true" $CVER
dockerlog $DNAME #You can delete this if don't want see initial logs
EOF
chmod 755 ~/cnode/scripts/run.sh
```

**TIP:** To reduce integration you may want to rsync the blockchain cnode/db from another client

### 6. Basic Operation

From cardano user login
* Run the node, restart after change options
```
run.sh #You can interrupt log with Ctrl+c safely or make a gracefull restart running it again
```
* Check container estatus
```
dockerps
```
* Check cardano log
```
dockerlog relay0
```
* gLiveView
```
docker exec -it relay0 /home/cardano/cnode/scripts/gLiveView.sh
```
