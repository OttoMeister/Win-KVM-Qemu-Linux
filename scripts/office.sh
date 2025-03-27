#!/bin/bash
# https://github.com/OttoMeister/Win-KVM-Qemu-Linux
# https://www.qemu.org/docs/master/system/qemu-manpage.html
# https://www.shellcheck.net/#

# give it a name, suports win11, tia19 and office
vm_name=office # win11, tia19 or office
vm_memory=8G # RAM 8G or 16G
vm_smp=cpus=6,sockets=1,cores=3,threads=2 # "cpus=4,sockets=1,cores=2,threads=2" # or 
spice_port=3005 # win11 = 3003, tia19 = 3004 or office = 3005
TSM=no # use yes or no
uefi_ovmf=long # OVMF long or short or none
vm_without_internet=no # use yes or no
#vm_cdrom_0=/var/lib/libvirt/images/virtio-win.iso
#vm_cdrom_1="/home/boss/Schreibtisch/Arbeit/TIA/TIA_Portal_STEP7_Prof_Safety_WinCC_V19.iso"
#vm_cdrom_2="/home/boss/Schreibtisch/Arbeit/TIA/S7-PLCSIM_V19.iso"
vm_kiosk_mode=no # use yes or no
vm_usb_redirect=no # use yes or no
vm_smb_drive=/home/boss/Schreibtisch/Arbeit #/home/boss/Desktop/Arbeit
vm_monitor_port=45456
vm_audio=usbaudio # use pipewire or usbaudio or no
vm_usb_network=no # use yes or no
vm_webcam=yes # use yes or no
vm_icon=/home/boss/${vm_name}.icon.png # /home/boss/office.icon.png /home/boss/tia19.icon.png /home/boss/win11.icon.png
vm_debug=yes # use yes or no

# load second script - do not change
. /home/boss/kvm.sh
