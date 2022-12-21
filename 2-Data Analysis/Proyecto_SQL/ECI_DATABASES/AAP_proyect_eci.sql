/*2. Genera una consulta que obtenga la lista ordenada de todas las referencias sin venta*/

SELECT *
FROM articulo
WHERE not exists (SELECT * FROM venta WHERE venta.referencia = articulo.referencia);



/*3.Genera una consulta que obtenga las ventas comprendidas entre 2010 y 2011 (ambos incluidos), que estén asociados a una campaña de tipo VENTA y que sean del departamento de JOYERÍA*/

SELECT *
FROM venta as v
LEFT JOIN articulo as a on v.referencia = a.referencia
LEFT JOIN departamento as d on d.id_dpto = a.id_dpto
LEFT JOIN depto_campania as dc on dc.id_dpto = d.id_dpto
LEFT JOIN campania as c on c.id_campania = dc.id_campania
WHERE d.desc_dpto = 'JOYERIA' and c.tipo = 'VENTA' and year(FECHA_VENTA) between 2010 and 2011;



/*4. Genere una consulta que cree un campo "co_ranking" que clasifique en orden ascendente las campañas según el total de venta, siendo 1 la campaña que más ha vendido y N la que menos. (N = Total de campañas)*/

SET @rank = 0;

SELECT result.*, @rank := @rank + 1 as coranking FROM (SELECT c.id_campania, sum(v.precio)
FROM venta as v
LEFT JOIN articulo as a on v.referencia = a.referencia
LEFT JOIN departamento as d on d.id_dpto = a.id_dpto
LEFT JOIN depto_campania as dc on dc.id_dpto = d.id_dpto
LEFT JOIN campania as c on c.id_campania = dc.id_campania
JOIN (SELECT @row_number := 0) r
GROUP BY c.id_campania
ORDER BY sum(v.precio) DESC) as result;



/*5. Clasifique todas las ventas en Mayor, Igual o Menor precio respecto a la media de los precios de todas las ventas realizadas.*/

SELECT talon, referencia, precio, fecha_venta, if(precio > MEDIA_PRECIOS, 'MAYOR', if(precio < MEDIA_PRECIOS, 'MENOR', 'IGUAL')) as clasificacion
FROM venta as v
LEFT JOIN (SELECT AVG(precio) as MEDIA_PRECIOS FROM venta) as medias ON referencia = referencia;



/*7.Genere una consulta que para cada campaña de tipo "venta" obtenga el talón medio, precio medio, nº de referencias compradas y nº de talones con venta superior al talón medio.*/

SELECT AVG(v.talon) as talon_medio, AVG(v.precio) as precio_medio, COUNT(a.referencia) as num_referencias, sum(if(v.talon > tmedio.valor, 1, 0)) as mayor_talon_medio
FROM venta as v
LEFT JOIN articulo as a on v.referencia = a.referencia
LEFT JOIN departamento as d on d.id_dpto = a.id_dpto
LEFT JOIN depto_campania as dc on dc.id_dpto = d.id_dpto
LEFT JOIN campania as c on c.id_campania = dc.id_campania
LEFT JOIN (SELECT AVG(v.talon) as valor FROM venta as v) as tmedio on v.referencia = v.referencia
WHERE c.tipo = "venta"
GROUP BY c.id_campania;



/*8.Genere una o varias consultas que devulevan las combinaciones de familias y campañas cuya venta haya sido superior a 100€*/

SELECT a.cod_familia, c.id_campania, v.precio
FROM venta as v
LEFT JOIN articulo as a ON v.referencia = a.referencia
LEFT JOIN departamento as d ON d.id_dpto = a.id_dpto
LEFT JOIN depto_campania as dc ON dc.id_dpto = d.id_dpto
LEFT JOIN campania as c ON c.id_campania = dc.id_campania
WHERE v.precio > 100;



/*9.Genere una o varias consultas que permitan catalogar los artículos vendidos y que no son de la Campaña CA1, según si se tratan de artículos de Ropa o Accesorios. En base a los departamentos y familias*/ 
/*NOTA: Se valorará la elaboración de la consulta y no la veracidad del propio catálogo)*/

SELECT * ,if(desc_dpto = "JOYERIA", 'ACCESORIOS', if(desc_dpto= "BOLSOS", 'ACCESORIOS', 'ROPA')) as CLASE_ARTICULO
FROM venta as v
LEFT JOIN articulo as a ON v.referencia = a.referencia
LEFT JOIN dpto_campania ON a.id_dpto = dpto_campania.id_dpto
LEFT JOIN departamento as d ON depto_campania.id_dpto = d.id_dpto
WHERE depto_campania.id_campania != "CA1";



/*10.Genere una o varias consultas que devuelvan la variación del total de venta entre años. Tomando como variación la siguiente fórmula(Yearn-Yearn-1/Yearn-1)*/
/*(Se valorará el control de valores 0 en la división o de indeterminaciones)*/

SELECT year(fecha_venta), SUM(precio) as total_ventas_años, ventas_tot.año2, ventas_tot.total_ventas2, ((SUM(precio) - ventas_tot.total_ventas2) / ventas_tot.total_ventas2) as variacion_ventas
FROM venta as v
LEFT JOIN (SELECT year(fecha_venta) year2, SUM(precio) as total_ventas2 FROM venta GROUP BY year(fecha_venta)) as ventas_tot ON year(ven.fecha_venta) = ventas_tot.year2 + 1
WHERE year2 is not null
GROUP BY year(fecha_venta)
ORDER BY year(fecha_venta);