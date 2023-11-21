# KUBERNETES

## MINIKUBE

### Installation
``` bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

### Version
``` bash
minikube version
```

### Start cluster
``` bash
minikube start --force
```

Secara otomatis akan menginstall Kubectl, selain itu cara instal Kubectl dapat dilihat di bagian KUBECTL Installation.

### Minikube Dashboard
```bash 
minikube dashboard
```

Hasilnya :

``` bash
* Enabling dashboard ...
  - Using image docker.io/kubernetesui/dashboard:v2.7.0
  - Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
* Some dashboard features require the metrics-server addon. To enable all features please run:

        minikube addons enable metrics-server


* Verifying dashboard health ...
* Launching proxy ...
* Verifying proxy health ...
http://127.0.0.1:33695/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/

#Selanjutnya akan terbuka browser Tab untuk Minikube
```


## KUBECTL

### Installation
``` bash 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Version
``` bash 
kubectl version --client
```

### Kubernetes Cluster
``` bash
kubectl cluster-info
```

Hasilnya :

``` bash 
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Cek Node pada Cluster
``` bash 
kubectl get node
```

Hasilnya : 
``` bash 
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   3m46s   v1.28.3
```


## POD

### Manifest pod.yaml
``` bash
apiVersion: v1 # Versi API berisi resource paling umum seperti Pod dan Node.
kind: Pod # Resource yang didefinisikan yaitu Pod. 
metadata: # Bagian ini kita mendefinisikan nama Pod sebagai mypod dan label dengan nilai app: webserver.
  name: mypod
  labels:
    app: webserver
spec: # Bagian ini menspesifikasikan resource. Kita mendefinisikan spesifikasi container di dalam Pod.
  containers:
  - name: mycontainer
    image: nginx:latest
    resources:
      requests:
        memory: "128Mi" # 128Mi = 128 mebibytes
        cpu: "500m"     # 500m = 500 milliCPUs (1/2 CPU)
      limits:
        memory: "128Mi"
        cpu: "500m"
    ports:
      - containerPort: 80
```

### Membuat Pod
``` bash
kubectl apply -f pod.yaml
```

### Status Pod
``` bash
kubectl get pods
```

### Detail Pod
``` bash
kubectl describe pod
```

### Request dari container dalam Pod
``` bash
kubectl exec mypod curl http://<Pod-IP>:80
```


## SERVICE

### Manifest service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: webserver 
  name: webserver
spec:
  ports:
  - port: 80
  selector:
    app: webserver #selector app:webserver menarget Pod yang kita buat sebelumnya
  type: NodePort
```


### Deploy Service
``` bash
kubectl apply -f service.yaml
```

### Cek Service
``` bash
kubectl get service
```

### Detail Service
``` bash
kubectl describe service webserver
```

Hasil
```bash
Name:                     webserver
Namespace:                default
Labels:                   app=webserver
Annotations:              <none>
Selector:                 app=webserver
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.111.83.243
IPs:                      10.111.83.243
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30869/TCP
Endpoints:                10.244.0.5:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### Node IP Address
``` bash
kubectl describe node | grep -i address -A 1
```

atau

``` bash
minikube ip
```

### Akses Apps
``` bash
curl http://192.168.49.2:30869
```


## NAMESPACE

``` bash
kubectl get namespace
```

Hasil :
``` bash
NAME                   STATUS   AGE
default                Active   2d12h
kube-node-lease        Active   2d12h
kube-public            Active   2d12h
kube-system            Active   2d12h
```

Berikut penjelasan singkat dari masing-masing Namespace tersebut.

default: lokasi semua object yang Anda buat (bila tanpa mencantumkan Namespace lain).
kube-node-lease: lokasi Node Lease object. Node lease memungkinkan kubelet untuk mengirim sinyal sehingga Control Plane dapat mendeteksi kegagalan Node.
kube-public: lokasi object yang bersifat public.
kube-system: lokasi object yang dibuat oleh sistem Kubernetes.


### Manifest namespace.yaml

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: webserver-ns
  labels:
    app: webserver
```

Sebelum lanjut, hapus Pod, dan Service yang pernah dibuat terlebih dahulu.

``` bash
kubectl delete pod mypod && kubectl delete service webserver
```

### Deploy Namespace

``` bash
kubectl apply -f namespace.yaml
```


### Cek Namespace

``` bash
kubectl get namespace
```


### Buat Pod dan Service

``` bash
kubectl apply -f pod.yaml -n webserver-ns && kubectl apply -f service.yaml -n webserver-ns
```

### Cek Pod

``` bash
kubectl describe pod mypod -n webserver-ns
```

### Cek Service

``` bash
kubectl describe service webserver -n webserver-ns
```

### List Obejct

Untuk melihat daftar object yang bisa disimpan pada namespace, jalankan perintah ini.

``` bash
kubectl api-resources --namespaced=true 
```

Untuk melihat daftar object yang tidak bisa disimpan pada namespace, jalankan perintah ini.

``` bash
kubectl api-resources --namespaced=false 
```


## DEPLOYMENT

### Namespace deployment-ns.yaml

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: deployments
  labels:
    app: counter
```

### Deploy

``` bash
kubectl apply -f deployment-ns.yaml
```

### Service data-tier.yaml

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: data-tier
  labels:
    app: microservices
spec:
  ports:
  - port: 6379
    protocol: TCP 
    name: redis
  selector:
    tier: data 
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-tier
  labels:
    app: microservices
    tier: data
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: data
  template:
    metadata:
      labels:
        app: microservices
        tier: data
    spec:
      containers:
      - name: redis
        image: redis:latest
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 6379
```

### Service app-tier.yaml

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: app-tier
  labels:
    app: microservices
spec:
  ports:
  - port: 8080
  selector:
    tier: app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-tier
  labels:
    app: microservices
    tier: app
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: app
  template:
    metadata:
      labels:
        app: microservices
        tier: app
    spec:
      containers:
      - name: server
        image: lrakai/microservices:server-v1
        ports:
          - containerPort: 8080
        env:
          - name: REDIS_URL
            # Environment variable service discovery
            # Naming pattern:
            #   IP address: <all_caps_service_name>_SERVICE_HOST
            #   Port: <all_caps_service_name>_SERVICE_PORT
            #   Named Port: <all_caps_service_name>_SERVICE_PORT_<all_caps_port_name>
            value: redis://$(DATA_TIER_SERVICE_HOST):$(DATA_TIER_SERVICE_PORT_REDIS)
```

### Deployment support-tier.yaml

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: support-tier
  labels:
    app: microservices
    tier: support
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: support
  template:
    metadata:
      labels:
        app: microservices
        tier: support
    spec:
        containers:
        - name: counter
          image: lrakai/microservices:counter-v1
          env:
            - name: API_URL
              # DNS for service discovery
              # Naming pattern:
              #   IP address: <service_name>.<service_namespace>
              #   Port: needs to be extracted from SRV DNS record
              value: http://app-tier.deployments:8080
 
 
        - name: poller
          image: lrakai/microservices:poller-v1
          env:
            - name: API_URL
              value: http://app-tier:$(APP_TIER_SERVICE_PORT)
```


### Deploy

``` bash
kubectl apply -f data-tier.yaml -f app-tier.yaml -f support-tier.yaml -n deployments

```

Hasil :
``` bash
service/data-tier created

deployment.apps/data-tier created

service/app-tier created

deployment.apps/app-tier created

deployment.apps/support-tier created
```

### Status Deployment

``` bash
kubectl get deployment -n deployments
```

### Cek Pod

``` bash
kubectl get pod -n deployments
```

Hasil : 
``` bash
NAME                            READY   STATUS    RESTARTS      AGE
app-tier-7ff89c6665-tgk48       1/1     Running   2 (97s ago)   112s
data-tier-58684c488b-t2rgg      1/1     Running   0             112s
support-tier-645555cdfb-mww47   2/2     Running   0             112s

```

### Cek Log

``` bash
kubectl logs support-tier-645555cdfb-mww47 poller -f -n deployments
```

### Replica Pod app-tier.yaml

``` yaml
spec:
  replicas: 5
  selector:
    matchLabels:
      tier: app
```

### Deploy kembali

``` bash
kubectl apply -f app-tier.yaml -n deployments
```


### Cek Pod

``` bash
kubectl get pod -n deployments
```

Hasil
```
NAME                            READY   STATUS    RESTARTS        AGE
app-tier-7ff89c6665-7xkws       1/1     Running   0               51s
app-tier-7ff89c6665-rwjk7       1/1     Running   0               51s
app-tier-7ff89c6665-tgk48       1/1     Running   2 (5m39s ago)   5m54s
app-tier-7ff89c6665-x7qc5       1/1     Running   0               51s
app-tier-7ff89c6665-xz7qp       1/1     Running   0               51s
data-tier-58684c488b-t2rgg      1/1     Running   0               5m54s
support-tier-645555cdfb-mww47   2/2     Running   0               5m54s
```

### Cara Hapus Pod

``` bash
kubectl delete pod app-tier-7ff89c6665-rwjk7 -n deployments
```

### Detail Service app-tier

``` bash
kubectl describe service app-tier -n deployments
```


## HorizontalPodAutoscaler

HorizontalPodAutoscaler merupakan jenis autoscaling, disingkat sebagai HPA. Object ini berfungsi untuk memperbarui workload resource (seperti Deployment atau StatefulSet) dengan tujuan scaling secara otomatis agar jumlah Pod sesuai dengan permintaan yang ditentukan.

### ServiceAccount metric-server.yaml

``` yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        image: k8s.gcr.io/metrics-server/metrics-server:v0.6.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
```

### Deploy

``` bash
kubectl apply -f metric-server.yaml 
```

### Cek Pod

``` bash
kubectl get pods -n kube-system
```

Melihat daftar penggunaan CPU dan memory untuk setiap Pod pada suatu Namespace.

``` bash
kubectl top pods -n deployments
```

### CPU Request app-tier.yaml

``` yaml
    spec:
      containers:
      - name: server
        image: lrakai/microservices:server-v1
        ports:
          - containerPort: 8080
        resources:
          requests:
            cpu: 20m
        env:
```

### Deploy

Setiap Pod akan meminta sumber daya kepada Kubernetes sebesar 20 milliCPU atau 0,02 CPU.

``` bash
kubectl apply -f app-tier.yaml -n deployments
```

### HorizontalPodAutoscaler hpa.yaml

``` bash
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: app-tier
  labels:
    app: microservices
    tier: app
spec:
  maxReplicas: 5
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-tier
  targetCPUUtilizationPercentage: 70
```

### Deploy

``` bash
kubectl apply -f hpa.yaml -n deployments
```

### Cek Deployment

``` bash
kubectl get deployment -n deployments --watch
```

Tekan CTRL+C untuk kembali ke prompt


### Cek HPA

``` bash
kubectl describe hpa -n deployments
```

atau

``` bash
kubectl get hpa -n deployments
```


### minReplicas hpa.yaml

``` yaml
spec:
  maxReplicas: 5
  minReplicas: 2
```

### Deploy

``` bash
kubectl apply -f hpa.yaml -n deployments
```

### Cek Pod

``` bash
kubectl get deployment -n deployments
```


## Volume dan Persistent Volume

### Namespace stateful-ns.yaml

``` yaml 
apiVersion: v1
kind: Namespace
metadata:
  name: stateful-ns
  labels:
    app: mysql
```

### Deploy

``` bash
kubectl apply -f stateful-ns.yaml
```

### Service mysql-svc-deploy.yaml

``` bash
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
  clusterIP: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```


### PersistentVolume mysql-pv-pvc.yaml

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

### Deploy

``` bash
kubectl apply -f mysql-pv-pvc.yaml -n stateful-ns
```

``` bash
kubectl apply -f mysql-svc-deploy.yaml -n stateful-ns
```


### Cek Deployment mysql

``` bash
kubectl describe deployment mysql -n stateful-ns
```

### Detail Persistent Volume 

``` bash
kubectl describe pvc mysql-pv-claim -n stateful-ns
```

``` bash
kubectl describe pv mysql-pv-volume -n stateful-ns
```


### Akses MySQL

``` bash
kubectl run -it --rm --image=mysql:5.6 --restart=Never --namespace=stateful-ns mysql-client -- mysql -h mysql -ppassword
```

``` mysql
CREATE DATABASE my_database;
```

``` mysql
USE my_database;
```

``` mysql
CREATE TABLE pet (name VARCHAR(20), owner VARCHAR(20), species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);
```

``` mysql
INSERT INTO pet VALUES ('Oyen', 'Budi', 'Kucing', 'J', '1945-08-17', NULL);
```

``` msyql
exit
```


Saat exit, pod mysql-client dihapus, coba akses kembali, dan cek Database. Terlihat Persistent Volume mampu mempertahankan data meski Pod telah dihapus. Inimembuktikan bahwa  membuat stateful application dengan Kubernetes telah berhasil.


## ConfigMap dan Secret

### Cek Deployment

``` bash
kubectl get all -n deployments
```

### ConfigMap data-tier-configmap.yaml

``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  config: |
    tcp-keepalive 240
    maxmemory 1mb
```

### Command & Volume data-tier.yaml

``` yaml
	spec:
      containers:
      - name: redis
        image: redis:latest
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 6379
        command:
          - redis-server
          - /etc/redis/redis.conf
        volumeMounts:
          - mountPath: /etc/redis
            name: config
      volumes:
        - name: config
          configMap:
            name: redis-config
            items:
            - key: config
              path: redis.conf
```

Path tergantung pada mount point untuk Volume. Lihat di bagian volumeMounts, kita tentukan lokasi /etc/redis sebagai mount path pada Volume bernama config. Path lengkap untuk config adalah /etc/redis/redis.conf.

Tambahkan command sehingga Redis dapat memuat berkas konfigurasi saat dimulai, dengan perintah redis-server /etc/redis/redis.conf. 


### Deploy

``` bash
kubectl apply -f data-tier-configmap.yaml -f data-tier.yaml -n deployments
```

Periksa Pod dan catat nama Pod untuk data tier

``` bash
kubectl get pod -n deployments
```

Hasil : 
``` bash
NAME                            READY   STATUS    RESTARTS   AGE
app-tier-6fdbd76fb-jssmd        1/1     Running   0          38m
app-tier-6fdbd76fb-k7bvq        1/1     Running   0          38m
data-tier-7f8446b9f-bbbjt       1/1     Running   0          40s
support-tier-645555cdfb-mww47   2/2     Running   0          57m
```


### Akses data tier container

``` bash
root@dicoding:~/Project/Microservices/Kubernetes# kubectl exec -it -n deployments data-tier-7f8446b9f-bbbjt -- /bin/bash
```

``` bash
root@data-tier-7f8446b9f-bbbjt:/data# cat /etc/redis/redis.conf
tcp-keepalive 240
maxmemory 1mb
root@data-tier-7f8446b9f-bbbjt:/data# exit
```


### Secret app-tier-secret.yaml

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-tier-secret
stringData:
  username: dicoding
data:
  api-key: MWYyZDFlMmU2N2Rm
  password: YWRtaW4=
```


### Deloy

``` bash
kubectl apply -f app-tier-secret.yaml -n deployments
```

### Detail Secret

``` bash
kubectl describe secret app-tier-secret -n deployments
```


### Penyesuaian app-tier

``` yaml
    spec:
      containers:
      - name: server
        image: lrakai/microservices:server-v1
        ports:
          - containerPort: 8080
        env:
          - name: REDIS_URL
            # Environment variable service discovery
            # Naming pattern:
            #   IP address: <all_caps_service_name>_SERVICE_HOST
            #   Port: <all_caps_service_name>_SERVICE_PORT
            #   Named Port: <all_caps_service_name>_SERVICE_PORT_<all_caps_port_name>
            value: redis://$(DATA_TIER_SERVICE_HOST):$(DATA_TIER_SERVICE_PORT_REDIS)
          - name: PASSWORD
            valueFrom:
              secretKeyRef:
                name: app-tier-secret
                key: password
```


### Deploy

``` bash
kubectl apply -f app-tier.yaml -n deployments
```

### Cek Pod

``` bash
kubectl get pod -n deployments
```

Hasil :

``` bash
NAME                            READY   STATUS        RESTARTS   AGE
app-tier-59f9c95768-8rftc       1/1     Running       0          14s
app-tier-59f9c95768-9rp4f       1/1     Running       0          18s
app-tier-59f9c95768-gmbgh       1/1     Running       0          18s
app-tier-59f9c95768-hpzcx       1/1     Running       0          18s
app-tier-59f9c95768-vz2w6       1/1     Running       0          15s
app-tier-6fdbd76fb-2l8r7        1/1     Terminating   0          18s
data-tier-7f8446b9f-bbbjt       1/1     Running       0          11m
support-tier-645555cdfb-mww47   2/2     Running       0          68m

```

### Melihat Env

``` bash
kubectl exec -n deployments app-tier-59f9c95768-8rftc -- env
```

Hasil :

``` bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=app-tier-59f9c95768-8rftc
REDIS_URL=redis://10.101.150.129:6379
PASSWORD=admin
DATA_TIER_SERVICE_HOST=10.101.150.129
DATA_TIER_SERVICE_PORT=6379
DATA_TIER_PORT_6379_TCP_PROTO=tcp
KUBERNETES_SERVICE_HOST=10.96.0.1
APP_TIER_PORT_8080_TCP_PROTO=tcp
APP_TIER_PORT_8080_TCP_ADDR=10.104.63.4
KUBERNETES_SERVICE_PORT=443
DATA_TIER_SERVICE_PORT_REDIS=6379
DATA_TIER_PORT_6379_TCP=tcp://10.101.150.129:6379
DATA_TIER_PORT_6379_TCP_ADDR=10.101.150.129
APP_TIER_SERVICE_PORT=8080
APP_TIER_PORT_8080_TCP=tcp://10.104.63.4:8080
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
DATA_TIER_PORT=tcp://10.101.150.129:6379
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
DATA_TIER_PORT_6379_TCP_PORT=6379
APP_TIER_SERVICE_HOST=10.104.63.4
APP_TIER_PORT=tcp://10.104.63.4:8080
APP_TIER_PORT_8080_TCP_PORT=8080
KUBERNETES_PORT=tcp://10.96.0.1:443
NPM_CONFIG_LOGLEVEL=info
NODE_VERSION=6.11.0
YARN_VERSION=0.24.6
HOME=/root
```


## StatefulSet

### Namespace statefulset-ns

``` bash
kubectl create namespace statefulset-ns
```

### Secret mysql-secret.yaml

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-pass
  namespace: statefulset-ns
type: Opaque
data:
  password: QWRtaW5AMTIzCg==
```

### Deploy

``` bash
kubectl apply -f mysql-secret.yaml -n statefulset-ns
```


### PersistentVolume mysql-pv.yaml

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/mysql"
```

### Deploy

```bash
kubectl apply -f mysql-pv.yaml -n statefulset-ns
```

### PersistentVolumeClaim mysql-pvc.yaml

``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: mysql
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Deloy

``` bash
kubectl apply -f mysql-pvc.yaml -n statefulset-ns
```

### Service mysql-service.yaml

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
    tier: backend
  clusterIP: None
```


``` bash
kubectl apply -f mysql-service.yaml -n statefulset-ns
```


### StatefulSet mysql-statefulset.yaml

``` yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  selector:
    matchLabels:
      app: mysql
      tier: backend
  serviceName: mysql
  replicas: 2
  minReadySeconds: 10
  template:
    metadata:
      labels:
        app: mysql
        tier: backend
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

### Deploy

``` bash
kubectl apply -f mysql-statefulset.yaml -n statefulset-ns
```

### Cek Objek

``` bash
kubectl get statefulset,service,po,pv,pvc -n statefulset-ns
```


### Cek Pod

``` bash
kubectl get pod -o wide -n statefulset-ns
```

Hasil :

``` bash
NAME      READY   STATUS    RESTARTS        AGE   IP            NODE       NOMINATED NODE   READINESS GATES
mysql-0   1/1     Running   6 (2m8s ago)    44m   10.244.0.32   minikube   <none>           <none>
mysql-1   1/1     Running   4 (4m32s ago)   44m   10.244.0.33   minikube   <none>           <none>
root@dicoding:~/Project/Microservices/Kubernetes#
```

Karena kita menentukan jumlah replica = 2, StatefulSet membuat 2 Pod dengan penamaan sesuai index yitu mysql-0 dan mysql-1.

Coba hapus Pod mysql-0.

``` bash
kubectl delete pod mysql-0 -n statefulset-ns
```

Kemudian cek kembali

``` bash
kubectl get pod -o wide -n statefulset-ns
```