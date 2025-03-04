# AzureNetAppFiles `[Microsoft.NetApp/netAppAccounts]`

This template deploys Azure NetApp Files.

## Resource types

| Resource Type | Api Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | 2016-09-01 |
| `Microsoft.Authorization/roleAssignments` | 2020-04-01-preview |
| `Microsoft.NetApp/netAppAccounts` | 2021-04-01 |
| `Microsoft.NetApp/netAppAccounts/capacityPools` | 2021-04-01 |
| `Microsoft.NetApp/netAppAccounts/capacityPools/volumes` | 2021-04-01 |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `capacityPools` | array | `[]` |  | Optional. Capacity pools to create. |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered |
| `dnsServers` | string |  |  | Optional. Required if domainName is specified. Comma separated list of DNS server IP addresses (IPv4 only) required for the Active Directory (AD) domain join and SMB authentication operations to succeed. |
| `domainJoinOU` | string |  |  | Optional. Used only if domainName is specified. LDAP Path for the Organization Unit (OU) where SMB Server machine accounts will be created (i.e. 'OU=SecondLevel,OU=FirstLevel'). |
| `domainJoinPassword` | secureString |  |  | Optional. Required if domainName is specified. Password of the user specified in domainJoinUser parameter |
| `domainJoinUser` | string |  |  | Optional. Required if domainName is specified. Username of Active Directory domain administrator, with permissions to create SMB server machine account in the AD domain. |
| `domainName` | string |  |  | Optional. Fully Qualified Active Directory DNS Domain Name (e.g. 'contoso.com') |
| `location` | string | `[resourceGroup().location]` |  | Optional. Location for all resources. |
| `lock` | string | `NotSpecified` | `[CanNotDelete, NotSpecified, ReadOnly]` | Optional. Specify the type of lock. |
| `netAppAccountName` | string |  |  | Required. The name of the NetApp account. |
| `roleAssignments` | array | `[]` |  | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or it's fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `smbServerNamePrefix` | string |  |  | Optional. Required if domainName is specified. NetBIOS name of the SMB server. A computer account with this prefix will be registered in the AD and used to mount volumes |
| `tags` | object | `{object}` |  | Optional. Tags for all resources. |

### Parameter Usage: `capacityPools`

The `capacityPools` parameter accepts a JSON array of objects with the following properties:

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
|poolName | string | Required. The name of the capacity pool. |
|poolServiceLevel | string | Required. The service level of the file system. - Standard, Premium, Ultra |
|poolSize | int | Required. Provisioned size of the pool (in bytes). Allowed values are in 4TiB chunks (value must be multiply of 4398046511104). |
|volumes | array | Optional. Volumes to be created. |
|roleAssignments | array | Optional. RBAC can also be assigned at capacity pool level. |

Here's an example of specifying a single capacity pool with no volumes, named "sxx-az-anfcp-x-001", with Premium service level, 4TiB of size and Reader role assigned to two principal Ids.

```json
"capacityPools": {
    "value": [
        {
            "poolName": "sxx-az-anfcp-x-001",
            "poolServiceLevel": "Premium",
            "poolSize": 4398046511104,
            "volumes": [],
            "roleAssignments": [
                {
                    "roleDefinitionIdOrName": "Reader",
                    "principalIds": [
                        "12345678-1234-1234-1234-123456789012" // object 1
                        "78945612-1234-1234-1234-123456789012" // object 2
                    ]
                }
            ]
        }
    ]
}
```

As part of the capacityPool parameter, the `volumes` parameter accepts a JSON array of objects with the following properties:

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
|poolVolumeName | string | Required. The name of the volume. |
|creationToken | string | Required. A unique file path for the volume. Used when creating mount targets. |
|poolVolumeQuota | int | Required. Maximum storage quota allowed for a file system in bytes. This is a soft quota used for alerting only. Minimum size is 100 GiB. Upper limit is 100TiB. Specified in bytes. |
|protocolTypes | array | Required. Set of protocol types - string |
|exportPolicy | object | Optional. Set of export policy rules for NFS volume types. You can create up to five export policy rules. |
|subnetId | string | Required. The Azure Resource URI for a delegated subnet. Must have the delegation Microsoft.NetApp/volumes. |
|roleAssignments | array | Optional. RBAC can also be assigned at capacity pool level. |

Here's an example of specifying three volumes of different protocol types: NFSv3, NFSv4.1 and SMB (CIFS) named respectively "vol01-nfsv3", "vol01-nfsv41" and "vol01-smb".
Each having 100GB of storage quota and using the same delegated subnet.
The NTFSv4.1 volume also specifies one export policy rule allowing Read and Write access to the volume.

```json
"volumes": [
    // NFS3 VOL
    {
        "poolVolumeName": "vol01-nfsv3",
        "creationToken": "vol01-nfsv3",
        "poolVolumeQuota": 107374182400,
        "protocolTypes": [
            "NFSv3"
        ],
        "subnetId": "/subscriptions/8629be3b-96bc-482d-a04b-ffff597c65a2/resourceGroups/dependencies-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-002/subnets/sxx-az-subnet-x-004",
        "roleAssignments": []
    },
    // NFS41 VOL
    {
        "poolVolumeName": "vol01-nfsv41",
        "creationToken": "vol01-nfsv41",
        "poolVolumeQuota": 107374182400,
        "protocolTypes": [
            "NFSv4.1"
        ],
        "exportPolicy": {
            "rules": [
                {
                    "ruleIndex": 1,
                    "unixReadOnly": false,
                    "unixReadWrite": true,
                    "nfsv3": false,
                    "nfsv41": true,
                    "allowedClients": "0.0.0.0/0"
                }
            ]
        },
        "subnetId": "/subscriptions/8629be3b-96bc-482d-a04b-ffff597c65a2/resourceGroups/dependencies-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-002/subnets/sxx-az-subnet-x-004",
        "roleAssignments": []
    },
    // SMB VOL (Requires AD connection)
    {
        "poolVolumeName": "vol01-smb",
        "creationToken": "vol01-smb",
        "poolVolumeQuota": 107374182400,
        "protocolTypes": [
            "CIFS"
        ],
        "subnetId": "/subscriptions/8629be3b-96bc-482d-a04b-ffff597c65a2/resourceGroups/dependencies-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-002/subnets/sxx-az-subnet-x-004",
        "roleAssignments": []
    }
]
```

### Parameter Usage: `roleAssignments`

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Reader",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012" // object 1
            ]
        }
    ]
}
```

### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

```json
"tags": {
    "value": {
        "Environment": "Non-Prod",
        "Contact": "test.user@testcompany.com",
        "PurchaseOrder": "1234",
        "CostCenter": "7890",
        "ServiceName": "DeploymentValidation",
        "Role": "DeploymentValidation"
    }
}
```

## Outputs

| Output Name | Type |
| :-- | :-- |
| `netAppAccountName` | string |
| `netAppAccountResourceGroup` | string |
| `netAppAccountResourceId` | string |

## Template references

- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2016-09-01/locks)
- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-04-01-preview/roleAssignments)
- [Netappaccounts](https://docs.microsoft.com/en-us/azure/templates/Microsoft.NetApp/2021-04-01/netAppAccounts)
- [Netappaccounts/Capacitypools](https://docs.microsoft.com/en-us/azure/templates/Microsoft.NetApp/2021-04-01/netAppAccounts/capacityPools)
- [Netappaccounts/Capacitypools/Volumes](https://docs.microsoft.com/en-us/azure/templates/Microsoft.NetApp/2021-04-01/netAppAccounts/capacityPools/volumes)
