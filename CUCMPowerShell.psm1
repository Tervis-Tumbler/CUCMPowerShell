function Invoke-CUCMSQLQuery {
    param(
        [Parameter(Mandatory)][String]$SQL
    )

    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:executeSQLQuery sequence="?">
        <sql>$SQL</sql>
      </ns:executeSQLQuery>
   </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName executeSQLQuery
    $XmlContent.Envelope.Body.executeSQLQueryResponse.return.row
}

function Get-CUCMUser {
    param(
        [Parameter(Mandatory)][String]$UserID
    )

    $AXL = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:getUser>
         <userid>$UserID</userid>
      </ns:getUser>
   </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName getUser
    $XmlContent.Envelope.Body.getUserResponse.return.user
}

function Find-CUCMUser {
    param(
        [Parameter(Mandatory)][String]$firstName
    )    
        $AXL=@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:listUser>
        <searchCriteria>
              <firstName>$firstName</firstName>
        </searchCriteria>
        <returnedTags>
        <userid/>
        <telephoneNumber/>
        </returnedTags>        
    </ns:listUser>
    </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName listUser
    $XmlContent.Envelope.Body.listUserResponse.return.user
}

function Find-CUCMPhone {
    param(
        [Parameter(Mandatory)][String]$Name
    )    
    $AXL=@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:listPhone>
        <searchCriteria>
              <name>$Name</name>
        </searchCriteria>
        <returnedTags>
        <name/>
        <ownerUserName/>
        </returnedTags>        
    </ns:listPhone>
    </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName listPhone
    
    $XmlContent.Envelope.Body.listPhoneResponse.return.phone    
}

function Find-CUCMLine {
    param(
        [Parameter(Mandatory)][String]$Pattern,
        [String]$Description
    )    
        $AXL=@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:listLine>
        <searchCriteria>
              <pattern>$Pattern</pattern>
              <description>$Description</description> 
        </searchCriteria>
        <returnedTags>
        <pattern/>
        <description/>
        </returnedTags>        
    </ns:listLine>
    </soapenv:Body>
</soapenv:Envelope>
"@
    $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName listLine
    $XmlContent.Envelope.Body.listLineResponse.return.line.pattern
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
            <name>$Name</name>
        </ns:getPhone>
    </soapenv:Body>
</soapenv:Envelope>
"@
     $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName getPhone
     
     $XmlContent.Envelope.Body.getPhoneResponse.return.phone
}

function Remove-CUCMPhone {
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$Name
    )
    process {
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
}

function Set-CUCMLine {
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$Pattern,
        [Parameter(Mandatory)][String]$RoutePartitionName,
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
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Ssl3

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
    $Stream = $WebRequest.GetRequestStream()
    $Body = [byte[]][char[]]$AXL
    $Stream.Write($Body, 0, $Body.Length)
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

function Add-CUCMPhone {
    param (
        [Parameter(Mandatory)][String]$UserID
        #[Parameter(Mandatory)][String]$DispalyName
    )
    $uuid = Add-CUCMLine -UserId $UserID

    $AdUser = Get-ADUser $UserID
    $DisplayName = $AdUser.name

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:addPhone sequence="?">
         <phone ctiid="?">
            <name>CSF$UserID</name>
            <description>$DisplayName</description>
            <product>Cisco Unified Client Services Framework</product>
            <class>Phone</class>
            <protocol>SIP</protocol>
            <protocolSide>User</protocolSide>
            <callingSearchSpaceName uuid="?">Gateway_outbound_CSS</callingSearchSpaceName>
            <devicePoolName uuid="?">TPA_DP</devicePoolName>
            <securityProfileName>Cisco Unified Client Services Framework - Standard SIP Non-Secure</securityProfileName>
            <sipProfileName>Standard SIP Profile</sipProfileName>
            <mediaResourceListName>TPA_MRL</mediaResourceListName>
            <locationName>Hub_None</locationName>
            <ownerUserName>$UserID</ownerUserName>
               <lines>
               <line>
                  <index>1</index>
                  <dirn uuid="{ED4445B1-6750-B685-67DB-21E7D1B9797B}"> </dirn> 
                  <label>$DisplayName</label>
                  <asciiLabel>$DisplayName</asciiLabel>
                  <display>$DisplayName</display>
                  <displayAscii>$DisplayName</displayAscii>
                  <e164Mask>941441XXXX</e164Mask>
                  <associatedEndusers>
                            <enduser>
                                <userId>$UserID</userId>
                            </enduser>
                        </associatedEndusers>
               </line>
            </lines>
            <phoneTemplateName uuid="?">Standard Client Services Framework</phoneTemplateName>
         </phone>
      </ns:addPhone>
   </soapenv:Body>
</soapenv:Envelope>

"@
    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName addPhone
    
    }

function Add-CUCMLine  {

     param (
        #[Parameter(Mandatory)][String]$Pattern,
        [Parameter(Mandatory)][String]$UserID
        #[Parameter(Mandatory)][String]$RoutePartition,
        #[Parameter(Mandatory)][String]$CSS
    )

    $Pattern = Find-CUCMLine -Pattern 7% -Description "" | select -First 1
    Set-ADUser $UserID -OfficePhone $Pattern
    Sync-CUCMtoLDAP 
    $ADUser = Get-ADUser $UserID
    $DisplayName = $ADUser.name
    


$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:updateLine sequence="?">
         <pattern>$Pattern</pattern>
         <routePartitionName>UCCX_PT</routePartitionName>
         <description>$DisplayName</description>
         <alertingName>$DisplayName</alertingName>
         <asciiAlertingName>$DisplayName</asciiAlertingName>
         <voiceMailProfileName>Voicemail</voiceMailProfileName>
         <shareLineAppearanceCssName>UCCX_CSS</shareLineAppearanceCssName>
         <userHoldMohAudioSourceId></userHoldMohAudioSourceId>
         <networkHoldMohAudioSourceId></networkHoldMohAudioSourceId>
         <callForwardAll>
                   <forwardToVoiceMail>false</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
                   <secondaryCallingSearchSpaceName uuid="?">UCCX_CSS</secondaryCallingSearchSpaceName>
         </callForwardAll>
         <callForwardBusy>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardBusy>
         <callForwardBusyInt>
                   <forwardToVoiceMail>true</forwardToVoiceMail>,,
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardBusyInt>
         <callForwardNoAnswer>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNoAnswer>
         <callForwardNoAnswerInt>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNoAnswerInt>
         <callForwardNoCoverage>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNoCoverage>
         <callForwardNoCoverageInt>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNoCoverageInt>
         <callForwardOnFailure>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardOnFailure>
         <callForwardOnFailure>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardOnFailure>
         <callForwardNotRegistered>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNotRegistered>
         <callForwardNotRegisteredInt>
                   <forwardToVoiceMail>true</forwardToVoiceMail>
                   <callingSearchSpaceName uuid="?">UCCX_CSS</callingSearchSpaceName>
         </callForwardNotRegisteredInt>
         <Lines>
         <lineIdentifier>
         <index>1</index>
         <display>$DisplayName</display>
         </lineIdentifier>
         </Lines>
    </ns:updateLine>
    </soapenv:Body>
</soapenv:Envelope>

"@
   
     $XmlContent = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateLine
     $XmlContent.Envelope.Body.updateLineResponse.return
    
    
    }

function Set-CUCMUser  {

     param (
        #[Parameter(Mandatory)][String]$Pattern,
        [Parameter(Mandatory)][String]$UserID
        #[Parameter(Mandatory)][String]$RoutePartition,
        #[Parameter(Mandatory)][String]$CSS
    )

    $ADUser = Get-ADUser $UserID -Properties TelephoneNumber
    $Pattern = $ADUser.TelephoneNumber

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:updateUser sequence="?">
         <userid>$UserID</userid>
         <imAndPresenceEnable>true</imAndPresenceEnable>
         <serviceProfile>UCServiceProfile_Migration_1</serviceProfile>
         <associatedDevices>
                <device>CSF$UserID</device>
         </associatedDevices>
         <primaryExtension>
                    <pattern>$Pattern</pattern>
                    <routePartitionName>UCCX_PT</routePartitionName>
         </primaryExtension>
         <associatedGroups>
           <userGroup>
           <name>CCM END USER SETTINGS</name>
           </userGroup>
          </associatedGroups>
          <userRoles>
          <name>CCM END USER SETTINGS</name>
          </userRoles>
         </ns:updateUser>
   </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateUser

}

function Set-CUCMIPCCExtension  {

     param (
        #[Parameter(Mandatory)][String]$Pattern,
        [Parameter(Mandatory)][String]$UserID
        #[Parameter(Mandatory)][String]$RoutePartition,
        #[Parameter(Mandatory)][String]$CSS
    )

    $ADUser = Get-ADUser $UserID -Properties TelephoneNumber
    $Pattern = $ADUser.TelephoneNumber

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:executeSQLUpdate sequence="?">
        <sql>insert into endusernumplanmap (fkenduser,fknumplan,tkdnusage) values((select pkid from enduser where userid='$UserID'),
        (select numplan.pkid from numplan join routepartition on(routepartition.pkid = numplan.fkroutepartition) where numplan.dnorpattern = '$Pattern' and routepartition.name = 'UCCX_PT'),'2')
        </sql>
      </ns:executeSQLUpdate>
   </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName executeSQLUpdate

}

function Get-CUCMAppuser  {

     param (
         #[Parameter(Mandatory)][String]$AppUserID
       
     )

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:getAppUser>
        <userid>axlcups</userid>
        </ns:getAppUser>
    </soapenv:Body>
</soapenv:Envelope>

"@

    $XmlContect = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName getAppuser
    $XmlContect.Envelope.Body.getAppUserResponse.return.appUser.associatedDevices.device  
}

function Set-CUCMAppuser  {

     param (
         [Parameter(Mandatory)][String]$UserID
       
     )

     $devices = Get-CUCMAppuser 
     ForEach ($device in $devices) {
      

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:updateAppUser>
        <userid>axlcups</userid>
        <associatedDevices>
          <device>$device</device>
          <device>CSF$UserID<device>
        </associatedDevices>
        </ns:updateAppUser>
    </soapenv:Body>
</soapenv:Envelope>

"@
}

    $XmlContect = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateAppuser

}

function Sync-CUCMtoLDAP {

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:doLdapSync>
        <name>TERV_AD</name>
        <sync>true</sync>
        </ns:doLdapSync>
    </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName doLdapSync

}





