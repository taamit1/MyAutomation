success_code=1

  grep "ScriptingException" logfile >>/dev/null 2>&1
  if test $? -eq 0
  then
    echo "Deploy FAIL with Scripting exception"
    exit 2
  elif [ ${success_code} -eq 0 ]
	then
		echo "deploy Success"
	else
		echo "deploymet Failed"
		exit 1
  fi
