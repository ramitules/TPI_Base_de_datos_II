USE GestionGimnasio
GO

-- Funcion que devuelve los dias restantes para el vencimiento de la suscripcion de un usuario. Si no tiene suscripcion activa, retorna 0.

CREATE FUNCTION fn_DiasRestantesSuscripcion (@IdUsuario INT)
RETURNS INT
AS
BEGIN

    declare @resultadoDiasRestantes INT;
    declare @fechaVencimiento DATE;

    SELECT @fechaVencimiento = FechaVencimiento 
    from Suscripciones
    where IdUsuario=@Idusuario 
        AND IdEstado = 1
        and getdate() BETWEEN FechaInicio and FechaVencimiento;

    IF (@fechaVencimiento is NOT NULL)
        BEGIN        
            SELECT @resultadoDiasRestantes = DATEDIFF (day, GETDATE(), @fechaVencimiento);
        END
    ELSE
        BEGIN
            set @resultadodiasRestantes = 0;
        END

    RETURN @resultadoDiasRestantes;
END;
GO

-- utilizacion en el trigger: dbo.tr_ValidarSesionConSuscripcionActiva 

CREATE FUNCTION dbo.fn_VerificarSuscripcionActiva(@IdUsuario INT)
RETURNS BIT
AS
BEGIN

    DECLARE @resultadoBusqueda INT;
    DECLARE @resultado BIT;

    SELECT @resultadoBusqueda = COUNT(*) 
    FROM Suscripciones 
    WHERE IdUsuario = @IdUsuario 
        AND IdEstado = 1 
        AND GETDATE() BETWEEN FechaInicio AND FechaVencimiento;

    IF (@resultadoBusqueda >= 1)
        BEGIN
            SET @resultado = 1;
        END
    ELSE 
        BEGIN
            SET @resultado = 0;
        END;

    RETURN @resultado;
END;
GO


CREATE FUNCTION fn_EdadUsuario(@FechaNacimiento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @ResultadoEdad INT
    DECLARE @CorreccionAños INT

    Select @ResultadoEdad = DATEDIFF (YEAR, @FechaNacimiento, GETDATE())

    --Verifico si todavia no cumplio los años
    
    IF (MONTH(@FechaNacimiento) > MONTH(GETDATE()))
        BEGIN
            Select @CorreccionAños = 1
        END
    else IF (MONTH(@FechaNacimiento) = MONTH(GETDATE())
        AND DAY(@FechaNacimiento) > DAY(GETDATE()))
        BEGIN
            Select @CorreccionAños = 1
        END        
    ELSE
        BEGIN
            Select @CorreccionAños = 0
        END    

    SET @ResultadoEdad = @ResultadoEdad - @CorreccionAños

    RETURN @ResultadoEdad
END
GO

--  Funcion que devuelve la cantidad de sesiones de entrenamiento registradas por un usuario.
CREATE FUNCTION fn_CantidadEntrenamientosUsuario
(
    @IdUsuario INT
)
RETURNS INT
AS
BEGIN

    DECLARE @Cantidad INT;

    SELECT
        @Cantidad = COUNT(*)
    FROM SesionesEntrenamiento
    WHERE IdUsuario = @IdUsuario;

    RETURN @Cantidad;

END;
GO


--  Funcion que devuelve la cantidad total de minutos entrenados por un usuario en todas sus sesiones. 
CREATE FUNCTION fn_MinutosEntrenadosUsuario
(
    @IdUsuario INT
)
RETURNS INT
AS
BEGIN

    DECLARE @Minutos INT;

    SELECT @Minutos =
        SUM(DATEDIFF(MINUTE, FechaHoraInicio, FechaHoraFin))
    FROM SesionesEntrenamiento
    WHERE IdUsuario = @IdUsuario;

    RETURN ISNULL(@Minutos, 0);

END;
GO
