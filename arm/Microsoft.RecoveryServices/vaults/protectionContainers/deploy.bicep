@description('Required. Name of the Azure Recovery Service Vault')
@minLength(1)
param recoveryVaultName string

@description('Required. Name of the Azure Recovery Service Vault Protection Container')
param name string

@description('Optional. Backup management type to execute the current Protection Container job.')
@allowed([
  'AzureBackupServer'
  'AzureIaasVM'
  'AzureSql'
  'AzureStorage'
  'AzureWorkload'
  'DPM'
  'DefaultBackup'
  'Invalid'
  'MAB'
  ''
])
param backupManagementType string = ''

@description('Optional. Resource Id of the target resource for the Protection Container ')
param sourceResourceId string = ''

@description('Optional. Friendly name of the Protection Container')
param friendlyName string = ''

@description('Optional. Type of the container')
@allowed([
  'AzureBackupServerContainer'
  'AzureSqlContainer'
  'GenericContainer'
  'Microsoft.ClassicCompute/virtualMachines'
  'Microsoft.Compute/virtualMachines'
  'SQLAGWorkLoadContainer'
  'StorageContainer'
  'VMAppContainer'
  'Windows'
  ''
])
param containerType string = ''

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

module pid_cuaId './.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2021-08-01' = {
  name: '${recoveryVaultName}/Azure/${name}'
  properties: {
    sourceResourceId: (empty(sourceResourceId) ? null : sourceResourceId)
    friendlyName: (empty(friendlyName) ? null : friendlyName)
    backupManagementType: (empty(backupManagementType) ? null : backupManagementType)
    containerType: (empty(containerType) ? null : containerType)
  }
}

@description('The name of the Resource Group the Protection Container was created in.')
output protectionContainerResourceGroup string = resourceGroup().name

@description('The Resource Id of the Protection Container.')
output protectionContainerId string = protectionContainer.id

@description('The Name of the Protection Container.')
output protectionContainerName string = protectionContainer.name
