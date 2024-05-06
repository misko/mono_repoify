find . -type f -name '*.py' | xargs sed -i 's/ocpmodels_root/fairchem_core_root/g'
find . -type f -name '*.py' | xargs sed -i 's/ocpmodels/fairchem.core/g'
find . -type f -name '*.py' | xargs sed -i 's/from ocpapi/from fairchem.demo.ocpapi/g'
find . -type f -name '*.py' | xargs sed -i 's/from ocdata/from fairchem.datagen.oc/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocpmodels/from fairchem.core/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocpapi/from fairchem.demo.ocpapi/g'
find . -type f -name '*.md' | xargs sed -i 's/from ocdata/from fairchem.datagen.oc/g'
sed -i 's@"fairchem.core"@"core"@g' src/fairchem/core/common/utils.py 
sed -i  's@^data$@/data\n/src/fairchem/data@g' .gitignore
git add -u 
git commit -m 'rename imports for monorepo'
git mv src/fairchem/demo/ocpapi/ocpapi/* ./src/fairchem/demo/ocpapi/
git mv src/fairchem/datagen/oc/ocdata/* ./src/fairchem/datagen/oc/
git add -u 
git commit -m 'folder promote ocpapi and open-catalyst-dataset'
cp -rf ../extras/.github ../extras/packages ../extras/src ./
git add -u
git commit -m 'fixes to workflow'
git add packages 
git commit -m 'add packages'
ruff check --fix --statistics --config packages/fairchem-core/pyproject.toml src/fairchem/core/
ruff check --fix --statistics --config packages/fairchem-datagen-oc/pyproject.toml src/fairchem/datagen/oc/
git add -u
git commit -m 'ruff fixes'
