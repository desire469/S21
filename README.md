# Helm и Kustomization

💡 [Tap here](https://new.oprosso.net/p/4cb31ec3f47a4596bc758ea1861fb624) **to leave your feedback on the project**. It's anonymous and will help our team make your educational experience better. We recommend completing the survey immediately after the project.

## Contents

1. [Chapter I](#chapter-i) 
2. [Chapter II](#chapter-ii) \
   2.1. [Deploying an application using Kustomize](#part-1-deploying-an-application-using-Kustomize) \
   2.2. [Deploying an application using Helm](#part-2-deploying-an-application-using-Helm) \

## Instructions

How to learn at “School 21”:

- Here, you’ll find a unique learning experience with a lot of freedom. You’re given a task and left to find your own way to solve it, using whatever resources work best for you — whether that’s the Internet or AI tools like GigaChat. Just be mindful of information quality: verify, think critically, analyze, and compare.
- Peer-to-peer (P2P) learning is the exchange of knowledge and experience with peers, where everyone acts as both mentor and student. This approach allows you to gain a deeper understanding of the material by learning from one another.
- Feel free to ask for help: around you are peers who are also navigating this path for the first time. Share your own experience and ideas with others.  Join Rocket.Chat to stay updated with the latest community announcements. 
- Your learning is meaningless if you just copy someone else’s solutions. When receiving help from others, always make sure you fully understand the “why”, “how”, and “purpose” behind the solution. Don’t be afraid to make mistakes. 
- Does the task seem impossible? Take a break, get some fresh air and clear your mind — this has helped many people. Maybe after that, the solution will come to you naturally.
- The learning process is just as important as the result. It’s not just about completing the task — it’s about understanding HOW to solve it. 

How to work with the project:

- Before starting, clone the project from GitLab into a repository with the same name.
- All files should be created inside the _src/_ folder of the cloned repository.
- After cloning the project, create a _develop_ branch and do all your development there. Then, push the _develop_ branch to GitLab.
- Your directory should not contain any files other than those specified in the assignments.

## Chapter I

Kubernetes is one of the fastest-growing technologies, and companies of all kinds are now using it. When running an application in Kubernetes, you need to deploy several objects, such as a deployment, a configuration map, and secrets. All of these objects must be defined in the manifest.yml file and sent to the Kubernetes API server. Kubernetes then reads these manifests and creates the necessary objects.

While deploying an application once is fine, if you want to deploy the application repeatedly, you must send all the manifest files to the Kubernetes API server each time. Helm is a tool that solves this problem.

**Helm** is a package manager for Kubernetes that provides solutions for package management, security, and configuration when deploying applications to Kubernetes. Helm simplifies your work with Kubernetes.

Meanwhile, **Kustomize** is becoming an increasingly popular tool for managing Kubernetes manifests. Unlike Helm, which uses templates, Kustomize relies on existing manifests. It provides various features, including resource namespace, metadata modification, and Kubernetes secret creation, without editing the source manifests.

## Chapter II

The result of the work must be a report with detailed descriptions of how each point was implemented, accompanied by screenshots. Prepare the report as a Markdown file in the `src` directory named `REPORT.MD`.

## Part 1. Deploying an application using Kustomize

### Task

1. Get a set of virtual machines with a deployed cluster.

2. Copy the manifests from previous blocks.

3. Install *kustomize* on the local machine.

4. Create a deployment project skeleton with one base configuration and one overlay configuration (production):

```
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   ├── service.yaml
│   └── ...
├── overlays
│   └── production
│       ├── kustomization.yaml
│       ├── configMap.yaml
│       ├── secret.yaml
│       └── ...
├── kustomization.yaml
└── ...
```

5. Write base and overlay configurations for Kustomize. Specify the services and deployments in the base configuration and add the specific secrets and configuration values in the production configuration.

6. Create `replicas-patch.yaml` for the production overlay that modifies the number of replicas for the gateway service deployment to three.

7. Build the resulting configuration file, taking the `production` overlay into account.

8. Run Postman functional tests to ensure that the application works.

## Part 2. Deploying an application using Helm

### Task 

1. Get a set of virtual machines with a deployed cluster.

2. Copy the manifests from previous blocks.

3. Install *Helm* on the local machine and ensure that the tool has a valid connection to the resulting remote Kubernetes cluster.

4. Create Helm charts and templates for your application with the `helm create` command. This command creates a basic chart structure with templates for deployment, service, and ingress resources.

5. Edit the `values.yaml` in the chart to specify the configuration parameters needed to create Kubernetes manifests for the specified deployments. Describe the deployment objects and services in the templates directory.

6. Use the `helm package` command to pack the *Helm chart* and create a `*.tgz` file containing the chart and its dependencies.

7. Deploy the Helm chart in the Kubernetes cluster using the `helm install` command. Specify an arbitrary `namespace` and `release-name`.

8. Check the status of the deployed application with the `kubectl get` command. Add the results to the report.

9. Make at least one change to `values.yaml` and run the `helm upgrade` command.

10. Run Postman functional tests to ensure that the application is working properly.