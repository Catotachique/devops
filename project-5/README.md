# Introduction to Rancher: On-prem Kubernetes

<a href="https://youtu.be/1j5lhDzlFUM" title="k8s-rancher"><img src="https://i.ytimg.com/vi/1j5lhDzlFUM/hqdefault.jpg" width="20%" alt="k8s-rancher" /></a> 

This guide follows the general instructions of running a [manual rancher install](https://rancher.com/docs/rancher/v2.5/en/quick-start-guide/deployment/quickstart-manual-setup/) and running our own infrastructure on Hyper-v

# Hyper-V : Prepare our infrastructure

In this demo, we will use Hyper-V to create our infrastructure.</br>
For on-premise, many companies use either Hyper-V, VMWare Vsphere and other technologies to create virtual infrastructure on bare metal.</br>

Few points to note here:

* Benefit of Virtual infrastructure is that it's immutable
  a) We can add and throw away virtual machines at will.</br>
  b) This makes maintenance easier as we can roll updated virtual machines instead of 
     patching existing machines and turning them to long-living snowflakes.</br>
  c) Reduce lifespan of machines.</br>

* Bare Metal provides the compute. 
  a) We don't want Kubernetes directly on bare metal as we want machines to be immutable.</br>
  b) This goes back to the previous point on immutability.</br>

* Every virtual machine needs to be able to reach each other on the network</br>
  a) This is a kubernetes networking requirements that all nodes can communicate with one another.</br>

# Hyper-V : Create our network

In order for us to create virtual machines all on the same network, I am going to create a virtual switch in Hyper-v </br>
Open Powershell in administrator.

```
# get our network adapter where all virtual machines will run on
# grab the name we want to use
Get-NetAdapter
Get-NetAdapter -Name "*Ethernet*"

Import-Module Hyper-V
$ethernet = Get-NetAdapter -Name "vEthernet (LAN)"
New-VMSwitch -Name "virtual-network" -SwitchType Internal -Notes "internal virtual network interface"
```

# Hyper-V : Create our machines
# We firstly need harddrives for every VM. </br>
# Let's create three:

```
mkdir c:\temp\vms\control-plane\
mkdir c:\temp\vms\worker-node\

New-VHD -Path c:\temp\vms\control-plane\control-plane.vhdx -SizeBytes 40GB
New-VHD -Path c:\temp\vms\worker-node\worker-node.vhdx -SizeBytes 40GB
```

```
New-VM `
-Name "control-plane" `
-Generation 1 `
-MemoryStartupBytes 2796MB `
-SwitchName "LAN" `
-VHDPath "c:\temp\vms\control-plane\control-plane.vhdx" `
-Path "c:\temp\vms\control-plane\"

Set-VMProcessor -VMName "control-plane" -Count 2

New-VM `
-Name "worker-node" `
-Generation 1 `
-MemoryStartupBytes 2796MB `
-SwitchName "LAN" `
-VHDPath "c:\temp\vms\worker-node\worker-node.vhdx" `
-Path "c:\temp\vms\worker-node\"

Set-VMProcessor -VMName "worker-node" -Count 2
```

# Setup a DVD drive that holds the `iso` file for Ubuntu Server

```
Set-VMDvdDrive -VMName "control-plane" -ControllerNumber 1 -Path "C:\temp\ubuntu-24.04.2-live-server-amd64.iso"
Set-VMDvdDrive -VMName "worker-node" -ControllerNumber 1 -Path "C:\temp\ubuntu-24.04.2-live-server-amd64.iso"
```

# Start our VM's

```
Start-VM -Name "control-plane"
Start-VM -Name "worker-node"
```
Now we can open up Hyper-v Manager and see our infrastructure. </br>
In this video we'll connect to each server, and run through the initial ubuntu setup. </br>
Once finished, select the option to reboot and once it starts, you will notice an `unmount` error on CD-Rom. </br>
This is ok, just shut down the server and start it up again. </br>

# Hyper-V : Setup SSH for our machines

Now in this demo, because I need to copy rancher bootstrap commands to each VM, it would be easier to do so
using SSH. So let's connect to each VM in Hyper-V and setup SSH. </br>
This is because `copy+paste` does not work without `Enhanced Session` mode in Ubuntu Server. </br>

Let's temporarily turn on SSH on each server:

```
sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common curl openssh-server net-tools docker-ce docker-ce-cli containerd.io docker.io etcd-server
sudo systemctl enable ssh
sudo ufw allow ssh
sudo systemctl start ssh
```

In new Powershell windows, let's SSH to our VMs

```
ssh control-plane@192.168.134.121
ssh worker-node@192.168.134.53
```

# Setup Docker

It is required that every machine that needs to join our cluster, has docker running on it.</br>
Firstly, Rancher will use docker to run it's agent as well as bootstrap the cluster.</br>

Install docker on each VM:
```
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $(whoami)
sudo service docker start
```

## To install RKE2 via install Tarball

curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh
INSTALL_RKE2_CHANNEL=latest ./install.sh
