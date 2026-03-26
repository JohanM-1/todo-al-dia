## Objetivo
Mantener un código Flutter multiplataforma consistente, fácil de mantener, testeable y con buen rendimiento.

## Alcance
- Flutter/Dart y configuración asociada: `pubspec.yaml`, `analysis_options.yaml`, Android (`android/`), iOS/macOS (`ios/`, `macos/`), Web (`web/`), Windows/Linux (`windows/`, `linux/`).
- Cambios deben ser compatibles con null-safety.

## Estilo y formato
- Ejecutar `dart format .` y no introducir formateo manual inconsistente.
- Preferir `const` y widgets inmutables cuando aplique.
- Nombres: `lowerCamelCase` (variables/métodos), `UpperCamelCase` (clases), `snake_case.dart` (archivos).
- Evitar abreviaturas crípticas; usar nombres descriptivos.

## Arquitectura y separación
- Mantener la lógica de negocio fuera de widgets; widgets deben enfocarse en UI.
- Extraer lógica a capas/servicios/repositorios cuando crezca más de lo trivial.
- Evitar dependencias cíclicas entre capas.
- Preferir composición sobre herencia en UI.

## Estado, asincronía y rendimiento
- No bloquear el hilo principal con trabajo pesado; mover a `compute`/isolates o a servicios nativos cuando corresponda.
- Evitar `setState` anidado y rebuilds innecesarios; dividir widgets y usar `const`.
- Manejar cancelación/limpieza de listeners, streams y controllers en `dispose`.

## Errores y validación
- Validar entradas en UI y en la capa de dominio cuando aplique.
- No ocultar excepciones: capturar con propósito y propagar o mapear a errores de dominio.
- No loguear tokens, llaves o datos sensibles.

## Multiplataforma
- Aislar código específico de plataforma detrás de adaptadores y APIs claras.
- Para plugins/canales de plataforma, definir contratos estables y pruebas donde sea posible.
- Evitar suposiciones sobre paths o capacidades del sistema operativo.

## Dependencias y pubspec
- No agregar dependencias si existe solución con SDK o dependencias ya presentes.
- Mantener `pubspec.yaml` ordenado; justificar cambios de versiones con impacto claro.
- No modificar `pubspec.lock` salvo que sea necesario por el cambio.

## Internacionalización y accesibilidad
- Usar `arb`/l10n cuando aplique; no hardcodear strings en UI.
- Respetar escalado de texto, contraste y navegación por teclado/lectores cuando aplique.

## Pruebas y calidad
- Agregar/actualizar pruebas cuando el cambio afecte lógica (unit/widget) o flujos críticos.
- Mantener el proyecto pasando `flutter analyze` y `flutter test`.
