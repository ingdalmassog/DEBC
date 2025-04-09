


--------EJERCICIO 002 -----------------------------------


-- 1

select 
    --*
    distinct 
        category_name 
from 
    categories c 
    
    
-- 2 
    
select
    --*
    distinct 
        region 
from 
    customers c 
    
-- 3 
    
select 
    distinct 
        CONTACT_TITLE 
from 
    customers c 
    
-- 4

select 
    *
from 
    customers c
order by
    country
        
-- 5
    
select 
    *
from 
    ORDERS
order by 
    employee_id 
    ,order_date 
    
-- 6 
    
select 
    *
from 
    customers c 
    
select column_name, data_type, character_maximum_length, column_default, is_nullable
from INFORMATION_SCHEMA.COLUMNS where table_name = 'customers';
    
insert into customers (customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax)
    values('GBY', 'DARESOFTWARELLC', 'Gabriel Dalmasso', 'Company Owner', 'Blas Parera 3309', 'Parana', 'ER', '3100', 'Argentina', '3435015865', '')
    
-- 7 
    
select 
    *
from 
    region r
    
insert into region (region_id, region_description)
    values(5, 'Capital City')
    
-- 8 
    
select 
    *
from 
    customers c
where 
    REGION is null
    
-- 9 
    
select 
    product_name 
    ,coalesce(unit_price, 10) as unit_price 
from 
    products p 
    
--- 10
    
select
    C.company_name 
    ,C.contact_name 
    ,O.order_date 
    --COUNT(*) -- 830
from 
    orders o 
    inner join 
        customers c 
        on C.customer_id = O.customer_id 
order by  
    O.order_date 
    
-- 11

select 
    OD.order_id 
    ,P.product_name
    ,OD.quantity 
    ,OD.discount 
from 
    order_details od
    inner join
        products p
        on P.product_id = OD.product_id 
        
/*
select 
    PRODUCT_ID
    ,COUNT(*)  
from 
    products p 
group by 
    1 
having 
    COUNT(*) > 1
*/
    
-- 12
        
select 
    *
from 
    orders o 
    left join 
        customers c 
        on C.customer_id = O.customer_id 
    
select 
    --*
    C.customer_id 
    ,C.company_name 
    ,O.order_id 
    ,O.order_date 
from 
    customers c
    left join 
        orders o 
        on C.customer_id = O.customer_id
--where 
--    O.order_id is null

-- 13
        
select 
    ET.employee_id
    ,e.last_name
    ,t.territory_id 
    ,t.territory_description 
from 
    employee_territories et
    left join 
        employees E 
        on ET.employee_id = E.employee_id
    left join 
        territories t 
        on t.territory_id = et.territory_id
        
select 
    e.employee_id
    ,e.last_name
    ,t.territory_id 
    ,t.territory_description 
from 
    employees e
    left join 
        employee_territories et 
        on ET.employee_id = E.employee_id
    inner join 
        territories t 
        on t.territory_id = et.territory_id        
        
-- 14
        
select 
    o.order_id
    ,c.company_name 
from 
    orders o 
    left join 
        customers c 
        on c.customer_id = o.customer_id
        
-- 15 

select
    O.order_id 
    ,C.company_name 
from 
    customers c 
    right join 
        orders o 
        on O.customer_id = C.customer_id
        
-- 16
        
select 
    S.company_name 
    ,O.order_date 
from 
    shippers s 
    right join 
        orders o 
        on O.ship_via = S.shipper_id
        
-- 17

select 
    E.first_name 
    ,E.last_name 
    ,ET.territory_id 
from 
    employees e 
    full outer join 
        employee_territories et 
        on ET.employee_id = E.employee_id
    
-- 18 
        
select 
    O.order_id 
    ,OD.unit_price 
    ,OD.quantity 
    ,(OD.quantity*OD.unit_price) as TOTAL
from 
    orders o
    full outer join 
        order_details od 
        on OD.order_id = O.order_id 
        
-- 19 

select 
    C.contact_name as NAME  
from 
    customers c 
union 
select 
    S.CONTACT_NAME as NAME 
from 
    suppliers s 
    
    
-- 20 
    
select 
    distinct 
        first_name as NAME
from 
    employees e 
    
select 
    FIRST_NAME as NAME
from 
    employees e 
where 
    employee_id <> 2 and employee_id <> 5
union 
select 
    first_name as NAME 
from 
    employees e2 
where 
    employee_id = 2 or employee_id = 5
    
    
-- 21 

select 
    distinct 
        S.PRODUCT_NAME
        ,S.PRODUCT_ID
from (
        select  
            P.product_id
            ,P.product_name
            ,P.units_in_stock 
            ,OD.order_id 
        from 
            products p 
            inner join 
                order_details od 
                on OD.product_id = P.product_id 
        where
            P.units_in_stock > 0    
    ) S
order by 
    PRODUCT_id
    
-- 22
    
select 
    distinct 
        c.company_name 
from 
    orders o
    inner join 
        customers c 
        on o.customer_id = c.customer_id 
where
    o.ship_country = 'Argentina' 
    
    
select 
    distinct
        c.company_name
from (
        select 
            c.company_name
        from 
            orders o
            inner join 
                customers c 
                on o.customer_id = c.customer_id 
        where
            o.ship_country = 'Argentina'
    ) c 
    
-- 23 

with no_french_client_orders as (
    select 
        distinct 
            order_id 
    from 
        orders o 
        left join (
                select 
                    distinct 
                        c.customer_id 
                from 
                    customers c 
                where 
                    c.country = 'France'
            ) fc
            on fc.customer_id = o.customer_id 
    where 
        fc.customer_id is null     
)
select
    distinct 
    p.product_name 
    ,p.product_id 
from 
    order_details od 
    inner join 
        no_french_client_orders nfo
        on nfo.order_id = od.order_id 
    left join 
        products p 
        on 
            p.product_id = od.product_id 
order by 
    p.product_id
        

-- 24
    
select 
    od.order_id
    ,sum(quantity)
from 
    order_details od 
group by 
    1

-- 25 
    
select 
    p.product_id 
    ,p.product_name 
    ,avg(units_in_stock) 
from 
    products p 
group by 
    p.product_id 
    ,p.product_name
--having 
--    avg(units_in_stock) = 115


-- 26 
    
select 
    p.product_id 
    ,p.product_name 
    ,avg(units_in_stock) 
from 
    products p 
group by 
    p.product_id 
    ,p.product_name
having 
    avg(units_in_stock) > 100

    
-- 27 

select 
   O.customer_id 
   ,O.COMPANY_NAME
   ,AVG(Q)   --- TODO: check HERE, THE SCREENSHOT in THE REQUIREMENT is SHOWING THE AVG(ORDER_ID) and IT'S WRONG!!!
from (
        select 
            c.customer_id 
            ,c.company_name 
            ,count(order_id) as Q
        from 
            orders o 
            inner join 
                customers c 
                on o.customer_id = c.customer_id 
        group by 
            1,2
    ) O
group by 
    1,2
having 
    AVG(Q) > 10


-- 28 
    
select 
    P.product_name 
    ,case 
        when P.DISCONTINUED = 1
            then 'Discontinued'
        else 
            c.category_name 
    end as CATEGORY
from 
    products p 
    left join 
        categories c 
        on C.category_id = P.category_id 
        
-- 29 
        
select 
    first_name 
    ,last_name 
    ,case 
        when title = 'Sales Manager'
            then 'Gerente de Ventas'
        else 
            title
    end as job_title
from 
    employees e 
    
