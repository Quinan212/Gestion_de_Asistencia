Add-Type -AssemblyName System.IO.Compression.FileSystem
$doc='C:\Users\alanm\Downloads\guia_ingresantes_diseno.docx'
$zip=[System.IO.Compression.ZipFile]::OpenRead($doc)
$entry=$zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$sr=New-Object IO.StreamReader($entry.Open())
$xmlText=$sr.ReadToEnd(); $sr.Close(); $zip.Dispose()
[xml]$xml=$xmlText
$ns=New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
$nodes=$xml.SelectNodes('//w:t',$ns)
$vals=@()
foreach($n in $nodes){
  $v=($n.'#text' -as [string])
  if($null -eq $v){ continue }
  $v=$v -replace '\s+',' '
  $v=$v.Trim()
  if($v -eq ''){ continue }
  $vals += $v
}
Write-Output "tokens=$($vals.Count)"
for($i=0;$i -lt [Math]::Min(260,$vals.Count);$i++){
  Write-Output ("{0:D3}: {1}" -f ($i+1), $vals[$i])
}
