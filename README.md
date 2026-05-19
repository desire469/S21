# Advanced Kubernetes

💡 [Tap here](https://new.oprosso.net/p/4cb31ec3f47a4596bc758ea1861fb624) **to leave your feedback on the project**. It's anonymous and will help our team make your educational experience better. We recommend completing the survey immediately after the project.

## Contents

1. [Chapter I](#chapter-i) 
2. [Chapter II](#chapter-ii) \
   2.1. [Deploying your own k3s cluster](#part-1-deploying-your-own-k3s-cluster) \

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

Besides Docker Swarm, there are many other orchestration tools. One of the most popular is Kubernetes, a tool developed by Google. Kubernetes' main difference is its higher complexity and scale. Kubernetes is intended for more serious applications with a large number of services and complex interactions. It also has a number of additional built-in tools, such as an internal monitoring system.

## Chapter II

The result of the work must be a report with detailed descriptions and screenshots of the implementation of each point. Prepare the report as a Markdown file in the `src` directory named `REPORT.MD`.

## Part 1. Deploying your own k3s cluster

### Task 

1. Obtain a set of virtual machines for the cluster.

2. Install k3s on all three machines. During installation, do not use the standard Ingress Controller by adding the flag `--disable=traefik`.

3. Connect the nodes to the cluster using the `k3s server` command and the `-token` and `--server` flags for the worker and master nodes, respectively. Once k3s is installed, the environment variable `NODE_TOKEN` can be used.

4. Install the Ingress Controller Nginx instead of the default one. You can use the official nginx-based ingress controller manifest file available on GitHub.

5. Get a domain name and configure the `cert-manager` utility inside the cluster. This should generate a wildcard certificate for the domain.

6. Create an Ingress resource for your personal domain, and configure it to use the Nginx Ingress Controller and the obtained certificate.

7. Create a Persistent Volume (PV) for the PostgreSQL database in the manifest from the tenth project.

8. Run the application described in the manifest.

9. Run Postman functional tests to ensure that the application is working properly.

10. Install and run the Prometheus Operator to collect metrics in the system. Include the result of the `kubectl get pods -n monitoring` command in the report.