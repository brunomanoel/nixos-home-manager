# Guia de Configuração YubiKey GPG/SSH

Este guia documenta o workflow completo com YubiKey para gerenciar chaves GPG e acesso SSH. Assume duas YubiKeys (principal + backup) e NixOS com Home Manager.

---

## Conceitos

- **Chave mestra** — raiz de confiança. Nunca usada no dia a dia. Mantida offline.
- **Subchaves** — três subchaves derivadas da mestra: Autenticação (SSH), Assinatura (commits git), Encriptação.
- **YubiKey** — armazena as subchaves. As chaves privadas nunca saem da YubiKey após a transferência.
- **User PIN** — usado para operações do dia a dia (SSH, assinatura). Padrão: `123456`. Altere no primeiro uso.
- **Admin PIN** — usado para operações administrativas na YubiKey (alterar PINs, importar chaves). Padrão: `12345678`. Altere no primeiro uso.
- **PUK** — desbloqueia o User PIN após 3 tentativas erradas. Armazene no LastPass. Se o PUK também for bloqueado, a YubiKey fica permanentemente inutilizada para GPG.

> **Armazene no LastPass:** User PIN, Admin PIN, PUK de ambas as YubiKeys, a passphrase da chave mestra e a própria chave mestra (como anexo em nota segura). O LastPass protegido por YubiKey 2FA é um modelo de segurança suficiente para a maioria dos casos. Alternativa: pendrive criptografado mantido fisicamente seguro.

---

## 1. Setup Inicial

### 1.1 Gerar a chave mestra (offline)

Faça isso em uma máquina air-gapped ou no mínimo em um Live USB. A chave mestra nunca deve ser armazenada sem criptografia em uma máquina de uso diário.

```bash
# Gerar chave mestra (apenas certificação, sem expiração)
gpg --expert --full-generate-key
# Escolha: (11) ECC (defina suas próprias capacidades)
# Alterne capacidades: 's' para remover Sign, 'a' para remover Authenticate
# Apenas 'Certify' deve permanecer — confirme com 'q'
# Curva: (1) Curve 25519
# Expiração: 0 (sem expiração)
# Nome real, email: sua identidade pessoal (email principal)
```

### 1.2 Adicionar User ID do GitHub (email noreply)

O GitHub fornece um email noreply para não expor seu email real nos commits.
Encontre o seu em: https://github.com/settings/emails (formato: `ID+username@users.noreply.github.com`)

```bash
gpg --edit-key SEU_KEY_ID
# No prompt do gpg:
adduid
# Digite: nome, email noreply do GitHub
uid 2          # selecionar o novo uid
trust          # definir nível de confiança
primary        # opcionalmente definir como primário
save
```

### 1.3 Adicionar subchaves

Duas subchaves — sem expiração (a YubiKey é a barreira de segurança):

```bash
gpg --expert --edit-key SEU_KEY_ID
# No prompt do gpg:

# Subchave 1: GitHub (Sign + Authenticate — para commits GPG e SSH no GitHub)
addkey
# Escolha: (11) ECC (defina suas próprias capacidades)
# Alterne: 's' para adicionar Sign, 'a' para adicionar Authenticate, 'e' para remover Encrypt
# Apenas Sign + Authenticate deve permanecer — confirme com 'q'
# Curva: (1) Curve 25519
# Expiração: 0 (sem expiração — YubiKey é a barreira de segurança)

# Subchave 2: Servidores (Authenticate only — para SSH no cloudarm e outros servidores)
addkey
# Escolha: (11) ECC (defina suas próprias capacidades)
# Alterne: 'a' para adicionar Authenticate — apenas Authenticate deve permanecer — confirme com 'q'
# Curva: (1) Curve 25519
# Expiração: 0

save
```

### 1.4 Exportar e fazer backup da chave mestra

```bash
# Exportar chave mestra
gpg --armor --export-secret-keys SEU_KEY_ID > master-key-backup.asc
gpg --armor --export SEU_KEY_ID > public-key.asc

# Backup em papel (opcional)
paperkey --secret-key master-key-backup.asc --output master-key-papel.txt
```

**Opção A (recomendada para este setup): Armazenar no LastPass**
- Crie uma nota segura no LastPass
- Anexe `master-key-backup.asc` como arquivo
- Armazene a passphrase na mesma nota
- O LastPass está protegido por YubiKey 2FA — segurança suficiente para este modelo de ameaça

**Opção B: Pendrive criptografado**
- Armazene `master-key-backup.asc` em um pendrive criptografado mantido fisicamente seguro
- Nunca armazene sem criptografia na nuvem ou em máquinas de uso diário

> Quando precisar da chave mestra para operações (adicionar UIDs, rotacionar subchaves), importe-a temporariamente, realize a operação e depois apague: `gpg --delete-secret-key SEU_KEY_ID`

### 1.5 Transferir subchaves para YubiKey 1

```bash
gpg --edit-key SEU_KEY_ID
# No prompt do gpg:
key 1          # selecionar subchave de autenticação
keytocard      # transferir para YubiKey → slot 3 (Autenticação)
key 1          # desselecionar
key 2          # selecionar subchave de assinatura
keytocard      # transferir → slot 1 (Assinatura)
key 2          # desselecionar
key 3          # selecionar subchave de encriptação
keytocard      # transferir → slot 2 (Encriptação)
save
```

> Após `keytocard`, a cópia local é substituída por um stub apontando para a YubiKey. A chave privada agora vive apenas no cartão.

### 1.6 Transferir subchaves para YubiKey 2 (backup)

Primeiro restaure o backup da chave mestra (para recuperar as chaves privadas reais, não os stubs):

```bash
gpg --import master-key-backup.asc
gpg --edit-key SEU_KEY_ID
# Repita keytocard para cada subchave, desta vez com a YubiKey 2 inserida
```

### 1.7 Registrar chave pública

```bash
# Exportar chave pública
gpg --armor --export SEU_KEY_ID > public-key.asc

# GitHub: Configurações → SSH e GPG keys → Nova GPG key → cole public-key.asc
# Servidores: adicione a chave SSH pública no authorized_keys
gpg --export-ssh-key SEU_KEY_ID   # gera no formato SSH public key
```

---

## 2. Uso no Dia a Dia

### 2.1 Nova máquina

```bash
# Importar chave pública (sem chave privada — ela está na YubiKey)
gpg --import public-key.asc
# Ou buscar do servidor de chaves
gpg --keyserver keys.openpgp.org --recv-keys SEU_KEY_ID

# Confiar na chave
gpg --edit-key SEU_KEY_ID
trust → 5 (ultimate) → save

# Plugar a YubiKey — gpg-agent detecta automaticamente
gpg --card-status   # verificar se a YubiKey foi reconhecida
```

O `gpg-agent` com `enableSshSupport = true` já está configurado nos dotfiles.
O `SSH_AUTH_SOCK` é definido automaticamente via `gpgconf --launch gpg-agent` no `loginExtra`.

### 2.2 Configurar git para assinar commits

```bash
git config --global user.signingkey SEU_SUBKEY_ID!  # note o ! no final
git config --global commit.gpgsign true
git config --global user.email "ID+username@users.noreply.github.com"  # noreply do GitHub
```

---

## 3. Importar Chaves de Terceiros

Quando um empregador ou serviço fornece um par de chaves RSA/ED25519:

### 3.1 Importar no GPG como subchave de autenticação

```bash
# Converter a chave privada para formato GPG e importar como subchave
# Atenção: esta chave existiu no disco — apague-a depois
gpg --expert --edit-key SEU_KEY_ID
addkey
# Escolha: (13) Chave existente → informe o caminho do arquivo
save
```

Depois transfira para a YubiKey:

```bash
gpg --edit-key SEU_KEY_ID
# Selecione a subchave recém-adicionada
keytocard   # transferir para slot de autenticação da YubiKey
save
```

### 3.2 Apagar a chave privada do disco

```bash
# Sobrescrever e apagar o arquivo original
shred -u caminho/para/private.key
# Verificar que foi apagado
ls caminho/para/private.key
```

---

## 4. Remover Subchaves Importadas de Terceiros

Quando o acesso não é mais necessário (mudança de emprego, fim de projeto):

```bash
gpg --expert --edit-key SEU_KEY_ID
# Liste as subchaves: key N para selecionar a que deseja remover
key N
delkey      # remove a subchave do keyring
save
```

> Isso remove o stub da subchave do seu keyring local. O slot da YubiKey pode ser sobrescrito importando uma chave diferente ou resetando o cartão.

Revogue também o acesso no serviço (remova do `authorized_keys`, GitHub, etc.).

---

## 5. Revogar Acesso a um Serviço

```bash
# Remover sua chave pública do servidor remoto
ssh usuario@servidor "sed -i '/SEU_FINGERPRINT/d' ~/.ssh/authorized_keys"

# GitHub: Configurações → SSH e GPG keys → Excluir chave
```

---

## 6. SSH Forwarding (Operações Git Remotas)

Quando conectado via SSH a um servidor remoto (ex: cloudarm) e precisando fazer git push:

Os dotfiles já configuram `ForwardAgent yes` e `remoteForwards` para forwarding do socket do gpg-agent.

No servidor remoto, garanta:

```bash
# ~/.gnupg/gpg-agent.conf
enable-ssh-support
extra-socket /run/user/1000/gnupg/S.gpg-agent.extra
```

A configuração SSH já cuida do forwarding do socket do agente automaticamente.

---

## 7. Setup no WSL

O WSL não tem acesso USB direto. Use `usbipd` (Windows) para encaminhar a YubiKey:

```powershell
# Windows (PowerShell como administrador)
winget install usbipd
usbipd list                          # encontre o bus ID da YubiKey
usbipd bind --busid BUSID
usbipd attach --wsl --busid BUSID
```

```bash
# WSL
gpg --card-status   # verificar se a YubiKey foi reconhecida
```

> Execute `usbipd attach` toda vez que plugar a YubiKey no Windows.

---

## 8. Setup no macOS

Use o GPG do Nix (já nos dotfiles) em vez do GPGTools para evitar conflitos:

```bash
# Verificar que o gpg é do Nix, não do GPGTools
which gpg   # deve ser /etc/profiles/per-user/... ou /run/current-system/...

# Importar chave pública
gpg --import public-key.asc

# Plugar a YubiKey
gpg --card-status
```

O pinentry usa `pinentry-curses` no macOS (configurado nos dotfiles).

---

## 9. Gerenciamento de PINs

| PIN | Padrão | Propósito | Tentativas antes de bloquear |
|-----|--------|-----------|------------------------------|
| User PIN | `123456` | Operações diárias (SSH, assinar) | 3 |
| Admin PIN | `12345678` | Administração do cartão (alterar PINs, importar) | 3 |
| PUK | `12345678` | Desbloquear User PIN | 3 |

```bash
# Alterar PINs (faça isso no primeiro uso)
gpg --card-edit
passwd   # alterar User PIN
admin
passwd   # alterar Admin PIN e PUK
```

> Armazene todos os PINs e o PUK no LastPass. Se o PUK for bloqueado, a YubiKey fica permanentemente inutilizada para operações GPG (pode ser resetada de fábrica, perdendo todas as chaves).

### 9.1 Desbloquear User PIN bloqueado

```bash
gpg --card-edit
admin
unblock   # usa o PUK para desbloquear o User PIN
```

---

## 10. Rotação de Subchaves

Subchaves devem ser rotacionadas a cada 1-2 anos (ou quando a expiração for atingida):

```bash
# Restaurar chave mestra do backup offline
gpg --import master-key-backup.asc

gpg --expert --edit-key SEU_KEY_ID
# Para cada subchave: selecione, defina nova expiração
key N
expire
# Ou gere novas subchaves e revogue as antigas
addkey   # nova subchave
key N    # selecionar subchave antiga
revkey   # revogar subchave antiga
save

# Transferir novas subchaves para ambas as YubiKeys
# Re-exportar e atualizar chave pública no GitHub e servidores
```

---

## 11. Emergência: YubiKey Perdida ou Quebrada

1. Use a YubiKey de backup imediatamente — mesmas chaves, mesmo PIN
2. Peça uma YubiKey de reposição
3. Quando chegar, restaure as subchaves do backup da chave mestra e transfira para a nova YubiKey
4. Altere os PINs na nova YubiKey

---

## 12. Emergência: YubiKey Comprometida

Se alguém teve acesso físico à sua YubiKey E conhece o PIN:

```bash
# Restaurar chave mestra do backup offline
gpg --import master-key-backup.asc

# Revogar subchaves comprometidas
gpg --edit-key SEU_KEY_ID
key N
revkey   # revogar a subchave comprometida
save

# Gerar novas subchaves e transferir para ambas as YubiKeys
# Atualizar chave pública em todos os lugares (GitHub, servidores)
gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID
```

---

## 13. Emergência: Chave Mestra Comprometida

Se o backup offline da chave mestra foi exposto:

1. Revogar toda a chave: `gpg --gen-revoke SEU_KEY_ID > revogacao.asc`
2. Publicar revogação: `gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID`
3. Gerar uma nova chave mestra e subchaves do zero (siga a Seção 1)
4. Atualizar em todos os lugares: GitHub, todos os servidores, git config

---

## 14. Adicionar um Endereço de Email

Use quando quiser associar um novo email à sua chave existente (ex: novo emprego, nova conta GitHub) sem remover os existentes.

```bash
# Passo 1: importar chave mestra do backup no LastPass
gpg --import master-key-backup.asc

# Passo 2: adicionar o novo User ID
gpg --edit-key SEU_KEY_ID
# No prompt do gpg:
adduid
# Digite: seu nome, novo endereço de email
uid N          # selecionar o novo uid (N = seu número na lista)
trust          # definir confiança: escolha 5 (ultimate, pois é sua própria chave)
save

# Passo 3: re-exportar e publicar chave pública atualizada
gpg --armor --export SEU_KEY_ID > public-key.asc
gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID

# Passo 4: atualizar o LastPass com o novo public-key.asc

# Passo 5: apagar chave mestra da máquina local
gpg --delete-secret-key SEU_KEY_ID
```

> A YubiKey continua funcionando após isso — as subchaves não mudaram. Apenas a chave pública precisa ser re-exportada e re-enviada aos serviços.

## 14b. Remover um Endereço de Email (Mudança de Email)

```bash
# Passo 1: importar chave mestra do backup no LastPass
gpg --import master-key-backup.asc

gpg --edit-key SEU_KEY_ID
uid N          # selecionar uid a remover
deluid         # remover
save

# Re-exportar e atualizar chave pública
gpg --armor --export SEU_KEY_ID > public-key.asc
gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID

# Apagar chave mestra da máquina local
gpg --delete-secret-key SEU_KEY_ID
```

---

## 15. Migração de Algoritmo

Se o algoritmo atual (ex: RSA 4096) for depreciado:

1. Gerar nova chave mestra com novo algoritmo (ex: Ed25519)
2. Assinar nova chave com a antiga para estabelecer cadeia de confiança (se possível)
3. Seguir o processo completo de setup (Seção 1)
4. Revogar chave antiga após migração completa em todos os lugares
