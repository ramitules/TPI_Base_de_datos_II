USE TPI_Base_de_datos_II
GO

CREATE PROCEDURE sp_ejemplo
    @ID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        COMMIT TRANSACTION;

        PRINT 'OK';
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
            
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

GO