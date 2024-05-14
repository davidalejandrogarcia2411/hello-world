Configuration datadogConfiguration {

    #Importing required DSC resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    #Getting the configuration parameters for deployment
    $datadogAPIKey = Get-AutomationVariable -Name "datadogAPIKey"
    $datadogSite = Get-AutomationVariable -Name "datadogSite"

    #Download location for Datadog Monitoring agent package
    $datadogAgentPackageLocalPath = "C:\Deploy\datadog-agent-7-latest.amd64.msi"

    Node localhost {

        #region Datadog Monitoring agent

        #Download installation file for Datadog Monitoring agent
        xRemoteFile datadogAgentPackage {
            Uri             = "https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi"
            DestinationPath = $datadogAgentPackageLocalPath
        }

        #Installing Datadog Monitoring agent on a host
        xPackage datadogAgent {
            Name      = "Datadog Agent"
            Ensure    = "Present"
            Path      = $datadogAgentPackageLocalPath
            Arguments = "APIKEY=" + $datadogAPIKey + " SITE=" + $datadogSite
            ProductId = "6AFE2B52-EB1F-4D0D-8C22-E1003ADA1196"
            DependsOn = "[xRemoteFile]datadogAgentPackage"
        }

        #Verifying that the agent service is running
        xService datadogAgentService {
            Name        = "datadogagent"
            Ensure      = "Present"
            State       = "Running"
            DependsOn   = "[xPackage]datadogAgent"
        }

        #Logging the installation in the event log (Microsoft-Windows-Desired State Configuration/Analytic event log)
        Log datadogAgentInstalled {
            Message   = "Datadog Monitoring Agent has been successfully installed."
            DependsOn = "[xPackage]datadogAgent"
        }

        #endregion
    }
}