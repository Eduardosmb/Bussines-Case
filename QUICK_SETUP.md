# 🚀 Configuração Rápida - CloudWalk Referrals

## ❌ Erro Corrigido

O erro `operator does not exist: text = uuid` foi corrigido! Agora use o script `supabase_setup_clean.sql`.

## ⚡ Passos Simples

### 1. Configure o .env
Edite o arquivo `.env` e adicione sua chave do Supabase:

```env
SUPABASE_URL=https://jcaaybpmhhgzbnhtkxbv.supabase.co
SUPABASE_ANON_KEY=SUA_CHAVE_AQUI
```

**Como pegar a chave:**
1. Vá em [supabase.com](https://supabase.com)
2. Seu projeto → Settings → API
3. Copie a **anon public key**

### 2. Execute o Script SQL Limpo
1. Supabase → SQL Editor
2. Copie todo o conteúdo de `supabase_setup_clean.sql`
3. Cole e clique **Run**

### 3. Teste a Aplicação
```bash
flutter run -t lib/main_simple_test.dart
```

## 🎯 O que Funciona

- ✅ **Registro sem dados mockados** - Banco começa vazio
- ✅ **UUIDs compatíveis** - Sem conflitos de tipos
- ✅ **Sistema de referrals** - Bônus automáticos
- ✅ **Políticas RLS simples** - Sem erros de permissão

## 🔍 Scripts Disponíveis

- `supabase_setup_clean.sql` ← **Use este (sem erro)**
- `supabase_tables.sql` ← Antigo (com erro de tipos)

## 📋 Estrutura do Banco

```
users (seus usuários registrados)
├── id (UUID do Supabase Auth)
├── email, first_name, last_name
├── referral_code (gerado automaticamente)
├── total_referrals, total_earnings
└── referred_by (código de quem indicou)

achievements (conquistas que você criar)
user_achievements (progresso das conquistas)
referral_links (links de compartilhamento)
referral_clicks (analytics de cliques)
```

Agora deve funcionar perfeitamente! 🎉
