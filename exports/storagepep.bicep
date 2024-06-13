param location string
param privateEndpointName string
param privateLinkResource string
param targetSubResource array
param requestMessage string
param subnet string
param virtualNetworkId string
param virtualNetworkResourceGroup string
param subnetDeploymentName string
param privateDnsDeploymentName string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnet
    }
    customNetworkInterfaceName: 'pepsa-nic'
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

module VirtualNetworkLink_20240612215918 './nested_VirtualNetworkLink_20240612215918.bicep' = {
  name: 'VirtualNetworkLink-20240612215918'
  params: {
    virtualNetworkId: virtualNetworkId
  }
  dependsOn: [
    privateDnsDeployment
  ]
}

module DnsZoneGroup_20240612215918 './nested_DnsZoneGroup_20240612215918.bicep' = {
  name: 'DnsZoneGroup-20240612215918'
  scope: resourceGroup('aistudio-storage')
  params: {
    privateEndpointName: privateEndpointName
    location: location
  }
  dependsOn: [
    privateEndpoint
    privateDnsDeployment
  ]
}
