#!/usr/bin/env bash -eux

echo '>>> Zeroing /dev/zero'
dd if=/dev/zero of=/empty bs=1M || echo "dd exit code $? is suppressed"
rm -f /empty

# Block until the empty file has actually been removed
sync

echo '>>> Remove bash history'
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

echo '>>> Wipe log files'
find /var/log -type f | while read f; do echo -ne '' > ${f}; done

echo '>>> Whiteout root'
COUNT=$(df --sync -kP / | tail -n1 | tr -s ' ' | cut -d ' ' -f 4)
COUNT=$((COUNT -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=${COUNT} || true
rm /tmp/whitespace

echo '>>> Whiteout /boot'
COUNT=$(df --sync -kP /boot | tail -n1 | tr -s ' ' | cut -d ' ' -f 4)
COUNT=$((COUNT -= 1))
dd if=/dev/zero of=/boot/whitespace bs=1024 count=${COUNT} || true
rm /boot/whitespace

echo '>>> Whiteout swap'
SWAPPART=$(swapon -s | tail -n1 | tr -s ' ' | cut -d ' ' -f 1)
swapoff ${SWAPPART}
dd if=/dev/zero of=${SWAPPART} || echo "dd exit code $? is suppressed"
mkswap ${SWAPPART}
swapon ${SWAPPART}
