Use retail_events_db;

/*QUERY1: Provide a list of products whose base price is less than 500 and comes under BOGOF promo.
This helps to identify the heavily discounted products.*/
Select distinct(dim_products.product_name), 
			   fact_events.base_price,
			   fact_events.promo_type
 from  dim_products inner join fact_events on 
 fact_events.product_code = dim_products.product_code
 where base_price>500 and promo_type='BOGOF';
 


/*Query2: Generate a report that provides an overview of the number osf stores in each city.
The results will be sorted in descending order of store counts allowing us to 
identify the cities with the highest store prescence. The report includes two essential 
fields city and store count.*/
 Select count(*) as Num_of_Stores,city  from dim_stores 
 group by 2 order by 1 desc;
 
Select distinct(city) from dim_stores;
/*Generate a report that displays each campaign along with total revenue generated before and after the campaign? The report includes three key fields:
Campaign_name,total_revenue(before_promotion),total_revenue(after_promotion). This SQL Query should help in evaluating 
the financial impact of our promotional campaigns. Display the values in millions.
*/
Select dim_campaigns.campaign_name,
sum(fact_events.quantity_sold_before_promo/1000000) as Total_Before_Promotion,
sum(fact_events.quantity_sold_after_promo/1000000) as Total_After_Promotion
from dim_campaigns inner join fact_events on 
dim_campaigns.campaign_id = fact_events.campaign_id
;


/*Produce a report that calculates the Incremental sold quantity(ISU%) for each category during the Diwali campaign. 
Additionally provide rankings for categories based on their isu%. The report will include 3 key fields : category,isu%,rank order.
 The information will assist in assessing the category wise success and impact of Diwali campaign on incremental sales.
Note: ISU%(Incremental Sold Quantity) is calculated as the % increase or % decrease in quantity sold (after promo) compared to quantity sold(before promo)*/
With cte as(
Select dim_products.category as category,
round((sum(fact_events.quantity_sold_after_promo) - sum(fact_events_sold_before_promo))*100/
sum(fact_events.quantity_sold_before_promo),3) as Incremental_Percentage
from dim_products join fact_events on dim_products.product_code = fact_events.product_code
join dim_campaigns on fact_events.campaign_id = dim_campaigns.campaign_id 
where dim_campaigns.campaign_name = 'Diwali'
group by dim_products.category)
Select dim_products.category,Incremental_Percentage, dense_rank() 
over (order by Incremental_Percentage) as Ranking from cte;

/*Create a report featuring the top 5 products ranked by Incremental Revenue percentage(IR%) across all campaigns. 
 This analysis helps identify the most successful products 
in terms of incremental revenue across our campaigns assisting in product optimization. */
With cte as (
Select dim_products.product_name,
dim_products.category,
round((sum(fact_events.quantity_sold_after_promo)/
sum(fact_events.quantity_sold_before_promo)*100),2) as IRevenue
from dim_products join fact_events on
dim_products.product_code = fact_events.product_code
group by
dim_products.product_name, dim_products.category)Select *,
dense_rank() over (order by IRevenue desc) as Ranking from cte limit 5;