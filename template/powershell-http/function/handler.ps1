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
