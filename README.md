# Win-KVM-Qemu-Linux
Windows 10 and 11 on Linux using KVM and Qemu
### Install Windows 11 auf KVM
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
Press Enter at boot, I do not have key, Win11ProN, Custom: Install Windows only, load Driver E:\viostor\w11\amd64, next -> installing Windows, 
Use the "Shift + F10" keyboard shortcut to open Command Prompt on the Windows 11 setup. <br>
Type the following command to disable the internet connection requirement to set up Windows 11 and press Enter: oobe\bypassnro -> Enter -> boot, "Shift + F10" ->  ipconfig /release  -> Enter, United States, Yes, US, Yes, add second layout, German (Germany), Add, I do not have internet, Continue with limited setup, boss -> next -> boss, boss, stupid questions -> next, no Spy, no Cortana.  <br>
Sutdown if finish and start new. Install all Win Guest Tools and Drivers: E:\virtio-win-guest-tools.exe <br>
Now start it like this: <br>
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
https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/Remove-EdgeOnly.exe  <br>
https://download.sysinternals.com/files/AutoLogon.zip <br>
https://github.com/hellzerg/optimizer/releases/latest <br>
https://github.com/ionuttbara/one-drive-uninstaller <br>
https://www.7-zip.org/download.html <br>
https://download.sysinternals.com/files/SDelete.zip <br>
https://github.com/Open-Shell/Open-Shell-Menu/releases/latest <br>
https://www.mozilla.org/en-US/firefox/all/#product-desktop-release <br>

### Install Windows 10 auf KVM

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
Press Enter at Boot, no Key, Win10ProN, Custom: Install Windows only, load Driver E:\viostor\w10\amd64, unhide, no internet, user boss, pwd boss, no Spy, no Cortana.<br>
After installation install all Win Guest Tools and Drivers: E:\virtio-win-guest-tools.exe
#### shutdown and reboot using this command:
```bash
/usr/bin/qemu-system-x86_64 \
  -enable-kvm \
  -m 8G \
  -smp 6,sockets=1,cores=3,threads=2 \
  -cpu host \
  -drive file=/var/lib/libvirt/images/win10.qcow2 \
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
#### Download Drivers and Tools on Linux and use drag and dropand to install: <br>
Ethernet-USB drivers "AX88179_178A_Win7_v1.x.11.0_Drivers_Setup_v3.0.3.0.zip" and Realtek "USB 3.0 LAN Driver_10.005.zip" <br>
#### Usefull Tools: <br>
https://github.com/ShadowWhisperer/Remove-MS-Edge/blob/main/Remove-EdgeOnly.exe  <br>
https://download.sysinternals.com/files/AutoLogon.zip <br>
https://github.com/hellzerg/optimizer/releases/latest <br>
https://github.com/ionuttbara/one-drive-uninstaller <br>
https://www.7-zip.org/download.html <br>
https://download.sysinternals.com/files/SDelete.zip <br>
https://github.com/Open-Shell/Open-Shell-Menu/releases/latest <br>
https://www.mozilla.org/en-US/firefox/all/#product-desktop-release <br>


