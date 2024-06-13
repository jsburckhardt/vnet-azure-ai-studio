@description('Azure region for the deployment, resource group and resources.')
param location string
param extendedLocation object = {}

@description('Name of the virtual network resource.')
param virtualNetworkName string = 'myVnet'

@description('Optional tags for the resources.')
param tagsByResource object = {}

@description('Array of address blocks reserved for this virtual network, in CIDR notation.')
param addressPrefixes array = [
  '10.1.0.0/16'
]
param encryptionEnabled bool = false

@allowed([
  'AllowUnencrypted'
  'DropUnencrypted'
])
param encryptionEnforcement string = 'AllowUnencrypted'

@description('Array of subnet objects for this virtual network.')
param subnets array = [
  {
    name: 'default'
    properties: {
      addressPrefixes: [
        '10.1.0.0/24'
      ]
    }
  }
]

@description('Enable DDoS Protection Standard on this virtual network.')
param ddosProtectionPlanEnabled bool = false

@description('Enable Azure Firewall on this virtual network.')
param firewallEnabled bool = false

@description('Enable Azure Bastion on this virtual network.')
param bastionEnabled bool = false

@description('Create a DDoS Protection Standard plan.')
param ddosProtectionPlanIsNew bool = false

@description('Create a Public IP address for Azure Firewall.')
param firewallPublicIpAddressIsNew bool = false

@description('Create a Firewall Policy.')
param firewallPolicyIsNew bool = false

@description('Create a public ip address for management traffic in the firewall policy')
param firewallPolicyManagementPublicIPAddressIsNew bool = false

@description('Create a Public IP address for Azure Bastion.')
param bastionPublicIpAddressIsNew bool = false

@description('Create a network security group for Azure Bastion.')
param bastionNsgIsNew bool = false

@description('Name of the DDoS Protection plan.')
param ddosProtectionPlanName string = '##ddos-protection-plan-name-not-set##'
param ddosProtectionPlanId string = '##ddos-protection-plan-id-not-set##'

@description('Name of the Azure Firewall resource.')
param firewallName string = '##firewall-name-not-set##'
param firewallSkuTier string = 'Standard'

@description('Name of the Public IP address resource.')
param firewallPublicIpAddressName string = '##firewall-public-ip-name-not-set##'
param firewallPublicIpAddressId string = '##firewall-public-ip-id-not-set##'

@description('Name of the Firewall Policy address resource.')
param firewallPolicyName string = '##firewall-policy-name-not-set##'
param firewallPolicyId string = '##firewall-policy-id-not-set##'
param firewallPolicyTier string = 'Standard'
param firewallPolicyManagementPublicIPAddressName string = '##firewall-policy-management-public-i-p-address-name-not-set##'
param firewallPolicyManagementPublicIPAddressId string = '##firewall-policy-management-public-i-p-address-id-not-set##'

@description('Name of the Azure Bastion resource.')
param bastionName string = '##bastion-name-not-set##'

@description('Name of the Azure Bastion resource.')
param bastionPublicIpAddressName string = '##bastion-public-ip-address-name-not-set##'
param bastionPublicIPAddressId string = '##bastion-public-i-p-address-id-not-set##'
param bastionNsgName string = '##bastion-nsg-name-not-set##'
param bastionNsgId string = '##bastion-nsg-id-not-set##'
param natGatewaysWithNewPublicIpAddress array = []
param natGatewaysWithoutNewPublicIpAddress array = []

@description('Array of public ip addresses for NAT Gateways.')
param natGatewayPublicIpAddressesNewNames array = []

@description('Array of NAT Gateway objects for subnets.')
param networkSecurityGroupsNew array = []
param ipv6Enabled bool = false
param subnetCount int = 1
param addressSpaceStartingAddressChanged bool = false
param addressSpaceAddressSizeChanged bool = false
param defaultSubnetChanged bool = false
param subnetsInfo array = []

var azureFirewallSubnetId = (contains(subnetNames, 'AzureFirewallSubnet')
  ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureFirewallSubnet')
  : null)
var azureFirewallManagementSubnetId = (contains(subnetNames, 'AzureFirewallManagementSubnet')
  ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureFirewallManagementSubnet')
  : null)
var azureBastionSubnetId = (contains(subnetNames, 'AzureBastionSubnet')
  ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureBastionSubnet')
  : null)
var firewallPublicIPSet = ((firewallPublicIpAddressName != '##firewall-public-ip-name-not-set##') || (firewallPublicIpAddressId != '##firewall-public-ip-id-not-set##'))
var firewallPolicyNameSet = (firewallPolicyName != '##firewall-policy-name-not-set##')
var firewallPolicyIdSet = (firewallPolicyId != '##firewall-policy-id-not-set##')
var firewallPolicyManagementPublicIPAddressIsSet = ((firewallPolicyManagementPublicIPAddressName != '##firewall-policy-management-public-i-p-address-name-not-set##') || (firewallPolicyManagementPublicIPAddressId != '##firewall-policy-management-public-i-p-address-id-not-set##'))
var bastionNsgIsSet = ((bastionNsgName != '##bastion-nsg-name-not-set##') || (bastionNsgId != '##bastion-nsg-id-not-set##'))
var standardSku = {
  name: 'Standard'
}
var staticAllocation = {
  publicIPAllocationMethod: 'Static'
}
var publicIpAddressesTags = (contains(tagsByResource, 'Microsoft.Network/publicIpAddresses')
  ? tagsByResource['Microsoft.Network/publicIpAddresses']
  : {})
var natGatewayTags = (contains(tagsByResource, 'Microsoft.Network/natGateways')
  ? tagsByResource['Microsoft.Network/natGateways']
  : {})
var subnetNames = [for item in subnets: item.name]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: virtualNetworkName
  location: location
  extendedLocation: (empty(extendedLocation) ? null : extendedLocation)
  tags: (contains(tagsByResource, 'Microsoft.Network/virtualNetworks')
    ? tagsByResource['Microsoft.Network/virtualNetworks']
    : {})
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
    enableDdosProtection: ddosProtectionPlanEnabled
    ddosProtectionPlan: (ddosProtectionPlanEnabled
      ? {
          id: (ddosProtectionPlanIsNew ? ddosProtectionPlan.id : ddosProtectionPlanId)
        }
      : null)
    encryption: {
      enabled: encryptionEnabled
      enforcement: encryptionEnforcement
    }
  }
  dependsOn: [
    bastionNsg
    bastionPublicIpAddress

    firewallPolicyManagementPublicIPAddress
    firewallPublicIpAddress
    natGatewaysWithNewPublicIpAddress_name
    natGatewaysWithoutNewPublicIpAddress_name
    networkSecurityGroupsNew_name
  ]
}

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2020-11-01' = [
  for i in range(0, length(range(0, (ddosProtectionPlanIsNew ? 1 : 0)))): if (ddosProtectionPlanIsNew && ddosProtectionPlanEnabled) {
    name: ddosProtectionPlanName
    location: location
    tags: (contains(tagsByResource, 'Microsoft.Network/ddosProtectionPlans')
      ? tagsByResource['Microsoft.Network/ddosProtectionPlans']
      : {})
    properties: {}
  }
]

resource firewallPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = if (firewallPublicIpAddressIsNew && firewallEnabled) {
  name: firewallPublicIpAddressName
  location: location
  sku: standardSku
  tags: publicIpAddressesTags
  properties: staticAllocation
}

resource firewallPolicyManagementPublicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = if (firewallPolicyManagementPublicIPAddressIsNew && firewallEnabled) {
  name: firewallPolicyManagementPublicIPAddressName
  location: location
  sku: standardSku
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = if (firewallEnabled) {
  name: firewallName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/azureFirewalls')
    ? tagsByResource['Microsoft.Network/azureFirewalls']
    : {})
  properties: {
    sku: {
      tier: firewallSkuTier
    }
    firewallPolicy: ((firewallPolicyNameSet || firewallPolicyIdSet)
      ? {
          id: (firewallPolicyIsNew ? firewallPolicy.id : firewallPolicyId)
        }
      : null)
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: azureFirewallSubnetId
          }
          publicIPAddress: {
            id: (firewallPublicIpAddressIsNew ? firewallPublicIpAddress.id : firewallPublicIpAddressId)
          }
        }
      }
    ]
    managementIpConfiguration: ((firewallPolicyManagementPublicIPAddressIsSet && (azureFirewallManagementSubnetId != null))
      ? {
          name: 'managementIpConfig'
          properties: {
            publicIPAddress: {
              id: (firewallPolicyManagementPublicIPAddressIsNew
                ? firewallPolicyManagementPublicIPAddress.id
                : firewallPolicyManagementPublicIPAddressId)
            }
            subnet: {
              id: azureFirewallManagementSubnetId
            }
          }
        }
      : null)
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-07-01' = if (firewallPolicyIsNew && firewallEnabled) {
  name: firewallPolicyName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/firewallPolicies')
    ? tagsByResource['Microsoft.Network/firewallPolicies']
    : {})
  properties: {
    sku: {
      tier: firewallPolicyTier
    }
  }
}

resource natGatewaysWithoutNewPublicIpAddress_name 'Microsoft.Network/natGateways@2020-11-01' = [
  for item in natGatewaysWithoutNewPublicIpAddress: if (length(natGatewaysWithoutNewPublicIpAddress) > 0) {
    name: item.name
    location: location
    tags: natGatewayTags
    sku: standardSku
    properties: item.properties
  }
]

resource natGatewaysWithNewPublicIpAddress_name 'Microsoft.Network/natGateways@2020-11-01' = [
  for item in natGatewaysWithNewPublicIpAddress: if (length(natGatewaysWithNewPublicIpAddress) > 0) {
    name: item.name
    location: location
    tags: natGatewayTags
    sku: standardSku
    properties: item.properties
    dependsOn: [
      natGatewayPublicIpAddressesNewNames_resource
    ]
  }
]

resource natGatewayPublicIpAddressesNewNames_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = [
  for item in natGatewayPublicIpAddressesNewNames: if (length(natGatewayPublicIpAddressesNewNames) > 0) {
    name: item
    location: location
    sku: standardSku
    tags: publicIpAddressesTags
    properties: staticAllocation
  }
]

resource networkSecurityGroupsNew_name 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [
  for item in networkSecurityGroupsNew: if (length(networkSecurityGroupsNew) > 0) {
    name: item.name
    location: location
    tags: (contains(tagsByResource, 'Microsoft.Network/networkSecurityGroups')
      ? tagsByResource['Microsoft.Network/networkSecurityGroups']
      : {})
    properties: {}
  }
]

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (bastionEnabled && bastionPublicIpAddressIsNew) {
  name: bastionPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (bastionNsgIsNew) {
  name: bastionNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = if (bastionEnabled) {
  name: bastionName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/bastionHosts')
    ? tagsByResource['Microsoft.Network/bastionHosts']
    : {})
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: azureBastionSubnetId
          }
          publicIPAddress: {
            id: (bastionPublicIpAddressIsNew ? bastionPublicIpAddress.id : bastionPublicIPAddressId)
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}
