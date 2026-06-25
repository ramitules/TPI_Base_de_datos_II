USE GestionGimnasio
GO

CREATE FUNCTION fn_ejemplo ()
RETURNS INT
AS
BEGIN
    RETURN 1
END;

GO

-- EN PREPARACION (MIGUE)
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
            set @diasRestantes = 0;
        END

    RETURN @diasRestantes;
END;
GO

CREATE FUNCTION fn_VerificarSuscripcionActiva(@IdUsuario INT)
RETURNS BIT
AS
BEGIN
    DECLARE @resultadoBusqueda INT
    DECLARE @resultado BIT

    Select @resultadoBusqueda = COUNT (*) 
    FROM Suscripciones 
    where IdUsuario=@IdUsuario 
        and IdEstado = 1 
        and getdate() BETWEEN FechaInicio and FechaVencimiento;

    if (@resultadoBusqueda >= 1)
        SELECT @resultado = 1
    ELSE 
        SELECT @resultado = 0;

    return @resultado
END
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

    SELECT @ResultadoEdad = @ResultadoEdad - @CorreccionAños

    RETURN @ResultadoEdad
END
GO
