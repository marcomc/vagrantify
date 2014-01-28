#!/bin/bash
##### Create a Certificate Authority and a Certificate for Apache #####
#  create a directory for the keys of the CA
mkdir -p $CA_ROOT
chmod 700 $CA_ROOT

# Next, generate a private key and a certificate request, and then self-sign the certificate for the CA.
openssl genrsa -out $CA_ROOT/CA.key 1024
openssl req -new -key $CA_ROOT/CA.key -out $CA_ROOT/CA.csr
openssl x509 -req -days 365 -in $CA_ROOT/CA.csr -signkey $CA_ROOT/CA.key -out $CA_ROOT/ca.crt

##### #####
