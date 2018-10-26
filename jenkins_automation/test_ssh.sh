echo "SVB US QA7"
ssh  -o StrictHostKeyChecking=no -i /packages/automation/.ssh/build-key ussvbq7@172.30.226.121 who
echo "SVB US QA2"
ssh  -o StrictHostKeyChecking=no -i /packages/automation/.ssh/build-key ussvbq2@172.30.226.80 who
echo "SVB US QA2 obcap47"
ssh  -o StrictHostKeyChecking=no -i /packages/automation/.ssh/build-key ussvbq2@172.30.226.88 who

