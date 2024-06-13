param name string = 'aistudiokv01'
param location string = 'eastus'
param sku string = 'Standard'
param accessPolicies array = []
param tenant string = '16b3c013-d300-468d-ac64-7eda0820b6d3'
param enabledForDeployment bool = false
param enabledForTemplateDeployment bool = false
param enabledForDiskEncryption bool = false
param enableRbacAuthorization bool = true
param publicNetworkAccess string = 'Disabled'
param enableSoftDelete bool = true
param softDeleteRetentionInDays int = 90
param networkAcls object = {
  defaultAction: 'deny'
  bypass: 'AzureServices'
  ipRules: []
  virtualNetworkRules: []
}

resource name_resource 'Microsoft.KeyVault/vaults@2023-08-01-preview' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    accessPolicies: accessPolicies
    tenantId: tenant
    sku: {
      name: sku
      family: 'A'
    }
    publicNetworkAccess: publicNetworkAccess
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    networkAcls: networkAcls
  }
  tags: {}
  dependsOn: []
}
