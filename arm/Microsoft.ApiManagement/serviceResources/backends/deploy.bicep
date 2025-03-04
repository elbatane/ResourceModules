@description('Required. The name of the of the Api Management service.')
param apiManagementServiceName string

@description('Required. Backend Name.')
param backendName string = ''

@description('Optional. Backend Credentials Contract Properties.')
param credentials object = {}

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

@description('Optional. Backend Description.')
param backendDescription string = ''

@description('Required. Backend communication protocol. - http or soap')
param protocol string = 'http'

@description('Optional. Backend Proxy Contract Properties')
param proxy object = {}

@description('Optional. Management Uri of the Resource in External System. This url can be the Arm Resource Id of Logic Apps, Function Apps or Api Apps.')
param resourceId string = ''

@description('Optional. Backend Service Fabric Cluster Properties.')
param serviceFabricCluster object = {}

@description('Optional. Backend Title.')
param title string = ''

@description('Optional. Backend TLS Properties')
param tls object = {
  validateCertificateChain: false
  validateCertificateName: false
}

@description('Required. Runtime Url of the Backend.')
param url string

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource backend 'Microsoft.ApiManagement/service/backends@2020-06-01-preview' = {
  name: '${apiManagementServiceName}/${backendName}'
  properties: {
    title: !empty(title) ? title : null
    description: !empty(backendDescription) ? backendDescription : null
    resourceId: !empty(resourceId) ? resourceId : null
    properties: {
      serviceFabricCluster: !empty(serviceFabricCluster) ? serviceFabricCluster : null
    }
    credentials: !empty(credentials) ? credentials : null
    proxy: !empty(proxy) ? proxy : null
    tls: !empty(tls) ? tls : null
    url: url
    protocol: protocol
  }
}

@description('The resourceId of the API management service backend')
output backendResourceId string = backend.id

@description('The name of the API management service backend')
output backendName string = backend.name

@description('The resource group the API management service backend was deployed into')
output backendResourceGroup string = resourceGroup().name
