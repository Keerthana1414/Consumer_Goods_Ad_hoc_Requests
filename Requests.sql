-- Request1
select distinct market from gdb023.dim_customer
where region = 'APAC';


-- Request2
with CTE AS
(
select count(distinct case when fiscal_year='2020' then product_code end ) as unique_products_2020, 
count( distinct case when fiscal_year='2021' then product_code end) as unique_products_2021 
from gdb023.fact_gross_price
)
select unique_products_2020, unique_products_2021, 
((unique_products_2021 - unique_products_2020)/unique_products_2020)*100 as Percentage_change
from CTE;


-- Request3
select segment, count(product_code) as product_count from gdb023.dim_product
group by segment;


-- Request4
with CTE AS
(
select segment, count(distinct case when fiscal_year = 2020 then a.product_code end) as Product_count_2020,
count(distinct case when fiscal_year = 2021 then a.product_code end) as Product_count_2021
from gdb023.dim_product as a
join gdb023.fact_gross_price as b 
on a.product_code = b.product_code
group by segment 
)
select segment, Product_count_2020, Product_count_2021, (Product_count_2021-Product_count_2020) as Difference from CTE;


-- Request5
select a.product_code, product, manufacturing_cost from gdb023.dim_product as a
join gdb023.fact_manufacturing_cost as b
on a.product_code = b.product_code
order by manufacturing_cost desc
Limit 10;
select a.product_code, product, manufacturing_cost from gdb023.dim_product as a
join gdb023.fact_manufacturing_cost as b
on a.product_code = b.product_code
order by manufacturing_cost 
Limit 10;


-- Request6
select a.customer_code, customer, avg(pre_invoice_discount_pct) *100 as average_discount_percentage 
from gdb023.dim_customer a
join gdb023.fact_pre_invoice_deductions b
on a.customer_code = b.customer_code
where fiscal_year='2021' and market='India'
group by a.customer_code, customer
order by average_discount_percentage desc
Limit 5;


-- Request7
with cte as 
(
select year(date) as Year, month(date) as Month_no, monthname(date) as Month, sum(gross_price * sold_quantity) as Gross_sales_amount from gdb023.fact_sales_monthly a 
join gdb023.fact_gross_price b
on a.product_code = b.product_code
join gdb023.dim_customer c on a.customer_code = c.customer_code
where a.fiscal_year = b.fiscal_year and customer = 'Atliq Exclusive'
group by year(date), month(date), monthname(date)
)
select Year, Month, Gross_sales_amount from cte 
order by Year,Month_no;


-- Request8
with cte as
(
select year(date) as Year, monthname(date) as Month, sum(sold_quantity) as Total_sold_quantity
from gdb023.fact_sales_monthly
group by year(date), monthname(date)
)
select case 
	when Month in ('September', 'October', 'November') and Year='2019' then '1'
    when Month in ('December') and Year='2019' then '2'
    when Month in ('January', 'February') and Year='2020' then '2'
    when Month in ('March', 'April', 'May') and Year='2020' then '3'
    when Month in ('June', 'July', 'August') and Year='2020' then '4' end as quarter, sum(Total_sold_quantity) as Total_sold_quantity  from cte
group by case 
	when Month in ('September', 'October', 'November') and Year='2019' then '1'
    when Month in ('December') and Year='2019' then '2'
    when Month in ('January', 'February') and Year='2020' then '2'
    when Month in ('March', 'April', 'May') and Year='2020' then '3'
    when Month in ('June', 'July', 'August') and Year='2020' then '4' end 
order by quarter;


-- Request9
with cte as
(
select channel, sum(sold_quantity * gross_price) as  Gross_sales
from gdb023.dim_customer a join gdb023.fact_sales_monthly b
on a.customer_code = b.customer_code
join gdb023.fact_gross_price c
on b.product_code = c.product_code
where b.fiscal_year = '2021'
group by channel
)
select channel, Gross_sales, (Gross_sales/sum(Gross_sales) over())*100 as Total_sales
from cte;


-- Request10
with cte as 
(
select division, a.product_code as product_code, product, sum(sold_quantity) as total_sold_qty from gdb023.dim_product a
join gdb023.fact_sales_monthly b 
on a.product_code = b.product_code
where fiscal_year='2021'
group by division, a.product_code, product
), cte2 as 
(
select division, product_code, product, total_sold_qty, 
rank() over(partition by division order by total_sold_qty desc) as rank_order
from cte
)
select division, product_code, product, total_sold_qty, rank_order
from cte2
where rank_order in (1,2,3);













