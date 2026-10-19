#!/bin/bash
# Configure this machine's ext4 root filesystem and GRUB for hibernation.
set -euo pipefail

if (( EUID != 0 )); then
    echo "Run this script with sudo bash $0" >&2
    exit 1
fi

swapfile=/swap-hibernate
if [[ $(findmnt -no FSTYPE /) != ext4 ]]; then
    echo "Expected an ext4 root filesystem; stopping." >&2
    exit 1
fi
if [[ ! -f /etc/default/grub || ! -d /boot/grub ]]; then
    echo "Expected GRUB configuration; stopping." >&2
    exit 1
fi
if ! grep -q '^HOOKS=.*systemd' /etc/mkinitcpio.conf; then
    echo "Expected the systemd initramfs hook; stopping." >&2
    exit 1
fi
for tool in mkswap swapon filefrag grub-mkconfig findmnt getconf stat blkid; do
    command -v "$tool" >/dev/null
done
if [[ -e $swapfile || -L $swapfile ]]; then
    if [[ -L $swapfile || ! -f $swapfile ]] ||
       [[ $(stat -c '%u:%a:%s' "$swapfile") != '0:600:8589934592' ]] ||
       [[ $(blkid -p -s TYPE -o value "$swapfile") != swap ]]; then
        echo "Existing $swapfile is not the expected root-owned 8 GiB swap file; stopping." >&2
        exit 1
    fi
    echo "Reusing existing $swapfile without reformatting it."
else
    available=$(df -B1 --output=avail / | tail -n 1)
    if (( available < 10 * 1024 * 1024 * 1024 )); then
        echo "Need at least 10 GiB free to create the 8 GiB swap file." >&2
        exit 1
    fi
    umask 077
    mkswap --file --size 8G "$swapfile"
fi

backup_dir=$(mktemp -d /etc/hibernate-backup.XXXXXX)
cp -a /etc/fstab /etc/default/grub "$backup_dir/"
echo "Configuration backups: $backup_dir"

if ! awk -v swapfile="$swapfile" '$1 == swapfile { found=1 } END { exit !found }' /proc/swaps; then
    swapon --priority 0 "$swapfile"
fi
uuid=$(findmnt -no UUID -T "$swapfile")
offset=$(LC_ALL=C filefrag -v -b"$(getconf PAGESIZE)" "$swapfile" | awk '$1 == "0:" { sub(/\.\..*/, "", $4); print $4 }')
if [[ -z $uuid || ! $offset =~ ^[0-9]+$ ]]; then
    echo "Unable to determine the resume device and offset; stopping." >&2
    exit 1
fi

if ! awk -v swapfile="$swapfile" '$1 == swapfile { found=1 } END { exit !found }' /etc/fstab; then
    printf '%s\n' "$swapfile none swap defaults,pri=0 0 0" >> /etc/fstab
fi
resume_line=$(printf 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} resume=UUID=%s resume_offset=%s"' "$uuid" "$offset")
if ! grep -Fxq "$resume_line" /etc/default/grub; then
    printf '\n# Resume from the hibernation swap file\n%s\n' "$resume_line" >> /etc/default/grub
fi
grub-mkconfig -o /boot/grub/grub.cfg
systemctl daemon-reload
swapon --show
echo "Setup complete. Reboot once, then try Hibernate from Waybar."
