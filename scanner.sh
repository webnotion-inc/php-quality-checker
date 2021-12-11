#!/bin/bash

source ./components/alerts.sh

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
        exit $output_status;
  fi
}

printSuccessText 'Code Quality Scan Result'

changed_files=$(git diff --name-status HEAD | sort | uniq | egrep '^(A|M|D)' | grep -E '.php$' | awk '{print $2;}')

stopExecutionIfNoFilesAreChanged $changed_files

printWarningAlert 'Running PHP code lint to check for PHP code syntax errors...'
runPhpLint $changed_files

printWarningAlert 'Running PHPStan to check PHP code logic errors...'
runPhpStan $changed_files

printWarningAlert 'Running CS Fixer to check PHP code style...'
runPhpCSFixer $changed_files

printSuccessAlert '\n\n DONE. Nice job! No errors found.\n'