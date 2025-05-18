-- Select adashi_database
USE adashi_staging;

-- Calculate number of transactions and months active per user
WITH transaction_summary AS (
    SELECT 
        owner_id,    -- Link to the user
        COUNT(*) AS total_transactions,    -- Get the total number of transactions
        -- Calculate the number of months between the first transaction and today
        PERIOD_DIFF(DATE_FORMAT(NOW(), '%Y%m'), DATE_FORMAT(MIN(transaction_date), '%Y%m')) + 1 AS active_months
    FROM savings_savingsaccount
    GROUP BY owner_id
),

-- Get the average transactions per month and categorize
transaction_frequency AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 1) AS avg_tx_per_month,

        -- Categorize users based on their transaction frequency
        CASE
            WHEN total_transactions / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions / active_months >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM transaction_summary
)

-- Aggregate by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,                    -- Get how many customers in this category
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month -- Get their average frequency
FROM transaction_frequency
GROUP BY frequency_category;

/* Alias Breakdown
- u: alias for the users_customuser table (u.id means user ID).
- p1: alias for plans_plan used for savings plans (is_regular_savings = 1).
- s: alias for savings_savingsaccount, where transactions with 
confirmed_amount > 0 is filtered to focus on actual deposits.
- p2: this alias is for plans_plan again, but this time filtered to 
only investment plans (is_a_fund = 1).
*/
