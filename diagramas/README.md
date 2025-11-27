# 📊 Diagramas UML - Sistema TRADEX

Este directorio contiene todos los diagramas UML del Sistema TRADEX en formato **PlantUML**.

## 📁 Archivos Disponibles

| Archivo | Descripción |
|---------|-------------|
| `01_arquitectura.puml` | Arquitectura de 3 capas del sistema |
| `02_entidad_relacion.puml` | Diagrama Entidad-Relación (ER) de la base de datos |
| `03_clases.puml` | Diagrama de Clases UML del backend |
| `04_secuencia_crear_usuario.puml` | Secuencia completa para crear usuario |
| `05_secuencia_asignar_conductor.puml` | Secuencia de asignación de conductor a vehículo |
| `06_componentes.puml` | Diagrama de componentes del sistema |
| `07_despliegue.puml` | Diagrama de despliegue (infraestructura) |

## 🌐 Visualizar y Descargar en Línea

### Opción 1: PlantUML Online Server (Recomendado)

Visita: **https://www.plantuml.com/plantuml/uml/**

**Pasos:**
1. Abre cualquier archivo `.puml` con VS Code o Notepad
2. Copia todo el contenido del archivo
3. Ve a https://www.plantuml.com/plantuml/uml/
4. Pega el código en el editor
5. El diagrama se genera automáticamente
6. Haz clic derecho en el diagrama → **"Guardar imagen como..."**
7. Descarga en PNG, SVG o PDF

### Opción 2: PlantUML Web Editor

Visita: **http://www.plantuml.com/plantuml/**

**Características:**
- Editor en tiempo real
- Múltiples formatos de exportación (PNG, SVG, PDF, LaTeX)
- URL permanente para compartir
- Sin instalación requerida

### Opción 3: Visual Studio Code

**Instalar extensión:**
1. Abre VS Code
2. Ve a Extensiones (Ctrl+Shift+X)
3. Busca **"PlantUML"** por jebbs
4. Instala la extensión

**Usar:**
1. Abre cualquier archivo `.puml`
2. Presiona **Alt+D** para vista previa
3. Clic derecho → **"Export Current Diagram"**
4. Selecciona formato: PNG, SVG, PDF, etc.

### Opción 4: PlantUML Viewer Online

Visita: **https://plantuml-editor.kkeisuke.com/**

**Ventajas:**
- Interfaz moderna
- Vista previa en tiempo real
- Exportación directa a PNG/SVG
- Soporte para temas personalizados

## 📥 Exportar Todos los Diagramas Rápidamente

### Método 1: Usando PlantUML CLI (Avanzado)

```bash
# Instalar PlantUML (requiere Java)
# Descargar plantuml.jar de https://plantuml.com/download

# Exportar todos los diagramas a PNG
java -jar plantuml.jar -tpng *.puml

# Exportar a SVG (vectorial - mejor calidad)
java -jar plantuml.jar -tsvg *.puml

# Exportar a PDF
java -jar plantuml.jar -tpdf *.puml
```

### Método 2: PlantUML Online Batch

Visita: **https://www.planttext.com/**

1. Pega el código de cada archivo
2. Clic en **"Refresh"** para generar
3. Descarga cada diagrama

## 🎨 Temas Disponibles

Los diagramas usan el tema `cerulean-outline` pero puedes cambiarlos editando la línea:

```plantuml
!theme cerulean-outline
```

**Otros temas disponibles:**
- `bluegray`
- `plain`
- `sketchy-outline`
- `toy`
- `vibrant`
- `amiga`
- `mars`

Para ver todos los temas: https://plantuml.com/theme

## 💡 Consejos

1. **Alta Calidad:** Usa SVG para obtener diagramas vectoriales que no pierden calidad al ampliar
2. **Presentaciones:** PNG con fondo blanco es ideal para Word/PowerPoint
3. **Documentación:** PDF es perfecto para documentos técnicos
4. **Web:** SVG es la mejor opción para páginas web

## 🔧 Personalización

Puedes editar cualquier archivo `.puml` para:
- Cambiar colores
- Agregar más entidades
- Modificar relaciones
- Añadir notas explicativas
- Cambiar el tema visual

## 📚 Recursos Adicionales

- **Documentación oficial:** https://plantuml.com/
- **Sintaxis de clases:** https://plantuml.com/class-diagram
- **Sintaxis de secuencia:** https://plantuml.com/sequence-diagram
- **Sintaxis de componentes:** https://plantuml.com/component-diagram
- **Sintaxis de despliegue:** https://plantuml.com/deployment-diagram

## 📞 Soporte

Si tienes problemas visualizando los diagramas:
1. Verifica que el archivo `.puml` esté completo
2. Usa el validador online: https://www.plantuml.com/plantuml/
3. Revisa que no haya errores de sintaxis

---

**Sistema TRADEX** - Documentación Técnica  
Versión 1.0 | Noviembre 2025
