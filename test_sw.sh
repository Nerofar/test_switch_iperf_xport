#!/bin/bash
yum install -y dialog >> /tmp/test.log
DIALOG="dialog"
$DIALOG --title "Testing switch" --msgbox "This wizard helps you to testing switches on clear CentOS (6,7,8)" 10 40
#configuring LAN interface
ALL_IFACES=`ls /sys/class/net | grep -v lo`

INTIF_DIALOG_START="$DIALOG --menu \"Select ingoing interface that interracts with your INTERNAL network\" 15 65 6 \\"
INTIF_DIALOG="${INTIF_DIALOG_START}"
for EACH_IFACE in $ALL_IFACES
do
   LIIFACE_MAC=`ip addr show ${EACH_IFACE} | grep ether | awk {'print $2'} | sed -n '1p'`
   LIIFACE_IP=`ip addr show ${EACH_IFACE} | grep inet' '| awk {'print $2'} | sed -n '1p'`
   INTIF_DIALOG="${INTIF_DIALOG}${EACH_IFACE} \\ \"${LIIFACE_IP} - ${LIIFACE_MAC}\" "
done
INTIF_DIALOG="${INTIF_DIALOG} 2> /tmp/infe"
sh -c "${INTIF_DIALOG}"
clear
infe=`cat /tmp/infe`

ALL_IFACES=`ls /sys/class/net | grep -v lo`

INTIF_DIALOG_START="$DIALOG --menu \"Select outgoing interface that interracts with your INTERNAL network\" 15 65 6 \\"
INTIF_DIALOG="${INTIF_DIALOG_START}"
for EACH_IFACE in $ALL_IFACES
do
   LIIFACE_MAC=`ip addr show ${EACH_IFACE} | grep ether | awk {'print $2'} | sed -n '1p'`
   LIIFACE_IP=`ip addr show ${EACH_IFACE} | grep inet' '| awk {'print $2'} | sed -n '1p'`
   INTIF_DIALOG="${INTIF_DIALOG}${EACH_IFACE} \\ \"${LIIFACE_IP} - ${LIIFACE_MAC}\" "
done
INTIF_DIALOG="${INTIF_DIALOG} 2> /tmp/outfe"
sh -c "${INTIF_DIALOG}"
clear
infe=`cat /tmp/outfe`

#set number ports of testing switch

$DIALOG --title "Number ports"--inputbox " \nК-во проверяемых портов:" 16 51 2> /tmp/ports
ports=`cat /tmp/ports`
# cleaning temp file
rm -fr /tmp/outfe
rm -fr /tmp/infe
rm -fr /tmp/ports

let ports=$ports+1200-1
for x in $(seq 1200 $ports)
do
    echo "DEVICE=vlan${x}" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "IPADDR=192.168.${x}.1" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "NETWORK=10.0.${x}.0" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "BROADCAST=10.0.${x}.255" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "PHYSDEV=$infe" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
    echo "VID=${x}" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
done

TITLE="any"
MENU="Исходящий свич:"

OPTIONS=(1 "D-link"
         2 "Zysel"
         3 "quit")

              CHOICE=$(dialog --clear \
                      --backtitle "$BACKTITLE" \
                      --title "$TITLE" \
                      --menu "$MENU" \
                      $HEIGHT $WIDTH $CHOICE_HEIGHT \
                      "${OPTIONS[@]}" \
                      2>&1 >/dev/tty)
clear
case $CHOICE in
      1)
      echo "Выбран D-link"
        for x in $(seq 1200 $ports)
        do
            echo "DEVICE=vlan${x}" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "IPADDR=192.168.${x}.1" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "NETWORK=10.0.${x}.0" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "BROADCAST=10.0.${x}.255" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "PHYSDEV=$infe" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
            echo "VID=${x}" >> /etc/sysconfig/network-scripts/ifcfg-vlan${x}
        done
      ;;
      2)
      echo "Выбран с chroot"
        echo '$user' >> /etc/vsftpd/chroot_list
      ;;
      3)
      echo "quit"
      ;;





esac
#clear vlan
rm -fr /etc/sysconfig/network-scripts/ifcfg-vlan*
