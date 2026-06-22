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
CREATE TRIGGER tr_ValidarSesionConSuscripcionActiva ON SesionesEntrenamiento
AFTER INSERT
AS
BEGIN
    -- A realizar domingo 22
END;
GO

-- EN PREPARACION (MIGUE)
-- Trigger para validar que no se elija la misma rutina para el mismo socio el mismo dia.
CREATE TRIGGER tr_ValidarRutinaMismoDia ON Rutinas
AFTER INSERT, UPDATE
AS
BEGIN
    -- A realizar domingo 22
END;
GO
