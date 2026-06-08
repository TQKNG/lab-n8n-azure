// Network Security Group Module
// Defines firewall rules for n8n VM

@description('Location for all resources')
param location string

@description('Base name for resources')
param baseName string

@description('Tags for resources')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${baseName}-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          description: 'Allow HTTPS traffic for n8n web interface'
        }
      }
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
          description: 'Allow HTTP for Let\'s Encrypt ACME challenge'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 120
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
          description: 'Allow SSH for management'
        }
      }
      {
        name: 'Deny-n8n-Direct'
        properties: {
          priority: 130
          protocol: 'Tcp'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '5678'
          description: 'Deny direct access to n8n port (use HTTPS only)'
        }
      }
      {
        name: 'Allow-Outbound-Internet'
        properties: {
          priority: 100
          protocol: '*'
          access: 'Allow'
          direction: 'Outbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          description: 'Allow outbound internet access'
        }
      }
    ]
  }
}

output nsgId string = nsg.id
output nsgName string = nsg.name
