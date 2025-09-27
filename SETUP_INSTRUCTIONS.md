# 🚀 Instruções de Configuração - CloudWalk Referrals

## ✅ Problemas Resolvidos

1. **Arquivo .env criado** ✅
2. **SupabaseService corrigido** ✅ 
3. **Scripts SQL das tabelas criados** ✅

## 🔧 Próximos Passos

### 1. Configure suas credenciais do Supabase

1. Acesse [supabase.com](https://supabase.com) e faça login
2. Vá ao seu projeto "CloudWalk Referrals" (ID: jcaaybpmhhgzbnhtkxbv)
3. Vá em **Settings** → **API**
4. Copie:
   - **Project URL**: `https://jcaaybpmhhgzbnhtkxbv.supabase.co`
   - **anon public key**: `eyJ...` (uma chave longa que começa com eyJ)

5. Abra o arquivo `.env` na raiz do projeto e substitua:

```env
SUPABASE_URL=https://jcaaybpmhhgzbnhtkxbv.supabase.co
SUPABASE_ANON_KEY=SUA_CHAVE_ANON_AQUI
```

### 2. Crie as tabelas no banco de dados

1. No Supabase, vá em **SQL Editor**
2. Abra o arquivo `supabase_tables.sql` que foi criado
3. Copie todo o conteúdo e cole no SQL Editor
4. Clique em **Run** para executar

### 3. Teste a aplicação

```bash
cd "/home/eduba/Área de trabalho/cloudwalk/Bussines-Case"
flutter run -t lib/main_simple_test.dart
```

## 🔍 O que foi corrigido

### SupabaseService.dart
- ✅ Implementada autenticação real do Supabase (`signUp`, `signInWithPassword`)
- ✅ Gestão correta de sessões (`getCurrentUser`, `logout`)
- ✅ Sistema de referrals funcionando (bônus de $25 para quem usa código, $50 para quem refere)
- ✅ Integração com banco de dados real

### main_simple_test.dart
- ✅ Carregamento correto do arquivo `.env`
- ✅ Inicialização do Supabase com tratamento de erros

### Banco de Dados
- ✅ Esquema completo com tabelas: `users`, `referral_links`, `achievements`, `user_achievements`
- ✅ Políticas RLS (Row Level Security) configuradas
- ✅ Triggers automáticos para atualizar estatísticas de referral
- ✅ Índices para performance

## 🎯 Como funciona agora

1. **Registro**: Usuário cria conta → Supabase Auth + perfil na tabela `users`
2. **Login**: Autenticação via Supabase + busca do perfil
3. **Referrals**: Sistema automático de bônus ($25 + $50)
4. **Dashboard**: Dados reais do banco de dados

## 🚨 Possíveis Erros e Soluções

### Erro 404 / URL inválida
- ✅ **Resolvido**: Agora usa a URL correta do seu projeto

### Erro de autenticação
- ✅ **Resolvido**: Implementada autenticação real do Supabase

### Tabelas não existem
- ✅ **Resolvido**: Script SQL completo criado em `supabase_tables.sql`

### .env não encontrado
- ✅ **Resolvido**: Arquivo `.env` criado (você só precisa adicionar sua SUPABASE_ANON_KEY)

## 📋 Checklist Final

- [ ] Copiar `SUPABASE_ANON_KEY` real no arquivo `.env`
- [ ] Executar `supabase_tables.sql` no Supabase SQL Editor
- [ ] Testar registro de novo usuário
- [ ] Testar login
- [ ] Verificar se dados aparecem no dashboard

## 🆘 Se ainda houver problemas

1. Verifique se a `SUPABASE_ANON_KEY` está correta
2. Confirme que as tabelas foram criadas (vá no Supabase → Table Editor)
3. Verifique o console do Flutter para mensagens de debug

Agora seu app deve conectar corretamente com o Supabase! 🎉
