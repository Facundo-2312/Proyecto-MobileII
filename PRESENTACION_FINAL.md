# Presentación Final - FoodFinder

## Slide 1 - Portada

- FoodFinder
- Aplicación Flutter para descubrir restaurantes cercanos
- Proyecto final Mobile II

## Slide 2 - Problema

- Los usuarios necesitan encontrar restaurantes próximos de forma rápida.
- La ubicación y el mapa deben estar integrados en una experiencia simple.
- La solución debe funcionar con datos locales y una interfaz clara.

## Slide 3 - Solución propuesta

- App mobile desarrollada con Flutter.
- Geolocalización para obtener la posición actual.
- Visualización de restaurantes en mapa y lista.
- Vista detallada con información útil para la decisión del usuario.

## Slide 4 - Objetivos cumplidos

- Obtener la ubicación actual del usuario.
- Mostrar restaurantes cercanos en un mapa interactivo.
- Permitir navegación por lista, mapa y detalle.
- Mantener una experiencia estable y rápida.

## Slide 5 - Funcionalidades principales

- Mapa interactivo en mobile y alternativa web.
- Cálculo de distancia entre usuario y restaurante.
- Pantallas de productos, pedidos, perfil y vista demo wearable.
- Registro de nuevos usuarios desde la propia app.
- Edición de pedidos con estado, total y observaciones.
- Confirmación previa antes de eliminar pedidos.
- Gestión local de datos y experiencia de navegación completa.

## Slide 6 - Arquitectura

- Capa de presentación con pantallas y widgets reutilizables.
- Capa de servicios para ubicación, restaurantes y persistencia.
- Capa de datos con modelos y constantes.
- Patrón singleton para compartir servicios de forma eficiente.

## Slide 7 - Tecnologías utilizadas

- Flutter y Dart.
- Google Maps en mobile.
- OpenStreetMap en web.
- Geolocator para ubicación.
- Sqflite para persistencia local.

## Slide 8 - Mejoras finales de release

- Nuevo icono del aplicativo.
- Pantalla de carga al iniciar la app.
- Splash nativo en Android e iOS.
- Build de release APK automatizable desde GitHub Actions.
- APK local generado en `build/app/outputs/flutter-apk/app-release.apk`.

## Slide 9 - Demo sugerida

- Abrir la aplicación y mostrar splash / loading screen.
- Entrar a inicio y navegar entre tabs.
- Registrar un usuario nuevo.
- Iniciar sesión con la cuenta creada.
- Abrir mapa y ubicar restaurantes cercanos.
- Entrar al detalle de un restaurante.
- Mostrar perfil, pedidos y vista wearable.
- Editar un pedido y agregar una observación.
- Eliminar un pedido confirmando la acción.

## Slide 10 - Valor del proyecto

- Interfaz moderna y entendible.
- Base escalable para integrar datos reales.
- Entrega multiplataforma con foco mobile.
- Proyecto listo para futuras extensiones.

## Slide 11 - Próximos pasos

- Integrar API real de restaurantes.
- Incorporar autenticación.
- Agregar favoritos, filtros y reseñas.
- Publicar el APK como release en GitHub usando el workflow de tags `v*`.
- Publicar releases continuas con pipeline automático.

## Slide 12 - Cierre

- FoodFinder combina geolocalización, mapa y catálogo en una sola experiencia.
- El proyecto quedó listo para entrega académica y evolución futura.
- Preguntas.

## Guion breve para exponer

- Abrir con el problema y la necesidad del usuario.
- Explicar la solución en menos de un minuto.
- Mostrar la demo siguiendo el orden splash, home, mapa y detalle.
- Cerrar con arquitectura, mejoras finales y próximos pasos.