# Task 3. Script checkes if there are open pull requests for a repository on GitHub.


## RUNING
```sh
	./task_html.sh https://github.com/ant-design/ant-design
```
OR
```sh
	./task_api.sh https://github.com/diasurgical/devilutionX
```
Any web-link to GitHub repository allowed instead url above.


## DESCRIPTION
* task_html.sh - download and parse HTML web-pages with pull requests to repository on GitHub
* task_api.sh - do the same but work with API of GitHub
* task.func - contains some basic functions


## FUNCTIONALITY
### Check and prepare reports:
* list of the most productive contributors (authors of more than 1 open PR)*
* list of users which PRs has created with the labels
* list of checks for every open PR*
*task_api.sh will show additional information about contributors, but will not show list of checks.


## WORKFLOW

### Check entred arguents
If no url entred then assuming user name and repository are diasurgical/devilutionX (link in example).

### Download web pages in HTML version
* Download first page and check if open pull requests do not fit on one page.
* Extract number of pages with open PR and download all pages sequentially.
### Download web pages in API version
* Download all data in json-format with open PR sequentially while response contain a data.

### Parse all downloaded pages (HTML version)
* Waits for first iteration of pull request on first stage of parsing.
* After that try to find user name, presence of a label and number of checks.
* Searching continues until next pull request iteration is found.
* When it happened, write the previosly found values ​​to the file.
* Its continues until the end of file. Then script step to the next file.
### Parse all downloaded json files (API version)
* Script easily extracts all needed data from all json files.

### Prepare reports based on result file
* Lists authors of more than one open PR with number of requests. Additionaly task_api will add to output name and numbers of public repositories of contributors.
* Lists all users who have at list one PR with the label.
* Lists user name and checks for every open PR which have that (only in HTML version of script).

### Save result file
* Suggests to save the result file. By default file will not saved.
* If user makes choice to save the file, by default result will saved in home user directory.


## task.func content
* inptchck() - check input argument, user and repository name should correspond GitHub rules
* tabs() - add additional tabs if output value length less than 16 characters
* pr_labels() - output user list whose PR with label
* save_result() - let user to save result file

