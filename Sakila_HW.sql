USE sakila;

-- show first name and last name of all actors in DB
SELECT first_name, last_name FROM actor;

-- create a fullname column
ALTER TABLE actor ADD COLUMN full_name VARCHAR (50);
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET full_name = CONCAT(first_name, ' ',last_name);
SET SQL_SAFE_UPDATES = 1;

-- information of actors with name "JOE"
SELECT * FROM actor WHERE first_name = "JOE";

-- Actors whose last name contains "GEN"
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- all actors whose last names contain the letters "LI"
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

-- country_id and country columns Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh','China');

-- create description column of type BLOB (based on what I have read it would be TEXT, not BLOB, though)
ALTER TABLE actor ADD COLUMN description BLOB;

-- jk.. delete description column
ALTER TABLE actor DROP COLUMN description;

-- list actor last names and last name counts
SELECT last_name, COUNT(actor_id)
FROM ACTOR
GROUP BY last_name;

--  List last names of actors and the number of actors who have that last name ( but only for names that are shared by at least two actors)
SELECT last_name, COUNT(actor_id) ct
FROM ACTOR
GROUP BY last_name
HAVING ct > 1;

-- change "GROUCHO WILLIAMS" to " HARPO WILLIAMS"
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET 
	first_name = 'HARPO', 
    full_name = 'HARPO WILLIAMS'
WHERE full_name = 'GROUCHO WILLIAMS';
SET SQL_SAFE_UPDATES = 1;

-- undo the last alteration
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET 
	first_name = 'GROUCHO', 
    full_name = 'GROUCHO WILLIMS'
WHERE full_name = 'HARPO WILLIAMS';
SET SQL_SAFE_UPDATES = 1;

-- 5A.-- Hypothetically re-create address table schema

SHOW CREATE TABLE address;

 CREATE TABLE address (
  address_id smallint(5) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  address varchar(50) NOT NULL,
  address2 varchar(50),
  district varchar(20) NOT NULL,
  city_id smallint(5) UNSIGNED NOT NULL,
  postal_code varchar(20),
  phone VARCHAR(20) NOT NULL,
  location GEOMETRY NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address
ON address.address_id = staff.address_id;

-- display the total amount rung up by each staff member in August of 2005
SELECT staff.first_name, staff.last_name,SUM(payment.amount)
FROM payment
INNER JOIN staff
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE "2005-06%"
GROUP BY payment.staff_id;


SELECT film.title, COUNT(film_actor.actor_id)
FROM film
LEFT JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- copies of the film Hunchback Impossible in the inventory system
 SELECT COUNT(inventory_id)
 FROM inventory 
 WHERE film_id IN (
	SELECT film_id
    FROM film
    WHERE title = "Hunchback Impossible");
 
-- list the total paid by each customer. List the customers alphabetically by last name. 
SELECT c.first_name, c.last_name, SUM(p.amount) AS "Total Amount Paid"
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- Ks and Qs in English
SELECT title 
FROM film 
WHERE language_id IN (
	SELECT language_id 
    FROM language
    WHERE name = "English")
AND (title LIKE "K%" OR title LIKE "Q%");

-- list all actors appearing in film "ALONE TRIP"
SELECT full_name
FROM actor
WHERE actor_id IN(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN(
		SELECT film_id
        FROM film
        WHERE title= "ALONE TRIP"
	)
);

-- names and addresses of all Canadian customers

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
INNER JOIN address
ON customer.address_id =address.address_id
INNER JOIN city ON address.city_id = city.city_id
RIGHT JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";

-- list all "Family" films

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
    FROM film_category
    WHERE category_id  IN (
		SELECT category_id
		FROM category 
		WHERE category.name = "family"
	)
);

-- most frequently rented movies, descending order

Select rental_rate from film ;

SELECT film.title, COUNT(rental.inventory_id) AS rental_freq
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY rental_freq DESC;

-- business in dollars brought in per store
SELECT store.store_id, SUM(payment.amount)
FROM payment
JOIN staff ON payment.staff_id = staff.staff_id
JOIN store ON staff.store_id = store.store_id
GROUP BY store.store_id;

-- store ids, city, and country
SELECT store.store_id, city.city, country.country
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

-- top five genres by gross revenue (desc)
CREATE VIEW top_5_genres_by_rev AS
	SELECT cat.name, SUM(payment.amount) AS gross_revenue
	FROM payment
	JOIN rental ON payment.rental_id = rental.rental_id
	JOIN inventory inv ON inv.inventory_id =rental.inventory_id
	JOIN film_category  AS f_cat ON inv.film_id = f_cat.film_id
	JOIN category  AS cat ON cat.category_id = f_cat.category_id
	GROUP BY cat.category_id
	ORDER BY gross_revenue DESC
	LIMIT 5;

-- 8b.
SELECT * FROM top_5_genres_by_rev;

-- delete "top_5_genres_by_rev" View
DROP VIEW top_5_genres_by_rev;


