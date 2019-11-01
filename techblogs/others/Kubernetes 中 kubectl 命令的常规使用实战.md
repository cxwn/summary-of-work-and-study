# Kubernetes 中 kubectl 命令的常规使用实战

## 一 背景

在某些情况下， kubectl 常用命令的熟练使用能起到事半功倍的效果。本文记录了该命令的一些常规用法，通过纯命令行创建各类常用资源。文中实战的 Kubernetes 版本为 v1.14。

## 二 帮助信息

```txt
kubectl controls the Kubernetes cluster manager.

 Find more information at: https://kubernetes.io/docs/reference/kubectl/overview/

Basic Commands (Beginner):
  create         Create a resource from a file or from stdin.
  expose         使用 replication controller, service, deployment 或者 pod 并暴露它作为一个 新的
Kubernetes Service
  run            在集群中运行一个指定的镜像
  set            为 objects 设置一个指定的特征

Basic Commands (Intermediate):
  explain        查看资源的文档
  get            显示一个或更多 resources
  edit           在服务器上编辑一个资源
  delete         Delete resources by filenames, stdin, resources and names, or by resources and label selector

Deploy Commands:
  rollout        Manage the rollout of a resource
  scale          为 Deployment, ReplicaSet, Replication Controller 或者 Job 设置一个新的副本数量
  autoscale      自动调整一个 Deployment, ReplicaSet, 或者 ReplicationController 的副本数量

Cluster Management Commands:
  certificate    修改 certificate 资源.
  cluster-info   显示集群信息
  top            Display Resource (CPU/Memory/Storage) usage.
  cordon         标记 node 为 unschedulable
  uncordon       标记 node 为 schedulable
  drain          Drain node in preparation for maintenance
  taint          更新一个或者多个 node 上的 taints

Troubleshooting and Debugging Commands:
  describe       显示一个指定 resource 或者 group 的 resources 详情
  logs           输出容器在 pod 中的日志
  attach         Attach 到一个运行中的 container
  exec           在一个 container 中执行一个命令
  port-forward   Forward one or more local ports to a pod
  proxy          运行一个 proxy 到 Kubernetes API server
  cp             复制 files 和 directories 到 containers 和从容器中复制 files 和 directories.
  auth           Inspect authorization

Advanced Commands:
  diff           Diff live version against would-be applied version
  apply          通过文件名或标准输入流(stdin)对资源进行配置
  patch          使用 strategic merge patch 更新一个资源的 field(s)
  replace        通过 filename 或者 stdin替换一个资源
  wait           Experimental: Wait for a specific condition on one or many resources.
  convert        在不同的 API versions 转换配置文件
  kustomize      Build a kustomization target from a directory or a remote url.

Settings Commands:
  label          更新在这个资源上的 labels
  annotate       更新一个资源的注解
  completion     Output shell completion code for the specified shell (bash or zsh)

Other Commands:
  api-resources  Print the supported API resources on the server
  api-versions   Print the supported API versions on the server, in the form of "group/version"
  config         修改 kubeconfig 文件
  plugin         Provides utilities for interacting with plugins.
  version        输出 client 和 server 的版本信息

Usage:
  kubectl [flags] [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

## 三 实战

由于涉及到的命令过多，文中以最常用的命令为例，其他命令以此类推。

### 2.1 使用 create、expose、edit、scale 命令创建一个服务。

create 命令用于常规资源的创建，帮助信息如下：

```txt
Create a resource from a file or from stdin.

 JSON and YAML formats are accepted.

Examples:
  # Create a pod using the data in pod.json.
  kubectl create -f ./pod.json
  
  # Create a pod based on the JSON passed into stdin.
  cat pod.json | kubectl create -f -
  
  # Edit the data in docker-registry.yaml in JSON then create the resource using the edited data.
  kubectl create -f docker-registry.yaml --edit -o json

Available Commands:
  clusterrole         Create a ClusterRole.
  clusterrolebinding  为一个指定的 ClusterRole 创建一个 ClusterRoleBinding
  configmap           从本地 file, directory 或者 literal value 创建一个 configmap
  cronjob             Create a cronjob with the specified name.
  deployment          创建一个指定名称的 deployment.
  job                 Create a job with the specified name.
  namespace           创建一个指定名称的 namespace
  poddisruptionbudget 创建一个指定名称的 pod disruption budget.
  priorityclass       Create a priorityclass with the specified name.
  quota               创建一个指定名称的 quota.
  role                Create a role with single rule.
  rolebinding         为一个指定的 Role 或者 ClusterRole创建一个 RoleBinding
  secret              使用指定的 subcommand 创建一个 secret
  service             使用指定的 subcommand 创建一个 service.
  serviceaccount      创建一个指定名称的 service account

Options:
      --allow-missing-template-keys=true: If true, ignore any errors in templates when a field or map key is missing in
the template. Only applies to golang and jsonpath output formats.
      --dry-run=false: If true, only print the object that would be sent, without sending it.
      --edit=false: Edit the API resource before creating
  -f, --filename=[]: Filename, directory, or URL to files to use to create the resource
  -k, --kustomize='': Process the kustomization directory. This flag can't be used together with -f or -R.
  -o, --output='': Output format. One of:
json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-file.
      --raw='': Raw URI to POST to the server.  Uses the transport specified by the kubeconfig file.
      --record=false: Record current kubectl command in the resource annotation. If set to false, do not record the
command. If set to true, record the command. If not set, default to updating the existing annotation value only if one
already exists.
  -R, --recursive=false: Process the directory used in -f, --filename recursively. Useful when you want to manage
related manifests organized within the same directory.
      --save-config=false: If true, the configuration of current object will be saved in its annotation. Otherwise, the
annotation will be unchanged. This flag is useful when you want to perform kubectl apply on this object in the future.
  -l, --selector='': Selector (label query) to filter on, supports '=', '==', and '!='.(e.g. -l key1=value1,key2=value2)
      --template='': Template string or path to template file to use when -o=go-template, -o=go-template-file. The
template format is golang templates [http://golang.org/pkg/text/template/#pkg-overview].
      --validate=true: If true, use a schema to validate the input before sending it
      --windows-line-endings=false: Only relevant if --edit=true. Defaults to the line ending native to your platform.

Usage:
  kubectl create -f FILENAME [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

相关资源的 yaml 大概轮廓，可以使用：

```bash
[root@gysl-master ~]# kubectl create deployment test --dry-run -o yaml --image=nginx
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: test
  name: test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: test
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

```bash
[root@gysl-master ~]# kubectl create deployment app-nginx --image=nginx:latest
deployment.apps/app-nginx created
```

```txt
Expose a resource as a new Kubernetes service.

 Looks up a deployment, service, replica set, replication controller or pod by name and uses the selector for that
resource as the selector for a new service on the specified port. A deployment or replica set will be exposed as a
service only if its selector is convertible to a selector that service supports, i.e. when the selector contains only
the matchLabels component. Note that if no port is specified via --port and the exposed resource has multiple ports, all
will be re-used by the new service. Also if no labels are specified, the new service will re-use the labels from the
resource it exposes.

 Possible resources include (case insensitive):

 pod (po), service (svc), replicationcontroller (rc), deployment (deploy), replicaset (rs)

Examples:
  # Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000.
  kubectl expose rc nginx --port=80 --target-port=8000
  
  # Create a service for a replication controller identified by type and name specified in "nginx-controller.yaml",
which serves on port 80 and connects to the containers on port 8000.
  kubectl expose -f nginx-controller.yaml --port=80 --target-port=8000
  
  # Create a service for a pod valid-pod, which serves on port 444 with the name "frontend"
  kubectl expose pod valid-pod --port=444 --name=frontend
  
  # Create a second service based on the above service, exposing the container port 8443 as port 443 with the name
"nginx-https"
  kubectl expose service nginx --port=443 --target-port=8443 --name=nginx-https
  
  # Create a service for a replicated streaming application on port 4100 balancing UDP traffic and named 'video-stream'.
  kubectl expose rc streamer --port=4100 --protocol=UDP --name=video-stream
  
  # Create a service for a replicated nginx using replica set, which serves on port 80 and connects to the containers on
port 8000.
  kubectl expose rs nginx --port=80 --target-port=8000
  
  # Create a service for an nginx deployment, which serves on port 80 and connects to the containers on port 8000.
  kubectl expose deployment nginx --port=80 --target-port=8000

Options:
      --allow-missing-template-keys=true: If true, ignore any errors in templates when a field or map key is missing in
the template. Only applies to golang and jsonpath output formats.
      --cluster-ip='': ClusterIP to be assigned to the service. Leave empty to auto-allocate, or set to 'None' to create
a headless service.
      --dry-run=false: If true, only print the object that would be sent, without sending it.
      --external-ip='': Additional external IP address (not managed by Kubernetes) to accept for the service. If this IP
is routed to a node, the service can be accessed by this IP in addition to its generated service IP.
  -f, --filename=[]: Filename, directory, or URL to files identifying the resource to expose a service
      --generator='service/v2': 使用 generator 的名称. 这里有 2 个 generators: 'service/v1' 和 'service/v2'.
为一个不同地方是服务端口在 v1 的情况下叫 'default', 如果在 v2 中没有指定名称.
默认的名称是 'service/v2'.
  -k, --kustomize='': Process the kustomization directory. This flag can't be used together with -f or -R.
  -l, --labels='': Labels to apply to the service created by this call.
      --load-balancer-ip='': IP to assign to the LoadBalancer. If empty, an ephemeral IP will be created and used
(cloud-provider specific).
      --name='': 名称为最新创建的对象.
  -o, --output='': Output format. One of:
json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-file.
      --overrides='': An inline JSON override for the generated object. If this is non-empty, it is used to override the
generated object. Requires that the object supply a valid apiVersion field.
      --port='': 服务的端口应该被指定. 如果没有指定, 从被创建的资源中复制
      --protocol='': 创建 service 的时候伴随着一个网络协议被创建. 默认是 'TCP'.
      --record=false: Record current kubectl command in the resource annotation. If set to false, do not record the
command. If set to true, record the command. If not set, default to updating the existing annotation value only if one
already exists.
  -R, --recursive=false: Process the directory used in -f, --filename recursively. Useful when you want to manage
related manifests organized within the same directory.
      --save-config=false: If true, the configuration of current object will be saved in its annotation. Otherwise, the
annotation will be unchanged. This flag is useful when you want to perform kubectl apply on this object in the future.
      --selector='': A label selector to use for this service. Only equality-based selector requirements are supported.
If empty (the default) infer the selector from the replication controller or replica set.)
      --session-affinity='': If non-empty, set the session affinity for the service to this; legal values: 'None',
'ClientIP'
      --target-port='': Name or number for the port on the container that the service should direct traffic to.
Optional.
      --template='': Template string or path to template file to use when -o=go-template, -o=go-template-file. The
template format is golang templates [http://golang.org/pkg/text/template/#pkg-overview].
      --type='': Type for this service: ClusterIP, NodePort, LoadBalancer, or ExternalName. Default is 'ClusterIP'.

Usage:
  kubectl expose (-f FILENAME | TYPE NAME) [--port=port] [--protocol=TCP|UDP|SCTP] [--target-port=number-or-name]
[--name=name] [--external-ip=external-ip-of-service] [--type=type] [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
```

```txt
Edit a resource from the default editor.

 The edit command allows you to directly edit any API resource you can retrieve via the command line tools. It will open
the editor defined by your KUBE_EDITOR, or EDITOR environment variables, or fall back to 'vi' for Linux or 'notepad' for
Windows. You can edit multiple objects, although changes are applied one at a time. The command accepts filenames as
well as command line arguments, although the files you point to must be previously saved versions of resources.

 Editing is done with the API version used to fetch the resource. To edit using a specific API version, fully-qualify
the resource, version, and group.

 The default format is YAML. To edit in JSON, specify "-o json".

 The flag --windows-line-endings can be used to force Windows line endings, otherwise the default for your operating
system will be used.

 In the event an error occurs while updating, a temporary file will be created on disk that contains your unapplied
changes. The most common error when updating a resource is another editor changing the resource on the server. When this
occurs, you will have to apply your changes to the newer version of the resource, or update your temporary saved copy to
include the latest resource version.

Examples:
  # Edit the service named 'docker-registry':
  kubectl edit svc/docker-registry
  
  # Use an alternative editor
  KUBE_EDITOR="nano" kubectl edit svc/docker-registry
  
  # Edit the job 'myjob' in JSON using the v1 API format:
  kubectl edit job.v1.batch/myjob -o json
  
  # Edit the deployment 'mydeployment' in YAML and save the modified config in its annotation:
  kubectl edit deployment/mydeployment -o yaml --save-config

Options:
      --allow-missing-template-keys=true: If true, ignore any errors in templates when a field or map key is missing in
the template. Only applies to golang and jsonpath output formats.
  -f, --filename=[]: Filename, directory, or URL to files to use to edit the resource
  -k, --kustomize='': Process the kustomization directory. This flag can't be used together with -f or -R.
  -o, --output='': Output format. One of:
json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-file.
      --output-patch=false: Output the patch if the resource is edited.
      --record=false: Record current kubectl command in the resource annotation. If set to false, do not record the
command. If set to true, record the command. If not set, default to updating the existing annotation value only if one
already exists.
  -R, --recursive=false: Process the directory used in -f, --filename recursively. Useful when you want to manage
related manifests organized within the same directory.
      --save-config=false: If true, the configuration of current object will be saved in its annotation. Otherwise, the
annotation will be unchanged. This flag is useful when you want to perform kubectl apply on this object in the future.
      --template='': Template string or path to template file to use when -o=go-template, -o=go-template-file. The
template format is golang templates [http://golang.org/pkg/text/template/#pkg-overview].
      --validate=true: If true, use a schema to validate the input before sending it
      --windows-line-endings=false: Defaults to the line ending native to your platform.

Usage:
  kubectl edit (RESOURCE/NAME | -f FILENAME) [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
```