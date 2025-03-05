# Migrate AWX to Ansible Controller
## High Level steps


### Packages required
   ```
$  python3 -m pip install ansible-navigator>=3.4.2 --user
$  python3 -m pip install ansible-builder>=3.0.0 --user
   ```

### Run the playbook to export the AWX configuration:
   ```
    ansible-navigator run playbooks/config-controller-export.yaml -i localhost -m stdout --eei satellite.bcnconsulting.com/red_ribbon/application_images/aap_ee-casc:pgoku-aap-2.4 --eev /tmp/:/tmp/ -e @vars/vault-awx.yaml --vault-password-file .vault-password  -e '{ansible_async_dir: /home/runner/.ansible_async/, is_aap: false, output_path: /tmp/filetree_output, organization_filter: AWX-ORG}'
   ```
### Show the manual required chages:
   ```
    vim -c "DirDiff /tmp/filetree_output ./examples/aap25/configs/"
   ```
### Run the playbook to import the AWX configuration in the automation controller:
   ```
    ansible-navigator run playbooks/config-controller-filetree.yaml -i localhost -m stdout --eei satellite.bcnconsulting.com/red_ribbon/application_images/aap_ee-casc:pgoku-aap-2.5 --vault-password-file .vault-password -e @vars/vault.yaml -e @vars/vault-controller.yaml -e @vars/controller.yaml -e @vars/paths-aap25.yaml --vault-password-file .vault-password -e '{controller_configuration_filetree_read_secure_logging: false,ansible_async_dir: /home/runner/.ansible_async/}'
   ```

### Run the playbook to import the AWX configuration in AWX:
   ```
    ansible-navigator run playbooks/config-controller-filetree_old.yaml -i localhost -m stdout --eei satellite.bcnconsulting.com/red_ribbon/application_images/aap_ee-casc:pgoku-aap-2.4 --vault-password-file .vault-password -e @vars/vault.yaml -e @vars/paths-awx.yaml -e@vars/vault-awx.yaml --vault-password-file .vault-password -e '{controller_configuration_filetree_read_secure_logging: false,ansible_async_dir: /home/runner/.ansible_async/}'
   ```

