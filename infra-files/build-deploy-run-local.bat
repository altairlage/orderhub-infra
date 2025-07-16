echo "Baixando os demais repositorios..."

git clone https://github.com/altairlage/orderhub-core.git ../orderhub-core

git clone https://github.com/altairlage/orderhub-cliente-service.git ../orderhub-cliente-service

git clone https://github.com/altairlage/orderhub-produto-service.git ../orderhub-produto-service

git clone https://github.com/altairlage/orderhub-estoque-service.git ../orderhub-estoque-service

git clone https://github.com/altairlage/orderhub-pedido-receiver.git ../orderhub-pedido-receiver

git clone https://github.com/altairlage/orderhub-pagamento-service.git ../orderhub-pagamento-service

echo "Compilando os serviços com docker e rodando com docker-compose..."

echo "*** Autenticando no Docker Hub..."
docker login -u "teamorderhub" -p "orderhub@1234"

echo "*** Construindo as imagens..."
docker-compose build

echo "*** Enviando as imagens para o Docker Hub..."
docker-compose push

echo "*** Iniciando os serviços..."
docker-compose up -d