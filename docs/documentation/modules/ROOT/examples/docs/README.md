
# superadmin

One of the main reasons to adopt Configuration as Code (CasC) is the flexibility that it brings, which allow to replicate the configuration between environments, sites or where ever you need. Most customers normally use database replication to copy the data from one environment to another, and importing that data to another Ansible Automation Platform site, but that approach could have many downsides like more dedicated infrastructure, specialized teams to handle it and pretty complex procedures to switching the active site, that might affect the consistency across multiple environments or sites.

## But, how to fit Automation Controller and CasC?
There are a lot of approach to do it, but there already are ansible collections that provide what is necessary to carry out this implementation. Let's check the below diagram:

Red Hat Communities of Practice Controller Configuration Collection
----------
![Alt text](images/collections_used.png?raw=true "Red Hat Communities of Practice Controller Configuration Collection")

The basis to configure an Automation Controller through a Configuration as Code approach relies in two ansible collections:

* **AWX / Ansible.Controller**: which is a collection that brings together all the modules and Ansible content related to the management of the AWX/Controller. It provides modules to connect and manage all objects of the AWX/Controller, however it does not have functionalities to use it in a scalable way.

* **infra.controller_configuration**: This collection provides a whole layer of functionalities on top of the AWX / Ansible.Controller base collection. It basically implements these modules, adding flexibility to work in a scalable way to manage the AWX/Controller. The most outstanding features are:
  - It is possible to work with lists of objects in yaml format, which do not need to perform any loop when using them, just call the role within the collection.
  - It is possible to consume the configuration from custom sources, that is, it is possible to have the configuration from a custom directory structure.
  - Role to export objects in yaml format to be consumed.
  - Compare existing objects in the API with a list, which can be obtained from information in a git repository.
  - The ansible roles used from this collection to create the continuous deployment flow are the following:
    * __filetree_read__: An ansible role which reads variables from a hierarchical and scalable directory structure which is grouped based on the configuration code life-cycle. It could be used to run the role filetree_read to load variables followed by dispatch role to apply the configuration.
    * __filetree_create__: The role filetree_create is intended to be used as the first step to begin using the Configuration as Code on Ansible Tower or Ansible Automation Controller, when you already have a running instance of any of them. Obviously, you could also start to write your objects as code from scratch, but the idea behind the creation of that role is to simplify your lives and make that task a little bit easier.
    * __object_diff__: An ansible role to manage the object diff of the AWX or Automation Controller configuration. This role leverages the controller_object_diff.py lookup plugin of the infra.controller_configuration, comparing two lists, one taken directly from the API and the other one from the git repository, and it could be used to delete objects in the AWX or Automation Controller that are not defined in the git repository list.
    * __dispatch__: An Ansible Role to run all roles on Ansible Controller.

## How to organize it to be scalable and flexible?

### Repository Organization  Structure for CasC

The first thing that needs to be defined, should be where the configuration will be stored and how it will be retrieved. This is very important because the whole configuration of the automation tool should be accessible but at the same time we must protect the sensitive data.

Having said that, the following questions must be answered:

- Where should be stored?
  - As configuration must be versioned and inmutable, git repositories are perfect for it. Also it could be leveraged of git features, practices and methodologies to be applied in the configuration, that must start treat it as Code.
- How to structure it?
  - A directory structure will provide flexibility and scalability to organize in a logical manner the configuration.
- How do we handle sensitive data?
  - Ansible Vault will provide the encryption layer needed to protect sensitive data.

It is recommended to create one git repository per organization, but the solution allows to have more than one organization per repository in case needed. However, it is strongly recommended to have just one super admin organization to manage objects that should only have access a privileged group of users, who must have the right Ansible Automation Platform expertise to handle the configuration.

To handle the environments it could leverage branches git features, as it can be seen in the below diagram, each repository must have a branch that must match the environment to which it belongs.

![Alt text](images/repository_structure.png?raw=true "Repository Organization Structure for CasC")

The directory structure is created to match up objects by environment to be able to reuse them and avoid the principle of software development don't repeat yourself (DRY). But there are objects that are unique and must be differentiated. As said before,   the configuration should start treating as Code or a piece of software, that is why it could be leverage software development techniques, or even use variables.The following diagram explains graphically how it could be organized.

![Alt text](images/directory_structure.png?raw=true "Directory Structure for CasC")

The directory structure along the git features will help to promote the configuration between environments, it could be done through branches committing, tagging and creating pull or merge request to specific environment. This provide the long awaited consistency across multiple Ansible Automation Controllers deployments, allowing to have the same configuration in all environments with the differences that could exist between them, such as credentials, hosts, etc.

## How does the flow between Automation Controller and CasC work?

![Alt text](images/CasC_Flow.png?raw=true "CasC Flow")

1. The flow starts when configuration files are modified or added to an Organization git repository in the Development branch.
2. An event is generated in the SCM when a commit has been made and the changes has been uploaded to the git repository.
3. The git event has been send through a git webhook payload, with all the information related to the commit: Files and its path that were add, modified or deleted, organization from where the changes has been made, etc.
4. A Workflow Job Template is being used to capture the data that has been sent from the git webhook payload and execute two tasks:
  - Project sync, which will do a git clone, and depending on whether it needs to download any collections or roles that it doesn't have in the execution environment, it will do so at this point.
  - The data sent through the payload is processed and converted into yaml/json format to be added as Extra Vars in the Job_Template object.
  - These variables will be used to perform actions on a Controller object. used with a Job Template object which calls another two Job Templates that contains the playbook to perform actions on the Controller objects.

To Continuously reconciled, a schedule object type is used to observe actual configuration state (objects list from API) and to attempt to apply the desired configuration (Objects list from the git repository).

![Alt text](images/CasC_Flow_Chart.png?raw=true "CasC Flow Chart")

## How to manage Ansible Automation Controller life cycle configuration?

As said before, git approach, methodologies and features are the bare bone of this implementation, to manage the life cycle of the Automation Controller configuration  will be carried out through a basic Git flow but adapted to configuration.

The main idea is always create temporary branches from the development branch to add, modify or delete controller's configuration, and once it is tested it could be promoted to the following environments .

As it could be seen in the below diagram, start on Day Zero creating a temporary branch where it will be added the basic objects to start applying the configuration in the controller. These objects are: projects, credentials, job_templates, workflow_job_templates, inventories, hosts.


![Alt text](images/CasC_Life_Cycle.png?raw=true "CasC Life Cycle")

Once the configuration is applied and tested in development environment, it could be promoted the configuration, basically the code from the development branch to the next environment until it reaches production.

The main idea of the flow would be test everything in previous environments before applying it in a productive environment, to avoid errors that lead to loss of service, platform instability, inconsistency, etc.

In case need it, Git features could be leveraged to rollback a configuration to a specific point in time, or in this case a specific release. Git features Tags / Releases will be used to create in the productive branch a "Snapshot" of the moment in which our configuration is safe to promote it to production. In such case that a failure/bug arise in our code/configuration, it could simply be used Tags/Releases, to rollback to that point where the configuration works correctly.

## How does it work in a Multi site Active-Passive Architecture?

![Alt text](images/multisite_arch_variables.png?raw=true "CasC Multi Site architecture variables needed")

##  Configuration as Code normally use the API to configure an application or software, so the connection of the ansible modules is not made directly against the host that we want to configure, but locally and then the module makes the call to the host serving that API.

In a Multi site Active / Passive architecture, it must be considered where the automation are being executed, so depending on the site whether it is active or passive, it could be changed the behavior of the Controller objects through variables.

To manage it, it has been proposed the use of variables to hook up where the execution is being done and to determine which is the active site:

  - __**Environment variable in the Execution Environment**__: which is used to determine where the execution has been carried out. As we are working with containers, this variable will be immutable allows us to anchor that variable to the site from where execution is performed.
  - __**Variable to determine which is the active site**__: This variable can be obtained from several places. In the diagram above, it is described two scenarios that have been tested. The objects where this variable could be added are:
    - __Controller Objects__: In this scenario, the variable will be retrieve from the git repository in the superadmin organization, so a team with superpowers will control which will be the active site.
    - __Inventory__: The variable could be added in the Inventory and permissions can be given to the organizations that will consume the CasC.
    - __Settings__: It is possible to add it in the Extra vars of the jobs in the settings, to have it globally and to be used by all organizations.
    - __Load Balancer Header__: As a key element of the AAP  active/passive architecture and as a third actor of the equation APP arch = (Automation Controller + git repository + LB), it makes sense to add the value of that variable as header in the Load Balancer configuration to reduce the single point of failures and steps in case of maintenance or Disaster Recovery actions, where it should be redirected requests to switch sites and another step is added  which is set the header with the value of the active site. To get the value it is done it in the corresponding flow playbooks to change the behavior when apply/modify/delete Controller's objects.

## How to configure automatic triggering automation in a Multisite Active-Passive Architecture?

In an active/passive architecture automation executions must be carried out only from one site, but not always.  Let's get deeper on this, analyzing the below diagram.

![Alt text](images/multisite_arch_webhooks.png?raw=true "CasC Multi Site architecture webhook configuration")

Basically there are two approach that it should be considered when a active/passive scenario comes in:

  - __**CasC Automation**__:in this scenario the automation must executed in both sites, so we are talking about an Active/Active scenario since its main function is to replicate the configuration between sites. In this approach two important considerations must be highlight:
    - __Different Objects values depending on site where should be applied__. For instance, Objects like execution environments that should point to different Automation Hub depending on the site, or credentials,  with the specific case of the automation hub which generates a token that cannot be duplicated.
    - __Webhooks__: To automatically trigger the creation, modification or deletion of objects in the controller, webhooks has been used and it must be configured one per environment and per site, pointing to the controller load balancer based in each site, so the configuration will be applied to both sites when is triggered.

  - __**Automation ONLY Active Site**__:This will be everything that is not CasC, so it must be run on the active site.
    - __Webhooks__: In case webhooks are needed to automatically trigger jobs in the controller, in this scenario webhooks must be configured pointing to the global Load Balancer to avoid that the job is triggered and executed only affects the active site without triggering in the passive.
    - __Controller objects__: to control the behavior of the objects that need to be active only in the active site, such as schedules or pretasks in playbooks in an active/passive architecture, a logic must be added in addition to the use of variables to achieve the expected  behavior.

## Send emails to the new Organization's admins

```
$ ansible-playbook mailing.yml
```

# Step-by-step configuration
To have a more detailed process, take a look at the [Step-by-step configuration][step-by-step]

[step-by-step]: ./README_step_by_step.md
