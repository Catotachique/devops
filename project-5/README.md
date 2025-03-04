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

# Hyper-V : Setup SSH for our machines

Now in this demo, because I need to copy rancher bootstrap commands to each VM, it would be easier to do so
using SSH. So let's connect to each VM in Hyper-V and setup SSH. </br>
This is because `copy+paste` does not work without `Enhanced Session` mode in Ubuntu Server. </br>

Let's temporarily turn on SSH on each server:

```
sudo apt update
sudo apt install -y nano net-tools openssh-server
sudo systemctl enable ssh
sudo ufw allow ssh
sudo systemctl start ssh
```

Record the IP address of each VM so we can SSH to it:

```
sudo ifconfig
# record eth0
linux-0 IP=192.168.0.16
linux-1 IP=192.168.0.17
linux-2 IP=192.168.0.18
```

In new Powershell windows, let's SSH to our VMs

```
ssh linux-0@192.168.0.16
ssh linux-1@192.168.0.17
ssh linux-2@192.168.0.18
```

# Setup Docker

It is required that every machine that needs to join our cluster, has docker running on it. </br>
Firstly, rancher will use docker to run it's agent as well as bootstrap the cluster.</br>

Install docker on each VM:
```
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $(whoami)
sudo service docker start
```

# Running Rancher in Docker

So Rancher can be [deployed](https://rancher.com/docs/rancher/v2.5/en/quick-start-guide/deployment/) almost anywhere. </br>
We can run it in Kubernetes on-prem or the cloud.  </br>

Now because we want Rancher to manage kubernetes clusters, we dont want it running in the clusters we are managing. </br>
So I would like to keep my Rancher server outside and separate from my Kubernetes clusters.</br>

So let's setup a single server with [docker](https://rancher.com/docs/rancher/v2.5/en/quick-start-guide/deployment/quickstart-manual-setup/)

## Persist data

We will want to persist ranchers data across reboots. </br>
Rancher stores its data under `/var/lib/rancher` </br> 

In this repo, let's create a space to persist data:

```
cd kubernetes/rancher
mkdir volume

```

## Run Rancher

```
docker run -d --name rancher-server  -v ${PWD}/volume:/var/lib/rancher --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher
```

## Unlock Rancher

Once its up and running we can extract the Rancher initial boostrap password from the logs 

```
docker logs rancher-server > rancher.log
```

## Get Rancher IP

It's important that our servers can reach the Rancher server. </br>
As all the VMs and my machine are on the same network, we can use my machine IP as the server IP so the VM's can reach it. </br>
let's grab the IP:

```
ipconfig
```

We can now access Rancher on [localhost](https://localhost)

## Deploy Sample Workloads

To deploy some sample basic workloads, let's get the `kubeconfig` for our cluster </br>

Set kubeconfig:

```
$ENV:KUBECONFIG="<path-to-kubeconfig>"
```

Deploy 2 pods, and a service:

```
kubectl create ns marcel
kubectl -n marcel apply -f .\kubernetes\configmaps\configmap.yaml
kubectl -n marcel apply -f .\kubernetes\secrets\secret.yaml
kubectl -n marcel apply -f .\kubernetes\deployments\deployment.yaml
kubectl -n marcel apply -f .\kubernetes\services\service.yaml
```

One caveat is because we are not a cloud provider, Kubernetes does not support our service `type=LoadBalancer`. </br>
For that, we need something like `metallb`. </br>
However - we can `port-forward`

```
kubectl -n marcel get svc 
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
example-service   LoadBalancer   10.43.235.240   <pending>     80:31310/TCP   13s

kubectl -n marcel port-forward svc/example-service 81:80
```

We can access our example-app on port 81