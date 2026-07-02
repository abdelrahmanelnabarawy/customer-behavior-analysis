SELECT * FROM Customers

--- Total revenue by gender
  SELECT gender , SUM(purchase_amount) AS revenue
  FROM Customers
  GROUP BY gender

  --- customers used discount but still spend more than the average purchase amount

  SELECT customer_id , Purchase_amount
  FROM Customers
  WHERE discount_applied = 'Yes' AND Purchase_amount >= (SELECT AVG(Purchase_amount) FROM Customers)

  --- Top 5 products with highest average review

  SELECT TOP 5 item_purchased , ROUND(AVG(review_rating),2) AS Average_rating
  FROM Customers
  GROUP BY item_purchased
  ORDER BY Average_rating DESC

  --- Compare avg purchase amount between standard and express shipping

  SELECT shipping_type , AVG(Purchase_amount) AS avg_purchase
  FROM Customers
  WHERE shipping_type IN ('Standard','Express')
  GROUP BY shipping_type

  --- Do subscribed customers spend more? compare average spend and total revenue between
  --- subscribed and non-subscribed customers

 SELECT subscription_status , COUNT(customer_id) AS total_customers,
 ROUND(AVG(Purchase_amount),2) AS avg_purchase,
 ROUND(SUM(Purchase_amount),2) AS revenue
 FROM Customers
 GROUP BY subscription_status

 --- Which 5 products have the highest percentage of purchases with discount applied?

 SELECT TOP 5
    item_purchased,COUNT (*) AS total_purchases,
    SUM(CASE WHEN discount_applied ='Yes' THEN 1 ELSE 0 END) AS discounted_purchases,
    100.0*SUM(CASE WHEN discount_applied ='Yes' THEN 1 ELSE 0 END)/COUNT(*) AS discounted_percentage
FROM dbo.Customers
GROUP BY item_purchased
ORDER BY discounted_percentage DESC;

--- segment customers into New , Returning and Loyal based on their total number of previous purchases
--- and show the count of each segment

with customer_type as(
 SELECT customer_id ,previous_purchases,
 CASE 
 WHEN previous_purchases = 1 THEN 'NEW'
 WHEN previous_purchases BETWEEN 2 AND 10 THEN 'RETURNING'
 ELSE 'LOYAL'
 END AS customer_segment
 FROM Customers
)
SELECT customer_segment , COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment
ORDER BY number_of_customers

--- What are the most 3 purchased items for each category?
;with item_count as(
SELECT category, item_purchased,
COUNT(customer_id) AS total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id)DESC) AS item_rank
FROM Customers
GROUP BY category , item_purchased
)
SELECT item_rank, category, item_purchased,total_orders
FROM item_count
where item_rank <=3

--- Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status , COUNT(customer_id) AS repeat_buyers
FROM Customers
WHERE previous_purchases > 5
GROUP BY subscription_status

--- What is the revenue contribution for each age group?

SELECT age_group , SUM(Purchase_amount) AS revenue
FROM Customers
GROUP BY age_group
ORDER BY revenue DESC