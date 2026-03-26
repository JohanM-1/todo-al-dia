# TodoAlDía

> App financiera personal con voz-first - MVP

## Descripción

TodoAlDía es una aplicación financiera personal diseñada para registrar gastos e ingresos de manera rápida y sin fricción, utilizando voz como método de entrada principal.

## Características MVP

- ✅ Registro de movimientos por voz
- ✅ Dashboard con balance y gráfico de gastos por categoría
- ✅ CRUD completo de movimientos
- ✅ Gestión de categorías
- ✅ Presupuestos por categoría
- ✅ Metas de ahorro
- ✅ Exportación CSV
- ✅ Offline-first (datos locales)
- ✅ Tema claro/oscuro

## Requisitos

- Flutter SDK 3.x
- Dart 3.x
- Android SDK 21+ (para Android)
- Xcode 13+ (para iOS/macOS)

## Instalación

1. **Clonar el repositorio:**
```bash
git clone <repo-url>
cd todoaldia
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Generar código Drift (base de datos):**
```bash
dart run build_runner build
```

4. **Ejecutar la app:**
```bash
flutter run
```

## Construcción

### APK Debug
```bash
flutter build apk --debug
```

### APK Release
```bash
flutter build apk --release
```

### Web
```bash
flutter build web
```

## Arquitectura

El proyecto sigue **Clean Architecture** con separación en capas:

```
lib/
├── core/                    # Configuración central
│   ├── constants/           # Constantes de la app
│   ├── errors/              # Errores personalizados
│   ├── router/              # Configuración de rutas
│   ├── theme/               # Temas de la app
│   └── utils/               # Utilidades
├── data/                    # Capa de datos
│   ├── database/            # Drift database
│   ├── models/              # Modelos de datos
│   └── repositories/        # Implementaciones de repositorios
├── domain/                  # Capa de dominio
│   ├── entities/            # Entidades del dominio
│   ├── errors/              # Errores del dominio
│   ├── repositories/        # Interfaces de repositorios
│   └── usecases/            # Casos de uso
├── presentation/            # Capa de presentación
│   ├── bloc/                # BLoCs para estado
│   ├── pages/               # Páginas de la app
│   ├── widgets/             # Widgets reutilizables
│   └── providers/           # Providers
├── services/                # Servicios externos
│   ├── export_service.dart  # Exportación CSV
│   └── voice_service.dart   # Reconocimiento de voz
└── main.dart                # Punto de entrada
```

## Uso de Voz

La app entiende los siguientes comandos de voz:

### Registrar gasto
- "Gasté 5000 en comida"
- "Pagué 1000 de transporte con débito"
- "Compré 200 en supermercado"

### Registrar ingreso
- "Cobré 150000 de sueldo"
- "Me pagaron 5000 de freelance"

### Consultas
- "¿Cuánto tengo?"
- "¿Cuánto gasté este mes?"
- "¿En qué gasté más esta semana?"

## Estado del Proyecto

- **Versión**: 0.1.0 (MVP)
- **Estado**: En desarrollo
- **Plataformas objetivo**: Android, Web

## Licencia

MIT 2026
