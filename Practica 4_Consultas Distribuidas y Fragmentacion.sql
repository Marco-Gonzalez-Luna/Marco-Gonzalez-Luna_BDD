/*1. El departamento de finanzas quiere un 
     reporte global de las ventas totales en línea 
	 y el promedio de compra por cliente en todo 
	 el mundo, ordenado de mayor a menor. 
*/

SET STATISTICS IO ON
SET STATISTICS TIME ON


SELECT 
    CustomerID, 
    SUM(TotalDue) AS VentasTotalesEnLinea,
    AVG(TotalDue) AS PromedioDeCompra
FROM (
    -- Al proyectar solo las dos columnas necesarias, reducimos el consumo de memoria RAM
    SELECT CustomerID, TotalDue FROM F1SOH
    UNION ALL
    SELECT CustomerID, TotalDue FROM F3SOH
    UNION ALL
    SELECT CustomerID, TotalDue FROM F5SOH
) AS VentasGlobalesEnLinea
GROUP BY CustomerID
ORDER BY VentasTotalesEnLinea DESC;







/*2. El gerente de marketing de la región Europa desea 
     saber cuáles son los 5 productos más vendidos en su
	 territorio para lanzar una campaña específica.
	 Mostrar el nombre y número delos productos.
*/

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT TOP 5
    p.[Name]          AS NombreProducto,
    p.ProductNumber   AS NumeroProducto,
    ve.CantidadTotalVendida
FROM (
    SELECT ProductID, SUM(OrderQty) AS CantidadTotalVendida
    FROM (
        -- Local F3: Index Seek sobre IX_F3SOD_ProductID
        SELECT ProductID, SUM(OrderQty) AS OrderQty
        FROM F3SOD
        GROUP BY ProductID

        UNION ALL

        -- Remoto F4: solo el resumen viaja por la red
        SELECT d.ProductID, SUM(d.OrderQty) AS OrderQty
        FROM SERVIDOR_B.fragmentacion.dbo.F4SOD d
        GROUP BY d.ProductID
    ) AS Parciales
    GROUP BY ProductID
) AS ve
JOIN [Product] p ON ve.ProductID = p.ProductID
ORDER BY CantidadTotalVendida DESC;






/*3. La dirección general quiere comparar el rendimiento
     de ventas entre NortAmerica y Pacific durante el
	 año 2014 detallando cuántas ordenes se procesaron 
	 en línea y mostrador, así como el monto total, 
	 utilizando la tabla global SalesTerritor para 
	 mapear los nombres de los países.
*/

SET STATISTICS IO ON
SET STATISTICS TIME ON


SELECT 
    t.[Name] AS Pais,
    t.[Group] AS Region,
    v.TipoDeVenta,
    SUM(v.OrdenesProcesadas) AS OrdenesProcesadas,
    SUM(v.MontoTotalVendido) AS MontoTotalVendido
FROM (
    -- Agrupación parcial F1 (Local)
    SELECT TerritoryID, 'En Línea' AS TipoDeVenta, COUNT(SalesOrderID) AS OrdenesProcesadas, SUM(TotalDue) AS MontoTotalVendido
    FROM F1SOH 
    WHERE OrderDate >= '2014-01-01' AND OrderDate < '2015-01-01'
    GROUP BY TerritoryID
    
    UNION ALL
    
    -- Agrupación parcial F2 (Remoto)
    SELECT TerritoryID, 'Mostrador' AS TipoDeVenta, COUNT(SalesOrderID) AS OrdenesProcesadas, SUM(TotalDue) AS MontoTotalVendido
    FROM SERVIDOR_B.fragmentacion.dbo.F2SOH 
    WHERE OrderDate >= '2014-01-01' AND OrderDate < '2015-01-01'
    GROUP BY TerritoryID
    
    UNION ALL
    
    -- Agrupación parcial F5 (Local)
    SELECT TerritoryID, 'En Línea' AS TipoDeVenta, COUNT(SalesOrderID) AS OrdenesProcesadas, SUM(TotalDue) AS MontoTotalVendido
    FROM F5SOH 
    WHERE OrderDate >= '2014-01-01' AND OrderDate < '2015-01-01'
    GROUP BY TerritoryID
    
    UNION ALL
    
    -- Agrupación parcial F6 (Remoto)
    SELECT TerritoryID, 'Mostrador' AS TipoDeVenta, COUNT(SalesOrderID) AS OrdenesProcesadas, SUM(TotalDue) AS MontoTotalVendido
    FROM SERVIDOR_B.fragmentacion.dbo.F6SOH 
    WHERE OrderDate >= '2014-01-01' AND OrderDate < '2015-01-01'
    GROUP BY TerritoryID
) AS v
-- JOIN final con la tabla global
JOIN SalesTerritory t ON v.TerritoryID = t.TerritoryID
GROUP BY t.[Name], t.[Group], v.TipoDeVenta
ORDER BY t.[Group], t.[Name], v.TipoDeVenta;
