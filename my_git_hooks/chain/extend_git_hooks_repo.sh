#!/bin/bash

# Create hook file
create_hook() {
	REPO_PATH=$1
	HOOK_FILE=$2
	cat <<EOT >> "$REPO_PATH/githooks/$HOOK_FILE"
#!/bin/bash

#############################
# This file is auto generated
#############################

BASEDIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
for h_file in \$BASEDIR/${HOOK_FILE}.d/${HOOK_FILE}.*
do
	if [ -f "\$h_file" ]
	then
		source \$h_file "\$@"
		h_file_return=\$?
		if [ \$h_file_return == 0 ]
		then
			echo "\$h_file --- SUCCESSFUL"
		else
			echo "\$h_file --- FAILED"
			exit \$h_file_return
		fi
	fi
done
EOT
	chmod +x "$REPO_PATH/githooks/$HOOK_FILE"
}

# Extend a specific hook
extend_hook() {

	REPO_PATH="$1"
	HOOK_FILE="$2"

	echo Extending $HOOK_FILE for the repository $REPO_PATH ...

	# If folder already exist
	if [ -d "$REPO_PATH/githooks/${HOOK_FILE}.d" ]
	then
		echo Skipped: ${HOOK_FILE}.d already exists
		return 1
	fi

	# Create folder
	mkdir "$REPO_PATH/githooks/${HOOK_FILE}.d"

	# If hook exist, move it to the new folder
	if [ -f "$REPO_PATH/githooks/$HOOK_FILE" ]
	then
		mv -v "$REPO_PATH/githooks/$HOOK_FILE" "$REPO_PATH/githooks/${HOOK_FILE}.d/${HOOK_FILE}.$(date +%s%N)"
	fi

	# Create hook file
	create_hook $REPO_PATH $HOOK_FILE

	echo Hook $HOOK_FILE extended successfully!
}

# Extend all hooks
extend_all_hooks() {
<<<<<<< HEAD

=======

>>>>>>> 2b031c544661bf65ddc044da994af1ae2ea43fc3
	REPO_PATH="$1"

	# If repo not found
	if ! [ -d "$REPO_PATH" ]
	then
		echo Repository $REPO_PATH was not found!
		return 1
	fi

	# Extend hooks
	extend_hook $REPO_PATH "applypatch-msg"
	extend_hook $REPO_PATH "commit-msg"
	extend_hook $REPO_PATH "post-update"
	extend_hook $REPO_PATH "pre-applypatch"
	extend_hook $REPO_PATH "pre-commit"
	extend_hook $REPO_PATH "prepare-commit-msg"
	extend_hook $REPO_PATH "pre-push"
	extend_hook $REPO_PATH "pre-rebase"
	extend_hook $REPO_PATH "update"
}

# Extend all hooks for provided repository
if [ -z "$1" ]
then
	echo Please specify the repository absolute path
else
	extend_all_hooks $1
<<<<<<< HEAD
fi
=======
fi
>>>>>>> 2b031c544661bf65ddc044da994af1ae2ea43fc3
