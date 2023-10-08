#!/bin/bash

set -e

APP_FOLDER="applications"
find ./ -maxdepth 1 -type d -name "$APP_FOLDER" | grep -q . || APP_FOLDER="."

MAIN_FOLDER="vuci-ui-core/src/src"
CURRENT_TARGET="none"

# apps to exclude from linking
EXCLUDE=(
	"api-core"
	"vuci-app-landingpage"
	"vuci-i18n-*"
	"vuci-node"
	"vuci-ui-core"
)

TARGETS=(
	"none"
	"tsw"
	"tap"
)

help() {
cat << EOF
Link all application views and plugins to the main vuci-ui-core app. 
Usage: $0 [ACTION]

Actions:
	-l	Link all applications (default)
	-u	Unlink all linked source files
	-h	Print this help and exit
	-d	Link all applications for certain device tag { ${TARGETS[@]} }
EOF
}

folders=(
	"$MAIN_FOLDER/views/services"
	"$MAIN_FOLDER/views/system"
	"$MAIN_FOLDER/views/status"
	"$MAIN_FOLDER/views/network"
)

mkdir_safe() {
	local folder="$1"
	[ -d "$folder" ] || mkdir -p "$folder"
}

find_sources() {
	local dir=$1
	shift 1
	echo "find '${dir}/' \( -name '*.vue' -or -name '*.js' \) $*"
}

link() {
	for d in "${folders[@]}"; do
		mkdir_safe "$d"
	done

	local exclusions=""
	for i in "${EXCLUDE[@]}"; do
		exclusions="${exclusions} ! -path \"*/$i/*\""
	done

	local file_list=$(eval "$(find_sources "${APP_FOLDER}" "$exclusions")")
	readarray -t files <<<"$file_list"
	local filtered_files

	# logic based on tag
	if [[ $CURRENT_TARGET == "none" ]]; then
		# OPTIMIZE -------------------------
		local tag_files
		# finds all tagged services
		for app in "${files[@]}"; do
			for target in "${TARGETS[@]}"
			do
				if [[ $app == *-$target*  ]]; then
					tag_files+=($app)
				fi
			done
		done

		# removes duplicated services that have tags
		for app in "${files[@]}"; do
			for tag_app in "${tag_files[@]}"; do
				local found_duplicate=0
				if [[ $app == $tag_app ]]; then
					found_duplicate=1; break
				fi
			done
			if [[ $found_duplicate == 0 ]]; then
				filtered_files+=($app)
			fi
		done
		# OPTIMIZE -------------------------
	else
		local tag_folders
		# finds specific tagged service folders
		for app in "${files[@]}"; do
			# if app has the current target postfix, then the same app has to be found without postfix or with the different postfixes
			# so they could be removed 
			if [[ $app == *-$CURRENT_TARGET*  ]]; then
				# all targets are iterated to construct the apps with their postfixes
				for target in "${TARGETS[@]}"
				do
					# if current is the same as iterated it is skipped so it is not added to the list of apps to be removed
					if [[ $target == $CURRENT_TARGET ]]; then
						continue
					fi
					# removes the postfix of the device from the folder name so it could be matched later for removal
					folder="$(cut -d'/' -f2 <<<"$app")"
					# if target isn't 'none' then the prefix is added
					if [[  $target != "none" ]]; then
						folder="$folder-$target"
					fi
					formated_folder=${folder/-$CURRENT_TARGET/}
					# checks for duplicates
					if [[ ! " ${tag_folders[*]} " =~ " ${formated_folder} " ]]; then
						tag_folders+=($formated_folder)
					fi
				done
			fi
		done
		# filters out the matched folders an leaves only the ones with the device postfix
		filtered_files=("${files[@]}")
		for element in "${tag_folders[@]}"; do
			filtered_files=(${filtered_files[@]/*${element}\/*/})
		done
	fi

	for i in "${filtered_files[@]}"; do
		local file=$(basename "$i")
		[ "$file" = "Index" ] && break

		local directory="$(dirname "$i")"
		local subdirectory2=$(basename "$directory")
		local path=$(grep -o -E "/src/(.+$)" <<<"$directory" | tail -c +6)

		[ "$subdirectory2" = "plugins" ] && path="$subdirectory2"

		mkdir_safe "$MAIN_FOLDER/$path"
		ln -f "$i" "$MAIN_FOLDER/$path"
	done
}

unlink() {
	for arg in "$@"; do
		eval "$(find_sources "$arg" -type f -links +1) -exec rm '{}' ';'"
	done
}

ACTION="link"

while getopts "hlud:" o; do
	case "${o}" in
	l) ;;
	u) ACTION="unlink '$MAIN_FOLDER/views' '$MAIN_FOLDER/plugins'" ;;
	d) [[ $OPTARG == "rut" ]] || CURRENT_TARGET=${OPTARG} ;;
	h) help ;&
	*) exit 1 ;;
	esac
done

# check target validity
# A way to check if the array contains the value
if [[ ! " ${TARGETS[*]} " =~ " ${CURRENT_TARGET} " ]]; then
    echo "Incorrect target selected: '${CURRENT_TARGET}'. Available targets: ${TARGETS[@]}"
	exit 1
fi

eval "$ACTION"
