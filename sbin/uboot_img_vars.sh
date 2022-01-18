#!bin/sh

get_uboot_vars ()
{
	active_bank=`uboot_env --get --name active_bank`
	[ $? -ne 0 ] && active_bank=""
	img_validA=`uboot_env --get --name img_validA`
	[ $? -ne 0 ] && img_validA=""
	img_validB=`uboot_env --get --name img_validB`
	[ $? -ne 0 ] && img_validB=""
	img_versionA=`uboot_env --get --name img_versionA`
	[ $? -ne 0 ] && img_versionA==""
	img_versionB=`uboot_env --get --name img_versionB`
	[ $? -ne 0 ] && img_versionB==""
	commit_bank=`uboot_env --get --name commit_bank`
	[ $? -ne 0 ] && commit_bank==""
	img_activate=`uboot_env --get --name img_activate`
	[ $? -ne 0 ] && img_activate=""

	str="
	{
		\"active_bank\" : \"${active_bank}\",
		\"img_validA\" : \"${img_validA}\",
		\"img_validB\" : \"${img_validB}\",
		\"img_versionA\" : \"${img_versionA}\",
		\"img_versionB\" : \"${img_versionB}\",
		\"commit_bank\" : \"${commit_bank}\",
		\"img_activate\" : \"${img_activate}\"
	}"
	echo $str
}

# Usage: set_img_valid A|B (1|0)
set_img_valid ()
{
	[ "$1" = "A" -o "$1" = "B" ] && {
		value=true
	        [ "$2" = "0" -o "$2" = "false" ] && value=false
		# Test if variable exists
		uboot_env --get --name img_valid$1
		if [ $? -ne 0 ]; then
			uboot_env --add --name img_valid$1 --value $value
		else
			uboot_env --set --name img_valid$1 --value $value
		fi
		[ $? -ne 0 ] && return 1
		return 0
	}
	return 1
}

# Usage: activate_img A|B
activate_img ()
{
	[ "$1" = "A" -o "$1" = "B" ] && {
		# Test if variable exists
		uboot_env --get --name img_activate
		if [ $? -ne 0 ]; then
			uboot_env --add --name img_activate --value $1
		else
			uboot_env --set --name img_activate --value $1
		fi
		[ $? -ne 0 ] && return 1
		return 0
	}
	return 1

}

# Usage: set_commit_bank A|B
set_commit_bank ()
{
	[ "$1" = "A" -o "$1" = "B" ] && {
		# Test if variable exists
		uboot_env --get --name commit_bank
		if [ $? -ne 0 ]; then
			uboot_env --add --name commit_bank --value $1
		else
			uboot_env --set --name commit_bank --value $1
		fi
		[ $? -ne 0 ] && return 1
		return 0
	}
	return 1
}


[ -n "$1" ] && {
	func="$1"
	shift
	$func $@ || >&-
}
