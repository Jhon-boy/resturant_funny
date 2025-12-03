# 🍽️ Cevicheria Riobamba

Aplicación móvil desarrollada en Flutter para la gestión integral de un restaurante de comida rápida. Permite administrar empleados, usuarios, inventario, ventas, reportes y múltiples sucursales desde una interfaz moderna y eficiente.

## ✨ Características Principales

- 🔐 **Autenticación y Roles**: Sistema de login con múltiples roles (Administrador, Empleado, Usuario)
- 📦 **Gestión de Inventario**: Control completo de productos, ingresos y egresos
- 💰 **Sistema de Ventas**: Registro de ventas, facturación y gestión de mesas
- 📊 **Reportes y Estadísticas**: Reportes detallados de ventas, inventario, empleados y comparativas
- 🏢 **Multi-sucursal**: Administración de múltiples sucursales desde una sola aplicación
- 👥 **Gestión de Usuarios**: CRUD completo de empleados y usuarios del sistema
- 🔔 **Notificaciones**: Sistema de notificaciones en tiempo real
- 🌙 **Modo Oscuro**: Soporte para tema claro y oscuro
- 🌍 **Multi-idioma**: Soporte para Español e Inglés
- 📱 **Offline Ready**: Manejo de conectividad y almacenamiento local

## 🏗️ Arquitectura

La aplicación está construida siguiendo los principios de **Clean Architecture** con separación de responsabilidades en tres capas principales:

```
lib/
├── app/              # Configuración de la aplicación
├── core/             # Servicios, utilidades y constantes compartidas
├── modules/          # Módulos de funcionalidad (Clean Architecture)
│   ├── authentication/
│   ├── inventario/
│   ├── ventas/
│   ├── user/
│   ├── reportes/
│   ├── sucursales/
│   └── ...
└── shared/           # Widgets y componentes compartidos
```

Cada módulo sigue la estructura:
- **data/**: Fuentes de datos (datasources, repositories implementation)
- **domain/**: Lógica de negocio (entities, repositories interfaces, providers)
- **presentation/**: Interfaz de usuario (pages, widgets)

## 🛠️ Stack Tecnológico

### Framework y Lenguaje
- **Flutter** 3.3.0+
- **Dart** 3.3.0+

### Gestión de Estado
- **Riverpod** 2.6.1 - Gestión de estado reactiva y declarativa

### Backend y Base de Datos
- **Supabase** 2.9.1 - Backend as a Service (BaaS)
- **PostgreSQL** - Base de datos relacional

## 📋 Requisitos Previos

- Flutter SDK >= 3.3.0
- Dart SDK >= 3.3.0
- Cuenta de Supabase configurada
- Android Studio / VS Code con extensiones de Flutter
- Git

## 🚀 Configuración e Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd resturant_funny
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**
   
   Crear un archivo `.env` en la raíz del proyecto con:
   ```env
   SUPABASE_URL=tu_url_de_supabase
   SUPABASE_ANON_KEY=tu_clave_anonima
   API_BASE_URL=tu_url_api
   API_TIMEOUT=30000
   ENVIRONMENT=development
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Módulos Principales

### 🔐 Autenticación
- Login con validación de credenciales
- Gestión de sesiones
- Registro de dispositivos
- Cambio de roles dinámico

### 📦 Inventario
- Gestión de productos con imágenes
- Control de stock
- Registro de ingresos y egresos
- Estados: Activo, Pendiente, Inactivo

### 💰 Ventas
- Registro de ventas en tiempo real
- Gestión de mesas
- Facturación
- Detalle de ventas por producto

### 👥 Usuarios y Empleados
- CRUD de usuarios
- Gestión de empleados
- Perfiles de usuario
- Estadísticas por empleado

### 📊 Reportes
- Reportes de ventas
- Reportes de inventario
- Reportes por empleado
- Comparativas entre períodos
- Reportes por sucursal

### 🏢 Sucursales
- Gestión de múltiples sucursales
- Detalle de sucursales
- Asignación de usuarios a sucursales

## 🎨 Características de UI/UX

- **Material Design 3**: Interfaz moderna siguiendo las últimas guías de Material Design
- **Responsive**: Adaptable a diferentes tamaños de pantalla
- **Animaciones**: Transiciones suaves con Lottie
- **Loading States**: Indicadores de carga con Shimmer
- **Error Handling**: Manejo elegante de errores con mensajes claros
- **Navegación**: Sistema de navegación intuitivo con drawer y bottom navigation

## 🔧 Servicios Core

- **SupabaseService**: Abstracción para operaciones CRUD con Supabase
- **StorageService**: Gestión de almacenamiento local
- **ConnectivityService**: Monitoreo de estado de conexión
- **SharedPrefsService**: Gestión de preferencias del usuario
- **EnhancedAuthService**: Servicio de autenticación mejorado

## 📄 Base de Datos

La aplicación utiliza PostgreSQL a través de Supabase. Las tablas principales incluyen:

- `TUSUARIO` - Usuarios del sistema
- `TPERSONA` - Información de personas
- `TPRODUCTO` - Catálogo de productos
- `TINVENTARIO` - Control de inventario
- `TVENTA` - Registro de ventas
- `TDETALLEVENTA` - Detalle de ventas
- `TSUCURSAL` - Sucursales
- `TROL` - Roles del sistema
- `TSESION` - Sesiones de usuario
- `TDISPOSITIVO` - Dispositivos registrados

Ver `SQL_V1.sql` para el esquema completo.

## 🌍 Internacionalización

La aplicación soporta múltiples idiomas:
- 🇪🇸 Español (ES)
- 🇺🇸 Inglés (US)

El idioma se puede cambiar dinámicamente desde la configuración de la aplicación.

## 🎯 Estado de la Aplicación

La aplicación utiliza **Riverpod** para la gestión de estado global:
- `appStateProvider`: Estado global (tema, idioma, loading)
- `navigationIndexProvider`: Índice de navegación
- Providers específicos por módulo

## 📦 Build y Deploy

### Android
```bash
flutter build apk --release
# o
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribución

Este es un proyecto personal, pero las sugerencias y mejoras son bienvenidas.

## 📝 Licencia

Este proyecto es de uso privado.

## 👤 Autor

ING. JOHN CUVI

---

**Versión**: 1.0.1+5  
**Última actualización**: 2025
