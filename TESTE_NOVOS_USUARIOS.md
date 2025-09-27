# 🧪 Teste com Usuários Novos

## 📧 Emails para Testar (use estes):

### **Usuário 1 (sem referral):**
- **Email**: `ana.silva@teste.com`
- **Nome**: Ana Silva
- **Senha**: `123456`
- **Código referral**: Não usar

### **Usuário 2 (com referral do Eduardo):**
- **Email**: `carlos.santos@teste.com`
- **Nome**: Carlos Santos
- **Senha**: `123456`
- **Código do Eduardo**: Use o código que aparece no dashboard do Eduardo

### **Usuário 3 (com referral da Ana):**
- **Email**: `maria.oliveira@teste.com`
- **Nome**: Maria Oliveira
- **Senha**: `123456`
- **Código da Ana**: Use o código que aparece no dashboard da Ana

## 🎯 **Fluxo de Teste:**

1. **Eduardo faz login** → Vê seus achievements
2. **Clica no ícone 🔔** → Testa popup de achievement
3. **Registra Ana** (sem código) → Ana ganha $0
4. **Registra Carlos** (com código do Eduardo) → Eduardo ganha +$50, Carlos ganha +$25
5. **Eduardo faz login** → Verifica se achievement "Primeiro Sucesso" (🎯) foi desbloqueado
6. **Popup aparece automaticamente** mostrando achievement desbloqueado!

## 🏆 **Achievements que devem desbloquear:**

- **Eduardo**: "Primeiro Sucesso" 🎯 (1 referral) → +$10 de bônus
- **Ana**: Nenhum ainda
- **Carlos**: Nenhum ainda

## 🔔 **Para Ver Popup:**

1. **Login como Eduardo**
2. **Registrar Carlos** com código do Eduardo
3. **Login novamente como Eduardo**
4. **Popup deve aparecer** automaticamente mostrando achievement desbloqueado!
