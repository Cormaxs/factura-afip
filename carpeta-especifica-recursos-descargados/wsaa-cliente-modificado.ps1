[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)]
    [string]$Certificado="certificado.crt",
    
    [Parameter(Mandatory=$False)]
    [string]$ClavePrivada="MiClavePrivada.key",
    
    [Parameter(Mandatory=$False)]
    [string]$ServicioId="wsfe",
    
    [Parameter(Mandatory=$False)]
    [string]$OutXml="LoginTicketRequest.xml",    
    
    [Parameter(Mandatory=$False)]
    [string]$OutCms="LoginTicketRequest.xml.cms",    

    [Parameter(Mandatory=$False)]
    [string]$WsaaWsdl = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms?WSDL"    
)

$ErrorActionPreference = "Stop"

$dtNow = Get-Date
$xmlTA = New-Object System.XML.XMLDocument
$xmlTA.LoadXml('<loginTicketRequest><header><uniqueId></uniqueId><generationTime></generationTime><expirationTime></expirationTime></header><service></service></loginTicketRequest>')
$xmlUniqueId = $xmlTA.SelectSingleNode("//uniqueId")
$xmlGenTime = $xmlTA.SelectSingleNode("//generationTime")
$xmlExpTime = $xmlTA.SelectSingleNode("//expirationTime")
$xmlService = $xmlTA.SelectSingleNode("//service")
$xmlGenTime.InnerText = $dtNow.AddMinutes(-10).ToString("s")
$xmlExpTime.InnerText = $dtNow.AddMinutes(+10).ToString("s")
$xmlUniqueId.InnerText = $dtNow.ToString("yyMMddHHMM")
$xmlService.InnerText = $ServicioId
$seqNr = Get-Date -UFormat "%Y%m%d%H%S"
$outputXmlPath = Join-Path (Get-Location) "$seqNr-$OutXml"
$xmlTA.InnerXml | Out-File $outputXmlPath -Encoding ASCII

try {
    $outputCmsDerPath = Join-Path (Get-Location) "$seqNr-$OutCms-DER"
    openssl cms -sign -in $outputXmlPath -signer $Certificado -inkey $ClavePrivada -nodetach -outform der -out $outputCmsDerPath -verify
}
catch {
    Write-Host "Error en la firma CMS: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

try {
    $outputCmsDerB64Path = Join-Path (Get-Location) "$seqNr-$OutCms-DER-b64"
    openssl base64 -in $outputCmsDerPath -e -out $outputCmsDerB64Path
}
catch {
    Write-Host "Error al codificar en Base64: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

try
{
    $cms = Get-Content $outputCmsDerB64Path -Raw
    $wsaa = New-WebServiceProxy -Uri $WsaaWsdl -ErrorAction Stop
    $wsaaResponse = $wsaa.loginCms($cms)
    
    $outputResponsePath = Join-Path (Get-Location) "$seqNr-loginTicketResponse.xml"
    $wsaaResponse | Out-File $outputResponsePath -Encoding UTF8
    
    $wsaaResponse
}
catch
{
    $errMsg = $_.Exception.Message
    $outputErrorPath = Join-Path (Get-Location) "$seqNr-loginTicketResponse-ERROR.xml"
    $errMsg | Out-File $outputErrorPath -Encoding UTF8
    Write-Host "Error al invocar al WSAA: $errMsg" -ForegroundColor Red
}