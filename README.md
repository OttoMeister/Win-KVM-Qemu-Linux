# Win-KVM-Qemu-Linux
Windows 10 and 11 on Linux using KVM and Qemu

### Preparacion:
Installing all tools:
```bash
sudo apt-get install  qemu-kvm  bridge-utils ovmf virt-manager samba qemu-utils qemu-system-x86  virt-viewer spice-client-gtk libvirt-daemon-system
```
check if your system supports KVM:
```bash
kvm-ok
```

## Install Windows 11 on KVM
Download image from https://msdl.gravesoft.dev (Windows 11 23H2 v2 (Build 22631.2861), US English, IsoX64 Download)
```bash
sudo mv ~/Downloads/Win11_23H2_English_x64v2.iso /var/lib/libvirt/images/win11.iso
```
#### Download drivers
```bash
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv ./virtio-win.iso /var/lib/libvirt/images/
```
#### Make image
```bash
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/win11.qcow2 80G 
sudo chmod a+w /var/lib/libvirt/images/win11.qcow2
sudo killall swtpm
sudo rm -rf /tmp/emulated_tpm
```
#### Install Windows 11 Pro N 
```bash
mkdir -p /tmp/emulated_tpm
swtpm socket --tpmstate dir=/tmp/emulated_tpm --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock --daemon
/usr/bin/qemu-system-x86_64 \
-cpu host,migratable=on,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
-enable-kvm \
-m 8G \
-smp 6 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \
-chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
-tpmdev emulator,id=tpm0,chardev=chrtpm \
-device tpm-tis,tpmdev=tpm0 \
-machine pc-q35-6.2,accel=kvm,smm=on \
-boot d -cdrom /var/lib/libvirt/images/win11.iso \
-drive file=/var/lib/libvirt/images/win11.qcow2,format=qcow2,if=virtio \
-drive if=ide,index=3,media=cdrom,file=/var/lib/libvirt/images/virtio-win.iso \
-device qemu-xhci -device usb-tablet \
-netdev user,id=net0 -device e1000,netdev=net0 \
-global driver=cfi.pflash01,property=secure,value=on
```
Boot: Press Enter at boot. <br>
Setup: Select "I do not have a key", Choose Win11ProN, Select Custom: Install Windows only. <br>
Load Driver: E:\viostor\w11\amd64. <br>
Disable Internet Requirement: Shift + F10 -> oobe\bypassnro -> Enter, Reboot -> Shift + F10 -> ipconfig /release -> Enter. <br>
Regional Settings: United States -> Yes. US -> Yes. Add German (Germany) layout. <br>
Internet Setup: Select "I do not have internet". Continue with limited setup.  <br>
User Setup: Username: user -> Next.Password: user -> Next. Skip unnecessary options (Spy, Cortana). <br>
Finalize: Shutdown, then restart. Install drivers: E:\virtio-win-guest-tools.exe. <br>
Now start your Windows 11 setup. <br>
```bash
mkdir -p /tmp/emulated_tpm && \
swtpm socket \
  --tpmstate dir=/tmp/emulated_tpm \
  --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock \
  --daemon && \
/usr/bin/qemu-system-x86_64 \
  -cpu host,migratable=on,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -enable-kvm \
  -m 8G \
  -smp 6 \
  -machine pc-q35-6.2,accel=kvm,smm=on \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \
  -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -drive file=/var/lib/libvirt/images/win11.qcow2,format=qcow2,if=virtio \
  -device qemu-xhci \
  -device usb-tablet \
  -global driver=cfi.pflash01,property=secure,value=on \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,smb=/home/user/Schreibtisch/Arbeit \
  -vga qxl \
  -device virtio-serial-pci \
  -spice port=3001,disable-ticketing=on \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -display spice-app
```
#### Usefull Tools: <br>
https://download.sysinternals.com/files/AutoLogon.zip <br>
https://download.sysinternals.com/files/SDelete.zip <br>
https://www.7-zip.org/download.html <br>
https://www.mozilla.org/en-US/firefox/all/#product-desktop-release <br>
https://github.com/valinet/ExplorerPatcher
https://github.com/hellzerg/optimizer/releases/latest <br>
https://github.com/ionuttbara/one-drive-uninstaller <br>
https://github.com/Open-Shell/Open-Shell-Menu/releases/latest <br>
https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/Remove-EdgeOnly.exe  <br>

## Install Windows 10 on KVM

#### Download image
Download image from https://msdl.gravesoft.dev (Windows 10 22H2 v1 ,Build 19045.2965, US English, IsoX64 Download)
```bash
sudo mv ~/Downloads/Win10_22H2_English_x64v1.iso /var/lib/libvirt/images/win10.iso
```
#### Download drivers
```bash
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv ./virtio-win.iso /var/lib/libvirt/images/
```
#### Make image
```bash
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/win10.qcow2 80G 
sudo chmod a+w /var/lib/libvirt/images/win10.qcow2
```
#### Install Windows 10 Pro N 
```bash
/usr/bin/qemu-system-x86_64 \
  -cpu host \
  -boot d \
  -cdrom /var/lib/libvirt/images/win10.iso \
  -enable-kvm \
  -m 4G \
  -drive file=/var/lib/libvirt/images/win10.qcow2,format=qcow2 \
  -drive if=ide,index=3,media=cdrom,file=/var/lib/libvirt/images/virtio-win.iso \
  -device virtio-tablet,wheel-axis=true \
  -net none
```
Press Enter at Boot, no Key, Win10ProN, Custom: Install Windows only, load Driver E:\viostor\w10\amd64, unhide, no internet, user user, pwd user, no Spy, no Cortana.<br>
After installation install all Win Guest Tools and Drivers: E:\virtio-win-guest-tools.exe
#### shutdown and reboot using this command:
```bash
/usr/bin/qemu-system-x86_64 \
  -enable-kvm \
  -m 8G \
  -smp 6,sockets=1,cores=3,threads=2 \
  -cpu host \
  -drive file=/var/lib/libvirt/images/win10.qcow2 \
  -device qemu-xhci \
  -device virtio-tablet,wheel-axis=true \
  -vga qxl \
  -device virtio-serial-pci \
  -spice port=3001,disable-ticketing=on \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -display spice-app \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,smb=/home/user/Schreibtisch/Arbeit \
```
Activate Windows -> open Powershell and insert "irm https://get.activated.win | iex" -> Enter -> 1 -> Enter <br>
Make all updates, any update like KB5034441 with error 0x80070643, you can make them unseen: <br>
http://download.microsoft.com/download/F/2/2/F22D5FDB-59CD-4275-8C95-1BE17BF70B21/wushowhide.diagcab <br>
#### Download Drivers and Tools on Linux and use drag and drop to install: <br>
Ethernet-USB drivers "AX88179_178A_Win7_v1.x.11.0_Drivers_Setup_v3.0.3.0.zip" and Realtek "USB 3.0 LAN Driver_10.005.zip" <br>
#### Usefull Tools: <br>
https://download.sysinternals.com/files/AutoLogon.zip <br>
https://download.sysinternals.com/files/SDelete.zip <br>
https://www.7-zip.org/download.html <br>
https://www.mozilla.org/en-US/firefox/all/#product-desktop-release <br>
https://github.com/valinet/ExplorerPatcher
https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/Remove-EdgeOnly.exe  <br>
https://github.com/Open-Shell/Open-Shell-Menu/releases/latest <br>
https://github.com/hellzerg/optimizer/releases/latest <br>
https://github.com/ionuttbara/one-drive-uninstaller <br>

## Move from VMware to KVM
Uninstall vmware utils using VMware <br>
Disable Hibernate in Windows 10: <br>
https://www.tenforums.com/tutorials/2859-enable-disable-hibernate-windows-10-a.html <br> 
Disable Sleep Mode In Windows 10: <br>
https://www.intowindows.com/how-to-enable-or-disable-sleep-mode-in-windows-10 <br>
Turn Off Fast Startup in Windows 10: <br>
https://www.tenforums.com/tutorials/4189-turn-off-fast-startup-windows-10-a.html <br>
#### download drivers
```bash
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv ./virtio-win.iso /var/lib/libvirt/images/
```
Copy virtual disk from VMWARE and install it in Linux
```bash
sudo rm /var/lib/libvirt/images/Siemens_TIA19.qcow2
sudo qemu-img convert -f vmdk -O qcow2 /home/user/Schreibtisch/Siemens_TIA19.vmdk /var/lib/libvirt/images/Siemens_TIA19.qcow2
sudo chmod a+w /var/lib/libvirt/images/Siemens_TIA19.qcow2
```
In Windows 10 after start qemu run D:\virtio-win-guest-tools.exe

## Gereric Infos and Qemu parameters

### qemu-system-x86_64 - Base parameters for Windows 11
```bash
mkdir -p /tmp/emulated_tpm && \
swtpm socket \
  --tpmstate dir=/tmp/emulated_tpm \
  --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock \
  --daemon && \
/usr/bin/qemu-system-x86_64 \
  -cpu host,migratable=on,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -enable-kvm \
  -m 8G \
  -smp 6,sockets=1,cores=3,threads=2 \
  -machine pc-q35-6.2,accel=kvm,smm=on \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \
  -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -global driver=cfi.pflash01,property=secure,value=on \
  -drive file=/var/lib/libvirt/images/win11.qcow2,format=qcow2,if=virtio \
  -device virtio-tablet,wheel-axis=true 
```

### qemu-system-x86_64 - Base parameters for Windows 10
```bash
/usr/bin/qemu-system-x86_64 \
  -enable-kvm \
  -m 8G \
  -smp 6,sockets=1,cores=3,threads=2 \
  -cpu host \
  -drive file=/var/lib/libvirt/images/win10.qcow2 \
  -device virtio-tablet,wheel-axis=true 
```

### qemu-system-x86_64 - Atatch CD-ROM with the drivers
Atatch one CD-ROM with the drivers
```bash
-cdrom /var/lib/libvirt/images/virtio-win.iso
```
Atatch two CD-ROM with the drivers
```bash
-drive if=ide,index=1,media=cdrom,file=/var/lib/libvirt/images/win10.iso 
-drive if=ide,index=2,media=cdrom,file=/var/lib/libvirt/images/virtio-win.iso
```

### qemu-system-x86_64 - Pass-Through Access to a Host USB Ethernet Stick
kernel: usb 3-4.2: new high-speed USB device number 12 using xhci_hcd <br>
kernel: usb 3-4.2: New USB device found, idVendor=0bda, idProduct=8153, bcdDevice=30.00 <br>
kernel: usb 3-4.2: New USB device strings: Mfr=1, Product=2, SerialNumber=6 <br>
kernel: usb 3-4.2: Product: USB 10/100/1000 LAN <br>
kernel: usb 3-4.2: Manufacturer: Realtek <br>
kernel: usb 3-4.2: SerialNumber: 000001 <br>
kernel: r8152-cfgselector 3-4.2: reset high-speed USB device number 12 using xhci_hcd <br>
kernel: r8152 3-4.2:1.0: load rtl8153a-4 v2 02/07/20 successfully <br>
Bus 003 Device 012: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter <br>
idVendor           0x0bda Realtek Semiconductor Corp. <br>
idProduct          0x8153 RTL8153 Gigabit Ethernet Adapter <br>
check permision:  <br>
```bash
ls -l /dev/bus/usb/003/012
crw-rw-r-- 1 root root 189, 267 Mai 23 16:18 /dev/bus/usb/003/012
```
change user:  <br>
```bash
sudo echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8153", OWNER="root", GROUP="kvm", MODE="0666"' > /etc/udev/rules.d/99-usb-stick.rules
udevadm control --reload-rules && udevadm trigger
```
check permision again:  <br>
```bash
ls -l /dev/bus/usb/003/012
```
crw-rw-rw- 1 root kvm 189, 267 Mai 23 17:43 /dev/bus/usb/003/012  <br> <br>
Now start quem with this parameter to use usb ethernet device <br>
```bash
-device usb-ehci,id=ehci -usb -device usb-host,bus=ehci.0,vendorid=0x0bda,productid=0x8153
```

### qemu-system-x86_64 - Adds audio  (untested)
```bash
-audiodev driver=spice,id=audio -device intel-hda -device hda-duplex,audiodev=audio 
```

### qemu-system-x86_64 - Enable USB3 support by emulating an XHCI controller (untested)
```bash
-device qemu-xhci,id=xhci 
```

### qemu-system-x86_64 - Emulate a tablet pointing device with mouse scroll support
```bash
-device virtio-tablet,wheel-axis=true 
```

### qemu-system-x86_64 - SPICE (Simple Protocol for Independent Computing Environments)
Copy & Paste + Drag & Drop + Automatic Resolution Adjustment <br>
Start quem with this parameter to use direct spice app: <br>
```bash
-vga qxl -device virtio-serial-pci -spice port=3001,disable-ticketing=on -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent -display spice-app
```
Start quem with this parameter to connect later with spice in second line:
```bash
-vga qxl -device virtio-serial-pci -spice port=3001,disable-ticketing=on -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent
```
Use one to connect to VM
```bash
remote-viewer spice://localhost:3001
spicy -h localhost -p 3001
```
Configure two USB redirection channel for spice.
```bash
-device usb-redir,chardev=usbredir0 -chardev spicevmc,id=usbredir0,name=usbredir \
-device usb-redir,chardev=usbredir1 -chardev spicevmc,id=usbredir1,name=usbredir
```

### qemu-system-x86_64 - The QEMU control console 
It will be launched from the same terminal this script runs from.
```bash
-monitor stdio
```
Use the QEMU monitor with telnet:
```bash
-monitor telnet::45454,server,nowait -serial mon:stdio
```
and on a host terminal:
```bash
telnet localhost 45454
```



### qemu-system-x86_64 - Netzwerk  Ping probleme
Command on host for working Ping until next boot:
```bash
sudo sysctl -w net.ipv4.ping_group_range='0 2147483647'
```
Command on host for working Ping forever (on linux host):
```bash
echo "net.ipv4.ping_group_range = 0 2147483647" | sudo tee -a /etc/sysctl.conf
```
    
### qemu-system-x86_64 - Virtuel Network using virtio driver
```bash
-device virtio-net,netdev=vmnic -netdev user,id=vmnic
```

### qemu-system-x86_64 - Easy File Sharing with QEMU's built-in SMB
```bash
-device virtio-net,netdev=vmnic -netdev user,id=vmnic,smb=/home/user/Schreibtisch/Arbeit
```
In windows:  <br><br>
explorer: \\\\10.0.2.4\qemu   ---> Map network device... <br><br>
On host:  <br>
```bash
sudo pluma /etc/samba/smb.conf
# Start /etc/samba/smb.conf 
[global]
	bind interfaces only = Yes
	interfaces = lo br0
	idmap config * : backend = tdb
[share]
	force user = user
	path = /home/user/Schreibtisch/Arbeit
	read only = No
# End /etc/samba/smb.conf   
testparm -s
sudo service smbd restart
sudo ufw allow samba
```

### Clean up the virtual drive (remove temps files, etc) 
Defrag with the open source UltraDefrag software with "full optimisation" <br>
Downlod tool: https://learn.microsoft.com/en-us/sysinternals/downloads/sdelete <br>
Clean with https://www.wisecleaner.com/wise-disk-cleaner.html <br>
On client:  <br>
```bash
sdelete -c c:
sdelete -z c:
```
On host:
```bash
time nice ionice -c 3 qemu-img convert -c -p -f qcow2 /var/lib/libvirt/images/win10.qcow2  -O qcow2 /var/lib/libvirt/images/win10.comp.qcow2
cp /var/lib/libvirt/images/win10.comp.qcow2 /var/lib/libvirt/images/win10.qcow2
time nice ionice -c 3 qemu-img convert -c -p -f qcow2 /var/lib/libvirt/images/win10.qcow2  -O qcow2 /var/lib/libvirt/images/win10.comp.qcow2
cp /var/lib/libvirt/images/win11.comp.qcow2 /var/lib/libvirt/images/win11.qcow2
```
Note: do not compress the end file.<br>

