// scope subscription
targetScope = 'subscription'

// create a resource group
param resourceGroupName string
param location string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroupName
  location: location
}

// vnet
module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup
  params: {
    location: location
    virtualNetworkName: 'vnet-${projNameAndSuffix}vnet'
  }
}
