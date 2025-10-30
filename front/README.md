# Gym Management - Flutter Frontend

Aplicativo de gestão de academias desenvolvido em Flutter.

## Funcionalidades

- Autenticação de usuários (Login/Registro)
- Tela inicial com menu de funcionalidades
- Gerenciamento de tokens JWT
- Interface básica e funcional

## Configuração

1. Certifique-se de ter o Flutter instalado
2. Execute `flutter pub get` para instalar as dependências
3. Configure o backend para rodar em `http://localhost:8080`
4. Execute `flutter run` para iniciar o aplicativo

## Estrutura do Projeto

```
lib/
├── main.dart          # Ponto de entrada da aplicação
├── models/            # Modelos de dados
├── services/          # Serviços de API
└── screens/           # Telas da aplicação
```

## API Endpoints

O aplicativo consome a API de autenticação nos seguintes endpoints:

- `POST /api/auth/login`
- `POST /api/auth/register` 
- `POST /api/auth/forgot-password`
- `POST /api/auth/resend-verification`
- `POST /api/auth/logout`