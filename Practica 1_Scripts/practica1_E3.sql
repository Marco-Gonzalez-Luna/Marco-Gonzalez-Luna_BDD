/*
	Ejercicio 3: Calcula ventas totales por territorio y año, 
	mostrando solo aquellos con más de 5 órdenes  y ventas > $1,000,000, 
	ordenado por ventas descendente.
*/

select *from Sales.SalesOrderHeader
select *from Sales.SalesTerritory


select 
    t.name as Territorio,
    year(h.OrderDate) as Año,
    count(h.SalesOrderID) as NumeroOrdenes,
    sum(h.TotalDue) as VentasTotales

	from Sales.SalesOrderHeader h
			JOIN 
		 Sales.SalesTerritory t 
		 
		 on h.TerritoryID = t.TerritoryID

				group by t.name, year(h.OrderDate)
				having count(h.SalesOrderID) > 5
				and sum(h.TotalDue) > 1000000
				order by sum(h.TotalDue) desc;



/*
	1.	Una vez resuelta la consulta agrega desviación estándar de ventas
*/


select 
    t.name as Territorio,
    year(h.OrderDate) as Año,
    count(h.SalesOrderID) as NumeroOrdenes,
    sum(h.TotalDue) as VentasTotales,
    stdev(h.TotalDue) as DesviacionEstandarVentas

from Sales.SalesOrderHeader h
	 join Sales.SalesTerritory t 
	 on h.TerritoryID = t.TerritoryID

			group by t.name, YEAR(h.OrderDate)
			having count(h.SalesOrderID) > 5
			   and sum(h.TotalDue) > 1000000
			order by sum(h.TotalDue) desc;