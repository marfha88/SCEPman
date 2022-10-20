@description('Location for resources. For a manual deployment, we recommend the default value.')
param location string = resourceGroup().location


@description('Tenant, Subscription and Resource Groups')
param tenant string = 'c39d49f7-9eed-4307-b032-bb28f3cf9d79'


@description('Name of the Company or Organization used for the Certificate Subject')
param orgName string = 'Martin Company'

@description('Adds time to tags')
param utctime string = utcNow('yyyyMMddTHHmm')

@description('List of tags passed from main to modules')
param tags object = {
  deployment:  'bicep'
  createdby: 'Martin'
  SCEPmanVersion: '2.1.522'
  updatedTime: utctime
}

// Storage Account
@description('Choose a globally unique name for your storage account. Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.')
param storageAccountName string = 'stgscepmanmartin'

// License
@description('License Key for SCEPman')
param license string = 'Trial' // change to your license

// Key vault parameters
@description('Specifies the name of the Azure Key Vault. The name of a Key Vault must be globally unique and contain only DNS-compatible characters (letters, numbers, and hyphens).')
param keyVaultName string = 'kv-scepman-martin'

//  Web app and app service plan
@description(' AppService')
param appServicePlanName string = 'asp-scepman-martin'
param skuName string = 'S1'
param skuCapacity int = 1


@description('The SCEPman  App Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
param AppServiceName string = 'as-scepman-martin'

@description('The App Service for the component SCEPman Certificate Master. As it is part of the default FQDN, it must be globally unique and contain only DNS-compatible characters.')
param certificateMasterAppServiceName string = 'as-scepman-martin-cm'

// Here Resource creation begin test
module SCEPmanWebApp 'Modules/SCEPmanAppServices.bicep' = {
  name: 'SCEPmanWebApp'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    AppServiceName: AppServiceName
    skuName: skuName
    skuCapacity: skuCapacity
    certificateMasterAppServiceName: certificateMasterAppServiceName
    tenant: tenant
    storageAccountName: storageAccountName
    license: license
    keyVaultName: keyVaultName  
    orgName: orgName
    tags: tags
  }
}

@description('Storage account for scepman')
module StorageAccount 'Modules/SCEPmanStorageaccount.bicep' = {
  name: storageAccountName
  params: {
    location: location
    resourceTags: tags
    StorageAccountName: storageAccountName
    tableContributorPrincipals: [
      SCEPmanWebApp.outputs.SCEPmanAppServicespid
      SCEPmanWebApp.outputs.SCEPmanAppServiceCmspid
    ]
  }
}


module SCEPmanVault 'Modules/SCEPmanVault.bicep' = {
  name: 'SCEPmanVault'
  params: {
    tenant: tenant
    keyVaultName: keyVaultName
    AppServicspid: SCEPmanWebApp.outputs.SCEPmanAppServicespid
    location: location
    tags: tags
  }
}
