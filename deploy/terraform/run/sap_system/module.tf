# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


#########################################################################################
#                                                                                       #
#  Name generator                                                                       #
#                                                                                       #
#########################################################################################

module "sap_namegenerator" {
  source                                        = "../../terraform-units/modules/sap_namegenerator"
  environment                                   = local.infrastructure.environment
  location                                      = local.infrastructure.region
  codename                                      = lower(try(local.infrastructure.codename, ""))
  random_id                                     = coalesce(var.custom_random_id, module.common_infrastructure.random_id)
  sap_vnet_name                                 = local.vnet_logical_name
  sap_sid                                       = local.sap_sid
  db_sid                                        = local.db_sid
  web_sid                                       = local.web_sid

  app_ostype                                    = upper(try(local.application_tier.app_os.os_type, "LINUX"))
  anchor_ostype                                 = upper(try(local.anchor_vms.os.os_type, "LINUX"))
  db_ostype                                     = upper(try(local.database.os.os_type, "LINUX"))
  db_server_count                               = var.database_server_count + var.stand_by_node_count
  app_server_count                              = local.enable_app_tier_deployment ? try(local.application_tier.application_server_count, 0) : 0
  web_server_count                              = local.enable_app_tier_deployment ? try(local.application_tier.webdispatcher_count, 0) : 0
  scs_server_count                              = local.enable_app_tier_deployment ? local.application_tier.scs_high_availability ? (
                                                    2 * local.application_tier.scs_server_count) : (
                                                    local.application_tier.scs_server_count
                                                  ) : 0

  app_zones                                     = local.enable_app_tier_deployment && var.application_server_count > 0 ? try(local.application_tier.app_zones, []) : []
  scs_zones                                     = local.enable_app_tier_deployment && var.scs_server_count > 0 ? try(local.application_tier.scs_zones, []) : []
  web_zones                                     = local.enable_app_tier_deployment && var.webdispatcher_server_count > 0 ? try(local.application_tier.web_zones, []) : []
  db_zones                                      = try(local.database.zones, [])

  resource_offset                               = try(var.resource_offset, 0)
  custom_prefix                                 = var.custom_prefix
  database_high_availability                    = local.database.high_availability
  database_cluster_type                         = local.database.database_cluster_type
  scs_high_availability                         = local.application_tier.scs_high_availability
  scs_cluster_type                              = local.application_tier.scs_cluster_type
  use_zonal_markers                             = var.use_zonal_markers
  scale_out                                     = var.database_HANA_use_scaleout_scenario
}

#########################################################################################
#                                                                                       #
#  Common Infrastructure                                                                #
#                                                                                       #
#########################################################################################

module "common_infrastructure" {
  source                                        = "../../terraform-units/modules/sap_system/common_infrastructure"
  providers                                     = {
                                                    azurerm.deployer                 = azurerm.deployer
                                                    azurerm.main                     = azurerm.system
                                                    azurerm.dnsmanagement            = azurerm.dnsmanagement
                                                    azurerm.privatelinkdnsmanagement = azurerm.privatelinkdnsmanagement
                                                  }
  Agent_IP                                      = var.add_Agent_IP ? var.Agent_IP : ""
  application_tier                              = local.application_tier
  application_tier_ppg_names                    = module.sap_namegenerator.naming_new.app_ppg_names
  authentication                                = local.authentication
  azure_files_sapmnt_id                         = var.azure_files_sapmnt_id
  custom_disk_sizes_filename                    = try(coalesce(var.custom_disk_sizes_filename, var.db_disk_sizes_filename), "")
  custom_prefix                                 = var.use_prefix ? var.custom_prefix : " "
  database                                      = local.database
  database_dual_nics                            = var.database_dual_nics
  deploy_application_security_groups            = var.deploy_application_security_groups
  deployer_tfstate                              = length(var.deployer_tfstate_key) > 0 ? data.terraform_remote_state.deployer[0].outputs : null
  deployment                                    = var.deployment
  enable_purge_control_for_keyvaults            = var.enable_purge_control_for_keyvaults
  ha_validator                                  = format("%d%d-%s",
                                                    local.application_tier.scs_high_availability ? 1 : 0,
                                                    local.database.high_availability ? 1 : 0,
                                                    upper(try(local.application_tier.app_os.os_type, "LINUX")) == "LINUX" ? var.NFS_provider : "WINDOWS"
                                                  )
  hana_ANF_volumes                              = local.hana_ANF_volumes
  infrastructure                                = local.infrastructure
  is_single_node_hana                           = "true"
  key_vault                                     = local.key_vault
  landscape_tfstate                             = data.terraform_remote_state.landscape.outputs
  license_type                                  = var.license_type
  naming                                        = length(var.name_override_file) > 0 ? local.custom_names : module.sap_namegenerator.naming
  NFS_provider                                  = var.NFS_provider
  options                                       = local.options
  sapmnt_private_endpoint_id                    = var.sapmnt_private_endpoint_id
  sapmnt_volume_size                            = var.sapmnt_volume_size
  scaleset_id                                   = var.scaleset_id
  tags                                          = var.tags
  terraform_template_version                    = var.terraform_template_version
  use_private_endpoint                          = var.use_private_endpoint
  use_random_id_for_storageaccounts             = var.use_random_id_for_storageaccounts
  use_scalesets_for_deployment                  = var.use_scalesets_for_deployment
  dns_settings                                  = local.dns_settings
  enable_firewall_for_keyvaults_and_storage     = var.enable_firewall_for_keyvaults_and_storage

}

#-------------------------------------------------------------------------------
#                                                                              #
#  HANA Infrastructure                                                         #
#                                                                              #
#--------------------------------------+---------------------------------------8
module "hdb_node" {
  source                                        = "../../terraform-units/modules/sap_system/hdb_node"
  depends_on                                    = [module.common_infrastructure]
  providers                                     = {
                                                    azurerm.deployer                 = azurerm.deployer
                                                    azurerm.main                     = azurerm.system
                                                    azurerm.dnsmanagement            = azurerm.dnsmanagement
                                                    azurerm.privatelinkdnsmanagement = azurerm.privatelinkdnsmanagement
                                                  }

  admin_subnet                                  = module.common_infrastructure.admin_subnet
  Agent_IP                                      = var.add_Agent_IP ? var.Agent_IP : ""
  anchor_vm                                     = module.common_infrastructure.anchor_vm // Workaround to create dependency from anchor to db to app
  cloudinit_growpart_config                     = null # This needs more consideration module.common_infrastructure.cloudinit_growpart_config
  custom_disk_sizes_filename                    = try(coalesce(var.custom_disk_sizes_filename, var.db_disk_sizes_filename), "")
  database                                      = local.database
  database_active_active                        = var.database_active_active
  database_dual_nics                            = try(module.common_infrastructure.admin_subnet, null) == null ? false : var.database_dual_nics
  enable_storage_nic                            = var.enable_storage_nic
  database_server_count                         = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    local.database.high_availability ? (
                                                      2 * (var.database_server_count + var.stand_by_node_count)) : (
                                                      var.database_server_count + var.stand_by_node_count
                                                    )) : (
                                                    0
                                                  )
  database_use_premium_v2_storage               = var.database_use_premium_v2_storage
  database_vm_admin_nic_ips                     = var.database_vm_admin_nic_ips
  database_vm_db_nic_ips                        = var.database_vm_db_nic_ips
  database_vm_db_nic_secondary_ips              = var.database_vm_db_nic_secondary_ips
  database_vm_storage_nic_ips                   = var.database_vm_storage_nic_ips
  db_asg_id                                     = module.common_infrastructure.db_asg_id
  db_subnet                                     = module.common_infrastructure.db_subnet
  deploy_application_security_groups            = var.deploy_application_security_groups
  deployment                                    = var.deployment
  dns_settings                                  = local.dns_settings
  enable_firewall_for_keyvaults_and_storage     = var.enable_firewall_for_keyvaults_and_storage
  fencing_role_name                             = var.fencing_role_name
  hana_ANF_volumes                              = local.hana_ANF_volumes
  hanashared_id                                 = length(var.hanashared_id) > 0 ? (length(var.hanashared_id[0]) > 0 ? var.hanashared_id : []) : []
  hanashared_private_endpoint_id                = length(var.hanashared_private_endpoint_id) > 0 ? (length(var.hanashared_private_endpoint_id[0]) > 0 ? var.hanashared_private_endpoint_id : []) : []
  use_single_hana_shared                        = var.use_single_hana_shared
  hanashared_volume_size                        = var.hanashared_volume_size
  infrastructure                                = local.infrastructure
  landscape_tfstate                             = data.terraform_remote_state.landscape.outputs
  license_type                                  = var.license_type
  naming                                        = length(var.name_override_file) > 0 ? local.custom_names : module.sap_namegenerator.naming
  NFS_provider                                  = var.NFS_provider
  observer_vm_size                              = var.observer_vm_size
  observer_vm_tags                              = var.observer_vm_tags
  observer_vm_zones                             = var.observer_vm_zones
  options                                       = local.options
  ppg                                           = module.common_infrastructure.ppg
  random_id                                     = coalesce(var.custom_random_id, module.common_infrastructure.random_id)
  resource_group                                = module.common_infrastructure.resource_group
  sap_sid                                       = local.sap_sid
  scale_set_id                                  = length(var.scaleset_id) > 0 ? var.scaleset_id : module.common_infrastructure.scale_set_id
  sdu_public_key                                = module.common_infrastructure.sdu_public_key
  sid_keyvault_user_id                          = module.common_infrastructure.sid_keyvault_user_id
  sid_password                                  = module.common_infrastructure.sid_password
  sid_username                                  = module.common_infrastructure.sid_username
  storage_bootdiag_endpoint                     = module.common_infrastructure.storage_bootdiag_endpoint
  storage_subnet                                = module.common_infrastructure.storage_subnet
  tags                                          = var.tags
  terraform_template_version                    = var.terraform_template_version
  use_admin_nic_suffix_for_observer             = var.use_admin_nic_suffix_for_observer
  use_admin_nic_for_asg                         = var.use_admin_nic_for_asg
  use_loadbalancers_for_standalone_deployments  = var.use_loadbalancers_for_standalone_deployments
  use_msi_for_clusters                          = var.use_msi_for_clusters
  use_observer                                  = var.database_HANA_use_scaleout_scenario && local.database.high_availability && var.use_observer
  use_private_endpoint                          = var.use_private_endpoint
  use_scalesets_for_deployment                  = var.use_scalesets_for_deployment
  use_secondary_ips                             = var.use_secondary_ips
}

#########################################################################################
#                                                                                       #
#  App Tier Infrastructure                                                              #
#                                                                                       #
#########################################################################################

module "app_tier" {
  source                                        = "../../terraform-units/modules/sap_system/app_tier"
  providers                                     = {
                                                    azurerm.deployer                 = azurerm.deployer
                                                    azurerm.main                     = azurerm.system
                                                    azurerm.dnsmanagement            = azurerm.dnsmanagement
                                                    azurerm.privatelinkdnsmanagement = azurerm.privatelinkdnsmanagement
                                                    # azapi.api                                 = azapi.api
                                                  }

  depends_on                                    = [module.common_infrastructure]
  admin_subnet                                  = module.common_infrastructure.admin_subnet
  application_tier                              = local.application_tier
  cloudinit_growpart_config                     = null # This needs more consideration module.common_infrastructure.cloudinit_growpart_config
  custom_disk_sizes_filename                    = try(coalesce(var.custom_disk_sizes_filename, var.app_disk_sizes_filename), "")
  deploy_application_security_groups            = var.deploy_application_security_groups
  deployment                                    = var.deployment
  fencing_role_name                             = var.fencing_role_name
  firewall_id                                   = module.common_infrastructure.firewall_id
  idle_timeout_scs_ers                          = var.idle_timeout_scs_ers
  infrastructure                                = local.infrastructure
  landscape_tfstate                             = data.terraform_remote_state.landscape.outputs
  license_type                                  = var.license_type
  naming                                        = length(var.name_override_file) > 0 ? local.custom_names : module.sap_namegenerator.naming
  network_location                              = module.common_infrastructure.network_location
  network_resource_group                        = module.common_infrastructure.network_resource_group
  options                                       = local.options
  order_deployment                              = null
  ppg                                           = var.use_app_proximityplacementgroups ? module.common_infrastructure.app_ppg : module.common_infrastructure.ppg
  resource_group                                = module.common_infrastructure.resource_group
  route_table_id                                = module.common_infrastructure.route_table_id
  sap_sid                                       = local.sap_sid
  scale_set_id                                  = try(module.common_infrastructure.scale_set_id, null)
  sdu_public_key                                = module.common_infrastructure.sdu_public_key
  sid_keyvault_user_id                          = module.common_infrastructure.sid_keyvault_user_id
  sid_password                                  = module.common_infrastructure.sid_password
  sid_username                                  = module.common_infrastructure.sid_username
  storage_bootdiag_endpoint                     = module.common_infrastructure.storage_bootdiag_endpoint
  tags                                          = var.tags
  terraform_template_version                    = var.terraform_template_version
  use_admin_nic_for_asg                         = var.use_admin_nic_for_asg
  use_loadbalancers_for_standalone_deployments  = var.use_loadbalancers_for_standalone_deployments
  use_msi_for_clusters                          = var.use_msi_for_clusters
  use_scalesets_for_deployment                  = var.use_scalesets_for_deployment
  use_secondary_ips                             = var.use_secondary_ips
  dns_settings                                  = local.dns_settings

}

#########################################################################################
#                                                                                       #
#  AnyDB Infrastructure                                                                 #
#                                                                                       #
#########################################################################################

module "anydb_node" {
  source                                        = "../../terraform-units/modules/sap_system/anydb_node"
  providers                                     = {
                                                    azurerm.deployer                 = azurerm.deployer
                                                    azurerm.main                     = azurerm.system
                                                    azurerm.dnsmanagement            = azurerm.dnsmanagement
                                                    azurerm.privatelinkdnsmanagement = azurerm.privatelinkdnsmanagement
                                                    # azapi.api                                 = azapi.api
                                                  }

  depends_on                                    = [module.common_infrastructure]

  admin_subnet                                  = try(module.common_infrastructure.admin_subnet, null)
  anchor_vm                                     = module.common_infrastructure.anchor_vm // Workaround to create dependency from anchor to db to app
  cloudinit_growpart_config                     = null # This needs more consideration module.common_infrastructure.cloudinit_growpart_config
  custom_disk_sizes_filename                    = try(coalesce(var.custom_disk_sizes_filename, var.db_disk_sizes_filename), "")
  database                                      = local.database
  database_vm_db_nic_ips                        = var.database_vm_db_nic_ips
  database_vm_db_nic_secondary_ips              = var.database_vm_db_nic_secondary_ips
  database_vm_admin_nic_ips                     = var.database_vm_admin_nic_ips
  database_server_count                         = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                  0) : (
                                                    local.database.high_availability ? 2 * var.database_server_count : var.database_server_count
                                                  )
  db_asg_id                                     = module.common_infrastructure.db_asg_id
  db_subnet                                     = module.common_infrastructure.db_subnet
  deploy_application_security_groups            = var.deploy_application_security_groups
  deployment                                    = var.deployment
  fencing_role_name                             = var.fencing_role_name
  infrastructure                                = local.infrastructure
  landscape_tfstate                             = data.terraform_remote_state.landscape.outputs
  license_type                                  = var.license_type
  naming                                        = length(var.name_override_file) > 0 ? local.custom_names : module.sap_namegenerator.naming
  observer_vm_size                              = var.observer_vm_size
  observer_vm_tags                              = var.observer_vm_tags
  observer_vm_zones                             = var.observer_vm_zones
  options                                       = local.options
  order_deployment                              = local.enable_db_deployment ? (
                                                    local.db_zonal_deployment && local.application_tier.enable_deployment ? (
                                                      try(module.app_tier.scs_vm_ids[0], null)
                                                    ) : (null)
                                                  ) : (null)
  ppg                                           = module.common_infrastructure.ppg
  resource_group                                = module.common_infrastructure.resource_group
  sap_sid                                       = local.sap_sid
  scale_set_id                                  = try(module.common_infrastructure.scale_set_id, null)
  sdu_public_key                                = module.common_infrastructure.sdu_public_key
  sid_keyvault_user_id                          = module.common_infrastructure.sid_keyvault_user_id
  sid_password                                  = module.common_infrastructure.sid_password
  sid_username                                  = module.common_infrastructure.sid_username
  storage_bootdiag_endpoint                     = module.common_infrastructure.storage_bootdiag_endpoint
  tags                                          = var.tags
  terraform_template_version                    = var.terraform_template_version
  use_admin_nic_suffix_for_observer             = var.use_admin_nic_suffix_for_observer
  use_admin_nic_for_asg                         = var.use_admin_nic_for_asg
  use_loadbalancers_for_standalone_deployments  = var.use_loadbalancers_for_standalone_deployments
  use_msi_for_clusters                          = var.use_msi_for_clusters
  use_observer                                  = var.use_observer
  use_scalesets_for_deployment                  = var.use_scalesets_for_deployment
  use_secondary_ips                             = var.use_secondary_ips
  dns_settings                                  = local.dns_settings

}

#########################################################################################
#                                                                                       #
#  Output files                                                                         #
#                                                                                       #
#########################################################################################

module "output_files" {
  source                                        = "../../terraform-units/modules/sap_system/output_files"
  depends_on                                    = [module.anydb_node, module.common_infrastructure, module.app_tier, module.hdb_node]
  providers                                     = {
                                                    azurerm.main           = azurerm.system
                                                    azurerm.dnsmanagement  = azurerm.dnsmanagement
                                                    # azapi.api                                 = azapi.api
                                                  }

  authentication                                = local.authentication
  authentication_type                           = try(local.application_tier.authentication.type, "key")
  configuration_settings                        = var.configuration_settings
  database                                      = local.database
  database_shared_disks                         = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.database_shared_disks) : (
                                                    module.anydb_node.database_shared_disks
                                                  )
  is_use_fence_kdump                            = var.use_fence_kdump
  infrastructure                                = local.infrastructure
  landscape_tfstate                             = data.terraform_remote_state.landscape.outputs
  naming                                        = length(var.name_override_file) > 0 ? (
                                                    local.custom_names) : (
                                                    module.sap_namegenerator.naming
                                                  )
  random_id                                     = module.common_infrastructure.random_id
  save_naming_information                       = var.save_naming_information
  tfstate_resource_id                           = var.tfstate_resource_id

  created_resource_group_name                   = module.common_infrastructure.created_resource_group_name
  created_resource_group_subscription_id        = module.common_infrastructure.created_resource_group_subscription_id

  #########################################################################################
  #  Database tier                                                                        #
  #########################################################################################
  database_admin_ips                            = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.db_admin_ip) : (
                                                    module.anydb_node.database_server_admin_ips
                                                  ) #TODO Change to use Admin IP
  database_authentication_type                  = try(local.database.authentication.type, "key")
  database_cluster_type                         = var.database_cluster_type
  database_cluster_ip                           = module.anydb_node.database_cluster_ip
  database_high_availability                    = local.database.high_availability
  database_active_active                        = var.database_active_active
  database_active_active_loadbalancer_ip        = try(module.hdb_node.database_loadbalancer_ip[1], "")
  database_loadbalancer_ip                      = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.database_loadbalancer_ip[0]) : (
                                                    module.anydb_node.database_loadbalancer_ip[0]
                                                  )
  database_server_ips                           = upper(try(local.database.platform, "HANA")) == "HANA" ? (module.hdb_node.database_server_ips
                                                  ) : (module.anydb_node.database_server_ips
                                                  )
  database_server_vm_names                      = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.database_server_vm_names) : (
                                                    module.anydb_node.database_server_vm_names
                                                  )
  database_server_secondary_ips                 = upper(try(local.database.platform, "HANA")) == "HANA" ? (module.hdb_node.database_server_secondary_ips
                                                  ) : (module.anydb_node.database_server_secondary_ips
                                                  )
  database_subnet_netmask                       = module.common_infrastructure.db_subnet_netmask
  disks                                         = distinct(compact(concat(module.hdb_node.database_disks,
                                                    module.anydb_node.database_disks,
                                                    module.app_tier.apptier_disks,
                                                    module.hdb_node.database_kdump_disks,
                                                    module.anydb_node.database_kdump_disks,
                                                    module.app_tier.scs_kdump_disks
                                                  )))
  loadbalancers                                 = module.hdb_node.loadbalancers

  subnet_cidr_anf                               = module.hdb_node.ANF_subnet_prefix
  subnet_cidr_app                               = module.app_tier.subnet_cidr_app
  subnet_cidr_client                            = module.common_infrastructure.subnet_cidr_client
  subnet_cidr_db                                = module.common_infrastructure.subnet_cidr_db
  subnet_cidr_storage                           = module.common_infrastructure.subnet_cidr_storage

  #########################################################################################
  #  SAP Application information                                                          #
  #########################################################################################
  bom_name                                      = var.bom_name
  db_sid                                        = local.db_sid
  observer_ips                                  = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.observer_ips) : (
                                                    module.anydb_node.observer_ips
                                                  )
  observer_vms                                  = upper(try(local.database.platform, "HANA")) == "HANA" ? (
                                                    module.hdb_node.observer_vms) : (
                                                    module.anydb_node.observer_vms
                                                  )

  platform                                      = upper(try(local.database.platform, "HANA"))
  sap_sid                                       = local.sap_sid
  web_sid                                       = var.web_sid
  web_instance_number                           = var.web_instance_number

  #########################################################################################
  #  Application tier                                                                     #
  #########################################################################################
  ansible_user                                  = module.common_infrastructure.sid_username
  app_subnet_netmask                            = module.app_tier.app_subnet_netmask
  app_tier_os_types                             = module.app_tier.app_tier_os_types
  application_server_ips                        = module.app_tier.application_server_ips
  application_server_secondary_ips              = module.app_tier.application_server_secondary_ips
  app_vm_names                                  = module.app_tier.app_vm_names
  ers_instance_number                           = var.ers_instance_number
  ers_server_loadbalancer_ip                    = module.app_tier.ers_server_loadbalancer_ip
  pas_instance_number                           = var.pas_instance_number
  app_instance_number                           = var.app_instance_number
  sid_keyvault_user_id                          = module.common_infrastructure.sid_keyvault_user_id
  scs_shared_disks                              = module.app_tier.scs_asd
  scs_cluster_loadbalancer_ip                   = module.app_tier.cluster_loadbalancer_ip
  scs_cluster_type                              = var.scs_cluster_type
  scs_high_availability                         = module.app_tier.scs_high_availability
  scs_instance_number                           = var.scs_instance_number
  scs_server_loadbalancer_ip                    = module.app_tier.scs_server_loadbalancer_ip
  scs_server_ips                                = module.app_tier.scs_server_ips
  scs_server_vm_resource_ids                    = module.app_tier.scs_vm_ids
  scs_server_secondary_ips                      = module.app_tier.scs_server_secondary_ips
  scs_vm_names                                  = module.app_tier.scs_vm_names
  use_local_credentials                         = module.common_infrastructure.use_local_credentials
  use_msi_for_clusters                          = var.use_msi_for_clusters
  use_secondary_ips                             = var.use_secondary_ips
  webdispatcher_server_ips                      = module.app_tier.webdispatcher_server_ips
  webdispatcher_server_secondary_ips            = module.app_tier.webdispatcher_server_secondary_ips
  webdispatcher_server_vm_names                 = module.app_tier.webdispatcher_server_vm_names

  #########################################################################################
  #  Mounting information                                                                 #
  #########################################################################################
  NFS_provider                                  = var.NFS_provider
  sap_mnt                                       = module.common_infrastructure.sapmnt_path
  sap_transport                                 = try(data.terraform_remote_state.landscape.outputs.saptransport_path, "")
  install_path                                  = try(data.terraform_remote_state.landscape.outputs.install_path, "")
  shared_home                                   = var.shared_home
  hana_data                                     = module.hdb_node.hana_data_ANF_volumes
  hana_log                                      = module.hdb_node.hana_log_ANF_volumes
  hana_shared                                   = var.NFS_provider == "ANF" ? module.hdb_node.hana_shared : module.hdb_node.hana_shared_afs_path
  usr_sap                                       = module.common_infrastructure.usrsap_path

  #########################################################################################
  #  DNS information                                                                      #
  #########################################################################################
  dns                                           = try(data.terraform_remote_state.landscape.outputs.dns_label, "")
  use_custom_dns_a_registration                 = try(data.terraform_remote_state.landscape.outputs.use_custom_dns_a_registration, false)
  management_dns_subscription_id                = try(data.terraform_remote_state.landscape.outputs.management_dns_subscription_id, null)
  management_dns_resourcegroup_name             = try(data.terraform_remote_state.landscape.outputs.management_dns_resourcegroup_name, local.SAPLibrary_resource_group_name)
  dns_zone_names                                = var.dns_zone_names
  dns_a_records_for_secondary_names             = var.dns_a_records_for_secondary_names

  #########################################################################################
  #  Server counts                                                                        #
  #########################################################################################
  app_server_count                              = try(local.application_tier.application_server_count, 0)
  db_server_count                               = var.database_server_count + var.stand_by_node_count
  scs_server_count                              = local.application_tier.scs_high_availability ? (
                                                  2 * local.application_tier.scs_server_count) : (
                                                  local.application_tier.scs_server_count
                                                  )
  web_server_count                              = try(local.application_tier.webdispatcher_count, 0)

  #########################################################################################
  #  Miscallaneous                                                                        #
  #########################################################################################
  use_simple_mount                              = local.validated_use_simple_mount
  upgrade_packages                              = var.upgrade_packages
  scale_out                                     = var.database_HANA_use_scaleout_scenario
  scale_out_no_standby_role                     = var.database_HANA_no_standby_role

  #########################################################################################
  #  iSCSI                                                                                #
  #########################################################################################
  iSCSI_server_ips                              = var.database_cluster_type == "ISCSI" || var.scs_cluster_type == "ISCSI" ? data.terraform_remote_state.landscape.outputs.iSCSI_server_ips : []
  iSCSI_server_names                            = var.database_cluster_type == "ISCSI" || var.scs_cluster_type == "ISCSI" ? data.terraform_remote_state.landscape.outputs.iSCSI_server_names : []
  iSCSI_servers                                 = var.database_cluster_type == "ISCSI" || var.scs_cluster_type == "ISCSI" ? data.terraform_remote_state.landscape.outputs.iSCSI_servers : []

  #########################################################################################
  #  AMS                                                                                  #
  #########################################################################################
  ams_resource_id                               = try(coalesce(var.ams_resource_id, try(data.terraform_remote_state.landscape.outputs.ams_resource_id, "")),"")
  enable_ha_monitoring                          = var.enable_ha_monitoring
  enable_os_monitoring                          = var.enable_os_monitoring

  #########################################################################################
  #  SAP CAL                                                                              #
  #########################################################################################
  enable_sap_cal                                = var.enable_sap_cal
  calapi_kv                                     = var.calapi_kv
  sap_cal_product_name                          = var.sap_cal_product_name

  site_information                              = module.hdb_node.site_information
}
