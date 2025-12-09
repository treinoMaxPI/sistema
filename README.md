# Treino Max

Sistema de gerenciamento de academia desenvolvido com Spring Boot, PostgreSQL e Flutter.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

- [Docker](https://www.docker.com/get-started) e [Docker Compose](https://docs.docker.com/compose/install/)
- [Java JDK 17+](https://www.oracle.com/java/technologies/downloads/)
- [Maven](https://maven.apache.org/download.cgi) (ou use o Maven Wrapper incluído no projeto)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/)

## 🚀 Como executar o projeto

### 1. Clone o repositório

```bash
git clone https://github.com/treinoMaxPI/sistema.git
cd sistema
```

### 2. Configure e inicie o banco de dados (PostgreSQL)

O projeto utiliza PostgreSQL rodando em Docker. Execute os comandos abaixo:

```bash
cd docker
docker compose up --build
```

Isso irá:
- Baixar a imagem do PostgreSQL (se necessário)
- Criar e iniciar o container do banco de dados
- O banco estará disponível em `localhost:5435`
- Database: `treinomax`
- Usuário: `postgres`
- Senha: `postgres`

**Verificar se o container está rodando:**

```bash
docker ps
```

**Para parar o banco de dados:**

```bash
docker compose down
```

### 3. Execute o Backend (Spring Boot)

Navegue até a pasta do backend e execute:

**Usando Maven Wrapper (recomendado):**

```bash
cd backend
./mvnw spring-boot:run
```

**Ou usando Maven instalado:**

```bash
cd backend
mvn spring-boot:run
```

O backend estará disponível em: **http://localhost:8080**

### 4. Execute o Frontend (Flutter)

Em um novo terminal, navegue até a pasta do frontend:

```bash
cd front
```

**Instale as dependências:**

```bash
flutter pub get
```

**Execute o projeto na porta 4200:**

```bash
flutter run -d chrome --web-port=4200
```

Ou para desenvolvimento web:

```bash
flutter run -d web-server --web-port=4200
```

O frontend estará disponível em: **http://localhost:4200**

## 🗂️ Estrutura do Projeto

```
sistema/
├── backend/              # API Spring Boot
│   ├── src/
│   └── pom.xml
├── front/                # Aplicação Flutter
│   ├── lib/
│   ├── uploads/          # Pasta para upload de arquivos
│   └── pubspec.yaml
├── docker-compose.yml    # Configuração do PostgreSQL
└── README.md
```

## 🔧 Configurações Importantes

### Backend

- **Porta:** 8080
- **Banco de dados:** PostgreSQL na porta 5435
- **JWT Secret:** Configurado no `application.properties`
- **Upload de arquivos:** Máximo 5MB, salvos em `../front/uploads`

### Frontend

- **Porta:** 4200
- **Comunicação com API:** http://localhost:8080

## 📝 Comandos Úteis

### Docker

```bash
# Iniciar banco de dados
docker-compose up -d

# Parar banco de dados
docker-compose down

# Ver logs do container
docker-compose logs -f

# Remover volumes (limpar dados do banco)
docker-compose down -v
```

### Backend

```bash
# Configurando application.properties
cp application.properties.example application.properties

# Compilar o projeto
./mvnw clean install

# Executar testes
./mvnw test

# Gerar JAR
./mvnw package
```

### Frontend

```bash
# Instalar dependências
flutter pub get

# Limpar build
flutter clean

# Executar em modo debug
flutter run -d chrome --web-port=4200

# Build para produção
flutter build web
```

## ❗ Solução de Problemas

### Banco de dados não conecta

1. Verifique se o Docker está rodando: `docker ps`
2. Verifique se a porta 5435 não está em uso
3. Tente recriar o container: `docker-compose down -v && docker-compose up -d`

### Backend não inicia

1. Verifique se o Java está instalado: `java -version`
2. Certifique-se que o banco de dados está rodando
3. Verifique se a porta 8080 está livre

### Frontend não carrega

1. Verifique se o Flutter está instalado: `flutter doctor`
2. Limpe o cache: `flutter clean && flutter pub get`
3. Certifique-se que a porta 4200 está livre

### Erro de CORS

Se houver problemas de CORS, verifique se o backend está configurado para aceitar requisições de `http://localhost:4200` no arquivo `application.properties`.

## 👥 Desenvolvimento

Para desenvolvimento, mantenha 3 terminais abertos:

1. **Terminal 1:** Docker Compose (banco de dados)
2. **Terminal 2:** Backend Spring Boot
3. **Terminal 3:** Frontend Flutter

## 📄 Licença

Este projeto é de uso educacional.

---
