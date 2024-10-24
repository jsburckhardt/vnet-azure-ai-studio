param tagValues object
param workspaceName string
param friendlyName string = workspaceName
param description string = ''
param location string
param kind string = 'Hub'
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
resource aiStudioServiceResource 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiStudioService
}

resource search 'Microsoft.Search/searchServices@2024-03-01-preview' existing = if (!empty(aiSearchName)) {
  name: aiSearchName
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
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
    allowRoleAssignmentOnRG: true
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
}

resource aiServiceConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-07-01-preview' = {
  name: '${aiStudioService}-aiservice-connection'
  parent: workspace
  properties: {
    category: 'AIServices'
    authType: 'AAD'
    isSharedToAll: true
    target: aiStudioServiceResource.properties.endpoints['OpenAI Language Model Instance API']
    // peRequirement: 'Required'
    metadata: {
      ApiVersion: '2023-07-01-preview'
      ApiType: 'azure'
      ResourceId: aiStudioServiceResource.id
    }
  }
  dependsOn: [
    aiStudioServiceResource
  ]
}

resource searchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-07-01-preview' = if (!empty(aiSearchName)) {
  name: '${aiSearchName}-connection'
  parent: workspace
  properties: {
    category: 'CognitiveSearch'
    isSharedToAll: true
    authType: 'AAD'
    target: 'https://${search.name}.search.windows.net/'
    // peRequirement: 'Required'
    metadata: {
      ApiType: 'azure'
      ResourceId: search.id
    }
  }
  dependsOn: [
    search
    aiStudioServiceResource
  ]
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
