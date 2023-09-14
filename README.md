# Migrate AWX to Ansible Controller
## High Level steps


### Packages required
   ```
$  python3 -m pip install ansible-navigator>=3.4.2 --user
$  python3 -m pip install ansible-builder>=3.0.0 --user
   ```

### Run the playbook to export the AWX configuration:
   ```
    ansible-navigator run playbooks/config-controller-export.yaml -i localhost -m stdout --eei quay.io/automationiberia/casc/ee-casc:latest --eev /tmp/:/tmp/ -e @vars/vault-awx.yaml --vault-password-file .vault-password  -e '{ansible_async_dir: /home/runner/.ansible_async/, is_aap: false, output_path: /tmp/filetree_output, organization_filter: AWX-ORG}'
   ```
### Run the playbook to import the AWX configuration in the automation controller:
   ```
    ansible-navigator run playbooks/config-controller-filetree.yaml -i localhost -m stdout --eei quay.io/automationiberia/casc/ee-casc:latest --vault-password-file .vault-password -e @vars/vault.yaml -e @vars/vault-controller.yaml -e @vars/controller.yaml -e @vars/paths-awx.yaml -e '{controller_configuration_filetree_read_secure_logging: false,ansible_async_dir: /home/runner/.ansible_async/}'
   ```

### Run the playbook to import the AWX configuration in AWX:
   ```
    ansible-navigator run playbooks/config-controller-filetree.yaml -i localhost -m stdout --eei quay.io/automationiberia/casc/ee-casc:latest --vault-password-file .vault-password -e @vars/vault.yaml -e @vars/paths-awx.yaml -e@vars/vault-awx.yaml -e '{controller_configuration_filetree_read_secure_logging: false,ansible_async_dir: /home/runner/.ansible_async/}'
   ```
### Run the playbook to import the CONTROLLER configuration in CONTROLLER:
   ```
    ansible-navigator run playbooks/config-controller-filetree.yaml -i localhost -m stdout --eei quay.io/automationiberia/casc/ee-casc:latest --vault-password-file .vault-password -e @vars/vault.yaml -e @vars/paths-controller.yaml -e@vars/vault-controller.yaml -e '{controller_configuration_filetree_read_secure_logging: false,ansible_async_dir: /home/runner/.ansible_async/}'
   ```
