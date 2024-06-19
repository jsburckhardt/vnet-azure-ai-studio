param tagValues object
param workspaceName string
param friendlyName string = workspaceName
param description string = ''
param location string
param kind string = 'Default'
param identityType string = 'systemAssigned'
param primaryUserAssignedIdentityResourceGroup string = resourceGroup().name
param primaryUserAssignedIdentityName string = ''
var userAssignedIdentities = {
  '${primaryUserAssignedIdentity}': {}
}
var primaryUserAssignedIdentity = resourceId(
  primaryUserAssignedIdentityResourceGroup,
  'Microsoft.ManagedIdentity/userAssignedIdentities',
  primaryUserAssignedIdentityName
)
@allowed([
  'Basic'
  'Free'
  'Premium'
  'Standard'
])
param sku string = 'Basic'
param storageAccountId string
param keyVaultId string
@allowed([
  'new'
  'existing'
  'none'
])
param applicationInsightsOption string = 'none'
param applicationInsightsId string = ''
@allowed([
  'new'
  'existing'
  'none'
])
param containerRegistryOption string = 'none'
param containerRegistryId string = ''
param managedNetwork object = {
  isolationMode: 'AllowInternetOutbound'
}
param publicNetworkAccess string = 'Disabled'

param aiStudioService string
param aiSearchName string

// get resources details
resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiStudioService
}

resource search 'Microsoft.Search/searchServices@2021-04-01-preview' existing = if (!empty(aiSearchName)) {
  name: aiSearchName
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  tags: tagValues
  name: workspaceName
  location: location
  kind: kind
  identity: {
    type: identityType
    userAssignedIdentities: ((identityType == 'userAssigned') ? userAssignedIdentities : null)
  }
  sku: {
    tier: sku
    name: sku
  }
  properties: {
    friendlyName: friendlyName
    description: description
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: ((applicationInsightsOption != 'none') ? applicationInsightsId : null)
    containerRegistry: ((containerRegistryOption != 'none') ? containerRegistryId : null)
    primaryUserAssignedIdentity: ((identityType == 'userAssigned') ? primaryUserAssignedIdentity : null)
    managedNetwork: managedNetwork
    publicNetworkAccess: publicNetworkAccess
  }
  // resource openAiConnection 'connections' = {
  //   name: '${aiStudioService}-aoai-connection'
  //   properties: {
  //     category: 'AzureOpenAI'
  //     authType: 'ApiKey'
  //     isSharedToAll: true
  //     target: openAi.properties.endpoints['OpenAI Language Model Instance API']
  //     metadata: {
  //       ApiVersion: '2023-07-01-preview'
  //       ApiType: 'azure'
  //       ResourceId: openAi.id
  //     }
  //     credentials: {
  //       key: openAi.listKeys().key1
  //     }
  //   }
  // }

  // resource aiServicesConnection 'connections' = {
  //   name: '${aiStudioService}-aiservices-connection'
  //   properties: {
  //     category: 'AIServices'
  //     authType: 'ApiKey'
  //     isSharedToAll: true
  //     target: openAi.properties.endpoints['OpenAI Language Model Instance API']
  //     metadata: {
  //       ApiVersion: '2023-07-01-preview'
  //       ApiType: 'azure'
  //       ResourceId: openAi.id
  //     }
  //     credentials: {
  //       key: openAi.listKeys().key1
  //     }
  //   }
  // }

  // resource contentSafetyConnection 'connections' = {
  //   name: '${aiStudioService}-content-safety-connection'
  //   properties: {
  //     category: 'AzureOpenAI'
  //     authType: 'ApiKey'
  //     isSharedToAll: true
  //     target: openAi.properties.endpoints['Content Safety']
  //     metadata: {
  //       ApiVersion: '2023-07-01-preview'
  //       ApiType: 'azure'
  //       ResourceId: openAi.id
  //     }
  //     credentials: {
  //       key: openAi.listKeys().key1
  //     }
  //   }
  // }

  // resource searchConnection 'connections' = if (!empty(aiSearchName)) {
  //   name: '${aiSearchName}-connection'
  //   properties: {
  //     category: 'CognitiveSearch'
  //     authType: 'ApiKey'
  //     isSharedToAll: true
  //     target: 'https://${search.name}.search.windows.net/'
  //     credentials: {
  //       key: !empty(aiSearchName) ? search.listAdminKeys().primaryKey : ''
  //     }
  //   }
  // }
}
