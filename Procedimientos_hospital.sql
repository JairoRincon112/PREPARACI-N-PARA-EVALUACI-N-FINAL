DELIMITER //

-- Procedimiento ACID para ingreso de emergencia
CREATE PROCEDURE admision_emergencia(
    IN p_paciente_id INT,
    IN p_habitacion_id INT,
    IN p_diagnostico TEXT
)
BEGIN
    DECLARE v_estado_hab VARCHAR(20);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Bloqueo pesimista para evitar concurrencia
    SELECT estado INTO v_estado_hab 
    FROM habitaciones 
    WHERE id = p_habitacion_id 
    FOR UPDATE;

    IF v_estado_hab != 'Disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La habitación no está disponible.';
    ELSE
        INSERT INTO hospitalizaciones (paciente_id, habitacion_id, fecha_ingreso, diagnostico_ingreso)
        VALUES (p_paciente_id, p_habitacion_id, NOW(), p_diagnostico);

        UPDATE habitaciones SET estado = 'Ocupada' WHERE id = p_habitacion_id;
        
        COMMIT;
    END IF;
END //

-- Trigger para auditar cambios en habitaciones
CREATE TRIGGER trigger_auditoria_hab
AFTER UPDATE ON habitaciones
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria_log (tabla_afectada, accion, usuario, detalles)
        VALUES ('habitaciones', 'UPDATE', CURRENT_USER(), 
                CONCAT('Cambio de estado de ', OLD.estado, ' a ', NEW.estado, ' en hab ', OLD.numero));
    END IF;
END //

DELIMITER ;