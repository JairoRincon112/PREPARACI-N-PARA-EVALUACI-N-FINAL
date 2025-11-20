-- 1. Limpieza inicial
DROP TABLE IF EXISTS prescripciones;
DROP TABLE IF EXISTS medicamentos;
DROP TABLE IF EXISTS consultas;
DROP TABLE IF EXISTS hospitalizaciones;
DROP TABLE IF EXISTS habitaciones;
DROP TABLE IF EXISTS medicos;
DROP TABLE IF EXISTS departamentos;
DROP TABLE IF EXISTS pacientes;
DROP TABLE IF EXISTS auditoria_log;

-- 2. Creación de Tablas

CREATE TABLE departamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ubicacion VARCHAR(50)
);

CREATE TABLE pacientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) CHECK (genero IN ('M', 'F', 'O')),
    telefono VARCHAR(20)
);

CREATE TABLE medicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(50),
    departamento_id INT,
    email_corporativo VARCHAR(100),
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
);

CREATE TABLE habitaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10) UNIQUE NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('General', 'UCI', 'Privada')),
    estado VARCHAR(20) DEFAULT 'Disponible' CHECK (estado IN ('Disponible', 'Ocupada', 'Mantenimiento')),
    costo_dia DECIMAL(10, 2) CHECK (costo_dia > 0)
);

CREATE TABLE hospitalizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    habitacion_id INT,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_alta TIMESTAMP NULL DEFAULT NULL,
    diagnostico_ingreso TEXT,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    FOREIGN KEY (habitacion_id) REFERENCES habitaciones(id)
);

CREATE TABLE medicamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    laboratorio VARCHAR(100),
    stock INT CHECK (stock >= 0)
);

CREATE TABLE consultas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medico_id INT,
    paciente_id INT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    diagnostico TEXT,
    FOREIGN KEY (medico_id) REFERENCES medicos(id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
);

CREATE TABLE prescripciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT,
    medicamento_id INT,
    dosis VARCHAR(100) NOT NULL,
    duracion_dias INT,
    FOREIGN KEY (consulta_id) REFERENCES consultas(id),
    FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id)
);

INSERT INTO departamentos (nombre, ubicacion) VALUES 
('Cardiología', 'Piso 1'), ('Pediatría', 'Piso 2'), ('Urgencias', 'PB');

INSERT INTO medicos (dni, nombre, especialidad, departamento_id, email_corporativo) VALUES
('1111', 'Dr. Juan Perez', 'Cardiólogo', 1, 'juan.perez@hospital.com'),
('2222', 'Dra. Ana Gomez', 'Pediatra', 2, 'ana.gomez@hospital.com'),
('3333', 'Dr. Luis Silva', 'Urgenciologo', 3, 'luis.silva@hospital.com');

INSERT INTO pacientes (dni, nombre, fecha_nacimiento, genero) VALUES
('AA123', 'Carlos Ruiz', '1980-05-15', 'M'),
('BB456', 'Maria Lopez', '1992-10-20', 'F'),
('CC789', 'Pedrito Diaz', '2015-01-01', 'M');

INSERT INTO habitaciones (numero, tipo, estado, costo_dia) VALUES
('101', 'General', 'Disponible', 50.00),
('102', 'General', 'Ocupada', 50.00),
('201', 'UCI', 'Disponible', 200.00);

INSERT INTO medicamentos (nombre, stock) VALUES ('Paracetamol', 100), ('Ibuprofeno', 50), ('Amoxicilina', 30);

INSERT INTO hospitalizaciones (paciente_id, habitacion_id, fecha_ingreso) VALUES (2, 2, NOW());
INSERT INTO consultas (medico_id, paciente_id, motivo) VALUES (2, 3, 'Fiebre alta');
INSERT INTO prescripciones (consulta_id, medicamento_id, dosis) VALUES (1, 1, '5ml cada 8 horas');


------------------------------------------------


DELIMITER //

CREATE PROCEDURE generar_datos_masivos()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    -- Desactivar chequeo de claves foráneas temporalmente para agilizar la carga
    SET FOREIGN_KEY_CHECKS = 0;

    -- Limpiar tablas (Opcional: quita los -- si quieres borrar lo anterior)
    -- TRUNCATE TABLE prescripciones;
    -- TRUNCATE TABLE consultas;
    -- TRUNCATE TABLE hospitalizaciones;
    -- TRUNCATE TABLE medicos;
    -- TRUNCATE TABLE pacientes;
    -- TRUNCATE TABLE habitaciones;
    -- TRUNCATE TABLE medicamentos;
    -- TRUNCATE TABLE departamentos;

    -- 1. Generar Departamentos (Solo necesitamos unos pocos, no 500)
    -- Insertamos 5 departamentos base si no existen
    INSERT IGNORE INTO departamentos (nombre, ubicacion) VALUES 
    ('Cardiología', 'Piso 1'), ('Pediatría', 'Piso 2'), ('Urgencias', 'PB'), 
    ('Neurología', 'Piso 3'), ('Dermatología', 'Piso 1');

    -- BUCLE PARA 500 REGISTROS
    WHILE i <= 500 DO
        
        -- 2. Pacientes
        INSERT INTO pacientes (dni, nombre, fecha_nacimiento, genero, telefono)
        VALUES (
            CONCAT('DNI-', i, '-', FLOOR(RAND()*1000)), -- DNI único simulado
            CONCAT('Paciente ', i, ' Apellido'),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 15000) DAY), -- Fecha random
            ELT(FLOOR(1 + RAND() * 3), 'M', 'F', 'O'), -- Genero random
            CONCAT('555-000-', i)
        );

        -- 3. Habitaciones (Generamos números únicos)
        INSERT INTO habitaciones (numero, tipo, estado, costo_dia)
        VALUES (
            CONCAT('H-', i),
            ELT(FLOOR(1 + RAND() * 3), 'General', 'UCI', 'Privada'),
            ELT(FLOOR(1 + RAND() * 3), 'Disponible', 'Ocupada', 'Mantenimiento'),
            ROUND(50 + (RAND() * 300), 2)
        );

        -- 4. Medicamentos
        INSERT INTO medicamentos (nombre, laboratorio, stock)
        VALUES (
            CONCAT('Medicamento Generico ', i),
            CONCAT('Laboratorio ', ELT(FLOOR(1 + RAND() * 4), 'Bayer', 'Pfizer', 'Genfar', 'MK')),
            FLOOR(RAND() * 500)
        );

        -- 5. Médicos (Creamos 500 médicos para el ejercicio)
        INSERT INTO medicos (dni, nombre, especialidad, departamento_id, email_corporativo)
        VALUES (
            CONCAT('MED-', i),
            CONCAT('Dr. Nombre ', i),
            ELT(FLOOR(1 + RAND() * 4), 'General', 'Cirujano', 'Internista', 'Pediatra'),
            FLOOR(1 + RAND() * 5), -- Asigna aleatoriamente a los primeros 5 deptos
            CONCAT('medico', i, '@hospital.com')
        );

        -- 6. Hospitalizaciones
        -- Asigna un paciente random (1 a i) a una habitación random (1 a i)
        INSERT INTO hospitalizaciones (paciente_id, habitacion_id, fecha_ingreso, diagnostico_ingreso)
        VALUES (
            FLOOR(1 + RAND() * i),
            FLOOR(1 + RAND() * i),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY),
            CONCAT('Diagnostico de prueba ', i)
        );

        -- 7. Consultas
        -- Medico random atiende a Paciente random
        INSERT INTO consultas (medico_id, paciente_id, fecha, motivo, diagnostico)
        VALUES (
            FLOOR(1 + RAND() * i),
            FLOOR(1 + RAND() * i),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
            'Dolor de cabeza y fiebre',
            'Gripe estacional'
        );
        
        -- 8. Prescripciones (Para la consulta que acabamos de crear - ID 'i')
        -- Nota: Esto asume que los IDs son autoincrementales y van parejos con 'i'. 
        -- En un entorno real, usaríamos LAST_INSERT_ID().
        INSERT INTO prescripciones (consulta_id, medicamento_id, dosis, duracion_dias)
        VALUES (
            (SELECT MAX(id) FROM consultas), -- Usa la última consulta creada
            FLOOR(1 + RAND() * i), -- Medicamento random
            '1 tableta cada 8 horas',
            7
        );

        SET i = i + 1;
    END WHILE;

    -- Reactivar chequeo de claves
    SET FOREIGN_KEY_CHECKS = 1;
END //

DELIMITER ;

-- EJECUTAR EL PROCEDIMIENTO PARA LLENAR LA BD
CALL generar_datos_masivos();

-- (OPCIONAL) BORRAR EL PROCEDIMIENTO DESPUÉS DE USARLO
-- DROP PROCEDURE generar_datos_masivos;