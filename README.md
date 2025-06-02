# Big Data Pipeline Project – Elon Musk Sentiment Analysis

This project demonstrates an end-to-end Big Data pipeline using AWS services. The goal was to process and analyze a real-world dataset of tweets mentioning Elon Musk to extract sentiment insights using scalable cloud tools.

## Objective

The main purpose of the project was to explore how to efficiently build a data pipeline in the cloud, covering:
- Scalable storage (Amazon S3)
- Data querying (Athena)
- Distributed processing (PySpark on Databricks)
- Dashboard visualization (QuickSight)

## Dataset Overview

- **Source**: Fetched tweets mentioning "Elon Musk"
- **Scope**: 2-day period, ~329,000 tweets
- **Sentiment**: Pre-labeled using VADER (Positive / Neutral / Negative)
- **Storage**: Stored as CSV in Amazon S3, processed in Databricks

## Architecture

The full pipeline consisted of:

1. **Data collection** (already fetched → uploaded to S3 bucket)
2. **AWS S3** – centralized data storage
3. **AWS Athena** – SQL querying and feature preparation
4. **Databricks (PySpark)** – scalable sentiment analysis & visualization
5. **AWS QuickSight** – dashboard creation & insights sharing

## Key Challenges

- Inconsistent formatting of scraped tweets (delimiters, merged columns)
- Class imbalance in sentiment labels (40% negative, 33% neutral, 27% positive)
- Risk of data leakage due to repeated retweets (chronological split applied)
- VADER sentiment analysis – efficient for social media, but context-limited

## Key Insights

- Tweets peak between 5 PM–11 PM
- Tuesday sees 2x more tweets than Monday
- Negative tweets tend to be longer; neutral tweets are shortest
- Vocabulary patterns vary significantly by sentiment class
- Most tweets were retweets; only 27% were unique

## Modeling Notes

A basic sentiment model using logistic regression was tested as part of the pipeline validation.  
While model performance was acceptable (F1 ≈ 88%), the focus of the project was on scalable data handling, not on maximizing model accuracy.

## Limitations

- Data covers only a 2-day window — longer periods would improve insights
- Databricks Community Edition limited compute performance
- VADER model was fast, but less nuanced than transformer-based alternatives

## Repository Contents

- `athena_sentiment_analysis.sql`: SQL queries for data visualization
- `notebook_pyspark_databricks.dbc`: PySpark notebook (Databricks)
- `elon_musk_sentiment_quicksight_dashboard.pdf`: Snapshot of dashboard
- `big_data_project_presentation.pdf`: Full project summary and visuals
