# Deploying Docker Agents

This repo is part of this blog post: https://justanothercloudblog.com/blog/deploy-private-pipeline-agents/

## Required Pipeline Variables (discussed in the post)
```yml
imageRegistry:
    Usage: The name of your image registry. Just use the name (not the full URL)
    Secret: No
    Example: justanothercloudblog
imageName:
    Usage: The name of the container build. Use anything you like
    Secret: No
    Example: Azure-Agents
imageBuildTag:
    Usage: The tag you can use to override what image to deploy. If for whatever reason a deployment has failed, you can revert to an older tag.
    Secret: No
    Example: latest
azpPool:
    Usage: The name of your custom pool. It must match exactly with what you have set in the Devops portal.
    Secret: No
    Example: Private Deployment Pipeline
azpUrl:
    Usage: The URL of your devops organization.
    Secret: No
    Example: https://dev.azure.com/justanothercloudblog
azpToken:
    Usage: The PAT token, with Agent Pool (read, manage) and Deployment Group (read, manage) rights. https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat
    Secret: Yes
    Example: 111222333 (secret value)
containerAmount:
    Usage: The amount of containers you wish to deploy. Make sure the amount you want to deploy fits in the subnet size.
    Secret: No
    Example: 1
deploymentPipelineName:
    Usage: The name that the resources get in the Azure Portal.
    Secret: No
    Example: deployment-agents
vnetPrefix:
    Usage: The VNET address range in CIDR format.
    Secret: No
    Example: 10.0.0.0/24
subnetPrefix:
    Usage: The Subnet address range in CIDR format. This range must fit in the VNET range.
    Secret: No
    Example: 10.0.0.0/27
location:
    Usage: The deployment location of the Azure resources.
    Secret: No
    Example: westeurope
```

