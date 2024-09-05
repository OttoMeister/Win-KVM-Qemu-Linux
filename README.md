# Win-KVM-Qemu-Linux
Windows 11 on Linux using KVM and Qemu

## Preparacion:
Installing all tools:
```
sudo apt-get install  qemu-kvm  bridge-utils ovmf virt-manager samba qemu-utils qemu-system-x86  virt-viewer spice-client-gtk libvirt-daemon-system
```
check if your system supports KVM:
```
kvm-ok
```

## Install Windows 11 on KVM
Download image from https://msdl.gravesoft.dev (Windows 11 23H2 v2 (Build 22631.2861), US English, IsoX64 Download)
```
sudo mv ~/Downloads/Win11_23H2_English_x64v2.iso /var/lib/libvirt/images/win11.iso
```
#### Download drivers
```
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv ./virtio-win.iso /var/lib/libvirt/images/
```
#### Make image
```
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/win11.qcow2 80G 
sudo chmod a+w /var/lib/libvirt/images/win11.qcow2
sudo killall swtpm
sudo rm -rf /tmp/emulated_tpm
```
#### Install Windows 11 Pro N 
```
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
Activate Windows -> open Powershell and insert "irm https://get.activated.win | iex" -> Enter -> 1 -> Enter <br>
Disable taskbar thumbnail preview using Windows Registry: <br>
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ExtendedUIHoverTime  DWORD 30000 <br>
Now start your Windows 11 setup. <br>
```
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
https://github.com/valinet/ExplorerPatcher <br>
https://github.com/hellzerg/optimizer/releases/latest <br>
https://github.com/ionuttbara/one-drive-uninstaller <br>
https://github.com/Open-Shell/Open-Shell-Menu/releases/latest <br>
https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/Remove-EdgeOnly.exe  <br>
https://github.com/massgravel/Microsoft-Activation-Scripts <br>
https://github.com/es3n1n/no-defender <br>


## Move from VMware to KVM
Uninstall vmware utils using VMware <br>
Disable Hibernate in Windows 10: <br>
https://www.tenforums.com/tutorials/2859-enable-disable-hibernate-windows-10-a.html <br> 
Disable Sleep Mode In Windows 10: <br>
https://www.intowindows.com/how-to-enable-or-disable-sleep-mode-in-windows-10 <br>
Turn Off Fast Startup in Windows 10: <br>
https://www.tenforums.com/tutorials/4189-turn-off-fast-startup-windows-10-a.html <br><br>
download drivers <br>
```
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
sudo mv ./virtio-win.iso /var/lib/libvirt/images/
```
Copy virtual disk from VMWARE and install it in Linux
```
sudo rm /var/lib/libvirt/images/Siemens_TIA19.qcow2
sudo qemu-img convert -f vmdk -O qcow2 /home/user/Schreibtisch/Siemens_TIA19.vmdk /var/lib/libvirt/images/Siemens_TIA19.qcow2
sudo chmod a+w /var/lib/libvirt/images/Siemens_TIA19.qcow2
```
In Windows after start qemu run D:\virtio-win-guest-tools.exe

## Gereric Infos and Qemu parameters

#### Base parameters for Windows 11
```
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
  -serial none \
  -parallel none \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \
  -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -device tpm-tis,tpmdev=tpm0 \
  -global driver=cfi.pflash01,property=secure,value=on \
  -drive file=/var/lib/libvirt/images/win11.qcow2,format=qcow2,if=virtio \
  -device virtio-tablet,wheel-axis=true  \
```

#### Base parameters for Windows 10
```
/usr/bin/qemu-system-x86_64 \
  -enable-kvm \
  -m 8G \
  -smp 6,sockets=1,cores=3,threads=2 \
  -cpu host \
  -drive file=/var/lib/libvirt/images/win10.qcow2 \
  -device virtio-tablet,wheel-axis=true  \
```

#### Atatch CD-ROM with the drivers
Atatch one CD-ROM with the drivers
```
-cdrom /var/lib/libvirt/images/virtio-win.iso \
```
Atatch two CD-ROM with the drivers
```
-drive if=ide,index=1,media=cdrom,file=/var/lib/libvirt/images/win10.iso  \
-drive if=ide,index=2,media=cdrom,file=/var/lib/libvirt/images/virtio-win.iso \
```

#### Pass-Through Access to a Host USB Ethernet Stick
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
```
lsusb
```
Bus 003 Device 012: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
```
ls -l /dev/bus/usb/003/012
```
crw-rw-r-- 1 root root 189, 267 Mai 23 16:18 /dev/bus/usb/003/012 <br> <br>
change user:  <br>
```
sudo echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8153", OWNER="root", GROUP="kvm", MODE="0666"' > /etc/udev/rules.d/99-usb-stick.rules
udevadm control --reload-rules && udevadm trigger
```
check permision again:  <br>
```
ls -l /dev/bus/usb/003/012
```
crw-rw-rw- 1 root kvm 189, 267 Mai 23 17:43 /dev/bus/usb/003/012  <br><br>

Now start quem with this parameter to use usb ethernet device <br>
```
-device usb-ehci,id=ehci -usb -device usb-host,bus=ehci.0,vendorid=0x0bda,productid=0x8153 \
```

#### Adds audio 
```
 -audiodev pipewire,id=audio0 -device intel-hda -device hda-duplex,audiodev=audio0 \
```

#### Enable USB3 support by emulating an XHCI controller
```
-device qemu-xhci,id=xhci \ 
```

#### Emulate a tablet pointing device with mouse scroll support
```
-device virtio-tablet,wheel-axis=true \
```

#### SPICE (Simple Protocol for Independent Computing Environments)
Copy & Paste + Drag & Drop + Automatic Resolution Adjustment <br>
Start quem with this parameter to use direct spice app: <br>
```
-vga qxl -device virtio-serial-pci -spice addr=127.0.0.1,port=3001,disable-ticketing=on \
-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
-chardev spicevmc,id=spicechannel0,name=vdagent \
-display spice-app \
```
Start quem with this parameter to connect later with spice:
```
-vga qxl -device virtio-serial-pci -spice addr=127.0.0.1,port=3001,disable-ticketing=on \
-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent \
```
Use one to connect to VM
```
remote-viewer spice://localhost:3001
spicy -h localhost -p 3001
```
Configure two USB redirection channel for spice.
```
-device usb-redir,chardev=usbredir0 -chardev spicevmc,id=usbredir0,name=usbredir \
-device usb-redir,chardev=usbredir1 -chardev spicevmc,id=usbredir1,name=usbredir \
```

#### The QEMU control console 
It will be launched from the same terminal this script runs from.
```
-monitor stdio \
```
Use the QEMU monitor with telnet:
```
-monitor telnet::45454,server,nowait \
```
and on a host terminal:
```
telnet localhost 45454
```

#### Netzwerk  Ping probleme
Command on host for working Ping until next boot:
```
sudo sysctl -w net.ipv4.ping_group_range='0 2147483647'
```
Command on host for working Ping forever (on linux host):
```
echo "net.ipv4.ping_group_range = 0 2147483647" | sudo tee -a /etc/sysctl.conf 
```
    
#### Virtuel Network using virtio driver
```
-device virtio-net,netdev=vmnic -netdev user,id=vmnic \
```

#### Port forwarting
Using my android mobil with DroidCamX to seve as a webcam. Forwardng this to the Windows guest: http://192.168.1.59:4747/
```
-device virtio-net-pci,netdev=unet \
-netdev user,id=unet,hostfwd=tcp::4747-:4747 \
```

#### Kiosk Mode
The -snapshot option is particularly useful in a kiosk mode scenario where you want the VM to return to a clean state after each session, ensuring that no user changes are permanent. <br>
Commit changes: Use in QEMU Monitor "commit virtio0" (if -snapshot is used) 
```
-snapshot \
```

#### Easy File Sharing with QEMU's built-in SMB
```
-device virtio-net,netdev=vmnic -netdev user,id=vmnic,smb=/home/user/Schreibtisch/Arbeit \
```
In windows:  <br><br>
explorer: \\\\10.0.2.4\qemu   ---> Map network device... <br><br>
On host:  <br>
```
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

#### Clean up the virtual drive (remove temps files, etc) 
Defrag with the open source UltraDefrag software with "full optimisation" <br>
Downlod tool: https://learn.microsoft.com/en-us/sysinternals/downloads/sdelete <br>
Clean with https://www.wisecleaner.com/wise-disk-cleaner.html <br>
On client:  <br>
```
sdelete -c c:
sdelete -z c:
```
On host:
```
time nice ionice -c 3 qemu-img convert -c -p -f qcow2 /var/lib/libvirt/images/win10.qcow2  -O qcow2 /var/lib/libvirt/images/win10.comp.qcow2
cp /var/lib/libvirt/images/win10.comp.qcow2 /var/lib/libvirt/images/win10.qcow2
time nice ionice -c 3 qemu-img convert -c -p -f qcow2 /var/lib/libvirt/images/win11.qcow2  -O qcow2 /var/lib/libvirt/images/win11.comp.qcow2
cp /var/lib/libvirt/images/win11.comp.qcow2 /var/lib/libvirt/images/win11.qcow2
```
Note: do not compress the end file.<br>

