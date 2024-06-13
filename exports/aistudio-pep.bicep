param location string = 'eastus'
param privateEndpointName string = 'fsdfa'
param privateLinkResource string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio/providers/Microsoft.MachineLearningServices/workspaces/aistudio01'
param targetSubResource array = [
  'amlworkspace'
]
param requestMessage string = ''
param subnet string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio/subnets/peps'
param virtualNetworkId string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio'
param subnetDeploymentName string = 'UpdateSubnetDeployment-20240613134152'
param virtualNetworkResourceGroup string = 'aistudio-vnet'
param privateDnsDeploymentName string = 'PrivateDns-20240613134153'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet
    }
    customNetworkInterfaceName: 'fsdfa-nic'
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkResource
          groupIds: targetSubResource
        }
      }
    ]
  }
  tags: {}
  dependsOn: []
}

module privateDnsDeployment './nested_privateDnsDeployment.bicep' = {
  name: privateDnsDeploymentName
  params: {}
  dependsOn: [
    privateEndpoint
  ]
}

module VirtualNetworkLink_20240613134153 './nested_VirtualNetworkLink_20240613134153.bicep' = {
  name: 'VirtualNetworkLink-20240613134153'
  params: {
    virtualNetworkId: virtualNetworkId
  }
  dependsOn: [
    privateDnsDeployment
  ]
}

module DnsZoneGroup_20240613134153 './nested_DnsZoneGroup_20240613134153.bicep' = {
  name: 'DnsZoneGroup-20240613134153'
  scope: resourceGroup('aistudio')
  params: {
    privateEndpointName: privateEndpointName
    location: location
  }
  dependsOn: [
    privateEndpoint
    privateDnsDeployment
  ]
}
