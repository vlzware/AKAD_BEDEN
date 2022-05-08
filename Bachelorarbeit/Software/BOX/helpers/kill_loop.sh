#!/bin/bash
set -x
sudo kill $(sudo ps jfx | grep "BOXrun.sh" | awk -F'[ ]+' '{print $3}')
sudo killall tcpdump
