find . -type f -name '*.py' | xargs sed -i 's/ocpmodels_root/fairchem_core_root/g'
find . -type f -name '*.py' | xargs sed -i 's/ocpmodels/fairchem.core/g'
find . -type f -name '*.py' | xargs sed -i 's/from ocpapi/from fairchem.demo.ocpapi/g'
find . -type f -name '*.py' | xargs sed -i 's/from ocdata/from fairchem.data.oc/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocpmodels/from fairchem.core/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocpapi/from fairchem.demo.ocpapi/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocdata/from fairchem.data.oc/g'
sed -i 's@"fairchem.core"@"core"@g' src/fairchem/core/common/utils.py 
sed -i  's@^data$@/data\n/src/fairchem/data@g' .gitignore
git add -u 
git commit -m 'rename imports for monorepo'
git mv src/fairchem/demo/ocpapi/ocpapi/* ./src/fairchem/demo/ocpapi/
git mv src/fairchem/data/oc/ocdata/* ./src/fairchem/data/oc/
git add -u 
git commit -m 'folder promote ocpapi and open-catalyst-dataset'
cp -rf ../extras/.github ../extras/packages ../extras/src ../extras/README.md ../extras/main.py ../extras/LICENSE.md ./
git add main.py README.md LICENSE.md
git add -u
git commit -m 'fixes to workflow'
cp -f ../extras/src/fairchem/core/common/utils.py ./src/fairchem/core/common/
git add -u
git commit -m 'fix yaml load'
git add packages 
git commit -m 'add packages'
ruff check --fix --statistics --config packages/fairchem-core/pyproject.toml src/fairchem/core/
ruff check --fix --statistics --config packages/fairchem-data-oc/pyproject.toml src/fairchem/data/oc/
git add -u
git commit -m 'ruff fixes'
find src/ | grep .gitignore | xargs git rm 
find src/ | grep .pre-commit-config.yaml | xargs git rm 
git  commit -m 'remove unused gitignore and pre-commit-config'
git add README.md
git commit -m 'add temporary readme'
git add main.py
git commit -m 'add symlink for main.py'
