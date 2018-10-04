# clair-local

https://github.com/arminc/clair-scanner

Local Docker containers vulnerability scan.

### help
```shell
make help
```

### example

```shell
# install clair scanner
make clair-scanner/install

# run clair server & postgre
make clair/run

# after 10~20 minutes. vulnerability updates
# if you check amount of CVE data on postgres
make check

# check image
make run IMAGE=golang:1.10
make tail

# byebye clair-local
make clean
```