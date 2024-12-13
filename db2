-- Step 1: Create ranges by self-joining the main_table
WITH CTE_Ranges AS (
    SELECT 
        m.id AS start_id,
        COALESCE(MIN(n.id), m.id + 1) AS next_id,
        d.desc
    FROM 
        main_table m
        LEFT JOIN main_table n ON n.id > m.id
        LEFT JOIN desc_table d ON m.id = d.id
    GROUP BY m.id, d.desc
),
-- Step 2: Use recursion to generate IDs within the ranges
Recursive_CTE AS (
    -- Anchor query: Start with the first ID in the range
    SELECT 
        start_id AS generated_id,
        start_id AS original_id,
        desc
    FROM CTE_Ranges
    UNION ALL
    -- Recursive query: Generate subsequent IDs until the range is exhausted
    SELECT 
        rc.generated_id + 1,
        rc.original_id,  -- Keep the same original ID
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