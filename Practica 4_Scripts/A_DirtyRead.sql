
USE AdventureWorks2022;

GO
BEGIN TRAN;

-- 1. Aplicación un cambio temporal
UPDATE HumanResources.Employee
SET VacationHours = 200
WHERE BusinessEntityID = 1;

-- 2. Dar tiempo para que la Conexión B lea el dato sucio
WAITFOR DELAY '00:00:10';

-- 3. Revertir el cambio. 
ROLLBACK TRAN;

