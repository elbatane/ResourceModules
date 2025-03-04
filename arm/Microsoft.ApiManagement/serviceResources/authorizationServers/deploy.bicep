@description('Required. Identifier of the authorization server.')
param apiManagementServiceAuthorizationServerName string

@description('Required. The name of the of the Api Management service.')
param apiManagementServiceName string

@description('Required. OAuth authorization endpoint. See <http://tools.ietf.org/html/rfc6749#section-3.2>.')
param authorizationEndpoint string = ''

@description('Optional. HTTP verbs supported by the authorization endpoint. GET must be always present. POST is optional. - HEAD, OPTIONS, TRACE, GET, POST, PUT, PATCH, DELETE')
param authorizationMethods array = [
  'GET'
]

@description('Required. Specifies the mechanism by which access token is passed to the API. - authorizationHeader or query')
param bearerTokenSendingMethods array = [
  'authorizationHeader'
]

@description('Required. Method of authentication supported by the token endpoint of this authorization server. Possible values are Basic and/or Body. When Body is specified, client credentials and other parameters are passed within the request body in the application/x-www-form-urlencoded format. - Basic or Body')
param clientAuthenticationMethod array = []

@description('Required. Client or app id registered with this authorization server.')
param clientId string = ''

@description('Required. Optional reference to a page where client or app registration for this authorization server is performed. Contains absolute URL to entity being referenced.')
param clientRegistrationEndpoint string = ''

@description('Required. Client or app secret registered with this authorization server. This property will not be filled on \'GET\' operations! Use \'/listSecrets\' POST request to get the value.')
@secure()
param clientSecret string = ''

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

@description('Optional. Access token scope that is going to be requested by default. Can be overridden at the API level. Should be provided in the form of a string containing space-delimited values.')
param defaultScope string = ''

@description('Optional. Description of the authorization server. Can contain HTML formatting tags.')
param serverDescription string = ''

@description('Required. Form of an authorization grant, which the client uses to request the access token. - authorizationCode, implicit, resourceOwnerPassword, clientCredentials')
param grantTypes array = []

@description('Optional. Can be optionally specified when resource owner password grant type is supported by this authorization server. Default resource owner password.')
param resourceOwnerPassword string = ''

@description('Optional. Can be optionally specified when resource owner password grant type is supported by this authorization server. Default resource owner username.')
param resourceOwnerUsername string = ''

@description('Optional. If true, authorization server will include state parameter from the authorization request to its response. Client may use state parameter to raise protocol security.')
param supportState bool = false

@description('Optional. Additional parameters required by the token endpoint of this authorization server represented as an array of JSON objects with name and value string properties, i.e. {"name" : "name value", "value": "a value"}. - TokenBodyParameterContract object')
param tokenBodyParameters array = []

@description('Optional. OAuth token endpoint. Contains absolute URI to entity being referenced.')
param tokenEndpoint string = ''

var defaultAuthorizationMethods = [
  'GET'
]
var setAuthorizationMethods = union(authorizationMethods, defaultAuthorizationMethods)

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource authorizationServer 'Microsoft.ApiManagement/service/authorizationServers@2020-06-01-preview' = {
  name: '${apiManagementServiceName}/${apiManagementServiceAuthorizationServerName}'
  properties: {
    description: serverDescription
    authorizationMethods: setAuthorizationMethods
    clientAuthenticationMethod: clientAuthenticationMethod
    tokenBodyParameters: tokenBodyParameters
    tokenEndpoint: tokenEndpoint
    supportState: supportState
    defaultScope: defaultScope
    bearerTokenSendingMethods: bearerTokenSendingMethods
    resourceOwnerUsername: resourceOwnerUsername
    resourceOwnerPassword: resourceOwnerPassword
    displayName: apiManagementServiceAuthorizationServerName
    clientRegistrationEndpoint: clientRegistrationEndpoint
    authorizationEndpoint: authorizationEndpoint
    grantTypes: grantTypes
    clientId: clientId
    clientSecret: clientSecret
  }
}

@description('The name of the API management service authorization server')
output authorizationServerName string = authorizationServer.name

@description('The resourceId of the API management service authorization server')
output authorizationServerResourceId string = authorizationServer.id

@description('The resource group the API management service authorization server was deployed into')
output authorizationServerResourceGroup string = resourceGroup().name
