#Requires -Modules WebServicesPowerShellProxyBuilder

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
    
    $CurrentCertificatePolicy = Get-CurrentCertificatePolicy
    $CurrentSecurityProtocol = Get-CurrentSecurityProtocol
    Set-CertificatePolicy -TrustAllCerts
    Set-SecurityProtocol -SecurityProtocol Ssl3

    $Credential = Import-Clixml $env:USERPROFILE\CUCMCredential.txt
     
    #This method should work but intermittently will give The remote server returned an error: (505) Http Version Not Supported,
    #unless you run it through fiddler to try and see what is wrong and then it works fine :(, 
    #$Result = Invoke-WebRequest -ContentType "text/xml;charset=UTF-8" -Headers @{SOAPAction="CUCM:DB ver=9.1 $MethodName";Accept="Accept: text/*"} -Body $AXL -Uri https://ter-cucm-pub1:8443/axl/ -Method Post -Credential $Credential -SessionVariable AXLWebSession
    #$XmlContent = [xml]$Result.Content
    
    #For me it looks like CUCM requiers at least Tls 1.1 and sends a Expect100Continue
    #After this changes the code works fine. 
    $AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    [System.Net.ServicePointManager]::Expect100Continue = $false
    
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

    Set-CertificatePolicy -CertificatePolicy $CurrentCertificatePolicy
    Set-SecurityProtocol -SecurityProtocol $CurrentSecurityProtocol
}

function New-CUCMCredential {
    param(
        $CUCMCredential = (Get-Credential)
    )
    
    $CUCMCredential | Export-Clixml $env:USERPROFILE\CUCMCredential.txt
}

function Add-CUCMPhone {
    param (
        [Parameter(Mandatory)][String]$UserID,
        [Parameter(Mandatory)][String]$DeviceName,
        [Parameter(Mandatory)][String]$Description,
        [Parameter(Mandatory)][String]$Product,
        [Parameter(Mandatory)][String]$Class,
        [Parameter(Mandatory)][String]$Protocol,
        [Parameter(Mandatory)][String]$ProtocolSide,
        [Parameter(Mandatory)][String]$CallingSearchSpaceName,
        [Parameter(Mandatory)][String]$DevicePoolName,
        [Parameter(Mandatory)][String]$SecurityProfileName,
        [Parameter(Mandatory)][String]$SipProfileName,
        [Parameter(Mandatory)][String]$MediaResourceListName,
        [Parameter(Mandatory)][String]$Locationname,
        [Parameter(Mandatory)][String]$Dirnuuid,
        [Parameter(Mandatory)][String]$PhoneTemplateName,
        [String]$Label,
        [String]$AsciiLabel,
        [String]$Display,
        [String]$DisplayAscii,
        [String]$E164Mask
        
   )
    

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:addPhone sequence="?">
         <phone ctiid="?">
            <name>$DeviceName</name>
            <description>$Description</description>
            <product>$Product</product>
            <class>$Class</class>
            <protocol>$Protocol</protocol>
            <protocolSide>$ProtocolSide</protocolSide>
            <callingSearchSpaceName uuid="?">$CallingSearchSpaceName</callingSearchSpaceName>
            <devicePoolName uuid="?">$DevicePoolName</devicePoolName>
            <securityProfileName>$SecurityProfileName</securityProfileName>
            <sipProfileName>$SipProfileName</sipProfileName>
            <mediaResourceListName>$MediaResourceListName</mediaResourceListName>
            <locationName>$LocationName</locationName>
            <ownerUserName>$UserID</ownerUserName>
               <lines>
               <line>
                  <index>1</index>
                  <dirn uuid="$Dirnuuid"> </dirn> 
                  <label>$Label</label>
                  <asciiLabel>$AsciiLabel</asciiLabel>
                  <display>$Display</display>
                  <displayAscii>$DisplayAscii</displayAscii>
                  <e164Mask>$E164Mask</e164Mask>
                  <associatedEndusers>
                            <enduser>
                                <userId>$UserID</userId>
                            </enduser>
                        </associatedEndusers>
               </line>
            </lines>
            <phoneTemplateName uuid="?">$PhoneTemplateName</phoneTemplateName>
         </phone>
      </ns:addPhone>
   </soapenv:Body>
</soapenv:Envelope>

"@
    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName addPhone
    
}


function Set-CUCMUser  {

     param (
        [Parameter(Mandatory)][String]$UserID,
        [Parameter(Mandatory)][String]$Pattern,
        $ImAndPresenceEnable,
        $ServiceProfile,
        $RoutePartitionName,
        $UserGroupName,
        $UserRolesName,
        $DeviceName
          
    )

   

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:updateUser sequence="?">
         <userid>$UserID</userid>
         <imAndPresenceEnable>$ImAndPresenceEnable</imAndPresenceEnable>
         <serviceProfile>$ServiceProfile</serviceProfile>
         <associatedDevices>
                <device>$DeviceName</device>
         </associatedDevices>
         <primaryExtension>
                    <pattern>$Pattern</pattern>
                    <routePartitionName>$RoutePartitionName</routePartitionName>
         </primaryExtension>
         <associatedGroups>
           <userGroup>
           <name>$UserGroupName</name>
           </userGroup>
          </associatedGroups>
          <userRoles>
          <name>$UserRolesName</name>
          </userRoles>
         </ns:updateUser>
   </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateUser

}

function Set-CUCMIPCCExtension  {

     param (
        [Parameter(Mandatory)][String]$Pattern,
        [Parameter(Mandatory)][String]$UserID,
        [Parameter(Mandatory)][String]$RoutePartition,
        [Parameter(Mandatory)][String]$CSS
    )


$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:executeSQLUpdate sequence="?">
        <sql>insert into endusernumplanmap (fkenduser,fknumplan,tkdnusage) values((select pkid from enduser where userid='$UserID'),
        (select numplan.pkid from numplan join routepartition on(routepartition.pkid = numplan.fkroutepartition) where numplan.dnorpattern = '$Pattern' and routepartition.name = '$RoutePartition'),'2')
        </sql>
      </ns:executeSQLUpdate>
   </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName executeSQLUpdate

}

function Get-CUCMAppuser  {

     param (
         [Parameter(Mandatory)][String]$UserID
       
     )

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:getAppUser>
        <userid>$UserID</userid>
        </ns:getAppUser>
    </soapenv:Body>
</soapenv:Envelope>

"@

    $XmlContect = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName getAppuser
    $XmlContect.Envelope.Body.getAppUserResponse.return.appUser 
}

function Set-CUCMAppuser  {

     param (
         [Parameter(Mandatory)][String]$UserID,
         $DeviceNames       
     )      



$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:updateAppUser>
        <userid>$UserID</userid>
        <associatedDevices>
            $(
                foreach ($DeviceName in $DeviceNames) {
                  New-XMLElement -Name device -InnerText $DeviceName | Select -ExpandProperty OuterXML
                }
            )
        </associatedDevices>
        </ns:updateAppUser>
    </soapenv:Body>
</soapenv:Envelope>

"@

    $XmlContect = Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName updateAppuser
}

function Sync-CUCMtoLDAP {
    param (
         [Parameter(Mandatory)][String]$LDAPDirectory

    )

$AXL = @"

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/9.1">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:doLdapSync>
        <name>$LDAPDirectory</name>
        <sync>true</sync>
        </ns:doLdapSync>
    </soapenv:Body>
</soapenv:Envelope>

"@

    Invoke-CUCMSOAPAPIFunction -AXL $AXL -MethodName doLdapSync

}
