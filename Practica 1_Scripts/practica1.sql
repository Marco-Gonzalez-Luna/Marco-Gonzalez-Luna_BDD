
use BDDAdventureWorks2022;


select * from Sales.SalesOrderHeader;    
select * from Sales.SalesOrderDetail;
select * from Production.Product;
select * from HumanResources.Employee;
select * from Person.Person;


select * from Sales.Customer;    



select * from Person.Person;

select * from Sales.SalesOrderHeader where CustomerID = '21129';    


/*
Ejercicio 1. Encuentra los 10 productos más vendidos en 2014, 
			 mostrando nombre del producto, cantidad total vendida y nombre del cliente.
*/
--1.Una vez resuelta la consulta: 
--agrega el precio unitario promedio (AVG(UnitPrice)) y filtra solo productos con ListPrice > 1000.
--2.Documenta la solución inicial y solución con las variantes solicitadas.


select name, cant
from Production.product p
join (select top 10 productid, sum(orderqty) cant
              from sales.SalesOrderDetail sod
			  group by productid
              order by cant desc) as T
on p.ProductID = t.ProductID
 



 WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014' ) 


			select top 10 productid, sum(p.OrderQty) cant
              from PROD2014 as p
			  group by p.productid
              order by cant desc;

-------------------------------------------------------------------

WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014' ) 

select name, p.ProductID, cant
from Production.product p
	join 
			(select top 10 productid, sum(p.OrderQty) cant
              from PROD2014 as p
			  group by p.productid
              order by cant desc) as T
		on p.ProductID = t.ProductID


-------------------------------------------------------------------

WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014' ),

Top10 as (

select name, t.ProductID, cant
from Production.product p
	join 
			(select top 10 productid , sum(p.OrderQty) cant
              from PROD2014 as p
			  group by p.productid
              order by cant desc) as T
		on p.ProductID = t.ProductID)

select t2.ProductID, t2.Name, p2.CustomerID, p2.OrderQty, t2.cant from
		PROD2014 as p2 JOIN Top10 as t2
		ON p2.ProductID = t2.ProductID
		order by t2.cant desc

		--12051
--------------------------------------------------------------------------------------------------

/*Ejercicio 1. Encuentra los 10 productos más vendidos en 2014, 
		       mostrando nombre del producto, 
			   cantidad total vendida y nombre del cliente.*/

WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014' ),

Top10 as (
select name, t.ProductID, cant
from Production.product p
	join 
			(select top 10 productid , sum(p.OrderQty) cant
              from PROD2014 as p
			  group by p.productid
              order by cant desc) as T
		on p.ProductID = t.ProductID),

ClienteConProducto as (
select t2.ProductID, t2.Name, p2.CustomerID, p2.OrderQty, t2.cant from
		PROD2014 as p2 JOIN Top10 as t2
		ON p2.ProductID = t2.ProductID
		)

Select ccp.ProductID, ccp.Name, ccp.CustomerID, ccp.OrderQty, 
	   per.FirstName, per.LastName, ccp.cant 
	from ClienteConProducto ccp JOIN
		Sales.Customer cus 
		ON cus.CustomerID = ccp.CustomerID

		JOIN Person.Person per
		ON cus.PersonID = per.BusinessEntityID
		order by ccp.cant desc;

-------------------------------------------------------------------------------------------------------



/*1.
Una vez resuelta la consulta: 
agrega el precio unitario promedio (AVG(UnitPrice)) 
y filtra solo productos con ListPrice > 1000.*/

select * from Sales.SalesOrderDetail; --unit price
select * from Production.Product; --list price


------------------------------------------------------------------------------------------------------

WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID, sod.UnitPrice, pr.ListPrice
from sales.SalesOrderHeader soh 
	join sales.SalesOrderDetail sod
	on soh.SalesOrderID = sod.SalesOrderID
	join Production.Product pr
	on pr.ProductID = sod.ProductID
	where year(OrderDate) = '2014' ) 

select name, prod.ProductID, cant, precioUProm, prod.ListPrice
from Production.product prod
	join 
			(select top 10 productid, sum(p.OrderQty) cant, avg(p.UnitPrice) precioUProm
              from PROD2014 as p

			  where p.ListPrice>1000
			  
			  group by p.productid
              order by cant desc) as T
		on prod.ProductID = t.ProductID


-------------------------------------------------------------------------------------------------------

select  sod.ProductID,avg(sod.UnitPrice)
from sales.SalesOrderHeader soh 
	join sales.SalesOrderDetail sod
	on soh.SalesOrderID = sod.SalesOrderID
	join Production.Product pr
	on pr.ProductID = sod.ProductID
	where year(OrderDate) = '2014' and sod.ProductID = 782
	group by sod.ProductID;

-------------------------------------------------------------------------------------------------------



/*1.Una vez resuelta la consulta: 
agrega el precio unitario promedio (AVG(UnitPrice)) 
y filtra solo productos con ListPrice > 1000.*/

WITH PROD2014 as (
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID, sod.UnitPrice, pr.ListPrice
from sales.SalesOrderHeader soh 
		join sales.SalesOrderDetail sod
		on soh.SalesOrderID = sod.SalesOrderID
		join Production.Product pr
		on pr.ProductID = sod.ProductID
		where year(OrderDate) = '2014' ),
Top10 as (
select prod.name, t.ProductID, cant, precioUProm, prod.ListPrice
from Production.product prod
	join 
			(select top 10 productid , sum(p.OrderQty) cant, avg(p.UnitPrice) precioUProm
              from PROD2014 as p
			  where p.ListPrice>1000
			  group by p.productid
              order by cant desc) as T
		on prod.ProductID = t.ProductID),

ClienteConProducto as (
select t2.ProductID, t2.Name, p2.CustomerID, p2.OrderQty, t2.cant, t2.precioUProm, t2.ListPrice from
		PROD2014 as p2 JOIN Top10 as t2
		ON p2.ProductID = t2.ProductID)

Select ccp.ProductID, ccp.Name, ccp.CustomerID, ccp.OrderQty, 
	   per.FirstName, per.LastName, ccp.cant, ccp.precioUProm, ccp.ListPrice
	from ClienteConProducto ccp JOIN
		Sales.Customer cus 
		ON cus.CustomerID = ccp.CustomerID
		JOIN Person.Person per
		ON cus.PersonID = per.BusinessEntityID
		order by ccp.cant desc;

















WITH c1 as(
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014' 
)

select c1.CustomerID, count(c1.OrderQty)
from c1
where PRODUCTID = 712
group by c1.CustomerID;


-- esta consulta me dice los 10 productos más vendidos en 2014

-- se refiere a la cantidad total vendida a cada cliente?
-- o sólo que mostremos si el producto se ha vendido al cliente?

-- creo que tengo que aplicar una división de los clientes que han comprado
-- todos esos productos en 2014 y luego filtrarlos por cuantos compraron

/*se filtra el avg de los 10 productos y también se muestran los clientes*/

/*
Quiero los clientes que 
*/

select * from Person.Person;



select IDC.SalesOrderID, IDC.CustomerID, p.FirstName, p.LastName

from
(select SalesOrderID, soh.CustomerID, c.PersonID from Sales.SalesOrderHeader as soh
JOIN
Sales.Customer as c
ON soh.CustomerID =  c.CustomerID)  as IDC 

	Join Person.Person p
	
	ON p.BusinessEntityID = IDC.PersonID; 