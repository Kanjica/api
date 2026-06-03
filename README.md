# Mobilidade Periférica API — Guia de Execução

## Estrutura do projeto

```
projeto/
├── main.py                  # ponto de entrada
├── requirements.txt
├── .env                     # credenciais (não commitar)
├── app/
│   ├── config.py            # lê variáveis do .env
│   ├── database.py          # pool de conexões + startup SQL
│   ├── schemas.py           # modelos Pydantic
│   └── routers/
│       ├── operacional.py   # POST /viagens, /gps, /lotacao
│       └── analitico.py     # GET  /analise/*
└── sql/
    ├── 00_dcl.sql           # usuários e permissões  ← roda PRIMEIRO, como root
    ├── 01_create_tables.sql
    ├── 02_triggers.sql
    ├── 03_functions.sql
    └── 04_views.sql         # os 4 acima rodam automático no startup da API
```

---

## Passo 1 — Instalar dependências

```bash
pip install -r requirements.txt
```

---

## Passo 2 — Criar o arquivo .env

Copie o exemplo e preencha com suas senhas reais:

```bash
cp .env.example .env
```

Conteúdo do `.env`:

```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=mydb

DB_ADMIN_USER=admin_mobilidade
DB_ADMIN_PASS=senha_do_admin

DB_USER=fiscal_operacional
DB_PASS=senha_fiscal_segura
```

---

## Passo 3 — Executar o DCL (único script manual)

O `05_dcl.sql` cria os usuários e concede permissões.
Ele precisa rodar **uma única vez**, antes de tudo, com um usuário que tenha
privilégios de administrador (normalmente `root`).

### Pelo terminal MySQL:

```bash
mysql -u root -p mydb < sql/05_dcl.sql
```

### Pelo MySQL Workbench:

1. Abra o Workbench e conecte com o usuário `root`
2. Vá em **File → Open SQL Script** e selecione `sql/05_dcl.sql`
3. Clique em **Execute** (raio) ou pressione `Ctrl+Shift+Enter`

> Após esse passo os usuários `admin_mobilidade`, `fiscal_operacional` e
> `analista_planejamento` já existem no banco.

---

## Passo 4 — Subir a API

```bash
uvicorn main:app --reload
```

Na inicialização o servidor executa automaticamente, nesta ordem:

| Ordem | Script                  | O que faz                              |
|-------|-------------------------|----------------------------------------|
| 1     | `01_create_tables.sql`  | Cria tabelas, índices e auditoria      |
| 2     | `02_triggers.sql`       | Cria os 6 triggers (validação + audit) |
| 3     | `03_functions.sql`      | Cria fn_percentual_ocupacao e fn_atraso_medio_rota |
| 4     | `04_views.sql`          | Cria as 3 views gerenciais             |
| 6     | `06_inserts.sql`        | Insere dados para teste

Se qualquer script falhar, a API **não sobe** — você verá o erro no terminal
antes de qualquer endpoint ficar disponível.

---

## Passo 5 — Testar

Acesse a documentação interativa gerada automaticamente pelo FastAPI:

```
http://localhost:8000/docs
```

Endpoints disponíveis:

| Método | Rota                          | Descrição                        |
|--------|-------------------------------|----------------------------------|
| POST   | `/api/v1/viagens`             | Inicia uma viagem                |
| POST   | `/api/v1/telemetria/gps`      | Registra posição GPS             |
| POST   | `/api/v1/operacao/lotacao`    | Registra lotação de passageiros  |
| GET    | `/api/v1/analise/deficit-bairros` | Relatório de infraestrutura  |
| GET    | `/api/v1/analise/pontualidade`    | Relatório de atrasos         |

---

## Observações

- Os scripts `01` a `04` usam `CREATE ... IF NOT EXISTS` e `DROP ... IF EXISTS`,
  então são idempotentes — podem rodar múltiplas vezes sem erro.
- O `05_dcl.sql` também usa `CREATE USER IF NOT EXISTS`, então é seguro
  rodar novamente caso precise recriar permissões.
- Em produção, remova o `--reload` do uvicorn e defina um número fixo de workers:
  ```bash
  uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
  ```
EOF
