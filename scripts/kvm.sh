# Begin defining the command to launch the QEMU system emulator

# Define the output file 
output_file=$(mktemp)_{vm_name} || { echo "Error: Failed to create temporary file."; exit 1; }

user=$(/usr/bin/whoami)

# Define the image directory -
image_dir="$HOME/Desktop/KVM"
disk_image="$image_dir/${vm_name}.qcow2"

[ ! -d "$image_dir" ] && { echo "Error: Directory $image_dir does not exist."; exit 1; }
[ ! -w "$image_dir" ] && { echo "Error: No write permission for $image_dir."; exit 1; }
[ ! -f "$disk_image" ] && { echo "Error: Disk image $disk_image not found."; exit 1; }
[ ! -f "$vm_icon" ] && { echo "Warning: Icon $vm_icon not found."; vm_icon=""; }

# append to output
ato() { echo "$*" >> "$output_file"; }

# TPM emulator
if [ "$TSM" = yes ]; then 
  ato "mkdir -p /tmp/emulated_tpm_${vm_name} &&"
  ato "/usr/bin/swtpm_setup \\"
  ato "--tpmstate /tmp/emulated_tpm_${vm_name} \\" 
  ato "--create-ek --create-platform-cert --lock-nvram   --overwrite &&"
  ato "/usr/bin/swtpm socket \\"
  ato "--log level=20 \\"
  ato "--tpmstate dir=/tmp/emulated_tpm_${vm_name} \\"
  ato "--tpm2 \\"
  ato "--ctrl type=unixio,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
  ato "--daemon &&"
  ato "sleep 1"
  ato "[[ -S /tmp/emulated_tpm_${vm_name}/swtpm-sock ]] || { echo "TPM socket not up"; exit 1; }"
fi

# Launches the QEMU virtual machine emulator with specific options and configurations.
ato "/usr/bin/qemu-system-x86_64 \\"

# Setting a name for the QEMU VM
ato "-name $vm_name,debug-threads=on \\"

# Hardware config
ato "-cpu host,migratable=on,hv-time=on,hv-relaxed=on,hv-vapic=on,hv-spinlocks=0x1fff \\"
ato "-enable-kvm \\" 
ato "-m $vm_memory \\"
ato "-smp $vm_smp \\"
ato "-machine q35,usb=off,vmport=off,smm=on,dump-guest-core=off,hpet=off,acpi=on \\"
ato "-global kvm-pit.lost_tick_policy=delay \\"
ato "-nodefaults -serial none -parallel none -no-user-config \\"
ato "-boot strict=on \\"
ato "-global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \\"


# Adds UEFI firmware files to support secure boot.
[ "$uefi_ovmf" = short ] && ato "-bios /usr/share/ovmf/OVMF.fd \\" 
[ "$uefi_ovmf" = long ] && ato "-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \\"
[ "$uefi_ovmf" = long ] && ato "-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \\"

# TPM emulator   # Defines a character device for the TPM, connected via the socket created earlier (swtpm-sock)
[ "$TSM" = yes ] && ato "-tpmdev emulator,id=tpm0,chardev=chrtpm \\"
[ "$TSM" = yes ] && ato "-chardev socket,id=chrtpm,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
[ "$TSM" = yes ] && ato "-device tpm-tis,tpmdev=tpm0 \\"
[ "$TSM" = yes ] && ato "-global driver=cfi.pflash01,property=secure,value=on \\"

# Attaches a virtual hard disk image using the VirtIO interface for efficient I/O.
ato "-object iothread,id=io1 \\"
ato "-drive id=hd0,file='$disk_image',format=qcow2,if=none,cache=none,discard=unmap,aio=io_uring,detect-zeroes=unmap \\"
ato "-device virtio-blk-pci,drive=hd0,iothread=io1,write-cache=on,num-queues=4,queue-size=1024 \\"

# Adds a virtual tablet device to capture mouse inputs smoothly.
ato "-device virtio-tablet,wheel-axis=true \\"

# enables USB support and adds a USB 2.0 EHCI and USB 3.0 XHCI controller in the VM.
# ato "-usb \\"
ato "-device usb-ehci,id=ehci \\"
ato "-device qemu-xhci,id=xhci \\"

# Map webcam from Notebook to virtual machine. Check permision, set udev rule.
[ "$vm_webcam" = yes ] && ato "-device usb-host,vendorid=0x04f2,productid=0xb735 \\"
[ "$vm_webcam" = yes ] && ato "-device usb-host,vendorid=0x04f2,productid=0xb5b9 \\"

# Passes a specific USB device (e.g., a Realtek USB network adapter) to the VM. Check permision, set udev rule.
[ "$vm_usb_network" = yes ] && ato "-device usb-host,bus=ehci.0,vendorid=0x0bda,productid=0x8153 \\" 

# Adds duplex audio with PipeWire to VM - ignor error "intel-hda: write to r/o reg". Check permision, set udev rule.
[ "$vm_audio" = pipewire ] && ato "-audiodev pipewire,id=audio0 \\"
[ "$vm_audio" = pipewire ] && ato "-device intel-hda \\"
[ "$vm_audio" = pipewire ] && ato "-device hda-duplex,audiodev=audio0 \\" 

# Adds duplex audio with USB Headset. Check permision, set udev rule.
 [ "$vm_audio" = usbaudio ] && ato "-device usb-host,vendorid=0x08bb,productid=0x2902 \\"

# Correct time synchronization and UTC as base time
ato "-rtc base=utc,clock=host,driftfix=slew \\"

# old SPICE Support
ato "-vga qxl -global qxl-vga.vgamem_mb=512 -global qxl-vga.ram_size=268435456 -global qxl-vga.vram_size=268435456  \\"
ato "-spice unix=on,addr=/tmp/${vm_name}.socket,disable-ticketing=on \\"
ato "-device virtio-serial-pci \\"
ato "-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \\"
ato "-chardev spicevmc,id=spicechannel0,name=vdagent \\"

# Adds USB redirection support, allowing USB devices from the client machine to be redirected from SPICE to the VM.
if [ "$vm_usb_redirect" = yes ]; then 
  ato "-device ich9-usb-ehci1,id=usb \\"
  ato "-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \\"
  ato "-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\"
  ato "-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \\"
  ato "-chardev spicevmc,name=usbredir,id=usbredirchardev1 \\"
  ato "-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\"
  ato "-chardev spicevmc,name=usbredir,id=usbredirchardev2 \\"
  ato "-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\"
  ato "-chardev spicevmc,name=usbredir,id=usbredirchardev3 \\"
  ato "-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\"
fi

# user-mode networking with Samba folder sharing.
ato "-device virtio-net,netdev=vmnic \\"
ato "-netdev restrict=${vm_without_internet},type=user,id=vmnic,smb=${vm_smb_drive} \\"

# Opens a monitor console via Telnet on port $vm_monitor_port for managing the VM.
ato "-monitor telnet::$vm_monitor_port,server,nowait \\"

# Attaches multiple ISO images as virtual CD-ROM drives to the VM for installation or upgrade purposes.
[ -f "$vm_cdrom_0" ] && ato "-drive if=ide,index=0,media=cdrom,file=${vm_cdrom_0} \\" 
[ -f "$vm_cdrom_1" ] && ato "-drive if=ide,index=1,media=cdrom,file=${vm_cdrom_1} \\" 
[ -f "$vm_cdrom_2" ] && ato "-drive if=ide,index=2,media=cdrom,file=${vm_cdrom_2} \\" 
[ -f "$vm_cdrom_3" ] && ato "-drive if=ide,index=3,media=cdrom,file=${vm_cdrom_3} \\" 
[ -f "$vm_cdrom_4" ] && ato "-drive if=ide,index=4,media=cdrom,file=${vm_cdrom_4} \\" 

# No image will be overwritten. all changes stay only in memory
[ "$vm_kiosk_mode" = yes ] && ato "-snapshot \\" 

# Enables debugging options for instruction disassembly, CPU, MMU, and guest errors.
# intel-hda: write to r/o reg CORBSIZE and RIRBSIZE is audio init - ignore
[ "$vm_debug" = yes ] && ato "-d in_asm,cpu,mmu,guest_errors \\"

# The & at the end runs the QEMU process in the background.
ato "&"  

# SPICE client = remote-viewer 
if [ "$vm_viewer" = remote-viewer ]; then 
  ato "sleep 2"
  ato "NEW_NAME=${vm_name}-${vm_name}-${vm_name}" 
  ato "[ "$vm_kiosk_mode" = yes ] && NEW_NAME=${vm_name}-Kiosk_Mode-${vm_name}" 
  ato remote-viewer spice+unix:///tmp/${vm_name}.socket  --title \"\$NEW_NAME\" --verbose --auto-resize=always --hotkeys=release-cursor=shift+f12 "&"  

fi

# Debug output
if [ "$vm_debug" = "yes" ]; then
  echo "Generated ${output_file} QEMU command:"
  cat "$output_file"
fi

# Run and cleanup
if bash "$output_file"; then echo rm "$output_file"
else echo "Error: Failed to execute QEMU command. See debug output above if enabled."; exit 1; 
fi

### Informational Messages ###
echo "+++++++++++++++ Info +++++++++++++++"
echo "# Compression of the image file:"
echo "time nice ionice -c 3 qemu-img convert -c -p -f qcow2 '$disk_image' -O qcow2 '${image_dir}/${vm_name}.comp.qcow2'"
echo "time nice ionice -c 3 sudo virt-sparsify --compress '$disk_image' '${image_dir}/${vm_name}.comp.qcow2' && chown ${user}:${user} '${image_dir}/${vm_name}.comp.qcow2'"
echo "# Backup and archive:"
echo "cp '${image_dir}/${vm_name}.comp.qcow2' '$disk_image'"
echo "mv '${image_dir}/${vm_name}.comp.qcow2' '${image_dir}/$(date +"%y%m%d")-${vm_name}.qcow2'"
echo "time nice ionice -c 3 7z a -mx=1 -mmt=on -p '${image_dir}/$(date +"%y%m%d")-${vm_name}.qcow2.7z' '$disk_image'"
echo "# List images:"
echo "ls -l '$image_dir' && find '$image_dir' | sort"
echo "# Edit scripts:"
echo "pluma '$HOME/kvm.sh' '$HOME/win11.sh' '$HOME/office.sh' '$HOME/tia19.sh' '$HOME/tia20.sh' &"
echo "# Cleanup:"
echo "killall swtpm"
echo "sudo service smbd restart"
echo "# Monitor VM:"
echo "telnet localhost $vm_monitor_port"
echo "# shutdown VM:"
echo "echo system_powerdown | nc localhost $vm_monitor_port"

if [ "$vm_kiosk_mode" = "yes" ]; then
    echo "Warning: Kiosk mode enabled. Disk changes are temporary unless committed."
    echo "echo commit hd0 | nc localhost $vm_monitor_port"
fi

