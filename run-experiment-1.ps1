New-Item -ItemType Directory -Force -Path "results/windows"
docker build -t miso:latest .; docker run --rm -it -v "$($PWD)/results/windows:/results" miso:latest