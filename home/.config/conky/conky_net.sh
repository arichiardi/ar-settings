#!/bin/bash
exec 2>/dev/null
IFACE=$(ip -4 route show default | awk 'NR==1{print $5}')
[ -z "$IFACE" ] && exit 0
IP=$(ip -4 addr show "$IFACE" | awk '/inet /{split($2,a,"/"); print a[1]}')
RX=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes || echo 0)
TX=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes || echo 0)
UPTIME=$(awk '{printf "%d", $1}' /proc/uptime || echo 1)
[ "$UPTIME" -lt 1 ] && UPTIME=1
DX=$(awk "BEGIN{printf \"%.1f\", ($RX/$UPTIME)/1024}")
UX=$(awk "BEGIN{printf \"%.1f\", ($TX/$UPTIME)/1024}")
echo "$IFACE|$IP|$DX KB/s|$UX KB/s"
