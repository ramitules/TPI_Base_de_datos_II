USE GestionGimnasio
GO


--Crear y modificar las rutinas para los socios.

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
            UPDATE Rutinas SET Nombre = @NOMBRE WHERE ID = @ID;
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
            UPDATE Rutinas SET Nombre = @NOMBRE, IdUsuario = @ID_USUARIO WHERE ID = @ID;;
        COMMIT TRANSACTION;
        PRINT 'OK';
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   
        PRINT 'Error al modificar la rutina personalizada: ' + ERROR_MESSAGE();
    END CATCH
END;

GO


