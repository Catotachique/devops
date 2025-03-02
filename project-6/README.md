# Studying to CKA
<li>
Prerequisites:
CPUs - 2
Memory - 2.5MB
Disk: 25 GB
</li>

Creating 1 Control Plane and 2 Worker Nodes in 3 VM's.

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