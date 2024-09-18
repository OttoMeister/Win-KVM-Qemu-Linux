#!/bin/bash
# https://github.com/OttoMeister/Win-KVM-Qemu-Linux
# https://www.qemu.org/docs/master/system/qemu-manpage.html

# give it a name, suports win11, tia19 and office
vm_name=win11 # win11, tia19 or office
vm_memmory=8G # RAM 8G or 16G
vm_smp="cpus=4,sockets=1,cores=2,threads=2" # or "cpus=6,sockets=1,cores=3,threads=2"
spice_port=3003 # win11 = 3003, tia19 = 3004 or office = 3005
TSM=no # use yes or no
uefi_ovmf=short # OVMF long or short or none
vm_without_internet=no # use yes or no
#vm_cdrom_0="/var/lib/libvirt/images/virtio-win.iso"
#vm_cdrom_1="/home/boss/Schreibtisch/Arbeit/TIA/TIA_Portal_STEP7_Prof_Safety_WinCC_V19.iso"
#vm_cdrom_2="/home/boss/Schreibtisch/Arbeit/TIA/S7-PLCSIM_V19.iso"
vm_kiosk_mode=no # use yes or no
vm_usb_redirect=no # use yes or no
vm_smb_drive="/home/boss/Schreibtisch/Arbeit"
vm_monitor_port=45455
vm_with_redirect_ip_webcam=no # use yes or no
vm_redirect_port=4748
vm_audio=no # use yes or no
vm_usb_network=no # use yes or no

# Begin defining the command to launch the QEMU system emulator
# do not edit below
# Define the output file 
output_file="${vm_name}.tmp.sh"

# Delete the output file if exist
rm -f $output_file 
if [ "$TSM" = yes ]; then {
    # Creates a directory (/tmp/emulated_tpm_${vm_name}) for storing TPM state files. The -p flag ensures that the directory is created only if it doesn't already exist.
    echo "mkdir -p /tmp/emulated_tpm_${vm_name} &&"
    # Runs the swtpm (software TPM emulator) as a background daemon process. It sets up a TPM 2.0 emulator to provide a virtual TPM device for the virtual machine.
    echo "swtpm socket \\"
    # Specifies the directory to store the TPM state files.
    echo "--tpmstate dir=/tmp/emulated_tpm_${vm_name} \\"
    # Defines a Unix domain socket (swtpm-sock) for communicating with the TPM emulator.
    echo "--ctrl type=unixio,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
    # Runs the swtpm as a daemon, so it continues running in the background.
    echo "--daemon &&"
  } >> "$output_file"; fi
  
# Launches the QEMU virtual machine emulator with specific options and configurations.
echo /usr/bin/qemu-system-x86_64 \\ >>$output_file
# Setting a name for the QEMU VM
echo -name ${vm_name} \\ >>$output_file
# suppresses the default networking configuration and the creation of several other default devices.
echo -nodefaults \\ >>$output_file
# Configures the CPU to match the host CPU and enable several CPU features like Hyper-V enlightenment for better virtualization performance.
echo -cpu host,migratable=on,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \\ >>$output_file
# Enables KVM (Kernel-based Virtual Machine) acceleration for better performance on compatible CPUs.
echo -enable-kvm \\ >>$output_file 
# Allocates X GB of RAM to the virtual machine
echo -m $vm_memmory \\ >>$output_file
# Configure 4 CPUs with 1 socket, 2 cores per socket, and 2 threads per core.
echo -smp $vm_smp \\ >>$output_file
# Specifies the machine type with the Q35 chipset, enables KVM acceleration, and turns on SMM (System Management Mode).
echo -machine pc-q35-7.1,accel=kvm,smm=on \\ >>$output_file
# Adds UEFI firmware files to support secure boot.
[ "$uefi_ovmf" = short ] && echo "-bios /usr/share/ovmf/OVMF.fd \\" >> $output_file
# Using for read and write 
if [ "$uefi_ovmf" = long ]; then  {
    echo "-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \\"
    echo "-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \\"
  } >> "$output_file"; fi
# TPM   
if [ "$TSM" = yes ]; then  {
# Defines a character device for the TPM, connected via the socket created earlier (swtpm-sock)
echo "-chardev socket,id=chrtpm,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
# Sets up the TPM device using the previously defined chardev. The tpm-tis device is a TPM interface type.
echo "-tpmdev emulator,id=tpm0,chardev=chrtpm -device tpm-tis,tpmdev=tpm0 \\"
# Configures global settings for secure firmware boot.
echo "-global driver=cfi.pflash01,property=secure,value=on \\"
  } >> $output_file; fi
# Attaches a virtual hard disk image using the VirtIO interface for efficient I/O.
echo -drive file=/var/lib/libvirt/images/${vm_name}.qcow2,format=qcow2,if=virtio,cache=writeback,discard=unmap \\ >>$output_file
# Adds a virtual tablet device to capture mouse inputs smoothly.
echo -device virtio-tablet,wheel-axis=true \\ >>$output_file
# Adds a USB Enhanced Host Controller Interface (EHCI) and enables USB support in the VM.
echo -usb -device usb-ehci,id=ehci \\ >>$output_file
# Passes a specific USB device (e.g., a Realtek USB network adapter) to the VM.
[ "$vm_usb_network" = yes ] && echo "-device usb-host,bus=ehci.0,vendorid=0x0bda,productid=0x8153 \\" >>$output_file
# Using my android mobil with DroidCamX to seve as a webcam. Forwardng this to the Windows guest: http://192.168.1.59:4747/
[ "$vm_with_redirect_ip_webcam" = yes ] && echo "-device virtio-net-pci,netdev=unet -netdev user,id=unet,hostfwd=tcp::4747-:${vm_redirect_port} \\" >>$output_file
# Adds duplex audio with pipewire to vm
[ "$vm_audio"  = yes ] && echo "-audiodev pipewire,id=audio0 -device intel-hda -device hda-duplex,audiodev=audio0 \\" >>$output_file
# Adds a USB 3.0 XHCI controller for better USB device support
echo -device qemu-xhci,id=xhci \\ >>$output_file
# korrekte Zeitsynchronisierung und UTC als Basiszeit
echo -rtc base=utc,clock=host \\ >>$output_file
# Sets the VGA display to QXL for use with SPICE (a remote display protocol).
echo -vga qxl \\ >>$output_file
# Adds a VirtIO serial port for improved guest communication.
echo -device virtio-serial-pci \\ >>$output_file
# Configures the SPICE server to listen on localhost (127.0.0.1) at $spice_port with no authentication required.
echo -spice addr=127.0.0.1,port=${spice_port},disable-ticketing=on \\ >>$output_file
# Adds a virtual serial port for the SPICE agent channel.
echo -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \\ >>$output_file
# Creates a character device for SPICE communication with the guest.
echo -chardev spicevmc,id=spicechannel0,name=vdagent \\ >>$output_file
# Adds USB redirection support, allowing USB devices from the client machine to be redirected from spice to the VM.
if [ "$vm_usb_redirect" = yes ]; then  {
  echo "-device ich9-usb-ehci1,id=usb \\"
  echo "-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on" \\
  echo "-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\"
  echo "-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \\"
  echo "-chardev spicevmc,name=usbredir,id=usbredirchardev1 \\"
  echo "-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\"
  echo "-chardev spicevmc,name=usbredir,id=usbredirchardev2 \\"
  echo "-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\"
  echo "-chardev spicevmc,name=usbredir,id=usbredirchardev3 \\"
  echo "-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\"
  } >> "$output_file"; fi
# Adds a network device using VirtIO for efficient networking and sets up a shared folder from the host to the VM.
echo -device virtio-net,netdev=vmnic -netdev restrict=${vm_without_internet},type=user,id=vmnic,smb=${vm_smb_drive} \\ >>$output_file
# Opens a monitor console via Telnet on port $vm_monitor_port for managing the VM.
echo -monitor telnet::$vm_monitor_port,server,nowait \\ >>$output_file
# Attaches multiple ISO images as virtual CD-ROM drives to the VM for installation or upgrade purposes.
[ -f "$vm_cdrom_0" ] && echo "-drive if=ide,index=0,media=cdrom,file=${vm_cdrom_0} \\" >>$output_file
[ -f "$vm_cdrom_1" ] && echo "-drive if=ide,index=1,media=cdrom,file=${vm_cdrom_1} \\" >>$output_file
[ -f "$vm_cdrom_2" ] && echo "-drive if=ide,index=2,media=cdrom,file=${vm_cdrom_2} \\" >>$output_file
# When the -snapshot option is enabled, any changes made to the virtual disk(s) during the VM session are not written to the actual disk image files. Instead, they are stored temporarily in memory or in a temporary file.
# Save snapshot using the QEMU monitor with telnet with "telnet localhost $vm_monitor_port" and command "commit virtio0"
[ "$vm_kiosk_mode" = yes ] && echo "-snapshot \\" >> $output_file
# echo -d cpu_reset,int,guest_errors \\ >> $output_file
# The & at the end runs the QEMU process in the background.
echo \& >>$output_file

# Open the SPICE client with the name and 800x600
echo "spicy -h localhost -p ${spice_port} &"                             >> $output_file
echo PID=\$!                                                             >> $output_file               
echo sleep 2                                                             >> $output_file
echo  echo "\"Spicy started with PID: \$PID\""                           >> $output_file
echo 'WINDOW_ID=$(wmctrl -lp | grep "$PID" | awk '"'"'{print $1}'"'"')'  >> $output_file
echo  echo "\"Found window with ID: \$WINDOW_ID for PID: \$PID\""        >> $output_file
echo "NEW_NAME=$vm_name"                                                 >> $output_file
echo 'wmctrl -i -r "$WINDOW_ID" -T "$NEW_NAME"'                          >> $output_file
echo 'wmctrl -i -r "$WINDOW_ID" -e 0,100,100,800,600'                    >> $output_file

# Start everything
cat $output_file
cat $output_file | bash

echo +++++++++++++++++++++++++++++++++++++
echo Komprimierung der Image-Datei 
echo time nice ionice -c 3 qemu-img convert -c -p -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 -O qcow2 /var/lib/libvirt/images/${vm_name}.comp.qcow2
echo cp /var/lib/libvirt/images/${vm_name}.comp.qcow2 /var/lib/libvirt/images/${vm_name}.qcow2
echo ls -l /var/lib/libvirt/images \&\& find /var/lib/libvirt/images \| sort 
echo pluma tia19.sh office.sh win11.sh \&
echo killall swtpm
echo sudo service smbd restart
echo telnet localhost $vm_monitor_port
echo \(qemu\) system_powerdown

