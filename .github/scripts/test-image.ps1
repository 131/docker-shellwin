$ErrorActionPreference = 'Stop'

function Invoke-Checked {
  param([string]$Command, [string[]]$Arguments)
  $output = & $Command @Arguments 2>&1
  $exitCode = $LASTEXITCODE
  $output | Write-Output
  if ($exitCode -ne 0) { throw "$Command failed ($exitCode): $output" }
}

$image = docker inspect shellwin:test | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Image inspection failed' }
if ($image.Os -ne 'windows' -or $image.Architecture -ne 'amd64') {
  throw 'Expected a windows/amd64 image'
}
if ($image.OsVersion -notlike '10.0.20348.*') { throw 'Expected LTSC 2022' }
if ($image.Config.Labels.'org.opencontainers.image.version' -ne '2.0.0') {
  throw 'Expected version 2.0.0'
}

$keys = Join-Path $env:RUNNER_TEMP 'shellwin-test-keys'
New-Item -ItemType Directory -Force $keys | Out-Null
Invoke-Checked -Command ssh-keygen -Arguments @('-t', 'ed25519', '-N', '', '-f', "$keys/host_key")
Invoke-Checked -Command ssh-keygen -Arguments @('-t', 'ed25519', '-N', '', '-f', "$keys/client_key")
Copy-Item "$keys/client_key.pub" "$keys/authorized_keys"

$container = 'shellwin-smoke-test'
try {
  Invoke-Checked -Command docker -Arguments @('create', '--name', $container,
    '-e', 'SHELL_AUTHORIZED_USERS=C:\testkeys\authorized_keys',
    '-e', 'SHELL_SERVER_KEY_PATH=C:\testkeys\host_key', 'shellwin:test')
  Invoke-Checked -Command docker -Arguments @('cp', $keys, "${container}:C:\testkeys")
  Invoke-Checked -Command docker -Arguments @('start', $container)
  $address = docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
  if ($LASTEXITCODE -ne 0 -or -not $address) { throw 'Cannot find container address' }
  $connected = $false
  for ($attempt = 0; $attempt -lt 30; $attempt++) {
    & ssh -i "$keys/client_key" -p 22 -o BatchMode=yes -o StrictHostKeyChecking=no `
      -o "UserKnownHostsFile=$keys/known_hosts" -o ConnectTimeout=5 "root@$address" 'docker --version'
    if ($LASTEXITCODE -eq 0) { $connected = $true; break }
    Start-Sleep -Seconds 2
  }
  if (-not $connected) { throw 'SSH login or Docker CLI smoke test failed' }
} finally {
  docker logs $container
  docker rm --force $container
}
