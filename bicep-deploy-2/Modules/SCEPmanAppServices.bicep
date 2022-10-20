// Location of resources
param location string

// appServicePlan
param appServicePlanName string
param skuName string
param skuCapacity int
param autoscalesettings_asp_scepman_name string

// appService
param primaryAppServiceName string
param certificateMasterAppServiceName string
param tenant string
param storageAccountName string
param license string
param keyVaultName string 
param orgName string

// Site configuration
var artifactsRepositoryUrl = 'https://raw.githubusercontent.com/scepman/install/master/'
var ArtifactsLocationSCEPman = uri(artifactsRepositoryUrl, 'dist/Artifacts.zip')
var ArtifactsLocationCertMaster = uri(artifactsRepositoryUrl, 'dist-certmaster/CertMaster-Artifacts.zip')
var TableStorageEndpoint = 'https://${storageAccountName}.table.${environment().suffixes.storage}'
var PrimaryBaseUrl = 'https://${primaryAppServiceName}.azurewebsites.net/'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'

// Tags
param tags object

@description('SCEPmanAppServicesplan is created here')
resource SCEPmanAppServicesplan 'Microsoft.Web/serverfarms@2021-03-01' = {
  kind: 'app'
  location: location
  name: appServicePlanName
  sku: {
    capacity: skuCapacity
    name: skuName
  }
}

resource autoscalesettings_asp_scepman 'microsoft.insights/autoscalesettings@2021-05-01-preview' = {
  location: location
  name: autoscalesettings_asp_scepman_name
  properties: {
    enabled: false
    name: autoscalesettings_asp_scepman_name
    notifications: []
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles: [
      {
        capacity: {
          default: '1'
          maximum: '1'
          minimum: '1'
        }
        name: 'Auto created scale condition'
        rules: [
          {
            metricTrigger: {
              dimensions: []
              dividePerInstance: true
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: SCEPmanAppServicesplan.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: '70'
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
            }
            scaleAction: {
              cooldown: 'PT15M'
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
            }
          }
          {
            metricTrigger: {
              dimensions: []
              dividePerInstance: true
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: SCEPmanAppServicesplan.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: '35'
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT20M'
            }
            scaleAction: {
              cooldown: 'PT30M'
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
            }
          }
        ]
      }
    ]
    targetResourceUri: SCEPmanAppServicesplan.id
  }
}

@description('primaryAppService is created here')
resource SCEPmanAppService 'Microsoft.Web/sites@2021-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: primaryAppServiceName
  properties: {
    serverFarmId: SCEPmanAppServicesplan.id
  }
  tags: tags
}

resource SCEPmanAppServiceconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppService
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': PrimaryBaseUrl
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:KeyVaultConfig:KeyVaultURL': KeyVaultURL
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${tenant}, O="${orgName}"'
    'AppConfig:LicenseKey': license
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:ValidityPeriodDays': '730'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman
    'AppConfig:AuthConfig:ApplicationId': 'd38f73b6-9900-4fe0-a935-f3b7e1fa4629'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1652165724'
   }
}

@description('certificateMasterAppService is created here')
resource SCEPmanAppServiceCm 'Microsoft.Web/sites@2021-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app'
  location: location
  name: certificateMasterAppServiceName
  properties: {    
    serverFarmId: SCEPmanAppServicesplan.id
    clientCertEnabled: true
    customDomainVerificationId: '*.innovasjonnorge.no,innovasjonnorge.no (76FF1F0F0E9B76C101658972AD33A8296859B86C)'
    hostNameSslStates: [
      {
        sslState: 'SniEnabled'
      }
    ]
  }
  tags: tags
}

resource SCEPmanAppServiceconfigCm 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceCm
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:SCEPman:URL': PrimaryBaseUrl
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationCertMaster 
   }
}

@description('Outputs for serviceprincipals')
output SCEPmanAppServicespid string = SCEPmanAppService.identity.principalId
output SCEPmanAppServiceCmspid string = SCEPmanAppServiceCm.identity.principalId
