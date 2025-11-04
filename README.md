# Migrate AWX to Ansible Controller
## High Level steps

### Check the /tmp/ directory doesn't contains any filetree_output subdirectory:
   ```console
   ls -l /tmp/f*
   ```

### Run the playbook to export the AAP 2.5 configuration:
   ```console
   time ansible-playbook playbooks/config-controller-export.yaml --vault-password-file .vault-password \
     -e @vars/vault.yaml \
     -e @vars/vault-aap25.yaml \
     -e '{aap_configuration_filetree_create_secure_logging: false}'
   ```

### Show the differences from the exported code to what we are going to apply
   ```console
   meld /tmp/filetree_output examples/aap25/configs/
   ```

### Run the playbook to import the AAP 2.5 configuration in the AAP 2.6:
   ```console
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
   ```console
   time ansible-playbook playbooks/config-controller-filetree.yaml --vault-password-file .vault-password \
     -e @vars/vault.yaml \
     -e @vars/paths-aap25.yaml \
     -e @vars/vault-aap25.yaml \
     -e @vars/vaulted-variables.yaml \
     -e '{controller_configuration_filetree_read_secure_logging: false,
          controller_configuration_inventories_enforce_defaults: true,
          controller_configuration_inventory_sources_enforce_defaults: true}'
   ```

