-- Execute no SQL Editor do Supabase (projeto novo).
create extension if not exists pgcrypto;
create table public.perfis (
 id uuid primary key references auth.users(id) on delete cascade,
 nome text not null default '', email text not null default '', telefone text not null default '',
 data_nascimento date, comunidade text not null default '', endereco text not null default '',
 experiencia text not null default '', observacoes text not null default '',
 updated_at timestamptz not null default now()
);
create table public.administradores (user_id uuid primary key references auth.users(id) on delete cascade);
create table public.turmas (
 id text primary key, ano integer not null default 2027, dia text not null,
 horario text not null, etapa text not null, vagas integer not null default 1 check(vagas>=1),
 unique(ano,dia,horario,etapa)
);
create table public.formacoes (
 id uuid primary key default gen_random_uuid(),
 catequista_id uuid not null references public.perfis(id) on delete cascade,
 curso text not null check(length(trim(curso))>0), instituicao text not null default '',
 ano integer check(ano between 1900 and 2100)
);
create table public.escolhas (
 catequista_id uuid not null references public.perfis(id) on delete cascade,
 turma_id text not null references public.turmas(id) on delete cascade,
 prioridade integer not null check(prioridade between 1 and 3),
 primary key(catequista_id,turma_id),unique(catequista_id,prioridade)
);
create table public.alocacoes (
 turma_id text not null references public.turmas(id),
 catequista_id uuid not null references public.perfis(id),
 status text not null default 'confirmado' check(status='confirmado'),
 criado_em timestamptz not null default now(),
 primary key(turma_id,catequista_id)
);
create index idx_escolhas_turma on public.escolhas(turma_id);
create index idx_alocacoes_turma on public.alocacoes(turma_id);
-- Administrador é definido exclusivamente pelo responsável pelo banco.
create or replace function public.eh_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.administradores where user_id=(select auth.uid()));
$$;
revoke all on function public.eh_admin() from public;
grant execute on function public.eh_admin() to authenticated;

create or replace function public.criar_perfil_usuario() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.perfis(id,email,nome) values(new.id,coalesce(new.email,''),coalesce(new.raw_user_meta_data->>'nome','')) on conflict(id) do nothing;
 return new;
end;
$$;
create trigger tr_criar_perfil after insert on auth.users for each row execute function public.criar_perfil_usuario();

create or replace function public.touch_perfil() returns trigger language plpgsql as $$begin new.updated_at=now();return new;end;$$;
create trigger tr_touch_perfil before update on public.perfis for each row execute function public.touch_perfil();

-- Operação atômica: substitui até três escolhas do próprio catequista.
create or replace function public.definir_escolhas(p_turmas text[]) returns void
language plpgsql security definer set search_path=public as $$
declare v_count integer;
begin
 if auth.uid() is null then raise exception 'Acesso não autorizado';end if;
 v_count:=coalesce(array_length(p_turmas,1),0);
 if v_count>3 then raise exception 'Máximo de três escolhas';end if;
 if (select count(distinct x) from unnest(coalesce(p_turmas,array[]::text[])) as x)<>v_count then raise exception 'Não repita turmas';end if;
 if exists(select 1 from unnest(coalesce(p_turmas,array[]::text[])) as x left join public.turmas t on t.id=x and t.ano=2027 where t.id is null) then raise exception 'Turma inválida';end if;
 perform 1 from public.perfis where id=auth.uid() for update;
 delete from public.escolhas where catequista_id=auth.uid();
 insert into public.escolhas(catequista_id,turma_id,prioridade)
 select auth.uid(),x,ord::integer from unnest(coalesce(p_turmas,array[]::text[])) with ordinality as v(x,ord);
end;
$$;
revoke all on function public.definir_escolhas(text[]) from public;
grant execute on function public.definir_escolhas(text[]) to authenticated;

-- Verificação transacional de vagas e interesse, serializada por turma.
create or replace function public.validar_alocacao() returns trigger language plpgsql security definer set search_path=public as $$
declare limite integer;ocupadas integer;
begin
 if not public.eh_admin() then raise exception 'Somente coordenação';end if;
 select vagas into limite from public.turmas where id=new.turma_id for update;
 if not found then raise exception 'Turma inexistente';end if;
 if not exists(select 1 from public.escolhas where turma_id=new.turma_id and catequista_id=new.catequista_id) then raise exception 'Catequista não escolheu esta turma';end if;
 select count(*) into ocupadas from public.alocacoes where turma_id=new.turma_id;
 if ocupadas>=limite then raise exception 'Turma sem vaga';end if;
 return new;
end;
$$;
create trigger tr_validar_alocacao before insert on public.alocacoes for each row execute function public.validar_alocacao();

alter table public.perfis enable row level security;
alter table public.formacoes enable row level security;
alter table public.escolhas enable row level security;
alter table public.alocacoes enable row level security;
alter table public.turmas enable row level security;
alter table public.administradores enable row level security;
create policy perfis_ler on public.perfis for select to authenticated using (id=(select auth.uid()) or public.eh_admin());
create policy perfis_inserir on public.perfis for insert to authenticated with check(id=(select auth.uid()));
create policy perfis_editar on public.perfis for update to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()));
create policy formacoes_ler on public.formacoes for select to authenticated using(catequista_id=(select auth.uid()) or public.eh_admin());
create policy formacoes_inserir on public.formacoes for insert to authenticated with check(catequista_id=(select auth.uid()));
create policy formacoes_apagar on public.formacoes for delete to authenticated using(catequista_id=(select auth.uid()));
create policy escolhas_ler on public.escolhas for select to authenticated using(catequista_id=(select auth.uid()) or public.eh_admin());
-- Escolhas só podem ser escritas pela função transacional.
create policy alocacoes_ler on public.alocacoes for select to authenticated using(catequista_id=(select auth.uid()) or public.eh_admin());
create policy alocacoes_inserir on public.alocacoes for insert to authenticated with check(public.eh_admin());
create policy alocacoes_apagar on public.alocacoes for delete to authenticated using(public.eh_admin());
create policy turmas_ler on public.turmas for select to authenticated using(true);
create policy administradores_ler on public.administradores for select to authenticated using(user_id=(select auth.uid()));
-- Realtime: publique apenas tabelas necessárias; RLS limita o que cada pessoa pode ler.
alter publication supabase_realtime add table public.perfis;
alter publication supabase_realtime add table public.escolhas;
alter publication supabase_realtime add table public.alocacoes;
insert into public.turmas(id,dia,horario,etapa) values
('t01','Terça-feira','14h','1ª Etapa'),('t02','Terça-feira','14h','2ª Etapa'),('t03','Terça-feira','14h','3ª Etapa'),('t04','Terça-feira','14h','4ª Etapa'),('t05','Terça-feira','14h','5ª Etapa'),
('t06','Terça-feira','19h','1ª Etapa'),('t07','Terça-feira','19h','2ª Etapa'),('t08','Terça-feira','19h','3ª Etapa'),('t09','Terça-feira','19h','4ª Etapa'),('t10','Terça-feira','19h','5ª Etapa'),
('t11','Quarta-feira','19h','1ª Etapa'),('t12','Quarta-feira','19h','2ª Etapa'),('t13','Quarta-feira','19h','3ª Etapa'),('t14','Quarta-feira','19h','4ª Etapa'),('t15','Quarta-feira','19h','5ª Etapa'),('t16','Quarta-feira','19h','Catequese de Adultos'),
('t17','Sábado','8h','1ª Etapa'),('t18','Sábado','8h','2ª Etapa'),('t19','Sábado','8h','3ª Etapa'),('t20','Sábado','8h','4ª Etapa'),('t21','Sábado','8h','5ª Etapa'),
('t22','Sábado','10h','3ª Etapa'),('t23','Sábado','10h','4ª Etapa'),('t24','Sábado','10h','5ª Etapa'),('t25','Sábado','10h','1ª Etapa Específica'),('t26','Sábado','10h','2ª Etapa Específica'),('t27','Sábado','10h','3ª Etapa Específica'),
('t28','Sábado','14h','Preparação Próxima para Crisma'),('t29','Domingo','19h','Catequese de Adultos')
on conflict(id) do nothing;
