USE GestionGimnasio
GO

-- EN PREPARACION (MIGUE)
-- Trigger para detectar un record personal y actualizar EsRecordPersonal.
-- Regla de negocio: Si el Peso levantado empata el Record para el ejercicio se verifica las repeticiones.
-- Observaciones: En vez de buscar por la bandera vamos directo a los datos.

Create Trigger tr_DetectarRecordPersonal ON SeriesCompletadas
After Insert 
AS
BEGIN

    -- Declaro las variables que voy a utilizar

    Declare @IdSerieCompletada INT;
    Declare @IdSesion INT;
    Declare @IdEjercicio INT;
    Declare @Repeticiones SMALLINT;
    Declare @PesoLevantadoKG SMALLINT;
    Declare @IdUsuario INT; -- Lo voy a tomar de la Sesion de entrenamiento con el IdSesion

    -- Capturo los datos insertados de SeriesCompletadas

    Select  @IdSerieCompletada = IdSeriesCompletadas, 
            @IdSesion = IdSesion, 
            @IdEjercicio = IdEjercicio, 
            @Repeticiones = RepeticionesLogradas, 
            @PesoLevantadoKG = PesoLevantadoKG
    From Inserted;

    -- Capturo el Id del Socio que completo la serie

    Select @IdUsuario = IdUsuario From SesionesEntrenamiento where IdSesionesEntrenamiento = @IdSesion;

    -- Busco la serie record del Socio y capturo los valores.

    Declare @MaxPesoLevantado SMALLINT;
    Declare @MaxRepeticiones SMALLINT;

    select top 1 
        @MaxPesoLevantado = SC.PesoLevantadoKG,
        @MaxRepeticiones = SC.RepeticionesLogradas
    from SeriesCompletadas SC 
    INNER JOIN SesionesEntrenamiento SE on SC.IdSesion = SE.IdSesionesEntrenamiento
    WHERE SE.IdUsuario = @IdUsuario AND SC.IdEjercicio = @IdEjercicio AND SC.IdSeriesCompletadas != @IdSerieCompletada
    ORDER BY SC.PesoLevantadoKG Desc, SC.RepeticionesLogradas DESC;

    -- Chequear si es Record e insertar
    IF @MaxPesoLevantado is NULL OR @PesoLevantadoKG > @MaxPesoLevantado or (@PesoLevantadoKG = @MaxPesoLevantado AND @Repeticiones > @MaxRepeticiones)
    BEGIN
        UPDATE SeriesCompletadas 
        Set EsRecordPersonal = 1 where IdSeriesCompletadas = @IdSerieCompletada;
    END
END;
GO

-- EN PREPARACION (MIGUE)
-- Trigger para validar que los socios esten activos antes de iniciar una sesion de entrenamiento.
-- Regla de negocio: Si el socio no tiene suscripcion activa no
 puede uniciar una sesion de entrenamiento.

CREATE TRIGGER tr_ValidarSesionConSuscripcionActiva ON SesionesEntrenamiento
AFTER INSERT
AS
BEGIN
    
    --Declaro las variables que voy a usar

    Declare @IdUsuario INT;
    Declare @FechaInicio DATE;

    --Capturo del Inserted

    Select @IdUsuario = IdUsuario, @FechaInicio = CAST(FechaHoraInicio as DATE) FROM inserted;

    --Chequeo si no existe

    IF NOT EXISTS (
    SELECT FROM Suscripciones
    WHERE IdUsuario = @IdUsuario AND IdEstado = 1 AND FechaInicio <= @FechaInicio AND FechaVencimiento >= @FechaInicio)
    BEGIN
        RAISERROR('El Socio no posee la suscripcion activa. No puede iniciar sesion.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
GO

-- En preparacion (Migue)
-- Trigger para gestionar las suscripciones y sus estados al realizar cambios


-- EN PREPARACION (MIGUE)
-- Trigger para validar que no se elija la misma rutina para el mismo socio el mismo dia.
CREATE TRIGGER tr_ValidarRutinaMismoDia ON Rutinas
AFTER INSERT, UPDATE
AS
BEGIN
    -- A realizar domingo 22
END;
GO

-- En preparacion (Migue)
-- Trigger para realizar solo eliminaciones logicas, no fisicas.
-- Chequear los atributos de la tabla.


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