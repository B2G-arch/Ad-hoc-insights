# 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region 

select customer,market,region from dim_customer
where customer='Atliq exclusive' and region='APAC';

# 2. What is the percentage of unique product increase in 2021 vs. 2020?

select count(distinct product_code) Unique_products, fiscal_year  from fact_sales_monthly 
group by fiscal_year;

# 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts

select count(distinct product_code) as Unique_products,segment from dim_product group by segment 
order by Unique_products desc;

# 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?

With CTE1 as (select a.product_code,b.segment, a.fiscal_year from fact_sales_monthly a join dim_product b on a.product_code = b.product_code)
select count(distinct product_code) as Products,segment,fiscal_year from CTE1 group by segment,fiscal_year;

# 5. Get the products that have the highest and lowest manufacturing costs.

with CTE1 as (select a.product_code,b.product, a.manufacturing_cost from fact_manufacturing_cost a join dim_product b on a.product_code = b.product_code)
select product_code,product ,manufacturing_cost from CTE1 order by manufacturing_cost desc;

# 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
With CTE1 as (select
 a.customer_code,b.customer, a.pre_invoice_discount_pct,b.market 
from 
fact_pre_invoice_deductions a join dim_customer b on a.customer_code = b.customer_code
where market = 'India' order by pre_invoice_discount_pct desc  )
select * from CTE1 limit 5;

# 7 Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month.

select
sum(gross_price*sold_quantity) as Atliq_Exclusive_gross_sales_amount ,year(date) as years ,month(date) as Months
from 
fact_gross_price a join fact_sales_monthly b on a.product_code = b.product_code
join dim_customer c 
on (a.product_code = b.product_code and b.customer_code=c.customer_code)
where customer= 'Atliq Exclusive' group by month(date),year(date) order by month(date) asc;


# 8. In which quarter of 2020, got the maximum total_sold_quantity?

select fiscal_year,quarter(date) as quarter_date, sum(sold_quantity) as sold_quantity from fact_sales_monthly
where fiscal_year='2020'
group by quarter_date
order by quarter_date;


# 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?

select
sum(gross_price*sold_quantity) as Sum_gross_sales_amount,max(gross_price*sold_quantity) as max_gross_sales_amount,
(((max(gross_price*sold_quantity)*100)/sum(gross_price*sold_quantity))*100) as channel_contribution_percentage ,b.fiscal_year
from 
fact_gross_price a join fact_sales_monthly b on a.product_code = b.product_code
join dim_customer c 
on (a.product_code = b.product_code and b.customer_code=c.customer_code)
where b.fiscal_year='2021';


# 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?	
 
 with Table_1 as (select *, row_number() over (Partition by division order by sold_quantity desc) as SN_no from 
 ( select a.division,a.product,b.sold_quantity,b.fiscal_year from dim_product a join fact_sales_monthly b on a.product_code = b.product_code
 where fiscal_year=2021 ) as CTE )
 select * from Table_1 where SN_no <= 3;

