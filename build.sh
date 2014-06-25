rm -rf target/*
cp -R * target
coffee --compile --output target/ ./