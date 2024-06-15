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
param publicNetworkAccess string = 'Disabled'

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
    subnetPrefix: subnetPrefix
    serviceEndpointsAll: serviceEndpointsAll
  }
}

// Key Vault
module keyvault 'modules/keyvault.bicep' = {
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
    name: !empty(aiStudioSerivceName) ? aiStudioSerivceName : '${abbrs.cognitiveServicesAccounts}${name}${uniqueSuffix}'
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
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

// ##########################################
// Outputs
// ##########################################

// vent
output vnetId string = vnet.outputs.vnetId
output pepSubnetId string = vnet.outputs.pepSubnetId
// keyvault
output keyVaultId string = keyvault.outputs.keyVaultId
// ai studio service
output aiStudioServiceId string = aiStudioService.outputs.aiStudioServiceId
