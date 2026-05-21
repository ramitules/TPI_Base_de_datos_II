USE GestionGimnasio
GO

---------------------------------------------------------------------------------------------------------------------
-- Vista de Suscripciones por Usuario

-- La vista sirve para consultar información sobre las suscripciones de los usuarios del gimnasio,
-- incluyendo el plan contratado, estado de la suscripción, fechas de vigencia y días restantes hasta el vencimiento.
---------------------------------------------------------------------------------------------------------------------

--CREATE VIEW VW_SuscripcionesUsuarios
--AS
SELECT
    u.ID AS IDUsuario,
    u.NombreCompleto,
    u.Email,
    p.Nombre AS 'Plan',
    p.PrecioMensual,
    se.Nombre AS EstadoSuscripcion,
    s.FechaInicio,
    s.FechaVencimiento,
    CASE
        WHEN s.FechaVencimiento < GETDATE() THEN 0
        ELSE DATEDIFF(DAY, GETDATE(), s.FechaVencimiento)
    END AS DiasRestantes
FROM Suscripciones s
INNER JOIN Usuarios u
    ON s.IdUsuario = u.ID
INNER JOIN Planes p
    ON s.IdPlan = p.ID
INNER JOIN SuscripcionesEstados se
    ON s.IdEstado = se.ID

GO

----------------------------------------------------------------------------------
-- Vista de Historial de Entrenamiento

-- La vista sirve para consultar un resumen de las sesiones de entrenamiento realizadas por los usuarios del gimnasio,
-- mostrando la rutina utilizada, fecha, horario y duración de cada entrenamiento.
----------------------------------------------------------------------------------

--CREATE VIEW VW_HistorialEntrenamientoUsuarios
--AS
SELECT
    se.ID AS IDSesion,
    u.NombreCompleto AS Usuario,
    r.Nombre AS Rutina,
    CAST(se.FechaHoraInicio AS DATE) AS FechaEntrenamiento,
    CAST(se.FechaHoraInicio AS TIME) AS HoraInicio,
    CAST(se.FechaHoraFin AS TIME) AS HoraFin,
    DATEDIFF(MINUTE, se.FechaHoraInicio, se.FechaHoraFin)
        AS DuracionEntrenamientoMinutos
FROM SesionesEntrenamiento se
INNER JOIN Usuarios u
    ON se.IdUsuario = u.ID
LEFT JOIN Rutinas r
    ON se.IdRutina = r.ID

GO

