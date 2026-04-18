# DATA_QA_Project_US_Healthcaredata
This project focuses on building an end-to-end Healthcare Data Quality Assurance (QA) pipeline using SQL Server and Python. The objective of this project is to simulate real-world US healthcare claims data and perform data validation to identify inconsistencies, errors, and data quality issues.

📌 Project Overview

In this project, a Claims dataset was created in SQL Server, containing key healthcare fields such as:

claim_id
patient_id
provider_id
icd_code
cpt_code
service_date
billing_amount

Synthetic data was inserted into the table with intentional data quality issues, including:

Duplicate claim records
NULL values in critical fields
Invalid ICD and CPT codes
Negative and zero billing amounts
Future service dates
🧪 Data Quality Validation (SQL Layer)

Various SQL-based validation queries were developed to detect data issues such as:

ICD code format validation
CPT code structure validation
Duplicate claim detection
Billing amount anomaly detection
Missing or NULL value checks
Date consistency validation

These SQL queries simulate real-world healthcare data validation rules used in production systems.

🐍 Python Automation Layer

Python was used to automate the data extraction and validation process by connecting to SQL Server using pyodbc. The validated dataset was then processed using pandas to perform additional rule-based checks.

The following validations were performed in Python:

Identification of invalid ICD codes
Detection of invalid CPT codes
Negative billing amount detection
Future service date validation
Duplicate claim detection
📊 Reporting and Output Generation

All detected data quality issues were automatically exported into an Excel report using openpyxl. The report contains separate sheets for each type of issue, making it easy to analyze and review data quality problems.

The final output includes:

Raw dataset
Invalid ICD codes
Invalid CPT codes
Negative billing records
Future-dated service records
Duplicate claims
🔧 Technologies Used
SQL Server (Data storage and validation queries)
Python (Data processing and automation)
Pandas (Data manipulation and analysis)
Pyodbc (Database connectivity)
OpenPyXL (Excel report generation)
🎯 Key Learning Outcome

This project demonstrates a complete Data QA workflow similar to real-world US healthcare systems. It showcases skills in SQL data validation, Python automation, ETL testing, and healthcare domain data quality checks.
