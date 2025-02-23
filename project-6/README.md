# Studying to CKA
<li>
Prerequisites:
CPUs - 2
Memory - 2.5MB
Disk: 25 GB
</li>

## Control Plane
`sudo apt-get update`
`sudo apt-get install -y apt-transport-https ca-certificates curl`
`curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`
`echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
`sudo apt-get update`

`sudo apt-get install -y kubeadm`
`sudo apt-get install -y kubelet`
`sudo apt-get install -y kubectl`

`sudo kubeadm reset -f`
`sudo kubeadm init --ignore-preflight-errors=NumCPU`

## Worker Node
`sudo apt-get update`
`sudo apt-get install -y apt-transport-https ca-certificates curl`
`curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -`
`echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list`
`sudo apt-get update`

`sudo apt-get install -y kubeadm`
`sudo apt-get install -y kubelet`
`sudo apt-get install -y kubectl`