# Ambiente PHP 5 com MSSQL

## Build da imagem

 - docker build -t gustavobcx/php-mssql:5.6.38-apache .

## Rodar o projeto

 - docker-compose up -d

## Observações

    Necessário configurar o compose file para os diretórios corretos onde se encontra o repositório do projeto e ajustar o arquivo de vhosts

## Pendente

    Terminar de configurar o SSL