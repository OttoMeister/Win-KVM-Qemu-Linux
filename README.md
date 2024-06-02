# Win-KVM-Qemu-Linux

#### Windows 10 and 11 on Linux using KVM and Qemu


## Install Windows 11 auf KVM
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
#### Press Enter at boot, I do not have key, Win11ProN, Custom: Install Windows only, load Driver E:\viostor\w11\amd64, next -> installing Windows, 
#Use the "Shift + F10" keyboard shortcut to open Command Prompt on the Windows 11 setup.
#Type the following command to disable the internet connection requirement to set up Windows 11 and press Enter: oobe\bypassnro -> Enter -> boot, "Shift + F10" ->  ipconfig /release  -> Enter, United States, Yes, US, Yes, add second layout, German (Germany), Add, I do not have internet, Continue with limited setup, boss -> next -> boss, boss, stupid questions -> next, no Spy, no Cortana.
########### Sutdown if finish and start new. Install all Win Guest Tools and Drivers: E:\virtio-win-guest-tools.exe
########### Now start it like this:
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
  -netdev user,id=vmnic,smb=/home/boss/Schreibtisch/Arbeit \
  -vga qxl \
  -device virtio-serial-pci \
  -spice port=3001,disable-ticketing=on \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -display spice-app





