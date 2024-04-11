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

cat > .gitignore <<EOF
collections/ansible_collections
users.csv
users_old.csv
.vault*
*artifact*
ansible-navigator.log
.*.swp
inventory_bastions
list
p.yml
id_rsa*
venv
EOF

cat > .yamllint.yml <<EOF
---
extends: default

ignore: |
  changelogs
  group_vars/*/configure_connection_controller_credentials.yml
  group_vars/*/vault
  orgs_vars/*/env/*/controller_credentials.d/
  orgs_vars/*/env/*/controller_users.d/
  orgs_vars/*/env/*/controller_settings.d/authentication/controller_settings_ldap.yml

yaml-files:
  - '*.yaml'
  - '*.yml'

rules:
  # 80 chars should be enough, but don't fail if a line is longer
  line-length: disable
  comments:
    require-starting-space: true
    ignore-shebangs: true
    min-spaces-from-content: 2
  commas:
    max-spaces-before: 0
    min-spaces-after: 1
    max-spaces-after: 1
  colons:
    max-spaces-before: 0
    max-spaces-after: -1
  document-end: {present: true}
  indentation:
    level: error
    indent-sequences: consistent
  truthy:
    level: error
    allowed-values:
      - 'True'
      - 'False'
      - 'true'
      - 'false'
      - 'on'
...
EOF

cat > .gitlab-ci.yml <<'EOF'
---
stages:
  - lint
  - check
  - prepare
  - release

yamllint:
  stage: lint
  image: quay.io/automationiberia/casc/ee-casc:latest
  tags:
    - casc
    - controller-group
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS'
      when: never
    - if: '$CI_COMMIT_BRANCH'
  script:
    - yamllint -c ./.yamllint.yml .

check_names:
  stage: check
  # variables:
  #   CI_DEBUG_TRACE: "true"
  image: quay.io/automationiberia/casc/ee-casc:latest
  tags:
    - casc
    - controller-group
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS'
      when: never
    - if: '$CI_COMMIT_BRANCH'
  script:
    - ansible-playbook check_playbook.yml

generate_tag:
  stage: prepare
  image: registry.gitlab.com/gitlab-org/release-cli
  tags:
    - casc
    - controller-group
  rules:
    - if: $CI_COMMIT_MESSAGE =~ /First Commit/
      when: never
    - if: $CI_COMMIT_TAG
      when: never
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      exists:
        - VERSION
      changes:
        - VERSION
  script:
    - echo "TAG=$(cat VERSION)" > tag.env
  artifacts:
    reports:
      dotenv: tag.env

auto-release-master:
  image: registry.gitlab.com/gitlab-org/release-cli
  tags:
    - casc
    - controller-group
  needs:
    - job: generate_tag
      artifacts: true
  stage: release
  rules:
    - if: $CI_COMMIT_TAG
      when: never
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      exists:
        - VERSION
      changes:
        - VERSION
  script:
    - echo "Release $TAG"
  release:
    name: "Release $TAG"
    description: "Created using the release-cli $EXTRA_DESCRIPTION"
    tag_name: v$TAG
    ref: $CI_COMMIT_SHA
...
EOF

### Prepare for the GitLab Runner configuration
# Download the binary for your system
sudo curl -L --output /usr/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo /usr/bin/gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo /usr/bin/gitlab-runner start
