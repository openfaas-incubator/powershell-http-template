
OpenFaaS PowerShell HTTP function template
=============================================

This template for building Powershell based functions on [OpenFaaS](https://www.openfaas.com), Docker, Knative and Cloud Run.

With this template you can create a new function and deploy it to a platform like [OpenFaaS](https://www.openfaas.com) for:

* scale-to-zero
* horizontal scale-out
* metrics & logs
* automated health-checks
* sane Kubernetes defaults like running as a non-root user

## Status of the template

This template is experimental and I would like your feedback through GitHub issues or [OpenFaaS Slack](https://docs.openfaas.com/community).

## Get started

You can create or scaffold a new function using the [OpenFaaS CLI](https://github.com/openfaas/faas-cli).

```
# USERNAME is your Docker Hub account or private Docker registry
$ export USERNAME=alexellisuk

$ faas template pull https://github.com/openfaas-incubator/powershell-http-template
$ faas new --lang powershell-http <fn-name> --prefix="${USERNAME}"
```

Once you've written your code you can run `faas-cli build` to create a local Docker image, then `faas-cli push` to transfer it to your registry.

You can now deploy it to OpenFaaS, Knative, Google Cloud Run or even use `docker run`.

See also: [Deploy OpenFaaS](https://docs.openfaas.com/deployment/)

## Example usage

### Minimal string based example

```
function Handler {
  Param(
  [Parameter(Mandatory=$true)]
  [FunctionContext]$fnContext,
  [Parameter(Mandatory=$true)]
  [FunctionResponse]$fnResponse
  )

  $output = "Hello! Your input was: " + $fnContext.Body

  $fnResponse.Body = $output
  
}
```

### Minimal JSON based example

```
function Handler {
  Param(
  [Parameter(Mandatory=$true)]
  [FunctionContext]$fnContext,
  [Parameter(Mandatory=$true)]
  [FunctionResponse]$fnResponse
  )

  $json = $fnContext.Body | Out-String | ConvertFrom-Json 

  $key1 = $json.key1
  $key2 = $json.key2

  $output = @{
      "Your JSON input was" = @{
          key1=$key1;
          key2=$key2;
      }
  } | ConvertTo-Json -Compress

  $fnResponse.Body = $output
  
}
```


### Example usage with WinRM based remote PowerShell module, environment variables and secrets.

```
function Handler {
  Param(
  [Parameter(Mandatory=$true)]
  [FunctionContext]$fnContext,
  [Parameter(Mandatory=$true)]
  [FunctionResponse]$fnResponse
  )

  $username = $env:USERNAME
  $password = Get-Content "/var/openfaas/secrets/password" | ConvertTo-SecureString -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

  $sessionoptions = New-PSSessionOption -SkipCACheck -SkipCNCheck
  $output = Invoke-Command -ComputerName <winrm-server> -Authentication Negotiate -SessionOption $sessionoptions -Credential $cred -ScriptBlock {
    Import-module ActiveDirectory
    Get-Domain
  }

  $fnResponse.Body = $output

}   
```
