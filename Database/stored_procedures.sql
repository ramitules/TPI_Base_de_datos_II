USE GestionGimnasio
GO

--Crear rutinas generales
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

--Crear rutinas personalizada
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


--

--Modificar rutina general
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

--Modificar rutina personalizada
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

-- SUSCRIPCIONES

-- Actualizar el estado de las suscripciones vencidas
Create PROCEDURE SP_Suscripciones_actualizar_estado_vencidas
AS
BEGIN 
    UPDATE Suscripciones
    SET IdEstado = 2
    WHERE FechaVencimiento < GETDATE() AND IdEstado = 1;
END;

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

-- Obtener datos completos de las suscripciones de un usuario
CREATE PROCEDURE sp_SuscripcionCompleta (@ID INTEGER)
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
	WHERE S.IdUsuario = @ID
	ORDER BY S.FechaVencimiento ASC
END
GO


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


-- Crear usuario
CREATE PROCEDURE sp_CrearUsuario (
	@Nombre VARCHAR(70),
	@Apellido VARCHAR(70),
	@Email VARCHAR(150),
	@FechaNacimiento DATETIME,
	@PesoCorporalKG DECIMAL(5, 2),
	@IdRol TINYINT,
	@FechaIngreso DATETIME,
	@CodUser VARCHAR(20),
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
			INSERT INTO AccesoUsuarios (IdUsuarios, CodUser, Pass)
			VALUES (@IdUsuario, @CodUser, @Pass)
		COMMIT TRANSACTION
		SELECT @IdUsuario
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al registrar usuario: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-- Modificar usuario
CREATE PROCEDURE sp_ModificarUsuario (
	@Nombre VARCHAR(70),
	@Apellido VARCHAR(70),
	@Email VARCHAR(150),
	@FechaNacimiento DATETIME,
	@PesoCorporal DECIMAL(5, 2),
	@IdRol TINYINT,
	@FechaIngreso DATETIME,
	@IdUsuario INT
)
AS
BEGIN
	UPDATE Usuarios SET
		Nombre = @Nombre, 
		Apellido = @Apellido, 
		Email = @Email, 
		FechaNacimiento = @FechaNacimiento,
		PesoCorporalKG = @PesoCorporal, 
		IdRol = @IdRol, 
		FechaIngreso = @FechaIngreso
	WHERE IdUsuarios = @IdUsuario
END

