#!/bin/bash
mkdir -p ../dest/
rm -rf ../dest/*
index_file=$(find ./src -name Index)
path="${index_file%/Index}"
path="${path##*/src/}"

build_files()
{
	app_name="$1"
	file_path=$(find "./src" -wholename "*src/views*$app_name.vue" -print -quit)
	app_name="${app_name##*/}"

	type_name="${file_path##*/src/views/}"
	app_type="${type_name%%/*}"

	touch ".env.plugin${app_name}"
	echo "VITE_PLUGIN_ENTRY=${file_path}" >> ".env.plugin${app_name}"
	echo "VITE_PLUGIN_NAME=${app_type}/${app_name}_js" >> ".env.plugin${app_name}"
	echo "VITE_PLUGIN_FILENAME=plugin" >> ".env.plugin${app_name}"
	vite build --outDir ./.plugin/temp --config plugin.vite.config.js --mode "plugin${app_name}"
	status=$(echo $?)
	rm ".env.plugin${app_name}"
	[ $status -ne 0 ] && {
		cat package.json
		exit $status
	}
	md5=$(md5sum .plugin/temp/* | cut -d ' ' -f1)
	md5_sub=${md5:0:6}

	mkdir -p "../dest/$app_type"
	app_target="../dest/$app_type/${app_name}_${md5_sub}"
	if [ -f .plugin/temp/plugin.umd.js.gz ]; then
		cp .plugin/temp/plugin.umd.js.gz "$app_target.js.gz"
	elif [ -f .plugin/temp/plugin.umd.js ]; then
		cp .plugin/temp/plugin.umd.js "$app_target.js"
	fi

	if [ -f .plugin/temp/style.css.gz ]; then
		cp .plugin/temp/style.css.gz "$app_target.css.gz"
	elif [ -f .plugin/temp/style.css ]; then
		cp .plugin/temp/style.css "$app_target.css"
	fi
	menu_d_path="../files/usr/share/vuci/menu.d/"
	menu_d_file=$(ls $menu_d_path)
	sed -i "s/\/$app_name\"/\/${app_name}_${md5_sub}\"/g" $menu_d_path$menu_d_file
	rm -rf .plugin
}

if [ -n "$index_file" ]; then
	while IFS= read -r line || [[ -n "$line" ]];
	do
	  build_files $line
	done < ./src/"$path"/Index
else
	name=$(find "./src/" -name *.vue)
	filepath="${name%.*}"
	build_files "${filepath##*/}"
fi
