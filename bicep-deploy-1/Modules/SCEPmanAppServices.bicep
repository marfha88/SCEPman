
// Location of resources
param location string

// Tags
param tags object

// appServicePlan
param appServicePlanName string
param skuName string
param skuCapacity int


// appService
param AppServiceName string
param certificateMasterAppServiceName string
param storageAccountName string
param license string
param keyVaultName string 
param orgName string
param caKeyType string

// Site configuration
var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var ArtifactsLocationCertMaster = uri(artifactsRepositoryUrl, 'dist-certmaster/CertMaster-Artifacts.zip')
var TableStorageEndpoint = 'https://${storageAccountName}.table.${environment().suffixes.storage}/'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/'


//######################################################### Here Resource creation begin test #####################################################
@description('SCEPmanAppServicesplan is created here')
resource SCEPmanAppServicesplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  kind: 'app'
  location: location
  name: appServicePlanName
  sku: {
    capacity: skuCapacity
    name: skuName
  }
}

@description('SCEPmanAppService is created here')
resource SCEPmanAppService 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: AppServiceName
  properties: {
    serverFarmId: SCEPmanAppServicesplan.id
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
  }  
  tags: tags
}

@description('App config')
resource SCEPmanAppServiceconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppService
  properties: {
    /*'AppConfig:AuthConfig:ApplicationId': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityEnabledForWebsiteHostname': '${AppServiceName}.azurewebsites.net' // // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityPermissionLevel': '2' // fil in after powershell script */
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': 'https://${AppServiceName}.azurewebsites.net/'
    // 'AppConfig:CertificateStorage:TableStorageEndpoint': TableStorageEndpoint // fil in after powershell script
    // 'AppConfig:CertMaster:URL': '${certificateMasterAppServiceName}.azurewebsites.net' // fil in after powershell script
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:KeyType': caKeyType
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${subscription().tenantId}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman
   }
}

@description('certificateMasterAppService is created here')
resource SCEPmanAppServiceCm 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: certificateMasterAppServiceName
  properties: {    
    serverFarmId: SCEPmanAppServicesplan.id
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
    }
  }
  tags: tags
}

@description('App config Certifaicate Master')
resource SCEPmanAppServiceconfigCm 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceCm
  properties: {
    /*'AppConfig:AuthConfig:ApplicationId': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': 'info from portal' // fil in after powershell script
    'AppConfig:AuthConfig:ManagedIdentityPermissionLevel': '2' // fil in after powershell script
    'AppConfig:AuthConfig:SCEPmanAPIScope': 'info from portal' // fil in after powershell script */
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:SCEPman:URL': 'https://${AppServiceName}.azurewebsites.net/'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationCertMaster 
   }
}


@description('Outputs for serviceprincipals')
output SCEPmanAppServicespid string = SCEPmanAppService.identity.principalId
output SCEPmanAppServicid string = SCEPmanAppService.id
output SCEPmanAppServiceCmspid string = SCEPmanAppServiceCm.identity.principalId






