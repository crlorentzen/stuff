# FreeNas notes

## Plex
1. Build the iojail
  ```
  jail_name='plex-test'
  bsd_ver='11.3-RELEASE'
  
  iocage stop ${jail_name} && iocage destroy ${jail_name}
  
  iocage create -n ${jail_name} -r ${bsd_ver} vnet="on" bpf="on" dhcp="on" boot="on"
  ```
2. Install Plex in jail
Ensure using latest packages
  - edit /etc/pkg/FreeBSD.conf
    - Change /quarterly to /latest
  - Update, upgrade, install
    * `pkg update && pkg -y upgrade`
    * `pkg install multimedia/plexmediaserver`
  - Configure start on boot
    * `sysrc plexmediaserver_enable=YES`
  - Manually start (if configured for start on boot, if not use onestart)
    * service plexmediaserver start
3. Install Post Processing Tools
  - Handbrake:\
  Handbrake requires some dependencies which cannot be pulled via the binary package manager (pkg), so we will use the portsnap tool to download and install from source
    - Get portsnap sources: `portsnap fetch extract`
    - Ensure up-to-date sources: `portsnap fetch update`
    - Install lame audio encoder
    ```
    cd /usr/ports/audio/lame
    make install clean
    ```
    - Install handbrake: `pkg install multiumedia/handbrake`
  
    
## Virtual Machines
FreeNAS uses a vm hypervisor known as behyve. There are a few workarounds for behyve issues I encountered below.
https://www.ixsystems.com/community/threads/howto-how-to-boot-linux-vms-using-uefi.54039/

### Linux (I use Debian as a docker host)
1. Use the GUI to generate the VM, select what you want to disk space and RAM
1. Configure the VNC session to 800x600 resolution, fixes garbled VNC output.
1. Use VNC to install the OS.
1. Fix boot issue, "The bhyve UEFI firmware conforms to the known “Default Boot Behaviour” and looks for the file \EFI\BOOT\boot64.efi in the EFI partition of your VM. If it's not present you end up in the EFI shell."
  - For Debian 10 amd64
    ```
    mkdir /boot/efi/EFI/BOOT
    cp /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
    ```
  
  
## Full Scripts
### Plex iocage
```
jail_name='plex-test'
bsd_ver='11.3-RELEASE'
ip4='10.1.10.42/24'
rtr='10.1.10.254'

iocage stop ${jail_name} && iocage destroy ${jail_name}
y

#iocage create -n ${jail_name} -r ${bsd_ver} vnet="on" bpf="on" dhcp="on" boot="on"
iocage create -n ${jail_name} -r ${bsd_ver} vnet="on" ip4_addr="vnet0|${ip4}" defaultrouter="${rtr}" boot="on"

iocage start ${jail_name}

iocage exec ${jail_name} 'mkdir -p /config'
mkdir "/mnt/data/jail_data/${jail_name}"
iocage fstab -a ${jail_name} "/mnt/data/jail_data/${jail_name}" /config nullfs rw 0 0

for dir in {'/media/tv','/media/movies','/media/music'}
  do 
  echo "${dir}"
  iocage exec ${jail_name} "mkdir -p ${dir}"
  iocage fstab -a ${jail_name} "/mnt/data${dir}" "${dir}" nullfs ro 0 0  
done

iocage exec ${jail_name} 'mkdir -p /media/recordings'
iocage fstab -a ${jail_name} /mnt/data/media/recordings /media/recordings nullfs rw 0 0


# Update to the latest repo
iocage exec ${jail_name} "mkdir -p /usr/local/etc/pkg/repos"
iocage exec ${jail_name} "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Update pkg
iocage pkg ${jail_name} update && iocage pkg ${jail_name} upgrade -y
# Install Plex and dependencies
iocage pkg ${jail_name} install -y plexmediaserver

# Set permissions
iocage exec ${jail_name} chown -R plex:plex /config

# Enable service
iocage exec ${jail_name} sysrc "plexmediaserver_enable=YES"
iocage exec ${jail_name} sysrc plexmediaserver_support_path="/config"

iocage restart ${jail_name}


# install Handbrake
#  iocage exec ${jail_name} 'portsnap fetch extract && portsnap fetch update'
#  iocage exec ${jail_name} 'cd /usr/ports/audio/lame && make install clean'
#  iocage exec ${jail_name} 'pkg install multimedia/handbrake'

# Install ffmpeg
iocage exec ${jail_name} 'pkg install multimedia/ffmpeg'
```
