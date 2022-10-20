@description('Name of the Company or Organization used for the Certificate Subject')
@minLength(2)
param OrgName string

@description('License Key for SCEPman')
param license string = 'trial'

@description('Specifies the name of the Azure Key Vault. The name of a Key Vault must be globally unique and contain only DNS-compatible characters (letters, numbers, and hyphens).')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'kv-scepman-UNIQUENAME'

@description('When generating the SCEPman CA certificate, which kind of key pair shall be created? RSA is a software-protected RSA key; RSA-HSM is HSM-protected.')
@allowed([
  'RSA'
  'RSA-HSM'
])
param caKeyType string = 'RSA-HSM'

@description('Choose a globally unique name for your storage account. Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stgscepmanUNIQUENAME'

@maxLength(40)
param appServicePlanName string = 'asp-scepman-UNIQUENAME'

@description('Provide the AppServicePlan ID of an existing App Service Plan. Keep default value \'none\' if you want to create a new one.')
param existingAppServicePlanID string = 'none'

@description('The SCEPman App Service and part of the default FQDN. Therefore, it must be globally unique and contain only DNS-compatible characters.')
@maxLength(60)
param primaryAppServiceName string = 'as-scepman-UNIQUENAME'

@description('The App Service for the component SCEPman Certificate Master. As it is part of the default FQDN, it must be globally unique and contain only DNS-compatible characters.')
@maxLength(60)
param certificateMasterAppServiceName string = 'as-scepman-UNIQUENAME-cm'

@description('Location for all resources. For a manual deployment, we recommend the default value.')
param location string = resourceGroup().location

@description('Tags to be assigned to all created resources. Use JSON syntax, e.g. if you want to add tags env with value dev and project with value scepman, then write { "env":"dev", "project":"scepman"}.')
param resourceTags object = {
}

var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var ArtifactsLocationCertMaster = uri(artifactsRepositoryUrl, 'dist-certmaster/CertMaster-Artifacts.zip')
var templateRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/prod/'
var appSvcTemplateUri = uri(templateRepositoryUrl, 'nestedtemplates/appSvcDouble.json')
var vaultTemplateUri = uri(templateRepositoryUrl, 'nestedtemplates/vault.json')
var appConfigTemplateUri = uri(templateRepositoryUrl, 'nestedtemplates/appConfig-scepman.json')
var appConfigCertMasterTemplateUri = uri(templateRepositoryUrl, 'nestedtemplates/appConfig-certmaster.json')
var stgAccountTemplateUri = uri(templateRepositoryUrl, 'nestedtemplates/stgAccount.json')

module pid_a262352f_52a9_4ed9_a9ba_6a2b2478d19b_partnercenter './nested_pid_a262352f_52a9_4ed9_a9ba_6a2b2478d19b_partnercenter.bicep' = {
  name: 'pid-a262352f-52a9-4ed9-a9ba-6a2b2478d19b-partnercenter'
  params: {
  }
}

module SCEPmanAppServices '?' /*TODO: replace with correct path to [variables('appSvcTemplateUri')]*/ = {
  name: 'SCEPmanAppServices'
  params: {
    AppServicePlanName: appServicePlanName
    existingAppServicePlanID: existingAppServicePlanID
    appServiceName: primaryAppServiceName
    appServiceName2: certificateMasterAppServiceName
    location: location
    resourceTags: resourceTags
  }
}

module SCEPmanVault '?' /*TODO: replace with correct path to [variables('vaultTemplateUri')]*/ = {
  name: 'SCEPmanVault'
  params: {
    keyVaultName: keyVaultName
    permittedPrincipalId: SCEPmanAppServices.properties.outputs.scepmanPrincipalID.value
    location: location
    resourceTags: resourceTags
  }
}

module DeploymentSCEPmanConfig '?' /*TODO: replace with correct path to [variables('appConfigTemplateUri')]*/ = {
  name: 'DeploymentSCEPmanConfig'
  params: {
    StorageAccountTableUrl: SCEPmanStorageAccount.properties.outputs.storageAccountTableUrl.value
    appServiceName: primaryAppServiceName
    scepManBaseURL: SCEPmanAppServices.properties.outputs.scepmanURL.value
    keyVaultURL: SCEPmanVault.properties.outputs.keyVaultURL.value
    caKeyType: caKeyType
    OrgName: OrgName
    WebsiteArtifactsUri: ArtifactsLocationSCEPman
    license: license
    location: location
  }
}

module DeploymentCertMasterConfig '?' /*TODO: replace with correct path to [variables('appConfigCertMasterTemplateUri')]*/ = {
  name: 'DeploymentCertMasterConfig'
  params: {
    appServiceName: certificateMasterAppServiceName
    scepmanUrl: SCEPmanAppServices.properties.outputs.scepmanURL.value
    StorageAccountTableUrl: SCEPmanStorageAccount.properties.outputs.storageAccountTableUrl.value
    WebsiteArtifactsUri: ArtifactsLocationCertMaster
    location: location
  }
}

module SCEPmanStorageAccount '?' /*TODO: replace with correct path to [variables('stgAccountTemplateUri')]*/ = {
  name: 'SCEPmanStorageAccount'
  params: {
    StorageAccountName: storageAccountName
    location: location
    resourceTags: resourceTags
    tableContributorPrincipals: [
      SCEPmanAppServices.properties.outputs.scepmanPrincipalID.value
      SCEPmanAppServices.properties.outputs.certmasterPrincipalID.value
    ]
  }
}