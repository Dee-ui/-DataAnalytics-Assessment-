-- Select adashi_database
USE adashi_staging;

-- Calculate tenure and total transaction volume
WITH customer_tx_summary AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        -- Calculate no of months since signup
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount) AS total_confirmed_amount
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, u.name, u.date_joined
),

-- Estimate the Customer Lifetime Value using given formula
clv_calc AS (
    SELECT *,
        -- Avoid divide-by-zero using NULLIF
        ROUND((total_transactions / NULLIF(tenure_months, 0)) * 12 * 0.001, 2) AS estimated_clv
    FROM customer_tx_summary
)

-- Output sorted CLV data
SELECT * 
FROM clv_calc
ORDER BY estimated_clv DESC;

/* Alias Breakdown
- u: alias for the users_customuser table (u.id means user ID).
- p1: alias for plans_plan used for savings plans (is_regular_savings = 1).
- s: alias for savings_savingsaccount, where transactions with 
confirmed_amount > 0 is filtered to focus on actual deposits.
- p2: this alias is for plans_plan again, but this time filtered to 
only investment plans (is_a_fund = 1).
*/
