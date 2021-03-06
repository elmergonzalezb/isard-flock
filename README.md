# Isard Flock

Isard Flock is the name for the automated VDI clustering system based on drbd9 and pacemaker.

Now we have it in production! Easy to install and automated setup with https://github.com/isard-vdi/isard-flock-iso !

## What's this

The final target is to have a unique script that will allow to set up a VDI cluster server that can grow with different setups based on the server types:

- Master node: It will bring up a complete IsardVDI, work as Nas + Hypervisor.
- Replica node: It will replicate storage with master through drbd. This replicas can be taken from cluster and used standalone. It will work as Nas + Hypervisor
- Diskless node: It will be only an Hypervisor.
- Backup node: It will have slow storage to keep automated backups from the cluster. It will work as Hypervisor
- GPU storage node: It will allow gVT/sr-iov GPU virtualization at the same time that will work as a nas in the cluster
- GPU diskless node: It will allow gVT/sr-iov GPU virtualization

## High availability

We have a pacemaker cluster on top of the system that will provide HA for storage and IsardVDI software.

The cluster stonith it is set up using low end IoT devices with Espurna firmware and a custom fence-espurna agent.

## Set ups

- Minimal:
  - One Master node
- Recommended:
  - 1 Master node
  - 1 Replica node
  - 1 Backup node
  - Networking: 10G 8 port switch, 2.4GHz ap and 3 Teckin SP22
  - 1 SAI 1,5KW
- Big infrastructure:
  - 1 Master node
  - n Replica nodes/GPU storage nodes
  - 1 Backup node
  - n GPU diskless nodes
  - Networking: 10G 24 port + 40G 2 port switch, 40G dual NIC, 2.4GHz AP and n Teckin SP22
  - Multiple SAI as per configuration
  
## Project status

Many tests have to be done to have it in production. We will try to update here the progress. 

- 2020-02-11: Working master and replica node in production cluster using isard-flock-iso and ESP8266 espurna flashed devices as stonith fencing. Implementation took us only one morning!
- 2019-11-25: Created a submodule in isard-flock-iso that will incorporate this isard-flock repo. Fixed the iso creation for both UEFI and non-UEFI machines. Installing and testing system in real development lab.
- 2019-07-31: The install script is working with master, replicas and diskless nodes! We have also a new repo (isard-flock-iso) to create an iso with all the packages and scripts needed.
- 2019-07-29: The install script allows to set up a master, replica and diskless node and the master node incorporates automatically other diskless nodes to the cluster. Now doing tests removing and adding replica nodes to the cluster.
- 2019-07-14: We now have the test lab configured with all the hardware and all the drbd packages compiled and running. Now we will work in programming a new fence agent that works with Teckin sp22 IoT devices with Espurna firmware, as this will lower the final budget a lot. Also we are working in testing intel gVT and AMD sriov gpu virtualization.

### TASK LIST

- [x] Set up lab with 4 CentOS nodes

- [x] Install & compile drbd & linstor

- [x] Configure drbd

- [x] Install pacemaker
- [x] Install docker and Isard
- [x] Performace tuning in 10G network & TCP stack
- [x] Performance tuning in drbd9
- [x] Test stonith with Teckin sp22 through [espurna](https://github.com/xoseperez/espurna) api
- [x] Program fence-espurna for pacemaker
- [x] Configure & test pacemaker
- [x] Test removing and adding again a replica node
- [ ] Fix mosquitto container and grafana to monitor nodes power consumption [WIP]
- [ ] Test intel gVT on i9-9900K [WIP]
- [ ] Add virtual GPU mapping to IsardVDI software
- [ ] Test hangs in AMD Firepro 7550 with sr-iov [WIP]
- Create ansibles for all the types of nodes [DISCARDED]
- [x] Final tests & production [WIP]

