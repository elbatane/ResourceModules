@description('Optional. Name of the Key Vault. If no name is provided, then unique name will be created.')
@maxLength(24)
param name string = ''

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Array of access policies object')
param accessPolicies array = []

@description('Optional. All secrets to create')
param secrets array = []

@description('Optional. All keys to create')
param keys array = []

@description('Optional. Specifies if the vault is enabled for deployment by script or compute')
@allowed([
  true
  false
])
param enableVaultForDeployment bool = true

@description('Optional. Specifies if the vault is enabled for a template deployment')
@allowed([
  true
  false
])
param enableVaultForTemplateDeployment bool = true

@description('Optional. Specifies if the azure platform has access to the vault for enabling disk encryption scenarios.')
@allowed([
  true
  false
])
param enableVaultForDiskEncryption bool = true

@description('Optional. Switch to enable/disable Key Vault\'s soft delete feature.')
param enableSoftDelete bool = true

@description('Optional. softDelete data retention days. It accepts >=7 and <=90.')
param softDeleteRetentionInDays int = 90

@description('Optional. Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored (warning: this is a preview feature). When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. If null or not specified, the vault is created with the default value of false. Note that management actions are always authorized with RBAC.')
param enableRbacAuthorization bool = false

@description('Optional. The vault\'s create mode to indicate whether the vault need to be recovered or not. - recover or default.')
param createMode string = 'default'

@description('Optional. Provide \'true\' to enable Key Vault\'s purge protection feature.')
param enablePurgeProtection bool = false

@description('Optional. Specifies the SKU for the vault')
@allowed([
  'premium'
  'standard'
])
param vaultSku string = 'premium'

@description('Optional. Service endpoint object information')
param networkAcls object = {}

@description('Optional. Virtual Network resource identifier, if networkAcls is passed, this value must be passed as well')
param vNetId string = ''

@description('Optional. The name of the Diagnostic setting.')
param diagnosticSettingName string = 'service'

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource identifier of the Diagnostic Storage Account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource identifier of Log Analytics.')
param workspaceId string = ''

@description('Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param eventHubAuthorizationRuleId string = ''

@description('Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param eventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Configuration Details for private endpoints.')
param privateEndpoints array = []

@description('Optional. Resource tags.')
param tags object = {}

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

@description('Generated. Do not provide a value! This date value is used to generate a SAS token to access the modules.')
param baseTime string = utcNow('u')

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'AuditEvent'
])
param logsToEnable array = [
  'AuditEvent'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

var diagnosticsLogs = [for log in logsToEnable: {
  category: log
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in metricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var maxNameLength = 24
var uniquenameUntrim = uniqueString('Key Vault${baseTime}')
var uniquename = (length(uniquenameUntrim) > maxNameLength ? substring(uniquenameUntrim, 0, maxNameLength) : uniquenameUntrim)
var name_var = empty(name) ? uniquename : name
var virtualNetworkRules = [for networkrule in ((contains(networkAcls, 'virtualNetworkRules')) ? networkAcls.virtualNetworkRules : []): {
  id: '${vNetId}/subnets/${networkrule.subnet}'
}]
var networkAcls_var = {
  bypass: (empty(networkAcls) ? null : networkAcls.bypass)
  defaultAction: (empty(networkAcls) ? null : networkAcls.defaultAction)
  virtualNetworkRules: (empty(networkAcls) ? null : virtualNetworkRules)
  ipRules: (empty(networkAcls) ? null : ((length(networkAcls.ipRules) == 0) ? [] : networkAcls.ipRules))
}

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name_var
  location: location
  tags: tags
  properties: {
    enabledForDeployment: enableVaultForDeployment
    enabledForTemplateDeployment: enableVaultForTemplateDeployment
    enabledForDiskEncryption: enableVaultForDiskEncryption
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    createMode: createMode
    enablePurgeProtection: ((!enablePurgeProtection) ? null : enablePurgeProtection)
    tenantId: subscription().tenantId
    accessPolicies: accessPolicies
    sku: {
      name: vaultSku
      family: 'A'
    }
    networkAcls: (empty(networkAcls) ? null : networkAcls_var)
  }
}

resource keyVault_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${keyVault.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: keyVault
}

resource keyVault_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${name_var}-${diagnosticSettingName}'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? null : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? null : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? null : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsLogs)
  }
  scope: keyVault
}

module keyVault_secrets 'secrets/deploy.bicep' = [for (secret, index) in secrets: {
  name: '${uniqueString(deployment().name, location)}-Secret-${index}'
  params: {
    name: secret.name
    value: secret.value
    vaultName: keyVault.name
    attributesEnabled: contains(secret, 'attributesEnabled') ? secret.attributesEnabled : true
    attributesExp: contains(secret, 'attributesExp') ? secret.attributesExp : -1
    attributesNbf: contains(secret, 'attributesNbf') ? secret.attributesNbf : -1
    contentType: contains(secret, 'contentType') ? secret.contentType : ''
    tags: contains(secret, 'tags') ? secret.tags : {}
  }
  dependsOn: [
    keyVault
  ]
}]

module keyVault_keys 'keys/deploy.bicep' = [for (key, index) in keys: {
  name: '${uniqueString(deployment().name, location)}-Key-${index}'
  params: {
    name: key.name
    vaultName: keyVault.name
    attributesEnabled: contains(key, 'attributesEnabled') ? key.attributesEnabled : true
    attributesExp: contains(key, 'attributesExp') ? key.attributesExp : -1
    attributesNbf: contains(key, 'attributesNbf') ? key.attributesNbf : -1
    curveName: contains(key, 'curveName') ? key.curveName : 'P-256'
    keyOps: contains(key, 'keyOps') ? key.keyOps : []
    keySize: contains(key, 'keySize') ? key.keySize : -1
    kty: contains(key, 'kty') ? key.kty : 'EC'
    tags: contains(key, 'tags') ? key.tags : {}
  }
  dependsOn: [
    keyVault
  ]
}]

module keyVault_privateEndpoints '.bicep/nested_privateEndpoint.bicep' = [for (privateEndpoint, index) in privateEndpoints: {
  name: '${uniqueString(deployment().name, location)}-PrivateEndpoint-${index}'
  params: {
    privateEndpointResourceId: keyVault.id
    privateEndpointVnetLocation: (empty(privateEndpoints) ? 'dummy' : reference(split(privateEndpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location)
    privateEndpointObj: privateEndpoint
    tags: tags
  }
}]

module keyVault_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: keyVault.name
  }
}]

@description('The Resource Id of the Key Vault.')
output keyVaultResourceId string = keyVault.id

@description('The name of the Resource Group the Key Vault was created in.')
output keyVaultResourceGroup string = resourceGroup().name

@description('The Name of the Key Vault.')
output keyVaultName string = keyVault.name

@description('The URL of the Key Vault.')
output keyVaultUrl string = reference(keyVault.id, '2016-10-01').vaultUri
