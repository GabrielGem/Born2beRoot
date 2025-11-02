#! /bin/bash

SYSTEM_INFO=$(uname -srmo)
PHYSICAL_CPU=$(lscpu | awk '/^CPU\(s\):/ {print$2}')
VIRTUAL_CPU=$(nproc)
MEM=$(free --mega | awk '/Mem:/ {printf("%s/%sMB (%.2f%%)", $3, $2, $3/$2*100)}')
DISK=$(df --block-size=M | awk '/^\/dev\// && !/\/boot/ \
{total += $2; used += $3} END \
{printf("%d/%.1fGb (%d%%)", used, total/1024, used/total*100)}')
CPU_USAGE=$(vmstat 1 2 | tail -1 | awk 'printf("%.1f%%", (100 - $15))')
BOOT=$(who -b | awk '{print $3, $4}')
LVM_CHECK=$(lsblk -o TYPE | awk 'BEGIN{f=0} $1=="lvm"{f=1;exit} END {print (f ? "yes" : "no")}')
CONNECTIONS=$(ss -s | awk '/estab/ {print $4, "ESTABLISHED"}' | tr -d ',')
USERS=$(who | wc -l)
IP_ADDR=$(hostname -I | awk '{print "IP", $1}')
MAC_ADDR=$(ip link | awk '/link\/ether/ {print$2}')
NUM_CMD_SUDO=$(journalctl _COMM=sudo | awk '/COMMAND/' | wc -l)

ps -ef | awk '/tty/ || / pts\// {print$6}' | sort -u | while read TTY; do echo "
	#ARCHITECTURE: $SYSTEM_INFO
	#CPU PHYSICAL : $PHYSICAL_CPU
	#VCPU : $VIRTUAL_CPU
	#MEMORY USAGE: $MEM
	#DISK USAGE: $DISK
	#CPU LOAD: $CPU_USAGE
	#LAST BOOT: $BOOT
	#LVM USE: $LVM_CHECK
	#CONNECTIONS TCP : $CONNECTIONS
	#User log: $USERS
	#Network: $IP_ADDR ($MAC_ADDR)
	#Sudo : $NUM_CMD_SUDO cmd" \
| tee /dev/$TTY 1 /dev/null; done
