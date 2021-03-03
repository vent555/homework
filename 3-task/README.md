# Task 3. Script checkes if there are open pull requests for a repository on GitHub.


## RUNING
```sh
	./task.sh https://github.com/ant-design/ant-design
```
Any web-link to GitHub repository allowed instead url above.


## FUNCTIONALITY
### Check and prepare reports:
* list of the most productive contributors (authors of more than 1 open PR)
* list of users which PRs has created with the labels
* list of checks for every open PR


## WORKFLOW

### Check entred arguents
If no url entred then assuming user name and repository are ant-design (link in example).

### Download web pages
* Download first page and check if open pull requests do not fit on one page.
* Extract number of pages with open PR and download all pages sequentially.

### Parse all downloaded pages
* Waits for first iteration of pull request on first stage of parsing.
* After that try to find user name, presence of a label and number of checks.
* Searching continues until next pull request iteration is found.
* When it happened, write the previosly found values ​​to the file.
* Its continues until the end of file. Then script step to the next file.

### Prepare reports based on result file
* Lists authors of more than one open PR with number of requests.
* Lists all users who have at list one PR with the label.
* Lists user name and checks for every open PR which have that.

### Save result file
* Suggests to save the result file. By default file will not saved.
* If user makes choice to save the file, by default result will saved in home user directory.
