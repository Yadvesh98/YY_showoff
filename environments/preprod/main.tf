module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "preprod-rg"
  rg_location = "East US"
}
module "storage_account" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_storage_account"
  stg_name   = "preprodstorageacct"
  rg_name    = "preprod-rg"
  location   = "East US"
  account_tier = "Standard"
  account_replication_type = "LRS"

}
module "vnet" {
  depends_on    = [module.rg]
  source        = "../../modules/azurerm_virtual_network"
  vnet_name     = "preprod-vnet"
  vnet_location = "East US"
  rg_name       = "preprod-rg"
  address_space = ["10.0.0.0/16"]

}
module "subnet" {
  depends_on       = [module.vnet]
  source           = "../../modules/azurerm_subnet"
  snet_name        = "preprod-subnet"
  rg_name          = "preprod-rg"
  vnet_name        = "preprod-vnet"
  address_prefixes = ["10.0.2.0/24"]

}

module "pip" {
  depends_on  = [module.subnet]
  source      = "../../modules/azurerm_public_ip"
  pip_name    = "preprod-pip"
  rg_name     = "preprod-rg"
  rg_location = "East US"

}

module "vm" {
  depends_on = [module.pip]
  source     = "../../modules/azurerm_linux_vm"
  vm_name    = "preprod-vm"
  rg_name    = "preprod-rg"
  location   = "East US"
  nic_name   = "preprod-nic"
  subnet_id  = "module.subnet.subnet_id"
  size       = "Standard_DS1_v2"
  username   = "azureuser"
  password   = "P@ssw0rd1234!"
}

module "sql_server" {
  depends_on  = [module.vm]
  source      = "../../modules/azurerm_sql_server"
  server_name = "preprod-sql-server"
  rg_name     = "preprod-rg"
  rg_location = "East US"
  username    = "sqladmin"
  password    = "P@ssw0rd1234!"
}

module "sql_db" {
  depends_on    = [module.sql_server]
  source        = "../../modules/azurerm_sql_database"
  sql_db_name   = "preprod-sql-db"
  sql_server_id = "module.sql_server.sql_server_id"


}


module "key_vault" {
  depends_on = [module.sql_db]
  source     = "../../modules/azurerm_key_vault"
  kv_name    = "preprod-kv"
  rg_name    = "preprod-rg"
  location   = "East US"
  tenant_id  = "data.azurerm_client_config.current.tenant_id"
}
