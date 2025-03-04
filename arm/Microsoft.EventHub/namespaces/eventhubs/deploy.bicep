@description('Required. The name of the EventHub namespace')
param namespaceName string

@description('Required. The name of the EventHub')
param name string

@description('Optional. Authorization Rules for the Event Hub')
param authorizationRules array = [
  {
    name: 'RootManageSharedAccessKey'
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
]

@description('Optional. Number of days to retain the events for this Event Hub, value should be 1 to 7 days')
@minValue(1)
@maxValue(7)
param messageRetentionInDays int = 1

@description('Optional. Number of partitions created for the Event Hub, allowed values are from 1 to 32 partitions.')
@minValue(1)
@maxValue(32)
param partitionCount int = 2

@description('Optional. Enumerates the possible values for the status of the Event Hub.')
@allowed([
  'Active'
  'Creating'
  'Deleting'
  'Disabled'
  'ReceiveDisabled'
  'Renaming'
  'Restoring'
  'SendDisabled'
  'Unknown'
])
param status string = 'Active'

@description('Optional. The consumer groups to create in this event hub instance')
param consumerGroups array = [
  {
    name: '$Default'
  }
]

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Name for capture destination')
param captureDescriptionDestinationName string = 'EventHubArchive.AzureBlockBlob'

@description('Optional. Blob naming convention for archive, e.g. {Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}. Here all the parameters (Namespace,EventHub .. etc) are mandatory irrespective of order')
param captureDescriptionDestinationArchiveNameFormat string = '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'

@description('Optional. Blob container Name')
param captureDescriptionDestinationBlobContainer string = ''

@description('Optional. Resource id of the storage account to be used to create the blobs')
param captureDescriptionDestinationStorageAccountResourceId string = ''

@description('Optional. A value that indicates whether capture description is enabled.')
param captureDescriptionEnabled bool = false

@description('Optional. Enumerates the possible values for the encoding format of capture description. Note: "AvroDeflate" will be deprecated in New API Version')
@allowed([
  'Avro'
  'AvroDeflate'
])
param captureDescriptionEncoding string = 'Avro'

@description('Optional. The time window allows you to set the frequency with which the capture to Azure Blobs will happen')
@minValue(60)
@maxValue(900)
param captureDescriptionIntervalInSeconds int = 300

@description('Optional. The size window defines the amount of data built up in your Event Hub before an capture operation')
@minValue(10485760)
@maxValue(524288000)
param captureDescriptionSizeLimitInBytes int = 314572800

@description('Optional. A value that indicates whether to Skip Empty Archives')
param captureDescriptionSkipEmptyArchives bool = false

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

var eventHubPropertiesSimple = {
  messageRetentionInDays: messageRetentionInDays
  partitionCount: partitionCount
  status: status
}
var eventHubPropertiesWithCapture = {
  messageRetentionInDays: messageRetentionInDays
  partitionCount: partitionCount
  status: status
  captureDescription: {
    destination: {
      name: captureDescriptionDestinationName
      properties: {
        archiveNameFormat: captureDescriptionDestinationArchiveNameFormat
        blobContainer: captureDescriptionDestinationBlobContainer
        storageAccountResourceId: captureDescriptionDestinationStorageAccountResourceId
      }
    }
    enabled: captureDescriptionEnabled
    encoding: captureDescriptionEncoding
    intervalInSeconds: captureDescriptionIntervalInSeconds
    sizeLimitInBytes: captureDescriptionSizeLimitInBytes
    skipEmptyArchives: captureDescriptionSkipEmptyArchives
  }
}

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-06-01-preview' = {
  name: '${namespaceName}/${name}'
  properties: captureDescriptionEnabled ? eventHubPropertiesWithCapture : eventHubPropertiesSimple
}

resource eventHub_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${last(split(eventHub.name, '/'))}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: eventHub
}

module eventHub_consumergroups 'consumergroups/deploy.bicep' = [for (consumerGroup, index) in consumerGroups: {
  name: '${deployment().name}-consumergroup-${index}'
  params: {
    namespaceName: namespaceName
    eventHubName: last(split(eventHub.name, '/'))
    name: consumerGroup.name
    userMetadata: contains(consumerGroup, 'userMetadata') ? consumerGroup.userMetadata : ''
  }
}]

module eventHub_authorizationRules 'authorizationRules/deploy.bicep' = [for (authorizationRule, index) in authorizationRules: {
  name: '${deployment().name}-authorizationRule-${index}'
  params: {
    namespaceName: namespaceName
    eventHubName: last(split(eventHub.name, '/'))
    name: authorizationRule.name
    rights: contains(authorizationRule, 'rights') ? authorizationRule.rights : []
  }
}]

module eventHub_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: eventHub.name
  }
}]

@description('The Name of the Event Hub.')
output eventhubName string = eventHub.name

@description('The Resource ID of the Event Hub.')
output eventHubId string = eventHub.id

@description('The Resource Group Name of the Event Hub.')
output eventHubResourceGroup string = resourceGroup().name

@description('The AuthRuleResourceId of the Event Hub.')
output authRuleResourceId string = resourceId('Microsoft.EventHub/namespaces/authorizationRules', namespaceName, 'RootManageSharedAccessKey')
