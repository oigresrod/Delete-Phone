if($cred -eq $null){$cred = Get-Credential} #Highly advise you create an account in CUCM with AXL previliges

function delete {
    param ([Parameter(Mandatory)][String]$macAddress)
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$TRUE}


        $axl =@"
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/12.5">
        <soapenv:Header/>
        <soapenv:Body>
           <ns:removePhone sequence="?">
              <!--You have a CHOICE of the next 2 items at this level-->
              <name>$macAddress</name>
              <!--<uuid>?</uuid>-->
           </ns:removePhone>
        </soapenv:Body>
     </soapenv:Envelope>
"@

try{
   $Result = Invoke-WebRequest -ContentType "text/xml;charset=UTF-8" -Headers @{SOAPAction="CUCM:DB ver=12.5"; Accept="Accept: text/*"} -Body $axl -Uri https://CUCM_IP_ADDRESS:8443/axl/ -Method Post -Credential $cred
$content = [xml]$Result.Content
$person = $content.Envelope.Body.getUserResponse.return.user

Write-Host "Phone deleted: " $macAddress

} catch {
   Write-Host "Phone not deleted: " $macAddress 
}


}

#You'll need to create a CSV with macAddress property to target (you can do this with a text file too, just make sure you change the syntax)

$file = Import-Csv -Path "location of your file" | select -ExpandProperty macAddress

foreach($phone in $file){

   $MAC = "SEP" + $phone #We're appending SEP + macAddress because that's the unique identifier in CUCM

   delete -macAddress $MAC

   
}
