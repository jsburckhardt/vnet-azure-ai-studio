param location string = 'eastus'
param privateEndpointName string = 'aistudiosa01blobpep'
param privateLinkResource string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-storage/providers/Microsoft.Storage/storageAccounts/aistudiosa01'
param targetSubResource array = [
  'blob'
]
param requestMessage string = ''
param subnet string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio/subnets/peps'
param virtualNetworkId string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio'
param subnetDeploymentName string = 'UpdateSubnetDeployment-20240613104747'
param virtualNetworkResourceGroup string = 'aistudio-vnet'
param privateDnsDeploymentName string = 'PrivateDns-20240613104748'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet
    }
    customNetworkInterfaceName: 'aistudiosa01blobpep-nic'
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

module VirtualNetworkLink_20240613104748 './nested_VirtualNetworkLink_20240613104748.bicep' = {
  name: 'VirtualNetworkLink-20240613104748'
  params: {
    virtualNetworkId: virtualNetworkId
  }
  dependsOn: [
    privateDnsDeployment
  ]
}

module DnsZoneGroup_20240613104748 './nested_DnsZoneGroup_20240613104748.bicep' = {
  name: 'DnsZoneGroup-20240613104748'
  scope: resourceGroup('aistudio-pep')
  params: {
    privateEndpointName: privateEndpointName
    location: location
  }
  dependsOn: [
    privateEndpoint
    privateDnsDeployment
  ]
}
