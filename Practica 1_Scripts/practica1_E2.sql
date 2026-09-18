use BDDAdventureWorks2022;

select * from Sales.SalesOrderHeader;    
select * from Sales.SalesOrderDetail;
select * from Production.Product;


select * from HumanResources.Employee;

select * from Sales.SalesPerson;

select * from Person.Person;

/*Ejercicio 2: Lista los empleados que han vendido más que el 
promedio de ventas por empleado en el territorio 'Northwest'.*/

select * from Sales.SalesTerritory where Name = 'Northwest';


select soh.SalesOrderID, soh.SalesPersonID, soh.TerritoryID 
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1; 
	   where soh.SalesPersonID = 276;   

-------------------------------------------------------------------

select soh.SalesPersonID, count(soh.SalesPersonID) cant_ventas
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1
	   and soh.SalesPersonID is not null
	   group by soh.SalesPersonID;


-------------------------------------------------------------------


WITH VentasNW as (
select soh.SalesPersonID, count(soh.SalesPersonID) cant_ventas
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1
	   and soh.SalesPersonID is not null
	   group by soh.SalesPersonID )

	   select avg(v.cant_ventas) avgVentas
			from VentasNW as v;
-------------------------------------------------------------------

WITH VentasNW as (
select soh.SalesPersonID, count(soh.SalesPersonID) cant_ventas
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1
	   and soh.SalesPersonID is not null
	   group by soh.SalesPersonID ),

avgVentas as(
	   select avg(v.cant_ventas) avgVentas
			from VentasNW as v)

select * from 
		VentasNW 
		CROSS JOIN
		avgVentas;

-------------------------------------------------------------------


WITH VentasNW as (
select soh.SalesPersonID, count(soh.SalesPersonID) cant_ventas
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1
	   and soh.SalesPersonID is not null
	   group by soh.SalesPersonID ),

avgV as(
	   select avg(v.cant_ventas) avgVentas
			from VentasNW as v)

select v2.SalesPersonID
	from VentasNW v2, avgV av
	where v2.cant_ventas > av.avgVentas

-------------------------------------------------------------------


WITH VentasNW as (
select soh.SalesPersonID, count(soh.SalesPersonID) cant_ventas
	   from Sales.SalesOrderHeader as soh
	   where soh.TerritoryID = 1
	   and soh.SalesPersonID is not null
	   group by soh.SalesPersonID ),

avgV as(
	   select avg(v.cant_ventas) avgVentas
			from VentasNW as v),
filtroV as(
select v2.SalesPersonID
	from VentasNW v2, avgV av
	where v2.cant_ventas > av.avgVentas)

select f.SalesPersonID, pp.FirstName, pp.LastName
		from filtroV f JOIN Sales.SalesPerson as sp
		on f.SalesPersonID = sp.BusinessEntityID
		join HumanResources.Employee hre
		on hre.BusinessEntityID = sp.BusinessEntityID
		join Person.Person pp
		on hre.BusinessEntityID = pp.BusinessEntityID;





/*Reunir con order header para ver que sea lo mismo en order detail
Se considera la suma de order cuantity * precio unitario

territorio de person con territorio de sales territory*/

/*incluir el promedio de ventas y ventas totales*/

-------------------------------------------------------------------		

select * from Person.Person;
select * from Sales.Store;
select * from Sales.SalesPerson;
select * from Person.Person;




SELECT 
    soh.SalesPersonID, 
    pp.FirstName, 
    pp.LastName
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee AS hre ON hre.BusinessEntityID = sp.BusinessEntityID
JOIN Person.Person AS pp ON hre.BusinessEntityID = pp.BusinessEntityID
WHERE soh.TerritoryID = 1
  AND soh.SalesPersonID IS NOT NULL
GROUP BY 
    soh.SalesPersonID, 
    pp.FirstName, 
    pp.LastName
-- Filtramos usando una subconsulta en el HAVING
HAVING COUNT(soh.SalesPersonID) > (
    SELECT AVG(cant_ventas)
    FROM (
        -- Subconsulta interna para calcular las ventas por vendedor
        SELECT COUNT(SalesPersonID) AS cant_ventas
        FROM Sales.SalesOrderHeader
        WHERE TerritoryID = 1 AND SalesPersonID IS NOT NULL
        GROUP BY SalesPersonID
    ) AS SubqVentas
);


















select * from Sales.SalesOrderHeader;    
select * from Sales.SalesOrderDetail;
select * from Production.Product;


select * from HumanResources.Employee;

select * from Sales.SalesPerson;

select * from Person.Person;




select * from Sales.SalesOrderHeader;    
select * from Sales.SalesOrderDetail;

SELECT soh.SalesOrderID, soh.SalesPersonID, soh.TerritoryID, sod.OrderQty, sod.UnitPrice
		FROM Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		where soh.TerritoryID = 1;

/*Ejercicio 2: Lista los empleados que han vendido más que el 
promedio de ventas por empleado en el territorio 'Northwest'.*/

WITH salesEmp AS(
SELECT  soh.SalesPersonID, pp.FirstName, pp.LastName , sum(sod.OrderQty * sod.UnitPrice) ventas
		FROM Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Sales.SalesPerson ssp
		ON ssp.BusinessEntityID = soh.SalesPersonID and ssp.TerritoryID =1
		JOIN Person.Person pp
		ON soh.SalesPersonID = pp.BusinessEntityID
		where soh.TerritoryID = 1
		and soh.SalesPersonID is not null
		group by soh.SalesPersonID, pp.FirstName, pp.LastName)


SELECT *
		FROM salesEmp se1 where se1.ventas > (SELECT avg(se.ventas) avgEmp FROM salesEmp se);



WITH salesEmp AS(
SELECT  soh.SalesPersonID, pp.FirstName, pp.LastName , sum(sod.OrderQty * sod.UnitPrice) ventas
		FROM Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Sales.SalesPerson ssp
		ON ssp.BusinessEntityID = soh.SalesPersonID and ssp.TerritoryID =1
		JOIN Person.Person pp
		ON soh.SalesPersonID = pp.BusinessEntityID
		where soh.TerritoryID = 1
		and soh.SalesPersonID is not null
		group by soh.SalesPersonID, pp.FirstName, pp.LastName),

promedio as (

SELECT avg(se.ventas) avgEmp
		FROM salesEmp se)

SELECT *
		FROM salesEmp se1 CROSS JOIN promedio p
		
		where se1.ventas > p.avgEmp;


/*Ejercicio 2: Lista los empleados que han vendido más que el 
promedio de ventas por empleado en el territorio 'Northwest'.*/
-- 1.Requisito adicional: aplicar subconsultas.

SELECT 
    VentasEmp.SalesPersonID, 
    VentasEmp.FirstName, 
    VentasEmp.LastName, 
    VentasEmp.ventas
FROM (
	SELECT  soh.SalesPersonID, pp.FirstName, pp.LastName , sum(sod.OrderQty * sod.UnitPrice) ventas
		FROM Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Sales.SalesPerson ssp
		ON ssp.BusinessEntityID = soh.SalesPersonID and ssp.TerritoryID =1
		JOIN Person.Person pp
		ON soh.SalesPersonID = pp.BusinessEntityID
		where soh.TerritoryID = 1
		and soh.SalesPersonID is not null
		group by soh.SalesPersonID, pp.FirstName, pp.LastName) AS VentasEmp

WHERE VentasEmp.ventas > (
        SELECT AVG(PromedioVentas.ventas_totales)
    FROM (
        SELECT  soh.SalesPersonID, sum(sod.OrderQty * sod.UnitPrice) ventas_totales
		FROM Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Sales.SalesPerson ssp
		ON ssp.BusinessEntityID = soh.SalesPersonID and ssp.TerritoryID =1
		JOIN Person.Person pp
		ON soh.SalesPersonID = pp.BusinessEntityID
		where soh.TerritoryID = 1
		and soh.SalesPersonID is not null
		group by soh.SalesPersonID, pp.FirstName, pp.LastName) AS PromedioVentas
);



-- 2.Una vez resuelta la consulta convierte la subconsulta 
--en un CTE (Common Table Expresión).