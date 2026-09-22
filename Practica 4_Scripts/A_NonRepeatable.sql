USE AdventureWorks2022;
GO
-- Nivel por defecto (previene lecturas sucias, pero permite lecturas no repetibles)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
BEGIN TRAN;

-- Primera lectura: valor original
SELECT BusinessEntityID, SickLeaveHours AS Horas_Lectura_1
FROM HumanResources.Employee
WHERE BusinessEntityID = 2;

-- Tiempo para que la Conexión B modifique el dato
WAITFOR DELAY '00:00:10';

-- Segunda lectura: el valor ha cambiado dentro de la misma transacción
SELECT BusinessEntityID, SickLeaveHours AS Horas_Lectura_2
FROM HumanResources.Employee
WHERE BusinessEntityID = 2;

COMMIT TRAN;