--Individual queries for given questions

-- Display the total number of customers based on gender who have placed individual orders of worth at least Rs.3000

SELECT c.CUS_GENDER, COUNT(DISTINCT c.CUS_ID) AS NumberOfCustomers
FROM customer c
JOIN orders o ON c.CUS_ID = o.CUS_ID
WHERE o.ORD_AMOUNT >= 3000
GROUP BY c.CUS_GENDER;

--Display all the orders along with product name ordered by a customer having Customer_Id=2
SELECT o.ORD_ID, o.ORD_AMOUNT, o.ORD_DATE, p.PRO_NAME
FROM orders o
JOIN supplier_pricing sp ON o.PRICING_ID = sp.PRICING_ID
JOIN product p ON sp.PRO_ID = p.PRO_ID
WHERE o.CUS_ID = 2;

--Display the Supplier details who can supply more than one product.
SELECT s.SUPP_ID, s.SUPP_NAME, s.SUPP_CITY, s.SUPP_PHONE
FROM supplier s
JOIN supplier_pricing sp ON s.SUPP_ID = sp.SUPP_ID
GROUP BY s.SUPP_ID, s.SUPP_NAME, s.SUPP_CITY, s.SUPP_PHONE
HAVING COUNT(DISTINCT sp.PRO_ID) > 1;

--Find the least expensive product from each category and print the table with category id, name, product name and price of the product
SELECT c.CAT_ID, c.CAT_NAME, p.PRO_NAME, sp.SUPP_PRICE
FROM category c
JOIN product p ON c.CAT_ID = p.CAT_ID
JOIN supplier_pricing sp ON p.PRO_ID = sp.PRO_ID
WHERE (c.CAT_ID, sp.SUPP_PRICE) IN (
    SELECT p.CAT_ID, MIN(sp2.SUPP_PRICE)
    FROM product p
    JOIN supplier_pricing sp2 ON p.PRO_ID = sp2.PRO_ID
    GROUP BY p.CAT_ID
);

--Display the Id and Name of the Product ordered after “2021-10-05”.
SELECT DISTINCT p.PRO_ID, p.PRO_NAME
FROM orders o
JOIN supplier_pricing sp ON o.PRICING_ID = sp.PRICING_ID
JOIN product p ON sp.PRO_ID = p.PRO_ID
WHERE o.ORD_DATE > '2021-10-05';

--Display customer name and gender whose names start or end with character 'A'.
SELECT CUS_NAME, CUS_GENDER
FROM customer
WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

/*Create a stored procedure to display supplier id, name, Rating(Average rating of all the products sold by every customer) and
Type_of_Service. For Type_of_Service, If rating =5, print “Excellent Service”,If rating >4 print “Good Service”, If rating >2 print “Average
Service” else print “Poor Service”. Note that there should be one rating per supplier.*/
DELIMITER //

CREATE PROCEDURE GetSupplierRatings()
BEGIN
    SELECT 
        s.SUPP_ID, 
        s.SUPP_NAME, 
        AVG(r.RAT_RATSTARS) AS AverageRating,
        CASE 
            WHEN AVG(r.RAT_RATSTARS) = 5 THEN 'Excellent Service'
            WHEN AVG(r.RAT_RATSTARS) > 4 THEN 'Good Service'
            WHEN AVG(r.RAT_RATSTARS) > 2 THEN 'Average Service'
            ELSE 'Poor Service'
        END AS Type_of_Service
    FROM supplier s
    JOIN supplier_pricing sp ON s.SUPP_ID = sp.SUPP_ID
    JOIN orders o ON sp.PRICING_ID = o.PRICING_ID
    JOIN rating r ON o.ORD_ID = r.ORD_ID
    GROUP BY s.SUPP_ID, s.SUPP_NAME;
END //

DELIMITER ;

CALL GetSupplierRatings();


