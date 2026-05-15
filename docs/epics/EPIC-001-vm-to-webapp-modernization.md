# EPIC-001 — VM-to-WebApp Modernization

> **Owner:** Morgan (PM) · **Status:** 🟢 **ACTIVE** · **Created:** 2026-05-07 · **Parked:** 2026-05-07 · **Activated:** 2026-05-15
> **Target event:** TFTEC "Copa do Mundo Azure"
> **Estimated total duration:** ~3h (workshop time)
>
> ✅ **ACTIVATED 2026-05-15:** pré-requisito atendido — EPIC-000 done + Story 0.10 (consolidação lote 05-08) fechada com QA gate 10/10 PASS.
>
> 📌 **Pré-dry-run (owner-owned, FORA do escopo do agente — decisão owner 2026-05-15):** o `FIFA2026Tickets.bacpac` (12 KB, 2026-05-07) está desatualizado vs o app live (104 jogos, preços FIFA, seed 100k — aplicados via migrations SQL em 2026-05-08, não no bacpac). **O owner regenera o bacpac manualmente no final**, à mão; não é ação de agente, não é blocker para o trabalho documental. As stories 1.x já estão ajustadas (contagens corrigidas via @po audit). Verificação do login `admin@fifa2026.com` (D2) também é owner-owned (precisa acesso ao DB). Runbook de regeneração disponível em [docs/qa/2026-05-15-po-validation-EPIC-001.md](../qa/2026-05-15-po-validation-EPIC-001.md).

---

## Motivação

A aplicação **FIFA 2026 Tickets** é o sistema-piloto do evento "Copa do Mundo Azure" da TFTEC. O evento é didático: o aluno experimenta a **jornada de modernização** de uma aplicação real, partindo de um deploy tradicional em VMs e chegando em uma arquitetura PaaS no Azure.

A jornada **é** o produto. Cada story é uma "lição" autônoma com pré-requisito, passo-a-passo e validação.

## Escopo (in scope)

- 4 stories cobrindo **o caminho crítico** da modernização VM → PaaS
- Estado inicial: aplicação rodando em **3 VMs** (VM-Front pública, VM-Back privada, VM-DB privada)
- Estado final: aplicação rodando 100% em **Azure PaaS** (Web App público + Web App privado + Azure SQL Database)
- Cada story tem critério de validação e pode parar ali (estados intermediários funcionais)

## Fora de escopo (out of scope)

Reservado para epic posterior — não cabe em ~3h:
- Application Insights / Log Analytics (observability)
- Endurecimento avançado (Access Restriction com IPs do front)
- VNet Integration + Private Endpoints
- Migração de secrets para Azure Key Vault
- Managed Identity
- CI/CD via GitHub Actions com OIDC

> Os artefatos para essas stories **já existem no repo** (workflows, IaC pronto), apenas a "lição" não foi roteirizada para este evento.

## Success criteria

| # | Critério | Verificação |
|---|---|---|
| SC-1 | Aluno consegue executar 100% das 4 stories no tempo do evento | Cronômetro durante dry-run |
| SC-2 | App permanece **funcional** ao final de cada story (sem estados quebrados) | Smoke test: login + listar jogos + comprar ingresso |
| SC-3 | Aluno entende a diferença entre os estados | Pergunta de fixação ao final de cada story |
| SC-4 | Custo total da subscription do aluno < $30 durante o evento | B1 + Basic SQL = ~$18/mês prorated |

## Stories

| # | ID | Título | Estimativa | Estado inicial → final |
|---|---|---|---|---|
| S1 | 1.1 | Deploy inicial em 3 VMs | 45 min | Nada → 3 VMs (front pública, back+db privadas) |
| S2 | 1.2 | Migrar Backend para Azure Web App | 30 min | Backend em VM → Backend em `fifa2026-back` (Web App) |
| S3 | 1.3 | Migrar Frontend para Azure Web App | 30 min | Frontend em VM → Frontend em `fifa2026-web` (Web App) |
| S4 | 1.4 | Migrar SQL Server (VM) para Azure SQL Database | 45 min | DB em VM → Azure SQL com bacpac importado |

**Total:** ~2h30 técnico + ~30min de explicação/transição = ~3h

## Dependências entre stories

```
S1 (3 VMs)
   └─> S2 (Back -> WebApp)        # frontend ainda em VM, back já em PaaS
        └─> S3 (Front -> WebApp)  # ambos em PaaS, DB ainda em VM
             └─> S4 (DB -> Azure SQL)  # tudo em PaaS
```

**Princípio:** cada story remove **uma** VM. No final da S4, as 3 VMs originais podem ser desligadas e o app continua rodando.

## Artefatos pré-existentes que cada story alavanca

| Story | Artefatos que reusa |
|---|---|
| S1 | `Lovable/.../DEPLOY_IIS_SIMPLIFICADO.md` (passo IIS), `fifa2026-api/.env.example`, `FIFA2026Tickets.bacpac`, `fifa2026-api/database/schema.sql` |
| S2 | `infra/main.bicep` (módulo `web-app-backend`), `infra/provision.sh`, `.github/workflows/deploy-backend.yml` |
| S3 | `infra/main.bicep` (módulo `web-app-frontend`), `Lovable/.../scripts/set-backend-url.mjs`, `.github/workflows/deploy-frontend.yml` |
| S4 | `infra/modules/sql-database.bicep`, README do `infra/` (passo de import bacpac) |

## Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Aluno trava na S1 (instalação de IIS/iisnode/ARR) | Alta | Bloqueia todo o evento | Disponibilizar VM pré-configurada via ARM template/golden image |
| Cota Azure do aluno insuficiente | Média | Aluno fica sem subscription | Pre-flight check no início do evento; ter subscription compartilhada de backup |
| Bacpac falha de importar (firewall/IP) | Média | Trava S4 | Pré-passos validados: liberar AllowAllAzureServices ANTES do import |
| Tempo estourar | Alta | Stories incompletas | Cada story é independente — aluno pode parar ali; instrutor decide quais fazer ao vivo |

## Próximos passos (PM → SM)

1. ✅ Epic criado em `docs/epics/EPIC-001-vm-to-webapp-modernization.md`
2. ➡️ **@sm (River)** drafta as 4 stories em `docs/stories/1.{1,2,3,4}.story.md` usando `story-tmpl.yaml`
3. Cada story deve ter:
   - **Status:** Draft
   - **Story (As a / I want / So that):** redigida do ponto de vista do **aluno do evento**
   - **Acceptance Criteria:** 5–8 critérios verificáveis
   - **Tasks/Subtasks:** passo-a-passo executável
   - **Dev Notes:** referências aos artefatos pré-existentes (não reinventar)
   - **Validation:** smoke test específico daquela story
4. Após drafting, **@po (Pax)** valida cada story no checklist de 10 pontos
5. **@dev** implementa só se algo do app precisar mudar (não esperado — o app já está pronto, só falta os roteiros das stories)

## Stakeholders

- **Owner do evento:** Raphael Andrade (rapha.rss@gmail.com)
- **Audiência:** alunos da TFTEC (pós-graduação)
- **Squad:** @pm (Morgan) → @sm (River) → @po (Pax) → @dev (Dex) — quando aplicável
