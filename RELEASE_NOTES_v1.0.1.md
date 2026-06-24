# FoodFinder v1.0.1

## Resumen

Esta release prepara la entrega final de FoodFinder con mejoras de presentación y empaquetado para Android.

## Cambios principales

- Nuevo icono de la aplicación generado desde `assets/branding/app_icon.png`.
- Nueva pantalla de carga dentro de Flutter durante la inicialización de la app.
- Nuevo splash nativo para Android e iOS con la identidad visual del proyecto.
- Incremento de versión a `1.0.1+2` para distribuir un APK de release.
- Workflow de GitHub Actions para construir y adjuntar el APK automáticamente en cada tag `v*`.

## APK

- Artefacto local esperado: `build/app/outputs/flutter-apk/app-release.apk`
- Nombre sugerido para la release: `FoodFinder v1.0.1`
- Tag sugerido: `v1.0.1`

## Publicación en GitHub

1. Confirmar y hacer commit de los cambios.
2. Crear el tag `v1.0.1` sobre el commit final.
3. Hacer push del branch y del tag al repositorio remoto.
4. Esperar a que el workflow `Release APK` termine.
5. Verificar en GitHub que la release tenga adjunto el APK.

## Nota operativa

La publicación automática depende de GitHub Actions y se ejecuta cuando el tag llega al remoto. En este entorno local no está disponible `gh`, por lo que la automatización en el repositorio es la vía más directa para cerrar la release.
