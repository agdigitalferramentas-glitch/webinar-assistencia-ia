Encontrei a causa provável do erro.

O envio não está falhando na primeira etapa: a requisição `POST /form_submissions` retorna `201`, ou seja, o lead é salvo com sucesso.

O erro aparece depois disso, dentro do próprio `embed.js`, quando ele tenta registrar o usuário no webinário via RPC `register_for_webinar` ou redirecionar para a sala. O script captura qualquer falha dessa etapa secundária e mostra a mensagem genérica “Erro ao enviar. Tente novamente.”, mesmo após já ter salvo o formulário.

Pontos encontrados:
- O formulário está renderizando corretamente dentro da div `agform-*`.
- Os campos são preenchidos corretamente.
- A submissão principal para `form_submissions` funciona e retorna sucesso.
- A tela permanece na mesma URL e mostra erro porque o script externo falha após o salvamento.
- Não há erro relevante no console da aplicação; os avisos vistos são do ambiente Lovable e não do formulário.

Plano para corrigir, se você aprovar:
1. Remover a dependência do fluxo de submit do `embed.js` para o envio final.
2. Manter o visual atual idêntico, reaproveitando o container e estilos existentes.
3. Implementar um submit controlado no próprio componente React que:
   - carrega o formulário e campos pela mesma API usada pelo script;
   - envia para `form_submissions`;
   - opcionalmente tenta registrar no webinário, sem quebrar a experiência se essa etapa falhar;
   - redireciona diretamente para `https://agwebinar.com.br/w/alan-terra-IA-lcluvv/obrigado` após salvar com sucesso.
4. Manter labels ocultos e título externo oculto, como já está hoje.
5. Validar no preview com um envio real e conferir as requisições de rede.