```
asdf plugin add minikube https://github.com/alvarobp/asdf-minikube.git
asdf plugin add garden https://github.com/pepov/asdf-garden.git

asdf install

minikube start --driver=docker --ports=127.0.0.1:80:80,127.0.0.1:443:443

# you will have to add this to your hosts file (you can add `127.0.0.1 kcp.playground.garden` to `/etc/hosts` manually if you don't want to use hostctl)
sudo hostctl add domains kcp-playground kcp.playground.garden

# deploy kcp and create a kubeconfig to be used inside the cluster
garden deploy kcp-account

# we can download the kcp kubeconfig to be used outside of the cluster
make kcp-local-config
export KUBECONFIG=$PWD/.kcp/admin-stable.kubeconfig

# we can for example check server version
kubectl version

# this supposed to fail miserably
kubectl get pod

# see what resources are actually available in a kcp API server
kubectl api-resources

# bonus: you can check kcp workspaces as well using the kcp kubectl plugin
asdf plugin add kcp https://github.com/pepov/asdf-kcp.git
asdf install kcp latest
asdf global kcp latest

kubectl ws tree

# go back to minikube
unset KUBECONFIG

# let's see if we can make cert-manager work against kcp this time
garden deploy kcp-cert-manager

# switch back to kcp and try to create some certificates inside kcp using cert-manager running outside (in minikube)
export KUBECONFIG=$PWD/.kcp/admin-stable.kubeconfig
kubectl apply -f manifests/demo.yaml
```
