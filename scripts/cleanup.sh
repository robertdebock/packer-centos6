#!/bin/sh

# Remove network configuration.
/bin/systemctl stop NetworkManager.service
#for ifcfg in `ls /etc/sysconfig/network-scripts/ifcfg-* | grep -v ifcfg-lo` ; do
#  rm -f $ifcfg
#done
rm -f /var/lib/NetworkManager/*

cat <<EOF | cat >> /etc/rc.d/rc.local
LANG=C
for con in \`nmcli -t -f uuid con\`; do
  if [ "\$con" != "" ]; then
    nmcli con del \$con
  fi
done
gwdev=\`nmcli dev | grep ethernet | egrep -v 'unmanaged' | head -n 1 | awk '{print \$1}'\`
if [ "\$gwdev" != "" ]; then
  nmcli c add type eth ifname \$gwdev con-name \$gwdev
fi
EOF

chmod +x /etc/rc.d/rc.local

# Remove SSH host keys.
rm -f /etc/ssh/ssh_host_*

# Clean up /tmp
rm -rf /tmp/*

# Remove package and yum cache.
yum -y group remove "Development Tools"
yum -y erase epel-release dkms
yum -y clean all

# Clear some logfiles.
for log in boot.log btmp cron dmesg maillog messages secure spooler tallylog wtmp yum.log ; do
  cat > /var/log/${log}
done

# Remove some logfiles
for log in vboxadd-install.log vboxadd-install-x11.log VBoxGuestAdditions.log ; do
  rm /var/log/${log}
done
