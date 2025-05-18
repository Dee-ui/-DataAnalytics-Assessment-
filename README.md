# -DataAnalytics-Assessment-

## Cowrywise Data Analyst Technical Assessment

This repository contains my solutions to the technical assessment for the Data Analyst position at Cowrywise. The project involved writing SQL queries to extract business-critical insights (`High-Value Customers with Multiple Products`, `Transaction Frequency Analysis`, `Account Inactivity Alert` and perform `Customer Lifetime Value (CLV) Estimation`) from a MySQL database. 

All queries were executed using MySQL Workbench on a provided `adashi_staging database`.
This repository contains sql data analysis queries to get.

### 1. High-Value Customers with Multiple Products

**Objective:** 
- Find users who have both a funded savings plan and a funded investment plan, then sort them by total confirmed deposits.

**Approach:**
- Begin with the `users_customuser` table as the main table, representing each user.
- Use two subqueries:
    - One to count savings plans where `is_regular_savings = 1`.
    - Another to get investment plans where `is_a_fund = 1`.
- Join with the `savings_savingsaccount` table to get the actual deposit data (`confirmed_amount > 0`).
- Use `SUM(confirmed_amount)` to aggregate deposits and convert from kobo to naira (divide by 100).
- Filter for users that has at least one savings and one investment using a `HAVING` clause.
- Order the result by deposit value to get the highest-value customers.

**Why This is a Good Solution:**

- Using subqueries helps make sure that savings and investment plan counts are treated independently.
- The `GROUP BY` and `HAVING` clauses filter the correct data that should be focused on.
- Sorting highlights top-value candidates.

### 2. Transaction Frequency Analysis

**Objective:** 
- Calculate the average number of monthly transactions per user and categorize them into frequency groups/batches.

**Approach:**
- Use a CTE (`transaction_summary`) to:
      - Count all transactions per user.
      - Get the number of active months using the `PERIOD_DIFF()` function between the current month and first month transaction happened.
- A second CTE (`transaction_frequency`) calculates:
- Average monthly transactions: `total_transactions / active_months`.
- Frequency category using `CASE/WHEN` logic:
      - High ≥ 10 transactions/month
      - Medium ≥ 3 transactions/month
      - Low ≤ 2 transactions/month
- The final aggregation counts how many customers are in each category and their average frequency.

**Why This is a Good Solution:**
- CTEs allows transformation stage by stage: raw -> summary -> interpretation.
- Frequency buckets is in direction with typical marketing segmentation logic.

### 3. Account Inactivity Alert

**Objective:** 
- Get the savings/investment accounts with no inflow activity in the past year.

**Approach:**

- Start from the `plans_plan` table to get all potential user plans.
- Join the information to the `savings_savingsaccount` using a `LEFT JOIN` to ensure that plans with no transactions are included.
- Use the `MAX(transaction_date)` to get the latest activity per plan.
- Use the `DATEDIFF(CURDATE(), MAX(transaction_date))` to calculate for inactivity.
- Filter for plans where:
     - No transaction ever occurred, or
     - Last transaction was more than 365 days ago.

**Why This is a Good Solution:**
- Left join prevents exclusion of plans without transactions.
- `GROUP BY` ensures per-plan logic.
- This also makes it possible for proactive re-engagement strategies.

---

### 4. Customer Lifetime Value (CLV) Estimation

**Objective:** 
- Estimate customer lifetime value (CLV) based on average transaction profit and tenure.

**Approach:**
- First CTE (`customer_tx_summary`) helps us get:
     - Tenure using `TIMESTAMPDIFF()` between sign-up date and today.
     - Total confirmed transactions and value.
- Second CTE (`clv_calc`) applies the provided CLV formula where:
     - CLV = `(total_transactions / tenure) * 12 * 0.1%`
     - Uses `NULLIF(tenure, 0)` to avoid division by zero.
     - `ROUND()` keeps currency formatting.
- Final result is ordered by estimated CLV in descending order.

**Why This is a Good Solution:**
- Tenure-based analysis balances recent vs. long-term users.
- This simplified CLV helps gives priority to high-value segments.

### ⚠Challenges & Resolutions

| Question | Challenge                                                       | Resolution                                                                                 |
| -------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Q1       | I was encountering a **Query timeout or lost connection** due to subquery complexity.| To resolve this, I made filtering better by placing confirmed deposits in WHERE clause early and reducing joins|
| Q2       | I encountered **Divide-by-zero errors** from new signups with zero tenure.    | I Used `NULLIF()` safeguard in calculations to account for that              |
| Q3       | **Plans with no transactions** causing ambiguity in joins       | I used `LEFT JOIN` and `HAVING` clause to bring out non-active plans accurately.           |
| Q4       | **Skewed CLV from short-tenure users**                          | I capped edge cases using conditional logic and formatting with `ROUND()` function         |

---

### Tools Used

-  **SQL Workbench (MySQL 8.x)** for query design and testing
- **MySQL Server** for local database setup
- `.sql` file: restored into `adashi_staging` schema

---

### Notes

- All monetary values are in **kobo**. Convert by dividing by 100 where necessary.
- `confirmed_amount` used for inflow validation.
- `CURDATE()` function makes it possible to perform real-time comparisons.
- Foreign keys:
     - `owner_id` links users to plans and savings
     - `plan_id` links plans to savings
