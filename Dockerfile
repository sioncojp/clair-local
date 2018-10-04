FROM golang:1.9
RUN go get -u github.com/golang/dep/cmd/dep
RUN git clone https://github.com/arminc/clair-scanner.git /go/src/github.com/arminc/clair-scanner
RUN cd /go/src/github.com/arminc/clair-scanner && make ensure
WORKDIR /go/src/github.com/arminc/clair-scanner
ENTRYPOINT [""]