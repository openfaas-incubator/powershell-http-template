Add-Type -AssemblyName System.Web

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:8081/")
$listener.Start()

do {
    $context = $listener.GetContext()
    $response = $context.Response
    $Content = ""

    $reqStream = $context.Request.InputStream
    $reqEncoding = $context.Request.ContentEncoding

    $reader = [System.IO.StreamReader]::new($reqStream, $reqEncoding)

    $reqBody = $reader.ReadToEnd()

    try {
        $funcResult = . .\function\handler.ps1 $reqBody

        $Content = [System.Text.Encoding]::UTF8.GetBytes($funcResult)
        $response.StatusCode = 200
    }
    catch {
        $Content = [System.Text.Encoding]::UTF8.GetBytes("$_.Exception.Message")
        $response.StatusCode = 500
    }

    $response.ContentLength64 = $Content.Length
    $response.OutputStream.Write($Content, 0, $Content.Length)
    $response.Close()
} while ($listener.IsListening)