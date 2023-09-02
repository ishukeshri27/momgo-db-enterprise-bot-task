#!/bin/bash
echo "[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" | sudo tee /etc/yum.repos.d/mongodb-org-5.0.repo

sudo yum install -y mongodb-org

sudo systemctl start mongod

sudo systemctl enable mongod

sudo systemctl status mongod

mkdir -p /data/db1 /data/db2 /data/db3 /data/log

mongod --port 27017 --dbpath /data/db1 --replSet rs0 --logpath /data/log/mongod1.log  --fork --wiredTigerCacheSizeGB 1 --setParameter enableLocalhostAuthBypass=false --setParameter disableJavaScriptProtection=true

mongod --port 27018 --dbpath /data/db2 --replSet rs0 --logpath /data/log/mongod2.log  --fork --wiredTigerCacheSizeGB 1 --setParameter enableLocalhostAuthBypass=false --setParameter disableJavaScriptProtection=true

mongod --port 27019 --dbpath /data/db3 --replSet rs0 --logpath /data/log/mongod3.log --fork --wiredTigerCacheSizeGB 1 --setParameter enableLocalhostAuthBypass=false --setParameter disableJavaScriptProtection=true --replSet rs0 --arbiterOnly



mongo --port 27017 <<EOF
rs.initiate(
  {
    _id: "rs0",
    members: [
      { _id: 0, host: "localhost:27017" },
      { _id: 1, host: "localhost:27018" },
      { _id: 2, host: "localhost:27019", arbiterOnly: true }
    ]
  }
);
EOF
mongo --port 27017 --eval "rs.status()"
