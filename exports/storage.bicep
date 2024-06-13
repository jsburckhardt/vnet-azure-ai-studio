param location string = 'eastus'
param storageAccountName string = 'aistudiosa01'
param accountType string = 'Standard_LRS'
param kind string = 'StorageV2'
param minimumTlsVersion string = 'TLS1_2'
param supportsHttpsTrafficOnly bool = true
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool = true
param defaultOAuth bool = false
param accessTier string = 'Hot'
param publicNetworkAccess string = 'Disabled'
param allowCrossTenantReplication bool = false
param networkAclsBypass string = 'AzureServices'
param networkAclsDefaultAction string = 'Deny'
param dnsEndpointType string = 'Standard'
param largeFileSharesState string = 'Enabled'
param keySource string = 'Microsoft.Storage'
param encryptionEnabled bool = true
param keyTypeForTableAndQueueEncryption string = 'Account'
param infrastructureEncryptionEnabled bool = false
param isBlobSoftDeleteEnabled bool = true
param blobSoftDeleteRetentionDays int = 7
param isContainerSoftDeleteEnabled bool = true
param containerSoftDeleteRetentionDays int = 7
param isShareSoftDeleteEnabled bool = true
param shareSoftDeleteRetentionDays int = 7

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  properties: {
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultOAuth
    accessTier: accessTier
    publicNetworkAccess: publicNetworkAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
    }
    dnsEndpointType: dnsEndpointType
    largeFileSharesState: largeFileSharesState
    encryption: {
      keySource: keySource
      services: {
        blob: {
          enabled: encryptionEnabled
        }
        file: {
          enabled: encryptionEnabled
        }
        table: {
          enabled: encryptionEnabled
        }
        queue: {
          enabled: encryptionEnabled
        }
      }
      requireInfrastructureEncryption: infrastructureEncryptionEnabled
    }
  }
  sku: {
    name: accountType
  }
  kind: kind
  tags: {}
  dependsOn: []
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: isBlobSoftDeleteEnabled
      days: blobSoftDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: isContainerSoftDeleteEnabled
      days: containerSoftDeleteRetentionDays
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileservices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileservices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: null
    shareDeleteRetentionPolicy: {
      enabled: isShareSoftDeleteEnabled
      days: shareSoftDeleteRetentionDays
    }
  }
  dependsOn: [
    storageAccountName_default
  ]
}
