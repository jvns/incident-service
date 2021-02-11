for i in $(flyctl apps list -j | jq -r  'map(select((.Name | startswith("puzzle")) and (.CurrentRelease.CreatedAt | now - fromdate  > 3600)) | .ID) | join("\\n")')
do
    flyctl destroy --yes $i
done
