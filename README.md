# OrderHub - Infraestrutura e Orquestração

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/docker--compose-%232496ED.svg?style=for-the-badge&logo=docker&logoColor=white)
![Spring](https://img.shields.io/badge/spring-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-F2F4F9?style=for-the-badge&logo=spring-boot)
![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Postman](https://img.shields.io/badge/Postman-FF6C37?style=for-the-badge&logo=postman&logoColor=white)

Este repositório contém a infraestrutura como código (IaC) para orquestrar a compilação, o deploy e a execução da solução de microserviços do OrderHub. Ele utiliza Docker e Docker Compose para automatizar todo o ciclo de vida da aplicação.

## Visão Geral

O objetivo deste repositório é centralizar e simplificar o gerenciamento do ambiente de desenvolvimento e produção. Ele é responsável por:
-   Clonar todos os repositórios de microserviços necessários.
-   Construir as imagens Docker para cada serviço, incluindo a compilação da biblioteca orderhub-core.
-   Publicar as imagens versionadas no Docker Hub.
-   Executar a stack completa de serviços de forma local ou a partir de imagens remotas (Dockerhub).

---

## Estrutura de Arquivos

Aqui está uma descrição dos principais arquivos de orquestração neste repositório:

### `docker-compose.yml`
Este é o coração da orquestração. Ele define todos os serviços da aplicação (microsserviços), suas dependências, configurações de rede, portas e como eles devem ser construídos.

-   **`services`**: Cada bloco dentro de `services` (ex: `produto-service`, `cliente-service`) representa um microserviço.
-   **`image`**: Define o nome e a tag da imagem Docker que será gerada ou baixada. Utilizamos a variável `${IMAGE_TAG:-latest}` para permitir a customização da tag.
-   **`build`**: Especifica como construir a imagem do serviço. Usamos um `context` que aponta para a pasta raiz do projeto para que o `Dockerfile` possa acessar e compilar dependências locais, como o `orderhub-core`.
-   **`ports`**: Mapeia as portas do contêiner para a máquina host, permitindo o acesso aos serviços.
-   **`environment`**: Define variáveis de ambiente para os contêineres, como o perfil ativo do Spring (`SPRING_PROFILES_ACTIVE=docker`).

### `build-deploy-run-local.sh` / `build-deploy-run-local.bat`
Estes scripts automatizam o ciclo completo de "subir" o ambiente a partir do código-fonte local. São as ferramentas ideais para desenvolvedores que precisam testar suas alterações. O script `.sh` é para ambientes Linux/macOS e o `.bat` para Windows.
Suas etapas são:
1.  **Clonar Repositórios**: Baixa as versões mais recentes de todos os repositórios de microserviços.
2.  **Autenticar**: Realiza o login no Docker Hub. (*Atenção: as credenciais estão hardcoded, o que não é uma boa prática. Para ambientes de CI/CD, use variáveis de ambiente*).
3.  **Construir Imagens**: Executa `docker-compose build` para compilar todos os projetos e criar as imagens Docker.
4.  **Publicar Imagens**: Executa `docker-compose push` para enviar as imagens recém-construídas para o Docker Hub.
5.  **Iniciar Serviços**: Executa `docker-compose up -d` para iniciar todos os contêineres em segundo plano.

### `run-from-dockerhub.sh` / `run-from-dockerhub.bat`
Estes scripts são projetados para iniciar o ambiente usando imagens que já existem no Docker Hub, sem a necessidade de compilar o código-fonte localmente. São ideais para simular um ambiente de produção ou para usuários que não são desenvolvedores. O script `.sh` é para ambientes Linux/macOS e o `.bat` para Windows.
Suas etapas são:
1.  **Clonar Repositórios**: Baixa os repositórios apenas para ter acesso aos `Dockerfiles` e à estrutura, embora não vá compilá-los.
2.  **Baixar Imagens**: Executa `docker-compose pull` para baixar as imagens especificadas no `docker-compose.yml` do Docker Hub.
3.  **Iniciar Serviços**: Executa `docker-compose up -d --no-build` para iniciar os contêineres usando as imagens baixadas.

### `.env`
Este arquivo (que não deve ser versionado se contiver informações sensíveis) é usado para definir variáveis de ambiente que o `docker-compose` utiliza. No nosso caso, ele serve para um propósito principal:


IMAGE_TAG=1.0.0

-   **`IMAGE_TAG`**: Controla a tag que será aplicada às imagens Docker durante o build e o push. Isso facilita o versionamento e o gerenciamento de diferentes releases.

---

## Como Utilizar

### Pré-requisitos
-   [Git](https://git-scm.com/)
-   [Docker](https://www.docker.com/products/docker-desktop/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

### Execução Automatizada (Scripts)

#### Opção 1: Compilar, Publicar e Executar (Fluxo de Desenvolvimento)
Este fluxo é para quando você fez alterações no código e quer atualizar as imagens no Docker Hub.

1.  Clone este repositório (`orderhub-infra`).
2.  Certifique-se de que o arquivo `.env` existe e a `IMAGE_TAG` está com a versão desejada.
3.  Execute o script correspondente ao seu sistema operacional:

    **Para Linux / macOS:**
    ```bash
    chmod +x build-deploy-run-local.sh
    ./build-deploy-run-local.sh
    ```

    **Para Windows:**
    ```cmd
    build-deploy-run-local.bat
    ```

#### Opção 2: Executar a Partir de Imagens Prontas (Fluxo de "Produção")
Este fluxo é para iniciar a aplicação usando versões já publicadas no Docker Hub.

1.  Clone este repositório (`orderhub-infra`).
2.  Certifique-se de que o arquivo `.env` existe e a `IMAGE_TAG` aponta para uma versão que existe no Docker Hub.
3.  Execute o script correspondente ao seu sistema operacional:

    **Para Linux / macOS:**
    ```bash
    chmod +x run-from-dockerhub.sh
    ./run-from-dockerhub.sh
    ```

    **Para Windows:**
    ```cmd
    run-from-dockerhub.bat
    ```

---

### Fluxo de Desenvolvimento para Feature Branches

Para evitar que as imagens de desenvolvimento poluam as tags de release (`1.0.0`, `latest`, etc.), siga este fluxo ao trabalhar em uma nova funcionalidade:

1.  **Crie sua branch**: A partir da `main` ou `develop`, crie uma branch com um nome descritivo.
    ```bash
    git checkout -b feature/pagamento-com-pix
    ```

2.  **Modifique a Tag da Imagem**: Abra o arquivo `.env` e altere a `IMAGE_TAG` para um nome que identifique sua branch. É uma boa prática usar o nome da própria branch.
    ```
    # Conteúdo do arquivo .env
    IMAGE_TAG=feature-pagamento-com-pix
    ```

3.  **Execute o Build e Deploy**: Rode o script de build local (`.sh` ou `.bat`). Isso irá construir e publicar imagens com a tag da sua feature (ex: `teamorderhub/orderhub-pagamento-service:feature-pagamento-com-pix`).

Dessa forma, você pode testar sua feature de forma isolada, e as tags principais (`latest`, `1.0.0`) permanecem limpas e estáveis.

---

### Execução Manual (Passo a Passo)

Se preferir executar cada passo manualmente:

1.  **Clone todos os repositórios** para a mesma pasta raiz.
    ```bash
    git clone [https://github.com/altairlage/orderhub-infra.git](https://github.com/altairlage/orderhub-infra.git)
    git clone [https://github.com/altairlage/orderhub-core.git](https://github.com/altairlage/orderhub-core.git)
    # ... clonar os outros serviços ...
    ```

2.  **Navegue para a pasta de infraestrutura**.
    ```bash
    cd orderhub-infra
    ```

3.  **Autentique-se no Docker Hub**.
    ```bash
    docker login
    ```

4.  **Construa as imagens**.
    ```bash
    docker-compose build
    ```

5.  **Envie as imagens para o Docker Hub**.
    ```bash
    docker-compose push
    ```

6.  **Inicie os serviços**.
    ```bash
    docker-compose up -d
    ```

Para parar todos os serviços, execute `docker-compose down`.

Recomendamos tambem 'limpar' as images e containers caso tenha algum problema de execução antes de tentar novamente:
    
```bash
docker-compose down -v

docker rm -f $(docker ps -a -q)

docker rmi -f $(docker images -aq)
```