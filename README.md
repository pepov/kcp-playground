### Purpose of this project

This is a demonstration on how one can deploy [kcp](kcp.io) and use it with stock Kubernetes tools like kubectl and an existing operator ([cert-manager](https://cert-manager.io) in this case) to do something useful.

I used [asdf](https://asdf-vm.com/) to install the required tools, but you can install them on your own with your favourite method. These are:
- kubectl
- minikube
- [garden](https://garden.io/)
- kcp kubectl plugin (optional)

```
asdf plugin add minikube https://github.com/alvarobp/asdf-minikube.git
asdf plugin add garden https://github.com/pepov/asdf-garden.git
asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
asdf install

minikube start --driver=docker --ports=127.0.0.1:80:80,127.0.0.1:443:443

# prepare to serve kcp.playground.garden locally
echo "127.0.0.1 kcp.playground.garden" | sudo tee -a /etc/hosts
```

I used [garden](https://garden.io/) because it's lightweight and works with simple Kubernetes manifests, but powerful enough to handle dependencies and allow basic templating. I recommend to play around with it as well.

The following command will deploy the kcp workload and will set up an admin kubeconfig that we can use to demonstrate connecting to a demo workspace in kcp.
```
garden deploy kcp-account
```

> Note: there is a cert-manager already running at this stage, but don't get confused about that, it's only providing certificates in our kubernetes cluster, not the one I use to demonstrate kcp's capabilities.

Now we can download the kubeconfig and start to use our new workspace
```
make kcp-local-config
export KUBECONFIG=$PWD/.kcp/admin-stable.kubeconfig

# we can for example check server version
kubectl version

# this supposed to fail miserably, since we are talking to a kcp workspace which doesn't have pods
kubectl get pod

# see what resources are actually available in a kcp API server
kubectl api-resources
```

As a bonus we can install kcp's kubectl plugin and check the actual kcp workspaces as well.
```
asdf plugin add kcp https://github.com/pepov/asdf-kcp.git
asdf install kcp latest
asdf local kcp latest

kubectl ws tree
```

Now let's go back to our hosting kubernetes cluster and continue deploying the demo app. This command should install a bare-bone cert-manager with only those controllers enabled that doesn't need to operate on any of the builtin Kubernetes workload types, like ingresses.
```
unset KUBECONFIG

# let's see if we can make cert-manager work against kcp this time
garden deploy kcp-cert-manager
```

You should see the following pods running:
```
NAME                                       READY   STATUS      RESTARTS   AGE
cert-manager-8598b54d89-7qcgb              1/1     Running     0          5m1s
cert-manager-cainjector-66885bc449-p58lt   1/1     Running     0          5m1s
cert-manager-webhook-884c4477c-xxwcv       1/1     Running     0          5m1s
ingress-nginx-controller-cr6vw             1/1     Running     0          4m34s
kcp-0                                      1/1     Running     0          3m54s
kcp-account-f26ng                          0/1     Completed   0          3m27s
kcp-cert-manager-0                         1/1     Running     0          107s
kcp-cert-manager-crds-vt48x                0/1     Completed   0          109s
```

Our guy is `kcp-cert-manager-0` - running against kcp using the same secret we used to connect kcp locally - and `kcp-cert-manager-crds-vt48x` which is a job to install the cert-manager CRDs on the kcp server.

Switch back to kcp and try to create a self-signed certificate in it
```
export KUBECONFIG=$PWD/.kcp/admin-stable.kubeconfig
kubectl apply -f manifests/demo.yaml
```

We should see the certificate has been created. (I use https://github.com/elsesiy/kubectl-view-secret for this)
```
kubectl view-secret self-signed-server tls.crt
-----BEGIN CERTIFICATE-----
MIICxjCCAa6gAwIBAgIRANkeEVRVbLSf1KfzopbR32UwDQYJKoZIhvcNAQELBQAw
ADAeFw0yMzA2MTUxNDMzMzFaFw0yMzA5MTMxNDMzMzFaMAAwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDx2e8LKDxdviPHto5Ny+GUh7cCcwnCieYz/PSu
t2ShF4IpgXQv6clOuem+UtvTXEGgUjkiAlkQtyQMfaB3gnCyBF2yACnLAppe8SMR
yH8i4GenfTiJTmJdp+j67GCGQQt0qu3V86ve9fK1kUcMZvJGApG1SjwImdJtCxJY
4M3irjWeWMMqP9k11u/W902EwgeN+PzHd7+YyRSJgD7DSQkdEhw9RX6nELSgIo2v
FUSkw0t9Njp3ihsraSlrpI2Q03cbcRprysWpzy5ld9j5Yve1qt2x0dXkvjBEdxgV
8OsBhNjJr5pQKS2SPKpxZGEzW/TQEyhxmx0tUGussFufNKEFAgMBAAGjOzA5MA4G
A1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAAMBkGA1UdEQEB/wQPMA2CC2ktYW0t
c2VydmVyMA0GCSqGSIb3DQEBCwUAA4IBAQCu5bJdpuj1ocBRPwMuiaGVyW/bwdeK
jhixWPhOJtdb24QXF2v5UR18T3qXzq1b4/lYtdw9T5LrxLFOtZa2HEHaRc6oiqRd
iq4kNGC1TTYNFbZTjh6r052d8BIcEbgg6DWc0SlNPWmX2BqOlo+vtY57t/L0NCf7
Lu2k4Z7xt5KAwNLt9cWxB1pRF3KQbV0Si1jwSO57WlgV1v5DReCAm6lIuwtOd6jY
QlMPm/BjxyUprKA72BnpSn/XszwL/nagcLHG1UfLHhiy2nmpga987GWIqV0OgRkY
YYDzfBLMRwnd1HrC6twApSwJ3gqWboPup8ZeoSi3ZlR6zHPEOY1ViHvK
-----END CERTIFICATE-----
```
