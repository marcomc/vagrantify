#!/bin/bash
##### Create a Certificate Authority and a Certificate for Apache #####
#  create a directory for the keys of the CA

CA_ROOT=$1 #/etc/pki/CA
CA_NAME=cakey.pem
DOMAIN_NAME=$2
    
CRT_INDEX=$CA_ROOT/index.txt
CRT_SERIAL=$CA_ROOT/serial
CA_KEY=$CA_ROOT/private/cakey.pem
CA_CSR=$CA_ROOT/ca.csr
CA_CRT=$CA_ROOT/cacert.pem
CA_C=GB
CA_ST=London
CA_L=London
CA_O=Inviqa
CA_CN=ca.inviqa

DOMAIN_KEY=$CA_ROOT/private/$DOMAIN_NAME.key
DOMAIN_CSR=$CA_ROOT/$DOMAIN_NAME.csr
DOMAIN_CRT=$CA_ROOT/certs/$DOMAIN_NAME.crt
DOMAIN_C=GB
DOMAIN_ST=London
DOMAIN_L=London
DOMAIN_O=Inviqa
DOMAIN_CN=$DOMAIN_NAME

touch $CRT_INDEX
if [ ! -f $CRT_SERIAL ];then echo "01\n" > $CRT_SERIAL; fi

# if the CA_Root folde do not exists, theit creates with the proper restricted permissions
if [ ! -d $CA_ROOT ];then mkdir -p $CA_ROOT;chmod 700 $CA_ROOT;fi


if [ ! -f $CA_CRT ];
then
    echo "Generating a CA certificate"
    # Generate a private key and a certificate request, and a self-signed certificate for the CA.
    openssl genrsa -out $CA_KEY 1024 2> /dev/null
    chmod 400 $CA_KEY
    openssl req -new -nodes -key $CA_KEY -out $CA_CSR  -subj "/C=$CA_C/ST=$CA_ST/L=$CA_L/O=$CA_O/CN=$CA_CN"
    openssl x509 -req -days 3650 -in $CA_CSR -signkey $CA_KEY -out $CA_CRT 2> /dev/null
    rm $CA_CSR
    echo "CA certificate generated"
else
    echo "Skipping the generation of the CA certificate which is already existing"
fi

if [ ! -f $DOMAIN_CRT ];
then
    echo "Generating a Selfsigne certificate for $DOMAIN_NAME"    
    # Generate a private key and a certificate request, and a self-signed certificate for the CA.
    openssl genrsa -out $DOMAIN_KEY 1024 2> /dev/null
    chmod 400 $DOMAIN_KEY
    openssl req -new -key $DOMAIN_KEY -out $DOMAIN_CSR  -subj "/C=$DOMAIN_C/ST=$DOMAIN_ST/L=$DOMAIN_L/O=$DOMAIN_O/CN=$DOMAIN_CN"
    openssl ca -batch -policy policy_anything -out $DOMAIN_CRT -infiles $DOMAIN_CSR 2> /dev/null
    rm $DOMAIN_CSR
    echo "Selfsigne certificate generated"    
else
    echo "Skipping the generation of the Domain $DOMAIN_NAME certificate which is already existing"
fi

