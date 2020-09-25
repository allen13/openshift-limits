openshift limits
----------------

Topics:

* CPU in Kubernetes
* CPU limits and requests
* ResourceQuota
* LimitRange
* ServiceAccounts
* ServiceAccount Tokens
* Secrets
* Openshift API
* Create App example that consumes API
* SCC
* Roles and RoleBindings
* ClusterRole and ClusterRoleBindings
* Openshift CLI Developer/Admin
* CNCF Projects
* Future of Kubernetes

user project
------------

This guide will focus on limiting consumption of openshift resources. This lesson will be essential for anyone mananing a multi-tenant cluster. Start by creating your own project/namespace and making sure your oc client context is set to that namespace.

meaning of cpu in kubernetes
----------------------------

Limits and requests for CPU resources are measured in cpu units. One cpu, in Kubernetes, is equivalent to 1 vCPU/Core for cloud providers and 1 hyperthread on bare-metal Intel processors.

Fractional requests are allowed. A Container with spec.containers[].resources.requests.cpu of 0.5 is guaranteed half as much CPU as one that asks for 1 CPU. The expression 0.1 is equivalent to the expression 100m, which can be read as "one hundred millicpu". Some people say "one hundred millicores", and this is understood to mean the same thing. A request with a decimal point, like 0.1, is converted to 100m by the API, and precision finer than 1m is not allowed. For this reason, the form 100m might be preferred.

CPU is always requested as an absolute quantity, never as a relative quantity; 0.1 is the same amount of CPU on a single-core, dual-core, or 48-core machine.

Keep in mind the performance of a core can be different for different CPU models.

requests vs limits
------------------

Requests and limits are the mechanisms Kubernetes uses to control resources such as CPU and memory. Requests are what the container is guaranteed to get. If a container requests a resource, Kubernetes will only schedule it on a node that can give it that resource. Limits, on the other hand, make sure a container never goes above a certain value. The container is only allowed to go up to the limit, and then it is restricted.

See [demo-pod.yml](demo-pod.yml)

quotas
------

A resource quota, defined by a ResourceQuota object, provides constraints that limit aggregate resource consumption per project. It can limit the quantity of objects that can be created in a project by type, as well as the total amount of compute resources and storage that may be consumed by resources in that project.

Apply a resource quota to your project. Keep the limits artificially low so you will have a resource conflict when deploying an app later. You will need to fix it. See [resourcequota.yml](resourcequota.yml)

* [Project Quota](https://docs.openshift.com/container-platform/4.5/applications/quotas/quotas-setting-per-project.html)
* [Cluster Quota](https://docs.openshift.com/container-platform/4.5/applications/quotas/quotas-setting-across-multiple-projects.html)

limit range
-----------

A limit range, defined by a LimitRange object, restricts resource consumption in a project. In the project you can set specific resource limits for a Pod, container, image, image stream, or persistent volume claim (PVC).

All requests to create and modify resources are evaluated against each LimitRange object in the project. If the resource violates any of the enumerated constraints, the resource is rejected.

Apply a limit range to your project. See [limitrange.yml](limitrange.yml)

* [Limit Range](https://docs.openshift.com/container-platform/4.5/nodes/clusters/nodes-cluster-limit-ranges.html)

service account
---------------

A service account is an OpenShift Container Platform account that allows a component to directly access the API. Service accounts are API objects that exist within each project. Service accounts provide a flexible way to control API access without sharing a regular user’s credentials.

Create a new service account in your namespace. Also, take time to list the existing service accounts that are part of your namespace by default.

* [Using Service Accounts](https://docs.openshift.com/container-platform/4.5/authentication/using-service-accounts-in-applications.html)

secrets
-------

Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Storing confidential information in a Secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image .

View the secrets in your current namspace that contain the service account tokens

* [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

kubernetes api app
------------------

Kubernetes has an extensive set of libraries for each language the allow easy programtic communication with resources. Review [podlist.go](podlist.go) as an example of that in action. Pay special attention to `InClusterConfig()`. This method reads the service account tokens that are mounted to the pod and then uses it to communicate with the kubernetes api.

Deploy the podlist app using the service account you created. See [deployment.yml](deployment.yml)

Expect problems. Run `oc get events`.

scc
---

Similar to the way that RBAC resources control user access, administrators can use Security Context Constraints (SCCs) to control permissions for pods. These permissions include actions that a pod, a collection of containers, can perform and what resources it can access. You can use SCCs to define a set of conditions that a pod must run with in order to be accepted into the system.

Apply an SCC to your new service account that allows a pod to perform host mounts.

Tip:

    oc adm policy add-scc-to-user hostmount-anyuid -z my-service-account -n my-project

* [Managing SCCs](https://docs.openshift.com/container-platform/4.5/authentication/managing-security-context-constraints.html)


rbac
----

An RBAC Role or ClusterRole contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).

A Role always sets permissions within a particular namespace ; when you create a Role, you have to specify the namespace it belongs in.

ClusterRole, by contrast, is a non-namespaced resource. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.

ClusterRoles have several uses. You can use a ClusterRole to:

    define permissions on namespaced resources and be granted within individual namespace(s)
    define permissions on namespaced resources and be granted across all namespaces
    define permissions on cluster-scoped resources

If you want to define a role within a namespace, use a Role; if you want to define a role cluster-wide, use a ClusterRole

Apply the view cluster role to the service account you created:

    # the openshift way
    oc adm policy add-cluster-role-to-user view -z <serviceaccountname> -n <namespace>

    # the kubernetes way
    kubectl create clusterrolebinding default-view --clusterrole=view --serviceaccount=<namespace>:<serviceaccountname>


* [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
* [Managing Roles with oc](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_rbac.html)

openshift cli
-------------

* [Admin CLI commands](https://docs.openshift.com/container-platform/4.5/cli_reference/openshift_cli/administrator-cli-commands.html)
* [Developer CLI commands](https://docs.openshift.com/container-platform/4.5/cli_reference/openshift_cli/developer-cli-commands.html)

CNCF (Cloud Native Foundation)
------------------------------

The Foundation’s mission is to make cloud native computing ubiquitous. The CNCF Cloud Native Definition v1.0 says:

Cloud native technologies empower organizations to build and run scalable applications in modern, dynamic environments such as public, private, and hybrid clouds. Containers, service meshes, microservices, immutable infrastructure, and declarative APIs exemplify this approach.

These techniques enable loosely coupled systems that are resilient, manageable, and observable. Combined with robust automation, they allow engineers to make high-impact changes frequently and predictably with minimal toil.

The Cloud Native Computing Foundation seeks to drive adoption of this paradigm by fostering and sustaining an ecosystem of open source, vendor-neutral projects. We democratize state-of-the-art patterns to make these innovations accessible for everyone.

* [CNCF](https://www.cncf.io/)
* [Graduated and Incubating Projects](https://www.cncf.io/projects/)
* [Sandbox Projects](https://www.cncf.io/sandbox-projects/)

future of openshift/kubernetes
------------------------------

Since its launch, Kubernetes has proven to be more than just Borg for everyone. It has distilled with most reliable API patterns and architectures of prior software. It has coupled them with current authorization policies, load balancing, and other features that are required to manage and run applications at massive scale. In turn, this provides developers with the groundwork for cluster abstractions to enable true portability across clouds. 

With the explosion of innovation around Kubernetes, businesses have started to analyze obstacles for complete adoption. Many giants in the industry have increased investing resources and assuring mission-critical workloads. Fortunately, Kubernetes got a better response for the wave of adoption that swept to the forefront of crowded container management space.

My prediction:

Kubernetes will continue to grow in adoption. However, over time, developers will use the base Kubernetes resources less and less. Projects like Knative and other serverless type abstractions will make it so developers can focus on solving business problems and not infrastructure problems. 

* [Future of Kubernetes](https://cloudacademy.com/blog/kubernetes-the-current-and-future-state-of-k8s-in-the-enterprise/)
* [Distributed Operating System](https://medium.com/@bleggett/kubernetes-distributed-operating-systems-and-language-level-parallelism-deb7a6710e41)
