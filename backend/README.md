# CloudWalk Referral API - FastAPI Backend

🚀 **Backend construído com FastAPI** para o sistema de referrals da CloudWalk.

## ⚡ Características

- **FastAPI** - Framework moderno e rápido
- **Documentação Automática** - `/docs` e `/redoc`
- **Validação de Dados** - Pydantic models
- **Autenticação JWT** - Segurança avançada
- **CORS configurado** - Para integração com Flutter Web

## 🏃‍♂️ Como Executar

### Opção 1: Script Automático
```bash
./run.sh
```

### Opção 2: Manual
```bash
# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Executar servidor
python main.py
```

## 📊 Endpoints Disponíveis

- `http://localhost:3002/docs` - Documentação interativa
- `http://localhost:3002/health` - Status do servidor
- `http://localhost:3002/api/demo/seed` - Criar dados de teste

## 🎯 Credenciais de Teste

```
Email: demo@cloudwalk.com
Senha: demo123
```
