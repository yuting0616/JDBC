--The book table holds data on each book that Libro offers for sale.

DROP TABLE book         CASCADE;
DROP TABLE customer     CASCADE;
DROP TABLE bookOrder	CASCADE;

DROP SCHEMA Libro_Database CASCADE;

----------------------------------------------------------------------------------------------------------------------
CREATE SCHEMA Libro_Database;
SET search_path to Libro_Database;
SET datestyle='ISO';

CREATE TABLE book (
--bno is a Libro's six-digit book number used by them to identify a book offered for sale
    bno      	INTEGER		PRIMARY KEY,
--title is the title of the book.
    title    	VARCHAR(20),
--author is the author(s) of the book.
    author   	VARCHAR(20),
--category is one of Science, Lifestyle, Arts or Leisure.
    category 	CHAR(10),
--price is the selling price of the book.
    price    	DECIMAL(6,2),
--sales is a count of the number of copies of the book which have been sold. This is zero when a
--new book is inserted into the database.
    sales    	INTEGER		DEFAULT 0,

    CONSTRAINT chk_bno CHECK (bno >= 100000 AND bno <= 999999),
    CONSTRAINT chk_category CHECK (category IN ('Science', 'Lifestyle', 'Arts', 'Leisure'))
);


--The customer table holds details of all Libro customers.
CREATE TABLE customer (
--cno is a six-digit number used to identify a customer.
    cno      	INTEGER		PRIMARY KEY,
--name is the name of the customer.
    name     	VARCHAR(20),
--address is the address of the customer.
    address  	VARCHAR(30),
--balance is the amount of money owed to Libro by the customer for books ordered. This is
--always zero when a new customer is inserted into the database.
    balance  	DECIMAL(8,2)	DEFAULT 0,

    CONSTRAINT chk_cno CHECK (cno >= 100000 AND cno <= 999999)
);


--The bookOrder table holds details of current orders placed by Libro customers. The order
--details are archived periodically and the bookOrder table is then emptied. Each order is for a
--single customer and for a single title but may be for multiple copies of the title.
CREATE TABLE bookOrder (

    cno      	INTEGER,

    bno      	INTEGER,
--qty is the number of copies of a specific book ordered by a customer.
    qty      	INTEGER,
--orderTime is a timestamp recording the instant in time when an order was put on the Libro
--database.
    orderTime 	TIMESTAMP 	DEFAULT	CURRENT_TIMESTAMP,

	CONSTRAINT bookOrder_pk  PRIMARY KEY (cno, bno, orderTime),
	CONSTRAINT bookOrder_fk1 FOREIGN KEY (cno) REFERENCES customer(cno),
	CONSTRAINT bookOrder_fk2 FOREIGN KEY (bno)  REFERENCES book(bno)

);

--Triger--
CREATE OR REPLACE FUNCTION update_book_customer()
RETURNS trigger AS $BODY$
BEGIN
	UPDATE book SET sales = sales + new.qty WHERE bno = new.bno;
    UPDATE customer SET balance = balance + (SELECT price FROM book WHERE bno = new.bno) * new.qty  WHERE cno = new.cno;
RETURN NEW;
END; $BODY$ LANGUAGE plpgsql;


CREATE TRIGGER insert_bookOrder
AFTER INSERT ON bookOrder
FOR EACH ROW
execute procedure update_book_customer();

--这个是真实要用的数据--

delete from bookOrder;
delete from book;
delete from customer;

INSERT INTO book values (100001,'Lord of the Rings', 'JRR Tolkien','Leisure',14.99,0);
INSERT INTO book values (100002,'Pride and Prejudice', 'Jane Austen','Leisure',12.99,0);
INSERT INTO book values (100003,'His Dark Materials','Philip Pullman','Leisure',10.99,0);
INSERT INTO book values (100004,'Dark Prejudice','JK Rowling','Leisure',7.99,0);
INSERT INTO book values (100005,'Kill a Mockingbird','Harper Lee','Leisure',10.99,0);
INSERT INTO book values (100006,'Advanced Biology','Phillip E. Pack', 'Science',35,0);
INSERT INTO book values (100007,'Guide to Everything','John R. Gribbin','Science',40,0);
INSERT INTO book values (100008,'Alpha and Omega','Charles Seife','Science',17.99,0);
INSERT INTO book values (100009,'Annals of the World','John A. McPhee','Science',15.99,0);
INSERT INTO book values (100010,'PURPLE HEARTS','Nina Berman','Arts',17.99,0);
INSERT INTO book values (100011,'DESIGN OF DISSENT', 'R Glaser', 'Arts',19.99,0);
INSERT INTO book values (100012,'CHANGING THE EARTH', 'Diana Bletter', 'Arts',22.00,0);
INSERT INTO book values (100013,'59 Seconds','Richard Wiseman','Lifestyle',14.99,0);
INSERT INTO book values (100014,'Talk to Anyone','Leil Lowndes','Lifestyle',12.99,0);

insert into customer (cno,name,address, balance)  values (100001,'Allan Brooke','1 The Medows,Norwich, Norfolk',0);
insert into customer (cno,name,address, balance)   values (100002,'Ralph Morston','12 Plain Drive,Lowestoft',0);
insert into customer (cno,name,address, balance)   values (100003,'Marion Jones','The Cottage, Dunston',0);
insert into customer (cno,name,address, balance)   values (100004,'James Olivier','5 Livinstone Square, Birmigham',0);
insert into customer (cno,name,address, balance)  values (100005,'Moira Stewart','7 The Medows, Manchester',0);
insert into customer(cno,name,address, balance)   values (100006,'Jonathan Bircham','20 Oxford Street, London',0);
insert into customer (cno,name,address, balance)  values (100007,'Paula Newman','25 Mill Hill, London',0);
insert into customer (cno,name,address, balance) values (100008,'David Jones','11 St Georges, London',0);
insert into customer (cno,name,address, balance)   values (100009,'Patricia Lewis','101 High Street, Glasgow',0);
insert into customer (cno,name,address, balance) values (100010,'Martha Bramley','12 Catton Grove, Norwich',0);

insert into bookOrder (cno, bno, orderTime, qty) values (100001,100007,current_timestamp,4);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100006,current_timestamp,3);
insert into bookOrder (cno, bno, orderTime, qty) values (100003,100007,current_timestamp,2);
insert into bookOrder (cno, bno, orderTime, qty) values (100008,100005,current_timestamp,2);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100007,'2019-03-04 13:00:03',4);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100003,'2019-04-04 13:00:03',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100010,100007,'2019-04-08 12:00:03',1);
insert into bookOrder (cno, bno, orderTime, qty) values (100004,100004,'2019-05-09 12:00:03',10);
insert into bookOrder (cno, bno, orderTime, qty) values (100007,100010,'2019-04-09 16:00:03',5);
insert into bookOrder (cno, bno, orderTime, qty) values (100007,100003,'2019-04-09 16:00:03',5);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100005,'2019-04-09 16:00:03',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100010,'2019-05-03 15:00:00',4);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100002,'2019-06-03 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100003,100002,'2019-08-03 11:00:00',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100002,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100008,100001,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100004,100012,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100013,'2019-08-05 11:00:00',1);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100001,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100008,'2019-08-05 11:00:00',2);


----------------------------------------------------------------------------------------------------------------------


--A. Insert a new book.
INSERT INTO book VALUES (100000,'Intro Java','Author-0','Science', '25.99');
INSERT INTO book VALUES (100001,'Advanced Java','Author-1','Lifestyle', '1');
INSERT INTO book VALUES (100002,'Intro JS','Author-2','Lifestyle', '2');
INSERT INTO book VALUES (100003,'Advanced JS','Author-3','Leisure', '3');
INSERT INTO book VALUES (100004,'Python','Author-4','Science', '4');

--B. Delete a book.
DELETE FROM book WHERE bno = 100004;

--C. Insert a customer.
INSERT INTO customer VALUES (900000, 'Customer-0', 'Adress-0');
INSERT INTO customer VALUES (900001, 'Customer-1', 'Adress-1');
INSERT INTO customer VALUES (900002, 'Customer-2', 'Adress-2');
INSERT INTO customer VALUES (900003, 'Customer-3', 'Adress-3');
INSERT INTO customer VALUES (900004, 'Customer-4', 'Adress-4');
--D. Delete a customer.
DELETE FROM customer WHERE cno = 900004;


--E. Place an order for a customer for a specified number of copies of a book. The copies
--ordered are assumed to be sold and will have to be paid for. Books are not supplied on 'sale
--or return' terms of business.
INSERT INTO bookOrder VALUES (900000, 100001, 10);
INSERT INTO bookOrder VALUES (900000, 100000, 1);
INSERT INTO bookOrder VALUES (900001, 100000, 1);
INSERT INTO bookOrder VALUES (900001, 100001, 1);
INSERT INTO bookOrder VALUES (900001, 100002, 1);

--F. Record a payment by a customer. The payment is subtracted from the customer's balance.
UPDATE customer SET balance = balance - 27.99 WHERE cno =900001;

--G. Find details of customers who have current orders for a book with a given text fragment in
--the book title. For example, find customers with orders for books with 'Java' in the title.
--This transaction produces a report with lines showing the full title of a book ordered, the
--customer name and the customer address relevant to the order. The report is to be sorted by
--title and then by customer name.
SELECT book.title, customer.name, customer.address FROM bookOrder
INNER JOIN book on bookOrder.bno = book.bno
INNER JOIN customer on bookOrder.cno = customer.cno
WHERE title LIKE '%Prejudice%'
ORDER BY title ASC, name ASC;


--H. Find details of books ordered by a specified customer. The report will show the name of
--the customer followed by, for each book, the book number, title and author, sorted by book
--number.
SELECT customer.name, book.bno, book.title, book.author FROM bookOrder
LEFT JOIN book on bookOrder.bno = book.bno
LEFT JOIN customer on bookOrder.cno = customer.cno
WHERE bookOrder.cno = 100006
ORDER BY bookOrder.bno;

--I. Produce a book report by category. This report shows, for each category, the number of
--books sold and the total value of these sales. The total value calculation assumes that the
--currently held price is used and any earlier changes in the price of a book since it was
--inserted into the database are ignored.
SELECT category, SUM(sales) AS num_of_books, sum(price * sales) AS total_sales_value FROM book
GROUP BY category;


--J. Produce a customer report. This report shows, for each customer, the customer number,
--customer name and a count of the number of copies of books on order (if any). This report is
--to be in customer number order.
SELECT customer.cno, customer.name, SUM(bookorder.qty) FROM customer
INNER JOIN bookOrder on customer.cno = bookOrder.cno
GROUP BY customer.cno
ORDER BY customer.cno;

--K. Daily sales. This transaction returns the total number of copies of books sold today.

SELECT SUM(bookOrder.qty) FROM bookOrder
WHERE DATE(bookOrder.orderTime) = (SELECT current_date);


--X. A transaction sent to close down the server application program.
DROP TABLE book         CASCADE;
DROP TABLE customer     CASCADE;
DROP TABLE bookOrder	CASCADE;
DROP SCHEMA Libro_Database CASCADE;

--这个是真实要用的数据--

delete from bookOrder;
delete from book;
delete from customer;

INSERT INTO book values (100001,'Lord of the Rings', 'JRR Tolkien','Leisure',14.99,0);
INSERT INTO book values (100002,'Pride and Prejudice', 'Jane Austen','Leisure',12.99,0);
INSERT INTO book values (100003,'His Dark Materials','Philip Pullman','Leisure',10.99,0);
INSERT INTO book values (100004,'Dark Prejudice','JK Rowling','Leisure',7.99,0);
INSERT INTO book values (100005,'Kill a Mockingbird','Harper Lee','Leisure',10.99,0);
INSERT INTO book values (100006,'Advanced Biology','Phillip E. Pack', 'Science',35,0);
INSERT INTO book values (100007,'Guide to Everything','John R. Gribbin','Science',40,0);
INSERT INTO book values (100008,'Alpha and Omega','Charles Seife','Science',17.99,0);
INSERT INTO book values (100009,'Annals of the World','John A. McPhee','Science',15.99,0);
INSERT INTO book values (100010,'PURPLE HEARTS','Nina Berman','Arts',17.99,0);
INSERT INTO book values (100011,'DESIGN OF DISSENT', 'R Glaser', 'Arts',19.99,0);
INSERT INTO book values (100012,'CHANGING THE EARTH', 'Diana Bletter', 'Arts',22.00,0);
INSERT INTO book values (100013,'59 Seconds','Richard Wiseman','Lifestyle',14.99,0);
INSERT INTO book values (100014,'Talk to Anyone','Leil Lowndes','Lifestyle',12.99,0);

insert into customer (cno,name,address, balance)  values (100001,'Allan Brooke','1 The Medows,Norwich, Norfolk',0);
insert into customer (cno,name,address, balance)   values (100002,'Ralph Morston','12 Plain Drive,Lowestoft',0);
insert into customer (cno,name,address, balance)   values (100003,'Marion Jones','The Cottage, Dunston',0);
insert into customer (cno,name,address, balance)   values (100004,'James Olivier','5 Livinstone Square, Birmigham',0);
insert into customer (cno,name,address, balance)  values (100005,'Moira Stewart','7 The Medows, Manchester',0);
insert into customer(cno,name,address, balance)   values (100006,'Jonathan Bircham','20 Oxford Street, London',0);
insert into customer (cno,name,address, balance)  values (100007,'Paula Newman','25 Mill Hill, London',0);
insert into customer (cno,name,address, balance) values (100008,'David Jones','11 St Georges, London',0);
insert into customer (cno,name,address, balance)   values (100009,'Patricia Lewis','101 High Street, Glasgow',0);
insert into customer (cno,name,address, balance) values (100010,'Martha Bramley','12 Catton Grove, Norwich',0);

insert into bookOrder (cno, bno, orderTime, qty) values (100001,100007,current_timestamp,4);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100006,current_timestamp,3);
insert into bookOrder (cno, bno, orderTime, qty) values (100003,100007,current_timestamp,2);
insert into bookOrder (cno, bno, orderTime, qty) values (100008,100005,current_timestamp,2);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100007,'2019-03-04 13:00:03',4);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100003,'2019-04-04 13:00:03',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100010,100007,'2019-04-08 12:00:03',1);
insert into bookOrder (cno, bno, orderTime, qty) values (100004,100004,'2019-05-09 12:00:03',10);
insert into bookOrder (cno, bno, orderTime, qty) values (100007,100010,'2019-04-09 16:00:03',5);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100005,'2019-04-09 16:00:03',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100010,'2019-05-03 15:00:00',4);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100002,'2019-06-03 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100003,100002,'2019-08-03 11:00:00',3);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100002,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100008,100001,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100004,100012,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100006,100013,'2019-08-05 11:00:00',1);
insert into bookOrder (cno, bno, orderTime, qty) values (100009,100001,'2019-08-05 11:00:00',2);
insert into bookOrder (cno, bno, orderTime, qty) values (100001,100008,'2019-08-05 11:00:00',2);



SET search_path to Libro_Database;

SELECT book.category, count(book.bno) AS noofbooks
FROM book
GROUP BY book.category
ORDER BY noofbooks ASC, category ASC;
