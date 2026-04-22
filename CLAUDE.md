# Carestone Salesforce

## Stack

Salesforce metadata project (Apex, Flow, Lightning Web Components, Aura, Visualforce). Source format via SFDX. No custom namespace.

## Branching

- Branch model: `dev` -> `main`
- Feature branches branch from `dev` and merge back to `dev`
- `main` is the production/deployment branch

## Key Directories

```
force-app/main/default/
  classes/          Apex classes (~350 files, ~140 are tests)
  triggers/         Apex triggers (22, one per SObject)
  lwc/              Lightning Web Components (58)
  aura/             Aura components (6)
  flows/            Platform flows (106)
  objects/          Custom and standard object metadata (72)
  pages/            Visualforce pages (92)
  staticresources/  Static resources (46)
  permissionsets/   Permission sets (30+)
```

- `manifest/` - package.xml and destructive change manifests
- `scripts/apex/` - Ad-hoc Apex scripts for development/debugging
- `config/` - Scratch org definition

## Architecture

### Trigger Pattern

Triggers are thin and named after their SObject (e.g. `Opportunity.trigger`). Each trigger calls `TriggerFactory.createHandler(SObject.getSObjectType())` which dispatches to a handler class implementing the `ITrigger` interface.

- Trigger: `Opportunity.trigger` -> `TriggerFactory` -> `OpportunityTriggerHandler` (implements `ITrigger`)
- Handler methods: `bulkBefore()`, `bulkAfter()`, `beforeInsert()`, `beforeUpdate()`, `afterInsert()`, `afterUpdate()`, `andFinally()`

Note: Some older triggers (like Opportunity) still contain inline business logic that predates the TriggerHandler pattern. New trigger logic should go into the TriggerHandler.

### Service Layer

Business logic belongs in Service classes (`XYZService.cls`). Services are called from TriggerHandlers and invocable actions.

Examples: `OpportunityService`, `ProvisionService`, `FinanzierungsanfrageService`, `AccountService`

### Invocable Actions

Flow-callable actions must be thin wrappers: one `@InvocableMethod` that delegates to a Service method. No business logic in the wrapper itself.

### Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Service | `XYZService` | `OpportunityService.cls` |
| Trigger Handler | `XYZTriggerHandler` | `OpportunityTriggerHandler.cls` |
| Trigger | SObject name | `Opportunity.trigger` |
| Controller | `XYZController` | `AccountController.cls` |
| Batch | `BatchXYZ` or `XYZBatch` | `BatchAccountUpdateChildAccounts.cls` |
| Schedulable | `XYZSchedulable` | `AccountActivitiesSummarySchedulable.cls` |
| Queueable | `XYZQueueable` | `CreateVisualforceFileQueueable.cls` |
| REST service | `RestXYZ` | `RestImmoframe.cls` |
| DTO | `XYZDTO` | `ProvisionPreviewDTO.cls` |
| Test | `XYZTest` | `OpportunityServiceTest.cls` |
| Test data | `TestDataFactory` | `TestDataFactory.cls` |

### Domain Language

Object and field names are predominantly German: Immobilie, Appartment, Berechnung, Finanzierungsanfrage, Gutschrift, Provision, Zahlung, MaBVRechnung, etc.

## Test Coverage Rules

Classify each class before writing tests:

- **Critical** (finance, commissions, integrations, number generators): exact hardcoded input/output assertions, boundary cases, failure paths. Examples: `ProvisionService`, `MaBVRechnungMasterUtil`, REST endpoints.
- **Standard** (general services, trigger handlers): happy path + at least one failure/edge case per method.
- **Light** (LWC/VF controllers, UI helpers): standard init test + one negative case.

When in doubt: if money moves or an external system is called, treat as Critical.

Use `TestDataFactory` for test data setup. Test classes use `@TestSetup` for shared data.

## Metadata

- `sourceApiVersion`: 59.0 for all new metadata
- `sfdx-project.json` currently lists 55.0 — new files should use 59.0
- No custom namespace

## Code Quality

- Prettier with Apex plugin for formatting
- ESLint for LWC/Aura JavaScript
- Husky pre-commit hooks enforce formatting
- LWC Jest for component-level JavaScript tests
