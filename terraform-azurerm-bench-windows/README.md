# Azure quick start configuration: terraform-azurerm-bench-windows  

## Overview

This quick start implements a dedicated Windows Server / SQL Server database server virtual machine and a dedicated Windows Server web server virtual machine connected to the dedicated spoke virtual network for use as a pre-configured environment for running benchmarks like [HammerDB](https://www.hammerdb.com/) and testing web applications. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-hub](../terraform-azurerm-vnet-hub)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Create required secrets in shared key vault and provision post-deployment script
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Note that the password must be at least 12 characters long and meet [defined complexity requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm). Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Create required secrets in shared key vault and provision post-deployment script
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning new virtual machines.
    * *adminpassword*: the admin password to use when provisioning new virtual machines. Note that the password must be at least 12 characters long and meet [defined complexity requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm). Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh`.
  * -n: Change to a custom *vm_name* if desired.
  * -s: Change to a different *vm_image_sku* if desired.
    * Run `az vm image list-skus -l eastus -p MicrosoftSQLServer -f sql2019-ws2019 -o table` for a list of valid image sku names. Change the -l parameter to the desired location.
  * -z: Change to a different *vm_size* if desired.
    * Run `az vm list-sizes -l eastus -o table` for a list of sizes. Change the -l parameter to the desired location.
  * -c: Change to a different *vm_data_disk_count* if desired. Set to "0" of no data disks are required.
  * -d: Change to a different *vm_data_disk_size_gb* if desired.
  * -t: Change to a different *tags* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the ~7 resources included in this quick start.

### Database server virtual machine

---

Dedicated Windows Server / SQL Server database server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) connected to the dedicated spoke virtual network with a configurable number of data disks, pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_db_name | Input | string | Local | winbenchdb01
vm_db_size | Input | string | Local | Standard_B2ms
vm_db_storage_replication_type | Input | string | Local | Standard_LRS
vm_db_image_publisher | Input | string | Local | MicrosoftSQLServer
vm_db_image_offer | Input | string | Local | sql2019-ws2019
vm_db_image_sku | Input | string | Local | sqldev
vm_db_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_03_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/winbenchdb01
virtual_machine_03_name | Output | string | Local | winbenchdb01

#### SQL Server virtual machine configuration

The default instance of SQL Server is pre-configured using the following settings:

* *sa* username and password credentials set using key vault
* sql_license_type = "PAYG"
* r_services_enabled = true
* sql_connectivity_port = 1433
* sql_connectivity_type = "PRIVATE"

#### Database server network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_03_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-winbenchdb01-001
virtual_machine_03_nic_01_name | Output | string | Local | nic-winbenchdb01-001
virtual_machine_03_nic_01_private_ip_address | Output | string | Local | 10.2.1.36

#### Database server managed disks and data disk attachments

One or more dedicated [managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) for use by the virtual machine as data disks. Each of the dedicated managed disks is automatically attached to the dedicated Windows Server virtual machine. Note that caching is disabled by default and must be configured post-deployment if needed.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_data_disk_count | Input | string | Local | 2
vm_storage_replication_type | Input | string | Local | Standard_LRS
vm_data_disk_size_gb | Input | string | Local | 32 (Gb)

#### Database server virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the virtual machine including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) also known as the *Microsoft Monitoring Agent* (MMA) version 1.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-windows) version 9.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to run a post-deployment script which partitions and formats new data disks.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
storage_account_name | Input | String | Local | st8e644ec51c5be098001
vm_db_post_deploy_script_name | Input | string | Local | virtual-machine-03-post-deploy.ps1 (Default)
vm_db_post_deploy_script_uri | Input | string | Local | <https://st8e644ec51c5be098001.blob.core.windows.net/scripts/virtual-machine-03-post-deploy.ps1>

### Web server virtual machine

---

Dedicated Windows Server web server [virtual machine](https://docs.microsoft.com/en-us/azure/azure-glossary-cloud-terminology#vm) connected to the dedicated spoke virtual network with pre-configured administrator credentials using key vault, and pre-configured virtual machine extensions.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vm_web_name | Input | string | Local | winbenchweb01
vm_web_size | Input | string | Local | Standard_B2s
vm_web_storage_replication_type | Input | string | Local | Standard_LRS
vm_web_image_publisher | Input | string | Local | MicrosoftWindowsServer
vm_web_image_offer | Input | string | Local | WindowsServer
vm_web_image_sku | Input | string | Local | 2019-Datacenter-smalldisk
vm_web_image_version | Input | string | Local | Latest (default)
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
virtual_machine_04_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Compute/virtualMachines/winbenchweb01
virtual_machine_04_name | Output | string | Local | winbenchweb01

#### Web server network interface

Dedicated [network interface](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) (NIC) with a dynamic private ip address attached to the virtual machine.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_machine_04_nic_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/networkInterfaces/nic-winbenchweb01-001
virtual_machine_04_nic_01_name | Output | string | Local | nic-winbenchweb01-001
virtual_machine_04_nic_01_private_ip_address | Output | string | Local | 10.2.1.68

#### Web server virtual machine extensions

Pre-configured [virtual machine extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview) attached to the virtual machine including:

* [Log Analytics virtual machine extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) also known as the *Microsoft Monitoring Agent* (MMA) version 1.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Dependency virtual machine extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-dependency-windows) version 9.0 with automatic minor version upgrades enabled and automatically connected to the shared log analytics workspace.
* [Custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) version 1.10 with automatic minor version upgrades enabled and configured to run a post-deployment script which partitions and formats new data disks.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
log_analytics_workspace_id | Input | string | Local | 00000000-0000-0000-0000-000000000000
vm_web_post_deploy_script_name | Input | string | Local | virtual-machine-04-post-deploy.ps1 (Default)
vm_web_post_deploy_script_uri | Input | string | Local | <https://st8e644ec51c5be098001.blob.core.windows.net/scripts/virtual-machine-04-post-deploy.ps1>
storage_account_name | Input | String | Local | st8e644ec51c5be098001

## Smoke testing

* Explore newly provisioned resources using the Azure portal.
  * Review the 4 secrets that were created in the shared key vault.
  * Generate a script for mapping drives to the shared file share.
    * Mapping a drive to an Azure Files file share requires automation due to the use of a complex shared key to authenticate.
    * In the Azure Portal navigate to *storage accounts* > *stxxxxxxxxxxxxxxxx001* > *file service* > *file shares* > *fs-xxxxxxxxxxxxxxxx-001* > *Connect* > *Windows*
    * Copy the PowerShell script in the right-hand pane for use in the next smoke testing exercise.
* Connect to the dedicated virtual machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Confirm access to shared file share private endpoint.
    * Run Windows PowerShell ISE, create a new script, and paste in the script generated previously.
    * Copy the fqdn for the file endpoint from line 4, for example *stxxxxxxxxxxxxxxxx001.file.core.windows.net*
    * Run `Resolve-DnsName stxxxxxxxxxxxxxxxx001.file.core.windows.net` from the Windows PowerShell ISE console.  
    * Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-001* subnet in the shared hub virtual network. This name resolution is accomplished using the shared private DNS zone.
    * Execute the PowerShell script copied from the Azure Portal to establish a drive mapping to the shared file share using the private endpoint.
    * Create some directories and sample files on the drive mapped to the shared file share to test functionality.
  * Review the log file created during execution of the post-deployment script in C:/Packages/Plugins/Microsoft.Compute.CustomScriptExtension/1.10.X/Downloads/0.
  * Launch SQL Server Management Studio and create a test database. Place the data file and the log file on different data disks.

## Next steps

Move on to the next quick start [terraform-azurerm-vwan](../terraform-azurerm-vwan).
