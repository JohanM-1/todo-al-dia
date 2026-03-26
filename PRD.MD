# PRD: TodoAlDía — App de Gestión de Dinero

> **Claridad financiera en segundos. Control sin fricción. Progreso visible.**

**Versión**: 0.1.0-draft  
**Autor**: (tu equipo)  
**Fecha**: 2026-03-17  
**Estado**: Draft

---

## 1. Problema

La mayoría de personas no necesita “contabilidad”, necesita **claridad** y **control** sin esfuerzo.

Hoy el usuario suele enfrentar:
- Registro manual tedioso (termina abandonando).
- Poca visibilidad (no sabe “cuánto tengo” ni “en qué se fue”).
- Falta de planificación (presupuestos/metas poco accionables).
- Herramientas complejas o saturadas (mala UX).
- Desconfianza (seguridad/privacidad).
- Continuidad rota entre dispositivos (sincronización).

**Oportunidad:** una app multiplataforma (Flutter) que reduzca fricción, automatice lo repetitivo y convierta datos en decisiones.

---

## 2. Visión

Ser la app financiera personal que:
- Muestra el estado del dinero en **≤ 5 segundos**.
- Permite registrar un gasto en **≤ 10 segundos**.
- Automatiza categorización y genera insights sin “hacerte trabajar”.
- Funciona en móvil, web y escritorio con datos sincronizados.
- Prioriza privacidad y control del usuario (modo manual sin bancos).

**Tagline (provisional):** “Organizá tu dinero. Sin fricción.”

### 2.1 Experiencia central: Voz-first
La interacción principal con la app es por voz, como si el usuario le contara a alguien lo que gastó y la app:
1. Transcribe.
2. Interpreta intención y extrae datos (monto, moneda, comercio, categoría, método, fecha).
3. Propone etiquetas/categorías y resumen.
4. Pide confirmación.
5. Permite corregir por voz y deja el registro limpio.

El usuario también puede preguntar por voz sobre sus datos y recibir respuestas claras, con opción de profundizar.

---

## 3. Usuarios Objetivo

### Primarios
- Personas que quieren ordenar gastos y ahorrar (nivel “no experto”).
- Usuarios con ingresos fijos y variables que buscan control mensual.

### Secundarios
- Freelancers que quieren separar personal vs trabajo.
- Parejas/familias que desean gastos compartidos.
- Usuarios multi-moneda o que viajan.

---

## 4. Plataformas Soportadas (Flutter)

| Plataforma | Soporte | Prioridad |
|----------|---------|----------|
| Android | Sí | P0 |
| Web | Sí | P0 |
| iOS | Sí | P1 |
| macOS | Sí | P2 |
| Windows | Sí | P2 |
| Linux | Sí | P2 |

**Nota:** El MVP se lanza primero en Android + Web (offline-first), con CI generando APK y build web. El resto de plataformas se habilitan después.

---

## 5. Arquitectura Técnica (Flutter + Convex)

### 5.1 Monorepo
- La app Flutter y el backend de Convex viven en el mismo repo para simplificar desarrollo, deploy y versionado.
- Convex se usa para datos en tiempo real (queries/mutations/actions) y sincronización multi-dispositivo a partir de V1.

### 5.2 Enfoque por fases
- MVP: offline-first local para iterar rápido y validar UX/retención.
- V1: habilitar Convex Auth (Google) + sync en tiempo real + agentes.

### 5.2.1 Voz-first (arquitectura lógica)
- Captura: push-to-talk y/o modo conversación (configurable).
- Transcripción: motor de speech-to-text (preferencia on-device en MVP cuando aplique).
- Interpretación: parser por intents + extracción de slots en MVP; agente en V1.
- Confirmación: pantalla ligera con el “resumen entendido” y acciones por voz.
- Observabilidad: registrar métricas de “entendido vs corregido” sin almacenar audio por defecto.

### 5.2.2 IA offline-first (MVP) y cloud (V1)
La IA es parte del core: sin interpretación y etiquetado, la experiencia voz-first no cumple el objetivo. Por eso el MVP requiere capacidades de IA local para funcionar sin internet.

**Capas de IA:**
- STT (speech-to-text): transcripción en el dispositivo.
- NLU/Intent parsing: detección de intent + extracción de slots (monto, fecha, comercio, método, categoría).
- Etiquetado/categorización: propuesta de categoría/etiquetas con confianza.
- Respuesta a consultas: generación de respuesta basada en datos (con preferencia por respuesta determinista + explicación).

**Estrategia MVP (offline-first):**
- Priorizar IA local para STT y NLU básico.
- El sistema debe funcionar en “modo sin modelo” solo como degradación excepcional, forzando formularios y desactivando voz-first.
- Distribución de modelos: bundle mínimo o descarga de un “paquete offline” durante onboarding si hay Wi-Fi, con control de tamaño y almacenamiento.

**Estrategia V1 (Convex):**
- Convex Agent para etiquetado, insights y multi-turn más robusto.
- Para tareas generativas se usa un proveedor externo vía API (OpenAI con un modelo tipo “ChatGPT mini”) integrado desde Convex (actions/agent).
- OCR no se ejecuta en cloud.
- La app debe permitir optar por:
  - Solo IA local (sin cloud).
  - IA cloud para mejorar precisión/fluidez.

**Compatibilidad por plataforma (IA local):**
- Android/iOS: soporte completo (objetivo).
- Desktop: soporte objetivo, sujeto a disponibilidad de runtime local.
- Web: soporte limitado; si el navegador no soporta IA local, se debe degradar a formularios y/o dictado si está disponible.

### 5.3 Modos de datos
- Invitado: datos locales en el dispositivo (offline-first).
- Google (V1): datos en Convex con sincronización en tiempo real entre dispositivos.
- Migración (V1): si el usuario está en modo invitado y luego inicia sesión con Google, la app importa y fusiona el historial local a Convex sin pérdida silenciosa.

### 5.3.1 Fusión invitado→Google (mismo esquema)
La app usa el mismo modelo lógico de datos en local y en Convex. En modo invitado, las entidades existen localmente con los mismos campos; al loguearse en V1 se sincronizan asignando ownership al usuario.

**Reglas de fusión:**
- Cada registro local tiene un `id` estable (UUID) generado al crear, para permitir upserts idempotentes.
- Migración sube registros locales a Convex con upsert por `id`.
- Ownership: al persistir en Convex se asigna `userId` (y/o `spaceId` cuando exista).
- Deduplicación adicional: si existen registros distintos pero potencialmente duplicados, se detectan por heurística (mismo monto, moneda, fecha aproximada, comercio y método) y se marcan para revisión.
- Conflictos: si un `id` existe en Convex con contenido distinto, se guarda la versión nueva como “pendiente de revisión” y la app solicita confirmación del usuario.

**Requisitos:**
- R-MIG-01: El esquema lógico local y el de Convex comparten los mismos campos principales.
- R-MIG-02: La migración es idempotente (reintentos no duplican registros).
- R-MIG-03: La deduplicación nunca borra; solo marca y propone fusionar.
- R-MIG-04: Los conflictos requieren decisión del usuario antes de consolidar.

### 5.4 Autenticación (Convex Auth) (V1)
- Login exclusivo con Google.
- No se soporta email/contraseña.

### 5.5 Agentes (Convex Agent) (V1)
- Etiquetado y categorización automática de compras y comercios.
- Sugerencias explicables y editables por el usuario, con opción de aceptar/rechazar.
- Ejecución por evento: al crear/editar movimientos, el agente propone etiquetas/categorías y genera insights.

**Requisitos:**
- R-PHASE-01: El MVP funciona 100% offline sin backend requerido.
- R-AI-LOCAL-01: El MVP incluye IA local para transcripción y detección de intents.
- R-AI-LOCAL-02: El etiquetado/categorización en MVP funciona offline con salida de “confianza”.
- R-AI-LOCAL-03: Si la confianza es baja, se requiere confirmación explícita y/o pregunta dirigida.
- R-AI-LOCAL-04: El usuario puede descargar/gestionar el paquete offline de modelos.
- R-AUTH-01: El único login soportado es Google (Convex Auth) en V1.
- R-AUTH-02: El modo invitado funciona 100% sin conexión.
- R-AUTH-03: Al loguearse (V1), el usuario puede migrar y fusionar datos locales a Convex.
- R-ARCH-01: El backend Convex se mantiene en el mismo repo que Flutter.
- R-AGENT-01: La categorización por agente (V1) es opcional y reversible por el usuario.
- R-AI-CLOUD-01: La IA cloud se habilita al configurar Convex y Convex Agent en V1.
- R-AI-CLOUD-02: OCR no se ejecuta en cloud.

### 5.6 CI/CD y builds (MVP)
El MVP necesita un pipeline reproducible para generar entregables sin trabajo manual.

**Entregables MVP:**
- Android: APK.
- Web: build estático.

**Requisitos:**
- R-CI-01: El CI ejecuta lint/analyze/tests y genera artifacts para Android (APK) y Web (build).
- R-CI-02: El build corre en un entorno reproducible basado en contenedor.
- R-CI-03: En PR se valida build; en main se publica artifact versionado.

---

## 6. Principios de Producto

1. **UX primero:** si se siente lenta o complicada, muere.
2. **Velocidad:** acciones frecuentes en 1–2 toques.
3. **Claridad:** gráficos simples, lenguaje directo, sin saturación.
4. **Automatización progresiva:** empezar simple, mejorar con IA sin imponer.
5. **Confianza:** seguridad, transparencia y control de datos.
6. **Progreso visible:** metas, hitos y feedback positivo.
7. **Voz-first real:** todo el core se puede hacer por voz de forma fluida, con fallback a formularios.

---

## 7. Alcance Funcional (MVP vs V1)

### MVP (P0)
- Onboarding rápido (modo invitado local).
- Registro de movimientos por voz (ingreso/gasto/transferencia) con confirmación.
- Consultas por voz sobre balance, categorías y períodos.
- Categorías (incluye personalización básica).
- Dashboard: balance actual + resumen mensual + top categorías.
- Presupuestos por categoría (mensual) + alertas de sobregasto.
- Metas de ahorro (progreso y aportes).
- Búsqueda y edición de movimientos.
- Exportación básica (CSV).
- Offline-first local (sin cuenta, sin sync).

### V1 (P1)
- Continuar con Google (Convex Auth).
- Sincronización en tiempo real multi-dispositivo (Convex).
- Migración invitado → Google (importación + fusión).
- Etiquetado/categorización asistida por Convex Agent.
- Modo conversación por voz con agente (más robusto, preguntas y seguimiento).
- Multi-cuenta (efectivo, bancos “manual”, tarjetas).
- Multi-moneda + tasas (manual/automática).
- Reglas de categorización inteligente.
- Voz y foto (OCR) para carga rápida.
- Insights automáticos y recomendaciones.
- Recordatorios (pagos, deudas, servicios).
- Compartir “espacios” (hogar/pareja) con permisos.
- Exportación PDF/Excel.

### Futuro (P2)
- Integraciones bancarias (dependen de país/partners).
- Predicciones y simulación de escenarios.
- Asistente chat/voz para consultas (“¿en qué gasté más?”).
- Gamificación ligera avanzada.

---

## 8. Features Detalladas

### 8.1 Registro Inteligente (sin fricción)
- Entrada por:
  - Voz (flujo principal).
  - Texto rápido (fallback).
  - Foto (ticket/recibo con OCR).
- Autocompletado:
  - Comercios frecuentes.
  - Categorías sugeridas por historial local (MVP) y/o Convex Agent (V1).
  - Reglas (“si contiene ‘uber’ → Transporte”).

**Requisitos:**
- R-REG-01: Registrar un gasto por voz en ≤ 10s con confirmación.
- R-REG-02: Permitir edición completa del movimiento.
- R-REG-03: Soportar adjuntos (foto) por movimiento (P1).
- R-VOICE-01: El usuario puede confirmar por voz (“sí”, “confirmar”) y corregir por voz.
- R-VOICE-02: Si falta un dato crítico (monto o tipo), la app pregunta por voz y completa.
- R-VOICE-03: Si hay baja confianza, la app pide confirmación explícita antes de guardar.
- R-AI-LOCAL-05: El MVP clasifica categoría/etiquetas offline y permite corrección inmediata.

### 8.2 Visibilidad Clara (en segundos)
- Home:
  - Balance actual (total + por cuenta).
  - Resumen del mes (ingresos vs gastos).
  - Gráficas simples (torta/barras) por categorías.
  - Alertas: sobregasto, picos, suscripciones.

**Requisitos:**
- R-DASH-01: Mostrar balance y resumen mensual en la primera pantalla.
- R-DASH-02: Permitir cambiar rango (semana/mes/año) en 1 toque.
- R-DASH-03: Alertas configurables por categoría y total mensual.

### 8.3 Control y Planificación
- Presupuestos por categoría:
  - Límite mensual.
  - Progreso y alerta al 80% / 100%.
- Metas de ahorro:
  - Monto objetivo, fecha objetivo (opcional).
  - Aportes manuales o automáticos (reglas).

**Requisitos:**
- R-PLAN-01: Presupuestos con alertas locales (sincronizables).
- R-PLAN-02: Metas con progreso visible y estimación simple (P1).

### 8.4 Inteligencia (IA)
- Insights automáticos:
  - “Este mes gastaste +18% en comida”.
  - “Aumentaron tus gastos en suscripciones”.
- Recomendaciones:
  - Ajustar presupuestos.
  - Sugerir metas realistas según hábitos.
- Predicción (P2):
  - Estimación de gasto final de mes.

**Requisitos:**
- R-IA-01: Insights explicables y accionables (no “caja negra”).
- R-IA-02: Permitir desactivar IA y mantener app 100% usable.
- R-IA-03: No enviar datos sensibles sin consentimiento explícito.
- R-IA-04: Los insights automáticos pueden ejecutarse via Convex Agent en V1.

### 8.4.1 Consultas por voz (core)
El usuario puede preguntar por voz y la app responde con:
- Respuesta corta primero (1–2 frases).
- Detalle bajo demanda (“mostrame el detalle”, “por categoría”, “solo comida”).
- Acciones directas (“abrí los movimientos”, “editá el último”, “marcá como suscripción”).

**Ejemplos:**
- “¿Cuánto me queda este mes?”
- “¿En qué gasté más esta semana?”
- “Mostrame comida de los últimos 15 días.”
- “¿Cuánto gasté en Uber en febrero?”
- “Registrá 12 mil en supermercado, efectivo.”

**Requisitos:**
- R-VOICE-04: Consultas por voz soportan filtros por período, categoría y comercio.
- R-VOICE-05: La respuesta siempre indica el rango consultado y la moneda.
- R-VOICE-06: El usuario puede pedir “detalle” y obtener lista/agrupación.

### 8.4.2 Especificación de comandos por voz (intents + slots)
El objetivo es que el usuario pueda operar “como conversación”, pero el sistema ejecute acciones deterministas. Para eso se define un catálogo de intents con slots mínimos y reglas de confirmación.

**Principios:**
- La app nunca “asume y guarda” sin confirmación si el dato es crítico o la confianza es baja.
- La app siempre muestra un resumen estructurado antes de confirmar (y lo lee en voz si el usuario habilita TTS).
- La corrección es parte del flujo, no un error.

**Intents MVP (offline-first):**
- `create_expense`
  - Slots: `amount`, `currency?`, `category?`, `merchant?`, `payment_method?`, `date?`, `note?`, `tags?`
  - Críticos: `amount`
  - Ejemplos: “Gasté 9500 en farmacia”, “Pagué 12 mil de súper con débito”
- `create_income`
  - Slots: `amount`, `currency?`, `source?`, `date?`, `note?`
  - Críticos: `amount`
  - Ejemplos: “Cobré 500 mil de sueldo”, “Me transfirieron 30.000 hoy”
- `query_balance`
  - Slots: `period?`, `account?`, `currency?`
  - Ejemplos: “¿Cuánto tengo?”, “¿Cómo voy este mes?”
- `query_spending`
  - Slots: `period`, `category?`, `merchant?`, `payment_method?`
  - Críticos: `period` (si falta: preguntar)
  - Ejemplos: “¿Cuánto gasté en comida este mes?”, “¿En qué gasté más esta semana?”
- `show_details`
  - Slots: `context` (última consulta), `group_by?` (categoría/commerce/día), `limit?`
  - Ejemplos: “Mostrame detalle”, “Abrí la lista”, “Por categoría”
- `edit_last_transaction`
  - Slots: `field`, `value`
  - Ejemplos: “Editá el último: fue 8500”, “Cambialo a efectivo”, “Ponelo en salud”
- `cancel`
  - Ejemplos: “Cancelá”, “No guardes”

**Intents V1 (con Convex + agente):**
- `transfer`
- `set_budget`
- `set_goal`
- `recategorize_batch`
- `tag_transaction`
- `export_range`
- `insight_explain`

**Reglas de extracción (MVP):**
- Montos:
  - Soportar “mil”, “miles”, “k” (“12 mil”, “12k”) y decimales.
  - Si hay ambigüedad (p. ej. “12” sin contexto) preguntar: “¿12 qué? ¿pesos/dólares?” o usar la moneda por defecto y pedir confirmación.
- Fechas:
  - Soportar “hoy”, “ayer”, “anteayer”, “el lunes”, “el 3 de marzo”, “la semana pasada”.
  - Si el usuario dice solo un mes (“en febrero”), interpretar como rango mensual en consultas.
- Método de pago:
  - Soportar “efectivo”, “débito”, “crédito”, “transferencia”.

**Confirmación (MVP y V1):**
- Siempre mostrar un “resumen entendido” con:
  - tipo, monto, moneda, fecha, categoría, comercio, método, notas/etiquetas.
- Comandos de confirmación:
  - “Confirmar / Sí / Guardar”
- Comandos de corrección:
  - “No, fue X”, “Cambiá categoría a X”, “Poné fecha ayer”, “Sin nota”, “Agregá etiqueta X”
- Si falta un crítico:
  - Pregunta dirigida de 1 dato por vez: “¿Cuánto fue?” / “¿De qué categoría?”

**Requisitos:**
- R-VOICE-INTENT-01: El MVP soporta los intents MVP con corrección por voz.
- R-VOICE-INTENT-02: La app maneja multi-turn para completar slots faltantes.
- R-VOICE-INTENT-03: La confirmación es obligatoria antes de persistir un registro.
- R-VOICE-INTENT-04: El usuario puede operar sin mirar la pantalla, con TTS opcional.

### 8.5 Seguridad y Confianza
- Bloqueo biométrico/PIN.
- Encriptación en reposo (según plataforma).
- Transparencia:
  - Qué se guarda local, qué se sincroniza.
  - Exportar/borrar datos.
- Modo manual completo (sin bancos).

**Requisitos:**
- R-SEC-01: Bloqueo opcional por biometría/PIN.
- R-SEC-02: Exportar datos del usuario bajo demanda.
- R-SEC-03: Borrado total de datos desde ajustes.
- R-PRIV-03: No se almacena audio por defecto; solo transcripción si el usuario lo habilita.
- R-PRIV-04: Los permisos de micrófono se explican claramente y son revocables.

### 8.6 Multiplataforma y Sincronización
- Offline-first:
  - Funciona sin internet.
  - En modo invitado, persiste localmente y no requiere red.
  - En modo Google, reintenta mutaciones y sincroniza al recuperar conexión.
- Conflictos:
  - Estrategia determinista (por timestamp/merge).
- Multi-dispositivo:
  - Sesión en móvil + web, estado consistente con Convex en tiempo real.

**Requisitos:**
- R-SYNC-01: Cambios locales persistentes sin conexión.
- R-SYNC-02: Sincronización incremental y eficiente.
- R-SYNC-03: Manejo de conflictos sin pérdida silenciosa.
- R-SYNC-04: La migración invitado→Google (V1) no pierde datos y es auditable por el usuario.

### 8.7 Integraciones y Exportación
- Exportación:
  - CSV (MVP).
  - PDF/Excel (P1).
- Integraciones bancarias (P2, por país):
  - Opt-in, con permisos y scopes claros.

**Requisitos:**
- R-EXP-01: Exportar por rango de fechas y filtros.
- R-EXP-02: No bloquear la app durante exportaciones (asíncrono).

### 8.8 Progreso y Retención
- Indicadores:
  - Tendencia de ahorro.
  - “Mejor mes”, rachas (ligero).
- Feedback positivo:
  - Hitos alcanzados (sin exceso de gamificación).

**Requisitos:**
- R-PROG-01: Mostrar avance de metas en Home (P1).
- R-PROG-02: Hitos configurables y discretos (no intrusivos).

---

## 9. Flujos Clave

### 9.1 Onboarding
1. Elegir moneda principal.
2. Crear primera cuenta (Efectivo por defecto).
3. Primer presupuesto y/o meta (opcional).
4. Tutorial corto (máximo 3 pantallas).

En V1 se suma la opción “Continuar con Google” para sincronizar y migrar datos.

### 9.2 Pasar de invitado a Google
1. El usuario toca “Continuar con Google”.
2. Se autentica con Convex Auth (Google).
3. La app ofrece migrar datos locales a la cuenta (importación + fusión).
4. Al finalizar, los datos quedan sincronizados en todos los dispositivos.

### 9.3 Registrar gasto
- Voz: “Gasté 9.500 en farmacia con tarjeta” → propuesta → confirmación → guardado.
- Fallback: botón + → formulario rápido → guardar.

### 9.3.1 Corrección por voz
- “No, fue 8.500” / “No, fue en efectivo” / “Ponelo en salud” → la app actualiza el resumen y vuelve a pedir confirmación.

### 9.3.2 Consulta por voz
- “¿Cuánto gasté en comida este mes?” → respuesta → “mostrame detalle” → lista filtrada.

### 9.4 Revisar mes
- Home → ver resumen → tocar categoría → ver lista de movimientos → editar.

---

## 10. Modelo de Datos (alto nivel)

- Perfil local (modo invitado)
- Dispositivo (para modo invitado local)
- Usuario (V1, identidad Google vía Convex Auth)
- Interacción por voz:
  - transcripción
  - intención detectada
  - slots extraídos (monto, categoría, comercio, fecha, método)
  - confianza
  - estado (propuesto/confirmado/corregido/cancelado)
- Espacio (personal/compartido) (P1)
- Cuenta (efectivo/tarjeta/banco manual)
- Categoría (sistema + personalizada)
- Movimiento:
  - tipo (ingreso/gasto/transferencia)
  - monto, moneda, fecha
  - cuenta origen/destino
  - categoría
  - etiquetas/notas
  - adjuntos (P1)
- Presupuesto (por categoría + período)
- Meta (objetivo + aportes)

---

## 11. Requisitos No Funcionales

### 11.1 Performance
- R-PERF-01: Home renderiza en < 300ms en dispositivo medio.
- R-PERF-02: Búsqueda responde en < 150ms con 10k movimientos.
- R-PERF-03: Sincronización no degrada scroll/listas.
- R-VOICE-PERF-01: La transcripción inicia en < 500ms y se siente continua.
- R-VOICE-PERF-02: De fin de frase a propuesta visible en < 800ms (MVP target).
- R-AI-LOCAL-PERF-01: El etiquetado offline propone categoría en < 300ms (p95) en móvil medio.
- R-AI-LOCAL-PERF-02: El consumo de batería en sesiones de voz es aceptable para uso diario.

### 11.2 Accesibilidad
- R-ACC-01: Soporte de tamaños de texto (Dynamic Type / textScale).
- R-ACC-02: Contraste AA para modos claro/oscuro.
- R-ACC-03: Navegación por teclado en web/desktop (P1).
- R-VOICE-ACC-01: Confirmación también disponible con toques para ambientes ruidosos.

### 11.3 Privacidad
- R-PRIV-01: Configuración clara de datos y permisos.
- R-PRIV-02: Consentimiento explícito para cualquier envío a servicios IA.
- R-PRIV-05: En V1, cualquier uso de IA cloud se comunica claramente y es configurable.

### 11.4 Confiabilidad
- R-REL-01: Migraciones de datos versionadas.
- R-REL-02: Crash-free sessions objetivo ≥ 99.5%.

---

## 12. Métricas de Éxito

| Métrica | Objetivo |
|--------|----------|
| Tiempo para registrar un gasto | ≤ 10s |
| Retención D7 | ≥ 20% (MVP) |
| Retención D30 | ≥ 10% |
| % movimientos categorizados correctamente | ≥ 85% (con reglas/IA P1) |
| Usuarios que crean al menos 1 presupuesto/meta | ≥ 40% |
| Crash-free sessions | ≥ 99.5% |
| % registros creados por voz | ≥ 60% (MVP) |
| Tasa de éxito voz sin corrección | ≥ 70% (MVP) |
| Tiempo voz→confirmación | ≤ 10s (p95) |

---

## 13. Riesgos y Mitigaciones

- **Complejidad de features IA** → empezar con insights simples + opt-out.
- **Sincronización/conflictos** → offline-first con estrategia clara y testeada.
- **Privacidad** → transparencia + controles + minimización de datos.
- **Sobrecarga de UI** → priorizar “claridad” sobre “cantidad”.
- **Errores de voz** → confirmación obligatoria, corrección por voz, fallback a formulario.

---

## 14. Open Questions

### Decisiones tomadas
- Nombre final: TodoAlDía.
- MVP: Android + Web, con artifacts (APK + build web).
- Fusión invitado→Google: mismo esquema local/Convex, upsert idempotente por `id`, dedup por heurística y conflictos revisables.
- IA cloud (V1): se habilita al configurar Convex + Convex Agent, usando OpenAI (modelo tipo “ChatGPT mini”).
- OCR: siempre on-device, nunca en cloud.
- Gastos compartidos: no prioridad (post-V1).

### Pendientes
1. ¿Cuál es el tamaño máximo aceptable del paquete offline de modelos?
2. ¿Qué runtime/modelos locales específicos se usarán para STT y NLU con máxima compatibilidad?
3. ¿Qué experiencia exacta se ofrece en Web cuando no haya IA local disponible?

---

## Appendix A: Priorización (resumen)

- **P0:** registro rápido, dashboard claro, presupuestos, metas básicas, offline-first, export CSV, seguridad básica.
- **P1:** multi-cuenta, multi-moneda, OCR/voz, insights, recordatorios, export PDF/Excel, compartir.
- **P2:** bancos, predicción, simulación, asistente chat/voz avanzado.
