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
            set @resultadoDiasRestantes = DATEDIFF (day, GETDATE(), @fechaVencimiento);
        END
    ELSE
        BEGIN
            set @diasRestantes = 0;
        END

    RETURN @diasRestantes;
END;
GO

CREATE FUNCTION fn_VerificarSuscripcionActiva(@IdUsuario INT)
Return BIT
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
        set @resultado = 1
    ELSE 
        set @resultado = 0;

    return @resultado
END