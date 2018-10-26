pkgpath=$1

PKGCNT=`ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|wc -l`

if [ ${PKGCNT} -gt 6 ]
then
  echo "Removing old DIRs from Package Upload DIR..."
  ls -t ${pkgpath}|grep '[0-9]\{2\}[a-zA-Z]\{3\}[0-9]\{10\}'|awk 'NR>20'|xargs rm -rf 2>/dev/null
  echo
fi
