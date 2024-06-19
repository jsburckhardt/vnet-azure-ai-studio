param vnetName string
param location string
param tagValues object
param addressPrefixes array
param subnetName string
param subnetPrefix string
param serviceEndpointsAll array = []

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource pepsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  parent: vnet
  name: '${subnetName}-pep'
  properties: {
    addressPrefix: subnetPrefix
    privateLinkServiceNetworkPolicies: 'Enabled' // based on the aml vnet deployment https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.machinelearningservices/machine-learning-workspace-vnet/README.md
    serviceEndpoints: serviceEndpointsAll // based on the aml vnet deployment ^^^
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output pepSubnetId string = pepsubnet.id
