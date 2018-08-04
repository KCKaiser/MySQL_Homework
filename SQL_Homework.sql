USE sakila
# SET SQL_SAFE_UPDATES = 0;

### 1 ###
## a. You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 
SELECT first_name AS 'First Name', last_name AS 'Last Name' FROM actor;

## b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

### 2 ###
## a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

## b. Find all actors whose last name contain the letters `GEN`
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

## c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

## d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

### 3 ###
## a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
# Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50) AFTER first_name;

SELECT * FROM actor;

## b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY middle_name BLOB;

DESCRIBE actor;

## c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT * FROM actor; 

### 4 ###
## a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name;

## b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1;

## c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

SELECT * FROM actor
WHERE last_name = 'WILLIAMS';

# Actor ID is 172 #

## d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = IF(first_name = 'HARPO', 'GROUCHO', 'MUCHO GROUCHO')
WHERE actor_id = 172;

SELECT * FROM actor
WHERE last_name = 'WILLIAMS';

### 5 ###
## a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE `address2`(
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  SPATIAL KEY `idx_location` (`location`),
CONSTRAINT `fk_address_city2` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

SELECT * FROM address2;

DROP TABLE address2;

### 6 ###

## a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.address_id, first_name, last_name, address
FROM staff s
INNER JOIN address a ON s.address_id = a.address_id;

## b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT staff.staff_id, first_name, last_name, sum(amount)
FROM staff 
INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE MONTH(payment_date) = 8 AND YEAR(payment_date) = 2005
GROUP BY staff_id;

## c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT fa.film_id, title, count(actor_id) AS 'Number of Actors'
FROM film_actor fa
INNER JOIN film f ON fa.film_id = f.film_id
GROUP BY title;

## d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

# How I would do it
SELECT film.film_id, title, count(inventory.film_id) AS 'Number of Copies'
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY title;

# How subqueries can do the same thing but more confusingly
SELECT film.film_id, title, (SELECT count(inventory.film_id) FROM inventory WHERE inventory.film_id = film.film_id) AS 'Number of Copies'
FROM film
WHERE title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY title;

# There are six copies #

## e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT payment.customer_id, last_name, first_name, sum(amount)
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY last_name;

## 7 ##
## a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title AS 'Movies Starting w/ "K" and "Q"'
FROM film 
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id IN (SELECT language_id FROM language WHERE name = 'English');

## b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN 
						(SELECT film_id FROM film WHERE title = 'Alone Trip'));

## c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer
INNER JOIN customer_list ON customer.customer_id = customer_list.ID
WHERE country = 'Canada';
#####################################

SELECT first_name, last_name, email
FROM customer
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country = 'Canada';

#####################################

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (SELECT address_id FROM address WHERE city_id IN
						(SELECT city_id FROM city WHERE country_id IN
                        (SELECT country_id FROM country WHERE country = 'Canada')));


## d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title AS 'Family Films'
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE name = 'Family';

## e. Display the most frequently rented movies in descending order.

SELECT film.title, count(inventory.film_id)
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.inventory_id = film.film_id
GROUP BY rental.inventory_id
ORDER BY count(inventory.film_id) desc;

## f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM sales_by_store;
SELECT * FROM staff

SELECT c.city, cy.country, concat(first_name, " ", last_name) AS 'manager', sum(p.amount) AS total_sales
FROM payment p 
JOIN rental r ON p.rental_id = r.rental_id 
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id 
JOIN country cy ON c.country_id = cy.country_id
JOIN staff m ON s.manager_staff_id = m.staff_id
GROUP BY s.store_id order by cy.country, c.city;


## g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city, country
FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id

## h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
# category, film_category, inventory, payment, and rental.

SELECT category.name AS category, sum(payment.amount) AS 'Gross Revenue'
FROM payment
INNER JOIN rental ON payment.rental_id = rental.rental_id
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category ON inventory.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY sum(payment.amount) desc LIMIT 5;

### 8 ###
## a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_5_Category_View AS 
	SELECT category.name AS category, sum(payment.amount) AS 'Gross Revenue'
	FROM payment
	INNER JOIN rental ON payment.rental_id = rental.rental_id
	INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film_category ON inventory.film_id = film_category.film_id
	INNER JOIN category ON film_category.category_id = category.category_id
	GROUP BY category.name
	ORDER BY sum(payment.amount) desc LIMIT 5;

## b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Category_View;

## c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_5_Category_View;
