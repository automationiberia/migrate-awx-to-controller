#!/usr/bin/env bash

VARS_REQUIRED=(PROJECT_URL_CASC_SETUP CONTROLLER_DEV_HOST CONTROLLER_PRO_HOST SUPERADMIN_ORG PROJECT_URL_CASC SSH_PRIVATE_KEY_FILE GITLAB_USERNAME GITLAB_API_TOKEN GITLAB_EMAIL VAULT_PASSWORD AAP_USER_NAME AAP_USER_PASSWORD AAP_USER_EMAIL AAP_USER_FIRSTNAME AAP_USER_LASTNAME ADMIN_DEV_PASSWORD ADMIN_PRO_PASSWORD)

for var in ${VARS_REQUIRED[@]}; do
  if [ "${!var:-UNDEFINED}" == "UNDEFINED" ]; then
    echo "ERROR: The variable ${var} must be defined. All the needed variables follows:"
    echo ""
    echo "  ${VARS_REQUIRED[@]}"
    echo ""
    echo "Please, export all the required environment variables."
    exit 1
  fi
done

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/controller_credentials_aap.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} AAP Credential"
    description: "{{ orgs }} {{ env }}  AAP Credential"
    credential_type: "Red Hat Ansible Automation Platform"
    organization: "{{ orgs }}"
    inputs:
      host: "{{ controller_hostname }}"
      username: "{{ controller_username }}"
      password: "{{ controller_password }}"
      verify_ssl: "{{ controller_validate_certs }}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/controller_credentials_scm.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} GitLab Credential"
    description: "Credential to be used by the 'IaC_playbooks' project"
    credential_type: "Source Control"
    organization: "{{ orgs }}"
    inputs:
      username: "${GITLAB_USERNAME}"
      ssh_key_data: |
$(cat ${SSH_PRIVATE_KEY_FILE} | while read line; do echo "        ${line}"; done)
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/controller_credentials_gitlab_api_token.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} GitLab API Token"
    description: "{{ orgs }} {{ env }} GitLab API Token"
    credential_type: "GitLab API Token"
    organization: "{{ orgs }}"
    inputs:
      gitlab_token: "${GITLAB_API_TOKEN}"
      gitlab_email: "${GITLAB_EMAIL}"
      gitlab_user: "${GITLAB_USERNAME}"
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/{controller_credentials_scm.yml,controller_credentials_gitlab_api_token.yml}

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/controller_credentials_vault.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} Vault Credential"
    description: "{{ orgs }} {{ env }} Vault Credential"
    credential_type: "Vault"
    organization: "{{ orgs }}"
    inputs:
      vault_password: "${VAULT_PASSWORD}"
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_credentials.d/controller_credentials_vault.yml

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_execution_environments.d/app-casc/controller_execution_environments_ee-casc.yml <<EOF
---
controller_execution_environments:
  - name: "ee-casc"
    image: "quay.io/automationiberia/aap/ee-casc:latest"
    pull: missing
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_hosts.d/app-casc/controller_hosts.yml <<EOF
---
controller_hosts:
  - name:  "${CONTROLLER_DEV_HOST}"
    description: "Controller host"
    inventory: "{{ orgs }} {{ env }} Controller"
    enabled: true
    variables:
      ansible_host: "${CONTROLLER_DEV_HOST}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_users.d/controller_user_accounts.yml <<EOF
---
controller_user_accounts:
  - username: "${AAP_USER_NAME}"
    password: "${AAP_USER_PASSWORD}"
    email: "${AAP_USER_EMAIL}"
    firstname: "${AAP_USER_FIRSTNAME}"
    lastname: "${AAP_USER_LASTNAME}"
    is_auditor: False
    is_superuser: True
    update_secrets: False
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/dev/controller_users.d/controller_user_accounts.yml

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/controller_credentials_aap.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} AAP Credential"
    description: "{{ orgs }} {{ env }}  AAP Credential"
    credential_type: "Red Hat Ansible Automation Platform"
    organization: "{{ orgs }}"
    inputs:
      host: "{{ controller_hostname }}"
      username: "{{ controller_username }}"
      password: "{{ controller_password }}"
      verify_ssl: "{{ controller_validate_certs }}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/controller_credentials_scm.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} GitLab Credential"
    description: "Credential to be used by the 'IaC_playbooks' project"
    credential_type: "Source Control"
    organization: "{{ orgs }}"
    inputs:
      username: "${GITLAB_USERNAME}"
      ssh_key_data: |
$(cat ${SSH_PRIVATE_KEY_FILE} | while read line; do echo "        ${line}"; done)
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/controller_credentials_gitlab_api_token.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} GitLab API Token"
    description: "{{ orgs }} {{ env }} GitLab API Token"
    credential_type: "GitLab API Token"
    organization: "{{ orgs }}"
    inputs:
      gitlab_token: "${GITLAB_API_TOKEN}"
      gitlab_email: "${GITLAB_EMAIL}"
      gitlab_user: "${GITLAB_USERNAME}"
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/{controller_credentials_scm.yml,controller_credentials_gitlab_api_token.yml}

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/controller_credentials_vault.yml <<EOF
---
controller_credentials:
  - name: "{{ orgs }} {{ env }} Vault Credential"
    description: "{{ orgs }} {{ env }} Vault Credential"
    credential_type: "Vault"
    organization: "{{ orgs }}"
    inputs:
      vault_password: "${VAULT_PASSWORD}"
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_credentials.d/controller_credentials_vault.yml

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_execution_environments.d/app-casc/controller_execution_environments_ee-casc.yml <<EOF
---
controller_execution_environments:
  - name: "ee-casc"
    image: "quay.io/automationiberia/aap/ee-casc:latest"
    pull: missing
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_hosts.d/app-casc/controller_hosts.yml <<EOF
---
controller_hosts:
  - name:  "${CONTROLLER_PRO_HOST}"
    description: "Controller host"
    inventory: "{{ orgs }} {{ env }} Controller"
    enabled: true
    variables:
      ansible_host: "${CONTROLLER_PRO_HOST}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_users.d/controller_user_accounts.yml <<EOF
---
controller_user_accounts:
  - username: "${AAP_USER_NAME}"
    password: "${AAP_USER_PASSWORD}"
    email: "${AAP_USER_EMAIL}"
    firstname: "${AAP_USER_FIRSTNAME}"
    lastname: "${AAP_USER_LASTNAME}"
    is_auditor: False
    is_superuser: True
    update_secrets: False
...
EOF

ansible-vault encrypt --vault-password-file .vault_password orgs_vars/${SUPERADMIN_ORG}/env/pro/controller_users.d/controller_user_accounts.yml

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_credential_types.d/app-casc/controller_credential_types_gitlab_api.yml <<EOF
---
controller_credential_types:
  - name: "GitLab API Token"
    kind: "cloud"
    state: present
    inputs:
      fields:
        - id: "gitlab_token"
          help_text: "gitlab API token"
          label: "API Token"
          type: "string"
          secret: true
        - id: "gitlab_user"
          help_text: "gitlab API user"
          label: "API User"
          type: "string"
        - id: "gitlab_email"
          help_text: "gitlab API user email"
          label: "API User email"
          type: "string"
        - id: "gitlab_verify"
          label: "Verify SSL Certificates"
          type: "boolean"
          default: false
      required:
        - "gitlab_token"
        - "gitlab_user"
        - "gitlab_email"
    injectors:
      extra_vars:
        gitlab_api_token: !unsafe '{{ gitlab_token }}'
        gitlab_api_user: !unsafe '{{ gitlab_user }}'
        gitlab_api_user_mail: !unsafe '{{ gitlab_email }}'
        gitlab_validate_certs: !unsafe '{{ gitlab_verify }}'
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_inventories.d/app-casc/controller_inventories_controller.yml <<EOF
---
controller_inventories:
  - name: "{{ orgs }} {{ env }} Controller"
    description: "Inventory for the Controller"
    organization: "{{ orgs }}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_groups.d/app-casc/controller_groups.yml <<EOF
---
controller_groups:
  - name: "{{ env }}"
    inventory: "{{ orgs }} {{ env }} Controller"
    hosts: "{{ groups[env] }}"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/app-casc/controller_jt_casc_cd_webhook.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} CasC Ctrl CD Webhook Trigger"
    description: "Template to attend Controller CasC webhook"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC Data"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "casc_ctrl_cd_webhook_trigger.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} AAP Credential"
      - "{{ orgs }} {{ env }} Vault Credential"
    concurrent_jobs_enabled: true
    webhook_service: "gitlab"
    ask_scm_branch_on_launch: true
    extra_vars:
      ansible_python_interpreter: /usr/bin/python3
      ansible_async_dir: /home/runner/.ansible_async/
    execution_environment: "ee-casc"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/app-casc/controller_jt_casc_config.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} CasC Ctrl Config"
    description: "Template to deploy Controller objects in Org {{ orgs }}"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC Data"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "casc_ctrl_config.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} AAP Credential"
      - "{{ orgs }} {{ env }} Vault Credential"
      - "{{ orgs }} {{ env }} GitLab API Token"
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
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/app-casc/controller_jt_casc_drop_diff.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} CasC Ctrl Drop Diff"
    description: "Template to assure no difference between API and repository"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC Data"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "casc_ctrl_drop_diff.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} AAP Credential"
      - "{{ orgs }} {{ env }} Vault Credential"
      - "{{ orgs }} {{ env }} GitLab API Token"
    concurrent_jobs_enabled: true
    ask_scm_branch_on_launch: true
    ask_tags_on_launch: true
    ask_verbosity_on_launch: true
    ask_variables_on_launch: true
    extra_vars:
      ansible_python_interpreter: /usr/bin/python3
      ansible_async_dir: /home/runner/.ansible_async/
      protect_not_empty_orgs: true
    execution_environment: "ee-casc"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/app-gitlab/controller_jt_casc_gitlab_project_creation.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} Gitlab Project Creation"
    description: "Template to create projet in gitlab"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC GitLab Webhook"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "playbooks/gitlab_setup.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} GitLab API Token"
    concurrent_jobs_enabled: true
    extra_vars:
      ansible_python_interpreter: /usr/bin/python3
      ansible_async_dir: /home/runner/.ansible_async/
      gitlab_branches: !unsafe "{{ gitlab_branches_string.split('\n') }}"
    execution_environment: "ee-casc"
    survey_enabled: True
    survey_spec:
      name: '{{ orgs }} {{ env }} Survey_Gitlab_Project_Creation'
      description: 'Survey_Gitlab_Project_Creation'
      spec:
        - question_name: controller_dev
          required: true
          type: multiplechoice
          variable: controller_dev
          min: 0
          max: 1024
          choices:
            - "${CONTROLLER_DEV_HOST}"
          default: "${CONTROLLER_DEV_HOST}"
          new_question: true

        - question_name: controller_pro
          required: true
          type: multiplechoice
          variable: controller_pro
          min: 0
          max: 1024
          choices:
            - "${CONTROLLER_PRO_HOST}"
          default: "${CONTROLLER_PRO_HOST}"
          new_question: true

        - question_name: gitlab_api_url
          required: true
          type: multiplechoice
          variable: gitlab_api_url
          min: 0
          max: 1024
          choices:
            - "https://gitlab.com"
          default: "https://gitlab.com"
          new_question: true

        - question_name: gitlab_group
          required: false
          type: text
          variable: gitlab_group
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: gitlab_subgroup
          required: false
          type: text
          variable: gitlab_subgroup
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: "gitlab_project"
          required: true
          type: text
          variable: "gitlab_project"
          min: 0
          max: 80
          new_question: true

        - question_name: gitlab_visibility
          required: true
          type: multiplechoice
          variable: gitlab_visibility
          min: 0
          max: 1024
          choices:
            - "internal"
            - "public"
          default: "public"
          new_question: true

        - question_name: gitlab_default_branch
          required: true
          type: multiplechoice
          variable: gitlab_default_branch
          min: 0
          max: 1024
          choices:
            - "pro"
          default: "pro"
          new_question: true

        - question_name: gitlab_http_protocol
          required: true
          type: multiplechoice
          variable: gitlab_http_protocol
          min: 0
          max: 1024
          choices:
            - "https"
            - "http"
          default: "https"
          new_question: true

        - question_name: gitlab_branches_string
          required: true
          type: textarea
          variable: gitlab_branches_string
          min: 0
          max: 1024
          default: "dev\npro"
          new_question: true
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/app-gitlab/controller_jt_casc_gitlab_webhook.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} Gitlab Webhook Creation"
    description: "Template to create webhook in the gitlab project"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC GitLab Webhook"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "playbooks/gitlab_webhook.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} AAP Credential"
      - "{{ orgs }} {{ env }} GitLab API Token"
    concurrent_jobs_enabled: true
    extra_vars:
      ansible_python_interpreter: /usr/bin/python3
      ansible_async_dir: /home/runner/.ansible_async/
    execution_environment: "ee-casc"
    survey_enabled: True
    survey_spec:
      name: '{{ orgs }} {{ env }} Survey_Gitlab_Webhook_Creation'
      description: 'Survey_Gitlab_Webhook_Creation'
      spec:
        - question_name: gitlab_api_url
          required: true
          type: multiplechoice
          variable: gitlab_api_url
          min: 0
          max: 1024
          choices:
            - "https://gitlab.com"
          default: "https://gitlab.com"
          new_question: true

        - question_name: gitlab_group
          required: false
          type: text
          variable: gitlab_group
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: gitlab_subgroup
          required: false
          type: text
          variable: gitlab_subgroup
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: Trigger hook on push events?
          required: true
          type: multiplechoice
          variable: gitlab_action_push
          min: 0
          max: 30
          choices: "true\nfalse"
          default: "{{ 'true' if env != 'pro' else 'false' }}"
          new_question: true

        - question_name: gitlab_action_tag
          required: true
          type: multiplechoice
          variable: gitlab_action_tag
          min: 0
          max: 1024
          choices: "true\nfalse"
          default: "{{ 'false' if env != 'pro' else 'true' }}"
          new_question: true

        - question_name: gitlab_branch_filter
          required: true
          type: multiplechoice
          variable: gitlab_branch_filter
          choices: "dev\npro"
          default: "{{ 'dev' if env != 'pro' else 'pro' }}"
          new_question: true

        - question_name: "CasC Organization Name"
          required: true
          type: text
          variable: casc_organization
          min: 0
          max: 40
          default: "{{ orgs }}"
          new_question: true

        - question_name: "Organization / Gitlab Project Name"
          required: true
          type: text
          variable: gitlab_project
          min: 0
          max: 40
          new_question: true

        - question_name: "Is a Workflow?"
          required: true
          type: multiplechoice
          variable: "is_workflow"
          min: 0
          max: 30
          choices: "true\nfalse"
          default: "{{ 'false' }}"
          new_question: true

        - question_name: "(Workflow) Job Template Name"
          required: true
          type: text
          variable: "job_template_name"
          min: 0
          max: 60
          new_question: true

...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_job_templates.d/controller_job_templates.yml <<EOF
---
controller_templates:
  - name: "{{ orgs }} {{ env }} New Organization Objects"
    description: "Template to create new organization objects in Org {{ orgs }}"
    organization: "{{ orgs }}"
    project: "{{ orgs }} {{ env }} CasC Data"
    inventory: "{{ orgs }} {{ env }} Controller"
    playbook: "new_project.yml"
    job_type: run
    fact_caching_enabled: false
    credentials:
      - "{{ orgs }} {{ env }} AAP Credential"
      - "{{ orgs }} {{ env }} Vault Credential"
      - "{{ orgs }} {{ env }} GitLab API Token"
    concurrent_jobs_enabled: false
    ask_scm_branch_on_launch: true
    ask_tags_on_launch: true
    ask_verbosity_on_launch: true
    ask_variables_on_launch: true
    execution_environment: "ee-casc"
    survey_enabled: True
    survey_spec:
      name: '{{ orgs }} {{ env }} Survey New Organization Objects'
      description: 'Survey New Organization Objects'
      spec:
        - question_name: Organization name
          required: true
          type: text
          variable: organization_name
          min: 0
          max: 80
          default: ""
          new_question: true

        - question_name: Organization description
          required: true
          type: text
          variable: organization_desc
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: Admin user
          required: true
          type: text
          variable: admin_user
          min: 0
          max: 80
          default: ""
          new_question: true
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_organizations.d/app-casc/controller_organization_superadmin.yml <<EOF
---
controller_organizations:
  - name: "{{ orgs }}"
    description: "Organization for objects that requiere superadmin powers"
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_projects.d/app-casc/controller_projects_casc.yml <<EOF
---
controller_projects:
  - name: "{{ orgs }} {{ env }} CasC Data"
    description: "Project to include the CasC playbooks"
    organization: "{{ orgs }}"
    scm_type: git
    scm_url: "${PROJECT_URL_CASC}"
    scm_credential: "{{ orgs }} {{ env }} GitLab Credential"
    scm_branch: "{{ casc_gitlab_scm_branch | default(env) }}"
    scm_clean: false
    scm_delete_on_update: false
    scm_update_on_launch: false
    scm_update_cache_timeout: 86400
    allow_override: true
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_projects.d/app-gitlab/controller_projects_gitlab.yml <<EOF
---
controller_projects:
  - name: "{{ orgs }} {{ env }} CasC GitLab Webhook"
    description: "Project to include playbooks to configure the GitLab Webhooks for the CasC to be able to run"
    organization: "{{ orgs }}"
    scm_type: git
    scm_url: "${PROJECT_URL_CASC_SETUP}"
    scm_credential: "{{ orgs }} {{ env }} GitLab Credential"
    scm_branch: main
    scm_clean: false
    scm_delete_on_update: false
    scm_update_on_launch: false
    scm_update_cache_timeout: 86400
    allow_override: true
...
EOF

cat > orgs_vars/${SUPERADMIN_ORG}/env/common/controller_workflow_job_templates.d/controller_workflow_job_templates.yml <<EOF
---
controller_workflows:
  - name: "{{ orgs }} {{ env }} WF New Project"
    state: present
    description: "Workflow to create a new project"
    ask_variables_on_launch: false
    allow_simultaneous: true
    scm_branch: "{{ env }}"
    organization: "{{ orgs }}"
    simplified_workflow_nodes:
      - identifier: "Create Webhooks"
        workflow_job_template: "{{ orgs }} {{ env }} WF New Project"
        unified_job_template: "{{ orgs }} {{ env }} Gitlab Webhook Creation"
        job_type: run
        organization: "{{ orgs }}"
        workflow: "{{ orgs }} {{ env }} WF New Project"

      - identifier: "Create SuperAdmin Objects"
        workflow_job_template: "{{ orgs }} {{ env }} WF New Project"
        unified_job_template: "{{ orgs }} {{ env }} New Organization Objects"
        job_type: run
        organization: "{{ orgs }}"
        workflow: "{{ orgs }} {{ env }} WF New Project"
        success_nodes:
          - "Create Webhooks"

      - identifier: "Create GitLab Repo"
        workflow_job_template: "{{ orgs }} {{ env }} WF New Project"
        unified_job_template: "{{ orgs }} {{ env }} Gitlab Project Creation"
        job_type: run
        organization: "{{ orgs }}"
        workflow: "{{ orgs }} {{ env }} WF New Project"
        extra_data:
          controller_dev: "${CONTROLLER_DEV_HOST}"
          controller_pro: "${CONTROLLER_PRO_HOST}"
          gitlab_api_url: "https://gitlab.com"
          gitlab_group: ""
          gitlab_subgroup: ""
          gitlab_project: "dummy"
          gitlab_visibility: "internal"
          gitlab_default_branch: "pro"
          gitlab_http_protocol: "https"
          gitlab_branches_string: "dummy"
        success_nodes:
          - "Create SuperAdmin Objects"
    notification_templates_started: []
    notification_templates_success: []
    notification_templates_error: []
    notification_templates_approvals: []
    extra_vars:
      orgs: "{{ orgs }}"
      orgs_vars: "{{ orgs_vars | default(dir_orgs_vars) }}"
      env: "{{ env }}"
    survey_enabled: True
    survey_spec:
      name: '{{ orgs }} {{ env }} Survey Gitlab Project Creation'
      description: 'Survey Gitlab Project Creation'
      spec:
        - question_name: Name for the new Organization
          question_description: Must be the same name of GitLab project to be created
          required: true
          type: text
          variable: "organization_name"
          min: 0
          max: 80
          new_question: true

        - question_name: Organization description
          required: true
          type: text
          variable: "organization_desc"
          min: 0
          max: 80
          new_question: true

        - question_name: Instance groups to assign the new organization to
          required: false
          type: text
          variable: "instance_groups"
          min: 0
          max: 80
          new_question: true

        - question_name: Admin user for the new Organization
          required: true
          type: text
          variable: "admin_user"
          min: 0
          max: 80
          new_question: true

        - question_name: Ansible Controller Host (Dev)
          required: true
          type: multiplechoice
          variable: controller_dev
          min: 0
          max: 1024
          choices:
            - "${CONTROLLER_DEV_HOST}"
          default: "${CONTROLLER_DEV_HOST}"
          new_question: true

        - question_name: Ansible Controller Host (Pro)
          required: true
          type: multiplechoice
          variable: controller_pro
          min: 0
          max: 1024
          choices:
            - "${CONTROLLER_PRO_HOST}"
          default: "${CONTROLLER_PRO_HOST}"
          new_question: true

        - question_name: GitLab API URL
          required: true
          type: multiplechoice
          variable: gitlab_api_url
          min: 0
          max: 1024
          choices:
            - "https://gitlab.com"
          default: "https://gitlab.com"
          new_question: true

        - question_name: GitLab group name
          required: false
          type: text
          variable: gitlab_group
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: GitLab subgroup name
          required: false
          type: text
          variable: gitlab_subgroup
          min: 0
          max: 1024
          default: ""
          new_question: true

        - question_name: GitLab Project
          question_description: Must be the same name of the organization to be created
          required: true
          type: text
          variable: "gitlab_project"
          min: 0
          max: 80
          new_question: true

        - question_name: GitLab project visibility
          required: true
          type: multiplechoice
          variable: gitlab_visibility
          min: 0
          max: 1024
          choices:
            - "internal"
            - "public"
          default: "public"
          new_question: true

        - question_name: GitLab default branch
          required: true
          type: multiplechoice
          variable: gitlab_default_branch
          min: 0
          max: 1024
          choices:
            - "pro"
          default: "pro"
          new_question: true

        - question_name: GitLab http connection Protocol
          required: true
          type: multiplechoice
          variable: gitlab_http_protocol
          min: 0
          max: 1024
          choices:
            - "https"
            - "http"
          default: "https"
          new_question: true

        - question_name: GitLab branches to be created
          required: true
          type: textarea
          variable: gitlab_branches_string
          min: 0
          max: 1024
          default: "dev\npro"
          new_question: true
...
EOF
