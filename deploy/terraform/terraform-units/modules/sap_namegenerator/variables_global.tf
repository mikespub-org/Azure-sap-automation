# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


variable "environment" {
  description = "Environment type (Prod, Test, Sand, QA)"
}

variable "library_environment" {
  description = "SAP Library environment type (Prod, Test, Sand, QA)"
  default     = ""
}

variable "deployer_environment" {
  description = "Deployer environment type (Prod, Test, Sand, QA)"
  default     = ""
}

variable "landscape_environment" {
  description = "Landscape environment type (Prod, Test, Sand, QA)"
  default     = ""
}

variable "location" {
  description = "Azure region"
}

variable "codename" {
  description = "Code name of application (optional)"
  default     = ""
}

variable "management_vnet_name" {
  description = "Name of Management vnet"
  default     = ""
}

variable "sap_vnet_name" {
  description = "Name of SAP vnet"
  default     = ""
}

variable "sap_sid" {
  description = "SAP SID"
  default     = ""
}

variable "web_sid" {
  description = "Web Dispatcher SID"
  default     = ""
}

variable "db_sid" {
  description = "Database SID"
  default     = ""
}

variable "random_id" {
  type        = string
  description = "Random hex string"
}

variable "db_ostype" {
  description = "Database operating system"
  default     = "LINUX"
}

variable "app_ostype" {
  description = "Application Server operating system"
  default     = "LINUX"
}

variable "db_platform" {
  description = "AnyDB platform type (Oracle, DB2, SQLServer, ASE)"
  default     = "HANA"
}

variable "anchor_ostype" {
  description = "Anchor Server operating system"
  default     = "LINUX"
}

variable "app_server_count" {
  description = "Number of Application Servers"
  type    = number
  default = 1
}

variable "scs_server_count" {
  description = "Number of SCS Servers"
  type    = number
  default = 1
}

variable "web_server_count" {
  description = "Number of Web Dispatchers"
  type    = number
  default = 1
}


variable "db_server_count" {
  description = "Number of Database Servers"
  type    = number
  default = 1
}

variable "iscsi_server_count" {
  type    = number
  default = 1
}

variable "deployer_vm_count" {
  type    = number
  default = 1
}

variable "resource_offset" {
  type    = number
  default = 0
}

variable "database_high_availability" {
  type    = bool
  default = false
}

variable "database_cluster_type" {
  description   = "Cluster quorum type; AFA (Azure Fencing Agent), ASD (Azure Shared Disk), ISCSI"
  default       = "AFA"
}

variable "scs_high_availability" {
  type    = bool
  default = false
}

variable "scs_cluster_type" {
  description   = "Cluster quorum type; AFA (Azure Fencing Agent), ASD (Azure Shared Disk), ISCSI"
  default       = "AFA"
}

variable "use_zonal_markers" {
  type    = bool
  default = true
}

//Todo: Add to documentation
variable "sapautomation_name_limits" {
  description = "Name length for automation resources"
  default = {
    environment_variable_length = 5
    sap_vnet_length             = 7
    random_id_length            = 3
    sdu_name_length             = 80
  }
}

//Todo: Add to documentation
variable "azlimits" {
  description = "Name length for resources"
  default = {
    asr         = 50
    aaa         = 50
    acr         = 49
    afw         = 50
    rg          = 80
    kv          = 24
    stgaccnt    = 24
    vnet        = 38
    nsg         = 80
    snet        = 80
    nic         = 80
    vml         = 64
    vmw         = 15
    vm          = 80
    functionapp = 60
    lb          = 80
    lbrule      = 80
    evh         = 50
    la          = 63
    pip         = 80
    peer        = 80
    gen         = 24
  }
}

variable "region_mapping" {
  type        = map(string)
  description = "Region Mapping: Full = Single CHAR, 4-CHAR"
  # 42 Regions
  default = {
    "australiacentral"   = "auce"
    "australiacentral2"  = "auc2"
    "australiaeast"      = "auea"
    "australiasoutheast" = "ause"
    "brazilsouth"        = "brso"
    "brazilsoutheast"    = "brse"
    "brazilus"           = "brus"
    "canadacentral"      = "cace"
    "canadaeast"         = "caea"
    "centralindia"       = "cein"
    "centralus"          = "ceus"
    "centraluseuap"      = "ceua"
    "eastasia"           = "eaas"
    "eastus"             = "eaus"
    "eastus2"            = "eus2"
    "eastus2euap"        = "eusa"
    "eastusstg"          = "eusg"
    "francecentral"      = "frce"
    "francesouth"        = "frso"
    "germanynorth"       = "geno"
    "germanywestcentral" = "gewc"
    "israelcentral"      = "isce"
    "italynorth"         = "itno"
    "japaneast"          = "jaea"
    "japanwest"          = "jawe"
    "jioindiacentral"    = "jinc"
    "jioindiawest"       = "jinw"
    "koreacentral"       = "koce"
    "koreasouth"         = "koso"
    "northcentralus"     = "ncus"
    "northeurope"        = "noeu"
    "norwayeast"         = "noea"
    "norwaywest"         = "nowe"
    "newzealandnorth"   =  "nzno"
    "polandcentral"      = "plce"
    "qatarcentral"       = "qace"
    "southafricanorth"   = "sano"
    "southafricawest"    = "sawe"
    "southcentralus"     = "scus"
    "southcentralusstg"  = "scug"
    "southeastasia"      = "soea"
    "southindia"         = "soin"
    "swedencentral"      = "sece"
    "swedensouth"        = "seso"
    "switzerlandnorth"   = "swno"
    "switzerlandwest"    = "swwe"
    "uaecentral"         = "uace"
    "uaenorth"           = "uano"
    "uksouth"            = "ukso"
    "ukwest"             = "ukwe"
    "westcentralus"      = "wcus"
    "westeurope"         = "weeu"
    "westindia"          = "wein"
    "westus"             = "weus"
    "westus2"            = "wus2"
    "westus3"            = "wus3"
    "newzealandnorth"    = "nzno"
  }
}

variable "resource_prefixes" {
  type        = map(string)
  description = "Prefix of resource name"

  default = {
    "admin_nic"                      = ""
    "admin_subnet"                   = ""
    "admin_subnet_nsg"               = ""
    "agent_subnet"                   = ""
    "ams_subnet"                     = ""
    "anf_subnet"                     = ""
    "anf_subnet_nsg"                 = ""
    "ansible"                        = ""
    "app_alb"                        = ""
    "app_asg"                        = ""
    "app_avset"                      = ""
    "app_service_plan"               = ""
    "app_subnet"                     = ""
    "app_subnet_nsg"                 = ""
    "appconfig_private_link"         = ""
    "appconfig_private_svc"          = ""
    "appconfig_link"                 = ""
    "bastion_host"                   = ""
    "bastion_pip"                    = ""
    "database_cluster_disk"          = ""
    "db_alb"                         = ""
    "db_alb_bepool"                  = ""
    "db_alb_feip"                    = ""
    "db_alb_hp"                      = ""
    "db_alb_rule"                    = ""
    "db_asg"                         = ""
    "db_avset"                       = ""
    "db_clst_feip"                   = ""
    "db_nic"                         = ""
    "db_rlb_feip"                    = ""
    "db_rlb_hp"                      = ""
    "db_rlb_rule"                    = ""
    "db_subnet"                      = ""
    "db_subnet_nsg"                  = ""
    "deployer_rg"                    = ""
    "deployer_state"                 = ""
    "deployer_subnet"                = ""
    "deployer_subnet_nsg"            = ""
    "deployer_web-subnet"            = ""
    "dev_center"                     = ""
    "disk"                           = ""
    "dns_link"                       = ""
    "ers_alb_bepool"                 = ""
    "fencing_agent_id"               = ""
    "fencing_agent_pwd"              = ""
    "fencing_agent_spn"              = ""
    "fencing_agent_sub"              = ""
    "fencing_agent_tenant"           = ""
    "firewall"                       = ""
    "firewall_rule_app"              = ""
    "firewall_rule_db"               = ""
    "fw_route"                       = ""
    "hana_avg"                       = ""
    "hanadata"                       = ""
    "hanalog"                        = ""
    "hanashared"                     = ""
    "install_volume"                 = ""
    "install_volume_smb"             = ""
    "iscsi_subnet"                   = ""
    "iscsi_subnet_nsg"               = ""
    "keyvault_private_link"          = ""
    "keyvault_private_svc"           = ""
    "kv"                             = ""
    "library_rg"                     = ""
    "library_state"                  = ""
    "msi"                            = ""
    "nat_gateway"                    = ""
    "netapp_account"                 = ""
    "netapp_pool"                    = ""
    "nic"                            = ""
    "osdisk"                         = ""
    "pip"                            = ""
    "ppg"                            = ""
    "routetable"                     = ""
    "sapbits"                        = ""
    "sapmnt"                         = ""
    "sapmnt_smb"                     = ""
    "scs_alb"                        = ""
    "scs_alb_bepool"                 = ""
    "scs_alb_feip"                   = ""
    "scs_alb_hp"                     = ""
    "scs_alb_rule"                   = ""
    "scs_avset"                      = ""
    "scs_clst_feip"                  = ""
    "scs_clst_hp"                    = ""
    "scs_clst_rule"                  = ""
    "scs_cluster_disk"               = ""
    "scs_ers_feip"                   = ""
    "scs_ers_hp"                     = ""
    "scs_ers_rule"                   = ""
    "scs_fs_feip"                    = ""
    "scs_fs_hp"                      = ""
    "scs_fs_rule"                    = ""
    "scs_scs_rule"                   = ""
    "sdu_rg"                         = ""
    "sdu_secret"                     = ""
    "storage_nic"                    = ""
    "storage_private_link_diag"      = ""
    "storage_private_link_install"   = ""
    "storage_private_link_sap"       = ""
    "storage_private_link_sapmnt"    = ""
    "storage_private_link_tf"        = ""
    "storage_private_link_transport" = ""
    "storage_private_link_witness"   = ""
    "storage_private_svc_diag"       = ""
    "storage_private_svc_install"    = ""
    "storage_private_svc_sap"        = ""
    "storage_private_svc_sapmnt"     = ""
    "storage_private_svc_tf"         = ""
    "storage_private_svc_transport"  = ""
    "storage_private_svc_witness"    = ""
    "storage_privatelink_hanashared" = ""
    "storage_subnet"                 = ""
    "storage_subnet_nsg"             = ""
    "tfstate"                        = ""
    "transport_volume"               = ""
    "usrsap"                         = ""
    "vm"                             = ""
    "vmss"                           = ""
    "vnet"                           = ""
    "vnet_rg"                        = ""
    "web_alb"                        = ""
    "web_alb_bepool"                 = ""
    "web_alb_feip"                   = ""
    "web_alb_hp"                     = ""
    "web_alb_inrule"                 = ""
    "web_asg"                        = ""
    "web_avset"                      = ""
    "web_subnet"                     = ""
    "web_subnet_nsg"                 = ""
    "witness"                        = ""
    "witness_accesskey"              = ""
    "witness_name"                   = ""
  }
}

//Todo: Add to documentation
variable "resource_suffixes" {
  type        = map(string)
  description = "Extension of resource name"

  default = {
    "admin_nic"                      = "-admin-nic"
    "admin_subnet"                   = "admin-subnet"
    "admin_subnet_nsg"               = "adminSubnet-nsg"
    "agent_subnet"                   = "_agent-subnet"
    "ams_instance"                   = "-AMS"
    "ams_subnet"                     = "ams-subnet"
    "anf_subnet"                     = "anf-subnet"
    "anf_subnet_nsg"                 = "anfSubnet-nsg"
    "ansible"                        = "ansible"
    "app_alb"                        = "app-alb"
    "app_asg"                        = "app-asg"
    "app_avset"                      = "app-avset"
    "app_service_plan"               = "-app-service-plan"
    "app_subnet"                     = "app-subnet"
    "app_subnet_nsg"                 = "appSubnet-nsg"
    "appconfig_private_link"         = "-appconfig-private-endpoint"
    "appconfig_private_svc"          = "-appconfig-private-service"
    "appconfig_link"                 = "appconfig-link"
    "bastion_host"                   = "bastion-host"
    "bastion_pip"                    = "bastion-pip"
    "database_cluster_disk"          = "db-cluster-disk"
    "db_alb"                         = "db-alb"
    "db_alb_bepool"                  = "dbAlb-bePool"
    "db_alb_feip"                    = "dbAlb-feip"
    "db_alb_hp"                      = "dbAlb-hp"
    "db_alb_rule"                    = "dbAlb-rule"
    "db_asg"                         = "db-asg"
    "db_avset"                       = "db-avset"
    "db_clst_feip"                   = "dbClst-feip"
    "db_nic"                         = "-db-nic"
    "db_rlb_feip"                    = "dbRlb-feip"
    "db_rlb_hp"                      = "dbRlb-hp"
    "db_rlb_rule"                    = "dbRlb-rule"
    "db_subnet"                      = "db-subnet"
    "db_subnet_nsg"                  = "dbSubnet-nsg"
    "deployer_rg"                    = "-INFRASTRUCTURE"
    "deployer_state"                 = "_DEPLOYER.terraform.tfstate"
    "deployer_subnet"                = "_deployment-subnet"
    "deployer_subnet_nsg"            = "_deployment-nsg"
    "deployer_web-subnet"            = "_deployment-web-subnet"
    "deployment_objects"             = "-deployment-objects"
    "dev_center"                     = "-devcenter"
    "disk"                           = ""
    "dns_link"                       = "dns-link"
    "ers_alb_bepool"                 = "ersAlb-bePool"
    "fencing_agent_id"               = "-fencing-spn-id"
    "fencing_agent_pwd"              = "-fencing-spn-pwd"
    "fencing_agent_spn"              = "fencing-agent"
    "fencing_agent_sub"              = "-fencing-spn-subscription"
    "fencing_agent_tenant"           = "-fencing-spn-tenant"
    "firewall"                       = "firewall"
    "firewall_rule_app"              = "firewall-rule-app"
    "firewall_rule_db"               = "firewall-rule-db"
    "fw_route"                       = "firewall-route"
    "hana_avg"                       = "hana-avg"
    "hanadata"                       = "hanadata"
    "hanalog"                        = "hanalog"
    "hanashared"                     = "hanashared"
    "hanasharedafs"                  = "hanashared"
    "install_volume"                 = "install"
    "install_volume_smb"             = "install-smb"
    "iscsi_subnet"                   = "iscsi-subnet"
    "iscsi_subnet_nsg"               = "iscsiSubnet-nsg"
    "keyvault_private_link"          = "-keyvault-private-endpoint"
    "keyvault_private_svc"           = "-keyvault-private-service"
    "kv"                             = ""
    "library_rg"                     = "-SAP_LIBRARY"
    "library_state"                  = "_SAP-LIBRARY.terraform.tfstate"
    "msi"                            = "-msi"
    "nat_gateway"                    = "-nat-gateway"
    "netapp_account"                 = "netapp_account"
    "netapp_pool"                    = "netapp_pool"
    "nic"                            = "-nic"
    "osdisk"                         = "-OsDisk"
    "pip"                            = "-pip"
    "ppg"                            = "-ppg"
    "routetable"                     = "route-table"
    "sapbits"                        = "sapbits"
    "sapmnt"                         = "sapmnt"
    "sapmnt_smb"                     = "sapmnt-smb"
    "scs_alb"                        = "scs-alb"
    "scs_alb_bepool"                 = "scsAlb-bePool"
    "scs_alb_feip"                   = "scsAlb-feip"
    "scs_alb_hp"                     = "scsAlb-hp"
    "scs_alb_rule"                   = "scsAlb-rule"
    "scs_avset"                      = "scs-avset"
    "scs_clst_feip"                  = "scsClst-feip"
    "scs_clst_hp"                    = "scsClst-hp"
    "scs_clst_rule"                  = "scsClst-rule"
    "scs_cluster_disk"               = "scs-cluster-disk"
    "scs_ers_feip"                   = "scsErs-feip"
    "scs_ers_hp"                     = "scsErs-hp"
    "scs_ers_rule"                   = "scsErs-rule"
    "scs_fs_feip"                    = "scsFs-feip"
    "scs_fs_hp"                      = "scsFs-hp"
    "scs_fs_rule"                    = "scsFs-rule"
    "scs_scs_rule"                   = "scsScs-rule"
    "sdu_rg"                         = ""
    "sdu_secret"                     = ""
    "storage_nic"                    = "-storage-nic"
    "storage_private_link_diag"      = "-diag-storage-private-endpoint"
    "storage_private_link_install"   = "-install-storage-private-endpoint"
    "storage_private_link_sap"       = "-sap-storage-private-endpoint"
    "storage_private_link_sapmnt"    = "-sapmnt-storage-private-endpoint"
    "storage_private_link_tf"        = "-tf-storage-private-endpoint"
    "storage_private_link_transport" = "-transport-storage-private-endpoint"
    "storage_private_link_witness"   = "-witness-storage-private-endpoint"
    "storage_private_svc_diag"       = "-diag-storage-private-service"
    "storage_private_svc_install"    = "-install-storage-private-service"
    "storage_private_svc_sap"        = "-sap-storage-private-service"
    "storage_private_svc_sapmnt"     = "-sapmnt-storage-private-service"
    "storage_private_svc_tf"         = "-tf-storage-private-service"
    "storage_private_svc_transport"  = "-transport-storage-private-service"
    "storage_private_svc_witness"    = "-witness-storage-private-service"
    "storage_privatelink_hanashared" = "-hanashared-storage-private-endpoint"
    "storage_subnet"                 = "storage-subnet"
    "storage_subnet_nsg"             = "storageSubnet-nsg"
    "tfstate"                        = "tfstate"
    "transport_volume"               = "transport"
    "usrsap"                         = "usrsap"
    "vm"                             = ""
    "vmss"                           = "-vmss"
    "vnet"                           = "-vnet"
    "vnet_rg"                        = "-INFRASTRUCTURE"
    "web_alb"                        = "web-alb"
    "web_alb_bepool"                 = "webAlb-bePool"
    "web_alb_feip"                   = "webAlb-feip"
    "web_alb_hp"                     = "webAlb-hp"
    "web_alb_inrule"                 = "webAlb-inRule"
    "web_asg"                        = "web-asg"
    "web_avset"                      = "web-avset"
    "web_subnet"                     = "web-subnet"
    "web_subnet_nsg"                 = "webSubnet-nsg"
    "webapp_url"                     = "-sapdeployment"
    "witness"                        = "-witness"
    "witness_accesskey"              = "-witness-accesskey"
    "witness_name"                   = "-witness-name"
  }
}

variable "app_zones" {
  type        = list(string)
  description = "List of availability zones for application tier"
  default     = []
}

variable "scs_zones" {
  type        = list(string)
  description = "List of availability zones for scs tier"
  default     = []
}

variable "web_zones" {
  type        = list(string)
  description = "List of availability zones for web tier"
  default     = []
}

variable "db_zones" {
  type        = list(string)
  description = "List of availability zones for db tier"
  default     = []
}

variable "custom_prefix" {
  type        = string
  description = "Custom prefix"
  default     = ""
}

variable "use_prefix" {
  type        = bool
  description = "Use prefix"
  default     = true
}


variable "deployer_location" {
  description = "Deployer Azure region"
  default     = ""
}

variable "utility_vm_count" {
  type    = number
  default = 0
}

variable "scale_out" {
  type    = bool
  default = false
}
