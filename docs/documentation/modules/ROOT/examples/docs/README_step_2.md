| [previous document][step_1] | [main document][main_doc] | [step-by-step document][step-by-step] | [next document][step_3] |
|:--:|:--:|:--:|:--:|

## 2. Day-0: Deploy the SUPERADMIN organization

Once all the objects are already configured, they can be populated for the first time into the configured Automation Controller.

### 2.1. Run the configuration playbook to create the defined objects in AAP

Run the following command:

```bash
$ ansible-navigator run casc_ctrl_config.yml -i inventory -l dev -e '{orgs: superadmin, dir_orgs_vars: orgs_vars, env: dev}' -m stdout --eei quay.io/automationiberia/aap/ee-casc:latest --vault-password-file .vault_password --pull-arguments=--tls-verify=false
```

> TIP: The file `.vault_password` used in the previous command, must exist and contain the vault password needed to access the vaulted variables

> TIP: The file `inventory` must be filled accordingly to the corresponding `group_vars` configuration file to reach the correct Automation Controller instance

> TIP: The Execution Environment used in the previous command must exist and must provide all the needed collections, listed at the file `collections/requirements.yaml`:
> ```yaml
> ---
> collections:
>   - name: infra.controller_configuration
> ...
> ```

### 2.2. Configure the GitLab Webhooks

Once the objects has been created at the Ansible Automation Controller, there are two options to configure the GitLab Webhook to run the Continuous Integration for the CasC:

#### 2.2.1. Manually

Following steps must be performed to configure the GitLab Webhook to run the Continuous Integration for the CasC in the specified organization:

1. Get the Job Template's webhook configuration:

   | ![Configure Webhook Get Config][configure_webhook_get_config] |
   |:--:|
   | **Fig. 2.2.1.1. Configure Webhook Get Config** |

   > IMPORTANT: The Url displayed in the (Workflow) Job Template configuration is using the ID to identify the (Workflow) Job Template, but it's not recommended to use this identifier, as it can change if the configuration is replied at different AAP instances. Instead, the `named_url` from the API may be used.
   > | ![Configure Webhook Named URL][configure_webhook_named_url] |
   > |:--:|
   > | **Fig. 2.2.1.2. Configure Webhook Named URL** |

2. Set the webhook information at the GitLab repository:

   | ![Configure Webhook Set Info][configure_webhook_set_info] |
   |:--:|
   | **Fig. 2.2.1.3. Configure webhook Set Info** |

#### 2.2.2. Automatically

A Job Template and a Project have been created to automatically configure the GitLab Webhook making use of the `GitLab API Token` credential defined and vaulted in the configuration files (take a look at [`orgs_vars/superadmin/env/dev/controller_credentials.d/controller_credentials_gitlab_api_token.yml`](orgs_vars/superadmin/env/dev/controller_credentials.d/controller_credentials_gitlab_api_token.yml)):

| ![Configure Webhook Launch][configure_webhook_launch] |
|:--:|
| **Fig. 2.2.2.1. Configure Webhook Launch** |

| ![Configure Webhook Params][configure_webhook_params] |
|:--:|
| **Fig. 2.2.2.2. Configure Webhook Params** |

After running the Job, the webhook will already be configured at the git repository for the specified organization, which will point to the selected Job Template in the selected Automation Controller.

| ![Configure Webhook Result][configure_webhook_result] |
|:--:|
| **Fig. 2.2.2.3. Configure Webhook Result** |

| [previous document][step_1] | [main document][main_doc] | [step-by-step document][step-by-step] | [next document][step_3] |
|:--:|:--:|:--:|:--:|

[configure_webhook_get_config]: images/configure_webhook_get_config.png
[configure_webhook_named_url]: images/configure_webhook_named_url.png
[configure_webhook_set_info]: images/configure_webhook_set_info.png
[configure_webhook_launch]: images/configure_webhook_launch.png
[configure_webhook_params]: images/configure_webhook_launch_params.png
[configure_webhook_result]: images/configure_webhook_result.png

[step_1]: README_step_1.md
[main_doc]: README.md
[step-by-step]: README_step_by_step.md
[step_3]: README_step_3.md

