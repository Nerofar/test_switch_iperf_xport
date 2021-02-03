#!/bin/bash
yum install -y dialog >> /tmp/test.log
DIALOG="dialog"
$DIALOG --title "Testing switch" --msgbox "This wizard helps you to testing switches on clear CentOS (7,8)" 10 40
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
OUTIF_DIALOG_START="$DIALOG --menu \"Select outgoing interface that interracts with your INTERNAL network\" 15 65 6 \\"
OUTIF_DIALOG="${OUTIF_DIALOG_START}"
for EACH_IFACE in $ALL_IFACES
do
   LIIIFACE_MAC=`ip addr show ${EACH_IFACE} | grep ether | awk {'print $2'} | sed -n '1p'`
   LIIIFACE_IP=`ip addr show ${EACH_IFACE} | grep inet' '| awk {'print $2'} | sed -n '1p'`
   OUTIF_DIALOG="${OUTIF_DIALOG}${EACH_IFACE} \\ \"${LIIIFACE_IP} - ${LIIIFACE_MAC}\" "
done
OUTIF_DIALOG="${OUTIF_DIALOG} 2> /tmp/outfe"
sh -c "${OUTIF_DIALOG}"
clear
outfe=`cat /tmp/outfe`
#set number ports of testing switch
$DIALOG --title "Testing switch" --msgbox "etap 3" 10 40
$DIALOG --title "Number ports" --inputbox " \nК-во проверяемых портов:" 10 40 2> /tmp/ports
ports=`cat /tmp/ports`
$DIALOG --title "Testing switch" --msgbox "etap 4" 10 40
$DIALOG --title "Testing switch" --msgbox "к-во портов свича $ports" 10 40
$DIALOG --title "Time sec" --inputbox " \nВремя проверки в сек.:" 10 40 2> /tmp/time
time=`cat /tmp/time`
# cleaning temp file



let ports=$ports+1200-1
let port_sw=$ports
for x in $(seq 1200 $port_sw)
do
let y=${x}-1200
#modprobe 8021q
#создание влан чёт вход, нечёт выход

  evenCheck=$(expr ${x} % 2)
  if [ $evenCheck = 0 ] ;
    then
    #вланы входящие
#    vconfig add ${infe} ${x}
#    nmcli con add type vlan con-name ${infe}.${x} id ${x} dev ${infe} ip4 10.0.${y}.12/24
#    nmcli con up ${infe}.${x}
    #неймспейс
    ##
    ip netns add iperf-server${x}
    ip link set ${infe}.${x} netns iperf-server${x}
    ip netns exec iperf-server${x} ip addr add dev ${infe}.${x} 10.0.${y}.11/24
    ip netns exec iperf-server${x} ip link set dev ${infe}.${x} up

#    ip netns exec iperf-server${x} ip addr add dev ${infe}.${x} 10.0.${y}.11/24
#    ip netns exec iperf-server${x} ip link set dev ${infe}.${x} up
    ##
    $DIALOG --title "Testing switch" --msgbox "test 1 переменная x ${x}и y ${y}" 10 40
  else
    #вланы исходящие
    let y=${y}-1
#    vconfig add ${outfe} ${x}
#    nmcli con add type vlan con-name ${outfe}.${x} id ${x} dev ${outfe} ip4 10.0.${y}.12/24
#    nmcli con up ${outfe}.${x}
    #неймспейс
    ip netns add iperf-client${x}
    ip link set ${outfe}.${x} netns iperf-client${x}
    ip netns exec iperf-client${x} ip addr add dev ${outfe}.${x} 10.0.${y}.12/24
    ip netns exec iperf-client${x} ip link set dev ${outfe}.${x} up

#    ip netns exec iperf-client${x} ip addr add dev ${outfe}.${x} 10.0.${y}.12/24
#    ip netns exec iperf-client${x} ip link set dev ${outfe}.${x} up
    ##
    ##
    $DIALOG --title "Testing switch" --msgbox "test 1 переменная x ${x}и y ${y}" 10 40
  fi

#
done


$DIALOG --title "Testing switch" --msgbox "etap 5" 10 40
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Choice test opt"
TITLE="Test switch"
MENU="Choose one of the following options:"

OPTIONS=(1 "Test iperf3"
         2 "Test ping"
         3 "Quit")

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
      let port_ip=$ports
      for z in $(seq 1200 $port_ip)
      do
      let a=${z}-1200
      #modprobe 8021q
      #создание влан чёт вход, нечёт выход

        evenCheck=$(expr ${z} % 2)
        if [ $evenCheck = 0 ] ;
          then
            ip netns exec iperf-server${z} iperf3 -s --logfile s${z}.log &
          ##
          $DIALOG --title "Testing switch" --msgbox "test 1 переменная x ${z}и y ${a}" 10 40
          else
            ip netns exec iperf-client${z} iperf3 -c 10.0.${a}.11 -P 10 -t ${time} &
      #    ip netns exec iperf-client${x} ip addr add dev ${outfe}.${x} 10.0.${y}.12/24
      #    ip netns exec iperf-client${x} ip link set dev ${outfe}.${x} up
          ##
          ##
          $DIALOG --title "Testing switch" --msgbox "test 1 переменная x ${z}и y ${a}" 10 40
        fi

      #
      done

      ;;
      2)

      ;;
      3)

      ;;
esac

rm -fr /tmp/outfe
rm -fr /tmp/infe
rm -fr /tmp/ports
rm -fr /tmp/time

## iperf start
# ip netns exec iperf-server${x} iperf3 -s --logfile s3.txt
# ip netns exec iperf-client${x} iperf3 -c 10.0.${y}.11 -P 10 -t 300
#clear vlan
##rm -fr /etc/sysconfig/network-scripts/enp1s0f0.12*
##rm -fr /etc/sysconfig/network-scripts/enp1s0f1.12*
##delete all namespace
##ip -all netns delete

# iperf server & client
#ip netns exec iperf-server${z} iperf3 -s --logfile s${z}.log &
#ip netns exec iperf-client${z} iperf3 -c 10.0.${a}.11 -P 10 -t ${time} &

# tail -F ss.log | grep -Po '[0-9.= A-Z]*( ?bits/sec)'
