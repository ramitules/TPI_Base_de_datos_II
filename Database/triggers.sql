USE GestionGimnasio
GO

-- Trigger para detectar y actualizar el record personal luego de insertar una serie.
-- Regla de negocio: Para el record personal se mide el peso levantado, en caso de empate se chequea las repeticiones.

CREATE TRIGGER dbo.tr_DetectarRecordPersonal 
ON SeriesCompletadas
AFTER INSERT 
AS
BEGIN
    UPDATE SC 
    SET SC.EsRecordPersonal = CASE 
        WHEN SC.IdSeriesCompletadas IN (
            SELECT TOP 1 WITH TIES SCR.IdSeriesCompletadas
            FROM SeriesCompletadas AS SCR -- Series Completatas Ranking
            INNER JOIN SesionesEntrenamiento AS SER ON SCR.IdSesion = SER.IdSesionesEntrenamiento
                WHERE SER.IdUsuario = SE.IdUsuario AND SCR.IdEjercicio = SC.IdEjercicio
                ORDER BY SCR.PesoLevantadoKG DESC, SCR.RepeticionesLogradas DESC
        ) THEN 1
        ELSE 0
    END
    FROM SeriesCompletadas AS SC
    INNER JOIN SesionesEntrenamiento AS SE ON SC.IdSesion = SE.IdSesionesEntrenamiento
    INNER JOIN (
        SELECT DISTINCT IdEjercicio, IdSesion 
        FROM inserted
    ) AS I ON SC.IdEjercicio = I.IdEjercicio
    INNER JOIN SesionesEntrenamiento AS SEI ON I.IdSesion = SEI.IdSesionesEntrenamiento
    WHERE SE.IdUsuario = SEI.IdUsuario;
END;
GO

-- Trigger para validar que los socios esten activos antes de iniciar una sesion de entrenamiento.
-- Regla de negocio: Si el socio no tiene suscripcion activa no puede uniciar una sesion de entrenamiento.

CREATE TRIGGER dbo.tr_ValidarSesionConSuscripcionActiva 
ON SesionesEntrenamiento
INSTEAD OF INSERT
AS
BEGIN
    BEGIN TRY
        DECLARE @cantidadInvalidos INT;

        SELECT @cantidadInvalidos = COUNT(*) 
        FROM inserted AS I
        WHERE dbo.fn_VerificarSuscripcionActiva(I.IdUsuario) = 0

        IF (@cantidadInvalidos > 0)
        BEGIN
            RAISERROR('Uno o más socios no poseen suscripción activa para iniciar una sesion de entrenamiento: tr_ValidarSesionConSuscripcionActiva ', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO SesionesEntrenamiento (IdUsuario, IdRutina, FechaHoraInicio, FechaHoraFin)
        SELECT I.IdUsuario, I.IdRutina, I.FechaHoraInicio, I.FechaHoraFin 
        FROM inserted AS I;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; 
        RAISERROR('Error al procesar el alta de la sesión de entrenamiento: tr_ValidarSesionConSuscripcionActiva .', 16, 1);
    END CATCH
END;
GO


-- Trigger para verificar y suscribir solo a usuarios que tengan el rol de cliente

CREATE TRIGGER dbo.tr_SoloClientesSuscripcion 
ON Suscripciones
INSTEAD OF INSERT
AS
BEGIN
    BEGIN TRY
        -- Validacion que detecta usuarios que no son clientes.
        DECLARE @CantidadInvalidos INT;

        SELECT @cantidadInvalidos = COUNT(*) 
        FROM inserted AS I
        INNER JOIN Usuarios AS U ON I.IdUsuario = U.IdUsuarios
        WHERE U.IdRol <> 3;

        IF (@cantidadInvalidos > 0)
        BEGIN
            RAISERROR('Uno o más usuarios en el lote no poseen el Rol de Cliente para realizar una Suscripcion.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Suscripciones (IdUsuario, IdPlan, IdEstado, FechaInicio, FechaVencimiento)
        SELECT I.IdUsuario, I.IdPlan, I.IdEstado, I.FechaInicio, I.FechaVencimiento 
        FROM inserted AS I;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; 
        RAISERROR('Error al procesar las altas de la suscripción: dbo.tr_SoloClientesSuscripcion .', 16, 1);
    END CATCH 
END;
GO

-- Trigger para realizar solo eliminaciones logicas (Cancela la suscripción).
-- Negocio: Se puede cancelar cualquier tipo de suscripcion.

CREATE TRIGGER dbo.tr_DesactivacionLogicaUsuarios 
ON Usuarios
INSTEAD OF DELETE
AS
BEGIN
    BEGIN TRY
        -- Modificamos solo los que están activos.
        UPDATE U
        SET U.Activo = 0 
        FROM Usuarios AS U
        WHERE U.IdUsuarios IN (SELECT D.IdUsuarios FROM deleted AS D) 
          AND U.Activo = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Error solo informativo (Severidad 10 no rompe las modificaciones)
            RAISERROR('Aviso: Los usuarios seleccionados ya se encontraban desactivados.', 10, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; 
        RAISERROR('Error al procesar la desactivación lógica en Usuarios: dbo.tr_DesactivacionLogicaUsuarios 
        ON Usuarios.', 16, 1);
    END CATCH
END;
GO

-- Trigger para realizar solo eliminaciones logicas (Cancela la suscripción).
-- Negocio: Se puede cancelar cualquier tipo de suscripcion.

CREATE TRIGGER dbo.tr_DesactivacionLogicaSuscripciones 
ON Suscripciones
INSTEAD OF DELETE
AS
BEGIN
    BEGIN TRY
        -- Modificamos solo las que no están canceladas
        UPDATE S
        SET S.IdEstado = 3 
        FROM Suscripciones AS S
        WHERE S.IdSuscripciones IN (SELECT D.IdSuscripciones FROM deleted AS D) 
          AND S.IdEstado <> 3;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Error solo informativo (Severidad 10 no rompe las modificaciones)
            RAISERROR('Aviso: Las suscripciones seleccionadas ya estaban desactivadas.', 10, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; 
        RAISERROR('Error al procesar la desactivación lógica: dbo.tr_DesactivacionLogicaSuscripciones 
        ON Suscripciones INSTEAD OF DELETE', 16, 1);
    END CATCH
END;
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


-- Actualizar el registro que se acaba de insertar en la tabla SeriesCompletadas 
-- en caso de detectar que la cantidad de kilogramos que el usuario pudo levantar
-- es superior al máximo que se ha levantado en el pasado en el mismo ejercicio.
CREATE TRIGGER TR_SeriesCompletadas_Record
ON SeriesCompletadas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE SC
       SET EsRecordPersonal = 1
      FROM SeriesCompletadas SC
      INNER JOIN inserted I
              ON I.IdSeriesCompletadas = SC.IdSeriesCompletadas
      INNER JOIN SesionesEntrenamiento SE
              ON SE.IdSesionesEntrenamiento = SC.IdSesion
     WHERE SC.PesoLevantadoKG > ISNULL((
               SELECT MAX(SC2.PesoLevantadoKG)
                 FROM SeriesCompletadas SC2
                 INNER JOIN SesionesEntrenamiento SE2
                         ON SE2.IdSesionesEntrenamiento = SC2.IdSesion
                WHERE SE2.IdUsuario   = SE.IdUsuario
                  AND SC2.IdEjercicio = SC.IdEjercicio
                  AND SC2.IdSeriesCompletadas <> SC.IdSeriesCompletadas), 0);
END
GO
