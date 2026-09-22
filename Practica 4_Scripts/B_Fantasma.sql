USE AdventureWorks2022;
GO
BEGIN TRAN;
-- Se inserta un nuevo departamento que entra en la condición de la Conexión A
INSERT INTO HumanResources.Department (Name, GroupName, ModifiedDate)
VALUES ('Proyectos Especiales', 'Research and Development', GETDATE());
COMMIT TRAN;

-- Espera a que la Conexión A termine su segunda lectura
WAITFOR DELAY '00:00:10';

-- Se elimina el registro fantasma para dejar la BD exactamente como estaba
DELETE FROM HumanResources.Department 
WHERE Name = 'Proyectos Especiales';
