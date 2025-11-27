# 🚀 TRADEX - Guía Rápida de Uso

## 📡 URLs del Proyecto

- **Backend API:** http://localhost:5000
- **Frontend Flutter:** http://localhost:8080
- **Base de Datos:** MySQL en XAMPP (puerto 3306)

## 🔐 Credenciales de Acceso

### Administrador
- **Email:** admin@tradex.com
- **Password:** 123456

### Conductores
- **Email:** conductor1@tradex.com | conductor2@tradex.com
- **Password:** 123456

### Cliente
- **Email:** cliente@empresa.com
- **Password:** 123456

---

## 🎯 Prueba Rápida de la API

### 1. Verificar que el backend está corriendo
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/" -Method GET
```
Debería responder: `StatusCode: 200` y `Content: OK`

### 2. Probar el login
```powershell
$body = @{
    email = "admin@tradex.com"
    password = "123456"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/api/login" -Method POST -Body $body -ContentType "application/json"
```

### 3. Listar usuarios
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/usuarios" -Method GET
```

### 4. Listar vehículos
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/vehiculos" -Method GET
```

### 5. Listar rutas
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/rutas" -Method GET
```

---

## 📊 Datos de Prueba Disponibles

### Usuarios (4)
1. Administrador Principal - admin@tradex.com
2. Juan Pérez (Conductor) - conductor1@tradex.com
3. María García (Conductor) - conductor2@tradex.com
4. Cliente Demo - cliente@empresa.com

### Vehículos (3)
1. ABC123 - Chevrolet NPR 2022 (3500 kg)
2. XYZ789 - Ford Cargo 2021 (2500 kg)
3. DEF456 - Hino 300 2023 (4000 kg)

### Rutas (2)
1. R-001 - Ruta Norte (planificada para 26/11/2025)
2. R-002 - Ruta Sur (en progreso)

---

## 🛠️ Comandos para Gestionar el Proyecto

### Iniciar Backend
```powershell
cd c:\taller\tradex\apitradex
python run.py
```

### Iniciar Frontend
```powershell
cd c:\taller\tradex\tradex
flutter run -d chrome --web-port=8080
```

### Ver Base de Datos
```powershell
cd c:\taller\tradex\apitradex
python ver_db.py
```

### Recrear Base de Datos
```powershell
cd c:\taller\tradex\apitradex
python setup_db.py
```

---

## ✅ Checklist de Verificación

- [x] XAMPP MySQL corriendo en puerto 3306
- [x] Base de datos `tradex2` creada con datos
- [x] Backend Flask corriendo en http://localhost:5000
- [x] Frontend Flutter compilando/corriendo
- [x] CRUD completo implementado en la API
- [ ] Interfaz Flutter conectada y funcionando

---

## 🔧 Solución de Problemas

### Si el backend no conecta a MySQL:
1. Verifica que XAMPP esté corriendo
2. Verifica la contraseña en `app/__init__.py` (debe ser `041124`)
3. Ejecuta `python setup_db.py` para recrear la BD

### Si Flutter no se conecta al backend:
1. Verifica que el backend esté corriendo en puerto 5000
2. Verifica `lib/env.dart` tenga `http://localhost:5000/api`
3. Abre las DevTools del navegador (F12) para ver errores

### Si sale "ERR_CONNECTION_REFUSED":
- Asegúrate de que el backend esté corriendo
- Verifica que no haya un firewall bloqueando el puerto 5000

---

Fecha: 25 de Noviembre, 2025
