param privateEndpointName string
param vnetId string
param vnetName string
param pepSubnetId string
param amlWorkspaceId string
param aiStudioServiceId string
param srchServiceId string
param storageId string
param location string

// Create the private endpoins for:
// studio
resource aiStudioPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateEndpointName}-aistudio'
  location: location
  properties: {
    subnet: {
      id: pepSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'workspace'
        properties: {
          privateLinkServiceId: amlWorkspaceId
          groupIds: [
            'amlworkspace'
          ]
        }
      }
    ]
  }
}

// aoai
resource aoaiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateEndpointName}-aoai'
  location: location
  properties: {
    subnet: {
      id: pepSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'aoai'
        properties: {
          privateLinkServiceId: aiStudioServiceId
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

// azure search
resource srchPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateEndpointName}-srch'
  location: location
  properties: {
    subnet: {
      id: pepSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'srch'
        properties: {
          privateLinkServiceId: srchServiceId
          groupIds: [
            'searchService'
          ]
        }
      }
    ]
  }
}

// azure storage blob
resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateEndpointName}-blob'
  location: location
  properties: {
    subnet: {
      id: pepSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'storage'
        properties: {
          privateLinkServiceId: storageId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// azure storage file
resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateEndpointName}-file'
  location: location
  properties: {
    subnet: {
      id: pepSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'storage'
        properties: {
          privateLinkServiceId: storageId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

// Create the private DNS zone for:
// studio
resource azuremlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  properties: {}
}

resource notebooksPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.notebooks.azure.net'
  location: 'global'
  properties: {}
}

// aoai
resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.cognitiveservices.azure.com'
  location: 'global'
  properties: {}
}

resource aoaiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
  properties: {}
}

// search
resource srchPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.search.windows.net'
  location: 'global'
  properties: {}
}

// storage blob
resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  properties: {}
}

// storage file
resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
  properties: {}
}

// Link the DNS zone to the virtual network for:
// aistudio
resource azuremlVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-azureml-link'
  parent: azuremlPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource notebooksVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-notebooks-link'
  parent: notebooksPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// aoai
resource cognitiveServicesVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-cog-link'
  parent: cognitiveServicesPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource aoaiVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-aoai-link'
  parent: aoaiPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// srch
resource srchVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-srch-link'
  parent: srchPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// storage blob
resource blobVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-st-blob-link'
  parent: blobPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// storage file
resource fileVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-st-file-link'
  parent: filePrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// Create the DNS zone group
// aistudio
resource aistudioDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'aistudiozonegroup'
  parent: aiStudioPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.api.azureml.ms'
        properties: {
          privateDnsZoneId: azuremlPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink.notebooks.azure.net'
        properties: {
          privateDnsZoneId: notebooksPrivateDnsZone.id
        }
      }
    ]
  }
}

// aoai
resource aoaiDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'aoaizonegroup'
  parent: aoaiPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.cognitiveservices.azure.com'
        properties: {
          privateDnsZoneId: cognitiveServicesPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink.openai.azure.com'
        properties: {
          privateDnsZoneId: aoaiPrivateDnsZone.id
        }
      }
    ]
  }
}

// srch
resource srchDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'srchzonegroup'
  parent: srchPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.search.windows.net'
        properties: {
          privateDnsZoneId: srchPrivateDnsZone.id
        }
      }
    ]
  }
}

// storage blob
resource blobDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'blobzonegroup'
  parent: blobPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.blob.${environment().suffixes.storage}'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

// storage file
resource fileDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'filezonegroup'
  parent: filePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.file.${environment().suffixes.storage}'
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}



// Link the DNS zone to the virtual network VPN:
param enablevpn bool = false
param vpnVnetName string = ''
param vpnVnetResourceGroupName string = ''

// aistudio
resource vpnVnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = if(enablevpn) {
  name: vpnVnetName
  scope: resourceGroup(vpnVnetResourceGroupName)
}

var vpnVnetId = vpnVnet.id

resource azuremlVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-azureml-link-vpn'
  parent: azuremlPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

resource notebooksVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-notebooks-link-vpn'
  parent: notebooksPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

// aoai
resource cognitiveServicesVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-cog-link-vpn'
  parent: cognitiveServicesPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

resource aoaiVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-aoai-link-vpn'
  parent: aoaiPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

// srch
resource srchVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-srch-link-vpn'
  parent: srchPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

// storage blob
resource blobVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-st-blob-link-vpn'
  parent: blobPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}

// storage file
resource fileVirtualNetworkLinkVpn 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if(enablevpn) {
  name: '${vnetName}-st-file-link-vpn'
  parent: filePrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vpnVnetId
    }
    registrationEnabled: false
  }
}
