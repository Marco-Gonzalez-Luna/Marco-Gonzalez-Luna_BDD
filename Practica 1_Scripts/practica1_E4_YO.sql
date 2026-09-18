/*Ejercicio 4: Encuentra vendedores que han vendido TODOS los productos de la categoría "Bikes".

    Implementación de una división del álgebra relacional 
    R÷S = 
			π_vendedorID(R) - π_vendedorID(     (π_vendedorID(R) × S)    -R        )
 
S = productos que pertenecen a la categoría Bikes
R = vendedores que han vendido algún producto que pertenece a la categoría bikes
π_vendedorID(R) = lista de todos los vendedores.
π_vendedorID(R) × S = combina cada vendedor con todos los productos de la categoría bikes
(π_vendedorID(R) × S) - R = pares vendedor - producto faltante, es decir productos que no vendió.
π_vendedorID(...) = vendedores que tienen al menos un producto faltante.
Finalmente, restamos del total de alumnos: quedan solo los que aprobaron todas las materias.
 

*/

use BDDAdventureWorks2022;

select * from Sales.SalesOrderHeader;
select * from Sales.SalesOrderDetail;
select * from Production.Product;
select * from Production.ProductSubcategory;
select * from Production.ProductCategory;



select  soh.SalesPersonID idVendedor, sod.ProductID idProducto
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		where soh.SalesPersonID is not null;

-------------------------------------------------------------------------------

/*productos que realmente ha vendido cada vendedor*/

select  soh.SalesPersonID idVendedor, sod.ProductID idProducto
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID

		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID

		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID

		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID

		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1

		GROUP BY soh.SalesPersonID, sod.ProductID
		ORDER BY soh.SalesPersonID asc;

-------------------------------------------------------------------------------


/*cuenta de cuántos productos de la categoría bikes ha vendido cada vendedor*/


select  soh.SalesPersonID idVendedor, count(distinct sod.ProductID)
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID

		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID

		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID

		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID

		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1

		GROUP BY soh.SalesPersonID
		ORDER BY soh.SalesPersonID asc;

-------------------------------------------------------------------------------
/* todos los productos de la categoría bikes*/

select * from Production.Product;
select * from Production.ProductSubcategory;
select * from Production.ProductCategory;

select pp.ProductID, pp.Name, pps.Name, ppc.Name
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1;

-------------------------------------------------------------------------------
/*contar todos los productos de la categoría bikes*/


select count(pp.ProductID) CantProdBike
		FROM Production.Product pp

		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID

		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID

		WHERE ppc.ProductCategoryID = 1
		GROUP BY ppc.Name;


/*SOLUCIÓN UNO, COMPARANDO LA CANTIDAD*/


WITH VENDEDORES AS(
select  soh.SalesPersonID idVendedor, count(distinct sod.ProductID) CANT
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1
		GROUP BY soh.SalesPersonID
		
		HAVING count(distinct sod.ProductID) = (

select count(pp.ProductID) CantProdBike
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1
		GROUP BY ppc.Name))

		SELECT  v.idVendedor, pp.FirstName, pp.LastName, v.CANT
			FROM VENDEDORES v
			JOIN
			Person.Person pp
			on v.idVendedor = pp.BusinessEntityID;







-------------------------------------------------------------------------------

/*productos que realmente ha vendido cada vendedor*/

select  soh.SalesPersonID idVendedor, sod.ProductID idProducto
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID

		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID

		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID

		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID

		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1

		GROUP BY soh.SalesPersonID, sod.ProductID
		ORDER BY soh.SalesPersonID asc;


-------------------------------------------------------------------------------



WITH VENDEDORES AS
(select  DISTINCT soh.SalesPersonID idVendedor
		from Sales.SalesOrderHeader soh
		WHERE SOH.SalesPersonID IS NOT NULL),

PRODUCTOS AS

		(select pp.ProductID
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1)
		
		SELECT *
			FROM VENDEDORES AS V
			CROSS JOIN PRODUCTOS AS P;


/*productos que idealmente ha vendido cada vendedor*/


WITH VENDEDORES AS
(select  DISTINCT soh.SalesPersonID idVendedor
		from Sales.SalesOrderHeader soh
		WHERE SOH.SalesPersonID IS NOT NULL),

PRODUCTOS AS

		(select pp.ProductID
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1),

PRODUCTOS_IDEALES AS	
		(SELECT *
			FROM VENDEDORES AS V
			CROSS JOIN PRODUCTOS AS P),

PRODUCTOS_REALES AS(

select  soh.SalesPersonID idVendedor, sod.ProductID idProducto
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1
		GROUP BY soh.SalesPersonID, sod.ProductID
),

RESTA1 AS 
	(SELECT  distinct PID.idVendedor
			FROM PRODUCTOS_IDEALES PID
				WHERE  NOT EXISTS (SELECT 1 FROM PRODUCTOS_REALES PR
												WHERE Pr.idVendedor = pid.idVendedor
												and pr.idProducto = pid.ProductID))
SELECT V.idVendedor, pp.FirstName, pp.LastName
			FROM VENDEDORES V
				JOIN
				Person.Person pp
				ON v.idVendedor = pp.BusinessEntityID
				WHERE V.idVendedor NOT IN (SELECT idVendedor FROM RESTA1 )
			






/*SOLUCIÓN UNO, COMPARANDO LA CANTIDAD*/


WITH VENDEDORES AS(
select  soh.SalesPersonID idVendedor, count(distinct sod.ProductID) CANT
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1
		GROUP BY soh.SalesPersonID
		
		HAVING count(distinct sod.ProductID) = (

select count(pp.ProductID) CantProdBike
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1
		GROUP BY ppc.Name))

		SELECT  v.idVendedor, pp.FirstName, pp.LastName, v.CANT
			FROM VENDEDORES v
			JOIN
			Person.Person pp
			on v.idVendedor = pp.BusinessEntityID;


/*SOLUCIÓN DOS, DIVISIÓN*/



WITH VENDEDORES AS
(select  DISTINCT soh.SalesPersonID idVendedor
		from Sales.SalesOrderHeader soh
		WHERE SOH.SalesPersonID IS NOT NULL),

PRODUCTOS AS

		(select pp.ProductID
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1),

PRODUCTOS_IDEALES AS	
		(SELECT *
			FROM VENDEDORES AS V
			CROSS JOIN PRODUCTOS AS P),

PRODUCTOS_REALES AS(

select  soh.SalesPersonID idVendedor, sod.ProductID idProducto
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 1
		GROUP BY soh.SalesPersonID, sod.ProductID
),

RESTA1 AS 
	(SELECT  distinct PID.idVendedor
			FROM PRODUCTOS_IDEALES PID
				WHERE  NOT EXISTS (SELECT 1 FROM PRODUCTOS_REALES PR
												WHERE Pr.idVendedor = pid.idVendedor
												and pr.idProducto = pid.ProductID))
SELECT V.idVendedor, pp.FirstName, pp.LastName
			FROM VENDEDORES V
				JOIN
				Person.Person pp
				ON v.idVendedor = pp.BusinessEntityID
				WHERE V.idVendedor NOT IN (SELECT idVendedor FROM RESTA1 )









-- 1.Cambia a categoría "Clothing" (ID=4).


WITH VENDEDORES AS(
select  soh.SalesPersonID idVendedor, count(distinct sod.ProductID) CANT
		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		AND ppc.ProductCategoryID = 3
		GROUP BY soh.SalesPersonID
		
		HAVING count(distinct sod.ProductID) = (

select count(pp.ProductID) CantProdBike
		FROM Production.Product pp
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		WHERE ppc.ProductCategoryID = 1
		GROUP BY ppc.Name))

		SELECT  v.idVendedor, pp.FirstName, pp.LastName, v.CANT
			FROM VENDEDORES v
			JOIN
			Person.Person pp
			on v.idVendedor = pp.BusinessEntityID;


-- 2.Cuenta cuántos productos por categoría maneja cada vendedor.


WITH VendCat as(

select  soh.SalesPersonID, ppc.ProductCategoryID, count(distinct pp.ProductID) prodXCat

		from Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
		JOIN Production.ProductSubcategory pps
		ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
		JOIN Production.ProductCategory ppc
		ON pps.ProductCategoryID = ppc.ProductCategoryID
		where soh.SalesPersonID is not null
		group by  soh.SalesPersonID, ppc.ProductCategoryID
		)

		select vc.SalesPersonID,pp.FirstName, pp.LastName, vc.ProductCategoryID, vc.prodXCat
			from VendCat vc
			JOIN
			Person.Person pp
			ON vc.SalesPersonID = pp.BusinessEntityID
			order by  vc.SalesPersonID, vc.ProductCategoryID;

