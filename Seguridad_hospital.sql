-- Creacion de Usuarios y Permisos (Equivalente a Roles en MySQL)

-- 1. Administrador del Hospital (Permisos Totales)
CREATE USER 'admin_hospital'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON hospital_db.* TO 'admin_hospital'@'localhost';

-- 2. Rol Médico (Solo datos clínicos y lectura de sus datos)
CREATE USER 'medico'@'localhost' IDENTIFIED BY 'med123';
-- Puede ver y crear consultas, recetas y hospitalizaciones
GRANT SELECT, INSERT, UPDATE ON hospital_db.consultas TO 'medico'@'localhost';
GRANT SELECT, INSERT, UPDATE ON hospital_db.prescripciones TO 'medico'@'localhost';
GRANT SELECT, INSERT, UPDATE ON hospital_db.hospitalizaciones TO 'medico'@'localhost';
-- Solo puede leer datos de departamentos y colegas, no modificar
GRANT SELECT ON hospital_db.medicos TO 'medico'@'localhost';
GRANT SELECT ON hospital_db.departamentos TO 'medico'@'localhost';

-- 3. Rol Recepcionista (Gestión administrativa básica)
CREATE USER 'recepcionista'@'localhost' IDENTIFIED BY 'recep123';
-- Puede gestionar pacientes y ver disponibilidad de habitaciones
GRANT SELECT, INSERT, UPDATE ON hospital_db.pacientes TO 'recepcionista'@'localhost';
GRANT SELECT ON hospital_db.habitaciones TO 'recepcionista'@'localhost';
-- No puede ver prescripciones ni diagnósticos detallados (Solo inserción en urgencia)
GRANT INSERT ON hospital_db.hospitalizaciones TO 'recepcionista'@'localhost';

FLUSH PRIVILEGES;

-- Mostrar usuarios creados

SELECT User, Host FROM mysql.user

-- Mostrar permisos creados

SHOW GRANTS FOR 'medico'@'localhost';
SHOW GRANTS FOR 'recepcionista'@'localhost' ;