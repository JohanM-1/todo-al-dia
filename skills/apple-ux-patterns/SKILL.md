---
name: apple-ux-patterns
description: >
  Project skill for interaction patterns inspired by Apple UX principles, focused on state communication,
  feedback, accessibility, CTA clarity, and conversion-oriented funnels for landing and product flows.
  Trigger: When designing or reviewing landing pages, CTA hierarchy, product feedback states,
  accessibility, or conversion-oriented user flows.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- When shaping a landing into a clear conversion funnel
- When reviewing primary vs secondary CTA hierarchy
- When defining loading, empty, success, validation, or error feedback
- When improving accessibility, focus order, labels, and recovery paths
- When borrowing Apple interaction principles without copying Apple visuals

## Critical Patterns

### Pattern 1: State Communication Must Remove Doubt

- Every important action must communicate its current state: idle, pending, success, validation issue, or failure.
- State copy must answer two questions fast: what happened, and what can the user do next.
- Empty states should orient action, not just describe absence.

### Pattern 2: Feedback Must Be Immediate and Recoverable

- Prefer local, inline feedback close to the action that triggered it.
- Validation errors must point to the exact field or decision the user needs to fix.
- If an action is reversible, prefer a fast correction path over a hard stop.
- If the user can continue safely, do not block the flow with unnecessary confirmations.

### Pattern 3: Accessibility Is Part of Clarity

- Maintain visible focus states for keyboard users.
- Use semantic landmarks, real headings, labeled controls, and meaningful link text.
- Preserve readable contrast and touch targets that remain usable on mobile.
- Do not rely on color alone to communicate status or priority.

### Pattern 4: Funnel First, Brochure Second

- Each screen should have one dominant primary action.
- Secondary actions may exist, but must be visually quieter and never compete with the main conversion.
- Landing order should be: value, expected result, friction reduction, proof, CTA.
- Copy should emphasize the outcome for the user before listing features.

### Pattern 5: Apple Patterns Are Interaction Guidance Only

- Use calm hierarchy, progressive disclosure, and clear status communication as references.
- Do not clone Apple visual language, hardware marketing, gradients, or brand tone.
- Preserve the product's own visual identity and business goals.

## Code Examples

```astro
<div class="hero-actions" aria-label="Accion principal">
  <a class="button button-primary" href={appUrl} data-analytics="cta-primary-hero">
    Abrir la app
  </a>
  <a class="text-link" href="#como-funciona">Ver como funciona</a>
</div>
```

```html
<p class="status-message" role="status" aria-live="polite">
  Guardado. Ya podes seguir con el siguiente movimiento.
</p>
```

## Commands

```bash
# Revisar la skill del proyecto
sed -n '1,220p' skills/apple-ux-patterns/SKILL.md

# Buscar CTAs y ganchos de analytics en la landing
rg "data-analytics|button-primary|text-link" landing/src

# Revisar el registry compilado
sed -n '1,260p' .atl/skill-registry.md
```

## Resources

- **Documentation**: See `AGENTS.md` and `.atl/skill-registry.md` for project-level resolution.
