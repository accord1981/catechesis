# Catechesis 2027 — Primeira versão funcional

Aplicação React + TypeScript + Supabase para atualização cadastral, registro de formações, escolha de até três turmas e painel de alocação da coordenação.

## Requisitos
- Node.js 20 ou superior e npm
- Projeto Supabase com autenticação por e-mail habilitada

## Configuração
1. Crie um projeto em https://supabase.com/dashboard.
2. No **SQL Editor**, execute integralmente `supabase/schema.sql` **uma vez**, em um projeto novo.
3. Em **Authentication > Providers > Email**, defina as regras de confirmação desejadas; para produção, habilite confirmação de e-mail e configure SMTP adequado.
4. Copie `.env.example` como `.env` e preencha `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` com a URL e a chave **publicável** do projeto. **Nunca use a service_role ou uma chave secreta no front-end.**
5. Execute `npm install` e `npm run dev`. Abra o endereço mostrado pelo terminal (geralmente http://localhost:5173).
6. Cadastre sua conta no formulário; confirme o e-mail, se aplicável.
7. Para torná-la administradora, consulte o ID da conta em **Authentication > Users** e execute no SQL Editor: `insert into public.administradores(user_id) values ('COLE_AQUI_UUID_DO_USUARIO');`. Recarregue a página depois.
8. Para disponibilizar na Internet, hospede o front-end no Netlify, Vercel ou serviço equivalente e configure as mesmas variáveis de ambiente. Ajuste as URLs permitidas no Supabase Auth para o domínio publicado.

## Como funciona
- Cadastro/login individual por e-mail + senha.
- Catequista atualiza dados pessoais e cursos.
- Catequista seleciona até **3** opções em ordem de preferência; clicar em **Salvar minhas escolhas** grava as opções na base.
- Administrador vê as **29 turmas**, interessados e a ocupação e pode alocar/remover um catequista interessado.
- Cada turma possui **1 vaga** por padrão, validada no banco, inclusive contra atualizações simultâneas.
- Alocação somente para catequistas interessados na turma (não equivale a disponibilidade automática).
- O painel utiliza eventos Realtime e também oferece atualização manual.

## Atenção antes de uso com dados reais
- O projeto é um **MVP**. É recomendável validar fluxos, identidade visual, acesso, política de privacidade, coleta mínima de dados e período de retenção com a coordenação antes da publicação.
- No Supabase Auth, avalie desabilitar autoinscrição pública depois de cadastrar os catequistas ou adotar convites para impedir contas não autorizadas.
- O nome informado pelo catequista não valida sua identidade; o e-mail deve ser confirmado.
- Nenhuma chave secreta ou credencial administrativa deve estar no código do navegador.
- Ações administrativas usam políticas RLS e validação transacional no banco.
- A coleção de dados pessoais exige aviso de privacidade, base legal e procedimentos de acesso/exclusão em conformidade com a LGPD.
- O cadastro inicial não requer CPF, documentos nem dados pessoais sensíveis.
- A versão 1 não inclui recuperação de senha na interface, edição de formações, exportação, aviso de privacidade completo, regras de conflitos de horário por catequista nem criação de turmas pela interface; são melhorias futuras.

## Estrutura
`src/App.tsx`: portal e painel; `src/data.ts`: catálogo de 29 turmas; `src/style.css`: layout responsivo; `supabase/schema.sql`: tabelas, políticas de segurança, gatilhos e realtime.
