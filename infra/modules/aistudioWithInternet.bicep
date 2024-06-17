@description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string
param friendlyName string = workspaceName
param description string = ''

@allowed([
  'Default'
  'FeatureStore'
  'Hub'
  'Project'
])
param kind string = 'Default'

@description('Specifies the location for all resources.')
param location string

@description('Specifies the resource group name of the Azure Machine Learning workspace.')
param resourceGroupName string

@description('Specifies log workspace name of the log workspace created for the Application Insights.')
param appInsightsLogWorkspaceName string = 'ai${uniqueString(resourceGroupName,workspaceName)}'

@description('Specifies the sku, also referred as \'edition\' of the Azure Machine Learning workspace.')
@allowed([
  'Basic'
  'Enterprise'
])
param sku string = 'Basic'

@description('Specifies the identity type of the Azure Machine Learning workspace.')
@allowed([
  'systemAssigned'
  'userAssigned'
])
param identityType string = 'systemAssigned'

@description('Specifies the resource group of user assigned identity that represents the Azure Machine Learing workspace.')
param primaryUserAssignedIdentityResourceGroup string = resourceGroupName

@description('Specifies the name of user assigned identity that represents the Azure Machine Learing workspace.')
param primaryUserAssignedIdentityName string = ''

@description('Determines whether or not a new storage should be provisioned.')
@allowed([
  'new'
  'existing'
])
param storageAccountOption string = 'new'

@description('Name of the storage account.')
param storageAccountName string = 'sa${uniqueString(resourceGroupName,workspaceName)}'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Determines whether or not to put the storage account behind VNet')
@allowed([
  'true'
  'false'
])
param storageAccountBehindVNet string = 'false'
param storageAccountResourceGroupName string = resourceGroupName
param storageAccountLocation string = location
param storageAccountHnsEnabled bool = false

@description('Determines whether or not a new key vault should be provisioned.')
@allowed([
  'new'
  'existing'
])
param keyVaultOption string = 'new'

@description('Name of the key vault.')
param keyVaultName string = 'kv${uniqueString(resourceGroupName,workspaceName)}'

@description('Determines whether or not to put the storage account behind VNet')
@allowed([
  'true'
  'false'
])
param keyVaultBehindVNet string = 'false'
param keyVaultResourceGroupName string = resourceGroupName
param keyVaultLocation string = location

@description('Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param applicationInsightsOption string = 'none'

@description('Name of ApplicationInsights.')
param applicationInsightsName string = 'ai${uniqueString(resourceGroupName,workspaceName)}'
param applicationInsightsResourceGroupName string = resourceGroupName
param applicationInsightsLocation string = location

@description('Determines whether or not a new container registry should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param containerRegistryOption string = 'none'

@description('The container registry bind to the workspace.')
param containerRegistryName string = 'cr${uniqueString(resourceGroupName,workspaceName)}'

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param containerRegistrySku string = 'Standard'
param containerRegistryResourceGroupName string = resourceGroupName

@description('Determines whether or not to put container registry behind VNet.')
@allowed([
  'true'
  'false'
])
param containerRegistryBehindVNet string = 'false'
param containerRegistryLocation string = location

@description('Determines whether or not a new VNet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param vnetOption string = ((privateEndpointType == 'none') ? 'none' : 'new')

@description('Name of the VNet')
param vnetName string = 'vn${uniqueString(resourceGroupName,workspaceName)}'
param vnetResourceGroupName string = resourceGroupName

@description('Address prefix of the virtual network')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Determines whether or not a new subnet should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param subnetOption string = (((privateEndpointType != 'none') || (vnetOption == 'new')) ? 'new' : 'none')

@description('Name of the subnet')
param subnetName string = 'sn${uniqueString(resourceGroupName,workspaceName)}'

@description('Subnet prefix of the virtual network')
param subnetPrefix string = '10.0.0.0/24'

@description('Azure Databrick workspace to be linked to the workspace')
param adbWorkspace string = ''

@description('Specifies that the Azure Machine Learning workspace holds highly confidential data.')
@allowed([
  'false'
  'true'
])
param confidential_data string = 'false'

@description('Specifies if the Azure Machine Learning workspace should be encrypted with customer managed key.')
@allowed([
  'Enabled'
  'Disabled'
])
param encryption_status string = 'Disabled'

@description('Specifies the customer managed keyVault arm id.')
param cmk_keyvault string = ''

@description('Specifies if the customer managed keyvault key uri.')
param resource_cmk_uri string = ''

@allowed([
  'AutoApproval'
  'ManualApproval'
  'none'
])
param privateEndpointType string = 'none'
param tagValues object

@description('Name of the private end point added to the workspace')
param privateEndpointName string = 'pe'

@description('Name of the resource group where the private end point is added to')
param privateEndpointResourceGroupName string = resourceGroupName

@description('Id of the subscription where the private end point is added to')
param privateEndpointSubscription string = subscription().subscriptionId

@description('Identity type of storage account services.')
param systemDatastoresAuthMode string = 'accessKey'

@description('Managed network settings to be used for the workspace. If not specified, isolation mode Disabled is the default')
param managedNetwork object = {
  isolationMode: 'Disabled'
}

@description('Default resource group for projects added to this Azure AI hub')
param defaultProjectResourceGroup string = ''

@description('Determines whether or not new AI Services should be provisioned.')
@allowed([
  'new'
  'existing'
])
param aiServicesOption string = 'new'

@allowed([
  'OpenAI'
  'AIServices'
])
param aiServicesKind string

@allowed([
  'create'
  'none'
])
param endpointOption string

@description('Name of AI Services.')
param aiServicesName string = 'aoai${uniqueString(resourceGroupName,workspaceName)}'
param aiServicesLocation string = location
param aiServicesResourceGroupName string = resourceGroupName

@description('Specifies whether the workspace can be accessed by public networks or not.')
param publicNetworkAccess string = 'Enabled'

var tenantId = subscription().tenantId
var storageAccount_var = resourceId(
  storageAccountResourceGroupName,
  'Microsoft.Storage/storageAccounts',
  storageAccountName
)
var keyVault_var = resourceId(keyVaultResourceGroupName, 'Microsoft.KeyVault/vaults', keyVaultName)
var containerRegistry_var = resourceId(
  containerRegistryResourceGroupName,
  'Microsoft.ContainerRegistry/registries',
  containerRegistryName
)
var applicationInsights_var = resourceId(
  applicationInsightsResourceGroupName,
  'Microsoft.Insights/components',
  applicationInsightsName
)
var vnet = resourceId(privateEndpointSubscription, vnetResourceGroupName, 'Microsoft.Network/virtualNetworks', vnetName)
var subnet = resourceId(
  privateEndpointSubscription,
  vnetResourceGroupName,
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  subnetName
)
var networkRuleSetBehindVNet = {
  defaultAction: 'deny'
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: subnet
    }
  ]
}
var privateEndpointSettings = {
  name: '${workspaceName}-PrivateEndpoint'
  properties: {
    privateLinkServiceId: workspace.id
    groupIds: [
      'amlworkspace'
    ]
  }
}
var defaultPEConnections = array(privateEndpointSettings)
var privateEndpointDeploymentName = 'DeployPrivateEndpoint-${uniqueString(privateEndpointName)}'
var userAssignedIdentities = {
  '${primaryUserAssignedIdentity}': {}
}
var primaryUserAssignedIdentity = resourceId(
  primaryUserAssignedIdentityResourceGroup,
  'Microsoft.ManagedIdentity/userAssignedIdentities',
  primaryUserAssignedIdentityName
)
var aiServices_var = resourceId(aiServicesResourceGroupName, 'Microsoft.CognitiveServices/accounts', aiServicesName)

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-12-01-preview' = {
  tags: tagValues
  name: workspaceName
  location: location
  kind: kind
  identity: {
    type: identityType
    userAssignedIdentities: ((identityType == 'userAssigned') ? userAssignedIdentities : json('null'))
  }
  sku: {
    tier: sku
    name: sku
  }
  properties: {
    friendlyName: friendlyName
    description: description
    storageAccount: storageAccount_var
    keyVault: keyVault_var
    applicationInsights: ((applicationInsightsOption != 'none') ? applicationInsights_var : json('null'))
    containerRegistry: ((containerRegistryOption != 'none') ? containerRegistry_var : json('null'))
    primaryUserAssignedIdentity: ((identityType == 'userAssigned') ? primaryUserAssignedIdentity : json('null'))
    systemDatastoresAuthMode: ((systemDatastoresAuthMode != 'accessKey') ? systemDatastoresAuthMode : json('null'))
    managedNetwork: managedNetwork
    workspaceHubConfig: {
      defaultWorkspaceResourceGroup: (empty(defaultProjectResourceGroup) ? null : defaultProjectResourceGroup)
    }
    publicNetworkAccess: publicNetworkAccess
  }
}

resource workspaceName_Azure_OpenAI 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
  parent: workspace
  name: 'Azure.OpenAI'
  properties: {
    name: 'Azure.OpenAI'
    endpointType: 'Azure.OpenAI'
    associatedResourceId: aiServices_var
  }
  dependsOn: [
    aiServices
  ]
}

resource workspaceName_Azure_ContentSafety 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
  parent: workspace
  name: 'Azure.ContentSafety'
  properties: {
    name: 'Azure.ContentSafety'
    endpointType: 'Azure.ContentSafety'
    associatedResourceId: aiServices_var
  }
  dependsOn: [
    aiServices
  ]
}

resource workspaceName_Azure_Speech 'Microsoft.MachineLearningServices/workspaces/endpoints@2023-08-01-preview' = if (endpointOption == 'create') {
  parent: workspace
  name: 'Azure.Speech'
  properties: {
    name: 'Azure.Speech'
    endpointType: 'Azure.Speech'
    associatedResourceId: aiServices_var
  }
  dependsOn: [
    aiServices
  ]
}

module privateEndpointDeployment './nested_privateEndpointDeployment.bicep' = if (privateEndpointType != 'none') {
  name: privateEndpointDeploymentName
  scope: resourceGroup(privateEndpointSubscription, privateEndpointResourceGroupName)
  params: {
    variables_defaultPEConnections: defaultPEConnections
    variables_subnet: subnet
    privateEndpointName: privateEndpointName
    location: location
    tagValues: tagValues
    privateEndpointType: privateEndpointType
  }
}
