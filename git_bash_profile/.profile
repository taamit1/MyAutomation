# ------------ begin of script --------------
#!/bin/bash
target_drive=$(env | grep '!C:' | cut -d: -f3 | sed 's|\\|\/|g')
if [[ "${target_drive}" != "" ]]; then
    cd "/c/${target_drive}"
fi
set -o vi
#cd "C:\Users\atarwade\Documents\AOD\uob_infra_code_base"
# ------------ end of script --------------
