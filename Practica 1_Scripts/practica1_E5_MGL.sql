/*Ejercicio 5: Determinar el producto más vendido de cada categoría de producto, 
considerando el escenario de que el esquema SALES se encuentra en una instancia (servidor) A 
y el esquema PRODUCTION en otra instancia (servidor) B.*/

use BDDAdventureWorks2022

WITH VentasPorCategoria AS (
 
)

SELECT * FROM VentasPorCategoria V1
WHERE TotalVendido = (
    SELECT MAX(TotalVendido) 
    FROM VentasPorCategoria V2 
    WHERE V2.ProductCategoryID = V1.ProductCategoryID
	
)
ORDER BY v1.ProductCategoryID;






go

WITH VentasPorCategoria AS (
    SELECT 
        ppc.ProductCategoryID, 
        ppc.Name, 
        pp.ProductID, 
        SUM(sod.OrderQty) AS TotalVendido
    FROM Sales.SalesOrderDetail sod -- Local (Servidor A)
    -- A partir de aquí, todo es remoto (Servidor B)
    JOIN SV_CRIS.AdventureWorks2022_2.Production.Product pp 
        ON sod.ProductID = pp.ProductID
    JOIN SV_CRIS.AdventureWorks2022_2.Production.ProductSubcategoryg pps 
        ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
    JOIN SV_CRIS.AdventureWorks2022_2.Production.ProductCategory ppc 
        ON pps.ProductCategoryID = ppc.ProductCategoryID
    GROUP BY ppc.ProductCategoryID, ppc.Name, pp.ProductID
)

SELECT * FROM VentasPorCategoria V1
WHERE TotalVendido = (
    SELECT MAX(TotalVendido) 
    FROM VentasPorCategoria V2 
    WHERE V2.ProductCategoryID = V1.ProductCategoryID
)
ORDER BY V1.ProductCategoryID;}

go