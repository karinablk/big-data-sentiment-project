
--creating table with cleaned data as a base for data analysis before model deployment
CREATE EXTERNAL TABLE IF NOT EXISTS `k1_lab`.`cleaned_data` (
  `id` string,
  `name` string,
  `username` string,
  `tweet` string,
  `followers_count` integer,
  `location` string,
  `geo` string,
  `created_at` string,
  `label` integer,
  `tweet_clean` string,
  `tweet_length` integer,
  `num_words` integer,
  `created_ts` timestamp,
  `created_date` string,
  `hour` integer,
  `weekday` integer,
  `sentiment_name` string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim' = '\t',
  'collection.delim' = '\u0002',
  'mapkey.delim' = '\u0003'
)
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://k1-blk/cleaned_data/'
TBLPROPERTIES (
  'skip.header.line.count' = '1'
);

-- creating table with predictions for the best model
CREATE EXTERNAL TABLE IF NOT EXISTS `k1_lab`.`predictions` (
  `id` string,
  `name` string,
  `username` string,
  `tweet` string,
  `followers_count` integer,
  `location` string,
  `geo` string,
  `created_at` string,
  `label` integer,
  `tweet_clean` string,
  `tweet_length` integer,
  `num_words` integer,
  `created_ts` timestamp,
  `created_date` string,
  `hour` integer,
  `weekday` integer,
  `sentiment_name` string,
  `prediction` integer
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim' = '\t',
  'collection.delim' = '\u0002',
  'mapkey.delim' = '\u0003'
)
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat' OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://k1-blk/prediction/'
TBLPROPERTIES ('skip.header.line.count' = '1');

-- creating table, that was used for word clouds
CREATE EXTERNAL TABLE IF NOT EXISTS `k1_lab`.`word_counts` (`label` integer,`word` string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim' = '\t',
  'collection.delim' = '\u0002',
  'mapkey.delim' = '\u0003'
)
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat' OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://k1-blk/word_counts/'
TBLPROPERTIES ('skip.header.line.count' = '1');

-- creating table based on word_counts for word cloud with limit 200 words (the option hide other in quicksight didn't work)
create or replace view top_200_words as
select word, COUNT(*) as count
from word_counts
where word != 'rt'
group by word
order by count desc
limit 200;

-- creating table based on word_counts, that was used for word clouds by sentiment
create or replace view top_200_words_labels AS
select *
from (
  select
    word,
    label,
    count(*) as count,
    row_number() over (partition by label order by count(*) desc) as rn
  from word_counts
  where word != 'rt'
  group by word, label
)
where rn <= 200;

-- creating table with data about unique tweets and retweets based on cleaned_data table
create or replace view tweet_numbers as
select 'Retweets' as type, count (*) as total
from cleaned_data
where tweet like 'RT %'

union all

select 'Unique tweets', count (distinct tweet)
from cleaned_data

union all

select 'Total tweets', count(*)
from cleaned_data;

-- top 10 retweets with sentiment
create or replace view retweets_analysis as
select tweet, sentiment_name, count(*) as count
from cleaned_data
group by tweet, sentiment_name
having count(*) > 1
order by count desc
limit 10;

-- table to show metrics of the model
create or replace view model_metrics as
select 'F1-score' as metric, 0.878 as value union all
select 'Accuracy', 0.879 union all
select 'Recall', 0.879 union all
select 'Precision', 0.879;

-- table to show accuracy level and percentage by sentiment
create or replace view class_accuracy as
select
    sentiment_name,
    count (*) as total,
    sum(case when label = prediction then 1 else 0 end) as correct,
    round(sum(case when label = prediction then 1 else 0 end) * 100 / count(*), 2) as accuracy_percent
from predictions
group by sentiment_name;


