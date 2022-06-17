--------------------------------------
-- Introduction With The Data 
--------------------------------------
USE projects
GO 

SELECT TOP 5 *
FROM card_transdata

SELECT COUNT (*)
FROM card_transdata

--There are 1,000,000 rows--
--There are 8 columns --

--5 columns with Boolean variable:

--And 3 columns with a continuous variable:

------------------------------------------
--The purpose of the analysis is to see what variables can be an indication
--of whether the transaction constitutes a fraudulent transaction?
------------------------------------------

--What percentage is fraud from the database?
--WITH SUB QUERIES--
SELECT fraud, FORMAT((CAST(COUNT(fraud) AS NUMERIC)/
				(SELECT COUNT (*) FROM card_transdata))*100,'##.##') AS fraud_PCT
FROM card_transdata
GROUP BY fraud
--WITH WINDOW FUNCTION QUERIES--
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_PRC
FROM card_transdata
GROUP BY fraud

fraud	fraud_PCT
0	91.26
1	8.74

--The relationship of each figure individually (in percent) to the question of whether a fraud was committed or not?? 
SELECT fraud,
	  SUM(CAST(repeat_retailer AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100  AS repeat_retailer_pct ,
      SUM(CAST (used_chip  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_chip_pct ,
	  SUM(CAST (used_pin_number  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_pin_number_pct,
      SUM(CAST (online_order  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS online_order_pct
FROM card_transdata
GROUP BY fraud

fraud	repeat_retailer_pct	used_chip_pct	used_pin_number_pct	online_order_pct
0		88.167100			35.940100		10.994400			62.222500
1		88.011800			25.639800		0.312300			94.631700


--The average data, divided by fraud category
SELECT fraud,
		 AVG(distance_from_home) AS AVG_distance_from_home,
		 AVG(distance_from_last_transaction) AS AVG_distance_from_last_transaction,
		 AVG(ratio_to_median_purchase_price) AS AVG_ratio_to_median_purchase_price
FROM card_transdata
GROUP BY fraud  


----View the results of the previous two queries together.

SELECT fraud,
	  SUM(CAST(repeat_retailer AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100  AS repeat_retailer_pct ,
      SUM(CAST (used_chip  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_chip_pct ,
	  SUM(CAST (used_pin_number  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS used_pin_number_pct,
      SUM(CAST (online_order  AS NUMERIC))/COUNT(CAST(fraud AS NUMERIC)) *100 AS online_order_pct,
		 AVG(distance_from_home) AS AVG_distance_from_home,
		 AVG(distance_from_last_transaction) AS AVG_distance_from_last_transaction,
		 AVG(ratio_to_median_purchase_price) AS AVG_ratio_to_median_purchase_price
FROM card_transdata
GROUP BY fraud 

fraud	repeat_retailer_pct	used_chip_pct	used_pin_number_pct	online_order_pct	AVG_distance_from_home	AVG_distance_from_last_transaction	AVG_ratio_to_median_purchase_price
0		88.167100			35.940100		10.994400			 62.222500			22.8329760188753		4.30139073534758					1.42364185544171
1		88.011800			25.639800		0.312300		   	 94.631700			66.261876335896			12.7121851262411					6.00632349101669

--According to the results, it seems that the figure that has the most impact is:online_order (94% Vs 62%) 
--And repeat_retailer has almost no effect.
--Because of this, I will create different combinations based on the above results.

--Combination_1: online_order = 1   &    used_pin_number=0	&	used_chip = 0
--Combination_2: online_order = 1   &    used_pin_number=0	&	distance_from_home >=42
--Combination_3: online_order = 1   &    used_pin_number=0	&	distance_from_last_transaction >=8
--Combination_4: online_order = 1   &    used_pin_number=0	&	ratio_to_median_purchase_price >=4
--Combination_5: online_order = 1   &    ratio_to_median_purchase_price >=4 & distance_from_last_transaction >=8
--Combination_6: online_order = 1   &    ratio_to_median_purchase_price >=4 & distance_from_home >=42

-----Investigation of scams of orders not made online-------
--Combination_7: online_order_prc = 0  &   ALL ABOVE


;WITH Combination_1 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND	used_chip = 0)
SELECT fraud,FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_ct 
FROM Combination_1
GROUP BY fraud

--fraud = 16%
------------------------------------------------------------
;WITH Combination_2 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND distance_from_home >=42)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_2
GROUP BY fraud
--fraud = 30%

--------------------------------------------------------------
;WITH Combination_3 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1   AND   used_pin_number =0	AND distance_from_last_transaction >=8)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_3
GROUP BY fraud
--fraud = 20%

--------------------------------------------------------------
;WITH Combination_4 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1  AND   used_pin_number =0 	AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_4
GROUP BY fraud
--fraud = 100%
--------------------------------------------------------------
--I wanted to test whether there is a significant impact to the figure:used_pin_number
--------------------------------------------------------------
;WITH Combination_4_A AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1 	AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_4_A
GROUP BY fraud
--fraud = 90%
--------------------------------------------------------------
;WITH Combination_5 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1  AND   distance_from_last_transaction >=8
		AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_5
GROUP BY fraud
--fraud = 90.49%

--I wanted to test whether there is a significant impact to the figure: distance_from_last_transaction
--------------------------------------------------------------
;WITH Combination_5_A AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1 -- AND   distance_from_last_transaction >=8
		AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_5_A
GROUP BY fraud
--fraud = 90.3%
--------------------------------------------------------------
;WITH Combination_6 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 1  AND   distance_from_last_transaction >=8	AND distance_from_home >=42)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_6
GROUP BY fraud
--fraud = 31%

--------------------------------------------------------------
;WITH Combination_7 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 0
		AND used_chip = 0 
		AND used_pin_number =0
		AND distance_from_home >=42
		AND distance_from_last_transaction >=8
		AND ratio_to_median_purchase_price >=4)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_7
GROUP BY fraud
--fraud = 39%

--Because the figure is very low, I changed the metrics to check which data would give me a high impact:
-- distance_from_home >=52
-- ratio_to_median_purchase_price >=5)
--------------------------------------------------------------
;WITH Combination_8 AS (
		SELECT fraud
		FROM card_transdata
		WHERE online_order = 0
		AND used_chip = 0 
		AND used_pin_number =0
		AND distance_from_home >=52
		AND distance_from_last_transaction >=12
	 	AND ratio_to_median_purchase_price >=5)
SELECT fraud, FORMAT(
				CAST(COUNT(*) AS NUMERIC)/ (SUM(COUNT (*))  OVER () )*100
				,'##.##') AS fraud_Pct
FROM Combination_8
GROUP BY fraud


--I did not find a data composition that would give me a high probability
--of fraud in case of non-online purchase

---------------------------------------------
--What data would I like to see in addition?
---------------------------------------------
--Customer Address: To check if there is a match in the shipping address to the customer address?
--Type of purchase: There may be some pattern of purchases (fashion / electronic device / games, etc.) that are mostly scams
--