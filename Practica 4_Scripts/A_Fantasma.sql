USE AdventureWorks2022;
GO
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;

-- Se lee cuántos departamentos hay en el grupo 'Research and Development'
SELECT COUNT(*) AS Total_Departamentos
FROM HumanResources.Department
WHERE GroupName = 'Research and Development';

-- Pausa para permitir la inserción fantasma
WAITFOR DELAY '00:00:10';

-- Se vuelve a contar: el número habrá incrementado (el fantasma)
SELECT COUNT(*) AS Total_Departamentos
FROM HumanResources.Department
WHERE GroupName = 'Research and Development';

COMMIT TRAN;