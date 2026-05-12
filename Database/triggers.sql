USE TPI_Base_de_datos_II
GO

CREATE TRIGGER trg_ejemplo
ON Ejemplo
AFTER INSERT, UPDATE
AS
BEGIN
    PRINT 'Ejemplo';
END;

GO
