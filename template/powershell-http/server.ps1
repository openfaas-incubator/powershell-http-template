Add-Type -AssemblyName System.Web

Class FunctionContext{
    [string] $Method;
    [string] $Request;
    [string] $Body;
    [System.Net.WebHeaderCollection] $Headers;
    [System.Collections.Specialized.NameValueCollection] $Query;
    [string] $Path;
}

Class FunctionResponse{
    [string] $Body;
    [System.Net.WebHeaderCollection] $Headers;
    [int] $Status;
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:8081/")
$listener.Start()

. "./function/handler.ps1"

do {
    $context = $listener.GetContext()
    $response = $context.Response
    $Content = ""

    $reqStream = $context.Request.InputStream
    $reqEncoding = $context.Request.ContentEncoding

    $reader = [System.IO.StreamReader]::new($reqStream, $reqEncoding)

    $fnContext = [FunctionContext]::new()
    $fnContext.Body = $reader.ReadToEnd()
    $fnContext.Headers = $context.Request.Headers
    $fnContext.Method = $context.Request.HttpMethod
    $fnContext.Query = $context.Request.QueryString
    $fnContext.Path = $context.Request.Url.LocalPath
    $fnContext.Request = $context.Request

    $fnResponse = [FunctionResponse]::new()
    $fnResponse.Headers = [System.Net.WebHeaderCollection]::new()
    try {
        Handler -fnContext $fnContext -fnResponse $fnResponse

        $Content = [System.Text.Encoding]::UTF8.GetBytes($fnResponse.Body)
        $response.StatusCode = $(If ($fnResponse.Status) {$fnResponse.Status} Else {200}) #default to 200 response if not set
    }
    catch {
        $responseBody = $(If ($_.Exception.Message) {$_.Exception.Message} Else {$fnResponse.Body})
        $Content = [System.Text.Encoding]::UTF8.GetBytes($responseBody)
        $response.StatusCode = $(If ($fnResponse.Status) {$fnResponse.Status} Else {500}) #default to 500 response for exceptions
    }

    $response.Headers = $fnResponse.Headers
    $response.ContentLength64 = $Content.Length
    $response.OutputStream.Write($Content, 0, $Content.Length)
    $response.Close()
} while ($listener.IsListening)