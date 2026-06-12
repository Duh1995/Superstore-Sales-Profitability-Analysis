select *
from raw_orders
limit 10;

-- Estrutura da tabela

select
	column_name,
	data_type
from information_schema.columns	
where table_name ='raw_orders';

-- Quantas linhas existe
select count(*) as total_rows
from raw_orders;

--Procurar Nulls

SELECT *
FROM raw_orders
WHERE
    "Order ID" IS NULL
    OR "Customer Name" IS NULL
    OR "Sales" IS NULL;

-- Ver Duplicados

select 
	"Order ID",
	Count(*) as Total 
from raw_orders ro 
group by "Order ID"
having COUNT(*) > 1
order by total desc;

select *,
	count(*) as total_duplicates
from raw_orders ro 
group by "Row ID",
    "Order ID",
    "Order Date",
    "Ship Date",
    "Ship Mode",
    "Customer ID",
    "Customer Name",
    "Segment",
    "Country",
    "City",
    "State",
    "Postal Code",
    "Region",
    "Product ID",
    "Category",
    "Sub-Category",
    "Product Name",
    "Sales",
    "Quantity",
    "Discount",
    "Profit"
Having count(*) > 1

-- Criação de Tabela Limpa

create table clean_orders as 
select
	"Row ID" AS row_id,
    "Order ID" AS order_id,
    "Order Date" AS order_date,
    "Ship Date" AS ship_date,
    "Ship Mode" AS ship_mode,
    "Customer ID" AS customer_id,
    "Customer Name" AS customer_name,
    "Segment" AS segment,
    "Country" AS country,
    "City" AS city,
    "State" AS state,
    "Postal Code" AS postal_code,
    "Region" AS region,
    "Product ID" AS product_id,
    "Category" AS category,
    "Sub-Category" AS sub_category,
    "Product Name" AS product_name,
    "Sales" AS sales,
    "Quantity" AS quantity,
    "Discount" AS discount,
    "Profit" AS profit
FROM raw_orders;

-- Verificação dos Dados

select 
	column_name,
	data_type
from information_schema.columns 
where table_name = 'clean_orders';

--Ver Datas

SELECT *
FROM raw_orders
WHERE "Ship Date" < "Order Date" ;

-- Converter Datas

select 
	order_date,
	to_date(order_date, 'MM/DD/YYYY')
from clean_orders
limit 10;

-- Alterar Tabelas

alter table clean_orders
alter column order_date type date
using to_date(order_date, 'MM/DD/YYYY')

alter table clean_orders
alter column ship_date type date
using to_date(ship_date, 'MM/DD/YYYY');

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'clean_orders';

-- Ver Categorias, SubCategorias, Região

select distinct category
from clean_orders co
order by category 

select distinct sub_category
from clean_orders co 
order by sub_category

select distinct region
from clean_orders co 
order by region


-- Vendas e Lucro por Categoria

select
	category,
	Round(Sum(sales)::numeric,2) as total_sales,
	round(sum(profit)::numeric,2) as total_profit
from clean_orders
group by category
order by total_sales desc

-- Vendas por Ano

select 
	extract(year from order_date) as year,
	Round(sum(sales)::numeric, 2) as total_sales
	from clean_orders
	group by year
	order by year

-- Top 10 Produtos
	
select 
	product_name,
	Round(sum(sales)::numeric,2) as total_sales
from clean_orders co 
group by product_name 
order by total_sales desc
limit 10

-- Produtos com Prejuízo

select 
	product_name,
	Round(sum(profit)::numeric,2) as total_profit
from clean_orders co 
group by product_name 
having Sum(profit) < 0
order by total_profit 

-- Impacto dos Descontos

select 
	discount,
	Round (Avg(profit)::numeric,2) as avg_profit
from clean_orders co 
group by discount
order by discount 

-- Top Clientes

select 
	customer_name,
	Round(sum(sales)::numeric,2) as total_sales,
	round(sum(profit)::numeric,2) as total_profit
from clean_orders co 
group by customer_name 
order by total_sales desc
limit 10

-- Top Descontos Por Cliente

select 
	customer_name,
	Round(avg(discount)::numeric,2) as avg_discount,
	round(sum(sales)::numeric,2) as total_sales,
	round(sum(profit)::numeric,2) as total_profit
from clean_orders 
group by customer_name
order by avg_discount desc, total_sales desc

-- Clientes Com Mais Prejuízo

SELECT
    customer_name,
    ROUND(AVG(discount)::numeric, 2) AS avg_discount,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM clean_orders
GROUP BY customer_name
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- Relação Desconto vs Lucro

select
	discount,
	count(*) as total_orders,
	Round(avg(profit)::numeric,2) as avg_profit,
	round(sum(profit)::numeric,2) as total_profit
from clean_orders co 
group by discount 
order by discount

-- Top Clientes Por Prejuízo

select
	customer_name,
	round(sum(sales)::numeric,2) as total_sales,
	round(sum(discount)::numeric,2) as total_discount,
	round(sum(profit)::numeric,2) as total_profit
from clean_orders co 
group by customer_name 
order by total_profit asc 
limit 10

-- Descontos Altos = Prejuízo

select 
	case
		when discount = 0 then 'No Discount'
		when discount <= 0.2 then '0% - 20%'
		else 'Above 20%'
	end as discount_group,
	count(*) as total_orders,
	round(sum(sales)::numeric,2) as total_sales,
	round(sum(profit)::numeric,2) as total_profit,
	round(avg(profit)::numeric,2) as avg_profit
from clean_orders
group by discount_group
order by total_profit desc

-- Impacto de Grandes Vendas

select
    customer_name,
    round(sum(sales)::numeric, 2) AS total_sales,
    round(avg(discount)::numeric, 2) AS avg_discount,
    round(sum(profit)::numeric, 2) AS total_profit
from clean_orders
group by customer_name
having
    sum(sales) > 10000
    and avg(discount) > 0.2
order by total_profit;


-- KPI Geral da Empresa

select
	round(sum(sales)::numeric,2) as total_sales,
	round(sum(profit)::numeric,2) as total_profit,
	round(avg(discount)::numeric,2) as avg_discount,
	count(distinct customer_id) as total_customers,
	count(distinct order_id) as total_orders
from clean_orders

-- Top Clientes com ranking

with customer_sales as (
	select 
		customer_name,
		round(sum(sales)::numeric,2) as total_sales,
		round(sum(profit)::numeric,2) as total_profit
	from clean_orders
	group by customer_name 
	)
	
	select*
	from customer_sales
	order by total_sales desc
	limit 10
	

select
	customer_name,
	round(sum(sales)::numeric,2) as total_sales,
	rank() over(
			order by sum(sales) desc
			) as sales_rank
from clean_orders
group by customer_name 

--Running Total Mensal

select 
	date_trunc('month', order_date) as month,
	round(sum(sales)::numeric,2) as total_sales,
	round(
		sum(sum(sales)) over (
			order by date_trunc('month', order_date)
			)::numeric,2
		) as running_total
	from clean_orders
	group by month
	order by month
	
	
--View
	--View Mensal
	
create view monthly_sales_summary as

	select 
		date_trunc('month', order_date) as month,
		round(sum(sales)::numeric,2) as total_sales,
		round(sum(profit)::numeric,2) as total_profit,
		count(distinct order_id) as total_orders,
		count(distinct customer_id) as total_customers
	from clean_orders 
	group by month
	order by month
	
	select*
	from monthly_sales_summary
	
	--Performance dos Produtos
	
create view product_performance as 
		select 
			product_name,
			category,
			sub_category,
			round(sum(sales)::numeric,2) as total_sales,
			round(sum(profit)::numeric,2) as total_profit,
			round(avg(discount)::numeric,2) as avg_discount,
			sum(quantity) as total_quantity
		from clean_orders
		group by product_name, category,sub_category
		
	select*
	from product_performance
	

--Customers Insights

create view customer_insights as
	select
    	customer_id,
    	customer_name,
    	segment,
    	region,
    	round(sum(sales)::numeric, 2) as total_sales,
    	round(sum(profit)::numeric, 2) as total_profit,
    	round(avg(discount)::numeric, 2) as avg_discount,
    	count(distinct order_id) as total_orders
from clean_orders
group by    customer_id, customer_name, segment, region

select *
from customer_insights

--Top Produtos Dentro de Categoria
select *
from (
    select
        category,
        product_name,
        round(sum(sales)::numeric, 2) as total_sales,
        rank() over (
            partition by category
            order by  sum(sales) desc
        ) as product_rank
    from clean_orders
    group by category, product_name
) ranked_products
where product_rank <= 3;

select*
from (
	select
		category,
		product_name,
		Round(sum(sales)::numeric,2) as total_sales,
		rank() over(
		partition by category
		order by sum(sales) desc
		) as product_rank 
	from clean_orders
	group by category, product_name 
) ranked_products
where product_rank <= 3