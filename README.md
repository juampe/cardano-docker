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

This is an efford to build cardano for several common productions architectures.
Is a complex and very demanding docker build process.
Supported platforms:

* linux/amd64
* linux/arm64/v8

Access to the git [repository](https://github.com/juampe/cardano-docker)

🙏If you apprecciate the effort, please consider to support us making an ADA donation or staking ADA into the Nutcracker [NUTCK](https://nutcracker.work/) pool. 
addr1qys8y92emhj6r5rs7puw6df9ahcvna6gtdm7jlseg8ek7xf46xjc0eelmgtjvmcl9tjgaamz93f4e5nu86dus6grqyrqd28l0r

# Running a Cardano-Node ⚡
## Environment and defaults
* NODE_NETWORK="mainnet"
* NODE_IP=""
* NODE_PORT="6000"
* NODE_UPNP=false
* NODE_BLOCK_PRODUCER=false
* NODE_UPDATE_TOPOLOGY=true
* NODE_CUSTOM_PEERS="" 
* NODE_HOME="/home/cardano/cnode"
* NODE_CONFIG="$NODE_HOME/config/mainnet-config.json" 
* NODE_TOPOLOGY="$NODE_HOME/config/mainnet-topology.json" 
* NODE_SHELLEY_KES_KEY="$NODE_HOME/keys/pool/kes.skey" 
* NODE_SHELLEY_VRF_KEY="$NODE_HOME/keys/pool/vrf.skey" 
* NODE_SHELLEY_OPERATIONAL_CERTIFICATE="$NODE_HOME/keys/pool/node.cert" 

## Examples

*For ARM64 v8
```docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /persistent/path:/home/cardano/cnode juampe/cardano:aarch64-1.25.1```

*For AMD64

```docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /persistent/path:/home/cardano/cnode juampe/cardano:x86_64-1.25.1```

# A complex building proccess recipe to build cardano.
We are working very hard, to bring this container. The building process in quemu arm64 is huge (20 times slower).
Please undestand that this is an "spartan race" building process due to qemu limitations.
We planned to made in 3 phases:
* Phase 1 Build Cabal 3.2.0.0 free of OFD Locking
 * Build with Github action in 12896s
 * Build with amd64 12VCPU 32GMEM 50GSSD in 7045s
* Phase 2 Build ghc 8.10.2 compatible with state-of-the-art qemu for multi architecture CI/CD
 * Unable to use Github action due to service limitations
 * Build with amd64 12VCPU 32GMEM 50GSSD in 26513s
* Phase 3 Bulid Cardano 1.25.1
 * Unable to use Github action due to service limitations
 * Unable to use qemu with amd64 due to ghc-pkg OFD hLock 
 * Build for in amd64 12VCPU 32GMEM 50GSSD in 26513.0s
 * Build for in arm64v8 t4g.medium Gravitron with 2G swapfile

# Build your own container. 🏗️
From a ubuntu:groovy prepare for docker buildx multiarch environment
At the moment, due to described qemu emulation problems, the container is built in the same architecture.

```
sudo apt-get update
sudo apt-get -y install git make docker.io byobu

git clone https://github.com/juampe/cardano-docker.git
cd cardano-docker

#Adapt Makefile to DOCKER_TAG to tag and fit your own docker registry
make
```