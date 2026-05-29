## Objetivo

Restaurar o script oficial `embed.js` do AGWebinar como responsável pelo envio do formulário, mantendo intacto o visual atual da squeeze page (layout, cores, tipografia, urgency bar, blocos "O que vai aprender", "Esta aula é para você", autoridade).

## O que muda em `src/routes/index.tsx`

1. **Remover o submit controlado em React**:
   - Estados `form`, `fields`, `values`, `submitting`, `error`, `done`.
   - Funções `handleSubmit`, `sbFetch`, `inputTypeFor`, `emailField`, `nameField`, `phoneField`.
   - Tipos `FormField`, `FormDef` e constantes `SUPABASE_URL`, `SUPABASE_KEY`, `FORM_SLUG`.
   - `useEffect` que faz fetch das tabelas `forms` e `form_fields`.
   - O `<form className="agform">` renderizado manualmente.

2. **Voltar a montar o container oficial do AGWebinar** dentro do `.form-box`:
   ```html
   <div id="agform-como-usar-...-1779800811194"></div>
   ```
   (mesma `div` id que o `embed.js` espera para injetar o formulário).

3. **Carregar o `embed.js` via `useEffect`**, injetando:
   ```html
   <script src="https://qywlapkndyjwbkpoqefx.supabase.co/storage/v1/object/public/embed/embed.js" async></script>
   ```
   com guarda para não duplicar o script em re-renders/HMR e cleanup adequado.

4. **Manter os elementos visuais que envolvem o form** (`.form-title`, `.form-subtitle`, `.form-privacy`, `.form-box`) exatamente como estão hoje.

## CSS — manter visual

No bloco `css` dentro do arquivo:

1. **Manter** todas as regras `.agform-*` já existentes (input, button, layout) — o `embed.js` renderiza com essas mesmas classes, então o visual continua idêntico.
2. **Manter** as regras que escondem os labels e o título do form embutido (foi pedido em mensagens anteriores).
3. **Remover** apenas as regras `.agform-error` e `.agform-success` que adicionei para o submit React, já que voltam a ser controladas pelo `embed.js`.

## O que NÃO muda

- Layout geral, imagens, textos, cores, fontes, animações, urgency bar e countdown.
- Os blocos "O que você vai aprender", "Esta aula é para você que…", autoridade do Alan Terra.
- Meta tags / `head()` da rota.
- Configuração no Supabase, formulário ou webinário no AGWebinar.
- Comportamento de redirect pós-envio: volta a ser o que o `embed.js` faz nativamente (que é o fluxo oficial e o que registra o lead corretamente no AGWebinar).

## Validação

Após implementar:
1. Verificar no preview que o formulário renderiza dentro do nosso `.form-box` com o visual atual (sem labels, mesmos inputs/botão estilizados).
2. Fazer um envio de teste e confirmar nos logs de rede que o `embed.js` chama as APIs do AGWebinar.
3. Você confirma no painel do AGWebinar que o lead aparece como inscrito no webinário.
