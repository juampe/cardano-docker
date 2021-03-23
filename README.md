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

# Multiarch cardano docker container 🐳
Cardano docker is now supported as container in Raspberri Pi or AWS Gravitron container platform.
It is based in debian:bullseye builder.

Access to the multi-platform docker [image](https://hub.docker.com/r/juampe/cardano).

## Multi-platform image 👪

This is an efford to build cardano for several common productions architectures.
Is a complex and very demanding docker build process based on cabal.
Supported platforms:

* linux/amd64
* linux/arm/v7
* linux/arm64/v8

Access to the git [repository](https://github.com/juampe/cardano-docker)

🙏If you apprecciate the effort, please consider to support us making an ADA donation or staking ADA into the Nutcracker [NUTCK](https://nutcracker.work/) pool. 
addr1qys8y92emhj6r5rs7puw6df9ahcvna6gtdm7jlseg8ek7xf46xjc0eelmgtjvmcl9tjgaamz93f4e5nu86dus6grqyrqd28l0r

## Running a Cardano-Node ⚡
```docker run --init -d --restart=always --network=host --name="relay1" -e "TZ=Europe/Madrid" -v /persistent/path:/cnode juampe/cardano```


