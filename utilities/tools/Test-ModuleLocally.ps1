﻿
<#
.SYNOPSIS
This Function Helps with Testing A Module Locally

.DESCRIPTION
This Function Helps with Testing A Module Locally. Use this Function To perform Pester Testing for a Module and then attempting to deploy it. It Also allows you to use your own
subscription Id, Principal Id, tenant ID and other parameters that need to be tokenized.

.PARAMETER ModuleName
Mandatory. A String for the name of The module to test. (i.e. 'Microsoft.Authorization/policyExemptions')

.PARAMETER PesterTest
Optional. A Switch Parameter that triggers a Pester Test for the Module

.PARAMETER ValidateOrDeployParameters
An Object consisting of the components that are required when using the Validate Test or DeploymentTest Switch parameter. See example:

.PARAMETER DeploymentTest
Optional. A Switch Parameter that triggers the Deployment of the Module

.PARAMETER ValidationTest
Optional. A Switch Parameter that triggers the Validation of the Module Only without Deployment

.PARAMETER DeployAllModuleParameterFiles
Optional. A Switch Parameter that triggers that enables directory based search for parameter files and deploys all of them. If not provided, it will only deploy the 'parameters.json' file

.PARAMETER GetParameterFileTokens
Optional. A Switch Parameter that triggers that enables the search for both local custom parameter file tokens (source control) and remote custom parameter file tokens (key vault -if TokenKeyVaultName parameter is provided)

.PARAMETER TokenKeyVaultName
Optional. String Parameter that points to the Key Vault Name where remote custom parameter file tokens are created. If not provided then GetParameterFileTokens will only search for local custom parameter file tokens.

.PARAMETER OtherCustomParameterFileTokens
Optional. A Hashtable Parameter that contains custom tokens to be replaced in the paramter files for deployment

.EXAMPLE

$TestModuleLocallyInput = @{
    ModuleName                    = 'Microsoft.Network\applicationSecurityGroups'
    PesterTest                    = $true
    DeploymentTest                = $true
    ValidationTest                = $false
    ValidateOrDeployParameters    = @{
        Location          = 'australiaeast'
        ResourceGroupName = 'validation-rg'
        SubscriptionId    = '12345678-1234-1234-1234-123456789123'
        ManagementGroupId = 'mg-contoso'
        RemoveDeployment  = $false
    }
    DeployAllModuleParameterFiles = $false
    GetParameterFileTokens        = $true
    #TokenKeyVaultName             = 'contoso-platform-kv'
    OtherCustomParameterFileTokens      = @(
        @{ Name = 'deploymentSpId'; Value = '12345678-1234-1234-1234-123456789123' }
        @{ Name = 'tenantId'; Value = '12345678-1234-1234-1234-123456789123' }
    )
}

Test-ModuleLocally @TestModuleLocallyInput -Verbose

.NOTES
- Make sure you provide the right information in the 'ValidateOrDeployParameters' parameter for this function to work.
- Ensure you have the ability to perform the deployment operations using your account
- If providing TokenKeyVaultName parameter, ensure you have read access to secrets in the key vault to be able to retrieve the tokens.

#>
function Test-ModuleLocally {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$ModuleName,

        [parameter(Mandatory = $false)]
        [switch]$PesterTest,

        [parameter(Mandatory)]
        [psobject]$ValidateOrDeployParameters,

        [parameter(Mandatory = $false)]
        [switch]$DeploymentTest,

        [parameter(Mandatory = $false)]
        [switch]$ValidationTest,

        [parameter(Mandatory = $false)]
        [switch]$DeployAllModuleParameterFiles,

        [parameter(Mandatory = $false)]
        [switch]$GetParameterFileTokens,

        [parameter(Mandatory = $false)]
        [string]$TokenKeyVaultName,

        [parameter(Mandatory = $false)]
        [psobject]$OtherCustomParameterFileTokens
    )

    begin {
        Write-Verbose "Running Local Tests for $($ModuleName.Split('\')[-1])"
        # Load Tokens Converter Script
        . (Join-Path $PSScriptRoot '../tokensReplacement/Convert-TokensInParameterFile.ps1')
        . (Join-Path $PSScriptRoot '../tokensReplacement/helper/Convert-TokensInFileList.ps1')
    }
    process {
        # Test Module
        if ($PesterTest) {
            Write-Verbose "Pester Testing Module: $ModuleName"
            try {
                Import-Module Pester
                Invoke-Pester -Configuration @{
                    Run        = @{
                        Container = New-PesterContainer -Path (Join-Path $PSScriptRoot '../..' 'arm/.global/global.module.tests.ps1') -Data @{
                            moduleFolderPaths = (Join-Path $PSScriptRoot '../../arm' $ModuleName)
                        }
                    }
                    Filter     = @{
                        #ExcludeTag = 'ApiCheck'
                        #Tag = 'ApiCheck'
                    }
                    TestResult = @{
                        TestSuiteName = 'Global Module Tests'
                        Enabled       = $false
                    }
                    Output     = @{
                        Verbosity = 'Detailed'
                    }
                }
            } catch {
                $PSItem.Exception.Message
            }
        }
        # Deploy Module
        if (($ValidationTest -or $DeploymentTest) -and $ValidateOrDeployParameters) {
            # Find Test Parameter Files
            $ModuleParameterFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot '../../arm' $ModuleName '.parameters') -Recurse
            # Replace Tokens with Values For Local Testing
            $DefaultParameterFileTokens = @(
                @{ Name = 'subscriptionId'; Value = "$($ValidateOrDeployParameters.SubscriptionId)" }
                @{ Name = 'managementGroupId'; Value = "$($ValidateOrDeployParameters.ManagementGroupId)" }
                @{ Name = 'resourceGroupName'; Value = "$($ValidateOrDeployParameters.resourceGroupName)" }
            ) | ForEach-Object { [PSCustomObject]$PSItem }

            # Look for Local Custom Parameter File Tokens (Source Control)
            if ($GetParameterFileTokens) {
                # Get Settings JSON File
                $Settings = Get-Content -Path (Join-Path $PSScriptRoot '../..' 'settings.json') | ConvertFrom-Json
                # Get Custom Parameter File Tokens (Local and Remote-If Key Vault Provided)
                $ConvertTokensInputs = @{
                    DefaultParameterFileTokens     = $DefaultParameterFileTokens
                    LocalCustomParameterFileTokens = $Settings.parameterFileTokens.localTokens.tokens
                    TokenPrefix                    = $Settings.parameterFileTokens.tokenPrefix
                    TokenSuffix                    = $Settings.parameterFileTokens.tokenSuffix
                }
                # Query Key Vault for Remote Tokens
                if ($TokenKeyVaultName -and "$($ValidateOrDeployParameters.SubscriptionId)") {
                    $ConvertTokensInputs += @{
                        TokensKeyVaultName           = $TokenKeyVaultName
                        TokensKeyVaultSubscriptionId = "$($ValidateOrDeployParameters.SubscriptionId)"
                    }
                    if ($Settings.parameterFileTokens.remoteTokens.keyVaultSecretNamePrefix) {
                        $ConvertTokensInputs += @{ TokensKeyVaultSecretNamePrefix = $Settings.parameterFileTokens.remoteTokens.keyVaultSecretNamePrefix
                        }
                    }
                }

                #Add Other Parameter File Tokens (For Testing)
                if ($OtherCustomParameterFileTokens) {
                    $ConvertTokensInputs += @{ OtherCustomParameterFileTokens = $OtherCustomParameterFileTokens
                    }
                }
            }
            # Invoke Token Replacement Functionality and Convert Tokens in Parameter Files
            Write-Verbose 'Invoking Convert-TokensInFileList'
            $ModuleParameterFiles | ForEach-Object { Convert-TokensInParameterFile @ConvertTokensInputs -ParameterFilePath $PSItem.FullName -Verbose }

            # Build Modules Validation and Deployment Inputs
            $functionInput = @{
                templateFilePath  = (Join-Path $PSScriptRoot '../../arm' $ModuleName 'deploy.bicep')
                parameterFilePath = (Join-Path $PSScriptRoot '../../arm' $ModuleName '.parameters/parameters.json')
                location          = "$($ValidateOrDeployParameters.Location)"
                resourceGroupName = "$($ValidateOrDeployParameters.ResourceGroupName)"
                subscriptionId    = "$($ValidateOrDeployParameters.SubscriptionId)"
                managementGroupId = "$($ValidateOrDeployParameters.ManagementGroupId)"
            }

            try {
                # Validate Template
                if ($ValidationTest) {
                    Write-Verbose "Validating Module: $ModuleName"
                    # Load Modules Deployment Script
                    . (Join-Path $PSScriptRoot '../..' '.github/actions/templates/validateModuleDeploy/scripts/Test-TemplateWithParameterFile.ps1')
                    # Invoke Validation
                    Test-TemplateWithParameterFile @functionInput -Verbose
                }

                # Deploy Template
                if ($DeploymentTest) {
                    Write-Verbose "Deploying Module: $ModuleName"
                    # Set the ParameterFilePath to Directory instead of the default 'parameters.json'
                    if ($DeployAllModuleParameterFiles) {
                        $functionInput.parameterFilePath = (Join-Path $PSScriptRoot '../../arm' $ModuleName '.parameters')
                    }
                    # Append to Function Input the required parameters for Deployment
                    $functionInput += @{
                        moduleName       = "l-$($ModuleName.Split('\')[-1])"
                        removeDeployment = [System.Convert]::ToBoolean($ValidateOrDeployParameters.RemoveDeployment)
                        retryLimit       = 1
                    }
                    # Load Modules Deployment Script
                    . (Join-Path $PSScriptRoot '../..' '.github/actions/templates/deployModule/scripts/New-ModuleDeployment.ps1')
                    # Invoke Deployment
                    New-ModuleDeployment @functionInput -Verbose
                }
            } catch {
                Write-Error $PSItem.Exception
            }
        }
    }

    end {
        # Restore Parameter Files
        if (($ValidationTest -or $DeploymentTest) -and $ValidateOrDeployParameters) {
            # Replace Values with Tokens For Repo Updates
            Write-Verbose 'Restoring Tokens'
            $ModuleParameterFiles | ForEach-Object { Convert-TokensInParameterFile @ConvertTokensInputs -ParameterFilePath $PSItem.FullName -RestoreTokens $true -Verbose }
        }
    }
}
