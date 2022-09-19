#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

APACHE_DIST_URLS=(
  "https://www.apache.org/dyn/closer.cgi?action=download&filename="
  # if the version is outdated (or we're grabbing the .asc file), we might have to pull from the dist/archive :/
  "https://www-us.apache.org/dist/"
  "https://www.apache.org/dist/"
  "https://archive.apache.org/dist/"
)

f="$1"; shift;
distFile="$1"; shift;
success=;
distUrl=;
for distUrl in "${APACHE_DIST_URLS[@]}"; do
    echo "Attempting to fetch $distFile from $distUrl"
    if wget -nv -O "$f" "$distUrl$distFile"; then
    success=1;
    break;
    fi;
done
[ -n "$success" ]
