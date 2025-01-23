SELECT
    CASE
        WHEN trip_distance <= 1 THEN 'Up to 1 mile'
        WHEN trip_distance > 1 AND trip_distance <= 3 THEN '1 to 3 miles'
        WHEN trip_distance > 3 AND trip_distance <= 7 THEN '3 to 7 miles'
        WHEN trip_distance > 7 AND trip_distance <= 10 THEN '7 to 10 miles'
        ELSE 'Over 10 miles'
    END AS distance_range,
    COUNT(*) AS trip_count
FROM
    green_tripdata
WHERE
   (lpep_dropoff_datetime >= '2019-10-01' AND
    lpep_dropoff_datetime < '2019-11-01')
GROUP BY
    distance_range;

-- "distance_range"	"trip_count"
-- "1 to 3 miles"	198924
-- "3 to 7 miles"	109603
-- "7 to 10 miles"	27678
-- "Over 10 miles"	35189
-- "Up to 1 mile"	104802