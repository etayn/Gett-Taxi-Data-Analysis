/*
This analsys based on Gett taxi test for data science position, provided by the website Stratascratch (Link in README),
the test consist of the following questions:

1 - Build up distribution of orders according to reasons for failure: 
cancellations before and after driver assignment, and reasons for order rejection.
Analyse the resulting plot. Which category has the highest number of orders?

2 - Plot the distribution of failed orders by hours. 
Is there a trend that certain hours have an abnormally high proportion of one category or another?
What hours are the biggest fails? How can this be explained?

3 - Plot the average time to cancellation with and without driver, by the hour. 
If there are any outliers in the data, it would be better to remove them. Can we draw any conclusions from this plot?

4 - Plot the distribution of average ETA by hours. How can this plot be explained?
 
 */

 -- Skills used: alternate table, update table, case when, datetime calculation, aggregate functions

 -- order_status_key: 4 - cancelled by client , 9 - cancelled by system

 -- Renaming order_status_key to CancellationReason, and changing the values from 4 and 9 to client and system
 exec sp_rename 'Orders.order_status_key' , 'CancellationReason' ,'column'

 alter table Orders
 alter column CancellationReason varchar(10)

 update Orders
 set CancellationReason = case when CancellationReason= 4 then 'client'
								when CancellationReason = 9 then 'system'
								else CancellationReason end

/*
 Question 1 - Results by table and Plot (In tableau): firstly CancellationReason = system and is_driver_assigned_key = 1
 has only 3 orders, so later we will remove this outliers from the table. Futhermore CancellationReason = client and
 is_driver_assigned_key = 0 has the highest number of orders
 */

 select CancellationReason , is_driver_assigned_key , count(is_driver_assigned_key) as NumberOfOrders
 from Orders
 group by CancellationReason , is_driver_assigned_key
 order by 1,2

 /*
 Question 2 - Results by Plot (In tableau): By looking the the chart in tableau we can see that on 8:00 for all categories 
there is abnormal number of cancelled orders than the rest of the day, expect around 21:00. but in contrast in 21:00
for the categories CancellationReason = client and is_driver_assigned_key = 1 the number of orders isn't high as at 8:00
(for the others this is not the case and at 8:00 and 21:00 there are about the same number of orders).
one explaination is than in 8:00 when drivers are matched with clients the waiting time is too long because of 
morning rush hours and client are cancelling the order, when at 21:00 this is rarley the case.

NOTE - here i'm deleting the 3 orders that are CancellationReason = 'system' and is_driver_assigned_key = 1,
as i mention this before.
 */

 delete from Orders
 where CancellationReason = 'system' and is_driver_assigned_key = 1
 
 select DATEPART(hour , order_datetime) as hour, CancellationReason , is_driver_assigned_key , count(is_driver_assigned_key) as NumberOfOrders
 from Orders
 group by DATEPART(hour , order_datetime),CancellationReason , is_driver_assigned_key
 order by 1,4 desc
 
/*
Question 3 - Results by Plot (In tableau): first we can see that for all hours the average time for cancellation when driver
is matched is higher than when driver isn't assigned yet. people maybe less rush to cancelled order after thay have a driver
becuase there is the concern that there will not be another driver assigned. second we can see that in the rush hours people 
tend to wait more for driver to be assigned then at not rush hours.
*/

 select DATEPART(hour , order_datetime) as hour, is_driver_assigned_key , avg(cancellations_time_in_seconds) as AverageTime
 from Orders
 group by DATEPART(hour , order_datetime), is_driver_assigned_key
 order by 1,3 desc

 
 /*
 Question 4 - Results by Plot (In tableau): we can see right away that during morning rush hours in 7:00-9:00
 the average waiting time for driver after being assigned is very long compared to the rest of the day, and during 
 the night the average waiting time is not long, which coinside with our explanation in question 2.
 */

 select DATEPART(hour , order_datetime) as hour , avg(m_order_eta) as AverageTime
 from Orders
 group by DATEPART(hour , order_datetime) 
 order by 1
 