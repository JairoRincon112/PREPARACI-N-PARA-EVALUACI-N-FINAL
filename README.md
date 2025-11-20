> ### Sistema de Gestión Hospitalaria

> ### Autores: Jairo Andres Rincon Blanco - Andres Camilo Cuvides Ortega

> ### Docente: Hely Suarez Marin


## 1. Descripción del Proyecto
El presente trabajo de BASE DE DATOS consiste en el diseño e implementación de una base de datos relacional robusta para la gestión integral de un centro hospitalario. El sistema administra flujos críticos de información como el ingreso de pacientes, gestión de médicos por departamentos, control de inventario de medicamentos y asignación de habitaciones.

## 2. Arquitectura y Diseño de Datos

### 2.1. Motor de Base de Datos
Se ha seleccionado **MySQL** como motor de base de datos.
* **Justificación:** MySQL ofrece un excelente equilibrio entre rendimiento de lectura/escritura y fiabilidad. Su amplia compatibilidad y soporte para procedimientos almacenados y triggers lo hacen ideal para aplicaciones web de gestión.

### 2.2. Modelo Relacional y Normalización
El esquema cumple con la **Tercera Forma Normal (3FN)** para garantizar la integridad de los datos y evitar redundancias:

* **Entidades Fuertes:** `departamentos`, `pacientes`, `medicamentos`, `habitaciones`. Estas tablas no dependen de otras para existir.
* **Entidades Dependientes:** `medicos` (depende de departamento).
* **Entidades Transaccionales:** `consultas`, `hospitalizaciones`, `prescripciones`. Estas tablas registran los eventos diarios del hospital y conectan las entidades fuertes.

## 3. Diccionario de Datos

| Tabla | Descripción |
| :--- | :--- |
| **departamentos** | Catálogo de áreas médicas (Cardiología, Urgencias, etc.). |
| **medicos** | Personal de salud vinculado a un departamento específico. |
| **pacientes** | Datos demográficos de las personas atendidas. |
| **habitaciones** | Inventario de camas, tipos (UCI, General) y su estado actual. |
| **medicamentos** | Farmacia e inventario disponible. |
| **consultas** | Registro histórico de atenciones ambulatorias. |
| **hospitalizaciones** | Control de ingresos y altas de pacientes en habitaciones. |
| **prescripciones** | Detalle de medicamentos recetados en cada consulta. |
| **auditoria_log** | Tabla técnica para registrar cambios críticos en el sistema automáticamente. |

## 4. Lógica de Negocio y Transaccionalidad (Backend SQL)

Para cumplir con los requisitos de integridad y seguridad, se implementaron lógicas a nivel de base de datos:

### 4.1. Procedimiento: `admision_emergencia`
Este Stored Procedure gestiona el ingreso de pacientes garantizando las propiedades **ACID** (Atomicidad, Consistencia, Aislamiento, Durabilidad).
* **Funcionalidad:** Verifica disponibilidad de habitación, registra el ingreso y cambia el estado de la habitación a "Ocupada" en un solo paso.
* **Control de Concurrencia:** Utiliza `SELECT ... FOR UPDATE` (Bloqueo Pesimista) para evitar que dos recepcionistas asignen la misma habitación simultáneamente.
* **Manejo de Errores:** Si ocurre un fallo, se ejecuta un `ROLLBACK` automático.

### 4.2. Trigger de Auditoría: `trigger_auditoria_hab`
* **Objetivo:** Mantener un rastro inmutable de los cambios en la infraestructura hospitalaria.
* **Funcionamiento:** Se dispara automáticamente `AFTER UPDATE` en la tabla `habitaciones`. Si el estado de una habitación cambia, guarda el usuario, la fecha y los detalles del cambio en `auditoria_log`.

## 5. Seguridad y Control de Acceso

Se implementó un esquema de seguridad basado en el principio de menor privilegio:

1.  **Usuario `medico`:**
    * Acceso de lectura/escritura a tablas clínicas (`consultas`, `recetas`).
    * Solo lectura en tablas administrativas (`medicos`).
2.  **Usuario `recepcionista`:**
    * Gestión de `pacientes` y `hospitalizaciones`.
    * Solo lectura en `habitaciones` para verificar disponibilidad.

## 6. Conclusiones
La base de datos resultante es escalable y segura. La implementación de lógica en el servidor (Triggers/Procedures) reduce la carga en la aplicación cliente y garantiza que las reglas de negocio (como no sobreasignar habitaciones) se cumplan siempre, independientemente de desde dónde se acceda a los datos.
