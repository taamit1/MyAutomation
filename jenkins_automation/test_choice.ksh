uob_ear="EP_UB6000H0V25_fimdlb.ear"
uob_jar="Config_UB6000H0V25_fimdlb.jar"
fiid=fimdlb

arr[0]=/platform/${fiid}/EP/build/${uob_ear}
arr[1]=/platform/${fiid}/EP/build/${uob_jar}
#echo ${arr[*]}
file2scp=`echo ${arr[*]}`

echo ${file2scp}

pkg_ver=`echo ${uob_ear} | awk 'BEGIN { FS="_" }{ print $2 }' |awk -F"UB" '{print $2}'`
echo $pkg_ver
