-- Select adashi_database
USE adashi_staging;

-- Get the plans that has transaction activity and calculate inactivity period
SELECT 
    p.id AS plan_id,         -- Plan ID
    p.owner_id,              -- User ID

    -- Classify the plan type
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,

    -- Get the latest transaction date
    MAX(s.transaction_date) AS last_transaction_date,

    -- Get number of days since last transaction
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days

-- From the plans table
FROM plans_plan p

-- Join to savings account to access transactions
LEFT JOIN savings_savingsaccount s 
  ON p.id = s.plan_id

-- Filter only savings or investment plans
WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1

-- Group by plan
GROUP BY p.id, p.owner_id, type

-- Keep only plans with no transaction in the last 365 days
HAVING last_transaction_date IS NULL OR inactivity_days > 365;

/* Alias Breakdown
- u: alias for the users_customuser table (u.id means user ID).
- p1: alias for plans_plan used for savings plans (is_regular_savings = 1).
- s: alias for savings_savingsaccount, where transactions with 
confirmed_amount > 0 is filtered to focus on actual deposits.
- p2: this alias is for plans_plan again, but this time filtered to 
only investment plans (is_a_fund = 1).
*/