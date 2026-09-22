USE AdventureWorks2022;
GO
-- Se guarda el valor original en memoria para restaurarlo al final
DECLARE @OriginalHours SMALLINT = (SELECT SickLeaveHours FROM HumanResources.Employee WHERE BusinessEntityID = 2);

-- Se modifica y confirma el cambio (cambio real temporal)
UPDATE HumanResources.Employee
SET SickLeaveHours = 100
WHERE BusinessEntityID = 2;

-- Se espera a que la Conexión A termine de leer este nuevo valor
WAITFOR DELAY '00:00:10';

-- Restauración la base de datos a su estado original
UPDATE HumanResources.Employee
SET SickLeaveHours = @OriginalHours
WHERE BusinessEntityID = 2;
