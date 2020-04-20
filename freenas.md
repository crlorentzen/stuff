# FreeNas notes

## Plex
1. Build the iojail
  - Will add commands later, initially used GUI. Planning to build another test install
1. Install Plex in jail
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
1. Install Post Processing Tools
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
1. Configure the VNC session to 800x600 resolution
1. Use VNC to install the OS
1. Fix boot issue, "The bhyve UEFI firmware conforms to the known “Default Boot Behaviour” and looks for the file \EFI\BOOT\boot64.efi in the EFI partition of your VM. If it's not present you end up in the EFI shell."
  - After install, access the shell and copy grubx64.efi to /EFI/BOOT/bootx64.efi. Don't worry if you don't do this, you can always recover later.
  `cp /boot/efi/grubx64.efi /boot/efi/BOOT/bootx64.efi`
