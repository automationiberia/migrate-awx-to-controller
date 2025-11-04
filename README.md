# Migrate AWX to Ansible Controller
## High Level steps

### Packages required
   ```
$  python3 -m pip install ansible-navigator>=3.4.2 --user
$  python3 -m pip install ansible-builder>=3.0.0 --user
   ```

### Run the playbook to export the AAP 2.5 configuration:
   ```
   time ansible-playbook playbooks/config-controller-export.yaml --vault-password-file .vault-password \
     -e @vars/vault.yaml \
     -e @vars/vault-aap25.yaml \
     -e '{aap_configuration_filetree_create_secure_logging: false}'
   ```
### Show the differences from the exported code to what we are going to apply
   ```
   meld /tmp/filetree_output examples/aap25/configs/
   ```
### Run the playbook to import the AAP 2.5 configuration in the AAP 2.6:
   ```
   time ansible-playbook playbooks/config-controller-filetree.yaml --vault-password-file .vault-password \
     -e @vars/vault.yaml \
     -e @vars/paths-aap25.yaml \
     -e @vars/vault-aap26.yaml \
     -e @vars/vaulted-variables.yaml \
     -e '{controller_configuration_filetree_read_secure_logging: false,
          controller_configuration_inventories_enforce_defaults: true,
          controller_configuration_inventory_sources_enforce_defaults: true}'
   ```

### Run the playbook to import the AAP 2.5 configuration in AAP 2.5:
   ```
   time ansible-playbook playbooks/config-controller-filetree.yaml --vault-password-file .vault-password \
     -e @vars/vault.yaml \
     -e @vars/paths-aap25.yaml \
     -e @vars/vault-aap25.yaml \
     -e @vars/vaulted-variables.yaml \
     -e '{controller_configuration_filetree_read_secure_logging: false,
          controller_configuration_inventories_enforce_defaults: true,
          controller_configuration_inventory_sources_enforce_defaults: true}'
   ```

