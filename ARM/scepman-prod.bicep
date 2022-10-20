param sites_as_scepman_martin_name string = 'as-scepman-martin'
param sites_as_scepman_martin_cm_name string = 'as-scepman-martin-cm'
param vaults_kv_scepman_martin_name string = 'kv-scepman-martin'
param serverfarms_asp_scepman_martin_name string = 'asp-scepman-martin'
param storageAccounts_stgscepmanmartin_name string = 'stgscepmanmartin'

resource vaults_kv_scepman_martin_name_resource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaults_kv_scepman_martin_name
  location: 'westeurope'
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
    accessPolicies: [
      {
        tenantId: '89c966d0-fc62-4a30-b104-cfcba0b97b07'
        objectId: '51a2d479-11cc-49c4-86de-e081b7fde7ce'
        permissions: {
          keys: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'UnwrapKey'
            'Verify'
            'Sign'
          ]
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
          ]
          certificates: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'ManageContacts'
            'ManageIssuers'
            'GetIssuers'
            'ListIssuers'
            'SetIssuers'
            'DeleteIssuers'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enablePurgeProtection: true
    vaultUri: 'https://${vaults_kv_scepman_martin_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource storageAccounts_stgscepmanmartin_name_resource 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccounts_stgscepmanmartin_name
  location: 'westeurope'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    routingPreference: {
      routingChoice: 'MicrosoftRouting'
      publishMicrosoftEndpoints: false
      publishInternetEndpoints: false
    }
    isNfsV3Enabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    isHnsEnabled: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource serverfarms_asp_scepman_martin_name_resource 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: serverfarms_asp_scepman_martin_name
  location: 'West Europe'
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource storageAccounts_stgscepmanmartin_name_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  parent: storageAccounts_stgscepmanmartin_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_stgscepmanmartin_name_default 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = {
  parent: storageAccounts_stgscepmanmartin_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {
      }
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_stgscepmanmartin_name_default 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' = {
  parent: storageAccounts_stgscepmanmartin_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_stgscepmanmartin_name_default 'Microsoft.Storage/storageAccounts/tableServices@2022-05-01' = {
  parent: storageAccounts_stgscepmanmartin_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_as_scepman_martin_name_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: sites_as_scepman_martin_name
  location: 'West Europe'
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_as_scepman_martin_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_as_scepman_martin_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_asp_scepman_martin_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '405FD280DA4A622D6823373B2451F547D60F587C1A53A6C311A0AFE2E406171C'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_as_scepman_martin_cm_name_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: sites_as_scepman_martin_cm_name
  location: 'West Europe'
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_as_scepman_martin_cm_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_as_scepman_martin_cm_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_asp_scepman_martin_name_resource.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '405FD280DA4A622D6823373B2451F547D60F587C1A53A6C311A0AFE2E406171C'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_as_scepman_martin_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: 'ftp'
  location: 'West Europe'
  properties: {
    allow: true
  }
}

resource sites_as_scepman_martin_cm_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: 'ftp'
  location: 'West Europe'
  properties: {
    allow: true
  }
}

resource sites_as_scepman_martin_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: 'scm'
  location: 'West Europe'
  properties: {
    allow: true
  }
}

resource sites_as_scepman_martin_cm_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: 'scm'
  location: 'West Europe'
  properties: {
    allow: true
  }
}

resource sites_as_scepman_martin_name_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: 'web'
  location: 'West Europe'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$as-scepman-martin'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 21740
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'Disabled'
    preWarmedInstanceCount: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {
    }
  }
}

resource sites_as_scepman_martin_cm_name_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: 'web'
  location: 'West Europe'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$as-scepman-martin-cm'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 21739
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    preWarmedInstanceCount: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {
    }
  }
}

resource sites_as_scepman_martin_name_sites_as_scepman_martin_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: '${sites_as_scepman_martin_name}.azurewebsites.net'
  location: 'West Europe'
  properties: {
    siteName: 'as-scepman-martin'
    hostNameType: 'Verified'
  }
}

resource sites_as_scepman_martin_cm_name_sites_as_scepman_martin_cm_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: '${sites_as_scepman_martin_cm_name}.azurewebsites.net'
  location: 'West Europe'
  properties: {
    siteName: 'as-scepman-martin-cm'
    hostNameType: 'Verified'
  }
}

resource sites_as_scepman_martin_name_2022_10_20T11_01_29_8069718 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: '2022-10-20T11_01_29_8069718'
}

resource sites_as_scepman_martin_cm_name_2022_10_20T11_01_29_8069718 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: '2022-10-20T11_01_29_8069718'
}

resource sites_as_scepman_martin_name_2022_10_20T12_01_29_9584665 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: '2022-10-20T12_01_29_9584665'
}

resource sites_as_scepman_martin_cm_name_2022_10_20T12_01_29_9584665 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: '2022-10-20T12_01_29_9584665'
}

resource sites_as_scepman_martin_name_2022_10_20T13_01_30_2869786 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: '2022-10-20T13_01_30_2869786'
}

resource sites_as_scepman_martin_cm_name_2022_10_20T13_01_30_2869786 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: '2022-10-20T13_01_30_2869786'
}

resource sites_as_scepman_martin_name_2022_10_20T14_01_30_3583236 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_name_resource
  name: '2022-10-20T14_01_30_3583236'
}

resource sites_as_scepman_martin_cm_name_2022_10_20T14_01_30_3583236 'Microsoft.Web/sites/snapshots@2015-08-01' = {
  parent: sites_as_scepman_martin_cm_name_resource
  name: '2022-10-20T14_01_30_3583236'
}