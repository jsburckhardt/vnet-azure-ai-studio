param location string = 'eastus'
param privateEndpointName string = 'aistudio01pep'
param privateLinkResource string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/secureaistudio/providers/Microsoft.CognitiveServices/accounts/adsfasd9501249934'
param targetSubResource array = [
  'account'
]
param requestMessage string = ''
param subnet string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio/subnets/peps'
param virtualNetworkId string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio'
param subnetDeploymentName string = 'UpdateSubnetDeployment-20240613124926'
param virtualNetworkResourceGroup string = 'aistudio-vnet'
param privateDnsDeploymentName string = 'PrivateDns-20240613124928'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet
    }
    customNetworkInterfaceName: 'aistudio01pep-nic'
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

module VirtualNetworkLink_20240613124928 './nested_VirtualNetworkLink_20240613124928.bicep' = {
  name: 'VirtualNetworkLink-20240613124928'
  params: {
    virtualNetworkId: virtualNetworkId
  }
  dependsOn: [
    privateDnsDeployment
  ]
}

module DnsZoneGroup_20240613124928 './nested_DnsZoneGroup_20240613124928.bicep' = {
  name: 'DnsZoneGroup-20240613124928'
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
