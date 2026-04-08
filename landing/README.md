# Landing

Landing SEO-friendly de TodoAlDía en Astro.

## Scripts

- `npm install`
- `npm run dev`
- `npm run build`
- `npm run preview`

## Notas

- El dominio base configurado por defecto es `https://todoaldia.app`.
- Si cambia el dominio final, actualizar `astro.config.mjs`, `public/robots.txt` y los links canónicos/sociales si aplica.
- La URL objetivo del CTA principal hacia la app Flutter está centralizada en `src/config/site.ts`.
- Los CTAs principales y secundarios ya incluyen atributos `data-analytics` para conectar medición futura sin agregar dependencias.
