USE GestionGimnasio

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
    -- A realizar domingo 22
    RETURN 1;
END;
GO


--  Función que devuelve la cantidad de sesiones de entrenamiento registradas por un usuario.
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


--  Función que devuelve la cantidad total de minutos entrenados por un usuario en todas sus sesiones. 
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