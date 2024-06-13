param privateEndpoints_aistudiosa01blobpep_name string = 'aistudiosa01blobpep'
param storageAccounts_aistudiosa01_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-storage/providers/Microsoft.Storage/storageAccounts/aistudiosa01'
param virtualNetworks_vnetaistudio_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/virtualNetworks/vnetaistudio'
param privateDnsZones_privatelink_blob_core_windows_net_externalid string = '/subscriptions/266966fb-4c39-4b07-a8b3-f1b1dff5670d/resourceGroups/aistudio-vnet/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'

resource privateEndpoints_aistudiosa01blobpep_name_resource 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpoints_aistudiosa01blobpep_name
  location: 'eastus'
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_aistudiosa01blobpep_name
        id: '${privateEndpoints_aistudiosa01blobpep_name_resource.id}/privateLinkServiceConnections/${privateEndpoints_aistudiosa01blobpep_name}'
        properties: {
          privateLinkServiceId: storageAccounts_aistudiosa01_externalid
          groupIds: [
            'blob'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${privateEndpoints_aistudiosa01blobpep_name}-nic'
    subnet: {
      id: '${virtualNetworks_vnetaistudio_externalid}/subnets/peps'
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateEndpoints_aistudiosa01blobpep_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: '${privateEndpoints_aistudiosa01blobpep_name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZones_privatelink_blob_core_windows_net_externalid
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints_aistudiosa01blobpep_name_resource
  ]
}
