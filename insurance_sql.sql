use insurance_db;

CREATE TABLE Opportunity (
    opportunity_name     VARCHAR(255),
    opportunity_id       VARCHAR(50),
    account_exe_id       INT,
    account_executive    VARCHAR(100),
    premium_amount       DECIMAL(15,2),
    revenue_amount       DECIMAL(15,2),
    closing_date         DATE,
    stage                VARCHAR(100),
    branch               VARCHAR(100),
    specialty            VARCHAR(255),
    product_group        VARCHAR(100),
    product_sub_group    VARCHAR(100),
    risk_details         VARCHAR(255)
);

CREATE TABLE Meeting (
    account_exe_id INT,
    account_executive VARCHAR(255),
    branch_name VARCHAR(255),
    global_attendees VARCHAR(255),
    meeting_date DATE,
    year INT
);

CREATE TABLE Invoice (
    invoice_number           BIGINT,
    invoice_date             DATE,
    revenue_transaction_type VARCHAR(50),
    branch_name              VARCHAR(100),
    solution_group           VARCHAR(255),
    account_exe_id           INT,
    account_executive        VARCHAR(100),
    income_class             VARCHAR(50),
    client_name              VARCHAR(255),
    policy_number            VARCHAR(100),
    amount                   DECIMAL(15,2),
    income_due_date          DATE
);

CREATE TABLE Individual_Budget (
    branch VARCHAR(255),
    account_exe_id INT,
    employee_name VARCHAR(255),
    new_role2 VARCHAR(255),
    new_budget DECIMAL(15,2),
    cross_sell_budget DECIMAL(15,2),
    renewal_budget DECIMAL(15,2)
);

CREATE TABLE Fees (
    client_name VARCHAR(255),
    branch_name VARCHAR(255),
    solution_group VARCHAR(255),
    account_exe_id INT,
    account_executive VARCHAR(255),
    income_class VARCHAR(100),
    amount DECIMAL(15,2),
    income_due_date DATE,
    revenue_transaction_type VARCHAR(100)
);


CREATE TABLE Brokerage (
    client_name              VARCHAR(255),
    policy_number            VARCHAR(100),
    policy_status            VARCHAR(50),
    policy_start_date        DATE,
    policy_end_date          DATE,
    product_group            VARCHAR(100),
    account_exe_id           INT,
    exe_name                 VARCHAR(100),
    branch_name              VARCHAR(100),
    solution_group           VARCHAR(255),
    income_class             VARCHAR(50),
    amount                   DECIMAL(15,2),
    income_due_date          DATE,
    revenue_transaction_type VARCHAR(50),
    renewal_status           VARCHAR(50),
    last_updated_date        DATE
);

select * from Brokerage;

select * from brokerage_c;
select * from fees_c;
select * from invoice_c;
select * from meeting_c;
select * from individual_bgt_c;
select * from opportunity_c;

#### Total amount from invoice
select income_class, CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') as Sum_of_Amount from invoice_c
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;
 
#### Total amount from brokerage
select income_class, CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') Sum_of_Amount from brokerage_c
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;

#### Total amount from fees
select income_class,CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') Sum_of_Amount from fees_c
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;
 
####Total amount from Budgets
select CONCAT(ROUND(SUM(`Cross sell bugdet`)/1000000, 2), ' M') as `Cross sell bugdet`, 
CONCAT(ROUND(SUM(`New budget`)/1000000, 2), ' M') as `New budget`,
CONCAT(ROUND(SUM(`Renewal budget`)/1000000, 2), ' M') as `Renewal budget`
from individual_bgt_c;

#### Total amount of Achievement
create table Achievement as
select income_class,CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') as Total_Amount from
(select income_class,amount from brokerage_c union all select income_class,amount from fees_c) as combined 
where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;
select * from Achievement;
##############################

#### Cross sell Sum across Invoice,Achievement,Target
select
(select CONCAT(ROUND(SUM(amount)/1000000, 2), ' M')  from invoice_c where income_class='Cross sell') Invoice,
(select concat( sum(Total_Amount),'M') from Achievement where income_class='Cross sell') Achievement,
(select CONCAT(ROUND(SUM(`Cross sell bugdet`)/1000000, 2), ' M')  Cross_sell_budget from individual_bgt_c) Target;
##########


#### New Sum across Invoice,Achievement,Target
select(select CONCAT(ROUND(SUM(amount)/1000000, 2), ' M')  from invoice_c where income_class='New') Invoice,
(select concat(sum(Total_Amount),"M") from Achievement where income_class='New') Achievement,
(select CONCAT(ROUND(SUM(`New budget`)/1000000, 2), ' M') New_budget from individual_bgt_c) Target;

#### Renewal Sum across Invoice,Achievement,Target
select(select CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') from invoice_c where income_class='Renewal') Invoice,
(select concat(sum(Total_Amount),"M") from Achievement where income_class='Renewal') Achievement,
(select CONCAT(ROUND(SUM(`Renewal budget`)/1000000, 2), ' M') Renewal_budget from individual_bgt_c) Target;


### Cross Sell Placed Ach%
select concat(round(((select sum(cast(replace(Total_Amount, 'M', '') as decimal(10,2))) from Achievement 
where income_class='Cross sell') / (select sum(`Cross sell bugdet`)/ 1000000 from individual_bgt_c))*100,2),'%')
 Cross_Sell_Placed_Ach;
 
### New Placed Ach%
select concat(round(((select sum(cast(replace(Total_Amount,'M','')as decimal(10,2))) from Achievement
 where income_class='New') / (select sum(`New budget`)/ 1000000 from individual_bgt_c))*100,2),'%')
New_Placed_Ach;

### Renewal Placed Ach%
select concat(round(((select sum(cast(replace(Total_Amount,'M','')as decimal(10,2))) from Achievement 
where income_class='Renewal') / (select sum(`Renewal budget`)/ 1000000 from individual_bgt_c ))*100,2),'%')
Renewal_Placed_Ach;

### Cross Sell Invoice Ach%
select concat(round(((select sum(Amount) from invoice_c
 where income_class='Cross sell') / (select sum(`Cross sell bugdet`) from individual_bgt_c))*100,2),'%')
Cross_Sell_Invoice_Ach;

### New Invoice Ach%
select concat(round(((select sum(Amount) from invoice_c
where income_class='New') / (select sum(`New budget`) from individual_bgt_c))*100,2),'%')
New_Invoice_Ach;


### Renewal Invoice Ach%
select concat(round(((select sum(Amount) from invoice_c
 where income_class='Renewal') / (select sum(`Renewal budget`) from individual_bgt_c))*100,2),'%')
Renewal_Invoice_Ach;

### Yearly Meeting Count
select Meeting_Year,count(*) Meeting_Count
from (
    select year(str_to_date(meeting_date, '%Y-%m-%d')) Meeting_Year
    from meeting_c) t
group by Meeting_Year
order by Meeting_Year;

###  No of meeting by Account Executive
select `Account Executive`,count(meeting_date) as count_of_meetingdate
 from meeting_c group by `Account Executive` order by count(meeting_date); 
 
 ### Count of Invoice by Account Executive
SELECT `Account Executive`,income_class,COUNT(invoice_date) AS invoice_count
FROM invoice_c GROUP BY income_class,`Account Executive` ORDER BY invoice_count DESC;

 ###  Total opportunities and Open opportunities
select count(stage) as Total_opportunities from opportunity_c;
select count(stage) as Total_Open_Opportunities from opportunity_c where stage in ('Propose Solution','Qualify Opportunity');

### Stage funnel by revenue
Select stage, sum(revenue_amount) AS Amount from opportunity_c Group By stage
ORDER BY Amount DESC;


### Top 5 Open-Opportunity by Revenue
select opportunity_name,revenue_amount from opportunity_c
 where stage IN ('Propose Solution','Qualify Opportunity') order by revenue_amount desc limit 5;

### Opportunity- Product Distribution
select product_group,count(opportunity_name) as Count_of_Opportunity_name 
from opportunity_c group by product_group order by count(opportunity_name) desc;

