#!/bin/bash
# https://github.com/OttoMeister/Win-KVM-Qemu-Linux
# https://www.qemu.org/docs/master/system/qemu-manpage.html
# https://www.shellcheck.net/#

# give it a name, suports win11, tia19 and office
vm_name=tia19 # win11, tia19 or office
vm_memory=16G # RAM 8G or 16G
vm_smp=cpus=6,sockets=1,cores=3,threads=2 # "cpus=4,sockets=1,cores=2,threads=2" # or 
spice_port=3004 # win11 = 3003, tia19 = 3004 or office = 3005
TSM=no # use yes or no
uefi_ovmf=long # OVMF long or short or none
vm_without_internet=yes # use yes or no
#vm_cdrom_0="/var/lib/libvirt/images/virtio-win.iso"
#vm_cdrom_1="/home/`/usr/bin/whoami`/Schreibtisch/Arbeit/SIMATIC_WinCC_Runtime_Professional_V19.iso"
#vm_cdrom_2="/home/`/usr/bin/whoami`/Schreibtisch/Arbeit/SIMATIC_WinCC_Runtime_Professional_V19_Upd3.iso"
#vm_cdrom_3="/home/`/usr/bin/whoami`/Schreibtisch/Arbeit/TIA_Portal_STEP7_Prof_Safety_WinCC_V19.iso"
vm_kiosk_mode=no # use yes or no
vm_usb_redirect=yes # use yes or no
vm_smb_drive=~/Schreibtisch/Arbeit 
vm_monitor_port=45457
vm_audio=no # use pipewire or usbaudio or no
vm_usb_network=yes # use yes or no
vm_webcam=no # use yes or no
vm_icon=~/${vm_name}.icon.png # /home/`/usr/bin/whoami`/office.icon.png /home/`/usr/bin/whoami`/tia19.icon.png /home/`/usr/bin/whoami`/win11.icon.png
vm_debug=yes # use yes or no

# load second script - do not change
. ~/kvm.sh
