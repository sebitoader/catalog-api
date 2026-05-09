const express = require('express');
const pool = require('./db');
require('dotenv').config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// GET /api/products
app.get('/api/products', async (req, res) => {
    const { category_id } = req.query;

    if (category_id !== undefined) {
        const id = Number(category_id);
        if (!Number.isInteger(id) || id <= 0) {
            return res.status(400).json({ error: 'category_id trebuie sa fie un numar intreg pozitiv'});
        }
    }

    try {
        let query = `
            SELECT p.id, p.name, p.price, p.stock, p.category_id, c.name AS category_name
            FROM products p
            JOIN categories c on p.category_id = c.id
        `;
        const params = [];

        if (category_id !== undefined) {
            query += ' WHERE p.category_id = ?';
            params.push(Number(category_id));
        }

        const [rows] = await pool.query(query, params);
        return res.status(200).json(rows);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Eroare server' });
    }
});

// GET /api/products/:id
app.get('/api/products/:id', async(req, res) => {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
        return res.status(400).json({ error: 'id trebuie sa fie un numar intreg pozitiv'});
    }

    try {
        const [rows] = await pool.query(`
            SELECT p.id, p.name, p.price, p.stock, p.category_id, c.name AS category_name, p.created_at
            FROM products p
            JOIN categories c ON p.category_id = c.id
            WHERE p.id = ?
            `, [id]);
        
        if (rows.length == 0) {
            return res.status(404).json({ error: 'Produsul nu a putut fi gasit' });
        }

        const product = rows[0];
        product.created_at = product.created_at
            .toISOString()
            .slice(0, 19)
            .replace('T', ' ');
        return res.status(200).json(product);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Eroare server'});
    }
});

// POST /api/orders
app.post('/api/orders', async (req, res) => {
    const { product_id, quantity, customer_email } = req.body;

    // validari
    if (!Number.isInteger(product_id) || product_id <= 0) {
        return res.status(400).json({ error: 'product_id trebuie sa fie un numar intreg pozitiv'});
    }
    if (!Number.isInteger(quantity) || quantity <= 0) {
        return res.status(400).json({ error: 'quantity trebuie sa fie un numar intreg pozitiv'});
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!customer_email || !emailRegex.test(customer_email) || customer_email.length > 150) {
        return res.status(400).json({ error: 'customer_email invalid'});
    }

    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        // verificam daca avem produsul si daca e in stoc
        const [rows] = await conn.query('SELECT * FROM products WHERE id = ?', [product_id]);
        if (rows.length === 0) {
            await conn.rollback();
            conn.release();
            return res.status(404).json({ error: 'Produsul nu a fost gasit'});
        }

        const product = rows[0];
        if (quantity > product.stock) {
            await conn.rollback();
            conn.release();
            return res.status(400).json({ error: 'Stoc insuficient' });
        }

        const total = parseFloat((product.price * quantity).toFixed(2));

        // facem comanda
        const [orderResult] = await conn.query(
            'INSERT INTO orders (product_id, quantity, customer_email, total) VALUES (?, ?, ?, ?)',
            [product_id, quantity, customer_email, total]
        );

        // actualizam stocul
        await conn.query(
            'UPDATE products SET stock = stock - ? where id = ?',
            [quantity, product_id]
        );

        await conn.commit();
        conn.release();

        return res.status(201).json({
            order_id: orderResult.insertId,
            product_id,
            quantity,
            total,
            created_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
        })
    } catch (err) {
        await conn.rollback();
        conn.release();
        console.error(err);
        return res.status(500).json({ error: 'Eroare server' });
    }
});

app.listen(PORT, () => {
    console.log(`Serverul a pornit pe port ${PORT}`);
})