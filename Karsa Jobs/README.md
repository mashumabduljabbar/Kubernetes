# KARSA JOBS

## Clone Project
### Backend
``` bash
git clone -b karsajobs https://github.com/mashumabduljabbar/a433-microservices/ karsajobs
```

### Frontend
``` bash
git clone -b karsajobs-ui https://github.com/mashumabduljabbar/a433-microservices/ karsajobs-ui
```


## Docker Hub

Buat repo baru di docker hub dengan nama karsajobs dan karsajobs-ui


## Shell Script

Masukkan Password Docker ke dalam Variabel
``` bash 
export PASSWORD_DOCKER_HUB="Sesuai Password"
```

Buat di dalam folder karsajobs

### build_push_image_karsajobs.sh

``` bash
#!/bin/bash

# Set username Docker Hub & Login
export USERNAME_DOCKER="mashumjabbar"
echo $PASSWORD_DOCKER_HUB | docker login -u $USERNAME_DOCKER --password-stdin

# Set Image Name
export IMAGE_BACKEND="karsajobs:latest"

# Nama repo untuk backend
export REPO_BACKEND="$USERNAME_DOCKER/$IMAGE_BACKEND"

# Build Docker image untuk backend
docker build -t $IMAGE_BACKEND -f Dockerfile .

# Cek Docker
docker images

# Tag Local Image dengan Docker Registry
docker tag $IMAGE_BACKEND $REPO_BACKEND

# Push image ke Docker Hub
docker push $REPO_BACKEND
```

Buat di dalam folder karsajobs-ui

### build_push_image_karsajobs_ui.sh

``` bash
#!/bin/bash

# Set Image Name
export IMAGE_FRONTEND="karsajobs-ui:latest"

# Nama repo untuk backend
export REPO_FRONTEND="$USERNAME_DOCKER/$IMAGE_FRONTEND"

# Build Docker image untuk backend
docker build -t $IMAGE_FRONTEND -f Dockerfile .

# Cek Docker
docker images

# Tag Local Image dengan Docker Registry
docker tag $IMAGE_FRONTEND $REPO_FRONTEND

# Push image ke Docker Hub
docker push $REPO_FRONTEND
```


### Build & Push Docker Registry
Berikut adalah cara menjalankan : 

1. Buka Terminal OS kemudian masuk ke dalam Root dari Repository ini yang sejajar dengan bashfile dan juga dockerfile ataupun docker-compose. 


2. Jalankan perintah berikut untuk memberikan hak eksekusi ke script tersebut : 

``` bash
chmod +x build_push_image_karsajobs.sh
```

``` bash
chmod +x build_push_image_karsajobs_ui.sh
```

3. Jalankan script Bash dengan perintah berikut:

``` bash
./build_push_image_karsajobs.sh
```

``` bash
./build_push_image_karsajobs_ui.sh
```


## Struktur Folder

Buat folder baru bernama kubernetes sejajar dengan folder source karsajobs dan karsajobs-ui kemudian buat menjadi seperti struktur berikut :

``` markdown

karsajobs
karsajobs-ui
kubernetes
├── backend
│   ├── karsajobs-service.yml
│   └── karsajobs-deployment.yml
├── frontend
│   ├── karsajobs-ui-service.yml
│   └── karsajobs-ui-deployment.yml
└── mongodb
    ├── mongo-configmap.yml
    ├── mongo-secret.yml
    ├── mongo-pv-pvc.yml
    ├── mongo-service.yml
    └── mongo-statefulset.yml
```

## Backend

### karsajobs-service.yml

``` yaml
apiVersion: v1 # Versi API
kind: Service # Jenis Objek Kubernetes
metadata:
  name: karsajobs-service # Nama Service
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: backend
spec:
  selector:
    app: backend
  ports:
    - port: 8080 # Port expose
  type: NodePort
```


### karsajobs-deployment.yml

``` yaml
apiVersion: apps/v1 # Versi API
kind: Deployment # Jenis Objek Kubernetes
metadata:
  name: karsajobs-deployment # Nama Deployment
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: backend
spec:
  replicas: 3 # Menentukan jumlah replika
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: karsajobs
          image: mashumjabbar/karsajobs:latest # Menggunakan Image yang dibuat dari tahap sebelumnya
          imagePullPolicy : IfNotPresent # Pull jika image tidak ada
          ports:
            - containerPort: 8080 # Port expose dari IP Pod
          resources:
            limits:
              cpu: "250m" # Menggunakan 1/4 CPU
              memory: "256Mi" # Menggunakan 256 MB Memory
          env:
            - name: APP_PORT # APP_PORT dengan nilai “8080”
              value: "8080"
            - name: MONGO_HOST # MONGO_HOST dengan nilai yang diambil dari MongoDB Service
              value: mongo
            - name: MONGO_USER # MONGO_USER dengan nilai yang diambil dari MongoDB Secret (MONGO_ROOT_USERNAME)
              valueFrom:
                secretKeyRef:
                  name: mongo-secret
                  key: MONGO_ROOT_USERNAME
            - name: MONGO_PASS # MONGO_PASS dengan nilai yang diambil dari MongoDB Secret (MONGO_ROOT_PASSWORD)
              valueFrom:
                secretKeyRef:
                  name: mongo-secret
                  key: MONGO_ROOT_PASSWORD
```


## Frontend

### karsajobs-ui-service.yml

``` yaml
apiVersion: v1 # Versi API
kind: Service # Jenis Objek Kubernetes
metadata:
  name: karsajobs-ui-service # Nama Service
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: frontend
spec:
  selector:
    app: frontend
  ports:
    - port: 80 # Port expose
  type: NodePort
```


### karsajobs-ui-deployment.yml

``` yaml
apiVersion: apps/v1 # Versi API
kind: Deployment # Jenis Objek Kubernetes
metadata:
  name: karsajobs-ui-deployment # Nama Deployment
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: frontend
spec:
  replicas: 1 # Menentukan jumlah replika
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: karsajobs-ui
          image: mashumjabbar/karsajobs-ui:latest # Menggunakan image dari tahap sebelumnya
          imagePullPolicy : IfNotPresent # Pull jika image tidak ada
          ports:
            - containerPort: 8000 # Port expose dari IP Pod
          resources:
            limits:
              cpu: "500m" # Menggunakan 1/2 CPU
              memory: "512Mi" # Menggunakan 512 MB Memory
          env:
            - name: VUE_APP_BACKEND
              value: http://127.0.0.1:54321 # Ketika hendak deploy karsajobs-ui (frontend), pastikan mengubah nilai VUE_APP_BACKEND dengan nilai Node IP dan Node Port sesuai pada komputer Anda.
```


## MongoDB

### mongo-configmap.yml

``` yaml
apiVersion: v1 # Versi API
kind: ConfigMap # Jenis Objek Kubernetes
metadata:
  name: mongo-config
  namespace: karsajobs-ns # Nama Namespace
data: #Lokasi
  mongo.conf: |
    storage:
      dbPath: /data/db 
```


### mongo-secret.yml

``` yaml
apiVersion: v1 # Versi API
kind: Secret # Jenis Objek Kubernetes
metadata:
  name: mongo-secret
  namespace: karsajobs-ns # Nama Namespace
type: Opaque
data:
  MONGO_ROOT_USERNAME: YWRtaW4= # admin
  MONGO_ROOT_PASSWORD: c3VwZXJzZWNyZXRwYXNzd29yZA== # supersecretpassword base64
```


### mongo-pv-pvc.yml

``` yaml
apiVersion: v1 # Versi API
kind: PersistentVolume # Jenis Objek Kubernetes
metadata:
  name: mongo-pv-pvc
  namespace: karsajobs-ns # Nama Namespace
  labels:
    type: local
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: manual
  hostPath:
    path: /data/db

---
apiVersion: v1 # Versi API
kind: PersistentVolumeClaim # Jenis Objek Kubernetes
metadata:
  name: mongo-pv-claim
  namespace: karsajobs-ns # Nama Namespace
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
```


### mongo-service.yml

``` yaml
apiVersion: v1 # Versi API
kind: Service # Jenis Objek Kubernetes
metadata:
  name: mongo-service
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: mongodb
spec:
  selector:
    app: mongodb
  ports:
    - port: 27017 # Port Expose
  clusterIP: None
```


### mongo-statefulset.yml

``` yaml
apiVersion: apps/v1 # Versi API
kind: StatefulSet # Jenis Objek Kubernetes
metadata:
  name: mongo-statefulset
  namespace: karsajobs-ns # Nama Namespace
  labels:
    app: mongodb
spec:
  serviceName: "mongo-service"
  minReadySeconds: 10
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: mongodb
        image: mongo:3 # Image dari Docker Hub untuk Mongo DB versi 3
        imagePullPolicy: IfNotPresent
        env: 
        - name: MONGO_INITDB_ROOT_USERNAME_FILE
          value: /etc/mongo-credentials/MONGO_ROOT_USERNAME
        - name: MONGO_INITDB_ROOT_PASSWORD_FILE
          value: /etc/mongo-credentials/MONGO_ROOT_PASSWORD
        ports:
        - containerPort: 27017
          name: mongodb
        volumeMounts:
        - name: mongo-persistent-storage # Persistent Volume dengan mount path /data/db
          mountPath: /data/db
        - name: mongo-config # ConfigMap dengan mount path /config
          mountPath: /config
        - name: mongo-secret # Secret dengan mount path /etc/mongo-credentials
          mountPath: /etc/mongo-credentials
      volumes:
      - name: mongo-persistent-storage
        persistentVolumeClaim:
          claimName: mongo-pv-claim
      - name: mongo-config
        configMap:
          name: mongo-config
          items: 
            - key: mongo.conf
              path: mongo.conf
      - name: mongo-secret
        secret:
          secretName: mongo-secret
```


## Deploy Kubernetes

### Jalankan minikube
``` 
sudo sysctl fs.protected_regular=0
sudo chown -R $(whoami) /root/.minikube
sudo chown -R $(whoami) /tmp/juju-*
minikube start --force
```

### Membuat Namespace

``` bash
kubectl create namespace karsajobs-ns
```

``` bash
kubectl get namespace
```

### Deploy MongoDB dan Backend

Masuk ke folder kubernetes

``` bash
kubectl apply -f mongodb/mongo-configmap.yml
kubectl apply -f mongodb/mongo-secret.yml
kubectl apply -f mongodb/mongo-pv-pvc.yml
kubectl apply -f mongodb/mongo-statefulset.yml
kubectl apply -f mongodb/mongo-service.yml
kubectl apply -f backend/karsajobs-service.yml
kubectl apply -f backend/karsajobs-deployment.yml
```

Cek IP dan Port

``` bash
kubectl get service karsajobs-service -n karsajobs-ns
```

``` bash
NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
karsajobs-service   NodePort   10.111.220.100   <none>        8080:30919/TCP   77m
```

Sesuaikan IP dan Port di karsajobs-ui-deployment.yml
``` yaml 
env:
  - name: VUE_APP_BACKEND
    value: http://10.111.220.100:30919
```

Cara lain agar tidak perlu menyesuaikan IP dan Port, ubah di karsajobs-service.yml

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: karsajobs-service
  namespace: karsajobs-ns
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
```

Sesuaikan di bagian karsajobs-ui-deployment.ym
``` yaml
env:
  - name: VUE_APP_BACKEND
    value: http://karsajobs-service:8080
```


### Deploy Frontend
``` bash
kubectl apply -f frontend/karsajobs-ui-service.yml
kubectl apply -f frontend/karsajobs-ui-deployment.yml
```

## Pengujian

### Cek IP Minikube

``` bash
root@dicoding:~/Project/Microservices/kubernetes# minikube ip
192.168.49.2
```

### Cek Port Node

``` bash
root@dicoding:~/Project/Microservices/kubernetes# kubectl get service karsajobs-ui-service -n karsajobs-ns
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
karsajobs-ui-service   NodePort   10.101.241.182   <none>        80:30199/TCP   117m
```

atau

``` bash
root@dicoding:~/Project/Microservices/kubernetes# minikube service karsajobs-ui-service -n karsajobs-ns
|--------------|----------------------|-------------|---------------------------|
|  NAMESPACE   |         NAME         | TARGET PORT |            URL            |
|--------------|----------------------|-------------|---------------------------|
| karsajobs-ns | karsajobs-ui-service |          80 | http://192.168.49.2:30199 |
|--------------|----------------------|-------------|---------------------------|
* Opening service karsajobs-ns/karsajobs-ui-service in default browser...
  http://192.168.49.2:30199
root@dicoding:~/Project/Microservices/kubernetes#

```

### Akses Browser

``` bash 
http://192.168.49.2:30199
```



## Just In Case

### Hapus Object
``` bash
# Hapus semua objek di namespace karsajobs-ns
kubectl delete all --all -n karsajobs-ns

# Hapus PersistentVolumes dan PersistentVolumeClaims (hati-hati dengan perintah ini)
kubectl delete pv,pvc --all -n karsajobs-ns

# Hapus namespace karsajobs-ns
kubectl delete namespace karsajobs-ns

```