# Chaos Engineering

## Install
* minikube start --vm-driver=hyperkit --cpus 4 --memory 6g
* brew install python3
* python3 -m venv ~/.venvs/chaostk
* source  ~/.venvs/chaostk/bin/activate
* pip install -U chaostoolkit
* chaos discover chaostoolkit-kubernetes

## Issues
### Need to specify to chaostoolkit where the K8s cluster is
KUBERNETES_KEY_FILE=/Users/bobbylei/.minikube/profiles/minikube/client.key KUBERNETES_CERT_FILE=/Users/bobbylei/.minikube/profiles/minikube/client.crt KUBERNETES_HOST=https://192.168.64.20:8443 chaos run chaos/terminate-pod.yaml --rollback-strategy=always

Using command 'kubectl config view'
```
...
- cluster:
    certificate-authority: /Users/bobbylei/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Mon, 18 Oct 2021 22:32:28 NZDT
        provider: minikube.sigs.k8s.io
        version: v1.17.1
      name: cluster_info
    server: https://192.168.64.20:8443
  name: minikube
...
```

Gives you the server to Minikube which we can use to configure KUBERNETES_HOST. It also gives the certificate-authority but we don't need it as KUBERNETES_CA_CERT_FILE isn't needed.

KUBERNETES_KEY_FILE and KUBERNETES_CERT_FILE can be found in $HOME/.minikube/profiles/minikube/

Can use either the client.crt and client.key or the apiserver.crt and apiserver.key. Therefore, this command also works:
KUBERNETES_KEY_FILE=/Users/bobbylei/.minikube/profiles/minikube/apiserver.key KUBERNETES_CERT_FILE=/Users/bobbylei/.minikube/profiles/minikube/apiserver.crt KUBERNETES_HOST=https://192.168.64.20:8443 chaos run chaos/terminate-pod.yaml

## Tips
* kubectl label namespace go-demo-8 istio-injection=enabled
  * label every the namespace so Istio will add a proxy container to every pod running in that namespace
  * Envoy is the proxy Istio injects into Pods as side-car containers. If you want to fine-tune your Virtual Service definitions with things such as retryOn codes, refer to the Envoy documentation

## Notes
### Principles of Chaos Engineering
* What we usually want to do is build a hypothesis around the steady-state behavior
* Then, we want to perform some potentially damaging actions on the network, on the applications, on the nodes, or on any other component of the system
* We want to create violent situations that will confirm that our state, the steady-state hypothesis, still holds. In other words, we want to validate that our system is in a specific state, perform some actions, and finish with the same validation to confirm that the state of our system did not change
* We want to run chaos experiments in production. We could do it in a non-production system. But that would be mostly for practice and for gaining confidence in chaos experiments
* We want to automate our experiments to run continuously. It would be pointless to run an experiment only once. We could never be sure what the right moment is. When is the system in conditions under which it would produce some negative effect?
* That can be every hour, every day, every week, every few hours, or every time some event is happening in our cluster
* Maybe we want to run experiments every time we deploy a new release or every time we upgrade the cluster. In other words, experiments are either scheduled to run periodically, or they are executed as part of continuous delivery pipelines
* Finally, we want to reduce the blast radius. In the beginning, we want to start small and to have a relatively small blast radius of the things that might explode. And then, over time, as we are increasing confidence in our work, we might be expanding that radius. Eventually, we might reach the level when we’re doing experiments across the whole system
* The summary of the principles we discussed is as follows
  * Build a hypothesis around steady-state
  * Simulate real-world events
  * Run experiments in production
  * Automate experiments and run them continuously
  * Minimize blast radius
* The summary of the process we discussed is as follows
  * Define the steady-state hypothesis
  * Confirm the steady-state
  * Produce or simulate 'real world' events
  * Confirm the steady-state
  * Use metrics, dashboards, and alerts to confirm that the system as a whole is behaving correctly

### Fault Tolerance vs High Availability
Fault Tolerance is the pods will be re-created if they are destroyed. It's different from HA.

HA is the app continues to serve requests when a pod or an instance is destroyed. In order to do this, the architecture should run multiple instances as a way to prevent the situation when an app cannot serve request because its in the middle of re-creating the pod. If, for example, we would have three instances of our application and we'd destroy one of them, the other two should be able to continue serving requests while Kubernetes is recreating the failed Pod. In other words, we need to increase the number of replicas of our application.

### How to Scale Pods
We could scale up in quite a few ways. We could just go to the definition of the Deployment and say that there should be two or three or four replicas of that application. But that’s a bad idea. That’s static. That would mean that if we say three replicas, then our app would always have three replicas. What we want is for our application to go up and down. It should increase and decrease the number of instances depending on their memory or CPU utilization. We could even define more complicated criteria based on Prometheus.

### Fix at K8s or App Level
For example - partial network failures can be fixed at the Envoy level, but what about total failures of the network? They should be at the application level...

I will not show you how to fix that situation because the solution should most likely not be applied inside Kubernetes, but on the application level. In that scenario, assuming that we have other processes in place that deal with infrastructure when the network completely fails, it will be recuperated at one moment. We cannot expect Kubernetes and Istio and software around our applications to fix all of the problems. And this is the case where the design of our applications should be able to handle it.

Let’s say that your frontend application is accessible, but that the backend is not. If, for example, your frontend application cannot, under any circumstance, communicate with the backend application, it should probably show a message like “shopping cart is currently not available, but feel free to browse our products” because they go to different backend applications. That’s why we like microservices. The smaller the applications are, the smaller the scope of an issue. Or maybe your frontend application is not accessible, and then you would serve your users some static version of your frontend. There can be many different scenarios, and we won’t go through them.


## Upto
Page 95

Simulating Denial Of Service Attacks
