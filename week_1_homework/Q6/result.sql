SELECT
    loc_drop."Zone" AS dropoff_zone,
    MAX(t.tip_amount) AS largest_tip
FROM
    green_tripdata AS t
JOIN
    taxi_zone_lookup AS loc_pick
ON
    t."PULocationID" = loc_pick."LocationID"
JOIN
    taxi_zone_lookup AS loc_drop
ON
    t."DOLocationID" = loc_drop."LocationID"
WHERE
    loc_pick."Zone" = 'East Harlem North'
    AND t.lpep_pickup_datetime >= '2019-10-01'
    AND t.lpep_pickup_datetime < '2019-11-01'
GROUP BY
    loc_drop."Zone"
ORDER BY
    largest_tip DESC
LIMIT 1;

-- "dropoff_zone"	"largest_tip"
-- "JFK Airport"	87.3