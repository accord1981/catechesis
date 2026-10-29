export type Turma={id:string;dia:string;horario:string;etapa:string;ano:number;vagas:number};
export type Escolha={turma_id:string;prioridade:number};
export type Perfil={id:string;nome:string;email:string;telefone:string;data_nascimento:string|null;comunidade:string;endereco:string;experiencia:string;observacoes:string;updated_at?:string};
export type Formacao={id:string;catequista_id:string;curso:string;instituicao:string;ano:number|null};
export type Alocacao={turma_id:string;catequista_id:string;status:string};
const grupos:[string,string,string[]][]=[
 ['Terça-feira','14h',['1ª Etapa','2ª Etapa','3ª Etapa','4ª Etapa','5ª Etapa']],
 ['Terça-feira','19h',['1ª Etapa','2ª Etapa','3ª Etapa','4ª Etapa','5ª Etapa']],
 ['Quarta-feira','19h',['1ª Etapa','2ª Etapa','3ª Etapa','4ª Etapa','5ª Etapa','Catequese de Adultos']],
 ['Sábado','8h',['1ª Etapa','2ª Etapa','3ª Etapa','4ª Etapa','5ª Etapa']],
 ['Sábado','10h',['3ª Etapa','4ª Etapa','5ª Etapa','1ª Etapa Específica','2ª Etapa Específica','3ª Etapa Específica']],
 ['Sábado','14h',['Preparação Próxima para Crisma']],
 ['Domingo','19h',['Catequese de Adultos']]
];
export const turmas:Turma[]=[];
let i=0;
for(const [dia,horario,etapas] of grupos)for(const etapa of etapas){i++;turmas.push({id:`t${String(i).padStart(2,'0')}`,dia,horario,etapa,ano:2027,vagas:1});}
export const nomeTurma=(t:Turma)=>`${t.dia} • ${t.horario} • ${t.etapa}`;
