USE GestionGimnasio
GO

-- RUTINAS
-- Crear rutinas generales
CREATE PROCEDURE SP_Rutina_General
    @NOMBRE VARCHAR(150)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO Rutinas (Nombre, FechaCreacion) VALUES (@NOMBRE, GETDATE());
        COMMIT TRANSACTION;
        PRINT 'OK';
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al crear rutina: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- Crear rutinas personalizada
CREATE PROCEDURE SP_Rutina_Personaliazda_Usuario
    @NOMBRE VARCHAR(150),
    @ID_USUARIO BIGINT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO Rutinas (Nombre,IdUsuario, FechaCreacion) VALUES (@NOMBRE, @ID_USUARIO, GETDATE());
        COMMIT TRANSACTION;
        PRINT 'OK';
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al crear rutina personalizada: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- Modificar rutina general
CREATE PROCEDURE SP_Modificar_Rutina_General
    @ID INT,
    @NOMBRE VARCHAR(150)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            UPDATE Rutinas SET Nombre = @NOMBRE WHERE IdRutinas = @ID;
        COMMIT TRANSACTION;
        PRINT 'OK';
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al modificar la rutina: ' + ERROR_MESSAGE();
    END CATCH
END;

GO

-- Modificar rutina personalizada
CREATE PROCEDURE SP_Modificar_Rutina_Personaliazda_Usuario
    @ID INT,
    @ID_USUARIO BIGINT,
    @NOMBRE VARCHAR(150)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            UPDATE Rutinas SET Nombre = @NOMBRE, IdUsuario = @ID_USUARIO WHERE IdRutinas = @ID;;
        COMMIT TRANSACTION;
        PRINT 'OK';
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al modificar la rutina personalizada: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Obtener los ejercicios (con detalle) de una rutina
CREATE PROCEDURE sp_EjerciciosDeRutina (@IdRutina INT)
AS
BEGIN
	SELECT
		RE.IdRutinasEjercicios  AS IdRutinaEjercicio,
		RE.ObjetivoKG           AS ObjetivoKG,
		RE.ObjetivoSeries       AS ObjetivoSeries,
		RE.ObjetivoRepeticiones AS ObjetivoRepeticiones,
		RE.OrdenEjercicio       AS OrdenEjercicio,
		E.IdEjercicios          AS IdEjercicio,
		E.Nombre                AS NombreEjercicio,
		GM.IdGruposMusculares   AS IdGrupoMuscular,
		GM.Nombre               AS NombreGrupoMuscular
	FROM RutinaEjercicios RE
	INNER JOIN Ejercicios E
		ON RE.IdEjercicio = E.IdEjercicios
	LEFT JOIN GruposMusculares GM
		ON E.IdGrupoMuscular = GM.IdGruposMusculares
	WHERE RE.IdRutina = @IdRutina
	ORDER BY RE.OrdenEjercicio
END
GO

-- SUSCRIPCIONES
-- Crear suscripcion
CREATE PROCEDURE sp_CrearSuscripcion (
	@IdUsuario INT,
	@IdPlan SMALLINT,
	@IdEstado TINYINT,
	@FechaInicio DATE,
	@FechaVencimiento DATE
)
AS
BEGIN
	INSERT INTO Suscripciones (IdUsuario, IdPlan, IdEstado, FechaInicio, FechaVencimiento)
	VALUES (@IdUsuario, @IdPlan, @IdEstado, @FechaInicio, @FechaVencimiento)
END
GO

-- Modificar suscripcion
CREATE PROCEDURE sp_ModificarSuscripcion (
	@IdUsuario INT,
	@IdPlan SMALLINT,
	@IdEstado TINYINT,
	@FechaInicio DATE,
	@FechaVencimiento DATE,
	@IdSuscripcion INT
)
AS
BEGIN
	UPDATE Suscripciones SET
		IdUsuario = @IdUsuario,
		IdPlan = @IdPlan,
		IdEstado = @IdEstado,
		FechaInicio = @FechaInicio,
		FechaVencimiento = @FechaVencimiento
	WHERE IdSuscripciones = @IdSuscripcion
END
GO

-- Actualizar el estado de las suscripciones vencidas
Create PROCEDURE SP_Suscripciones_actualizar_estado_vencidas
AS
BEGIN 
    UPDATE Suscripciones
    SET IdEstado = 2
    WHERE FechaVencimiento < GETDATE() AND IdEstado = 1;
END;
GO

-- Obtener datos completos de la suscripcion de un usuario
CREATE PROCEDURE sp_SuscripcionCompleta (@ID INTEGER, @IdEstado INTEGER)
AS
BEGIN
	SELECT TOP 1
		S.IdSuscripciones   as IdSuscripcion,
		S.FechaInicio       as FechaInicio,
		S.FechaVencimiento  as FechaVencimiento,
		S.IdPlan            as IdPlan,
		S.IdEstado          as IdEstado,
		P.Nombre            as NombrePlan,
		P.PrecioMensual     as PrecioPlan,
		P.DuracionDias      as DuracionPlan
	FROM Suscripciones S
	LEFT JOIN Planes P
		ON S.IdPlan = P.IdPlanes
	WHERE S.IdUsuario = @ID AND S.IdEstado = @IdEstado
	ORDER BY S.FechaVencimiento ASC
END
GO

-- USUARIOS
-- Creacion
CREATE PROCEDURE sp_CrearUsuario (
	@Nombre VARCHAR(70),
	@Apellido VARCHAR(70),
	@Email VARCHAR(150),
	@FechaNacimiento DATETIME,
	@PesoCorporalKG DECIMAL(5, 2),
	@IdRol TINYINT,
	@FechaIngreso DATETIME,
	@Pass VARCHAR(40)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @IdUsuario INT; 
			INSERT INTO Usuarios (Nombre, Apellido, Email, FechaNacimiento, PesoCorporalKG, IdRol, FechaIngreso)
			VALUES (@Nombre, @Apellido, @Email, @FechaNacimiento, @PesoCorporalKG, @IdRol, @FechaIngreso)
			SET @IdUsuario = (SELECT SCOPE_IDENTITY());
			INSERT INTO AccesoUsuarios (IdUsuarios, Pass)
			VALUES (@IdUsuario, @Pass)
		COMMIT TRANSACTION
		SELECT @IdUsuario
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al registrar usuario: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-- Modificacion
CREATE PROCEDURE sp_ModificarUsuario (
	@Nombre VARCHAR(70),
	@Apellido VARCHAR(70),
	@Email VARCHAR(150),
	@FechaNacimiento DATETIME,
	@PesoCorporal DECIMAL(5, 2),
	@IdRol TINYINT,
	@FechaIngreso DATETIME,
	@Activo BIT,
	@IdUsuario INT,
	@Pass VARCHAR(150)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE Usuarios SET
				Nombre = @Nombre, 
				Apellido = @Apellido, 
				Email = @Email, 
				FechaNacimiento = @FechaNacimiento,
				PesoCorporalKG = @PesoCorporal, 
				IdRol = @IdRol, 
				FechaIngreso = @FechaIngreso,
				Activo = @Activo
			WHERE IdUsuarios = @IdUsuario
			IF @Pass IS NOT NULL AND @Pass != ''
			BEGIN
				UPDATE AccesoUsuarios SET
					Pass = @Pass
				WHERE IdUsuarios = @IdUsuario
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	END CATCH
END
GO


-- Obtener usuarios dependiendo del rol. Acepta la cadena 'TODOS' para obtener todos los usuarios sin filtro
CREATE PROCEDURE sp_ObtenerUsuarios (@Rol VARCHAR(50))
AS
BEGIN
	IF @Rol = 'TODOS'
		BEGIN
			SELECT * FROM Usuarios
		END
	ELSE
		BEGIN
			SELECT IdUsuarios, Usuarios.Nombre, Apellido, Email, FechaNacimiento, PesoCorporalKG, IdRol, FechaIngreso, Activo
			FROM Usuarios
			LEFT JOIN Roles
				ON Roles.IdRoles = Usuarios.IdRol
			WHERE Roles.Nombre = @Rol
		END
END
GO

-- RECORDS
-- Obtener records personales del usuario
CREATE PROCEDURE sp_RecordsPersonales (@ID INTEGER)
AS
BEGIN
	SELECT
		SC.PesoLevantadoKG		as PesoKG,
		E.IdEjercicios			as IdEjercicio,
		E.Nombre				as EjercicioNombre,
		GM.IdGruposMusculares	as IdGrupoMuscular,
		GM.Nombre				as GrupoMuscularNombre
	FROM SeriesCompletadas AS SC
	LEFT JOIN Ejercicios as E
		ON E.IdEjercicios = SC.IdEjercicio
	LEFT JOIN GruposMusculares as GM
		ON GM.IdGruposMusculares = E.IdGrupoMuscular
	WHERE EsRecordPersonal = 1
END
GO

-- SESIONES DE ENTRENAMIENTO
-- Creacion
CREATE PROCEDURE sp_CrearSesionEntrenamiento (
	@IdUsuario INT,
	@IdRutina INT,
	@FechaHoraInicio DATETIME,
	@FechaHoraFin DATETIME
)
AS
BEGIN
	INSERT INTO SesionesEntrenamiento (IdUsuario, IdRutina, FechaHoraInicio, FechaHoraFin)
	VALUES (@IdUsuario, @IdRutina, @FechaHoraInicio, @FechaHoraFin)
END
GO

-- Modificacion
CREATE PROCEDURE sp_ModificarSesionEntrenamiento (
	@IdSesion INT,
	@IdUsuario INT,
	@IdRutina INT,
	@FechaHoraInicio DATETIME,
	@FechaHoraFin DATETIME
)
AS
BEGIN
	UPDATE SesionesEntrenamiento SET
		IdUsuario = @IdUsuario,
		IdRutina = @IdRutina,
		FechaHoraInicio = @FechaHoraInicio,
		FechaHoraFin = @FechaHoraFin
	WHERE IdSesionesEntrenamiento = @IdSesion
END
GO

--Busca coincidencia de alguna instancia en una vista VW_Usuarios y trae todos los atributos 
CREATE PROCEDURE sp_logueo
	@Email VARCHAR(100),
	@Pass VARCHAR(100)
AS
BEGIN
SELECT IdUsuarios, 
Nombre, 
Apellido, 
Email, 
FechaNacimiento, 
PesoCorporalKG, 
IdRol, 
[Rol Nombre], 
FechaIngreso, 
IdPlan, [Plan], 
Activo, 
PrecioMensual, 
DuracionDias,
IdEstado, Estado, 
FechaInicio, 
FechaVencimiento 
FROM VW_Usuarios 
WHERE Email = @Email AND Pass = @Pass
END
GO

CREATE PROCEDURE [dbo].[sp_Traer_Admins]
AS
  BEGIN
    SELECT U.IdUsuarios, 
    U.Nombre, 
    U.Apellido, 
    U.Email, 
    U.FechaNacimiento AS [Fecha de Nacimiento],
    U.IdRol,
    R.Nombre AS [Rol],
    U.FechaIngreso AS [Fecha de Ingreso],
    U.Activo
    FROM Usuarios U
    INNER JOIN Roles R ON U.IdRol = R.IdRoles
    WHERE U.IdRol = 1
END;
GO

CREATE PROCEDURE [dbo].[sp_Traer_Entrenadores]
AS
  BEGIN
    SELECT U.IdUsuarios, 
    U.Nombre, 
    U.Apellido, 
    U.Email, 
    U.FechaNacimiento AS [Fecha de Nacimiento],
    U.IdRol,
    R.Nombre AS [Rol],
    U.FechaIngreso AS [Fecha de Ingreso],
    U.Activo
    FROM Usuarios U
    INNER JOIN Roles R ON U.IdRol = R.IdRoles
    WHERE U.IdRol = 4
END;
GO

CREATE PROCEDURE [dbo].[sp_Traer_Recepcionistas]
AS
  BEGIN
    SELECT U.IdUsuarios, 
    U.Nombre, 
    U.Apellido, 
    U.Email, 
    U.FechaNacimiento AS [Fecha de Nacimiento],
    U.IdRol,
    R.Nombre AS [Rol],
    U.FechaIngreso AS [Fecha de Ingreso],
    U.Activo
    FROM Usuarios U
    INNER JOIN Roles R ON U.IdRol = R.IdRoles
    WHERE U.IdRol = 2
END;
GO

ALTER PROCEDURE [dbo].[sp_Traer_Clientes]
AS
  BEGIN
    SELECT U.IdUsuarios, 
    U.Nombre, 
    U.Apellido, 
    U.Email, 
    U.FechaNacimiento AS [Fecha de Nacimiento],
    U.IdRol,
    R.Nombre AS [Rol],
    U.FechaIngreso AS [Fecha de Ingreso],
    U.PesoCorporalKG,
    S.IdEstado,
    SE.Nombre,
    U.Activo
    FROM Usuarios U
    LEFT JOIN Roles R ON U.IdRol = R.IdRoles
    LEFT JOIN Suscripciones S ON S.IdUsuario = U.IdUsuarios
    LEFT JOIN SuscripcionesEstados SE ON SE.IdSuscripcionesEstados = S.IdEstado
    WHERE U.IdRol = 3
END;
GO

CREATE PROCEDURE sp_Traer_Estados_De_Suscripciones
AS 
BEGIN
SELECT IdSuscripcionesEstados, Nombre FROM SuscripcionesEstados
END;
GO


CREATE PROCEDURE sp_RegistrarSerieCompletada
(
    @IdSesion INT,
    @IdEjercicio INT,
    @Peso SMALLINT,
    @Repeticiones SMALLINT,
    @RIR TINYINT
)
AS
BEGIN

    INSERT INTO SeriesCompletadas
    (
        IdSesion,
        IdEjercicio,
        PesoLevantadoKG,
        RepeticionesLogradas,
        RIR
    )
    VALUES
    (
        @IdSesion,
        @IdEjercicio,
        @Peso,
        @Repeticiones,
        @RIR
    );

END;
GO

CREATE PROCEDURE sp_RenovarSuscripcion
(
    @IdUsuario INT,
    @IdPlan SMALLINT
)
AS
BEGIN

    DECLARE @DuracionDias INT;

    SELECT @DuracionDias = DuracionDias
    FROM Planes
    WHERE IdPlanes = @IdPlan;

    INSERT INTO Suscripciones
    (
        IdUsuario,
        IdPlan,
        IdEstado,
        FechaInicio,
        FechaVencimiento
    )
    VALUES
    (
        @IdUsuario,
        @IdPlan,
        1,
        GETDATE(),
        DATEADD(DAY, @DuracionDias, GETDATE())
    );

END;
GO

CREATE PROCEDURE sp_HistorialEntrenamientosUsuario
(
    @IdUsuario INT
)
AS
BEGIN

    SELECT
        SE.IdSesionesEntrenamiento AS IdSesion,
        R.Nombre AS Rutina,
        SE.FechaHoraInicio,
        SE.FechaHoraFin,
        DATEDIFF
        (
            MINUTE,
            SE.FechaHoraInicio,
            SE.FechaHoraFin
        ) AS DuracionMinutos

    FROM SesionesEntrenamiento SE

    LEFT JOIN Rutinas R
        ON R.IdRutinas = SE.IdRutina

    WHERE SE.IdUsuario = @IdUsuario

    ORDER BY SE.FechaHoraInicio DESC;

END;
GO