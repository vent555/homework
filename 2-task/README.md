# Task 2. Analize database and tell which March the price was the least volatile since 2015?


## DESCRIPTION
task.sh parse database of historical quotes for EUR/RUB pair to answer the question.

## WORKFLOW
* Script download and analise qoutes.json from https://yandex.ru/news/quotes/graph_2000.json
* Main cycle while parses all date-quote pair values and lookes for March.
* If March found then script start to calculate sum of all qoutes and also select min and max qoute in March of current year.
* Calculated values are written to the corresponding variables and the script goes to the next year.
* When database parsed, month valotile calculated and the script finds the minimum volatile value. 
* Min, max, mean and valotile values will displayed for March of every year from file.
* Finaly, script answers the question.
