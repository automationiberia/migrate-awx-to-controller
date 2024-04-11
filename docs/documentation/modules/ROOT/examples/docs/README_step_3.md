| [previous document][step_2] | [main document][main_doc] | [step-by-step document][step-by-step] |
|:--:|:--:|:--:|

## 3. Day-2: Create a new Organization

As an overview, when creating a new Organization, some objects must be populated at the SUPERADMIN organization, such as the organization itself, the corresponding CasC Job Templates, the user to be the future organization admin and the roles to give that user the admin privileges to the organization. A new Git Repository is needed for the new Organization as well.

> IMPORTANT: To create the new objects, a new git branch is needed, as the branches used to deploy the CasC to the different environments are protected, doesn't accept direct pushes and only accept merges through Pull Requests.

### 3.1. Run the playbook to create the new organization objects

These new objects can be created manually without any problem, but a playbook is provided to make this easier. It must be executed from the command line (PR are welcome), and is creating all the files with the new objects for us, except the one for the organization's admin user.

To create the new objects, just run the following command:

```console
$ ansible-playbook new_project.yml -e '{organization_name: NewOrg, organization_desc: "NewOrg Organization", instance_groups: [MADRID], admin_user: "neworgadminuser", orgs_vars: "orgs_vars", orgs: SUPERADMIN, env: PRE, casc_gitlab_scm_branch: centralize_casc}'
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] *****************************************************************************************************************************************************************************************************************************

TASK [Assert that the required input variables are defined] **********************************************************************************************************************************************************************************
ok: [localhost] => (item=Check the required variable organization_name is defined)
ok: [localhost] => (item=Check the required variable organization_desc is defined)
ok: [localhost] => (item=Check the required variable instance_groups is defined)
ok: [localhost] => (item=Check the required variable admin_user is defined)

TASK [Create all the required objects] *******************************************************************************************************************************************************************************************************
changed: [localhost] => (item=Creating the file orgs_vars/SUPERADMIN/env/common/controller_organizations.d/NewOrg.yml)
changed: [localhost] => (item=Creating the file orgs_vars/SUPERADMIN/env/common/controller_projects.d/NewOrg_casc.yml)
changed: [localhost] => (item=Creating the file orgs_vars/SUPERADMIN/env/common/controller_job_templates.d/NewOrg_casc.yml)
changed: [localhost] => (item=Creating the file orgs_vars/SUPERADMIN/env/PRE/controller_credentials.d/NewOrg_casc.yml)
changed: [localhost] => (item=Creating the file orgs_vars/SUPERADMIN/env/common/controller_roles.d/NewOrg.yml)

TASK [Show manual steps] *********************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "Remember to:",
        "  - Add the user neworgadminuser manually at orgs_vars/SUPERADMIN/env/PRE/controller_users.d/controller_user_accounts.yml"
    ]
}

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

> NOTE: This playbook can also be executed with `ansible-navigator` inside an Execution Environment.

### 3.2. Add the admin user for the new organization

In order to add the new Organization's admin user, it must be done manually as the file should be ansible-vaulted, so the following steps are needed:

* Add a new entry at the controller_user_accounts.yml file (it can also be a new one) into the desired environment (PRE in the example):

  ```console
  $ ansible-vault edit orgs_vars/SUPERADMIN/env/PRE/controller_users.d/controller_user_accounts.yml
  Vault password:
  ```
  ```yaml
  ---
  controller_user_accounts:
    - username: "admin"
      password: "SuperadminPassword"
      email: "superadmin@example.com"
      firstname: "superadmin"
      lastname: "superadmin"
      is_auditor: False
      is_superuser: True
      update_secrets: False
    - username: "neworgadminuser"
      password: "NewUserPassword"
      email: "neworgadminuser@example.com"
      firstname: "neworgadminuser"
      lastname: "neworgadminuser"
      is_auditor: False
      is_superuser: False
      update_secrets: False
  ```

### 3.3. Push the changes to create the new objects

As the SUPERADMIN organization already have the Webhook configured, the only action needed to create the new objects is just to push the code to the git repository for the Webhook to trigger the CasC processes:

```console
$ git commit -m "New Organization"; git push
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/PRE/controller_credentials.d/NewOrg_casc.yml updated
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/PRE/controller_users.d/controller_user_accounts.yml updated
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/common/controller_job_templates.d/NewOrg_casc.yml updated
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/common/controller_organizations.d/NewOrg.yml updated
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/common/controller_projects.d/NewOrg_casc.yml updated
[centralize_casc e5fd56e] orgs_vars/SUPERADMIN/env/common/controller_roles.d/NewOrg.yml updated
 6 file changed, 83 insertions(+), 3 deletions(-)
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 12 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 1.00 KiB | 1.00 MiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote:
remote: To create a merge request for centralize_casc, visit:
remote:   https://gitlab.server.domain/group/sub-group/casc/super-admin/-/merge_requests/new?merge_request%5Bsource_branch%5D=centralize_casc
remote:
To ssh://gitlab.server.domain:2222/group/sub-group/casc/super-admin.git
   ad54fd5..e5fd56e  centralize_casc -> centralize_casc
```

Now, the branch can be merged into PRE to trigger the CasC mechanism and get all the new objects created at the Automation Controller.

### 3.4. Run the Job Template to create a new Git Project for the newly created organization

Another thing that should be created is a git repository where to define all the new organization's related objects. That git repo can be created manually, but a Job Template for the SUPERADMIN organization is provided to make things easier. That Job template is creating (thanks to the `casc-setup` collection into the assigned Execuction Environment) all the basic objects and a `README.md` that contains a step by step process to start working with the repo and the CasC, so it's very recommended to use that Job Template:

| ![GitLab Project Creation Job Template][gitlab_project_creation_jt] |
|:--:|
| **Fig. 3.4.1. Gitlab Project Creation Job Template** |

| ![GitLab Project Creation Launch][gitlab_project_creation_launch] |
|:--:|
| **Fig. 3.4.2. Gitlab Project Creation Launch** |

| ![GitLab Project Creation README Snap][gitlab_project_creation_readme_snap] |
|:--:|
| **Fig. 3.4.3. Gitlab Project Creation README Snap** |


### 3.5. Run the Job Template to create the CasC Webhook for the newly created organization

The same way the CasC is triggered for the SUPERADMIN organization, for the newly created one a webhook must be created as well. That one is slightly different on how the playbook treats the input information, but is running the same overall process to launch the CasC processes.

The configuration is almost the same shown at [2.2. Configure the GitLab Webhooks
][22-configure-the-gitlab-webhooks], but the organization name and the Job Template that is executed from the webhook, will be different:

| ![Configure Webhook for the new organization][configure_webhook_neworg_params] |
|:--:|
| **Fig. 3.5.1. Configure Webhook for the NewOrg Organization** |

| [previous document][step_2] | [main document][main_doc] | [step-by-step document][step-by-step] |
|:--:|:--:|:--:|

[gitlab_project_creation_jt]: images/gitlab_project_creation_jt.png
[gitlab_project_creation_launch]: images/gitlab_project_creation_launch.png
[gitlab_project_creation_readme_snap]: images/gitlab_project_creation_readme_snap.png
[configure_webhook_neworg_params]: images/configure_webhook_neworg_launch_params.png

[22-configure-the-gitlab-webhooks]: README_step_2.md#22-configure-the-gitlab-webhooks

[step_2]: README_step_2.md
[main_doc]: README.md
[step-by-step]: README_step_by_step.md
