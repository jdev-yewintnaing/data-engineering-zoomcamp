SELECT
    loc."Zone" AS pickup_location,
    SUM(t.total_amount) AS total_amount
FROM
    green_tripdata AS t
JOIN
    taxi_zone_lookup AS loc
ON
    t."PULocationID" = loc."LocationID"
WHERE
    DATE(t.lpep_pickup_datetime) = '2019-10-18'
GROUP BY
    loc."Zone"
HAVING
    SUM(t.total_amount) > 13000
ORDER BY
    total_amount DESC;

-- "pickup_location"	"total_amount"
-- "East Harlem North"	18686.680000000088
-- "East Harlem South"	16797.26000000007
-- "Morningside Heights"	13029.79000000004