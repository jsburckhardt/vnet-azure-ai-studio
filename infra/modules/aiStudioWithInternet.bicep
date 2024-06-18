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

resource workspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
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
  resource openAiConnection 'connections' = {
    name: '${aiStudioService}-connection'
    properties: {
      category: 'AzureOpenAI'
      authType: 'ApiKey'
      isSharedToAll: true
      target: openAi.properties.endpoints['OpenAI Language Model Instance API']
      metadata: {
        ApiVersion: '2023-07-01-preview'
        ApiType: 'azure'
        ResourceId: openAi.id
      }
      credentials: {
        key: openAi.listKeys().key1
      }
    }
  }

  resource contentSafetyConnection 'connections' = {
    name: openAiContentSafetyConnectionName
    properties: {
      category: 'AzureOpenAI'
      authType: 'ApiKey'
      isSharedToAll: true
      target: openAi.properties.endpoints['Content Safety']
      metadata: {
        ApiVersion: '2023-07-01-preview'
        ApiType: 'azure'
        ResourceId: openAi.id
      }
      credentials: {
        key: openAi.listKeys().key1
      }
    }
  }

  resource searchConnection 'connections' = if (!empty(aiSearchName)) {
    name: aiSearchConnectionName
    properties: {
      category: 'CognitiveSearch'
      authType: 'ApiKey'
      isSharedToAll: true
      target: 'https://${search.name}.search.windows.net/'
      credentials: {
        key: !empty(aiSearchName) ? search.listAdminKeys().primaryKey : ''
      }
    }
  }
}

// resource workspaceName_Azure_OpenAI 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
//   parent: workspace
//   name: 'Azure.OpenAI'
//   properties: {
//     name: 'Azure.OpenAI'
//     endpointType: 'Azure.OpenAI'
//     associatedResourceId: aiServices_var
//   }
//   dependsOn: [
//     aiServices
//   ]
// }

// resource workspaceName_Azure_ContentSafety 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
//   parent: workspace
//   name: 'Azure.ContentSafety'
//   properties: {
//     name: 'Azure.ContentSafety'
//     endpointType: 'Azure.ContentSafety'
//     associatedResourceId: aiServices_var
//   }
//   dependsOn: [
//     aiServices
//   ]
// }

// resource workspaceName_Azure_Speech 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
//   parent: workspace
//   name: 'Azure.Speech'
//   properties: {
//     name: 'Azure.Speech'
//     endpointType: 'Azure.Speech'
//     associatedResourceId: aiServices_var
//   }
//   dependsOn: [
//     aiServices
//   ]
// }

// module privateEndpointDeployment './nested_privateEndpointDeployment.bicep' = if (privateEndpointType != 'none') {
//   name: privateEndpointDeploymentName
//   scope: resourceGroup(privateEndpointSubscription, privateEndpointResourceGroupName)
//   params: {
//     variables_defaultPEConnections: defaultPEConnections
//     variables_subnet: subnet
//     privateEndpointName: privateEndpointName
//     location: location
//     tagValues: tagValues
//     privateEndpointType: privateEndpointType
//   }
// }

// from template
// resource contentSafetyConnection 'connections' = {
//   name: openAiContentSafetyConnectionName
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
