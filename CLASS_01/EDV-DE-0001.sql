create table DISENGADGEMENTS_RAW (
    ID INTEGER,
    NAME VARCHAR(100),
    SURNAME VARCHAR(100),
    DEPARTMENT VARCHAR(255),
    INITIAL_DATE DATE,
    FINAL_DATE DATE,
    level VARCHAR(10),
    RECRUITMENT_GROUP VARCHAR(100),
    RECRUITMENT_TIME INTEGER,
    SALARY_RANGE VARCHAR(50),
    COMP_SALARY_RANGE VARCHAR(50),
    MANAGER INTEGER,
    TRAINED VARCHAR(10)
);


COPY DISENGADGEMENTS_RAW(ID, NAME, SURNAME, DEPARTMENT, INITIAL_DATE, FINAL_DATE, level, RECRUITMENT_GROUP, RECRUITMENT_TIME, SALARY_RANGE, COMP_SALARY_RANGE, MANAGER, TRAINED)
FROM 
    '/var/tmp/Utimas_Desvinculaciones_Row_data.csv'
--'C:\sampledb\persons.csv'
DELIMITER ','
CSV HEADER;

----

create table MANAGERS (
    ID INTEGER,
    NAME VARCHAR(100),
    SURNAME VARCHAR(100)
);


COPY MANAGERS(ID, NAME, SURNAME)
FROM 
    '/var/tmp/Utimas_Desvinculaciones_Managers.csv'
--'C:\sampledb\persons.csv'
DELIMITER ','
CSV HEADER;


----

create table RANGES_LOOKUP (
    SALARY_RANGE VARCHAR(50),
    MIN_SALARY INTEGER,
    MAX_SALARY INTEGER
);


COPY RANGES_LOOKUP(SALARY_RANGE, MIN_SALARY, MAX_SALARY)
FROM 
    '/var/tmp/Utimas_Desvinculaciones_Ranges.csv'
--'C:\sampledb\persons.csv'
DELIMITER ','
CSV HEADER;

------

------------------------------------------------------------------------------------ ###################### ANALYSYS ################################ ----------------------------------------------------------------


-- CLEANING THE RAW DATA

select
    *
from
    ranges_lookup
    
create table SALARY_RANGES_LOOKUP as 
select 
    cast(trim(leading 'Rango ' from SALARY_RANGE) as INTEGER) as SALARY_RANGE_ID
    ,MIN_SALARY
    ,MAX_SALARY
from 
    RANGES_LOOKUP
    

select
    *
from
    SALARY_RANGES_LOOKUP
    
-----
    
select
    *
from
    MANAGERS

    
---
    
    
create table disengadgements AS
select
    ID as EMPLOYEE_ID
    ,NAME 
    ,SURNAME as LAST_NAME 
    ,DEPARTMENT
    ,INITIAL_DATE
    ,FINAL_DATE
    ,cast(trim(leading 'N' from LEVEL) as INTEGER) as level
    ,cast(trim(leading 'Grupo ' from RECRUITMENT_GROUP) as VARCHAR(1)) as RECRUITMENT_GROUP --  TODO: THIS CAN BE AN INTEGER 
    ,RECRUITMENT_TIME AS RECRUITMENT_TIME_MONTHS
    ,cast(trim(leading 'Rango ' from SALARY_RANGE) as INTEGER) as SALARY_RANGE_ID
    ,cast(trim(leading 'Rango ' from COMP_SALARY_RANGE) as INTEGER) as COMP_SALARY_RANGE_ID
    ,MANAGER as MANAGER_ID
    ,case 
        when UPPER(TRAINED) = 'SI'
            then true
        when 
            UPPER(TRAINED) = 'NO'
            then FALSE
        else 
            NULL
    end as TRAINED
from
    disengadgements_raw
    

---- ANALYSIS    
select
    -- TIME_WINDOW
    MIN(FINAL_DATE) MIN_DISENGADGMENT_DATE -- 2017-11-30
    ,MAX(FINAL_DATE) MAX_DISENGADGMENT_DATE -- 2022-07-01
from
    disengadgements

    
-- THE 70% OF THE DISENGADMENTS WERE IN 2021 AND 2022
with D_BY_YEAR as (    
    select
        EXTRACT(YEAR FROM final_date) as YEAR
        --,EXTRACT(MONTH FROM final_date) as MONTH
        -- ,COUNT(*) OVER(partition by EXTRACT(YEAR FROM final_date) order by EXTRACT(YEAR FROM final_date)) as DISENGADMENTS_BY_YEAR
        ,count(*) as DISENGADMENTS_BY_YEAR
    from
        disengadgements
    group by
        year
)
,DISENGADMENTS_BY_YEAR as (
    select 
        D.year 
        ,D.DISENGADMENTS_BY_YEAR
        ,(D.DISENGADMENTS_BY_YEAR/(select SUM(DISENGADMENTS_BY_YEAR) from d_by_year))*100 as PERCENTAGE
    from 
        D_BY_YEAR as D
    --order by 
    --    percentage DESC
)
,D_BY_TRAINED as (    
    select
        D.TRAINED
        ,count(*) as DISENGADMENTS_BY_TRAINED
    from
        disengadgements D
    group by
        D.TRAINED
)
--- THE 67% OF THE DISENGADMENTS ARE TRAINED PEOPLE
,DISENGADMENTS_BY_TRAINED as (
    select 
        D.TRAINED 
        --,D.DISENGADMENTS_BY_TRAINED
        ,(D.DISENGADMENTS_BY_TRAINED/(select SUM(DISENGADMENTS_BY_TRAINED) from D_BY_TRAINED))*100 as PERCENTAGE
    from 
        D_BY_TRAINED D
    --group by 
      --  D.TRAINED
)
select 
    *
from 
    DISENGADMENTS_BY_TRAINED;
    
    

---
    
with TOTAL_D as (
    select 
        EMPLOYEE_ID
        ,NAME
        ,LAST_NAME
        ,DEPARTMENT
        ,INITIAL_DATE
        ,FINAL_DATE
        ,EXTRACT(YEAR FROM final_date) as D_YEAR
        ,FINAL_DATE - INITIAL_DATE as LIFE_TIME_DAYS
        ,FLOOR((FINAL_DATE - INITIAL_DATE)/30.4167) as LIFE_TIME_MONTHS
        --,AGE(FINAL_DATE, INITIAL_DATE) 
        ,level
        ,RECRUITMENT_GROUP
        ,RECRUITMENT_TIME_MONTHS
        ,SALARY_RANGE_ID
        ,COMP_SALARY_RANGE_ID
        ,MANAGER_ID
        ,TRAINED
        ,SUM(Q_ID) OVER(ORDER by Q_ID) as TOTAL_D
        ,case 
            when COMP_SALARY_RANGE_ID < SALARY_RANGE_ID
                then -- 'LS'
                    -1
            when COMP_SALARY_RANGE_ID > SALARY_RANGE_ID
                then --'MS'
                    1
            else 
                0 --'ES'
        end as SALARY_CHOICE
    from (
        --DEDUPLICATIG DATA
        select
            *
            ,row_number() over (partition by employee_id order by employee_id) as Q_ID
        from 
            disengadgements
    )
    where 
        Q_ID = 1
)
/*
select 
    *
from
    TOTAL_D
*/
,ADD_LIFE_TIME_FLAG as (
    select 
        EMPLOYEE_ID
        ,NAME
        ,LAST_NAME
        ,DEPARTMENT
        ,INITIAL_DATE
        ,FINAL_DATE
        ,D_YEAR
        ,LIFE_TIME_DAYS
        ,LIFE_TIME_MONTHS
        ,case 
            when LIFE_TIME_MONTHS <= 12
                then 1
            when LIFE_TIME_MONTHS between 13 and 24
                then 2 
            when LIFE_TIME_MONTHS between 25 and 36
                then 3
            when LIFE_TIME_MONTHS between 37 and 48
                then 4
            else 
                5
        end as year_OF_D
        ,level
        ,RECRUITMENT_GROUP
        ,RECRUITMENT_TIME_MONTHS
        ,SALARY_RANGE_ID
        ,COMP_SALARY_RANGE_ID
        ,MANAGER_ID
        ,TRAINED
        ,TOTAL_D
        ,SALARY_CHOICE
    from
        TOTAL_D
)
,ADD_COUNTERS as (
    select 
        *  
        ,COUNT(*) OVER(partition by SALARY_RANGE_ID) as DISENGADMENTS_BY_SALARY_RANGE
        ,COUNT(*) OVER(partition by COMP_SALARY_RANGE_ID) as DISENGADMENTS_BY_COMP_SALARY_RANGE
        ,COUNT(*) OVER(partition by department) as DISENGADMENTS_BY_DEPARTMENT
        ,COUNT(*) OVER(partition by trained) as DISENGADMENTS_BY_TRAINED
        ,COUNT(*) OVER(partition by EXTRACT(YEAR FROM final_date)) as DISENGADMENTS_BY_YEAR
        ,COUNT(*) OVER(partition by LEVEL) as DISENGADMENTS_BY_LEVEL
        ,COUNT(*) OVER(partition by RECRUITMENT_GROUP) as DISENGADMENTS_BY_RECRUITMENT_GROUP
        ,COUNT(*) OVER(partition by MANAGER_ID) as DISENGADMENTS_BY_MANAGER_ID
        ,COUNT(*) OVER(partition by SALARY_CHOICE) as DISENGADMENTS_BY_SALARY_CHOICE
        ,COUNT(*) OVER(partition by YEAR_OF_D) as DISENGADMENTS_BY_LIFE_TIME_YEAR
    from 
        ADD_LIFE_TIME_FLAG
)
select
    R.DEPARTMENT
    ,R.FINAL_DATE
    ,R.D_YEAR
    --,LIFE_TIME_DAYS
    ,R.LIFE_TIME_MONTHS
    ,case 
        when R.year_OF_D = 1 
                then '1 año'
            when R.year_OF_D = 2
                then '2 años' 
            when R.year_OF_D = 3
                then '3 años'
            when R.year_OF_D = 4
                then '4 años'
            else 
                'Mas de 4 años'
    end as Antiguedad
    ,R.level
    ,R.RECRUITMENT_GROUP
    ,R.RECRUITMENT_TIME_MONTHS
    ,R.SALARY_RANGE_ID
    ,(S.max_salary + S.min_salary)/2 as SALARY
    ,R.COMP_SALARY_RANGE_ID
    ,(S.max_salary + S.min_salary)/2 as COMP_SALARY
    ,R.MANAGER_ID
    ,M.surname 
    ,R.TRAINED as TRAINED_FLAG
    ,case 
        when 
            R.TRAINED = true
                then 'Con Capacitacion'
        when 
            R.TRAINED = false
                then 'Sin Capacitacion'
    end as CAPACITACION
    ,R.TOTAL_D
    ,R.SALARY_CHOICE as SALARY_CHOICE_FLAG 
    ,case 
        when R.SALARY_CHOICE = -1
            then 'Lower Salary'
        when R.SALARY_CHOICE = 0
            then 'Equal Salary'
        when R.SALARY_CHOICE = 1
            then 'Higher Salary'
    end as SALARY_CHOICE
    ,R.TOTAL_D as TOTAL_DESVINCULACIONES
    ,DISENGADMENTS_BY_SALARY_RANGE
    ,DISENGADMENTS_BY_COMP_SALARY_RANGE
    ,DISENGADMENTS_BY_DEPARTMENT
    ,DISENGADMENTS_BY_TRAINED
    ,DISENGADMENTS_BY_YEAR
    ,DISENGADMENTS_BY_LEVEL as DISENGADMENTS_BY_HIERARCHY 
    ,DISENGADMENTS_BY_RECRUITMENT_GROUP
    ,DISENGADMENTS_BY_MANAGER_ID as DISENGADMENTS_BY_MANAGER
    ,DISENGADMENTS_BY_SALARY_CHOICE
    ,DISENGADMENTS_BY_LIFE_TIME_YEAR 
from 
    ADD_COUNTERS as R
    -- left join
    inner join   
        SALARY_RANGES_LOOKUP as S
        on R.SALARY_RANGE_ID = S.salary_range_id 
    INNER join
        managers as M
        on R.MANAGER_ID = M.id
        



WHERE 
    --life_time_months < 12 
    -- life_time_months between 24 and 36
    --life_time_months between 12 and 24 
--group by 
    --ALL

    
    
    
    
    
    