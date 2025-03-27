# Begin defining the command to launch the QEMU system emulator

# Define the output file 
output_file=`/bin/mktemp`

# Define the image directory -
image_dir="/home/boss/Desktop/Arbeit/KVM"

# TPM emulator
if [ "$TSM" = yes ]; then {
# Creates a directory (/tmp/emulated_tpm_${vm_name}) for storing TPM state files. 
echo "mkdir -p /tmp/emulated_tpm_${vm_name} &&"
# Runs the swtpm software TPM 2.0 emulator as a background daemon process. 
echo "swtpm socket \\"
# Specifies the directory to store the TPM state files.
echo "--tpmstate dir=/tmp/emulated_tpm_${vm_name} \\"
# Defines a Unix domain socket (swtpm-sock) for communicating with the TPM emulator.
echo "--ctrl type=unixio,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
# Runs the swtpm as a daemon, so it continues running in the background.
echo "--daemon &&"
} >> "$output_file"; fi

# Launches the QEMU virtual machine emulator with specific options and configurations.
echo /usr/bin/qemu-system-x86_64 \\ >> "$output_file"

# Setting a name for the QEMU VM
echo -name $vm_name,debug-threads=on \\ >> "$output_file"
#echo -name $vm_name \\ >> "$output_file"

# Hardware config
# Configures the CPU to match the host CPU and enable several CPU features for better virtualization performance.
echo -cpu host,migratable=on,hv-time=on,hv-relaxed=on,hv-vapic=on,hv-spinlocks=0x1fff \\ >> "$output_file"
# Enables KVM (Kernel-based Virtual Machine) acceleration for better performance on compatible CPUs.
echo -enable-kvm \\ >> "$output_file" 
# Allocates X GB of RAM to the virtual machine
echo -m $vm_memory \\ >> "$output_file"
# Configures 4 CPUs with 1 socket, 2 cores per socket, and 2 threads per core.
echo -smp $vm_smp \\ >> "$output_file"
# Specifies the machine type with the Q35 chipset and configures various machine features.
echo -machine q35,usb=off,vmport=off,smm=on,dump-guest-core=off,hpet=off,acpi=on \\ >> "$output_file"
# Config the Programmable Interval Timer
echo -global kvm-pit.lost_tick_policy=delay \\ >> "$output_file"
# Suppresses the default networking configuration and the creation of several other default devices.
echo -nodefaults -serial none -parallel none -no-user-config \\ >> "$output_file"
# Boot
echo -boot strict=on \\ >> "$output_file"
# no sleep
echo -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \\ >> "$output_file"

# Adds UEFI firmware files to support secure boot.
[ "$uefi_ovmf" = short ] && echo "-bios /usr/share/ovmf/OVMF.fd \\" >> "$output_file"
if [ "$uefi_ovmf" = long ]; then {
echo "-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \\"
echo "-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \\"
} >> "$output_file"; fi

# TPM emulator
if [ "$TSM" = yes ]; then {
# Defines a character device for the TPM, connected via the socket created earlier (swtpm-sock)
echo "-chardev socket,id=chrtpm,path=/tmp/emulated_tpm_${vm_name}/swtpm-sock \\"
# Sets up the TPM device using the previously defined chardev. The tpm-tis device is a TPM interface type.
echo "-tpmdev emulator,id=tpm0,chardev=chrtpm -device tpm-tis,tpmdev=tpm0 \\"
# Configures global settings for secure firmware boot.
echo "-global driver=cfi.pflash01,property=secure,value=on \\"
} >> "$output_file"; fi

# Attaches a virtual hard disk image using the VirtIO interface for efficient I/O.
echo -drive file=${image_dir}/${vm_name}.qcow2,format=qcow2,if=virtio,cache=writeback,discard=unmap \\ >> "$output_file"

# Adds a virtual tablet device to capture mouse inputs smoothly.
echo -device virtio-tablet,wheel-axis=true \\ >> "$output_file"

# enables USB support and adds a USB 2.0 EHCI and USB 3.0 XHCI controller in the VM.
echo -usb \\ >> "$output_file"
echo -device usb-ehci,id=ehci \\ >> "$output_file"
echo -device qemu-xhci,id=xhci \\ >> "$output_file"

# Map webcam from Notebook to virtual machine. Check permision, set udev rule.
if [ "$vm_webcam" = yes ]; then { 
echo -device usb-host,vendorid=0x04f2,productid=0xb735 \\ 
echo -device usb-host,vendorid=0x04f2,productid=0xb5b9 \\ 
} >> "$output_file"; fi

# Passes a specific USB device (e.g., a Realtek USB network adapter) to the VM. Check permision, set udev rule.
[ "$vm_usb_network" = yes ] && echo "-device usb-host,bus=ehci.0,vendorid=0x0bda,productid=0x8153 \\" >> "$output_file"

# Adds duplex audio with PipeWire to VM - ignor error "intel-hda: write to r/o reg". Check permision, set udev rule.
if [ "$vm_audio" = pipewire ]; then { 
echo "-audiodev pipewire,id=audio0 \\"
echo "-device intel-hda \\"
echo "-device hda-duplex,audiodev=audio0 \\" 
} >> "$output_file"; fi

# Adds duplex audio with USB Headset. Check permision, set udev rule.
if [ "$vm_audio" = usbaudio ]; then { 
echo "-device usb-host,vendorid=0x08bb,productid=0x2902 \\"
} >> "$output_file"; fi

# Correct time synchronization and UTC as base time
echo -rtc base=utc,clock=host,driftfix=slew \\ >> "$output_file"

# SPICE Support
# Sets the VGA display to QXL
echo -vga qxl \\ >> "$output_file"
# Adds a VirtIO serial port for improved guest communication.
echo -device virtio-serial-pci \\ >> "$output_file"
# Configures the SPICE server to listen on localhost (127.0.0.1) at $spice_port with no authentication required.
echo -spice addr=127.0.0.1,port=${spice_port},disable-ticketing=on \\ >> "$output_file"
# Adds a virtual serial port for the SPICE agent channel.
echo -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \\ >> "$output_file"
# Creates a character device for SPICE communication with the guest.
echo -chardev spicevmc,id=spicechannel0,name=vdagent \\ >> "$output_file"

# Adds USB redirection support, allowing USB devices from the client machine to be redirected from SPICE to the VM.
if [ "$vm_usb_redirect" = yes ]; then {
echo "-device ich9-usb-ehci1,id=usb \\"
echo "-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \\"
echo "-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\"
echo "-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \\"
echo "-chardev spicevmc,name=usbredir,id=usbredirchardev1 \\"
echo "-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\"
echo "-chardev spicevmc,name=usbredir,id=usbredirchardev2 \\"
echo "-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\"
echo "-chardev spicevmc,name=usbredir,id=usbredirchardev3 \\"
echo "-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\"
} >> "$output_file"; fi

# virtiofs
# https://github.com/winfsp/winfsp/
# /usr/libexec/virtiofsd --socket-path=/tmp/vhostqemu --shared-dir=/home/boss/Desktop/Arbeit
#echo -device vhost-user-fs-pci,chardev=chr-vu-fs0,tag=myfs \\ >> "$output_file"
#echo -chardev socket,id=chr-vu-fs0,path=/tmp/vhostqemu \\ >> "$output_file"

# user-mode networking with Samba folder sharing.
echo -device virtio-net,netdev=vmnic \\ >> "$output_file"
echo -netdev restrict=${vm_without_internet},type=user,id=vmnic,smb=${vm_smb_drive} \\ >> "$output_file"

# Opens a monitor console via Telnet on port $vm_monitor_port for managing the VM.
echo -monitor telnet::$vm_monitor_port,server,nowait \\ >> "$output_file"

# Attaches multiple ISO images as virtual CD-ROM drives to the VM for installation or upgrade purposes.
[ -f "$vm_cdrom_0" ] && echo "-drive if=ide,index=0,media=cdrom,file=${vm_cdrom_0} \\" >> "$output_file"
[ -f "$vm_cdrom_1" ] && echo "-drive if=ide,index=1,media=cdrom,file=${vm_cdrom_1} \\" >> "$output_file"
[ -f "$vm_cdrom_2" ] && echo "-drive if=ide,index=2,media=cdrom,file=${vm_cdrom_2} \\" >> "$output_file"

# When the -snapshot option is enabled, any changes made to the virtual disk(s) during the VM session are not written to the actual disk image files. Instead, they are stored temporarily in memory or in a temporary file.
# Save snapshot using the QEMU monitor with telnet with "telnet localhost $vm_monitor_port" and command "commit virtio0"
[ "$vm_kiosk_mode" = yes ] && echo "-snapshot \\" >> "$output_file"

# Enables debugging options for instruction disassembly, CPU, MMU, and guest errors.
# intel-hda: write to r/o reg CORBSIZE and RIRBSIZE is audio init - ignore
if [ "$vm_debug" = yes ] ; then {
echo -d in_asm,cpu,mmu,guest_errors \\
# echo -D /tmp/${vm_name}.log \\ 
} >> "$output_file"; fi

# The & at the end runs the QEMU process in the background.
echo \& >> "$output_file"

# Open the SPICE client with the name and resize to 800x600
{ echo "spicy -h localhost -p ${spice_port} &"
echo "PID=\$!"
echo "sleep 2"
echo "WINDOW_ID=\$(wmctrl -lp | grep \"\$PID\" | awk '{print \$1}')"
echo "echo \"Found spicy window with WINDOW_ID: \$WINDOW_ID for PID: \$PID\""
echo "NEW_NAME=${vm_name}-${vm_name}-${vm_name}"
[ "$vm_kiosk_mode" = yes ] && echo "NEW_NAME=${vm_name}-Kiosk_Mode-${vm_name}"
echo "wmctrl -i -r \$WINDOW_ID -T \$NEW_NAME"
echo "wmctrl -i -r \$WINDOW_ID -e 0,100,100,1024,768"
echo "/usr/local/bin/xseticon -id \"\$WINDOW_ID\" ${vm_icon}"
} >> "$output_file"

# If vm_debug is set to yes, display "$output_file" 
[ "$vm_debug" = yes ] && cat "$output_file"

# Start everything and erase
bash "$output_file" && rm "$output_file"


echo +++++++++++++++info+++++++++++++++++
echo Compression of the image file 
echo time nice ionice -c 3 qemu-img convert -c -p -f qcow2 ${image_dir}/${vm_name}.qcow2 -O qcow2 ${image_dir}/${vm_name}.comp.qcow2
echo time nice ionice -c 3 sudo virt-sparsify --compress ${image_dir}/${vm_name}.qcow2 ${image_dir}/${vm_name}.comp.qcow2 \&\& chown boss:boss ${image_dir}/${vm_name}.comp.qcow2 
echo cp ${image_dir}/${vm_name}.comp.qcow2 ${image_dir}/${vm_name}.qcow2
echo mv ${image_dir}/${vm_name}.qcow2 ${image_dir}/$(date +"%y%m%d")-${vm_name}.qcow2
echo time nice ionice -c 3 7z a -mx=1 -mmt=on -p ${image_dir}/$(date +"%y%m%d")-${vm_name}.qcow2.7z ${image_dir}/${vm_name}.qcow2 
echo ls -l ${image_dir} \&\& find ${image_dir} \| sort 
echo "pluma ~/kvm.sh ~/win11.sh ~/office.sh ~/tia19.sh" \&
echo killall swtpm
echo sudo service smbd restart
echo telnet localhost $vm_monitor_port
echo \(qemu\) system_powerdown
