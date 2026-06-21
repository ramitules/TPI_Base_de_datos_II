USE TPI_Base_de_datos_II
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
    -- A realizar domingo 22
    RETURN 1;
END;
GO