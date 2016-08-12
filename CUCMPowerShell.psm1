function Get-CUCMDeviceName {
    param(
        [Parameter(Mandatory)][String]$UserIDAssociatedWithDevice
    )

    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:executeSQLQuery sequence="?">
        <sql>select device.name, enduser.userid from device, enduser, enduserdevicemap
            where device.pkid=enduserdevicemap.fkdevice and  
            enduser.pkid=enduserdevicemap.fkenduser and enduser.userid = '$UserIDAssociatedWithDevice'
        </sql>
      </ns:executeSQLQuery>
   </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName executeSQLQuery

    $XmlContent.Envelope.Body.executeSQLQueryResponse.return.row
}

function Get-CUCMPhone {
    param(
        [Parameter(Mandatory)][String]$Name
    )
    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:getPhone sequence="?">
            <name>$DeviceName</name>
        </ns:getPhone>
    </soapenv:Body>
</soapenv:Envelope>
"@
     $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName getPhone
     
     $XmlContent.Envelope.Body.getPhoneResponse.return.phone
}

function Remove-CUCMPhone {
    param(
        [Parameter(Mandatory)][String]$Name
    )

    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:removePhone>
        <name>$Name</name>
        </ns:removePhone>
    </soapenv:Body>
</soapenv:Envelope>
"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName removePhone
}

function Set-CUCMLine {
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$Pattern,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$RoutePartitionName,
        [String]$Description,
        [String]$AlertingName,
        [String]$AsciiAlertingName
    )

    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:updateLine sequence="?">
         <pattern>$Pattern</pattern>
         <routePartitionName>$RoutePartitionName</routePartitionName>
         <description>$Description</description>
         <alertingName>$AlertingName</alertingName>
         <asciiAlertingName>$AsciiAlertingName</asciiAlertingName>
    </ns:updateLine>
   </soapenv:Body>
</soapenv:Envelope>
"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateLine
}


function Invoke-CUCMSOAPAPIFunction {
    param(
        [parameter(Mandatory)]$AXL,
        [parameter(Mandatory)]$MethodName
    )
    
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $Credential = Import-Clixml $env:USERPROFILE\CUCMCredential.txt
     
    #This method should work but intermittently will give The remote server returned an error: (505) Http Version Not Supported,
    #unless you run it through fiddler to try and see what is wrong and then it works fine :(, 
    #$Result = Invoke-WebRequest -ContentType "text/xml;charset=UTF-8" -Headers @{SOAPAction="CUCM:DB ver=9.1 $MethodName";Accept="Accept: text/*"} -Body $AXL -Uri https://ter-cucm-pub1:8443/axl/ -Method Post -Credential $Credential -SessionVariable AXLWebSession
    #$XmlContent = [xml]$Result.Content

    $WebRequest = [System.Net.WebRequest]::Create("https://ter-cucm-pub1:8443/axl/") 
    $WebRequest.Method = "POST"
    $WebRequest.ProtocolVersion = [System.Net.HttpVersion]::Version10
    $WebRequest.Headers.Add("SOAPAction","CUCM:DB ver=9.1 $MethodName")
    $WebRequest.ContentType = "text/xml"
    $WebRequest.Credentials = $Credential.GetNetworkCredential()
    $Stream = $WebRequest.GetRequestStream();
    $Body = [byte[]][char[]]$AXL
    $Stream.Write($Body, 0, $Body.Length);
    $WebResponse = $WebRequest.GetResponse()
    $WebResponseStream = $WebResponse.GetResponseStream()
    $StreamReader = new-object System.IO.StreamReader $WebResponseStream
    $ResponeData = $StreamReader.ReadToEnd()
    $XmlContent = [xml]$ResponeData
    $XmlContent
}

function New-CUCMCredential {
    $CUCMCredential = Get-Credential
    $CUCMCredential | Export-Clixml $env:USERPROFILE\CUCMCredential.txt
}