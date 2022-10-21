@description('URL of the Storage Account\'s table endpoint to retrieve certificate information from')
param StorageAccountTableUrl string

@description('Name of SCEPman\'s app service')
param appServiceName string

@description('Base URL of SCEPman')
param scepManBaseURL string

@description('URL of the key vault')
param keyVaultURL string

@description('Name of company or organization for certificate subject')
param OrgName string

@description('When generating the SCEPman CA certificate, which kind of key pair shall be created? RSA is a software-protected RSA key; RSA-HSM is HSM-protected.')
@allowed([
  'RSA'
  'RSA-HSM'
])
param caKeyType string = 'RSA-HSM'

@description('License Key for SCEPman')
param license string = 'trial'

@description('The full URI where SCEPman artifact binaries are stored')
param WebsiteArtifactsUri string

@description('Resource Group')
param location string

resource appServiceName_appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: '${appServiceName}/appsettings'
  location: location
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: WebsiteArtifactsUri
    'AppConfig:BaseUrl': scepManBaseURL
    'AppConfig:LicenseKey': license
    'AppConfig:AuthConfig:TenantId': subscription().tenantId
    'AppConfig:UseRequestedKeyUsages': 'true'
    'AppConfig:ValidityPeriodDays': '730'
    'AppConfig:IntuneValidation:ValidityPeriodDays': '365'
    'AppConfig:DirectCSRValidation:Enabled': 'true'
    'AppConfig:IntuneValidation:DeviceDirectory': 'AADAndIntune'
    'AppConfig:KeyVaultConfig:KeyVaultURL': keyVaultURL
    'AppConfig:AzureStorage:TableStorageEndpoint': StorageAccountTableUrl
    'AppConfig:KeyVaultConfig:RootCertificateConfig:CertificateName': 'SCEPman-Root-CA-V1'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:KeyType': caKeyType
    'AppConfig:ValidityClockSkewMinutes': '1440'
    'AppConfig:KeyVaultConfig:RootCertificateConfig:Subject': 'CN=SCEPman-Root-CA-V1, OU=${subscription().tenantId}, O="${OrgName}"'
  }
}