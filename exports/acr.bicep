param registryName string = 'aistudioacr01'
param registryLocation string = 'eastus'
param zoneRedundancy string = 'disabled'
param registrySku string = 'Premium'
param tags object = {}
param publicNetworkAccess string = 'Disabled'

resource registry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: registryName
  location: registryLocation
  sku: {
    name: registrySku
  }
  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}
