-- Step 1: Create ranges using self-join
WITH CTE_Ranges AS (
    SELECT 
        a.id AS start_id,
        COALESCE(MIN(b.id), a.id + 1) AS next_id,
        a.desc
    FROM 
        main_table a
        LEFT JOIN main_table b ON b.id > a.id
    GROUP BY a.id, a.desc
),
-- Step 2: Generate IDs within the ranges
Recursive_CTE AS (
    -- Anchor query: Start with the first ID in each range
    SELECT 
        start_id AS generated_id,
        start_id AS original_id,
        desc
    FROM CTE_Ranges
    UNION ALL
    -- Recursive query: Generate IDs up to the `next_id` boundary
    SELECT 
        rc.generated_id + 1,
        rc.original_id,
        rc.desc
    FROM Recursive_CTE rc
    JOIN CTE_Ranges r
      ON rc.generated_id + 1 < r.next_id
     AND rc.generated_id >= r.start_id
)
-- Step 3: Final SELECT
SELECT 
    generated_id AS id,
    original_id,
    desc
FROM Recursive_CTE
ORDER BY generated_id;