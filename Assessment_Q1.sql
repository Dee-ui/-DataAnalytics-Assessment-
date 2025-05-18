/* Goal: To Find customers with at least one funded savings plan 
AND one funded investment plan, sorted by total deposits. */

-- Select adashi_database
USE adashi_staging;

-- Fetch High-Value Customers with Multiple Products
SELECT 
    u.id AS owner_id,
    u.name,
    (
        SELECT COUNT(DISTINCT p1.id)
        FROM plans_plan p1
        WHERE p1.owner_id = u.id AND p1.is_regular_savings = 1
    ) AS savings_account,
    (
        SELECT COUNT(DISTINCT p2.id)
        FROM plans_plan p2
        WHERE p2.owner_id = u.id AND p2.is_a_fund = 1
    ) AS investment_count,
    SUM(sa.confirmed_amount) / 100 AS total_deposits
FROM users_customuser u
JOIN savings_savingsaccount sa ON u.id = sa.owner_id
WHERE sa.confirmed_amount > 0
GROUP BY u.id, u.name
HAVING savings_account > 0 AND investment_count > 0
ORDER BY total_deposits DESC;

/* Alias Breakdown
- u: alias for the users_customuser table (u.id means user ID).
- p1: alias for plans_plan used for savings plans (is_regular_savings = 1).
- s: alias for savings_savingsaccount, where transactions with 
confirmed_amount > 0 is filtered to focus on actual deposits.
- p2: this alias is for plans_plan again, but this time filtered to 
only investment plans (is_a_fund = 1).
*/