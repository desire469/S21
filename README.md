# Automation tools

Automation tools for node provisioning.

💡 [Tap here](https://new.oprosso.net/p/4cb31ec3f47a4596bc758ea1861fb624) **to leave your feedback on the project**. It's anonymous and will help our team make your educational experience better. We recommend completing the survey immediately after the project.

## Contents

1. [Chapter I](#chapter-i) 
2. [Chapter II](#chapter-ii) \
   2.1. [Remote node configuration via Ansible](#part-1-remote-node-configuration-via-Ansible) \
   2.2. [Service Discovery](#part-2-service-discovery) 

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

When deploying an application on a node, whether in production or in a test environment, the machine itself must be prepared for the deployment. As you know, the Docker image contains all the necessary dependencies to run the application. However, there are still a number of parameters that require additional configuration or provisioning. These can include installing packages and tools (such as Docker itself or Git) or additional configurations depending on the node, migration of files, etc. Many tools have been created to automate remote machine configuration, one of which is **Ansible**.

In the world of modern web applications, it often happens that a service available at one IP address is moved to another. The most pressing problem in this case is manually reconfiguring the communication channels of various application subsystems that are allocated into separate services. **Consul** solves this problem by performing *Service Discovery*, which automates the process of configuring communication channels.

## Chapter II

The result of the work must be a report with detailed descriptions of the implementation of each of the points with screenshots. The report is prepared as a markdown file in the `src` directory named `REPORT.MD`.

## Part 1. Remote node configuration via Ansible

In this chapter you will perform a remote node configuration to deploy a multiservice application.

### Task

1. Using Vagrant, create three machines: manager, node01, and node02. Do not install Docker using shell scripts when creating machines on Vagrant. Forward the Node 01 ports to the local machine to access the undeployed microservice application.

2. Prepare the manager machine for remote configuration using Ansible (help is included in the materials).
   - Go to the manager.
   - Check the connection to node01 via SSH on a private network.
   - Generate an SSH key to connect to node01 from the manager without a passphrase.
   - Copy the Docker Compose file and the microservice source code to the manager. Use the project from the src folder and the Docker Compose file from the previous chapter. Help on SSH is included in the materials.
   - Install Ansible on the manager and create an Ansible folder in which to create the inventory file.
   - Use the ping module to check the connection via Ansible.
   - Place the result of the module in a report.

3. Write the first Ansible playbook that performs an apt update, installs Docker and Docker Compose, copies the Compose file from the manager, and deploys the microservice application.

4. Run the prepared tests through Postman and ensure they are all successful. Show the test results in the report.

5. Form three roles:
   - The application role deploys a microservice application using Docker Compose;
   - Apache installs and runs the standard Apache server;
   - Postgres installs and runs Postgres, creates a database with an arbitrary table, and adds three arbitrary records to it.
   - Assign the first role to node01, and assign the second two roles to node02. Check the functionality of the microservice application using Postman tests. Make sure that PostgreSQL and the Apache server are available. For Apache, a web page should open in the browser. For PostgreSQL, connect from the local machine and display the contents of the previously created table with data.

6. Place the files created in this section into the `src\ansible01` folder in your personal repository.

## Part 2. Service Discovery

Now, let's move on to service discovery. In this chapter, you will simulate two remote services—an API and a database—and establish a connection between them using Consul's Service Discovery.

### Task

1. Write two configuration files for Consul (information on Consul can be found in the materials):
   - consul_server.hcl:
      - sets up the agent as a server;
      - specifies the interface directed to the internal Vagrant network in advertise_addr;
   - consul_client.hcl:
      - sets up the agent as a client;
      - specifies the interface directed to the internal Vagrant network in advertise_addr.

2. Create three machines using Vagrant: consul_server, api, manager, and db.
   - Forward port 8082 from the API to the local machine to access the still undeployed API.
   - Forward port 8500 with the consul_server to access the UI Consul.

3. Write a playbook for Ansible and four roles:
   - install_consul_server:
      - works with consul_server;
      - copies consul_server.hcl;
      - installs Consul and all necessary dependencies;
      - runs the Consul service.
   - install_consul_client:
      - works with the API and database;
      - copies consul_client.hcl;
      - installs Consul and Envoy, as well as all necessary dependencies for Consul;
      - runs the Consul and Consul-Envoy services.
   - install_db:
      - works with the database;
      - installs PostgreSQL and runs it;
      - creates the `hotels_db` database.
   - install_hotels_service:
      - works with the API;
      - copies the service source code;
      - installs `openjdk-21-jdk`.
      - creates global environment variables:
         - POSTGRES_HOST="127.0.0.1";
         - POSTGRES_PORT="5432";
         - POSTGRES_DB="hotels_db";
         - POSTGRES_USER="<user name>";
         - POSTGRES_PASSWORD="<user password>";
      - runs the built JAR file with the command: `java -jar <path to hotel-service>/hotel-service/target/<jar file name>.jar`.

4. Check the functionality of CRUD operations on the hotel service. Show the test results in the report.

5. Place the files created in this part in the `src\ansible02` and `src\consul01` folders in your personal repository.