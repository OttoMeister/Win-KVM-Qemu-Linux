#!/bin/bash
# https://github.com/OttoMeister/Win-KVM-Qemu-Linux
# https://www.qemu.org/docs/master/system/qemu-manpage.html
# https://www.shellcheck.net/#

# give it a name, suports win11, tia19 and office
vm_name=win11 # win11, tia19 or office
vm_memory=8G # RAM 8G or 16G
vm_smp=cpus=4,sockets=1,cores=4,threads=1 # or cpus=6,sockets=1,cores=3,threads=2
TSM=yes # use yes or no
uefi_ovmf=long # OVMF long or short or none
vm_without_internet=no # use yes or no
vm_cdrom_0="/var/lib/libvirt/images/virtio-win.iso"
#vm_cdrom_1=""
#vm_cdrom_2=""
#vm_cdrom_3=""
#vm_cdrom_4=""
vm_kiosk_mode=yes # use yes or no
vm_usb_redirect=yes # use yes or no
vm_smb_drive=~/Schreibtisch/Arbeit 
vm_monitor_port=45455
vm_audio=no # use pipewire or usbaudio or no
vm_usb_network=no # use yes or no
vm_webcam=no # use yes or no
vm_icon=~/${vm_name}.icon.png 
vm_debug=yes # use yes or no
vm_viewer=remote-viewer # use remote-viewer 

# load second script - do not change
. ~/kvm.sh
