select * from customer;
select * from bike;
select * from rental;
select * from membership_type;
select * from membership;

---1)Emily gostaria de saber quantas bicicletas a loja possui por categoria. Você pode mostrar isso a ela? Exiba o nome da categoria e o número de bicicletas que a loja possui cada categoria (chame esta coluna de number_of_bikes ). Mostrar apenas as categorias onde o número de bicicletas é maior que 2.
--1)Emily would like to know how many bikes the shop owns by category. Can you get this for her? Display the category name and the number of bikes the shop owns in each category (call this column number_of_bikes ). Show only the categories where the number of bikes is greater than 2 .
SELECT category, COUNT (id) AS number_of_bikes
FROM bike
GROUP BY category
HAVING COUNT (id) >2
ORDER BY category;


--2)Emily precisa de uma lista de nomes de clientes com o número total de assinaturas adquiridas por cada um. Para cada cliente, exiba o nome do cliente e a contagem de assinaturas compradas (chame esta coluna de member_count ). Classifique o resultados por member_count , começando com o cliente que comprou o maior número de associados. Lembre-se de que alguns clientes podem não ter comprado nenhum adesões ainda. Em tal situação, exiba 0 para subscription_count 
--2)Emily needs a list of customer names with the total number of memberships purchased by each. For each customer, display the customer's name and the count of memberships purchased (call this column membership_count ). Sort the results by membership_count , starting with the customer who has purchased the highest number of memberships. Keep in mind that some customers may not have purchased any memberships yet. In such a situation, display 0 for the membership_count .
SELECT customer.name, 
COALESCE (COUNT(membership.id),0) AS member_count
FROM customer
JOIN membership
ON customer.id = membership.customer_id
GROUP BY customer.name
ORDER BY member_count DESC;


--3)Emily está trabalhando em uma oferta especial para os meses de inverno. Você pode ajudá-la preparar uma lista de novos preços de aluguel? Para cada bicicleta, exiba seu ID, categoria, preço antigo por hora (chame esta coluna old_price_per_hour ), preço com desconto por hora (chame-o de new_price_per_hour ), antigo preço por dia (chame-o de old_price_per_day ) e preço com desconto por dia (chame-o new_price_per_day).
--3)Emily is working on a special offer for the winter months. Can you help her prepare a list of new rental prices? For each bike, display its ID, category, old price per hour (call this column old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old price per day (call it old_price_per_day ), and discounted price per day (call it new_price_per_day ). Electric bikes should have a 10% discount for hourly rentals and a 20% cdiscount for daily rentals. Mountain bikes should have a 20% discount for hourly rentals and a 50% discount for daily rentals. All other bikes should have a 50% discount for all types of rentals. Round the new prices to 2 decimal digits.
SELECT bike.id, bike.category, bike.price_per_hour AS  old_price_per_hour, bike.price_per_day AS old_price_per_day,
ROUND(
CASE 
WHEN bike.category = 'eletric' THEN bike.price_per_hour *0.90
WHEN bike.category = 'mountain bike' THEN  bike.price_per_hour *0.80
ELSE bike.price_per_hour *0.50
END, 2) AS new_price_per_hour,
ROUND(
CASE 
WHEN bike.category = 'eletric' THEN bike.price_per_day *0.80
WHEN bike.category = 'mountain bike' THEN bike.price_per_day *0.50
ELSE bike.price_per_day *0.50
END, 2) AS new_price_per_day
FROM bike
ORDER BY bike.id, bike.category;


--4)Emily está procurando contagens de bicicletas alugadas e de bicicletas disponíveis em cada categoria. Exibe o número de bicicletas disponíveis (chame esta coluna available_bikes_count ) e o número de bicicletas alugadas (chame esta coluna rented_bikes_count ) por categoria de bicicleta
--4)Emily is looking for counts of the rented bikes and of the available bikes in each category. Display the number of available bikes (call this column available_bikes_count ) and the number of rented bikes (call this column rented_bikes_count ) by bike category.
SELECT category,
COUNT (CASE WHEN status = 'available' THEN 1 END) AS available_bikes_count,
COUNT (CASE WHEN status = 'rented' THEN 1 END) AS rented_bikes_count
FROM bike
GROUP BY category;

--5)Emily está preparando um relatório de vendas. Ela precisa saber a receita total de aluguéis por mês, o total por ano e o tempo todo em todos os anos.Exiba a receita total de aluguéis de cada mês, o total de cada ano e o total de todos os anos. Não leve associações em conta. Deve haver 3 colunas: ano, mês e receita. Classifique os resultados cronologicamente. Exibir o total do ano depois de todo o mês totais do ano correspondente. Mostre o total histórico como a última linha.
--5)Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across all the years.Display the total revenue from rentals for each month, the total for each year, and the total across all the years. Do not take memberships into account. There should be 3 columns: year , month , and revenue . Sort the results chronologically. Display the year total after all the month totals for the corresponding year. Show the all-time total as the last row.
SELECT
EXTRACT (YEAR FROM start_timestamp) AS YEAR,
EXTRACT (MONTH FROM start_timestamp) AS MONTH,
SUM (total_paid) AS REVENUE
FROM rental
GROUP BY ROLLUP(YEAR, MONTH)
ORDER BY YEAR, MONTH;


--6). Emily pediu que você obtivesse a receita total das assinaturas de cada combinação de ano, mês e tipo de associação. Exiba o ano, o mês, o nome do tipo de associação (chame isso coluna member_type_name ) e a receita total (chame esta coluna total_revenue ) para cada combinação de ano, mês e tipo de associação. Classifique os resultados por ano, mês e nome do tipo de associação.
--6)Emily has asked you to get the total revenue from memberships for each combination of year, month, and membership type. Display the year, the month, the name of the membership type (call this column membership_type_name ), and the total revenue (call this column total_revenue ) for every combination of year, month, and membership type. Sort the results by year, month, and name of membership type.
SELECT 
EXTRACT (YEAR FROM start_date) AS YEAR,
EXTRACT (MONTH FROM start_date) AS MONTH,
membership_type.name AS member_type_name,
SUM (membership) AS total_revenue
FROM membership
JOIN membership_type
ON membership.membership_type_id = membership_type.id
GROUP BY YEAR, MONTH, member_type_name
ORDER BY YEAR, MONTH, member_type_name;


--7)Em seguida, Emily gostaria de dados sobre assinaturas adquiridas em 2023, com subtotais e totais gerais para todas as diferentes combinações de membros tipos e meses. Exiba a receita total de assinaturas adquiridas em 2023 para cada combinação de mês e tipo de associação. Gere subtotais e totais gerais para todas as combinações possíveis. Deve haver 3 colunas: member_type_name , mês e total_revenue . Classifique os resultados por nome do tipo de associação em ordem alfabética e depois cronologicamente por mês.
--7)Next, Emily would like data about memberships purchased in 2023, with subtotals and grand totals for all the different combinations of membership types and months. Display the total revenue from memberships purchased in 2023 for each combination of month and membership type. Generate subtotals and grand totals for all possible combinations. There should be 3 columns: membership_type_name , month , and total_revenue . Sort the results by membership type name alphabetically and then chronologically by month.
SELECT   
membership_type.name AS membership_type_name,
EXTRACT (MONTH FROM membership.start_date) AS MONTH,
SUM (membership.total_paid) AS total_revenue
FROM membership
JOIN membership_type
ON membership.membership_type_id = membership_type.id
WHERE EXTRACT(YEAR FROM membership.start_date) = 2023
GROUP BY membership_type.name, MONTH
ORDER BY membership_type.name ASC, MONTH ASC;


--8)Emily deseja segmentar os clientes com base no número de aluguéis e veja a contagem de clientes em cada segmento. Use suas habilidades em SQL para obter esse! Categorize os clientes com base em seu histórico de locação da seguinte forma: Os clientes que tiveram mais de 10 aluguéis são categorizados como 'mais do que 10'. Os clientes que tiveram de 5 a 10 aluguéis (inclusive) são categorizados como 'entre 5 e 10' . Os clientes que tiveram menos de 5 aluguéis devem ser categorizados como 'menos de 5'. Calcule o número de clientes em cada categoria. Exibir duas colunas: rental_count_category (a categoria de contagem de aluguel) e customer_count (a número de clientes em cada categoria).
--8)Now it's time for the final task. Emily wants to segment customers based on the number of rentals and see the count of customers in each segment. Use your SQL skills to get this! Categorize customers based on their rental history as follows: Customers who have had more than 10 rentals are categorized as 'more than 10' . Customers who have had 5 to 10 rentals (inclusive) are categorized as 'between 5 and 10' . Customers who have had fewer than 5 rentals should be categorized as 'fewer than 5' . Calculate the number of customers in each category. Display two columns: rental_count_category (the rental count category) and customer_count (the number of customers in each category).
SELECT CASE
WHEN COUNT (customer_id) > 10 THEN 'more than 10'
WHEN COUNT(customer_id) BETWEEN 5 AND 10 THEN 'between 5 and 1'
ELSE 'fewer than 5'
END AS rental_count_category,
COUNT(*) AS customer_count
FROM rental
GROUP BY customer_id
ORDER BY rental_count_category;


