/*
	Ejercicio 4: Encuentra vendedores que han vendido TODOS los productos de la categoría "Bikes".
*/

select * from Production.Product;
select * from Production.ProductSubcategory;
select * from Production.ProductCategory;



with ProductosBikes as (
    select p.ProductID
    from Production.Product p
    join Production.ProductSubcategory ps 	
	on p.ProductSubcategoryID = ps.ProductSubcategoryID

    join Production.ProductCategory pc 
	on ps.ProductCategoryID = pc.ProductCategoryID
    where pc.Name = 'Bikes'
),
VentasPorVendedor as (
    select h.SalesPersonID, d.ProductID

    from Sales.SalesOrderHeader h
    join Sales.SalesOrderDetail d 
	on h.SalesOrderID = d.SalesOrderID
    
	where h.SalesPersonID IS NOT NULL
)

select sp.BusinessEntityID, p.FirstName, p.LastName

from Sales.SalesPerson sp
join Person.Person p 
on sp.BusinessEntityID = p.BusinessEntityID

where NOT EXISTS (
    select pb.ProductID
    from ProductosBikes pb
    where NOT EXISTS (
        select 1
        from VentasPorVendedor vv
        where vv.SalesPersonID = sp.BusinessEntityID
          and vv.ProductID = pb.ProductID
    )
);

/*
	1.	Cambia a categoría "Clothing" (ID=4).
*/

with ProductosBikes as (
    select p.ProductID
    from Production.Product p
    join Production.ProductSubcategory ps 	
	on p.ProductSubcategoryID = ps.ProductSubcategoryID

    join Production.ProductCategory pc 
	on ps.ProductCategoryID = pc.ProductCategoryID
    where pc.Name = 'Clothing'
),
VentasPorVendedor as (
    select h.SalesPersonID, d.ProductID

    from Sales.SalesOrderHeader h
    join Sales.SalesOrderDetail d 
	on h.SalesOrderID = d.SalesOrderID
    
	where h.SalesPersonID IS NOT NULL
)

select sp.BusinessEntityID, p.FirstName, p.LastName

from Sales.SalesPerson sp
join Person.Person p 
on sp.BusinessEntityID = p.BusinessEntityID

where NOT EXISTS (
    select pb.ProductID
    from ProductosBikes pb
    where NOT EXISTS (
        select 1
        from VentasPorVendedor vv
        where vv.SalesPersonID = sp.BusinessEntityID
          and vv.ProductID = pb.ProductID
    )
);


/*
	2.	Cuenta cuántos productos por categoría maneja cada vendedor
*/

select 
    sp.BusinessEntityID as VendedorID,
    per.FirstName,
    per.LastName,
    pc.name as Categoria,
    count(distinct p.ProductID) as ProductosVendidos
from Sales.SalesPerson sp
join Person.Person per 
    on sp.BusinessEntityID = per.BusinessEntityID
join Sales.SalesOrderHeader h 
    on sp.BusinessEntityID = h.SalesPersonID
join Sales.SalesOrderDetail d 
    on h.SalesOrderID = d.SalesOrderID
join Production.Product p 
    on d.ProductID = p.ProductID
join Production.ProductSubcategory ps 
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc 
    on ps.ProductCategoryID = pc.ProductCategoryID
group by sp.BusinessEntityID, per.FirstName, per.LastName, pc.name
order by sp.BusinessEntityID, pc.name;









