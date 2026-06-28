USE GestionGimnasio
GO

-- EN PREPARACION (MIGUE)
-- Trigger para detectar un record personal y actualizar EsRecordPersonal.
-- Regla de negocio: Si el Peso levantado empata el Record para el ejercicio se verifica las repeticiones.
-- Observaciones: En vez de buscar por la bandera vamos directo a los datos.


CREATE TRIGGER tr_DetectarRecordPersonal ON SeriesCompletadas
AFTER INSERT 
AS
BEGIN
    -- Primero seteamos los records en cero para los usuarios y ejercicios que estan en el inserted.

    UPDATE SeriesCompletadas
    SET SC.EsRecordPersonal = 0
    FROM SeriesCompletadas SC
        INNER JOIN SesionesEntrenamiento SE ON SC.IdSesion = SE.IdSesionesEntrenamiento
        INNER JOIN inserted i ON SC.IdEjercicio = i.IdEjercicio
        INNER JOIN SesionesEntrenamiento SEI ON i.IdSesion = SEI.IdSesionesEntrenamiento
    WHERE SE.IdUsuario = SEI.IdUsuario 
        AND SC.IdEjercicio = i.IdEjercicio
        AND SC.EsRecordPersonal = 1;

    
    -- Segundo identificamos y marcamos de nuevo los récords
    SET SC.EsRecordPersonal = 1
    FROM SeriesCompletadas SC
    INNER JOIN inserted i ON SC.IdSeriesCompletadas = i.IdSeriesCompletadas
    INNER JOIN SesionesEntrenamiento SE ON i.IdSesion = SE.IdSesionesEntrenamiento
    -- Intentamos unir con cualquier serie "mejor" del mismo usuario y ejercicio
    LEFT JOIN SeriesCompletadas SC2 ON SC2.IdEjercicio = i.IdEjercicio
        AND SC2.IdSeriesCompletadas <> i.IdSeriesCompletadas 
        AND (
            SC2.PesoLevantadoKG > i.PesoLevantadoKG 
            OR (SC2.PesoLevantadoKG = i.PesoLevantadoKG AND SC2.RepeticionesLogradas >= i.RepeticionesLogradas)
        )
    LEFT JOIN SesionesEntrenamiento SE2 ON SC2.IdSesion = SE2.IdSesionesEntrenamiento
        AND SE2.IdUsuario = SE.IdUsuario
    WHERE SC2.IdSeriesCompletadas IS NULL; 
END;
GO

-- Trigger para validar que los socios esten activos antes de iniciar una sesion de entrenamiento.
-- Regla de negocio: Si el socio no tiene suscripcion activa no puede uniciar una sesion de entrenamiento.

CREATE TRIGGER tr_ValidarSesionConSuscripcionActiva ON SesionesEntrenamiento
INSTEAD OF INSERT
AS
BEGIN
    Declare @IdUsuario INT;
    Declare @IdRutina INT;
    Declare @FechaHoraInicio DATETIME;
    Declare @FechaHoraFin DATETIME;

    --Capturo del Inserted

    Select @IdUsuario=IdUsuario, @IdRutina=IdRutina, @FechaHoraInicio=FechaHoraInicio, @FechaHoraFin=FechaHoraFin FROM inserted;

    --Chequeo si existe

    IF (dbo.fn_VerificarSuscripcionActiva(@IdUsuario) = 1)
    BEGIN
        EXEC sp_CrearSesionEntrenamiento @IdUsuario, @IdRutina, @FechaHoraInicio, @FechaHoraFin
    END
    ELSE
    BEGIN
        RAISERROR('El Socio no posee la suscripcion activa. No puede iniciar sesion.', 16, 1);
    END
END;
GO

CREATE TRIGGER tr_SoloClientesSuscripcion on Suscripciones
INSTEAD OF INSERT
AS
BEGIN

    DECLARE @CantidadInvalidos INT;

    SELECT @CantidadInvalidos = COUNT(*) FROM inserted i
    INNER JOIN Usuarios u ON i.IdUsuario = u.IdUsuario
    WHERE u.IdRol <> 3;

    IF (@CantidadInvalidos > 0)
    BEGIN
        RAISERROR('Uno o más usuarios en el lote no poseen el Rol de Cliente para realizar una Suscripcion.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Suscripciones (IdUsuario, IdPlan, IdEstado, FechaInicio, FechaVencimiento)
        SELECT IdUsuario, IdPlan, IdEstado, FechaInicio, FechaVencimiento 
        FROM inserted;
    END
END;
GO

Create TRIGGER tr_DesactivacionLogicaUsuarios on Usuarios
INSTEAD OF DELETE
AS
begin  
    -- Usar in por si se elimina mas de una fila (no declarar variable )
    update Usuarios Set Activo = 0 
    where IdUsuarios in (Select IdUsuarios from Deleted) and activo = 1;
end;
GO


-- En preparacion (Migue)
-- Trigger para realizar solo eliminaciones logicas, no fisicas.
-- Negocio: Se puede cancelar una Suscripcion vencida tambien, chequear si una activa pendiente.

Create Trigger tr_DesactivacionLogicaSuscripciones on Suscripciones
Instead of DELETE
as
BEGIN

    update Suscripciones set IdEstado = 3 
    where IdSuscripciones in (select IdSuscripciones from deleted) and IdEstado <> 3;
end;
GO


--Trigger de auditoria(Probando)--
--Este solo insertaria registro en la tabla Auditoria_Usuarios solo cuando los cambios se hagan desde el gestor (desde la app se registraria un un sp)
CREATE TRIGGER tr_Registrar_Movimiento_en_Tabla_Usuarios ON USUARIOS
AFTER UPDATE, DELETE
AS
BEGIN
  IF (APP_NAME() LIKE '%Management Studio%')
    BEGIN

        INSERT INTO Auditoria_Usuarios (IdUsuarioAfectado, Accion, DatosAnteriores, DatosNuevos, IdUsuarioApp, UsuarioBD)
        SELECT 
            COALESCE(i.IdUsuarios, d.IdUsuarios),
            CASE WHEN EXISTS(SELECT 1 FROM inserted) THEN 'UPDATE' ELSE 'DELETE' END,
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            NULL,         
            SUSER_SNAME()
        FROM inserted i
        FULL OUTER JOIN deleted d ON i.IdUsuarios = d.IdUsuarios;
    END
END;
GO

--Este solo insertaria registro en la tabla Auditoria_Pass solo cuando los cambios se hagan desde el gestor (desde la app se registraria un un sp). Si falla deberia registrar en Auditoria_Errores el error
CREATE TRIGGER tr_Registrar_Movimiento_en_Tabla_AccesoUsuarios ON AccesoUsuarios
AFTER UPDATE
AS
BEGIN
IF APP_NAME() LIKE '%Management Studio%'
  BEGIN
      DECLARE @DireccionIP VARCHAR(45)

      SELECT @DireccionIP = client_net_address FROM SYS.dm_exec_connections WHERE session_id = @@SPID
      SET @DireccionIP = COALESCE(@DireccionIP, 'LOCAL')

      BEGIN TRY
        INSERT INTO Auditoria_Pass (IdUsuarioModificado, Pass, IdUsuarioModificador, UsuarioBD, FechaHora, DireccionIP)
                    SELECT I.IdUsuarios, I.Pass, NULL, (SUSER_SNAME()), GETDATE(), @DireccionIP FROM inserted I;
      END TRY
      BEGIN CATCH
        INSERT INTO Auditoria_Errores (FechaHora, Modulo, MensajeError, StackTrace, IdUsuarioLogueado, DatosEntrada)
                        VALUES(GETDATE(), 'Trigger LOG Modificacion de Pass', ERROR_MESSAGE(), (CAST(ERROR_NUMBER() AS VARCHAR(10)) + CAST(ERROR_LINE() AS VARCHAR(10)) +  CAST(ERROR_SEVERITY() AS VARCHAR(10))), NULL, ('IdModificado: ' + CAST((SELECT TOP 1 I.IdUsuarios FROM inserted I) AS VARCHAR(10))));
        THROW;
      END CATCH
  END
END;
GO