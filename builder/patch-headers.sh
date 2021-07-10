#!/bin/sh
set -e

# Patch headers paths to comply paths inside frameworks
sed -i '.bak' 's|#include "td/telegram/|#include "|g' ../td/td/telegram/td_json_client.h
sed -i '.bak' 's|#include "td/telegram/|#include "|g' ../td/td/telegram/td_log.h