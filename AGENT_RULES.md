# ⛔ REGRAS INVIOLÁVEIS PARA O AGENTE LOVABLE

> Este arquivo é a **fonte de verdade** das regras operacionais deste projeto.
> Qualquer agente (Lovable, humano ou automação) DEVE ler e respeitar antes
> de qualquer ação.

 ## 🎯 0. O GRANDE OBJETIVO (A FILOSOFIA MIRROR)
 
 O **DeployHub** existe para ser um **espelho (mirror) absoluto** da aplicação que reside na Lovable/Lovable Cloud em um ambiente externo (Servidor Próprio + Supabase Externo).
 
 **Meta 100% Migration:** O objetivo é migrar **tudo**, sem exceções:
 - Repositório GitHub (código, histórico, segredos).
 - Supabase Externo (Schema, Dados, Usuários, Permissões, Auth, Storage).
 - Infraestrutura (Dokploy, SSL, Domínios).
 
 O DeployHub deve garantir que o sistema rodando externamente seja **idêntico** ao que a Lovable gerou, preservando permissões e estados.
 
 ## 🔒 1. BLOQUEIO TOTAL DO LOVABLE CLOUD

**É TERMINANTEMENTE PROIBIDO** consultar, diagnosticar, ler logs, escrever,
migrar ou de qualquer forma utilizar o **Lovable Cloud** (`obyhdjpmzxfvhbqxvzfi`)
como fonte de dados para o DeployHub.

### Ferramentas BANIDAS para diagnóstico de dados do app:
- `supabase--read_query`
- `supabase--insert`
- `supabase--migration` (somente para schema do próprio Cloud — JAMAIS para dados do DeployHub)
- `supabase--analytics_query`
- `supabase--linter`
- `supabase--cloud_status`
- `psql` / variáveis `PG*` apontando para o Cloud

### Por quê
O Lovable Cloud está **vazio/desatualizado** em relação ao DeployHub real.
Olhar para ele leva a diagnósticos errados, perda de tempo e quebra de
confiança. O usuário já corrigiu isso múltiplas vezes.

## ✅ 2. ÚNICA FONTE DE VERDADE: SUPABASE EXTERNO

- **Project ref:** `oalaegjhbzvbigyxkgoy`
- **Organização:** `ljapcbzjuflxxpwrnsgq`
- Todo o estado real do app (servidores, projetos, integrações, deployments,
  user_integrations, organization_members, etc.) vive aqui.
- Edge functions deste repositório **leem o Supabase externo via secrets**
  (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`). Apenas o **deploy** das
  funções acontece no lado Lovable.

## 🔧 3. COMO DIAGNOSTICAR SEM QUEBRAR A REGRA

Se for absolutamente necessário inspecionar dados:

1. **Pedir ao usuário** para rodar a query no Supabase externo dele e colar o resultado.
2. Inspecionar **código** (`src/`, `supabase/functions/`) para entender o fluxo.
3. Verificar **logs de edge functions** via `supabase--edge_function_logs`
   (essas funções rodam contra o externo, então os logs são confiáveis).
4. Usar `supabase--curl_edge_functions` para testar uma function ponta-a-ponta.

## 🚫 4. CHECKLIST OBRIGATÓRIO ANTES DE QUALQUER QUERY

Antes de chamar QUALQUER tool de banco, perguntar:

- [ ] Esta tool atinge o Lovable Cloud (`obyhdjpmzxfvhbqxvzfi`)?
- [ ] Se sim, **PARAR** e pedir ao usuário ou usar outra abordagem.
- [ ] Só prosseguir se a tool toca exclusivamente o Supabase externo
      (`oalaegjhbzvbigyxkgoy`) — o que, hoje, **nenhuma tool nativa do
      Lovable faz diretamente**.

**Conclusão prática:** o agente NÃO executa SQL contra banco nenhum.
Pede pro usuário ou lê via edge function.

## 🛠️ 6. CONSISTÊNCIA DE BUILD (SSR / TANSTACK START)

- O projeto usa TanStack Start com Nitro.
- O diretório de saída DEVE ser `dist` (não `.output`).
- O `Dockerfile` deve sempre validar a existência de `dist/server/index.mjs` antes de finalizar.
- Qualquer mudança no `vite.config.ts` ou `package.json` que altere o preset do Nitro deve ser refletida imediatamente no `Dockerfile`.

## 📌 7. QUEM ALTERAR ESTE ARQUIVO

Apenas o usuário pode relaxar essas regras explicitamente. O agente NÃO
remove nem flexibiliza este arquivo por conta própria, mesmo que pareça
conveniente para resolver um problema mais rápido.