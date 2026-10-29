# Atualização do nome para Catechesis

Alterado: título da aba do navegador (`index.html`), título da tela de login e cabeçalho interno (`src/App.tsx`), nome técnico do pacote (`package.json`).

O ano de **2027 permanece nas turmas, no planejamento e no banco de dados**, para preservar os cadastros existentes.

## Aplicar no Windows (VS Code)

1. Faça uma cópia da pasta local atual.
2. Extraia este ZIP em **uma pasta nova**; não substitua seu `.env` existente.
3. Copie o arquivo `.env` da pasta local antiga para a pasta nova; ele contém as configurações públicas do seu Supabase. Não envie `.env` à Hostinger nem compartilhe suas chaves.
4. No VS Code, abra a nova pasta `catechesis`.
5. Abra o terminal e execute `npm.cmd install` e `npm.cmd run build`.
6. Verifique que a pasta `dist` contém `index.html` e `assets`.
7. Faça um ZIP do **conteúdo** de `dist` (não a pasta em si).
8. No hPanel Hostinger → Sites → Gerenciar → Gerenciador de Arquivos → `public_html`, crie um backup dos arquivos publicados; depois substitua `index.html` e os arquivos da pasta `assets` pelos da nova versão. Cuidado para não criar `public_html/dist/index.html`.
9. Teste `https://catechesis.net.br` e use Ctrl+F5 se o navegador estiver exibindo a versão antiga.

Não execute novamente o SQL do Supabase. Não apague a base existente. Não altere nomes de domínio ou URLs no Supabase: continuam iguais.
