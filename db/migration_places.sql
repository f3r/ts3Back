SELECT 
  foo1.id, 
  foo1.geo_ansiname as name, 
  foo1.geo_latitude as lat, 
  foo1.geo_longitude as lon,
  foo3.geo_ansiname as state,
  foo2.name as country

 FROM cities as foo1
 
 JOIN countries as foo2
    ON foo1.geo_country_code = foo2.code_iso 
 
    JOIN states as foo3
    ON foo1.geo_admin1_code = foo3.geo_admin1_code
    AND foo2.code_iso = foo3.country_code

 WHERE foo1.geo_country_code IN ("ES")
 GROUP BY foo1.id,foo2.code_iso
 ORDER BY foo1.geo_ansiname;