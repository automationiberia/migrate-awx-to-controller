| [main document][main_doc] | [step-by-step document][step-by-step] | [next document][step_2] |
|:--:|:--:|:--:|

## 1. Customize the `superadmin` organization objects

The first settings to be configured are the credentials to reach the Ansible Automation Controller. This configuration is done at the following `ansible-vault`ed files:


> ```console
> $ cat group_vars/all/configure_connection_controller_credentials.yml
> ```
> ```yaml
> ---
> vault_controller_username: 'admin'
> # vault_controller_password: 'password' #Per environment
> vault_controller_validate_certs: false
> ...

> ```console
> $ cat group_vars/dev/configure_connection_controller_credentials.yml
> ```
> ```yaml
> ---
> vault_controller_password: 'password-dev'
> vault_controller_hostname: "{{ groups['dev'][0] }}"
> ...
> ```

The hostname is taken from the inventory used to run the configuragion playbook. In the code above, we are taking the first controller on group `dev`.

Other important files to be configured are in the following directories:

* `orgs_vars/superadmin/env/dev/controller_credentials.d`: Configuration files for the credentials used for the Job Templates to access Git repositories, Ansible Controller, Private Automation Hub, Machines and also the vault password to decrypt our vaulted-files. Following is an example a `Red Hat Ansible Automation Platform` credential:
  ```yaml
  ---
  controller_credentials:
    - name: "{{ orgs }} {{ env }} AAP Credential"
      description: "{{ orgs }} {{ env }} AAP Credential"
      credential_type: "Red Hat Ansible Automation Platform"
      organization: "{{ orgs }}"
      inputs:
        host: "{{ controller_hostname }}"
        username: "{{ controller_username }}"
        password: "{{ controller_password }}"
        verify_ssl: "{{ controller_validate_certs }}"
  ...
  ```
* `orgs_vars/superadmin/env/dev/controller_execution_environments.d`: Configuration files for the execution environments we are providing to both CasC Job Templates and current ones:
  ```yaml
  ---
  controller_execution_environments:
    - name: "EE-CASC"
      image: "{{ automation_hub_hostname }}/ee-casc:1.1"
      pull: "missing"
      credential: "{{ orgs }}-{{ env }}-PAH-Container-Registry"
  ...
  ```
* `orgs_vars/superadmin/env/dev/controller_instance_groups.d/controller_instance_groups.yml`: Configuration files for the instance groups to be generated:
  ```yaml
  ---
  controller_instance_groups:
    - name: INSTANCE_1
      instances:
        - controller.host.first.fqdn
        - controller.host.second.fqdn
    - name: INSTANCE_2
      instances:
        - 10.20.30.40
        - 10.20.30.41
  ...
  ```
* `orgs_vars/superadmin/env/dev/controller_settings.d`: Configuration files to control all the Controller settings. An example for the job related settings is shown below, and is stored at `orgs_vars/superadmin/env/dev/controller_settings.d/jobs/controller_settings_jobs.yml`:
  ```yaml
  ---
  controller_settings:
    - name: DEFAULT_PROJECT_UPDATE_TIMEOUT
      value: 0
    - name: DEFAULT_INVENTORY_UPDATE_TIMEOUT
      value: 0
    - name: DEFAULT_JOB_TIMEOUT
      value: 0
    - name: MAX_FORKS
      value: 200
  #   - name: AWX_ISOLATION_SHOW_PATHS
  #     value: "['/tmp', '/mnt/backup']"
  #   - name: AWX_TASK_ENV
  #     value:
  #       ENVIRONMENT_VAR1: "VAR1_VALUE"
  #       ENVIRONMENT_VAR2: "VAR2_VALUE"
  ...
  ```
* `orgs_vars/superadmin/env/common/controller_organizations.d`: Configuration files for the organizations to be created:
  ```yaml
  ---
  controller_organizations:
    - name: "superadmin"
      description: "Organization for objects that requiere superadmin powers"
      galaxy_credentials:
        - "{{ orgs }} {{ env }} Automation Hub Community Repository"
        - "{{ orgs }} {{ env }} Automation Hub Published Repository"
        - "{{ orgs }} {{ env }} Automation Hub RH Certified Repository"
  ...
  ```
* `orgs_vars/superadmin/env/common/controller_projects.d`: Configuration files for the projects to be defined into our organization:
  ```yaml
  ---
  controller_projects:
    - name: "{{ orgs }} CasC Data"
      description: "Project to include the CasC playbooks"
      organization: "{{ orgs }}"
      scm_type: git
      scm_url: "git@github.com:automationiberia/controller-casc-cd.git"
      scm_credential: "{{ orgs }} {{ env }} GitLab Credential"
      scm_branch: "{{ casc_gitlab_scm_branch | default(env) }}"
      scm_clean: false
      scm_delete_on_update: false
      scm_update_on_launch: false
      scm_update_cache_timeout: 86400
      allow_override: true

    - name: "{{ orgs }}-CASC-GitLab-Webhook"
      description: "Project to include playbooks to configure the GitLab Webhooks for the CasC to be able to run"
      organization: "{{ orgs }}"
      scm_url: "git@github.com:automationiberia/casc_setup.git"
      scm_credential: "{{ orgs }} {{ env }} GitLab Credential"
      scm_branch: main
      scm_clean: false
      scm_delete_on_update: false
      scm_update_on_launch: false
      scm_update_cache_timeout: 86400
      allow_override: true
  ...
  ```
* `orgs_vars/superadmin/env/common/controller_job_templates.d`: Configuration files for the Job Templates to be created:
  ```yaml
  ---
  controller_templates:
    - name: "{{ orgs }} CasC Ctrl Config"
      description: "Template to deploy Controller objects in Org {{ orgs }}"
      organization: "{{ orgs }}"
      project: "{{ orgs }} CasC Data"
      inventory: "{{ orgs }} Controller"
      playbook: "casc_ctrl_config.yml"
      job_type: run
      fact_caching_enabled: false
      credentials:
        - "{{ orgs }} {{ env }} AAP Credential"
        - "{{ orgs }} {{ env }} Vault Credential"
      concurrent_jobs_enabled: true
      ask_scm_branch_on_launch: true
      ask_tags_on_launch: true
      ask_verbosity_on_launch: true
      ask_variables_on_launch: true
      extra_vars:
        ansible_python_interpreter: /usr/bin/python3
        ansible_async_dir: /home/runner/.ansible_async/
      execution_environment: "ee-casc"
    - name: "{{ orgs }} CasC Ctrl Config"
      description: "Template to deploy Controller objects in Org {{ orgs }}"
      organization: "{{ orgs }}"
      project: "{{ orgs }} CasC Data"
      inventory: "{{ orgs }} Controller"
      playbook: "casc_ctrl_config_unified.yml"
      job_type: run
      fact_caching_enabled: false
      credentials:
        - "{{ orgs }} {{ env }} AAP Credential"
        - "{{ orgs }} {{ env }} Vault Credential"
      concurrent_jobs_enabled: true
      ask_scm_branch_on_launch: true
      ask_tags_on_launch: true
      ask_verbosity_on_launch: true
      ask_variables_on_launch: true
      extra_vars:
        ansible_python_interpreter: /usr/bin/python3
        ansible_async_dir: /home/runner/.ansible_async/
      execution_environment: "ee-casc"
  ...
  ```
* `orgs_vars/superadmin/env/common/controller_roles.d`: Configuration files to create the needed roles for the different object types:
  ```yaml
  ---
  controller_roles:
    - user: "user1"
      organizations:
        - "casc_org1"
      role: admin
    - user: "user2"
      organizations:
        - "casc_org2"
      role: admin
  ...
  ```

| [main document][main_doc] | [step-by-step document][step-by-step] | [next document][step_2] |
|:--:|:--:|:--:|

[main_doc]: README.md
[step-by-step]: README_step_by_step.md
[step_2]: README_step_2.md
