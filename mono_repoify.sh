#!/bin/bash
set -e

log_file=`pwd`/mono_repoify_log.txt
rm -f ${log_file}

echo_and_run() { 
    echo "\$ $*" 2>&1 | tee -a ${log_file} 
    "$@" >> ${log_file}  2>&1
}

#parent_remote="git@github.com:misko/ocp_mono_test.git"
parent_remote="git@github.com:Open-Catalyst-Project/ocp.git"
repos_and_relatives=`pwd`/repos_and_relatives.txt

{ cat repos_and_relatives.txt; echo; } | while read -r remote relative_path branch; 
do
    if [ -z "$branch"  ]; then
	   continue
    fi 
    echo "${parent_remote} / $relative_path <= $remote ($branch)"
done 

read -p "Continue [y/N]" ans
if [ "$ans" != "y" -a "$ans" != "Y" ]; then
    echo "Abort!"
    exit
fi

#download git filter repo
rm -f git-filter-repo
echo_and_run wget https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo
gfr=`pwd`/git-filter-repo


# #download the parent repo
echo_and_run git clone ${parent_remote} parent_repo
pushd parent_repo
git branch monorepo
git checkout monorepo
popd
#want to move the repo around here
pushd parent_repo
mkdir -p src/fairchem/core
git mv requirements.txt requirements-optional.txt configs ocpmodels/* scripts tests *.yml *.md *.py *.toml src/fairchem/core
rmdir ocpmodels
git commit -m 'move to new src folder'
echo_and_run git gc 
echo_and_run sleep 1
echo_and_run git gc 
echo_and_run git gc 
popd

echo_and_run mkdir sub_repos
echo_and_run pushd sub_repos
{ cat ${repos_and_relatives}; echo; }  | while read -r remote relative_path branch; 
do
    if [ -z "$branch"  ]; then
	   continue
    fi 
    repo_name=`basename $remote | sed 's/.git//g'`
    echo_and_run git clone --branch ${branch} $remote $repo_name

    echo_and_run pushd $repo_name

    # for some reason this doesn't always work the first time...
    echo_and_run git gc 
    echo_and_run sleep 1
    echo_and_run git gc 
    echo_and_run git gc 

    # rename the files in the git tree
    echo_and_run python $gfr --to-subdirectory-filter ${relative_path}

    echo_and_run popd
done 
echo_and_run popd

echo_and_run pushd parent_repo
{ cat ${repos_and_relatives}; echo; }  | while read -r remote relative_path branch; 
do
    if [ -z "$branch"  ]; then
	   continue
    fi 
    repo_name=`basename $remote | sed 's/.git//g'`
    echo "Merging $repo_name ($branch) $remote => $relative_path"
    echo_and_run git gc
    echo_and_run sleep 1
    echo_and_run git gc
    echo_and_run git gc
    echo_and_run git remote add -f ${repo_name} ../sub_repos/${repo_name} 
	echo_and_run git merge --allow-unrelated-histories ${repo_name}/${branch} 
	echo_and_run git remote remove ${repo_name}
done 
echo_and_run popd
