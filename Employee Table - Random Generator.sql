--create a 2 dimensional table of names that will later be randomly mixed into new names
DROP TABLE IF EXISTS [#name_Generator];
CREATE TABLE #name_Generator
(
    first_Name NVARCHAR(20),
    last_Name NVARCHAR(20)
);
INSERT INTO #name_Generator
(
    first_Name,
    last_Name
)
VALUES
(   'John', -- first_Name - nvarchar(20)
    'Smith' -- last_Name - nvarchar(20)
    ),
(   'Mark', -- first_Name - nvarchar(20)
    'Jones' -- last_Name - nvarchar(20)
),
(   'Caleb',  -- first_Name - nvarchar(20)
    'Johnson' -- last_Name - nvarchar(20)
),
(   'Drew',  -- first_Name - nvarchar(20)
    'Miller' -- last_Name - nvarchar(20)
),
(   'Jacob',   -- first_Name - nvarchar(20)
    'Williams' -- last_Name - nvarchar(20)
),
(   'Anthony', -- first_Name - nvarchar(20)
    'Garcia'   -- last_Name - nvarchar(20)
),
(   'Katie', -- first_Name - nvarchar(20)
    'Davis'  -- last_Name - nvarchar(20)
),
(   'Sarah',   -- first_Name - nvarchar(20)
    'Martinez' -- last_Name - nvarchar(20)
),
(   'Lucy',  -- first_Name - nvarchar(20)
    'Wilson' -- last_Name - nvarchar(20)
),
(   'Paige', -- first_Name - nvarchar(20)
    'Taylor' -- last_Name - nvarchar(20)
),
(   'Hannah', -- first_Name - nvarchar(20)
    'Moore'   -- last_Name - nvarchar(20)
);


--create a one dimensional table of days ranging from a start day to today
DROP TABLE IF EXISTS [#start_Date_Generator];
CREATE TABLE #start_Date_Generator
(
    date DATE
);
DECLARE @start_Date AS DATE;
SET @start_Date = '01.01.2010';
WHILE COALESCE(
      (
          SELECT TOP 1 date FROM #start_Date_Generator ORDER BY date DESC
      ),
      @start_Date
              ) <
(
    SELECT GETDATE()
)
BEGIN
    INSERT INTO #start_Date_Generator
    (
        date
    )
    VALUES
    (@start_Date -- date - date
        );
    SET @start_Date = DATEADD(DAY, 1, @start_Date); --increase day generator by 1
END;

DROP TABLE IF EXISTS [#division_Generator];
CREATE TABLE #division_Generator
(
    division NVARCHAR(20)
);
INSERT INTO #division_Generator
(
    division
)
VALUES
('Marketing' -- division - nvarchar(20)
    ),
('Sales' -- division - nvarchar(20)
),
('Human Resources' -- division - nvarchar(20)
),
('Technology' -- division - nvarchar(20)
);

DROP TABLE IF EXISTS [#Employee];
CREATE TABLE #Employee
(
    employee_ID INT,
    first_Name NVARCHAR(20),
    last_Name NVARCHAR(20),
    age NVARCHAR(20),
    hire_Date NVARCHAR(20),
    division NVARCHAR(20),
    manager NVARCHAR(20)
);

DECLARE @table_Size AS INT;
SET @table_Size = 100;
DECLARE @employee_ID_Generator AS INT;
SET @employee_ID_Generator = 1;
WHILE
(SELECT COUNT(*)FROM #Employee) < @table_Size
BEGIN
    INSERT INTO #Employee
    (
        employee_ID,
        first_Name,
        last_Name,
        age,
        hire_Date,
        division,
        manager
    )
    VALUES
    (   (@employee_ID_Generator), -- assigns incrementing integers to each employee to be used as a primary key
        (
            SELECT TOP 1 first_Name FROM #name_Generator ORDER BY NEWID()
        ),                        -- first_Name - nvarchar(10) selects random first name from #name_Generator
        (
            SELECT TOP 1 last_Name FROM #name_Generator ORDER BY NEWID()
        ),                        -- last_Name - nvarchar(10) selects random last name from #name_Generator
        (
            SELECT FLOOR(RAND() * (60 - 18 + 1)) + 18
        ),                        -- age - nvarchar(10) selects random age between 18 and 60
        (
            SELECT TOP 1 date FROM #start_Date_Generator ORDER BY NEWID()
        ),                        -- hire_Date - nvarchar(10) selects random start date between @start_Date and today (uses #start_Date_Generator)
        (
            SELECT TOP 1 division FROM #division_Generator ORDER BY NEWID()
        ),                        -- division - nvarchar(10) selects a random value from #division_Generator
        NULL                      -- manager - nvarchar(10)
        );
    SET @employee_ID_Generator = @employee_ID_Generator + 1;
END;








DROP TABLE IF EXISTS [#every_N_Rows];
CREATE TABLE #every_N_Rows
(
    employee_ID INT,
    subordinate VARCHAR(20)
);
DECLARE @emp_ID_Iterator AS INT;
SET @emp_ID_Iterator = 1;
DECLARE @lowest_Subordinate AS INT;
SET @lowest_Subordinate = 3;
WHILE @lowest_Subordinate < @table_Size
BEGIN
    INSERT INTO #every_N_Rows
    (
        employee_ID,
        subordinate
    )
    SELECT @emp_ID_Iterator,
           CONCAT(
                     CAST(@lowest_Subordinate AS VARCHAR(3)),
                     ', ',
                     CAST(@lowest_Subordinate + 1 AS VARCHAR(3)),
                     ', ',
                     CAST(@lowest_Subordinate + 2 AS VARCHAR(3))
                 );
    SET @lowest_Subordinate = @lowest_Subordinate + 3;
    SET @emp_ID_Iterator = @emp_ID_Iterator + 1;
END;

----------------Final Table
SELECT e.employee_ID,
       e.first_Name,
       e.last_Name,
       e.age,
       e.hire_Date,
       e.division,
       n.subordinate AS subordinate_ID
FROM #Employee e
    LEFT JOIN #every_N_Rows n
        ON n.employee_ID = e.employee_ID;




-- #management_Generator is created after #employee table is created due to management_Generator needing #employee as input


--DECLARE @table_Size AS int
--SET @table_Size = 100;

--WITH management_Generator(employee_ID,manager,subordinate,bunch)
--AS (
--	SELECT
--		1,
--		0,
--		2,
--		0
--	UNION ALL
--	SELECT
--		employee_ID + 1,

--		CASE WHEN (SELECT(COUNT(*) FROM Management_Generator )
--		--SELECT LAG(manager,1) OVER (ORDER BY employee_ID ASC) FROM management_Generator
--		--CASE WHEN (SELECT COUNT((LAG(manager,1) FROM management_Generator) > 1) THEN 0,


--		subordinate + 1,
--		ROUND(AVG(manager) OVER (
--			PARTITION BY employee_ID),2)
--	FROM management_Generator
--	WHERE employee_ID < @table_Size
--)
--SELECT * FROM management_Generator


