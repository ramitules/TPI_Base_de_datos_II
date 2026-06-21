USE GestionGimnasio
GO

-- EN PREPARACION (MIGUE)
-- Trigger para detectar un record personal y actualizar EsRecordPersonal.
CREATE TRIGGER tr_DetectarRecordPersonal ON SeriesCompletadas
AFTER INSERT
AS
BEGIN
    -- A realizar domingo 22
END;
GO

-- EN PREPARACION (MIGUE)
-- Trigger para validar que los socios esten activos antes de iniciar una sesion de entrenamiento.
CREATE TRIGGER tr_ValidarSesionConSuscripcionActiva ON SesionesEntrenamiento
AFTER INSERT
AS
BEGIN
    -- A realizar domingo 22
END;
GO

-- EN PREPARACION (MIGUE)
-- Trigger para validar que no se elija la misma rutina para el mismo socio el mismo dia.
CREATE TRIGGER tr_ValidarRutinaMismoDia ON Rutinas
AFTER INSERT, UPDATE
AS
BEGIN
    -- A realizar domingo 22
END;
GO
