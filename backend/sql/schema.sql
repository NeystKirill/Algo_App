create table if not exists algorithms (
  id text primary key,
  title text not null,
  category text not null,
  difficulty text not null,
  theory text not null,
  time_complexity text not null,
  space_complexity text not null,
  visualization_kind text not null,
  code_samples jsonb not null
);
