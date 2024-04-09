#!/bin/bash
set -e

log_file=`pwd`/mono_repoify_log.txt
rm -f ${log_file}

echo_and_run() { 
    echo "\$ $*" 2>&1 | tee -a ${log_file} 
    "$@" >> ${log_file}  2>&1
}

parent_remote="git@github.com:misko/ocp_mono_test.git"

while read -r remote relative_path branch; 
do
    echo "${parent_remote} / $relative_path <= $remote ($branch)"
done < repos_and_relatives.txt

read -p "Continue [y/N]" ans
if [ "$ans" != "y" -a "$ans" != "Y" ]; then
    echo "Abort!"
    exit
fi

#download git filter repo
rm -f git-filter-repo
wget https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo
gfr=`pwd`/git-filter-repo


# #download the parent repo
# git clone ${parent_remote} parent_repo

mkdir sub_repos
pushd sub_repos
while read -r remote relative_path branch; 
do
    repo_name=`basename $remote | sed 's/.git//g'`
    echo_and_run git clone --branch ${branch} $remote $repo_name

    pushd $repo_name

    # for some reason this doesn't always work the first time...
    echo_and_run git gc 
    echo_and_run sleep 1
    echo_and_run git gc 
    echo_and_run git gc 

    # rename the files in the git tree
    echo_and_run python $gfr --to-subdirectory-filter ${relative_path}

    popd
done < ../repos_and_relatives.txt
popd

pushd parent_repo
while read -r remote relative_path branch; 
do
    repo_name=`basename $remote | sed 's/.git//g'`
    echo "Merging $repo_name ($branch) $remote => $relative_path"
    echo_and_run git gc
    echo_and_run sleep 1
    echo_and_run git gc
    echo_and_run git gc
    echo_and_run git remote add -f ${repo_name} ../sub_repos/${repo_name} 
	echo_and_run git merge --allow-unrelated-histories ${repo_name}/${branch} 
	echo_and_run git remote remove ${repo_name}
done < ../repos_and_relatives.txt
popd