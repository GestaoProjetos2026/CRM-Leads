# Frontend do SalesWeakness (CRM Leads)

Este diretório contém a aplicação frontend do SalesWeakness — uma SPA em React + Vite + TypeScript usada para visualizar e interagir com leads, funil e métricas.

Resumo rápido
- Stack: React, Vite, TypeScript
- Localização: `src/` contém todo o código da aplicação
- Build: `npm run build` gera os assets estáticos preparados para servir (há `Dockerfile` e `nginx.conf` para deploy)

Pré-requisitos
- Node.js (recomenda-se v16+)
- npm (ou yarn/pnpm, mas os exemplos usam npm)

Instalação

Execute no PowerShell a partir da pasta `frontend`:

```powershell
git checkout <sua-branch>
npm install
```

Principais scripts (assumidos a partir do fluxo do projeto)
- npm run dev  — inicia o servidor Vite em modo de desenvolvimento
- npm run build — gera a build de produção em `dist/`
- npm run preview — (opcional) serve a build localmente para checar a produção

Se algum script não existir, use os scripts listados em `package.json`.

Estrutura do projeto (visão geral)

- `index.html` — ponto de entrada HTML usado pelo Vite
- `vite.config.ts` — configuração do Vite
- `.env` — variáveis de ambiente locais (não comitar credenciais)
- `Dockerfile`, `nginx.conf`, `deployment.yaml` — arquivos úteis para containerização e deploy

- `src/` — código fonte da aplicação
	- `main.tsx` — bootstrap da aplicação
	- `App.tsx` — layout / rotas principais
	- `MainLayout.tsx` — layout global (menu, header, rodapé)
	- `DashboardOverview.tsx`, `LeadsScreen.tsx`, `LoginScreen.tsx`, `RegisterScreen.tsx`, `SettingsPlaceholder.tsx` — telas principais
	- `pages/` — páginas específicas (por exemplo: `BottlenecksPage.tsx`, `FunnelPage.tsx`, `ConversionLatencyPage.tsx`)
	- `services/` — chamadas HTTP e lógica de integração (`api.ts`, `LeadService.ts`, `OpportunityService.ts`)
	- `services/mocks/mockData.ts` — dados mock usados em desenvolvimento/testes
	- `assets/` — imagens e logos (ex.: `logo.svg`)
	- `styles/` — CSS global e específicos (`index.css`, `incoming.css`)

Principais arquivos e responsabilidades
- `src/services/api.ts` — cliente HTTP (configura baseURL, interceptors, tokens)
- `src/services/LeadService.ts` — chamadas relacionadas a leads
- `src/services/OpportunityService.ts` — chamadas de oportunidades
- `src/pages/*` — páginas organizadas por feature

Variáveis de ambiente
- Use o arquivo `.env` para configurar valores como endpoints da API. Não versionar segredos.
- Exemplos (nomes ilustrativos — ver arquivo `.env` real):

```
VITE_API_BASE_URL=https://api.example.com
VITE_APP_ENV=development
```

Rodando em desenvolvimento

No PowerShell, dentro de `frontend`:

```powershell
npm install
npm run dev
```

Build para produção

```powershell
npm run build
# opcional: servir a build localmente para checar
npm run preview
```

Docker e deploy
- O `Dockerfile` no diretório gera uma imagem que serve a build compilada. O `nginx.conf` está pronto para servir os assets estáticos.
- `deployment.yaml` contém um exemplo Kubernetes para deployment (ver `backend/deployment.yaml` para integração com a API se necessário).

Dicas de desenvolvimento e arquitetura
- Organização por feature: prefira criar subpastas em `src/` para features maiores (ex.: `leads/`, `opportunities/`) contendo componentes, hooks e testes.
- Centralize chamadas HTTP em `src/services/` para facilitar mocking e testes.
- Use `src/services/mocks/mockData.ts` e técnicas de environment-specific config para trabalhar off-line.

Onde alterar o UI
- Componentes de página: `src/pages/` e `/src` (arquivos de tela)
- Componentes reutilizáveis: crie `src/components/` se ainda não houver uma pasta (boa prática)
- Estilos: `src/styles/` contém CSS global — prefira CSS Modules ou styled-components para escopo local se for necessário.

Observações e boas práticas
- Mantenha o `README.md` atualizado com scripts reais do `package.json` ao alterar os scripts.
- Não commit `.env` com segredos. Use variáveis de ambiente no CI/CD para builds em produção.

Próximos passos sugeridos
- Adicionar um `CONTRIBUTING.md` descrevendo convenções de branching e lint/format.
- Incluir testes unitários (Jest/React Testing Library) e um pequeno pipeline de CI para rodar build/lint/test.

Contato
Se precisar que eu adapte este README para incluir exemplos reais de `package.json` ou `.env`, envie esses arquivos e eu atualizo o README com comandos e scripts precisos.
