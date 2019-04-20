#!/bin/bash
sed -i "s/PASSWD/$PASSWD/g" /etc/config.json
sed -i "s/IP/$IP/g" /etc/config.json
sed -i "s/PORT/$PORT/g" /etc/config.json
ss-server -c /etc/config.json
