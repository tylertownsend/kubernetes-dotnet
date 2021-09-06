A simple project to demonstrate running a .NET application on kubernetes. If ollows most of this [tutorial](https://faun.pub/how-to-deploy-a-net-5-api-in-a-kubernetes-cluster-53212af6a0e2)

# Setup
## Distro
This is currently done with [Ubuntu 21.04](https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#2104-).

## .NET 5
### Add Microsoft Package Signing Key
```bash
wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
```
### Install .NET 5 SDK
```bash
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-5.0
```

### Check installation
```bash
dotnet --info
```
Should display something like
```
.NET SDK (reflecting any global.json):
 Version:   5.0.400
 Commit:    d61950f9bf

Runtime Environment:
 OS Name:     ubuntu
 OS Version:  20.04
 OS Platform: Linux
 RID:         ubuntu.20.04-x64
 Base Path:   /usr/share/dotnet/sdk/5.0.400/

Host (useful for support):
  Version: 5.0.9
  Commit:  208e377a53

.NET SDKs installed:
  5.0.400 [/usr/share/dotnet/sdk]

.NET runtimes installed:
  Microsoft.AspNetCore.App 5.0.9 [/usr/share/dotnet/shared/Microsoft.AspNetCore.App]
  Microsoft.NETCore.App 5.0.9 [/usr/share/dotnet/shared/Microsoft.NETCore.App]

To install additional .NET runtimes or SDKs:
  https://aka.ms/dotnet-download
```

Note the version and runtime installed.

## Docker
Step found [here](https://docs.docker.com/engine/install/ubuntu/)
### Uninstall old versions
Older versions of Docker were called docker, docker.io, or docker-engine. If these are installed, uninstall them:
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

### Install using the repository
Before you install Docker Engine set up the Docker repository. Afterward, install and manage Docker from the repository.

### Set up the repository
#### Update Index
Update the apt package index and install packages to allow apt to use a repository over HTTPS:
```bash
sudo apt-get update
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
```
Add Docker’s official GPG key:

#### Get official GPG key
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-ke
```

#### Setup Stable version
```bash
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## Install Docker Engine
### Install Latest Version
Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version:

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

### Check installation

```bash
sudo docker run hello-world
```
### Create Docker group and add user
```bash
sudo groupadd docker
```

Add your user to the docker group.

```
sudo usermod -aG docker $USER
```

You would need to loog out and log back in so that your group membership is re-evaluated or type the following command:

```
su $USER
```

## Install Kubernetes
More instructions [here](https://ubuntu.com/kubernetes/install). NOTE! Don't click on the green button at the top. It's to rope you into signing up for support.

### Install MicroK8s on Linux
```
sudo snap install microk8s --classic
```

### Add your user to the microk8s admin group
MicroK8s creates a group to enable seamless usage of commands which require admin privilege. Use the following commands to join the group:

```
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```

You will also need to re-enter the session for the group update to take place:
```
su - $USER
```

### Check the status while Kubernetes starts
```
microk8s status --wait-ready
```

### Turn on the services you want
```
microk8s enable dashboard dns ingress`
```

### Start using Kubernetes
microk8s kubectl get all --all-namespaces

#### Creating a shortcut for kubetcl
If you mainly use MicroK8s you can make our kubectl the default one on your command-line with alias mkctl=”microk8s kubectl”. Since it is a standard upstream kubectl, you can also drive other Kubernetes clusters with it by pointing to the respective kubeconfig file via the “--kubeconfig” argument.

### Access the Kubernetes dashboard
```
microk8s dashboard-proxy
```

## Install Kubcetl
Instructions found [here.](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
### Package Index
Update the apt package index and install packages needed to use the Kubernetes apt repository:

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```
### Signing Key
Download the Google Cloud public signing key:
```
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

### Repo
Add the Kubernetes apt repository:

```
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update apt package index with the new repository and install kubectl:

```
sudo apt-get update
sudo apt-get install -y kubectl
```

# Running kubernetes service

## Start the Service
```bash
microk8s start
```
Check the status
```bash
microk8s status --wait-ready
```

## Create the deployment
```bash
microk8s kubectl create -f deployment.yaml
```

check status
```
/Desktop/kubernetes-dotnet$ microk8s kubectl get deployment
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
training-deployment   0/3     3            0           22s
```

## Create the Service

```
microk8s kubectl create -f service.yaml
```

```
microk8s kubectl get service -o wide
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE     SELECTOR
kubernetes         ClusterIP      10.152.183.1     <none>        443/TCP          3d12h   <none>
training-service   LoadBalancer   10.152.183.137   <pending>     8080:31526/TCP   61s     app=training
```

As you can see, the service will expose port 8080 and forward the request to the pods whose selector contains the label app=training.

### Horizontal Scaling
```
microk8s kubectl scale --replicas=6 deployment/training-deployment
```

```
microk8s kubectl get pod
```