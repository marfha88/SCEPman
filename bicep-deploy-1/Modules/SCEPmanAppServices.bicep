
// Location of resources
param location string

// Tags
param tags object

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
// var PrimaryBaseUrl = 'https://${primaryAppServiceName}.azurewebsites.net/'
var KeyVaultURL = 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'

// Certificate
param thumbprint string

// Application Insight
param InstrumentationKey string
param ConnectionString string

//######################################################### Here Resource creation begin test #####################################################
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

@description('Autoscale is created here')
resource autoscalesettings_asp_scepman 'microsoft.insights/autoscalesettings@2021-05-01-preview' = {
  location: location
  name: autoscalesettings_asp_scepman_name
  properties: {
    enabled: true
    name: autoscalesettings_asp_scepman_name
    notifications: []
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles: [
      {
        capacity: {
          default: '2'
          maximum: '10'
          minimum: '2'
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
              threshold: 70
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
              threshold: 35
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
    enabled: true
    customDomainVerificationId: 'BCF8C29E756BCF6CFD26CFA7C1B77BA277F90F8BA71E5EB690CA56BCBBC95E68'
    clientCertMode: 'Required'
    hostNameSslStates: [
      {
        name: 'scepman.innovasjonnorge.no'
        sslState: 'SniEnabled'
        thumbprint: thumbprint
        hostType: 'Standard'
      }
    ]
  }  
  tags: tags
}

@description('Certificate binding')
resource scepmanin_hostNameBinding1 'Microsoft.Web/sites/hostNameBindings@2021-03-01' = {
  parent: SCEPmanAppService
  name: 'scepman.innovasjonnorge.no'
  properties: {
    siteName: primaryAppServiceName
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

@description('App config')
resource SCEPmanAppServiceconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppService
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': 'https://scepman.innovasjonnorge.no/' 
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
    WEBSITE_RUN_FROM_PACKAGE: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/scepman-artifacts/Artifacts.zip' //'https://scepmaninsa.blob.core.windows.net/scepman-artifacts/Artifacts.zip'
    'AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1652439058'
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: '~1'
    SnapshotDebugger_EXTENSION_VERSION: '~1'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    XDT_MicrosoftApplicationInsights_Java: '1'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_NodeJS: '1'
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
   }
}

@description('Health proble for SCEPman webapp')
resource SCEPmanAppServicehealth 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: SCEPmanAppService
  properties: {
    healthCheckPath: '/probe'
  }
}


//                                               Deployment slots 
resource SCEPmanDeploymentSlots 'Microsoft.Web/sites/slots@2021-03-01' = {
  name: '${primaryAppServiceName}pre-release'
  location: location
  kind: 'app'
  parent: SCEPmanAppService
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: SCEPmanAppServicesplan.id
  }
  tags: tags
}

@description('App config Deployment slot')
resource SCEPmanAppServiceSlotCeconfig 'Microsoft.Web/sites/slots/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanDeploymentSlots
  properties: {
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:BaseUrl': 'https://scepman.innovasjonnorge.no/' 
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
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationSCEPman //'https://scepmaninsa.blob.core.windows.net/scepman-artifacts/Artifacts.zip'
    'AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1653576653'
    APPINSIGHTS_INSTRUMENTATIONKEY: InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    'BackUp:AppConfig:AuthConfig:ApplicationId': 'aa73e078-3bd0-484e-a702-b99b06638f34'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: '~1'
    SnapshotDebugger_EXTENSION_VERSION: '~1'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    XDT_MicrosoftApplicationInsights_Java: '1'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_NodeJS: '1'
    XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
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
  }
  tags: tags
}

@description('App config Certifaicate Master')
resource SCEPmanAppServiceconfigCm 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: SCEPmanAppServiceCm
  properties: {
    'AppConfig:AuthConfig:ApplicationId': '1368a5a2-ceed-46ef-b69d-15d91c2649fc'
    'AppConfig:AuthConfig:ManagedIdentityEnabledOnUnixTime': '1654070214'
    'AppConfig:AuthConfig:SCEPmanAPIScope': 'api://aa73e078-3bd0-484e-a702-b99b06638f34'
    'AppConfig:AuthConfig:TenantId': tenant
    'AppConfig:AzureStorage:TableStorageEndpoint': TableStorageEndpoint
    'AppConfig:SCEPman:URL': 'https://scepman.innovasjonnorge.no/'
    WEBSITE_RUN_FROM_PACKAGE: ArtifactsLocationCertMaster 
   }
}


@description('Outputs for serviceprincipals')
output SCEPmanAppServicespid string = SCEPmanAppService.identity.principalId
output SCEPmanAppServicid string = SCEPmanAppService.id
output SCEPmanAppServiceCmspid string = SCEPmanAppServiceCm.identity.principalId
// output SCEPmanAppCertBindingThumbprint string = thumbprint
output SCEPmanAppServiceSlotspid string = SCEPmanDeploymentSlots.identity.principalId




