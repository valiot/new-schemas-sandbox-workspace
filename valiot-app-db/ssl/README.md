# Certificates generation

Application repo: [https://github.com/square/certstrap](https://github.com/square/certstrap)

```sh
cd workspace/postgres/ssl

./certstrap-windows-amd64 init --common-name valiot
./certstrap-windows-amd64 request-cert --common-name postgresdb --domain localhost
./certstrap-windows-amd64 sign postgresdb --CA valiot

cd ../../..
```
