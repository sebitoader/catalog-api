-- ============================================================
-- SoftPrim Technology SRL — Exercițiu tehnic stagiu
-- Setup bază de date MySQL
-- ============================================================
-- Instrucțiuni:
--   1. Creează baza de date:  CREATE DATABASE softprim_test;
--   2. Importă acest fișier:  mysql -u root -p softprim_test < setup.sql
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- Tabel: categories
-- ============================================================
CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categories (id, name, slug) VALUES
  (1, 'Întrerupătoare automate', 'intrerupatoare-automate'),
  (2, 'Contoare electrice',      'contoare-electrice'),
  (3, 'Relee de monitorizare',   'relee-monitorizare'),
  (4, 'Tablouri electrice',      'tablouri-electrice'),
  (5, 'Conectori și accesorii',  'conectori-accesorii');

-- ============================================================
-- Tabel: products
-- ============================================================
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO products (category_id, name, price, stock) VALUES
  -- Întrerupătoare automate
  (1, 'Siguranță automată 1P+N 16A curba C',          45.50,  120),
  (1, 'Siguranță automată 1P+N 25A curba C',          52.00,  85),
  (1, 'Siguranță automată tetrapolară 4P 32A',       189.00,  40),
  (1, 'Siguranță automată diferențială 2P 25A 30mA', 145.50,  60),
  (1, 'AFDD detector arc electric 1P+N 16A',         320.00,  15),

  -- Contoare electrice
  (2, 'Contor electric monofazat digital 5(60)A',    175.00,  50),
  (2, 'Contor electric trifazat 3x230/400V',         420.00,  25),
  (2, 'Contor electric monofazat MID certificat',    245.00,  35),

  -- Relee de monitorizare
  (3, 'Releu monitorizare tensiune trifazat',        285.00,  30),
  (3, 'Releu monitorizare lipsa fază 3x400V',        210.50,  45),
  (3, 'Releu de timp multifuncțional 16 funcții',    165.00,  55),

  -- Tablouri electrice
  (4, 'Tablou electric metalic IP55 12 module',      189.00,  20),
  (4, 'Tablou inox IP65 24 module aplicat',          485.00,   8),
  (4, 'Tablou electric PVC 8 module aplicat',         55.00,  100),
  (4, 'Tablou metalic distribuție 36 module',        320.00,  18),

  -- Conectori și accesorii
  (5, 'Conector cupru-aluminiu 16-95 mmp',            28.50,  200),
  (5, 'Separator de sarcină 4P 63A tetrapolar',      145.00,  35),
  (5, 'Bară de nul cu 12 borne pentru tablou',        18.00,  150),
  (5, 'Cleme șir 2.5mmp gri (set 50 buc)',            32.00,  75),
  (5, 'Conector de derivație 6mmp izolat',             4.50,  500);

-- ============================================================
-- Tabel: orders
-- ============================================================
CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  customer_email VARCHAR(150) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Verificare rapidă
-- ============================================================
-- SELECT COUNT(*) AS total_categories FROM categories;  -- 5
-- SELECT COUNT(*) AS total_products FROM products;      -- 20
