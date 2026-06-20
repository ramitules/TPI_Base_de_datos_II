USE GestionGimnasio
GO

---------------------------------------------------------------------------------------------------------------------
-- Vista de Suscripciones por Usuario

-- La vista sirve para consultar informaci�n sobre las suscripciones de los usuarios del gimnasio,
-- incluyendo el plan contratado, estado de la suscripci�n, fechas de vigencia y d�as restantes hasta el vencimiento.
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
-- mostrando la rutina utilizada, fecha, horario y duraci�n de cada entrenamiento.
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


----------------------------------------------------------------------------------
-- Vista de todos los usuarios del sistema con sus respectivos atributos

-- La vista sirve para consultar todos los datos necesario para instanciar los distintos tipos de usuarios y a la vez para la consulta del logueo
----------------------------------------------------------------------------------
CREATE VIEW VW_Usuarios AS
SELECT U.IdUsuarios, U.Nombre, U.Apellido, U.Email, U.FechaNacimiento, U.PesoCorporalKG, U.IdRol, R.Nombre AS [Rol Nombre], U.FechaIngreso, S.IdPlan, U.Activo, P.Nombre AS [Plan], P.PrecioMensual, P.DuracionDias, S.IdEstado, SE.Nombre AS [Estado], S.FechaInicio, S.FechaVencimiento, AU.Pass FROM Usuarios U
LEFT JOIN Suscripciones S ON U.IdUsuarios = S.IdUsuario
LEFT JOIN Planes P ON P.IdPlanes = S.IdPlan
LEFT JOIN SuscripcionesEstados SE ON S.IdEstado = SE.IdSuscripcionesEstados
LEFT JOIN Roles R ON U.IdRol = R.IdRoles
LEFT JOIN AccesoUsuarios AU ON U.IdUsuarios = AU.IdUsuarios