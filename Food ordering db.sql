DROP DATABASE IF EXISTS food_ordering_db;
CREATE DATABASE food_ordering_db;
USE food_ordering_db;

CREATE TABLE CUSTOMER (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15)  NOT NULL UNIQUE,
    address         VARCHAR(255) NOT NULL
);

CREATE TABLE RESTAURANT (
    restaurant_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    phone           VARCHAR(15)  NOT NULL,
    address         VARCHAR(255) NOT NULL,
    rating          DECIMAL(2,1) DEFAULT 0.0 CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE MENU_ITEM (
    menu_item_id    INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id   INT NOT NULL,
    name            VARCHAR(100) NOT NULL,
    category        VARCHAR(50)  NOT NULL,
    price           DECIMAL(8,2) NOT NULL CHECK (price > 0),
    availability    BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_menuitem_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES RESTAURANT(restaurant_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ORDERS (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    restaurant_id   INT NOT NULL,
    order_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    status          ENUM('PLACED','CONFIRMED','PREPARING','OUT_FOR_DELIVERY','DELIVERED','CANCELLED')
                        NOT NULL DEFAULT 'PLACED',
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES RESTAURANT(restaurant_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ORDER_ITEM (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    menu_item_id    INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(8,2) NOT NULL CHECK (unit_price > 0),
    subtotal        DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderitem_menuitem
        FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEM(menu_item_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_order_menuitem UNIQUE (order_id, menu_item_id)
);

CREATE TABLE PAYMENT (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    payment_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount          DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    method          ENUM('CARD','UPI','CASH_ON_DELIVERY','WALLET') NOT NULL,
    status          ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE DELIVERY (
    delivery_id       INT AUTO_INCREMENT PRIMARY KEY,
    order_id          INT NOT NULL UNIQUE,
    delivery_address  VARCHAR(255) NOT NULL,
    delivery_status   ENUM('ASSIGNED','PICKED_UP','OUT_FOR_DELIVERY','DELIVERED','FAILED')
                          NOT NULL DEFAULT 'ASSIGNED',
    assigned_at       DATETIME NULL,
    delivered_at      DATETIME NULL,
    CONSTRAINT fk_delivery_order
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_menuitem_restaurant   ON MENU_ITEM(restaurant_id);
CREATE INDEX idx_orders_customer       ON ORDERS(customer_id);
CREATE INDEX idx_orders_restaurant     ON ORDERS(restaurant_id);
CREATE INDEX idx_orders_status         ON ORDERS(status);
CREATE INDEX idx_orderitem_order       ON ORDER_ITEM(order_id);
CREATE INDEX idx_payment_order         ON PAYMENT(order_id);
CREATE INDEX idx_delivery_order        ON DELIVERY(order_id);
CREATE INDEX idx_delivery_status       ON DELIVERY(delivery_status);

INSERT INTO CUSTOMER (name, email, phone, address) VALUES
('Aditi Rao',     'aditi.rao@example.com',     '9000000001', 'Flat 12, Green Residency, Hyderabad'),
('Rohan Mehta',   'rohan.mehta@example.com',   '9000000002', '45 MG Road, Bengaluru'),
('Sara Fernandes','sara.fernandes@example.com','9000000003', '7 Church Street, Goa'),
('Imran Sheikh',  'imran.sheikh@example.com',  '9000000004', '221 Park Lane, Mumbai');

INSERT INTO RESTAURANT (name, phone, address, rating) VALUES
('Spice Villa',        '8000000001', 'Banjara Hills, Hyderabad', 4.5),
('Green Leaf Kitchen',  '8000000002', 'Indiranagar, Bengaluru',   4.2),
('Coastal Curry House', '8000000003', 'Panjim, Goa',              4.7);

INSERT INTO MENU_ITEM (restaurant_id, name, category, price, availability) VALUES
(1, 'Paneer Butter Masala', 'Main Course', 220.00, TRUE),
(1, 'Butter Naan',          'Bread',        40.00, TRUE),
(1, 'Gulab Jamun',          'Dessert',      80.00, TRUE),
(2, 'Veg Buddha Bowl',      'Main Course', 260.00, TRUE),
(2, 'Cold-Pressed Juice',   'Beverage',     90.00, TRUE),
(3, 'Goan Fish Curry',      'Main Course', 320.00, TRUE),
(3, 'Prawn Balchao',        'Main Course', 350.00, FALSE);

INSERT INTO ORDERS (customer_id, restaurant_id, order_date, total_amount, status) VALUES
(1, 1, '2026-08-20 12:30:00', 0.00, 'DELIVERED'),
(2, 2, '2026-08-21 19:15:00', 0.00, 'DELIVERED'),
(1, 1, '2026-08-25 20:00:00', 0.00, 'OUT_FOR_DELIVERY'),
(3, 3, '2026-08-27 13:45:00', 0.00, 'PLACED');

INSERT INTO ORDER_ITEM (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 1, 1, 220.00),
(1, 2, 2, 40.00),
(2, 4, 1, 260.00),
(2, 5, 2, 90.00),
(3, 1, 2, 220.00),
(3, 3, 1, 80.00),
(4, 6, 1, 320.00);

INSERT INTO PAYMENT (order_id, payment_date, amount, method, status) VALUES
(1, '2026-08-20 12:31:00', 300.00, 'UPI',  'SUCCESS'),
(2, '2026-08-21 19:16:00', 440.00, 'CARD', 'SUCCESS'),
(3, '2026-08-25 20:01:00', 460.00, 'UPI',  'SUCCESS'),
(4, '2026-08-27 13:46:00', 320.00, 'CASH_ON_DELIVERY', 'PENDING');

INSERT INTO DELIVERY (order_id, delivery_address, delivery_status, assigned_at, delivered_at) VALUES
(1, 'Flat 12, Green Residency, Hyderabad', 'DELIVERED',        '2026-08-20 12:35:00', '2026-08-20 13:10:00'),
(2, '45 MG Road, Bengaluru',               'DELIVERED',        '2026-08-21 19:20:00', '2026-08-21 19:55:00'),
(3, 'Flat 12, Green Residency, Hyderabad', 'OUT_FOR_DELIVERY', '2026-08-25 20:05:00', NULL),
(4, '7 Church Street, Goa',                'ASSIGNED',         NULL, NULL);

UPDATE ORDERS o
SET o.total_amount = (
    SELECT COALESCE(SUM(oi.subtotal), 0)
    FROM ORDER_ITEM oi
    WHERE oi.order_id = o.order_id
);

UPDATE MENU_ITEM SET price = 230.00 WHERE menu_item_id = 1;

DELETE FROM MENU_ITEM WHERE menu_item_id = 7 AND availability = FALSE;

CREATE OR REPLACE VIEW vw_delivery_status_report AS
SELECT
    o.order_id,
    c.name           AS customer_name,
    c.phone          AS customer_phone,
    r.name           AS restaurant_name,
    o.order_date,
    o.total_amount,
    o.status         AS order_status,
    d.delivery_address,
    d.delivery_status,
    d.assigned_at,
    d.delivered_at
FROM ORDERS o
JOIN CUSTOMER   c ON c.customer_id   = o.customer_id
JOIN RESTAURANT r ON r.restaurant_id = o.restaurant_id
LEFT JOIN DELIVERY d ON d.order_id   = o.order_id;

CREATE OR REPLACE VIEW vw_restaurant_sales_summary AS
SELECT
    r.restaurant_id,
    r.name              AS restaurant_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue
FROM RESTAURANT r
LEFT JOIN ORDERS o ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name;

DELIMITER //

CREATE TRIGGER trg_orderitem_after_insert
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE ORDERS
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0) FROM ORDER_ITEM WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

CREATE TRIGGER trg_orderitem_after_delete
AFTER DELETE ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE ORDERS
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0) FROM ORDER_ITEM WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END //

CREATE TRIGGER trg_orderitem_before_insert
BEFORE INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    DECLARE is_available BOOLEAN;
    SELECT availability INTO is_available FROM MENU_ITEM WHERE menu_item_id = NEW.menu_item_id;
    IF is_available = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot order a menu item that is currently unavailable.';
    END IF;
END //

CREATE TRIGGER trg_delivery_after_update
AFTER UPDATE ON DELIVERY
FOR EACH ROW
BEGIN
    IF NEW.delivery_status = 'DELIVERED' AND OLD.delivery_status <> 'DELIVERED' THEN
        UPDATE ORDERS SET status = 'DELIVERED' WHERE order_id = NEW.order_id;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_available_menu(IN p_restaurant_id INT)
BEGIN
    SELECT menu_item_id, name, category, price
    FROM MENU_ITEM
    WHERE restaurant_id = p_restaurant_id AND availability = TRUE
    ORDER BY category, name;
END //

CREATE PROCEDURE sp_place_order (
    IN  p_customer_id     INT,
    IN  p_restaurant_id   INT,
    IN  p_menu_item_id    INT,
    IN  p_quantity        INT,
    IN  p_payment_method  VARCHAR(20),
    IN  p_delivery_address VARCHAR(255),
    OUT p_order_id        INT
)
BEGIN
    DECLARE v_unit_price DECIMAL(8,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT price INTO v_unit_price
    FROM MENU_ITEM
    WHERE menu_item_id = p_menu_item_id AND availability = TRUE
    FOR UPDATE;

    IF v_unit_price IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Menu item not found or unavailable.';
    END IF;

    INSERT INTO ORDERS (customer_id, restaurant_id, status)
    VALUES (p_customer_id, p_restaurant_id, 'PLACED');
    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO ORDER_ITEM (order_id, menu_item_id, quantity, unit_price)
    VALUES (p_order_id, p_menu_item_id, p_quantity, v_unit_price);

    INSERT INTO PAYMENT (order_id, amount, method, status)
    VALUES (p_order_id, v_unit_price * p_quantity, p_payment_method, 'PENDING');

    INSERT INTO DELIVERY (order_id, delivery_address, delivery_status)
    VALUES (p_order_id, p_delivery_address, 'ASSIGNED');

    COMMIT;
END //

DELIMITER ;

START TRANSACTION;

INSERT INTO ORDERS (customer_id, restaurant_id, status)
VALUES (2, 1, 'PLACED');
SET @new_order_id = LAST_INSERT_ID();

INSERT INTO ORDER_ITEM (order_id, menu_item_id, quantity, unit_price)
VALUES (@new_order_id, 2, 3, 40.00);

INSERT INTO PAYMENT (order_id, amount, method, status)
VALUES (@new_order_id, 120.00, 'CARD', 'SUCCESS');

COMMIT;

CREATE USER IF NOT EXISTS 'food_app_readonly'@'localhost' IDENTIFIED BY 'ChangeMe123!';
GRANT SELECT ON food_ordering_db.* TO 'food_app_readonly'@'localhost';

CREATE USER IF NOT EXISTS 'food_app_writer'@'localhost' IDENTIFIED BY 'ChangeMe456!';
GRANT SELECT, INSERT, UPDATE ON food_ordering_db.* TO 'food_app_writer'@'localhost';
REVOKE DELETE ON food_ordering_db.* FROM 'food_app_writer'@'localhost';

FLUSH PRIVILEGES;

SELECT oi.order_item_id, mi.name, oi.quantity, oi.unit_price, oi.subtotal
FROM ORDER_ITEM oi
JOIN MENU_ITEM mi ON mi.menu_item_id = oi.menu_item_id
WHERE oi.order_id = 1;

SELECT o.order_id, c.name AS customer, r.name AS restaurant,
       o.order_date, o.total_amount, o.status,
       p.method, p.status AS payment_status
FROM ORDERS o
JOIN CUSTOMER c   ON c.customer_id   = o.customer_id
JOIN RESTAURANT r ON r.restaurant_id = o.restaurant_id
LEFT JOIN PAYMENT p ON p.order_id    = o.order_id
ORDER BY o.order_date DESC;

SELECT mi.restaurant_id, mi.name, mi.price
FROM MENU_ITEM mi
WHERE mi.price > (
    SELECT AVG(mi2.price)
    FROM MENU_ITEM mi2
    WHERE mi2.restaurant_id = mi.restaurant_id
);

SELECT c.customer_id, c.name, COUNT(o.order_id) AS order_count
FROM CUSTOMER c
JOIN ORDERS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) > 1;

SELECT * FROM vw_delivery_status_report;

EXPLAIN SELECT * FROM ORDERS WHERE customer_id = 1;
