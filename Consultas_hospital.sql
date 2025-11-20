-- 1. Estadísticas: Total de médicos por departamento
SELECT d.nombre AS departamento, COUNT(m.id) AS total_medicos
FROM departamentos d
LEFT JOIN medicos m ON d.id = m.departamento_id
GROUP BY d.nombre;

-- 2. Historial Clínico: Consultas de pacientes con detalle del médico
SELECT p.nombre AS paciente, m.nombre AS medico, c.fecha, c.motivo
FROM pacientes p
JOIN consultas c ON p.id = c.paciente_id
JOIN medicos m ON c.medico_id = m.id
ORDER BY c.fecha DESC;

-- 3. Gestión de Camas: Ver habitaciones ocupadas y quién las ocupa
SELECT h.numero, h.tipo, p.nombre AS paciente_actual
FROM habitaciones h
JOIN hospitalizaciones hos ON h.id = hos.habitacion_id
JOIN pacientes p ON hos.paciente_id = p.id
WHERE h.estado = 'Ocupada' AND hos.fecha_alta IS NULL;

-- 4. Farmacia: Los 10 medicamentos más recetados
SELECT med.nombre, COUNT(pre.id) AS veces_recetado
FROM medicamentos med
JOIN prescripciones pre ON med.id = pre.medicamento_id
GROUP BY med.nombre
ORDER BY veces_recetado DESC
LIMIT 10;

-- 5. Rendimiento: Médicos con mayor cantidad de consultas atendidas
SELECT m.nombre, COUNT(c.id) AS total_consultas
FROM medicos m
LEFT JOIN consultas c ON m.id = c.medico_id
GROUP BY m.nombre
ORDER BY total_consultas DESC;