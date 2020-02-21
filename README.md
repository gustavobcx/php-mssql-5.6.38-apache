# Ambiente PHP 5 com MSSQL

## Build da imagem

 - docker build -t gustavobcx/php-mssql-httpd:5.6.38 .

## Rodar o projeto

 - docker-compose up -d

## Observações

    Necessário configurar o apontamento do projeto no compose file
    e ajustar o arquivo de vhosts

## Pendente

    Terminar de configurar o SSL
