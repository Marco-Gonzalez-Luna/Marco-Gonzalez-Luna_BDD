USE AdventureWorks2022;

GO
-- Forzamos a SQL Server a ignorar los bloqueos exclusivos de otras transacciones
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

-- Esto leerá "200" en VacationHours, un dato que será revertido en breve
SELECT BusinessEntityID, VacationHours
FROM HumanResources.Employee
WHERE BusinessEntityID = 1;