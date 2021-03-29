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

# Work in progress, please keep waiting.
We are working very hard, to bring this container. Our VM's are very busy too.
Please undestand that this is an "spartan race" building process due to qemu limitations.
* Phase 1 Build ghc 8.10.2 compatible with state-of-the-art qemu for multi architecture CI/CD
* Phase 2 Build Cabal 3.2.0.0 free of OFD Locking 
* Phase 3 Bulid Cardano 1.25.1

# Multiarch cardano docker container 🐳
Cardano docker is can now be supported as container a in Raspberri Pi or AWS Gravitron container platform.
It is based in ubuntu focal builder in a documented and formal way (supply chain review).

Access to the multi-platform docker [image](https://hub.docker.com/r/juampe/cardano).

# Minimize supply chain attack
You can supervise all the sources, all the build steps, build yourserlf

## Multi-platform image 👪

This is an efford to build cardano for several common productions architectures.
Is a complex and very demanding docker build process based on cabal.
Supported platforms:

* linux/amd64
* linux/arm64/v8

Access to the git [repository](https://github.com/juampe/cardano-docker)

🙏If you apprecciate the effort, please consider to support us making an ADA donation or staking ADA into the Nutcracker [NUTCK](https://nutcracker.work/) pool. 
addr1qys8y92emhj6r5rs7puw6df9ahcvna6gtdm7jlseg8ek7xf46xjc0eelmgtjvmcl9tjgaamz93f4e5nu86dus6grqyrqd28l0r

## Running a Cardano-Node ⚡
```docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /persistent/path:/cnode juampe/cardano```


