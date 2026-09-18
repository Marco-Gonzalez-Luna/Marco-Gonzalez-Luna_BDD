/*Ejercicio 5: Determinar el producto más vendido de cada categoría de producto, 
			   considerando el escenario de que el esquema SALES se encuentra en 
			   una instancia (servidor) A y el esquema PRODUCTION en otra instancia (servidor) B.*/


WITH VentasPorProducto AS (
    SELECT 
        pc.ProductCategoryID,
        pc.Name AS Categoria,
        p.ProductID,
        p.Name AS Producto,
        SUM(d.OrderQty) AS CantidadVendida
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h 
        ON d.SalesOrderID = h.SalesOrderID
    JOIN Production.Product p 
        ON d.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps 
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc 
        ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.ProductCategoryID, pc.Name, p.ProductID, p.Name
)
SELECT Categoria, Producto, CantidadVendida
FROM (
    SELECT 
        Categoria,
        Producto,
        CantidadVendida,
        ROW_NUMBER() OVER (PARTITION BY Categoria ORDER BY CantidadVendida DESC) AS rn
    FROM VentasPorProducto
) t
WHERE rn = 1;




WITH VentasPorProducto AS (
    SELECT 
        pc.ProductCategoryID,
        pc.Name AS Categoria,
        p.ProductID,
        p.Name AS Producto,
        SUM(d.OrderQty) AS CantidadVendida
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h 
        ON d.SalesOrderID = h.SalesOrderID
    -- Aquí usamos el linked server para acceder a Production
    JOIN ServidorB.AdventureWorks2022.Production.Product p 
        ON d.ProductID = p.ProductID
    JOIN ServidorB.AdventureWorks2022.Production.ProductSubcategory ps 
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN ServidorB.AdventureWorks2022.Production.ProductCategory pc 
        ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.ProductCategoryID, pc.Name, p.ProductID, p.Name
)
SELECT Categoria, Producto, CantidadVendida
FROM (
    SELECT 
        Categoria,
        Producto,
        CantidadVendida,
        ROW_NUMBER() OVER (PARTITION BY Categoria ORDER BY CantidadVendida DESC) AS rn
    FROM VentasPorProducto
) t
WHERE rn = 1;



-- Paso 1: Calculamos cuánto vendió cada producto en su categoría
WITH TotalesPorProducto AS (
    SELECT 
        pc.Name AS Categoria,
        p.Name AS Producto,
        SUM(d.OrderQty) AS CantidadVendida
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    JOIN Production.Product p ON d.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name, p.Name
),
-- Paso 2: Buscamos cuál fue el número máximo de ventas en cada categoría
MaximosPorCategoria AS (
    SELECT 
        Categoria,
        MAX(CantidadVendida) AS VentaMaxima
    FROM TotalesPorProducto
    GROUP BY Categoria
)
-- Paso 3: Cruzamos las tablas para recuperar el nombre del producto que logró esa venta máxima
SELECT 
    t.Categoria, 
    t.Producto, 
    t.CantidadVendida
FROM TotalesPorProducto t
JOIN MaximosPorCategoria m 
    ON t.Categoria = m.Categoria 
    AND t.CantidadVendida = m.VentaMaxima;