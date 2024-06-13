az network public-ip create \
  --name AiStudioPublicIP \
  --resource-group aistudio-vnet \
  --allocation-method Dynamic \
  --sku basic

az network vnet-gateway create \
  --name AiStudioVNetGateway \
  --resource-group aistudio-vnet \
  --vnet vnetaistudio \
  --public-ip-address AiStudioPublicIP \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku Basic \
  --no-wait

# create certificats
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=RootCertificate" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature -Subject "CN=ClientCertificate" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
