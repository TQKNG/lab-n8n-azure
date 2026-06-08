// Main Bicep Template for n8n Infrastructure
// Clean orchestration - delegates to modules

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Location for all resources')
param location string = resourceGroup().location

@description('Base name for resources')
@minLength(3)
@maxLength(10)
param baseName string = 'n8n'

@description('Domain name for n8n (e.g., n8n.example.com)')
param domainName string

@description('VM size')
@allowed([
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
])
param vmSize string = 'Standard_B2ms'

@description('n8n version (Docker tag)')
param n8nVersion string = 'latest'

@description('SSH public key for VM access')
@secure()
param sshPublicKey string

@description('n8n encryption key (32+ characters)')
@secure()
@minLength(32)
param n8nEncryptionKey string

@description('Admin username for VM')
@minLength(3)
@maxLength(20)
param adminUsername string = 'azureuser'

@description('TLS email for Let\'s Encrypt notifications')
param tlsEmail string = ''

@description('Deployment timestamp')
param deploymentTimestamp string = utcNow('yyyy-MM-dd HH:mm:ss')

@description('Environment tag')
@allowed([
  'development'
  'staging'
  'production'
])
param environment string = 'production'

@description('Tags to apply to all resources')
param tags object = {}

@description('VNet address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.0.1.0/24'

// ============================================================================
// VARIABLES
// ============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)
var fullBaseName = '${baseName}-${uniqueSuffix}'

// Calculate TLS email (use provided or default to admin@domain)
var calculatedTlsEmail = empty(tlsEmail) ? 'admin@${domainName}' : tlsEmail

// Merge default tags with custom tags
var defaultTags = {
  Project: 'n8n-automation'
  ManagedBy: 'Bicep'
  Environment: environment
  DeployedAt: deploymentTimestamp
  Domain: domainName
}
var allTags = union(defaultTags, tags)

// ============================================================================
// MODULES
// ============================================================================

// Module 1: Cloud-Init Configuration
module cloudInitModule 'modules/cloud-init.bicep' = {
  name: 'cloud-init-${uniqueSuffix}'
  params: {
    domainName: domainName
    n8nVersion: n8nVersion
    n8nEncryptionKey: n8nEncryptionKey
    adminUsername: adminUsername
    tlsEmail: calculatedTlsEmail
    environment: environment
  }
}

// Module 2: Network Security Group
module nsgModule 'modules/nsg.bicep' = {
  name: 'nsg-${uniqueSuffix}'
  params: {
    location: location
    baseName: fullBaseName
    tags: allTags
  }
}

// Module 3: Network Infrastructure
module networkModule 'modules/network.bicep' = {
  name: 'network-${uniqueSuffix}'
  params: {
    location: location
    baseName: fullBaseName
    vnetAddressPrefix: vnetAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
    networkSecurityGroupId: nsgModule.outputs.nsgId
    tags: allTags
  }
}

// Module 4: Virtual Machine
module vmModule 'modules/vm.bicep' = {
  name: 'vm-${uniqueSuffix}'
  params: {
    location: location
    baseName: fullBaseName
    vmSize: vmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    networkInterfaceId: networkModule.outputs.nicId
    cloudInit: cloudInitModule.outputs.cloudInitBase64
    tags: allTags
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('VM name')
output vmName string = vmModule.outputs.vmName

@description('VM resource ID')
output vmId string = vmModule.outputs.vmId

@description('Public IP address')
output publicIPAddress string = networkModule.outputs.publicIPAddress

@description('Public IP resource ID')
output publicIpId string = networkModule.outputs.publicIPId

@description('Fully qualified domain name (Azure DNS)')
output fqdn string = networkModule.outputs.fqdn

@description('Custom domain name')
output domainName string = domainName

@description('SSH command to connect to VM')
output sshCommand string = 'ssh ${adminUsername}@${networkModule.outputs.publicIPAddress}'

@description('n8n URL (after DNS configuration)')
output n8nUrl string = 'https://${domainName}'

@description('TLS email used for Let\'s Encrypt')
output tlsEmail string = calculatedTlsEmail

@description('Network interface ID')
output nicId string = networkModule.outputs.nicId

@description('VNet resource ID')
output vnetId string = networkModule.outputs.vnetId

@description('Subnet resource ID')
output subnetId string = networkModule.outputs.subnetId

@description('NSG resource ID')
output nsgId string = nsgModule.outputs.nsgId

@description('Cloud-init configuration summary')
output cloudInitSummary object = cloudInitModule.outputs.configSummary

@description('Container files included in deployment')
output containerFiles object = cloudInitModule.outputs.filesIncluded

@description('Deployment metadata')
output deploymentMetadata object = {
  timestamp: deploymentTimestamp
  environment: environment
  location: location
  baseName: fullBaseName
  vmSize: vmSize
  n8nVersion: n8nVersion
  domain: domainName
  tlsEmail: calculatedTlsEmail
}
