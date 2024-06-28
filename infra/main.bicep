// ##########################################
// Params
// ##########################################

// Global
@description('Deployment name - identifier')
param prefix string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Tags for workspace, will also be populated if provisioning new dependent resources.')
param tagValues object = {}

var abbrs = loadJsonContent('abbreviations.json')
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 5)
var name = toLower('${prefix}')
var tenantId = subscription().tenantId

// VNET params
@description('Name of the VNet')
param vnetName string = ''

@description('Address prefix of the virtual network')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Name of the subnet')
param subnetName string = ''

@description('Subnet prefix of the virtual network')
param subnetPrefix string = '10.0.0.0/24'

var serviceEndpointsAll = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.KeyVault'
  }
  {
    service: 'Microsoft.ContainerRegistry'
  }
]

// keyvault params
param keyVaultName string = ''
param keyVaultSku string = 'standard'
param keyVaultAccessPolicies array = []

// ai studio service
param aiStudioSerivceName string = ''
param aiStudioSerivcesku string = 'S0'
param aiStudioSerivcekind string = 'AIServices'
param aiStudioSerivcepublicNetworkAccess string = 'Disabled'

// acr
param containerRegistryName string = ''
param zoneRedundancy string = 'disabled'
param containerRegistrySku string = 'Premium'
param acrPublicNetworkAccess string = 'Disabled'

// azure search
param searchName string = ''
param searchSku string = 'basic'
param hostingMode string = 'default'
param searchPublicNetworkAccess string = 'Disabled'

// storage
param storageAccountName string = ''
param storageSkuName string = 'Standard_LRS'

// ai studio
@description('Specifies the name of the Azure Machine Learning workspace.')
param aiStudioWorkspaceName string = ''
param aiStudioFriendlyName string = ''
param aiStudioDescription string = ''
@allowed([
  'Default'
  'FeatureStore'
  'Hub'
  'Project'
])
param aiStudioKind string = 'Hub'
@description('Specifies the identity type of the Azure Machine Learning workspace.')
@allowed([
  'systemAssigned'
  'userAssigned'
])
param aiStudioIdentityType string = 'systemAssigned'
@description('Specifies the sku, also referred as \'edition\' of the Azure Machine Learning workspace.')
@allowed([
  'Basic'
  'Free'
  'Premium'
  'Standard'
])
param aiStudioSku string = 'Basic'

@description('Determines whether or not new ApplicationInsights should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param applicationInsightsOption string = 'none'
param applicationInsightsId string = ''
@description('Determines whether or not a new container registry should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param aiStudioContainerRegistryOption string = 'new'
@description('Managed network settings to be used for the workspace. If not specified, isolation mode Disabled is the default')
param aiStudioManagedNetwork object = {
  isolationMode: 'AllowInternetOutbound'
}
@description('Specifies whether the workspace can be accessed by public networks or not.')
param aiStudioPublicNetworkAccess string = 'Disabled'

// private endpoints
param privateEndpointName string = ''

// compute instance
@description('Disables local auth when not using ssh')
param disableLocalAuth bool = true

@description('Specifies whether SSH access should be enabled for compute instance')
@allowed([
  'Disabled'
  'Enabled'
])
param sshAccess string = 'Disabled'

@description('Specifies the VM size of the Compute Instance to create under Azure Machine Learning workspace.')
param vmSize string = 'Standard_DS3_v2'

@description('Specifies the name of the Compute Instance to create under Azure Machine Learning workspace.')
param computeInstanceName string

@description('Specifies who the compute is assigned to. Only they can access it.')
param assignedUserId string

@description('Specifies the tenant of the assigned user.')
param assignedUserTenant string

@description('Enable or disable node public IP address provisioning')
param enableNodePublicIp bool = false

// vpn
param deployVpnResources bool = false
param enablevpn bool = false
param vpnVnetName string = ''
param vpnVnetResourceGroupName string = ''

// ##########################################
// Resources
// ##########################################

// VNET
module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    vnetName: !empty(vnetName) ? vnetName : '${abbrs.virtualNetworks}${name}${uniqueSuffix}'
    location: location
    tagValues: tagValues
    addressPrefixes: addressPrefixes
    subnetName: !empty(subnetName) ? subnetName : '${abbrs.networkVirtualNetworksSubnets}${name}${uniqueSuffix}'
    subnetPrivateDnsResolverName: '${abbrs.networkPrivateDnsResolver}${name}${uniqueSuffix}' // for vpn purpose
    subnetPrefix: subnetPrefix
    serviceEndpointsAll: serviceEndpointsAll
  }
}

// Key Vault
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${name}${uniqueSuffix}'
    location: location
    sku: keyVaultSku
    accessPolicies: keyVaultAccessPolicies
    tenant: tenantId
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: false
    publicNetworkAccess: 'Disabled'
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'deny'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// AI Studio Service
module aiStudioService 'modules/aiStudioService.bicep' = {
  name: 'aiStudioService'
  params: {
    name: !empty(aiStudioSerivceName)
      ? aiStudioSerivceName
      : '${abbrs.cognitiveServicesAccounts}service-${name}${uniqueSuffix}'
    sku: aiStudioSerivcesku
    kind: aiStudioSerivcekind
    publicNetworkAccess: aiStudioSerivcepublicNetworkAccess
    location: location
  }
}

// ACR
module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    containerRegistryName: !empty(containerRegistryName)
      ? containerRegistryName
      : '${abbrs.containerRegistryRegistries}${name}${uniqueSuffix}'
    location: location
    tags: tagValues
    containerRegistrySku: containerRegistrySku
    publicNetworkAccess: acrPublicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

// Azure Search
module azureSearch 'modules/azureSearch.bicep' = {
  name: 'azureSearch'
  params: {
    searchName: !empty(searchName) ? searchName : '${abbrs.searchSearchServices}${name}${uniqueSuffix}'
    location: location
    sku: searchSku
    hostingMode: hostingMode
    publicNetworkAccess: searchPublicNetworkAccess
  }
}

// Azure Storage
module storage 'modules/storage.bicep' = {
  name: 'azureStorage'
  params: {
    location: location
    storageAccountName: !empty(storageAccountName)
      ? storageAccountName
      : '${abbrs.storageStorageAccounts}${name}${uniqueSuffix}'
    storageSkuName: storageSkuName
    tags: tagValues
  }
}

// AI Studio
module aiStudio 'modules/aiStudioWithInternet.bicep' = {
  name: 'aiStudio'
  params: {
    tagValues: tagValues
    workspaceName: !empty(aiStudioWorkspaceName)
      ? aiStudioWorkspaceName
      : '${abbrs.cognitiveServicesAccounts}${name}${uniqueSuffix}'
    friendlyName: aiStudioFriendlyName
    description: aiStudioDescription
    location: location
    kind: aiStudioKind
    identityType: aiStudioIdentityType
    sku: aiStudioSku
    storageAccountId: storage.outputs.storageAccountId
    keyVaultId: keyVault.outputs.keyVaultId
    applicationInsightsOption: applicationInsightsOption
    applicationInsightsId: applicationInsightsId
    containerRegistryOption: aiStudioContainerRegistryOption
    containerRegistryId: acr.outputs.registryId
    // systemDatastoresAuthMode: systemDatastoresAuthMode
    managedNetwork: aiStudioManagedNetwork
    publicNetworkAccess: aiStudioPublicNetworkAccess
    aiSearchName: azureSearch.outputs.searchName
    aiStudioService: aiStudioService.outputs.aiStudioServiceName
  }
  dependsOn: [
    storage
    keyVault
    aiStudioService
    acr
    azureSearch
  ]
}

// private endpoints
// to studio
module privateEndpoints 'modules/privateEndpoints.bicep' = {
  name: 'privateEndpoints'
  params: {
    location: location
    vnetId: vnet.outputs.vnetId
    vnetName: vnet.outputs.vnetName
    pepSubnetId: vnet.outputs.pepSubnetId
    amlWorkspaceId: aiStudio.outputs.workspaceId
    aiStudioServiceId: aiStudioService.outputs.aiStudioServiceId
    srchServiceId: azureSearch.outputs.searchId
    storageId: storage.outputs.storageAccountId
    privateEndpointName: !empty(privateEndpointName)
      ? privateEndpointName
      : '${abbrs.privateEndpoint}${name}${uniqueSuffix}'
    enablevpn: enablevpn
    vpnVnetName: vpnVnetName
    vpnVnetResourceGroupName: vpnVnetResourceGroupName
  }
}

// compute instances to share across projects
module computeInstanceSample 'modules/aiStudioComputeInstance.bicep' = {
  name: 'computeInstances'
  params: {
    workspaceName: aiStudio.outputs.workspaceName
    computeInstanceName: computeInstanceName
    location: location
    disableLocalAuth: disableLocalAuth
    sshAccess: sshAccess
    vmSize: vmSize
    assignedUserId: assignedUserId
    assignedUserTenant: assignedUserTenant
    enableNodePublicIp: enableNodePublicIp
  }
}

// not required for real env - just for testing - vpn=true
module vpnAccess 'modules/vpnAccess.bicep' = if (deployVpnResources) {
  name: 'vpnAccess'
  params: {
    location: location
    gatewaySubnetId: vnet.outputs.gatewaySubnetId
    privateDnsResolverSubnetId: vnet.outputs.privateDnsResolverSubnetId
    publicIpName: '${abbrs.networkPublicIPAddresses}${name}${uniqueSuffix}'
    vpnGatewayName: '${abbrs.networkVirtualNetworkGateways}${name}${uniqueSuffix}'
    resolverName: '${abbrs.networkPrivateDnsResolver}${name}${uniqueSuffix}'
    vnetName: vnet.outputs.vnetName
  }
}

// ##########################################
// Outputs
// ##########################################

// vent
output vnetId string = vnet.outputs.vnetId
output pepSubnetId string = vnet.outputs.pepSubnetId
// keyvault
output keyVaultId string = keyVault.outputs.keyVaultId
// ai studio service
output aiStudioServiceId string = aiStudioService.outputs.aiStudioServiceId
// acr
output registryName string = acr.outputs.registryName
output registryId string = acr.outputs.registryId
output registryUrl string = acr.outputs.registryUrl
// azure search
output searchId string = azureSearch.outputs.searchId
