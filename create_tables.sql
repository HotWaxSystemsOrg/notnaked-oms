-- =========================
-- ORDER HEADER
-- =========================

-- Stores high-level order information
CREATE TABLE order_header (
    order_id VARCHAR(30) PRIMARY KEY,

    -- External reference (Shopify)
    external_order_id VARCHAR(100) NOT NULL, -- Shopify Order ID
    external_order_source VARCHAR(30) NOT NULL, -- SHOPIFY

    order_type_id VARCHAR(30) NOT NULL, -- SALES_ORDER
    order_name VARCHAR(100),
    status_id VARCHAR(30), -- ORDER_CREATED, ORDER_COMPLETED, ORDER_CANCELLED
    currency VARCHAR(10),

    order_date DATETIME NOT NULL,
    entry_date DATETIME,

    from_date DATE NOT NULL,
    thru_date DATE,

    UNIQUE (external_order_id, external_order_source)
);

-- =========================
-- ORDER ITEM
-- =========================

-- Stores individual line items
CREATE TABLE order_item (
    order_id VARCHAR(30) NOT NULL,
    order_item_seq_id VARCHAR(30) NOT NULL,
    product_id VARCHAR(30),
    product_variant_id VARCHAR(30),
    quantity DECIMAL(18,6) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    status_id VARCHAR(30),
    PRIMARY KEY (order_id, order_item_seq_id),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id)
);

-- =========================
-- ORDER ROLE
-- =========================

-- Associates parties to orders (customer, bill-to, ship-to)
CREATE TABLE order_role (
    order_id VARCHAR(30) NOT NULL,
    party_id VARCHAR(30) NOT NULL,
    role_type_id VARCHAR(30) NOT NULL, -- CUSTOMER, BILL_TO, SHIP_TO
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (order_id, party_id, role_type_id, from_date),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id),
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- =========================
-- ORDER STATUS
-- =========================

-- Tracks order lifecycle changes
CREATE TABLE order_status (
    order_id VARCHAR(30) NOT NULL,
    status_id VARCHAR(30) NOT NULL,
    status_datetime DATETIME NOT NULL,
    change_reason VARCHAR(255),
    PRIMARY KEY (order_id, status_datetime),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id)
);

-- =========================
-- ORDER ADJUSTMENT
-- =========================

-- Stores taxes, discounts, shipping charges, etc.
CREATE TABLE order_adjustment (
    order_adjustment_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    order_item_seq_id VARCHAR(30),
    adjustment_type_id VARCHAR(30) NOT NULL, -- TAX, SHIPPING, DISCOUNT
    amount DECIMAL(18,2) NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id)
);

-- =========================
-- ORDER ITEM SHIP GROUP
-- =========================

-- Groups items by shipping logic
CREATE TABLE order_item_ship_group (
    order_id VARCHAR(30) NOT NULL,
    ship_group_seq_id VARCHAR(30) NOT NULL,
    shipment_method VARCHAR(60),
    postal_contact_mech_id VARCHAR(30),
    PRIMARY KEY (order_id, ship_group_seq_id),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id),
    FOREIGN KEY (postal_contact_mech_id) REFERENCES contact_mech(contact_mech_id)
);

-- =========================
-- ORDER ITEM SHIP GROUP ASSOC
-- =========================

-- Associates items to ship groups
CREATE TABLE order_item_ship_group_assoc (
    order_id VARCHAR(30) NOT NULL,
    order_item_seq_id VARCHAR(30) NOT NULL,
    ship_group_seq_id VARCHAR(30) NOT NULL,
    quantity DECIMAL(18,6),
    PRIMARY KEY (order_id, order_item_seq_id, ship_group_seq_id),
    FOREIGN KEY (order_id) REFERENCES order_header(order_id)
);
