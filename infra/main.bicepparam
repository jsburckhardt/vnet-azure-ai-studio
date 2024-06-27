using './main.bicep'

param prefix = ''
param tagValues = {}
param vnetName = ''
param addressPrefixes = [
  '10.0.0.0/16'
]
param subnetName = ''
param subnetPrefix = '10.0.0.0/24'
param keyVaultName = ''
param keyVaultSku = 'standard'
param keyVaultAccessPolicies = []
param aiStudioSerivceName = ''
param aiStudioSerivcesku = 'S0'
param aiStudioSerivcekind = 'AIServices'
param aiStudioSerivcepublicNetworkAccess = 'Disabled'
param containerRegistryName = ''
param zoneRedundancy = 'disabled'
param containerRegistrySku = 'Premium'
param acrPublicNetworkAccess = 'Disabled'
param searchName = ''
param searchSku = 'basic'
param hostingMode = 'default'
param searchPublicNetworkAccess = 'Disabled'
param storageAccountName = ''
param storageSkuName = 'Standard_LRS'
param aiStudioWorkspaceName = ''
param aiStudioFriendlyName = ''
param aiStudioDescription = ''
param aiStudioKind = 'Hub'
param aiStudioIdentityType = 'systemAssigned'
param aiStudioSku = 'Basic'
param applicationInsightsOption = 'none'
param applicationInsightsId = ''
param aiStudioContainerRegistryOption = 'new'
param aiStudioManagedNetwork = {
  isolationMode: 'AllowInternetOutbound'
}
param aiStudioPublicNetworkAccess = 'Disabled'
param privateEndpointName = ''
param disableLocalAuth = true
param sshAccess = 'Disabled'
param vmSize = 'Standard_DS3_v2'
param assignedUserId = 'c11b4b66-d260-4a64-b8aa-2b49fa379213'
param assignedUserTenant = '16b3c013-d300-468d-ac64-7eda0820b6d3'
param enableNodePublicIp = false
param deployVpnResources = false