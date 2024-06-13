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

// ##########################################
// Outputs
// ##########################################

// vent
output vnetId string = vnet.outputs.vnetId
output pepSubnetId string = vnet.outputs.pepSubnetId
