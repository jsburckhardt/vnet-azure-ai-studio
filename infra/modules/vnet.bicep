@description('Azure region for the deployment, resource group and resources.')
param location string

@description('Name of the virtual network resource.')
param virtualNetworkName string

@description('Optional tags for the resources.')
param tagsByResource object = {}

@description('Array of address blocks reserved for this virtual network, in CIDR notation.')
param addressPrefixes array = [
  '10.1.0.0/16'
]

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
  {
    name: 'peps'
    properties: {
      addressPrefixes: [
        '10.1.1.0/24'
      ]
    }
  }
]


@description('Enable Azure Bastion on this virtual network.')
param bastionEnabled bool = false


@description('Create a Public IP address for Azure Bastion.')
param bastionPublicIpAddressIsNew bool = false

@description('Create a network security group for Azure Bastion.')
param bastionNsgIsNew bool = false




@description('Name of the Azure Bastion resource.')
param bastionName string = '##bastion-name-not-set##'

@description('Name of the Azure Bastion resource.')
param bastionPublicIpAddressName string = '##bastion-public-ip-address-name-not-set##'
param bastionPublicIPAddressId string = '##bastion-public-i-p-address-id-not-set##'
param bastionNsgName string = '##bastion-nsg-name-not-set##'
param bastionNsgId string = '##bastion-nsg-id-not-set##'


@description('Array of NAT Gateway objects for subnets.')
param networkSecurityGroupsNew array = []

var azureBastionSubnetId = (contains(subnetNames, 'AzureBastionSubnet')
  ? resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureBastionSubnet')
  : null)

var subnetNames = [for item in subnets: item.name]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: virtualNetworkName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/virtualNetworks')
    ? tagsByResource['Microsoft.Network/virtualNetworks']
    : {})
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
  dependsOn: [
    bastionNsg
    bastionPublicIpAddress
    networkSecurityGroupsNew_name
  ]
}

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
