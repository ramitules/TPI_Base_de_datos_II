USE GestionGimnasio;
GO

---------------------------------------------------------------------------------------------------------------------
-- Vista de Suscripciones por Usuario

-- Permite consultar las suscripciones registradas, incluyendo plan contratado,
-- estado actual, fechas de vigencia y días restantes hasta el vencimiento.
---------------------------------------------------------------------------------------------------------------------

CREATE VIEW VW_SuscripcionesUsuarios
AS
SELECT
    U.IdUsuarios AS IdUsuario,
    U.Nombre,
    U.Apellido,
    U.Email,

    P.Nombre AS 'Plan',
    P.PrecioMensual,

    SE.Nombre AS EstadoRegistrado,

    CASE
        WHEN S.FechaVencimiento < GETDATE()
            THEN 'Vencida'
        ELSE 'Vigente'
    END AS EstadoReal,

    CASE
        WHEN S.IdEstado = 1
            THEN DATEDIFF(DAY, GETDATE(), S.FechaVencimiento)
        ELSE NULL
    END AS DiasRestantes,

    S.FechaInicio,
    S.FechaVencimiento

FROM Suscripciones S
INNER JOIN Usuarios U
    ON S.IdUsuario = U.IdUsuarios
INNER JOIN Planes P
    ON S.IdPlan = P.IdPlanes
INNER JOIN SuscripcionesEstados SE
    ON S.IdEstado = SE.IdSuscripcionesEstados;
GO

--------------------------------------------------------------------------------------------------
-- Vista de Historial de Entrenamiento

-- Permite consultar las sesiones realizadas por los usuarios, mostrando
-- la rutina utilizada, fecha de entrenamiento y duración de cada sesión.
--------------------------------------------------------------------------------------------------

CREATE VIEW VW_HistorialEntrenamientoUsuarios
AS
SELECT
    SE.IdSesionesEntrenamiento AS IdSesion,
    U.Nombre + ' ' + U.Apellido AS Usuario,
    R.Nombre AS Rutina,
    CAST(SE.FechaHoraInicio AS DATE) AS FechaEntrenamiento,
    CAST(SE.FechaHoraInicio AS TIME) AS HoraInicio,
    CAST(SE.FechaHoraFin AS TIME) AS HoraFin,
    DATEDIFF(MINUTE, SE.FechaHoraInicio, SE.FechaHoraFin) AS DuracionEntrenamientoMinutos
FROM SesionesEntrenamiento SE
INNER JOIN Usuarios U
    ON SE.IdUsuario = U.IdUsuarios
LEFT JOIN Rutinas R
    ON SE.IdRutina = R.IdRutinas;
GO

--------------------------------------------------------------------------------------------------
-- Vista de Usuarios

-- Permite obtener toda la información necesaria para consultas de usuarios
-- y validación de acceso al sistema.
--------------------------------------------------------------------------------------------------

CREATE VIEW VW_Usuarios
AS
SELECT
    U.IdUsuarios,
    U.Nombre,
    U.Apellido,
    U.Email,
    U.FechaNacimiento,
    U.PesoCorporalKG,
    U.IdRol,
    R.Nombre AS [Rol Nombre],
    U.FechaIngreso,
    S.IdPlan,
    U.Activo,
    P.Nombre AS [Plan],
    P.PrecioMensual,
    P.DuracionDias,
    S.IdEstado,
    SE.Nombre AS [Estado],
    S.FechaInicio,
    S.FechaVencimiento,
    AU.Pass
FROM Usuarios U
LEFT JOIN Suscripciones S
    ON U.IdUsuarios = S.IdUsuario
LEFT JOIN Planes P
    ON P.IdPlanes = S.IdPlan
LEFT JOIN SuscripcionesEstados SE
    ON SE.IdSuscripcionesEstados = S.IdEstado
LEFT JOIN Roles R
    ON U.IdRol = R.IdRoles
LEFT JOIN AccesoUsuarios AU
    ON U.IdUsuarios = AU.IdUsuarios;
GO

--------------------------------------------------------------------------------------------------
-- Vista de Resumen de Entrenamientos

-- Permite visualizar estadísticas generales de entrenamiento de los clientes,
-- incluyendo cantidad de sesiones, tiempo total entrenado y último entrenamiento.
--------------------------------------------------------------------------------------------------

CREATE VIEW VW_ResumenEntrenamientos
AS
SELECT
    U.IdUsuarios,
    U.Nombre,
    U.Apellido,

    COUNT(SE.IdSesionesEntrenamiento) AS CantidadSesiones,

    SUM(
        DATEDIFF(
            MINUTE,
            SE.FechaHoraInicio,
            SE.FechaHoraFin
        )
    ) AS MinutosTotalesEntrenados,

    AVG(
        DATEDIFF(
            MINUTE,
            SE.FechaHoraInicio,
            SE.FechaHoraFin
        )
    ) AS PromedioMinutosEntrenamiento,

    MAX(SE.FechaHoraInicio) AS UltimoEntrenamiento

FROM Usuarios U
LEFT JOIN SesionesEntrenamiento SE
    ON U.IdUsuarios = SE.IdUsuario
WHERE U.IdRol = 3
GROUP BY
    U.IdUsuarios,
    U.Nombre,
    U.Apellido;
GO

--------------------------------------------------------------------------------------------------
-- Vista de Records Personales

-- Permite consultar los records personales alcanzados por los usuarios
-- para cada ejercicio registrado en el sistema.
--------------------------------------------------------------------------------------------------

CREATE VIEW VW_RecordsPersonales
AS
SELECT
    U.IdUsuarios,
    U.Nombre,
    U.Apellido,
    E.Nombre AS Ejercicio,
    GM.Nombre AS GrupoMuscular,
    SC.PesoLevantadoKG,
    SC.RepeticionesLogradas,
    SE.FechaHoraInicio AS FechaRecord

FROM SeriesCompletadas SC
INNER JOIN SesionesEntrenamiento SE
    ON SC.IdSesion = SE.IdSesionesEntrenamiento
INNER JOIN Usuarios U
    ON U.IdUsuarios = SE.IdUsuario
INNER JOIN Ejercicios E
    ON E.IdEjercicios = SC.IdEjercicio
LEFT JOIN GruposMusculares GM
    ON GM.IdGruposMusculares = E.IdGrupoMuscular
WHERE SC.EsRecordPersonal = 1;