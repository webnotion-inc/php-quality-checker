#!/bin/bash

readonly RED_TEXT_START='\033[0;31m'
readonly GREEN_TEXT_START='\033[0;32m'
readonly YELLOW_TEXT_START='\033[0;33m'
readonly TEXT_COLOR_END='\033[0m'

readonly RED_BG_START='\e[0;41m'
readonly GREEN_BG_START='\e[0;42m'
readonly YELLOW_BG_START='\e[0;43m'
readonly BG_END='\e[0m'

function printSuccessText() {
    message=$1
    printf "${GREEN_TEXT_START}$message${TEXT_COLOR_END}\n"
}

function printWarningText() {
    message=$1
    printf "${YELLOW_TEXT_START}$message${TEXT_COLOR_END}\n"
}

function printErrorText() {
    message=$1
    printf "${RED_TEXT_START}$message${TEXT_COLOR_END}\n"
}

function printSuccessAlert() {
    message=$1
    printf "${GREEN_BG_START}$message${BG_END}\n"
}

function printWarningAlert() {
    message=$1
    printf "${YELLOW_BG_START}$message${BG_END}\n"
}

function printErrorAlert() {
    message=$1
    printf "${RED_BG_START}$message${BG_END}\n"
}

function printNewLine() {
    echo -e "\n"
}

function stopExecutionIfNoFilesAreChanged() {
  files=$@

  if [ -z "$files" ]
  then
        printWarningText 'Ignoring... No files changed.'
        exit 0;
  fi
}

function runPhpLint() {
  files=$@

  for file in files
  do
    php -l $file >> /dev/null
  done
}

function runPhpStan() {
  files=$@

  for file in files
  do
    output=$(bin/phpstan analyse -c phpstan.neon $files --no-progress)

    if [ ! $? -eq 0 ]; then
      printf "$output"
      printNewLine
      exit 1
    fi
  done
}

function runPhpCSFixer() {
  files=$@

  bin/php-cs-fixer fix --config .php-cs-fixer.dist.php --dry-run --stop-on-violation --using-cache=no --allow-risky=yes --diff $files

  if [ ! $? -eq 0 ]
  then
        printf '\nYou can fix style errors by running: '
        printWarningText "php bin/php-cs-fixer fix {/path/filename}"
        printNewLine
        exit 1
  fi
}

printSuccessText 'Code Quality Scan Result'

source_branch=$1
target_branch=$2

if [ -z "$source_branch" ] || [ -z "$target_branch" ]
then
  changed_files=$(git diff --name-status HEAD | sort | uniq | egrep '^(A|M|D)' | grep -E '.php$' | awk '{print $2;}')
else
  echo "Source branch name: $source_branch"
  echo "Target branch name: $target_branch"
  changed_files=$(git diff --name-status origin/$target_branch...origin/$source_branch | sort | uniq | egrep '^(A|M|D)' | grep -E '.php$' | awk '{print $2;}')
fi

stopExecutionIfNoFilesAreChanged $changed_files

printWarningAlert 'Running PHP code lint to check for PHP code syntax errors...'
runPhpLint $changed_files

printWarningAlert 'Running PHPStan to check PHP code logic errors...'
runPhpStan $changed_files

printWarningAlert 'Running CS Fixer to check PHP code style...'
runPhpCSFixer $changed_files

printSuccessAlert '\n\n DONE. Nice job! No errors found.\n'
exit 0