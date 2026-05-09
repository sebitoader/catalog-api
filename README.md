# catalog-produse

API REST pentru catalog produse si plasare comenzi, construit cu Node.js si MySQL.

## Tehnologii folosite

- Node.js v20
- Express 4
- MySQL 8.0
- mysql2 (pentru conectarea la baza de date)
- dotenv (pentru variabilele de mediu)

## Pasii de instalare

### 1. Instaleaza dependentele

```bash
npm install
```

### 2. Creaza baza de date si importa datele

```bash
mysql -u root -p -e "CREATE DATABASE softprim_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p softprim_test < setup.sql
```

### 3. Configureaza conexiunea la baza de date

Copiaza fisierul .env.example si redenumeste-l in .env:

```bash
cp .env.example .env
```

Apoi deschide .env si completeaza cu datele tale:
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=parola_ta_mysql
DB_NAME=softprim_test
PORT=3000

### 4. Porneste serverul

```bash
node index.js
```

Serverul porneste pe http://localhost:3000

---

## Exemple de apel

### GET /api/products — lista tuturor produselor

```bash
curl http://localhost:3000/api/products
```

Raspuns asteptat (200 OK):
```json
[
  {
    "id": 1,
    "name": "Siguranta automata 1P+N 16A curba C",
    "price": "45.50",
    "stock": 120,
    "category_id": 1,
    "category_name": "Intrerupatoare automate"
  }
]
```

Filtrare dupa categorie:

```bash
curl http://localhost:3000/api/products?category_id=2
```

Category_id invalid (400 Bad Request):

```bash
curl http://localhost:3000/api/products?category_id=abc
```

---

### GET /api/products/:id — un singur produs

```bash
curl http://localhost:3000/api/products/1
```

Raspuns asteptat (200 OK):
```json
{
  "id": 1,
  "name": "Siguranta automata 1P+N 16A curba C",
  "price": "45.50",
  "stock": 120,
  "category_id": 1,
  "category_name": "Intrerupatoare automate",
  "created_at": "2026-05-08 11:11:57"
}
```

Produs inexistent (404 Not Found):

```bash
curl http://localhost:3000/api/products/999
```

---

### POST /api/orders — plaseaza o comanda

```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2, "customer_email": "client@exemplu.ro"}'
```

Raspuns asteptat (201 Created):
```json
{
  "order_id": 1,
  "product_id": 1,
  "quantity": 2,
  "total": 91,
  "created_at": "2026-05-08 12:50:56"
}
```

Stoc insuficient (400 Bad Request):

```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"product_id": 5, "quantity": 999, "customer_email": "client@exemplu.ro"}'
```

Produs inexistent (404 Not Found):

```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"product_id": 999, "quantity": 1, "customer_email": "client@exemplu.ro"}'
```

---

## Decizii tehnice

Am ales Express si mysql2 pentru ca sunt cele mai simple si mai folosite in Node.js.
Nu am folosit niciun ORM  pentru ca am vrut sa scriu SQL direct si sa inteleg ce se intampla.
La endpoint-ul POST /api/orders am folosit o tranzactie SQL ca sa ma asigur ca
INSERT in orders si UPDATE la stock se intampla impreuna — daca una esueaza,
cealalta se anuleaza automat.
