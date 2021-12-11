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
    printf "${GREEN_TEXT_START}$message${TEXT_COLOR_END}\n\n"
}

function printWarningText() {
    message=$1
    printf "${YELLOW_TEXT_START}$message${TEXT_COLOR_END}\n\n"
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