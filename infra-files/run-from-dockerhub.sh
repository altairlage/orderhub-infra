#!/bin/bash

echo "Baixando os demais repositorios..."
git clone https://github.com/altairlage/orderhub-core.git ../orderhub-core

git clone https://github.com/altairlage/orderhub-cliente-service.git ../orderhub-cliente-service

git clone https://github.com/altairlage/orderhub-produto-service.git ../orderhub-produto-service

git clone https://github.com/altairlage/orderhub-estoque-service.git ../orderhub-estoque-service

git clone https://github.com/altairlage/orderhub-pedido-receiver.git ../orderhub-pedido-receiver

git clone https://github.com/altairlage/orderhub-pagamento-service.git ../orderhub-pagamento-service

echo "*** Baixando as imagens..."
docker-compose pull

echo "*** Iniciando os serviços..."
docker-compose up -d --no-build
