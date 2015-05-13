
#!/bin/bash

if [ -z $1 ]; then
	sqlplus -s / as sysdba << EOF > /dev/null
set head off
SET TERMOUT OFF
spool /tmp/asmdiskgroup.txt
select  NAME, TOTAL_MB, FREE_MB from v\$asm_diskgroup;
spool off
exit;
EOF

	DATA=($(awk '{ print $1 }' /tmp/asmdiskgroup.txt))
	LAST=${DATA[${#DATA[@]} -1]}

	echo -e "{ \n \t\"data\": ["
	for i in "${DATA[@]}"; do
		if [ ${i} != ${LAST} ]; then
			echo -e '\t   { "{#ASMNAME}": "'$i'" },'
		else
			echo -e '\t   { "{#ASMNAME}": "'$i'" }'
		fi
	done
	echo -e '\t] \n}'
else
        sqlplus -s / as sysdba << EOF > /dev/null
set head off
SET TERM OFF
spool /tmp/asmdisk.txt
select  NAME, TOTAL_MB, FREE_MB from v\$asm_diskgroup where NAME='$1';
spool off
exit;
EOF
	if [ $2 == "asmname" ]; then
		echo $(awk '{ print $1 }' /tmp/asmdisk.txt)
	elif [ $2 == "asmtotal" ]; then
		echo $(awk '{ print $2 }' /tmp/asmdisk.txt)
	elif [ $2 == "asmfree" ]; then
		echo $(awk '{ print $3 }' /tmp/asmdisk.txt)
	fi
fi
