# Skill Registry - TodoAlDía

## Project Skills
Ninguna skill de proyecto definida aún.

## SDD Skills (Global)
| Skill | Ubicación | Descripción |
|-------|-----------|-------------|
| sdd-init | ~/.config/opencode/skills/sdd-init/SKILL.md | Inicializar contexto SDD |
| sdd-explore | ~/.config/opencode/skills/sdd-explore/SKILL.md | Explorar e investigar ideas |
| sdd-propose | ~/.config/opencode/skills/sdd-propose/SKILL.md | Crear propuesta de cambio |
| sdd-spec | ~/.config/opencode/skills/sdd-spec/SKILL.md | Escribir especificaciones |
| sdd-design | ~/.config/opencode/skills/sdd-design/SKILL.md | Diseño técnico |
| sdd-tasks | ~/.config/opencode/skills/sdd-tasks/SKILL.md | Desglose en tareas |
| sdd-apply | ~/.config/opencode/skills/sdd-apply/SKILL.md | Implementar tareas |
| sdd-verify | ~/.config/opencode/skills/sdd-verify/SKILL.md | Validar implementación |
| sdd-archive | ~/.config/opencode/skills/sdd-archive/SKILL.md | Archivar cambio completado |

## Other Skills
| Skill | Ubicación | Descripción |
|-------|-----------|-------------|
| go-testing | ~/.config/opencode/skills/go-testing/SKILL.md | Testing patterns para Go |
| skill-creator | ~/.config/opencode/skills/skill-creator/SKILL.md | Crear nuevas skills |

## Convenciones del Proyecto
- Archivo: AGENTS.md (raíz del proyecto)
- Stack: Flutter/Dart (SDK ^3.0.0)
- Arquitectura: Clean Architecture (lógica de negocio en servicios/repositorios)
- Null-safety: Obligatorio

## Tech Stack Detectado
- **State**: flutter_bloc ^8.1.3, equatable ^2.0.5
- **Navigation**: go_router ^13.0.0
- **Database**: Hive ^2.2.3 + hive_flutter ^1.1.0
- **Voice**: speech_to_text ^7.0.0
- **Charts**: fl_chart ^0.66.0
- **Testing**: mocktail ^1.0.1, patrol ^4.3.0

## SDD Mode

**Current Mode**: engram (persistent memory)

All SDD artifacts are persisted to Engram for cross-session recovery.