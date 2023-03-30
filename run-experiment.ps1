param(
    [Parameter(Mandatory=$true)]
    [string]$ResultsPath
)

if (-not $ResultsPath) {
    Write-Host "Results path is not provided"
    return
}

New-Item -ItemType Directory -Force -Path $ResultsPath
docker build -t miso:latest .; docker run --rm -it -v "$($PWD)/${ResultsPath}:/results" miso:latest