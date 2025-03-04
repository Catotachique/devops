# Studying to CKA
<li>
Prerequisites:
CPUs - 2
Memory - 2.5MB
Disk: 25 GB
</li>

Creating 1 Control Plane and 2 Worker Nodes in 3 VM's.

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

We firstly need harddrives for every VM. </br>
Let's create three:

```
mkdir c:\temp\vms\linux-0\
mkdir c:\temp\vms\linux-1\

New-VHD -Path c:\temp\vms\linux-0\linux-0.vhdx -SizeBytes 25GB
New-VHD -Path c:\temp\vms\linux-1\linux-1.vhdx -SizeBytes 25GB
```

```
New-VM `
-Name "linux-0" `
-Generation 1 `
-MemoryStartupBytes 2596MB `
-SwitchName "virtual-network" `
-VHDPath "c:\temp\vms\linux-0\linux-0.vhdx" `
-Path "c:\temp\vms\linux-0\"

Set-VMProcessor -VMName "linux-0" -Count 2

New-VM `
-Name "linux-1" `
-Generation 1 `
-MemoryStartupBytes 2596MB `
-SwitchName "virtual-network" `
-VHDPath "c:\temp\vms\linux-1\linux-1.vhdx" `
-Path "c:\temp\vms\linux-1\"

Set-VMProcessor -VMName "linux-1" -Count 2
```

Setup a DVD drive that holds the `iso` file for Ubuntu Server

```
Set-VMDvdDrive -VMName "linux-0" -ControllerNumber 1 -Path "C:\temp\ubuntu-24.04.2-live-server-amd64.iso"
Set-VMDvdDrive -VMName "linux-1" -ControllerNumber 1 -Path "C:\temp\ubuntu-24.04.2-live-server-amd64.iso"
```

Start our VM's

```
Start-VM -Name "linux-0"
Start-VM -Name "linux-1"
```

Now we can open up Hyper-v Manager and see our infrastructure. </br>
In this video we'll connect to each server, and run through the initial ubuntu setup. </br>
Once finished, select the option to reboot and once it starts, you will notice an `unmount` error on CD-Rom. </br>
This is ok, just shut down the server and start it up again. </br>

## Control Plane
`sudo apt-get update`
`sudo apt-get install -y apt-transport-https ca-certificates curl`
`curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`
`echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
`sudo apt-get update`

`sudo swapoff -a`
`sudo nano /etc/fstab`

Change it to:
`#/swapfile none swap sw 0 0`
`free -h`

`sudo apt install -y docker.io`
`sudo snap install kubeadm --classic`
`sudo snap install kubelet --classic`
`sudo snap install kubectl --classic`

`sudo kubeadm reset -f`
`sudo kubeadm init --ignore-preflight-errors=NumCPU`
`sudo kubeadm init --ignore-preflight-errors=all`

## Worker Node
`sudo apt-get update`
`sudo apt-get install -y apt-transport-https ca-certificates curl`
`curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`
`echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
`sudo apt-get update`

`sudo swapoff -a`
`sudo nano /etc/fstab`

Change it to:
`#/swapfile none swap sw 0 0`
`free -h`

`sudo apt install -y docker.io`
`sudo apt install -y conntrack`
`sudo snap install kubeadm --classic`
`sudo snap install kubelet --classic`
`sudo snap install kubectl --classic`

`sudo systemctl enable --now docker.service`
`sudo systemctl enable snap.kubelet.daemon.service`
`sudo systemctl status snap.kubelet.daemon.service`
`sudo systemctl restart snap.kubelet.daemon.service`

#### To stop Kubelet
`sudo systemctl stop snap.kubelet.daemon.service`

#### You can always retrieve the join command by running 
`sudo kubeadm token create --print-join-command`

If port 10250 is still in use (as previously reported), you can stop any process that might be occupying it using the following commands:
`sudo lsof -i :10250`   # Identify processes using port 10250
`sudo kill -9 <PID>`    # Stop the process occupying port 10250 (replace <PID> with the process ID)