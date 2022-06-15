--------------------------------------
-- Introduction With The Data 
--------------------------------------
USE projects
GO 

SELECT COUNT (*)
FROM card_transdata
--There are 1,000,000 rows--
--There are 8 coulmns --

--Witch precent is detection as fraud? 
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM card_transdata))*100,'##.##') AS fraud_PRC
FROM card_transdata
GROUP BY fraud


fraud	fraud_PRC
0	91.26
1	8.74

--Witch precent is detection as fraud, by eatch character? 
SELECT fraud,
	  SUM(CAST(repeat_retailer AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100  AS repeat_retailer_prc ,
      SUM(CAST (used_chip  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_chip_prc ,
	  SUM(CAST (used_pin_number  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_pin_number_prc,
      SUM(CAST (online_order  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS online_order_prc
FROM card_transdata
GROUP BY fraud

fraud	repeat_retailer_prc	used_chip_prc	used_pin_number_prc	online_order_prc
0		88.167100			35.940100		10.994400			62.222500
1		88.011800			25.639800		0.312300			94.631700



SELECT fraud,
		 AVG(distance_from_home) AS AVG_distance_from_home,
		 AVG(distance_from_last_transaction) AS AVG_distance_from_last_transaction,
		 AVG(ratio_to_median_purchase_price) AS AVG_ratio_to_median_purchase_price
FROM card_transdata
GROUP BY fraud  

--- חציון לנ"ל הנתונים? כדי לראות עד כמה זה משפיע-וכמה חריגים יש שהם ללא הונאה ומה האינדיקציה הנכונה (מעל איזה מרחק להגיד לא כדאי)  אולי בפייתון


----שילוב של נתונים

SELECT fraud,
	  SUM(CAST(repeat_retailer AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100  AS repeat_retailer_prc ,
      SUM(CAST (used_chip  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_chip_prc ,
	  SUM(CAST (used_pin_number  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_pin_number_prc,
      SUM(CAST (online_order  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS online_order_prc,
		 AVG(distance_from_home) AS AVG_distance_from_home,
		 AVG(distance_from_last_transaction) AS AVG_distance_from_last_transaction,
		 AVG(ratio_to_median_purchase_price) AS AVG_ratio_to_median_purchase_price
FROM card_transdata
GROUP BY fraud 

fraud	repeat_retailer_prc	used_chip_prc	used_pin_number_prc	online_order_prc	AVG_distance_from_home	AVG_distance_from_last_transaction	AVG_ratio_to_median_purchase_price
0		88.167100			35.940100		10.994400			 62.222500			22.8329760188753		4.30139073534758					1.42364185544171
1		88.011800			25.639800		0.312300		   	 94.631700			66.261876335896			12.7121851262411					6.00632349101669

--  -בחירת נתונים שונים ובדיקה עד כמה משתנה אחוז ההונאה? תוך התמקדות בזמנות באינטרנט (שם יש 94%) .ג ---
--Combination_1: online_order = 1   &    used_pin_number=0	&	used_chip = 0
--Combination_2: online_order = 1   &    used_pin_number=0	&	distance_from_home >=42
--Combination_3: online_order = 1   &    used_pin_number=0	&	distance_from_last_transaction >=8
--Combination_4: online_order = 1   &    used_pin_number=0	&	ratio_to_median_purchase_price >=4
--Combination_5: online_order = 1   &    used_pin_number=0
--Combination_6: online_order = 1   &    used_pin_number=0
--בדיקה של הונאות של הזמנות שלא נעשות באינטרנט
--Combination_7: online_order_prc = 0  &    used_pin_number_prc =0



;WITH Combination_1 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND	used_chip = 0)
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM Combination_1))*100,'##.##') AS fraud_PRC
FROM Combination_1
GROUP BY fraud

--fraud = 16%
------------------------------------------------------------
;WITH Combination_2 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND distance_from_home >=42)
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM Combination_2))*100,'##.##') AS fraud_PRC
FROM Combination_2
GROUP BY fraud
--fraud = 30%

--------------------------------------------------------------
;WITH Combination_3 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND distance_from_last_transaction >=8)
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM Combination_3))*100,'##.##') AS fraud_PRC
FROM Combination_3
GROUP BY fraud
--fraud = 20%

--------------------------------------------------------------
;WITH Combination_4 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1  AND   used_pin_number =0 	AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM Combination_4))*100,'##.##') AS fraud_PRC
FROM Combination_4
GROUP BY fraud
--fraud = 100%