## Cloud Native Project

I'm looking to build a modern cloud-native system<br>
Overview:<br>
Local development with Kind <br>
CI/CD automation with GitHub Actions <br>
GitOps deployment via ArgoCD (apps) and optionally FluxCD (infra) <br>
Observability with Prometheus, Alertmanager, Grafana, and Jaeger <br>
Service Mesh with Istio <br>
Centralized logging with the ELK stack <br>

<br>
✅ 1. Infrastructure Layer
Cloud provider: AWS / GCP / Azure (or on-prem with kubeadm or k3s)
Cluster provisioning:
EKS / GKE / AKS (Managed Kubernetes)
Or use Terraform for IaC

<br>
🧠 2. Orchestration & Runtime
Kubernetes: Container orchestration
Docker: Used to containerize your applications
Helm: To package, version, and deploy apps as charts

<br>
🔄 3. GitOps & CI/CD
GitHub Actions:
CI: Run tests, build Docker images, push to a registry
CD: Push Helm chart updates to Git repo
<br>
ArgoCD:
Watches Git repo (Helm charts or K8s manifests)
Syncs to Kubernetes cluster automatically (GitOps model)

<br>
🌐 4. Service Mesh
Istio:
Handles traffic routing, retries, timeouts, circuit breaking
Enables mTLS (zero-trust), observability, and A/B testing
Integrates with Prometheus, Grafana, and Jaeger

<br>
📊 5. Observability Stack
Logging:
ELK Stack (Elasticsearch, Logstash, Kibana)
Fluent Bit or Filebeat to ship logs to Elasticsearch
<br>
Monitoring:
Prometheus: Collects metrics from apps and Istio
Alertmanager: Sends alerts (Slack, email, etc.)
Grafana: Visualizes Prometheus metrics
<br>
Tracing:
Jaeger: Distributed tracing (integrates with Istio)

<br>
🔐 6. Security & Config (optional add-ons)
Cert-Manager: For auto TLS with Let's Encrypt
OPA/Gatekeeper: For policy enforcement

<br>
📦 Deployment Flow (simplified):
Developer pushes code → GitHub
GitHub Actions runs tests, builds/pushes Docker image, updates Helm chart
ArgoCD detects chart change → syncs to cluster
Istio routes traffic → app
Logs/metrics/traces → ELK / Prometheus / Jaeger
Grafana dashboards + Alertmanager notifications

#### Project Folder Structure

cloud-native-app/
├── .github/
│   └── workflows/
│       └── deploy.yaml          	 # GitHub Actions workflow
├── charts/
│   └── catota-app/              	 # Helm chart for your app
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           └── virtualservice.yaml 	 # Istio VirtualService
├── manifests/
│   ├── argocd/
│   │   └── app.yaml             	 # ArgoCD Application definition
│   ├── istio/
│   │   └── gateway.yaml         	 # Istio Gateway for external traffic
│   └── observability/
│       ├── prometheus.yaml      	 # Prometheus config (if needed)
│       ├── grafana-dashboards/  	 # JSON dashboard definitions
│       ├── jaeger.yaml
│       └── fluentbit.yaml       	 # (optional) logging agent
├── app/
│   ├── Dockerfile               	 # Dockerfile for your app
│   ├── main.py / index.js / ...	 # Your app code
│   └── requirements.txt / package.json
├── k8s/
│   ├── base/                    	 # Base manifests if not using Helm
│   └── overlays/dev/            	 # Kustomize overlays (optional)
├── scripts/
│   └── kind-setup.sh            	 # Script to create Kind cluster + registry
├── README.md
└── .env                         	 # Optional: environment variables
<br>

#### Create a cluster Kind
I created a custom configuration file (e.g., cluster.yaml) to define specific cluster parameters, such as the number of nodes.
Here's an example for creating a multi-node cluster:
```
// cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

Then create the cluster with:
`kind create cluster --config kind-config.yaml`

### Install FluxCD
`curl -s https://fluxcd.io/install.sh | sudo bash`

### Create the folders to FluxCD and you config files
```
mkdir clusters
cd clusters/
mkdir template
cd template/
mkdir flux-system
cd flux-system/
touch gotk-components.yaml gotk-sync.yaml kustomization.yaml
```

### Edit the file kustomize.yaml
`cd infrastructure-k8s/clusters/template/flux-system` <br>
`nano kustomization.yaml`

```                                                                        
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml

```

### Insert the Token in your system
`export GITHUB_TOKEN=uhp_lx37wYoJiHZ8nAxk4YqN6yoB2yLG91cOz9H`

### Bootstrap the FLuxCD
```
flux bootstrap github \
  --owner=felipedds \
  --repository=cloud-native-1 \
  --branch=main \
  --path=infrastructure-k8s/clusters/template \
  --token-auth
  --personal
```

### Check the pods created after Bootstrap, to verify if the FluxCD was installed
`kubectl get pods -n flux-system`

##### The controllers that should be installed in the cluster
```
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-656f694f99-qmp65           1/1     Running   0          25m
kustomize-controller-f6756756f-dvxfg       1/1     Running   0          25m
notification-controller-848f84bccd-952fp   1/1     Running   0          25m
source-controller-59b9b6567b-zjbr7         1/1     Running   0          25m
```

### Check the secrets related with FluxCD
`kubectl get secrets -n flux-system`

### Decode the secret (if necessary)
`kubectl get secret flux-system -n flux-system -o jsonpath='{.data.password}' | base64 -d`

### Check the clusterrolebindings
`kubectl get clusterrolebindings | grep flux`

### Go the kustomize directory.
`cd /home/ubuntu/Downloads/devops/cloud-native-1/infrastructure-k8s/clusters/template`

### Create the podinfo-repo.yaml file.
`nano podinfo-repo.yaml`

### Add the following content:
```
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
 name: podinfo
 namespace: flux-system
spec:
 interval: 30s
 ref:
 branch: main
 url: https://github.com/Catotachique/devops/tree/main/cloud-native-1
```

### Create the info-kustomization.yaml file.
`nano info-kustomization.yaml`

### Add the following content:
```
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: cloud-native-1
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./kustomize             
  prune: true
  sourceRef:
    kind: GitRepository
    name: cloud-native-1
  targetNamespace: default
```


