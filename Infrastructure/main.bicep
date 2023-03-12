@description('The name of your image registry. Just use the name (not the full URL)')
param deploymentPipelineName string

@description('The amount of containers you wish to deploy. Make sure the amount you want to deploy fits in the subnet size.')
param containerAmount int

@description('The name of the container build. Use anything you like.')
param imageName string

@description('The tag you can use to override what image to deploy. If for whatever reason a deployment has failed, you can revert to an older tag.')
param imageBuildTag string

@description('The URL of your devops organization.')
param azpUrl string

@description('The PAT token, with Agent Pool (read, manage) and Deployment Group (read, manage) rights. https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat')
param azpToken string

@description('The name of your custom pool. It must match exactly with what you have set in the Devops portal.')
param azpPool string

@description('The deployment location of the Azure resources.')
param location string

@description('The VNET address range in CIDR format.')
param vnetAddressPrefix string

@description('10.0.0.0/27')
param subnetAddressPrefix string

@description('The name of your image registry. Just use the name (not the full URL)')
param imageRegistry string

var vnetName = 'vnet-${deploymentPipelineName}'
var subnetName = 'snet-${deploymentPipelineName}'
var containerInstanceGroup = 'cig-${deploymentPipelineName}'
var containerInstance = 'ci-${deploymentPipelineName}'
var image = '${containerRegistry.properties.loginServer}/${imageName}:${imageBuildTag}'

resource aciVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource aciSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  name: subnetName
  parent: aciVnet
  properties: {
    addressPrefix: subnetAddressPrefix
    delegations: [
      {
        name: 'DelegationService'
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}

resource containerInstances 'Microsoft.ContainerInstance/containerGroups@2022-09-01' = {
  name: containerInstanceGroup
  location: location
  properties: {
    imageRegistryCredentials: [
      {
        server: containerRegistry.properties.loginServer
        username: containerRegistry.listCredentials().username
        password: containerRegistry.listCredentials().passwords[0].value
      }
    ]
    containers: [for i in range(0, containerAmount): {
      name: '${containerInstance}-${i}'
      properties: {
        image: image
        resources: {
          requests: {
            cpu: 2
            memoryInGB: 2 
          }
        }
        environmentVariables: [
          {
            name: 'AZP_URL'
            value: azpUrl
          }
          {
            name: 'AZP_TOKEN'
            secureValue: azpToken
          }
          {
            name: 'AZP_AGENT_NAME'
            value: '${deploymentPipelineName}-docker-${i}'
          }
          {
            name: 'AZP_POOL'
            value: azpPool
          }
        ]
      }
    }]
    osType: 'Linux'
    subnetIds: [
      {
        id: aciSubnet.id
      }
    ]
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: imageRegistry
  scope: resourceGroup('rg-registry')
}

output vnetId string = aciVnet.id
