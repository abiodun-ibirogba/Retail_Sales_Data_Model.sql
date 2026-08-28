# Retail Sales Data Model — PostgreSQL

## Overview
A relational database schema and analytical query set built in PostgreSQL,
modelling a retail business around a central Sales fact table connected to
three dimension tables: Stores, Products, and Customers.

## Schema
- **sales** — the fact table, holding every transaction (invoice, quantity,
  unit price, cost price, discount, total amount), with foreign keys into
  stores, products, and customers
- **stores** — store name, city, opening date
- **products** — product name, category, unit price
- **customers** — demographics, loyalty tier, registration date

## Queries Included
- Total and average revenue, overall and by product
- Revenue by product category
- Revenue by store location
- Yearly and monthly revenue trends (2023–2025)
- Revenue segmented by customer age band, gender, and loyalty tier
- A full multi-table join combining all four tables into one analytical view

## Tools Used
PostgreSQL

## Author
Ibirogba Abiodun Isaac | Data Analyst
📍 Lagos, Nigeria
🔗 [LinkedIn](https://linkedin.com/in/abiodun-ibirogba)
