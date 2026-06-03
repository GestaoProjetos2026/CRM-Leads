# Módulo SalesWeakness (CRM-leads) - P2

## Visão Geral

Este módulo aprensenta toda entrada de leads e a forma como eles estão tendo contato com a empresa, mostra a visão geral de quanto dinheiro está sendo investido e onde está sendo usado com ajuda do módulo Fiscal.

## Diagrama de Arquitetura

```
┌──────────────────────────────────────────────────────────────────────┐
│                      CLIENTES (Frontend Web)                         │
│   Diretor Comercial | Gestor de Marketing | SDR / Vendedor           │
│   /dashboard/director | /dashboard/marketing | /dashboard/sales-rep  │
└────────────────────────────┬─────────────────────────────────────────┘
                             │ HTTPS / WebSocket
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         API GATEWAY                                  │
│     Validação JWT | Injeção de tenant_id | Rate Limiting             │
│     Roteamento para serviços de negócio                              │
└──────┬──────────────────────┬──────────────────────┬─────────────────┘
       │                      │                      │
       ▼                      ▼                      ▼
┌─────────────┐  ┌────────────────────────┐  ┌──────────────────────┐
│  Serviço    │  │  Serviço de Analytics  │  │  Serviço de          │
│  de CRM     │  │  (Funil / Auditoria)   │  │  Automação (Réguas)  │
│             │  │                        │  │                      │
│ PATCH deals │  │ GET /funnel/audit      │  │ Gestão de réguas     │
│ POST ingest │  │ Cache Redis (P95<300ms)│  │ Disparo WhatsApp/Mail│
│ Kanban API  │  │ CTEs + Agregados       │  │ Retry Logic          │
└──────┬──────┘  └───────────┬────────────┘  └──────────┬───────────┘
       │                     │                          │
       └─────────────────────┼──────────────────────────┘
                             │
       ┌─────────────────────▼───────────────────────────┐
       │                 CAMADA DE DADOS                 │
       │                                                 │
       │  PostgreSQL (RLS ativo) │ Redis (Cache/Filas)   │
       │  Isolamento por tenant  │ TTL configurável      │
       └────────────────────────┬────────────────────────┘
                                │
       ┌────────────────────────▼────────────────────────┐
       │          PROCESSAMENTO EM BACKGROUND            │
       │                                                 │
       │  Worker: Detecção de Estagnação 48h (Cron)      │
       │  Worker: Marcação de Inatividade 180d (Cron)    │
       │  Worker: Consumidor de Fila (Webhooks/Automação)│
       └────────────────────────┬────────────────────────┘
                                │
       ┌────────────────────────▼────────────────────────┐
       │           MESSAGE QUEUE (RabbitMQ / SQS)        │
       │                                                 │
       │  Fila: lead.stagnated                           │
       │  Fila: lead.inactive                            │
       │  Fila: campaign.low_conversion                  │
       │  Fila: outbound.email                           │
       │  Fila: outbound.whatsapp                        │
       └─────────────────────────────────────────────────┘
```

## Pré-requisitos

Para rodar o módulo sem erros a máquina host precisa dos seguinter softwares

- Docker
- Docker Compose
- Node 24.16.0 (LTS)
- Postgres (Com usuário e senha configurado no .env do backend)
- Redis

## Guia de Variáveis de Ambiente:

### Backend

```env
# ─── Application ───────────────────────────────────────────────────────────────
NODE_ENV=production
PORT=3031
APP_NAME=SalesWeakness

# ─── Database (PostgreSQL) ──────────────────────────────────────────────────────
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sales_weakness
DB_USER=salesweakness
DB_PASSWORD=salesweakness
# For TypeORM synchronize — NEVER use true in production
DB_SYNCHRONIZE=false

# ─── Redis ─────────────────────────────────────────────────────────────────────
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_USER=redis_sales_weakness
REDIS_PASSWORD=9dae3874790746cc3306920234d88ede517cdef6c5376fc50bbbfe86bee9a0a7

# Analytics cache TTL in seconds (default: 300 = 5 minutes)
CACHE_TTL_SECONDS=300

# ─── Auth (JWT) ─────────────────────────────────────────────────────────────────
JWT_SECRET=28e43872e0ad1a8e385b183897e2168e83234e8150b34b6c336ac1f31db64529
JWT_EXPIRES_IN=1h
CORE_ENGINE_URL=https://api.core-engine.40.82.176.176.nip.io

# ─── Rate Limiting ──────────────────────────────────────────────────────────────
THROTTLE_TTL_SECONDS=60
THROTTLE_LIMIT=100

# ─── Fiscal API (Squad 2 — Finance-Fiscal) ─────────────────────────────────────
FISCAL_API_BASE_URL=https://api.fiscal-finance.40.82.176.176.nip.io
FISCAL_API_USER=admin
FISCAL_API_PASSWORD=admin123
FISCAL_API_TIMEOUT_MS=5000

# ─── Core Engine API ─────────────────────────────────────
CORE_ENGINE_URL=https://api.core-engine.40.82.176.176.nip.io
```

## Step-by-Step de Execução

```bash
# Clonando repositório
$ git clone https://github.com/GestaoProjetos2026/crm-leads

# Entrando no projeto
$ cd crm-leads

# Executando o projeto usando docker
$ docker-compose up -d

# Executando o projeto como dev
$ cd frontend
$ npm i --legacy-peer-deps
$ npm run dev
$ cd ../backend
$ npm i --legacy-peer-deps
$ npm run start
```

## Documentação da API

https://api.crm-leads.40.82.176.176.nip.io/api/docs

## Troubleshooting

- Caso tenha algum erro no banco, crie um novo usuário no seu postgres e atualize o .env do backend
- Caso o banco não ache, mude no backend\src\config\database.config.ts o host do banco.
- Caso o docker-entrypoint.sh não seja executado no banco, faça o migrate direto na aplicação do backend, usando o comando `npm run migration:run` e delete a linha 31 e 48 do docker file do backend.
