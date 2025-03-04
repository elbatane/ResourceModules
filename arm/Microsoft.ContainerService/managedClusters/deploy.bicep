@description('Required. Specifies the name of the AKS cluster.')
param aksClusterName string

@description('Optional. Specifies the location of AKS cluster. It picks up Resource Group\'s location by default.')
param location string = resourceGroup().location

@description('Optional. Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Optional. The identity of the managed cluster.')
param identity object = {
  type: 'SystemAssigned'
}

@description('Optional. Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  ''
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = ''

@description('Optional. Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  ''
  'azure'
  'calico'
])
param aksClusterNetworkPolicy string = ''

@description('Optional. Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = ''

@description('Optional. A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = ''

@description('Optional. Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = ''

@description('Optional. Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param aksClusterDockerBridgeCidr string = ''

@description('Optional. Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Optional. Outbound IP Count for the Load balancer.')
param managedOutboundIPCount int = 0

@description('Optional. Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'

@description('Optional. Tier of a managed cluster SKU. - Free or Paid')
@allowed([
  'Free'
  'Paid'
])
param aksClusterSkuTier string = 'Free'

@description('Optional. Version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = ''

@description('Optional. Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string = 'azureuser'

@description('Optional. Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string = ''

@description('Optional. Information about a service principal identity for the cluster to use for manipulating Azure APIs.')
param aksServicePrincipalProfile object = {}

@description('Optional. The client AAD application ID.')
param aadProfileClientAppID string = ''

@description('Optional. The server AAD application ID.')
param aadProfileServerAppID string = ''

@description('Optional. The server AAD application secret.')
param aadProfileServerAppSecret string = ''

@description('Optional. Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Optional. Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Optional. Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = true

@description('Optional. Specifies whether to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = true

@description('Optional. Name of the resource group containing agent pool nodes.')
param nodeResourceGroup string = '${resourceGroup().name}_aks_${aksClusterName}_nodes'

@description('Optional. Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = false

@description('Required. Properties of the primary agent pool.')
param primaryAgentPoolProfile array

@description('Optional. Define one or multiple node pools')
param additionalAgentPools array = []

@description('Optional. Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Optional. Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

@description('Optional. Specifies whether the azurepolicy add-on is enabled or not.')
param azurePolicyEnabled bool = true

@description('Optional. Specifies the azure policy version to use.')
param azurePolicyVersion string = 'v2'

@description('Optional. Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Optional. Specifies the scan interval of the auto-scaler of the AKS cluster.')
param autoScalerProfileScanInterval string = '10s'

@description('Optional. Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

@description('Optional. Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

@description('Optional. Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

@description('Optional. Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnneededTime string = '10m'

@description('Optional. Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnreadyTime string = '20m'

@description('Optional. Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
param autoScalerProfileUtilizationThreshold string = '0.5'

@description('Optional. Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
param autoScalerProfileMaxGracefulTerminationSec string = '600'

@description('Optional. Resource identifier of the Diagnostic Storage Account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource identifier of Log Analytics.')
param workspaceId string = ''

@description('Optional. Specifies whether the OMS agent is enabled.')
param omsAgentEnabled bool = true

@description('Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param eventHubAuthorizationRuleId string = ''

@description('Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param eventHubName string = ''

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'kube-apiserver'
  'kube-audit'
  'kube-controller-manager'
  'kube-scheduler'
  'cluster-autoscaler'
])
param logsToEnable array = [
  'kube-apiserver'
  'kube-audit'
  'kube-controller-manager'
  'kube-scheduler'
  'cluster-autoscaler'
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

var aksClusterLinuxProfile = {
  adminUsername: aksClusterAdminUsername
  ssh: {
    publicKeys: [
      {
        keyData: aksClusterSshPublicKey
      }
    ]
  }
}

var lbProfile = {
  managedOutboundIPs: {
    count: managedOutboundIPCount
  }
  effectiveOutboundIPs: []
}

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource managedCluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: aksClusterName
  location: location
  tags: (empty(tags) ? null : tags)
  identity: identity
  properties: {
    kubernetesVersion: (empty(aksClusterKubernetesVersion) ? null : aksClusterKubernetesVersion)
    dnsPrefix: aksClusterDnsPrefix
    agentPoolProfiles: primaryAgentPoolProfile
    sku: {
      name: 'Basic'
      tier: aksClusterSkuTier
    }
    linuxProfile: (empty(aksClusterSshPublicKey) ? null : aksClusterLinuxProfile)
    servicePrincipalProfile: (empty(aksServicePrincipalProfile) ? null : aksServicePrincipalProfile)
    addonProfiles: {
      httpApplicationRouting: {
        enabled: httpApplicationRoutingEnabled
      }
      omsagent: {
        enabled: (omsAgentEnabled && (!empty(workspaceId)))
        config: {
          logAnalyticsWorkspaceResourceID: ((!empty(workspaceId)) ? workspaceId : null)
        }
      }
      aciConnectorLinux: {
        enabled: aciConnectorLinuxEnabled
      }
      azurepolicy: {
        enabled: azurePolicyEnabled
        config: {
          version: azurePolicyVersion
        }
      }
      kubeDashboard: {
        enabled: kubeDashboardEnabled
      }
    }
    enableRBAC: aadProfileEnableAzureRBAC
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: (empty(aksClusterNetworkPlugin) ? null : aksClusterNetworkPlugin)
      networkPolicy: (empty(aksClusterNetworkPolicy) ? null : aksClusterNetworkPolicy)
      podCidr: (empty(aksClusterPodCidr) ? null : aksClusterPodCidr)
      serviceCidr: (empty(aksClusterServiceCidr) ? null : aksClusterServiceCidr)
      dnsServiceIP: (empty(aksClusterDnsServiceIP) ? null : aksClusterDnsServiceIP)
      dockerBridgeCidr: (empty(aksClusterDockerBridgeCidr) ? null : aksClusterDockerBridgeCidr)
      outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
      loadBalancerProfile: ((managedOutboundIPCount == 0) ? null : lbProfile)
    }
    aadProfile: {
      clientAppID: aadProfileClientAppID
      serverAppID: aadProfileServerAppID
      serverAppSecret: aadProfileServerAppSecret
      managed: aadProfileManaged
      enableAzureRBAC: aadProfileEnableAzureRBAC
      adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
      tenantID: aadProfileTenantId
    }
    autoScalerProfile: {
      'scan-interval': autoScalerProfileScanInterval
      'scale-down-delay-after-add': autoScalerProfileScaleDownDelayAfterAdd
      'scale-down-delay-after-delete': autoScalerProfileScaleDownDelayAfterDelete
      'scale-down-delay-after-failure': autoScalerProfileScaleDownDelayAfterFailure
      'scale-down-unneeded-time': autoScalerProfileScaleDownUnneededTime
      'scale-down-unready-time': autoScalerProfileScaleDownUnreadyTime
      'scale-down-utilization-threshold': autoScalerProfileUtilizationThreshold
      'max-graceful-termination-sec': autoScalerProfileMaxGracefulTerminationSec
    }
    apiServerAccessProfile: {
      enablePrivateCluster: aksClusterEnablePrivateCluster
    }
  }
}

resource aksClusterName_nodePoolName 'Microsoft.ContainerService/managedClusters/agentPools@2021-05-01' = [for additionalAgentPool in additionalAgentPools: {
  name: additionalAgentPool.name
  properties: additionalAgentPool.properties
  parent: managedCluster
}]

resource managedCluster_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${managedCluster.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: managedCluster
}

resource managedCluster_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${managedCluster.name}-diagnosticSettings'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? null : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? null : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? null : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsLogs)
  }
  scope: managedCluster
}

module managedCluster_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: managedCluster.name
  }
}]

output azureKubernetesServiceResourceId string = managedCluster.id
output azureKubernetesServiceResourceGroup string = resourceGroup().name
output azureKubernetesServiceName string = managedCluster.name
output controlPlaneFQDN string = (aksClusterEnablePrivateCluster ? managedCluster.properties.privateFQDN : managedCluster.properties.fqdn)
