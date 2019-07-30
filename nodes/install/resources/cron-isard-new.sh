#!/bin/bash
# Should be added to cron and will detect and incorporate new nodes

# check that cluster is running

# check if new node appears in system or exit
if ping -c 1 isard-new &> /dev/null
then
  echo "Found new isard. Get new host number..."
  host=1
  while nc -z "if$host" 22 2>/dev/null; do
    host=$((host+1))
  done
else
  exit 0
fi

# remove keys if known already
sed -i '/^isard-new/ d' /root/.ssh/known_hosts
# Copy actual keys to new node
/usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p isard-flock ssh -o StrictHostKeyChecking=no -l root" /root/.ssh/*  isard-new:/root/.ssh/

# Set new host IP's
ssh -n -f isard-new "bash -c 'nohup /root/isard-flock/nodes/install/set_ips.sh $host &'"
# Copy isard-flock version to new node
#~ scp -r /root/isard-flock isard-new:/root/

while ! ping -c 1 172.31.1.1$host &> /dev/null
do
	sleep 2
done
sleep 5

sed -i '/^isard-new/ d' /root/.ssh/known_hosts
/usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p isard-flock ssh -o StrictHostKeyChecking=no -l root" /root/.ssh/*  if$host:/root/.ssh/

# Check type of node
ssh if$host -- lsblk | grep md
RAID=$?
ssh if$host -- vgs | grep drbdpool
DRBD=$?
ssh if$host -- systemctl status pcsd
PCSD=$?
ssh if$host -- ls /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/ | grep i915-GVTg
VGTD=$?
ssh if$host -- vgs | grep backup
BACKUP=$?


# Lauch new node setup

if [[ $DRBD -eq 0 ]]; then
	echo "drbd"
	#~ exit 1
	linstor node add if$host 172.31.1.1$host
	linstor resource create linstordb --auto-place $host --storage-pool data
	linstor resource create isard --auto-place $host --storage-pool data
if [[ $PCSD -eq 0 ]]; then
	echo "pcsd"
	#~ exit 1
	pcs cluster auth if$host <<EOF
hacluster
isard-flock
EOF
	pcs cluster node add if$host
	pcs cluster start if$host
fi
if [[ $RAID -eq 0 ]]; then
	echo raid
	exit 1
	pcs constraint modify prefer_node_storage add if$host
	# or play with node weights
	
	# wait for /opt/isard to be mounted (drbd or nfs)
	# cd /opt/isard && docker-compose pull
fi
