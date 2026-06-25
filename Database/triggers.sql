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
INSTEAD OF INSERT, UPDATE
AS
BEGIN

    DECLARE @IdUsuario INT;
    DECLARE @IdPlan INT;
    DECLARE @IdEstado INT;
    DECLARE @FechaInicio DATE;
    DECLARE @FechaVencimiento DATE;

    SELECT @IdUsuario = IdUsuario, 
        @IdPlan = IdPlan,
        @IdEstado = IdEstado,
        @FechaInicio = FechaInicio,
        @FechaVencimiento = FechaVencimiento
        from inserted;

    DECLARE @IdRol INT;

    SELECT @IdRol = IdRol from Usuarios WHERE IdUsuario=@IdUsuario;

    IF (@IdRol = 3)
        BEGIN
            EXEC sp_CrearSuscripcion @IdUsuario, @IdPlan, @IdEstado, @FechaInicio, @FechaVencimiento
        END;
    ELSE
        BEGIN
            RAISERROR('El Usuario no posee el Rol de Cliente para realizar una Suscripcion.', 16, 1);
            RETURN
        END;

END;
GO

-- En preparacion (Migue)
-- Trigger para realizar solo eliminaciones logicas, no fisicas.
-- Chequear los atributos de la tabla.

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


 