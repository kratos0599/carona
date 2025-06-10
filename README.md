<<<<<<< HEAD
# 🚗 Carona Feliz

Um sistema de carona solidária que permite aos usuários oferecer ou solicitar caronas, com interfaces distintas para motoristas e passageiros. Composto por uma **API backend Laravel** e um **aplicativo móvel Flutter**.

## 📋 Características

### 👥 Tipos de Usuários
- **Motoristas**: Podem criar, editar e gerenciar ofertas de carona
- **Passageiros**: Podem buscar e solicitar participação em caronas

### 🚀 Funcionalidades Principais
- ✅ Sistema de autenticação completo (registro/login/logout)
- ✅ CRUD completo de caronas para motoristas
- ✅ Sistema de busca com filtros avançados para passageiros
- ✅ Upload e visualização de fotos do veículo
- ✅ Sistema de solicitações de carona (envio/aceitação/rejeição)
- ✅ Gerenciamento de solicitações (aceitar/rejeitar)
- ✅ Interface nativa para iOS e Android
- ✅ API RESTful completa com autenticação JWT

### 🛠 Tecnologias Utilizadas

#### Backend (Laravel)
- **Framework**: Laravel 11
- **Autenticação**: Laravel Sanctum (JWT)
- **Banco de Dados**: SQLite (desenvolvimento) / MySQL ou PostgreSQL (produção)
- **Upload de Imagens**: Intervention Image
- **Validação**: Laravel Form Requests
- **API RESTful** com documentação Swagger

#### Mobile (Flutter)
- **Framework**: Flutter
- **Gerenciamento de Estado**: Provider
- **Interface**: Material Design 3
- **HTTP Client**: Dart HTTP package
- **Storage Local**: SharedPreferences
- **Suporte**: iOS, Android, Web

## 📁 Estrutura do Projeto

```
CARONA-FELIZ/
├── backend/                 # API Laravel
│   ├── app/                # Controllers, Models, Services
│   ├── database/           # Migrações, Seeders, SQLite
│   ├── routes/             # Rotas da API
│   ├── config/             # Configurações
│   └── storage/            # Uploads (fotos dos veículos)
├── mobile/                 # Aplicativo Flutter
│   ├── lib/               # Código Dart/Flutter
│   ├── android/           # Configurações Android
│   ├── ios/               # Configurações iOS
│   └── assets/            # Imagens e recursos
├── README.md              # Este arquivo
├── FUNCIONALIDADES.md     # Lista detalhada de funcionalidades
└── CORRECOES_REALIZADAS.md # Histórico de correções
```

## 🚀 Guia de Instalação Completo

### 📋 Pré-requisitos

#### Para o Backend (Laravel)
- **PHP**: Versão 8.1 ou superior
- **Composer**: Gerenciador de dependências PHP
- **Extensões PHP**: mbstring, xml, bcmath, json, curl, zip, sqlite3

#### Para o Mobile (Flutter)
- **Flutter SDK**: Versão 3.0 ou superior
- **Dart**: Incluído com Flutter
- **IDE**: Android Studio, VS Code ou IntelliJ

### 🖥️ Instalação por Sistema Operacional

## 🍎 macOS

### Backend Laravel

1. **Instalar PHP usando Homebrew**:
```bash
# Instalar Homebrew (se não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar PHP
brew install php@8.2
brew install composer

# Verificar instalação
php --version
composer --version
```

2. **Configurar o projeto**:
```bash
# Navegar para o backend
cd backend

# Instalar dependências
composer install

# Copiar arquivo de configuração
cp .env.example .env

# Gerar chave da aplicação
php artisan key:generate

# Executar migrações (criar tabelas)
php artisan migrate

# Criar link simbólico para uploads
php artisan storage:link

# Iniciar servidor
php artisan serve
```

### Mobile Flutter

1. **Instalar Flutter**:
```bash
# Usando Homebrew
brew install --cask flutter

# Ou baixar manualmente do site oficial
# https://flutter.dev/docs/get-started/install/macos
```

2. **Configurar ambiente**:
```bash
# Verificar configuração
flutter doctor

# Aceitar licenças Android
flutter doctor --android-licenses
```

3. **Executar o app**:
```bash
cd mobile
flutter pub get
flutter run
```

## 🐧 Linux (Ubuntu/Debian)

### Backend Laravel

1. **Instalar dependências**:
```bash
# Atualizar sistema
sudo apt update

# Instalar PHP e extensões
sudo apt install php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip php8.2-sqlite3 php8.2-bcmath

# Instalar Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Verificar instalação
php --version
composer --version
```

2. **Configurar o projeto**:
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan storage:link
php artisan serve
```

### Mobile Flutter

1. **Instalar Flutter**:
```bash
# Baixar Flutter
cd ~/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz

# Adicionar ao PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verificar instalação
flutter doctor
```

2. **Instalar Android Studio** (opcional):
```bash
# Baixar do site oficial
# https://developer.android.com/studio
```

3. **Executar o app**:
```bash
cd mobile
flutter pub get
flutter run
```

## 🪟 Windows

### Backend Laravel

1. **Instalar XAMPP ou WAMP**:
   - Baixe XAMPP: https://www.apachefriends.org/pt_br/index.html
   - Ou use Laragon: https://laragon.org/

2. **Instalar Composer**:
   - Baixe: https://getcomposer.org/Composer-Setup.exe
   - Execute o instalador

3. **Configurar o projeto**:
```cmd
cd backend
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate
php artisan storage:link
php artisan serve
```

### Mobile Flutter

1. **Instalar Flutter**:
   - Baixe: https://flutter.dev/docs/get-started/install/windows
   - Extraia para `C:\flutter`
   - Adicione `C:\flutter\bin` ao PATH

2. **Configurar ambiente**:
```cmd
flutter doctor
flutter doctor --android-licenses
```

3. **Executar o app**:
```cmd
cd mobile
flutter pub get
flutter run
```

## 🐳 Docker (Opcional)

### Usando Docker Compose

```bash
# Clonar o repositório
git clone https://github.com/victorgportela/carona-feliz.git
cd carona-feliz

# Executar com Docker
docker-compose up -d
```

## 📱 Configuração do Aplicativo Flutter

### 1. Configurar URL da API

Edite o arquivo `mobile/lib/services/api_service.dart`:

```dart
class ApiService {
  // Para desenvolvimento local
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Para Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Para dispositivo físico (substitua pelo seu IP)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
}
```

### 2. Encontrar seu IP local

**macOS/Linux**:
```bash
ifconfig | grep "inet "
```

**Windows**:
```cmd
ipconfig
```

## 🧪 Como Testar o Sistema

### 1. Testar Backend (API)

Use Postman, Insomnia ou curl:

**Registro de usuário:**
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Motorista",
    "email": "joao@email.com",
    "password": "12345678",
    "password_confirmation": "12345678",
    "role": "driver",
    "phone": "(11) 99999-9999"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@email.com",
    "password": "12345678"
  }'
```

### 2. Testar Flutter App

1. Certifique-se que o backend está rodando
2. Execute `flutter run` no diretório mobile
3. Registre-se como motorista ou passageiro
4. Teste as funcionalidades principais

## 📊 Banco de Dados

### Estrutura das Tabelas

- **users**: Usuários (motoristas e passageiros)
- **rides**: Caronas oferecidas pelos motoristas
- **ride_requests**: Solicitações de carona dos passageiros
- **vehicle_photos**: Fotos dos veículos dos motoristas

### Resetar Banco de Dados

```bash
cd backend
php artisan migrate:fresh
```

## 🌐 Endpoints da API

### Autenticação
- `POST /api/register` - Registro de usuário
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/me` - Dados do usuário autenticado

### Caronas (Rides)
- `GET /api/rides` - Listar caronas (com filtros)
- `POST /api/rides` - Criar carona (apenas motoristas)
- `GET /api/rides/{id}` - Detalhes da carona
- `PUT /api/rides/{id}` - Atualizar carona (apenas proprietário)
- `DELETE /api/rides/{id}` - Excluir carona (apenas proprietário)
- `GET /api/my-rides` - Caronas do usuário logado

### Solicitações de Carona
- `POST /api/rides/{id}/request` - Solicitar carona (apenas passageiros)
- `GET /api/rides/{id}/requests` - Solicitações da carona (apenas motorista)
- `PUT /api/ride-requests/{id}/accept` - Aceitar solicitação
- `PUT /api/ride-requests/{id}/reject` - Rejeitar solicitação
- `DELETE /api/ride-requests/{id}` - Cancelar solicitação

### Upload de Imagens
- `POST /api/rides/{id}/photos` - Upload de foto do veículo

## 🎨 Interface do Aplicativo

### Para Motoristas
- **Dashboard**: Visão geral das caronas criadas
- **Criar Carona**: Formulário completo com upload de fotos
- **Gerenciar Caronas**: Editar, excluir e visualizar caronas
- **Solicitações**: Aceitar ou rejeitar pedidos de passageiros
- **Perfil**: Gerenciar dados pessoais

### Para Passageiros
- **Buscar Caronas**: Interface de pesquisa com filtros
- **Detalhes da Carona**: Visualizar informações completas
- **Solicitar Carona**: Enviar pedido para o motorista
- **Minhas Solicitações**: Acompanhar status dos pedidos
- **Perfil**: Gerenciar dados pessoais

## 🔧 Configuração Avançada

### Configurar Banco MySQL/PostgreSQL

1. Edite o arquivo `.env` no backend:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=carona_feliz
DB_USERNAME=root
DB_PASSWORD=
```

2. Execute as migrações:
```bash
php artisan migrate
```

### Configurar Upload em Produção

Para produção, configure storage em nuvem (AWS S3, Google Cloud):

```env
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=carona-feliz-uploads
```

## 🔒 Segurança

- **Autenticação**: JWT com Laravel Sanctum
- **Autorização**: Middleware para diferentes tipos de usuário
- **Validação**: Validação completa de dados de entrada
- **Upload Seguro**: Validação de tipos de arquivo
- **CORS**: Headers configurados para cross-origin
- **Rate Limiting**: Limitação de requisições por IP

## 🐛 Solução de Problemas Comuns

### Backend

**Erro: "Class 'PDO' not found"**
```bash
# Ubuntu/Debian
sudo apt install php8.2-sqlite3

# macOS
brew install php@8.2
```

**Erro de permissão no storage**
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

**Porta 8000 em uso**
```bash
php artisan serve --port=8080
```

### Flutter

**Flutter Doctor Issues**
```bash
flutter doctor
flutter doctor --android-licenses
```

**Erro de conexão com API**
- Verifique se o backend está rodando
- Confirme a URL no `ApiService`
- Para Android emulator, use `10.0.2.2` ao invés de `localhost`

**Erro de dependências**
```bash
flutter clean
flutter pub get
```

## 🚀 Deploy em Produção

### Backend Laravel

1. **VPS/Cloud**:
```bash
# Atualizar dependências para produção
composer install --optimize-autoloader --no-dev

# Configurar ambiente
cp .env.example .env
# Editar .env com dados de produção

# Otimizações
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

2. **Servidor Web**: Configure Apache/Nginx para apontar para `public/`

### Flutter Mobile

1. **Android**:
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

2. **iOS**:
```bash
flutter build ios --release
```

3. **Web**:
```bash
flutter build web --release
```

## 📝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- **Laravel**: PSR-12
- **Flutter**: Dart Style Guide
- **Commits**: Conventional Commits

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

- **Email**: suporte@caronafeliz.com.br
- **Issues**: https://github.com/victorgportela/carona-feliz/issues
- **Wiki**: https://github.com/victorgportela/carona-feliz/wiki

## 🏆 Créditos

Desenvolvido com ❤️ pela equipe Carona Feliz:
- **Backend**: Laravel + PHP
- **Mobile**: Flutter + Dart
- **Design**: Material Design 3

---

**Sistema limpo e pronto para uso em produção!** 🎉

Para mais informações técnicas, consulte os arquivos:
- `FUNCIONALIDADES.md` - Lista completa de funcionalidades
- `CORRECOES_REALIZADAS.md` - Histórico de melhorias e correções 
=======
# carona
carona feliz 2.0
>>>>>>> b6e7a9ded715793b84607e98197cfbc908adb8e3
