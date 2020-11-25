# erlite USB replacement

https://community.ui.com/questions/EdgeMax-rescue-kit-now-you-can-reinstall-EdgeOS-from-scratch/58d474b4-604d-48c9-871d-ff44fd9240f3
https://community.ui.com/questions/Failing-USB-drive-on-a-Edgerouter-Lite/ca8240c4-6738-4e98-98ff-2b50f94f749d

# OLD erlite
## Old Bootcmd 
```
setenv bootcmd 'fatload usb 0 $loadaddr vmlinux.64;bootoctlinux $loadaddr coremask=0x3 root=/dev/sda2 rootdelay=15 rw rootsqimg=squashfs.img rootsqwdir=w mtdparts=phys_mapped_flash:512k(boot0),512k(boot1),64k@3072k(eeprom)'
```

## New Bootcmd
```
setenv bootcmd 'fatload usb 0 $loadaddr vmlinux.64;bootoctlinux $loadaddr coremask=0x3 root=/dev/sda2 rootdelay=15 rw rootsqimg=squashfs.img rootsqwdir=w mtdparts=phys_mapped_flash:512k(boot0),512k(boot1),64k@3072k(eeprom)'
setenv bootcmd 'sleep 1; usb reset; sleep 1; $(oldbootcmd)'
saveenv
```

# Newer ERLIGHT
## Old Bootcmd
```
bootcmd=fatload usb 0 $loadaddr vmlinux.64;bootoctlinux $loadaddr coremask=0x3 root=/dev/sda2 rootdelay=15 rw rootsqimg=squashfs.img rootsqwdir=w mtdparts=phys_mapped_flash:512k(boot0),512k(boot1),64k@1024k(eeprom)

```


## New Bootcmd
```
setenv oldbootcmd 'fatload usb 0 $loadaddr vmlinux.64;bootoctlinux $loadaddr coremask=0x3 root=/dev/sda2 rootdelay=15 rw rootsqimg=squashfs.img rootsqwdir=w mtdparts=phys_mapped_flash:512k(boot0),512k(boot1),64k@1024k(eeprom)'
setenv bootcmd 'sleep 1; usb reset; sleep 1; $(oldbootcmd)'
saveenv
```
