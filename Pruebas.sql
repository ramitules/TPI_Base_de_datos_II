-- EL SELECT CON VARIABLES LO QUE HACE ES ASIGNAR DATOS
-- SELECT @IDCUENTA = ID, @SALDO = SALDO FROM DELETED;




CREATE PROCEDURE 


AS BEGIN

    BEGIN TRY

        BEGIN TRANSACTION

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION
        RAISE
    END CATCH

END;

-- TRIGGERS / DESENCADENADORES

CREATE TRIGGER tr_NombreTrigger ON NombreTabla
INSTEAD OF DELETE
AS BEGIN

    -- DECLARO LAS VARIABLES QUE NECESITO

    DECLARE @ID INT;
    DECLARE @Saldo VARCHAR(50);

    -- VALIDACIONES: Una vez valido todo hago el delete

    IF @Saldo <> 0 BEGIN
        RAISERROR('No se puede eliminar la cuenta porque el saldo no es 0', 16, 1);
        RETURN;
    END

    Update Cuentas Set FechaBaja = GETDATE() WHERE ID = @ID;
    






