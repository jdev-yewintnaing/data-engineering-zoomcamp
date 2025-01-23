select * from
  (SELECT
        DATE(lpep_pickup_datetime) AS pickup_date,
        MAX(trip_distance) AS max_distance
    FROM
        green_tripdata
    GROUP BY
        DATE(lpep_pickup_datetime)
		) where  pickup_date IN ('2019-10-11', '2019-10-24', '2019-10-26', '2019-10-31')
ORDER BY
    max_distance DESC
LIMIT 1;

-- "pickup_date"	"max_distance"
-- "2019-10-31"	515.89