# Seg4 — Login Biométrico + Artículos

Aplicación Flutter con backend Node.js que implementa:
- Login con usuario/clave y autenticación biométrica (huella / Face ID).
- JWT de sesión (corta vida, en memoria) + JWT biométrico (larga vida, SecureStorage).
- Catálogo de artículos y ofertas con JWT en cada solicitud.
- Almacenamiento relacional obligatorio en SQLite (backend).

---

## Estructura del Proyecto

```
seg4_project/
├── backend/
│   ├── package.json          ← Dependencias Node.js
│   └── server.js             ← API REST completa (6 endpoints)
│
└── flutter/
    ├── pubspec.yaml           ← Dependencias Flutter
    ├── android_permissions.xml← Permisos Android a agregar
    └── lib/
        ├── main.dart
        ├── constants/
        │   └── app_colors.dart     ← Paleta pastel + AppTheme
        ├── models/
        │   └── articulo.dart       ← Modelo + lógica descuentos
        ├── services/
        │   ├── auth_service.dart   ← JWT dual, biometría
        │   └── api_service.dart    ← GET artículos/ofertas con JWT
        ├── screens/
        │   ├── login_screen.dart
        │   ├── biometric_setup_screen.dart
        │   └── home_screen.dart
        └── widgets/
            ├── menu_principal.dart  ← Widget 1  (2pts)
            ├── lista_articulos.dart ← Widget 2  (8pts)
            ├── lista_ofertas.dart   ← Widget 3  (8pts)
            ├── item_articulo.dart   ← Widget 4  (10pts)
            ├── ficha_articulo.dart  ← Widget 5  (16pts)
            └── valoracion.dart      ← Widget 6  (6pts)
```

---

## Setup — Backend

### Requisitos
- Node.js 18+

### Instalación y arranque

```bash
cd backend
npm install
npm start
# Servidor en http://localhost:3000
```

### Usuario de prueba creado automáticamente
- **Usuario:** `admin`
- **Clave:** `1234`

### Endpoints disponibles

| Método | Ruta                      | Auth       | Descripción                        |
|--------|---------------------------|------------|------------------------------------|
| POST   | /auth/login               | ✗          | Login usuario+clave → sessionToken |
| POST   | /auth/enable-biometric    | ✗          | Habilita biometría → biometricToken|
| POST   | /auth/login-biometric     | ✗          | Login con biometricToken           |
| POST   | /auth/disable-biometric   | JWT sesión | Deshabilita biometría              |
| GET    | /api/articulos            | JWT sesión | Todos los artículos (desde BD)     |
| GET    | /api/ofertas              | JWT sesión | Solo artículos con descuento > 0   |

---

## Setup — Flutter

### Dependencias (pubspec.yaml)

```yaml
local_auth: ^2.3.0
flutter_secure_storage: ^9.2.2
cached_network_image: ^3.3.1
http: ^1.2.1
```

### Instalación

```bash
cd flutter
flutter pub get
```

### Configuración de URL del backend

En `lib/services/auth_service.dart` y `lib/services/api_service.dart`:

```dart
// Emulador Android → 10.0.2.2
static const String _baseUrl = 'http://10.0.2.2:3000';

// Dispositivo físico → IP de tu máquina en la red local
static const String _baseUrl = 'http://192.168.1.X:3000';
```

### Permisos Android requeridos

En `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

Para HTTP en desarrollo, crea `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">10.0.2.2</domain>
  </domain-config>
</network-security-config>
```

Y en `<application>` agrega: `android:networkSecurityConfig="@xml/network_security_config"`

---

## Flujo JWT Explicado

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUJO DE AUTENTICACIÓN                      │
├──────────────────────────────────────────────────────────────────┤
│  1. LOGIN CLÁSICO                                                │
│     App → POST /auth/login {usuario, clave}                     │
│     Backend → sessionToken (JWT 2h)                             │
│     App → guarda en MEMORIA (se destruye al cerrar la app)      │
│                                                                  │
│  2. HABILITAR BIOMETRÍA                                          │
│     App → POST /auth/enable-biometric {usuario, clave}          │
│     Backend → biometricToken (JWT 365d) + guarda en BD          │
│     App → guarda en FlutterSecureStorage (persiste)             │
│                                                                  │
│  3. LOGIN BIOMÉTRICO (futuros inicios)                          │
│     App → lee biometricToken de SecureStorage                   │
│     SO  → presenta prompt de huella/Face ID                     │
│     App → POST /auth/login-biometric {biometricToken}           │
│     Backend → verifica token vs BD → sessionToken (JWT 2h)      │
│     App → guarda sessionToken en MEMORIA                        │
│                                                                  │
│  4. SOLICITUDES PROTEGIDAS                                       │
│     App → GET /api/articulos                                    │
│           Header: Authorization: Bearer <sessionToken>          │
│     Backend → valida JWT → consulta BD → retorna datos          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Lógica de Descuentos

```dart
// En lib/models/articulo.dart
bool get tieneDescuento => descuento > 0;

// Precio final aplicando el descuento
double get precioFinal {
  if (!tieneDescuento) return precio;
  return precio * (1 - descuento / 100);
}

// Ejemplos con datos reales de la API:
// Audífonos Lenovo: precio=$135.000, descuento=15%
//   → precioFinal = 135000 * (1 - 0.15) = $114.750
// Power Bank: precio=$69.900, descuento=45%
//   → precioFinal = 69900 * (1 - 0.45) = $38.445
```

---

## Lógica de Valoración (Estrellas)

```dart
// En lib/models/articulo.dart
// El campo `valoracion` de la API va de 0 a 50
// Se divide entre 10 para obtener escala 0-5 de estrellas

double get estrellas => valoracion / 10.0;

// Ejemplo: valoracion=32 → 3.2 estrellas
// → 3 estrellas llenas + 1 media + 1 vacía
```

---

## Paleta de Colores Pastel

| Token            | Color Hex   | Uso                          |
|------------------|-------------|------------------------------|
| `background`     | `#FDFBF7`   | Fondo principal (crema)      |
| `card`           | `#FFFFFF`   | Tarjetas con sombra tenue    |
| `accentBlue`     | `#AEC6CF`   | Botones, íconos primarios    |
| `accentGreen`    | `#B1D8B7`   | Ofertas, badges de descuento |
| `accentPink`     | `#FFD1DC`   | Errores, acentos secundarios |
| `starFilled`     | `#FFD580`   | Estrellas de valoración      |
| `priceDiscount`  | `#5A9A6F`   | Precio con descuento         |
| `textPrimary`    | `#3A3A3A`   | Texto principal              |
| `textSecondary`  | `#8A8A8A`   | Texto secundario             |
# apkloginbiometrico
